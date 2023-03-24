///@class MultipartDataBuilder(data, boundary=String)
///@param {Struct,Struct.JsonStruct} data The body data.
///@param {String} boundary (Optional) The boundary string to use.
///@desc Utility class for building multipart/form-data body buffers.
function MultipartDataBuilder(data, boundary=__multipart_generate_boundary__()) constructor {
	self.boundary = boundary;
	self.data = data;
	size = 0;
	
	///@func getBuffer()
	///@return {Id.Buffer}
	///@desc Return a multipart/form-data body buffer.
	static getBuffer = function() {
		var bodyBuffer = buffer_create(4096, buffer_grow, 1);
		buffer_write(bodyBuffer, buffer_text, "--");
		buffer_write(bodyBuffer, buffer_text, boundary);
		var isConflict = instanceof(data) == "JsonStruct";
		var keys = isConflict ? data.keys() : variable_struct_get_names(data);
		var nKeys = array_length(keys);
		for (var i = 0; i < nKeys; ++i) {
			var k = keys[i];
			var v = isConflict ? data.get(k) : variable_struct_get(data, k);
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
	
	///@func writeHeaderMap(map)
	///@param {Id.DsMap} map 
	///@desc Set headers applicable to multipart/form-data in the given header map.
	static writeHeaderMap = function(map) {
		map[? "Content-Type"] = "multipart/form-data; boundary=" + boundary;
		map[? "Content-Length"] = string(size);
	};
}

///@class StringFilePart(filename, body)
///@param {string} filename The file name reported in the request body.
///@param {string} body The contents of the simulated file.
///@desc A file part simulated by a string.
function StringFilePart(filename, body) constructor {
	self.filename = filename;
	mimeType = __multipart_get_mime_type__(filename_ext(filename));
	self.body = body;
	
	///@func writeToMultipartBuffer(b, k, bd)
	///@param {Id.Buffer} b The buffer to write to.
	///@param {string} k The key to write to.
	///@param {string} bd The boundary string to use.
	///@desc Write file data to the given buffer.
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

///@class FilePart(filepath)
///@param {string} filepath The file to attach.
///@desc A file part tied to a file at the binary level.
function FilePart(filepath) constructor {
	self.filepath = filepath;
	mimeType = __multipart_get_mime_type__(filename_ext(filepath));
	
	///@func writeToMultipartBuffer(b, k, bd)
	///@param {Id.Buffer} b The buffer to write to.
	///@param {string} k The key to write to.
	///@param {string} bd The boundary string to use.
	///@desc Write file data to the given buffer.
	static writeToMultipartBuffer = function(b, k, bd) {
		buffer_write(b, buffer_text, "\r\nContent-Disposition: form-data; name=\"");
		buffer_write(b, buffer_text, k);
		buffer_write(b, buffer_text, "\"; filename=\"");
		buffer_write(b, buffer_text, filename_name(filepath));
		buffer_write(b, buffer_text, "\"\r\nContent-Type: ");
		buffer_write(b, buffer_text, mimeType);
		buffer_write(b, buffer_text, "\r\n\r\n");
		var fb = buffer_load(filepath);
		var fbsize = buffer_get_size(fb);
		buffer_copy(fb, 0, fbsize, b, buffer_tell(b));
		buffer_delete(fb);
		buffer_seek(b, buffer_seek_relative, fbsize);
	};
}

///@class TextFilePart(filepath)
///@param {string} filepath The file to attach
///@desc A file part tied to a file at the text level.
function TextFilePart(filepath) constructor {
	self.filepath = filepath;
	newline = "\r\n";
	trailingNewline = false;
	if (argument_count > 1 && is_struct(argument[1])) {
		var opts = argument[1];
		var optKeys = variable_struct_get_names(opts);
		for (var i = array_length(optKeys)-1; i >= 0; --i) {
			var optKey = optKeys[i];
			switch (optKey) {
				case "newline": case "trailingNewline":
					variable_struct_set(self, optKey, variable_struct_get(opts, optKey));
				break;
			}
		}
	}
	mimeType = __multipart_get_mime_type__(filename_ext(filepath));
	
	///@func writeToMultipartBuffer(b, k, bd)
	///@param {Id.Buffer} b The buffer to write to.
	///@param {string} k The key to write to.
	///@param {string} bd The boundary string to use.
	///@desc Write file data to the given buffer.
	static writeToMultipartBuffer = function(b, k, bd) {
		buffer_write(b, buffer_text, "\r\nContent-Disposition: form-data; name=\"");
		buffer_write(b, buffer_text, k);
		buffer_write(b, buffer_text, "\"; filename=\"");
		buffer_write(b, buffer_text, filename_name(filepath));
		buffer_write(b, buffer_text, "\"\r\nContent-Type: ");
		buffer_write(b, buffer_text, mimeType);
		buffer_write(b, buffer_text, "\r\n\r\n");
		var pastFirstLine = false;
		var f;
		for (f = file_text_open_read(filepath); !file_text_eof(f); file_text_readln(f)) {
			if (pastFirstLine) {
				buffer_write(b, buffer_text, newline);
			} else {
				pastFirstLine = true;
			}
			buffer_write(b, buffer_text, file_text_read_string(f));
		}
		if (trailingNewline) {
			buffer_write(b, buffer_text, newline);
		}
		file_text_close(f);
	};
}

///@class BufferFilePart(filename, buffer)
///@param {string} filename The file name reported in the request body.
///@param {Id.Buffer} buffer The contents of the simulated file.
///@desc A file part simulated by a buffer.
function BufferFilePart(filename, buffer) constructor {
	self.filename = filename;
	mimeType = __multipart_get_mime_type__(filename_ext(filename));
	self.buffer = buffer;
	bufferStart = 0;
	bufferSize = buffer_tell(buffer);
	
	///@func writeToMultipartBuffer(b, k, bd)
	///@param {Id.Buffer} b The buffer to write to.
	///@param {string} k The key to write to.
	///@param {string} bd The boundary string to use.
	///@desc Write file data to the given buffer.
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

///@class BufferPart(buffer)
///@param {Id.Buffer} buffer The buffer to use.
///@desc A field value represented by a buffer.
function BufferPart(buffer) constructor {
	self.buffer = buffer;
	bufferStart = 0;
	bufferSize = buffer_tell(buffer);
	
	///@func writeToMultipartBuffer(b, k, bd)
	///@param {Id.Buffer} b The buffer to write to.
	///@param {string} k The key to write to.
	///@param {string} bd The boundary string to use.
	///@desc Write file data to the given buffer.
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
