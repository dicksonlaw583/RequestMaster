function MultipartDataBuilder(_data) constructor {
	boundary = __multipart_generate_boundary__();
	data = _data;
	size = 0;
	static getBuffer = function() {
		var bodyBuffer = buffer_create(4096, buffer_grow, 1);
		buffer_write(bodyBuffer, buffer_text, "--");
		buffer_write(bodyBuffer, buffer_text, boundary);
		var keys = variable_struct_get_names(data);
		var nKeys = array_length(keys);
		for (var i = 0; i < nKeys; ++i) {
			var k = keys[i];
			var v = variable_struct_get(data, k);
			switch (typeof(v)) {
				case "string":
					buffer_write(bodyBuffer, buffer_text, "\r\n");
					buffer_write(bodyBuffer, buffer_text, "Content-Disposition: form-data; name=\"");
					buffer_write(bodyBuffer, buffer_text, k);
					buffer_write(bodyBuffer, buffer_text, "\"\r\n\r\n");
					buffer_write(bodyBuffer, buffer_text, v);
				break;
				case "struct":
					if (variable_struct_exists(v, "writeToMultipartBuffer") && is_method(v.writeToMultipartBuffer)) {
						v.writeToMultipartBuffer(bodyBuffer, k, boundary);
					} else {
						__multipart_write_substruct__(k, bodyBuffer, v, boundary);
					}
				break;
				case "array":
					__multipart_write_subarray__(k, bodyBuffer, v, boundary);
				break;
				case "method": break;
				default:
					buffer_write(bodyBuffer, buffer_text, "\r\n");
					buffer_write(bodyBuffer, buffer_text, "Content-Disposition: form-data; name=\"");
					buffer_write(bodyBuffer, buffer_text, k);
					buffer_write(bodyBuffer, buffer_text, "\"\r\n\r\n");
					buffer_write(bodyBuffer, buffer_text, string(v));
			}
			buffer_write(bodyBuffer, buffer_text, "\r\n--");
			buffer_write(bodyBuffer, buffer_text, boundary);
		}
		buffer_write(bodyBuffer, buffer_text, "--\r\n");
		size = buffer_tell(bodyBuffer);
		buffer_resize(bodyBuffer, size);
		return bodyBuffer;
	};
	static getHeaderMap = function() {
		var headerMap = ds_map_create();
		writeHeaderMap(headerMap);
		return headerMap;
	};
	static writeHeaderMap = function(map) {
		map[? "Content-Type"] = "multipart/form-data; boundary=" + boundary;
		map[? "Content-Length"] = string(size);
	};
}

function StringFilePart(_filename, _body) constructor {
	filename = _filename;
	mimeType = __multipart_get_mime_type__(filename_ext(filename));
	body = _body;
	static writeToMultipartBuffer = function(b, k, bd) {
		buffer_write(b, buffer_text, "\r\nContent-Disposition: form-data; name=\"");
		buffer_write(b, buffer_text, k);
		buffer_write(b, buffer_text, "\"; filename=\"");
		buffer_write(b, buffer_text, filename);
		buffer_write(b, buffer_text, "\"\r\nContent-Type: ");
		buffer_write(b, buffer_text, mimeType);
		buffer_write(b, buffer_text, "\r\n\r\n");
		buffer_write(b, buffer_text, body);
	};
}

function FilePart(_filepath) constructor {
	filepath = _filepath;
	mimeType = __multipart_get_mime_type__(filename_ext(filepath));
	static writeToMultipartBuffer = function(b, k, bd) {
		buffer_write(b, buffer_text, "\r\nContent-Disposition: form-data; name=\"");
		buffer_write(b, buffer_text, k);
		buffer_write(b, buffer_text, "\"; filename=\"");
		buffer_write(b, buffer_text, filename_name(filepath));
		buffer_write(b, buffer_text, "\"\r\nContent-Type: ");
		buffer_write(b, buffer_text, mimeType);
		buffer_write(b, buffer_text, "\r\n\r\n");
		var f = file_bin_open(filepath, 0);
		var siz = file_bin_size(f);
		repeat (siz) {
			buffer_write(b, buffer_u8, file_bin_read_byte(f));
		}
		file_bin_close(f);
	};
}

function BufferFilePart(_filename, _buffer) constructor {
	filename = _filename;
	mimeType = __multipart_get_mime_type__(filename_ext(filename));
	buffer = _buffer;
	bufferStart = 0;
	bufferSize = buffer_tell(buffer);
	static writeToMultipartBuffer = function(b, k, bd) {
		buffer_write(b, buffer_text, "\r\nContent-Disposition: form-data; name=\"");
		buffer_write(b, buffer_text, k);
		buffer_write(b, buffer_text, "\"; filename=\"");
		buffer_write(b, buffer_text, filename);
		buffer_write(b, buffer_text, "\"\r\nContent-Type: ");
		buffer_write(b, buffer_text, mimeType);
		buffer_write(b, buffer_text, "\r\n\r\n");
		var bt = buffer_tell(b);
		buffer_seek(buffer, buffer_seek_start, bufferStart);
		repeat (bufferSize) {
			buffer_write(b, buffer_u8, buffer_read(buffer, buffer_u8));
		}
		buffer_seek(buffer, buffer_seek_start, bt);
	};
}

function BufferPart(_buffer) constructor {
	buffer = _buffer;
	bufferStart = 0;
	bufferSize = buffer_tell(buffer);
	static writeToMultipartBuffer = function(b, k, bd) {
		buffer_write(b, buffer_text, "\r\nContent-Disposition: form-data; name=\"");
		buffer_write(b, buffer_text, k);
		buffer_write(b, buffer_text, "\"\r\n\r\n");
		var bt = buffer_tell(b);
		buffer_seek(buffer, buffer_seek_start, bufferStart);
		repeat (bufferSize) {
			buffer_write(b, buffer_u8, buffer_read(buffer, buffer_u8));
		}
		buffer_seek(buffer, buffer_seek_start, bt);
	};
}
