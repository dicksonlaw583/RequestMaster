///@func __multipart_write_substruct__(prefix, buffer, data, boundary)
///@param prefix
///@param buffer
///@param data
///@param boundary
function __multipart_write_substruct__(argument0, argument1, argument2, argument3) {
	var keys = variable_struct_get_names(argument2);
	var nKeys = array_length(keys);
	for (var i = 0; i < nKeys; ++i) {
		var k = keys[i];
		var v = variable_struct_get(argument2, k);
		var ck = argument0 + "[" + k + "]";
		switch (typeof(v)) {
			case "string":
				buffer_write(argument1, buffer_text, "\r\n");
				buffer_write(argument1, buffer_text, "Content-Disposition: form-data; name=\"");
				buffer_write(argument1, buffer_text, ck);
				buffer_write(argument1, buffer_text, "\"\r\n\r\n");
				buffer_write(argument1, buffer_text, v);
			break;
			case "struct":
				if (variable_struct_exists(v, "writeToMultipartBuffer") && is_method(v.writeToMultipartBuffer)) {
					v.writeToMultipartBuffer(argument1, ck, argument3);
				} else {
					__multipart_write_substruct__(ck, argument1, v, argument3);
				}
			break;
			case "array":
				__multipart_write_subarray__(ck, argument1, v, argument3);
			break;
			case "method": break;
			default:
				buffer_write(argument1, buffer_text, "\r\n");
				buffer_write(argument1, buffer_text, "Content-Disposition: form-data; name=\"");
				buffer_write(argument1, buffer_text, ck);
				buffer_write(argument1, buffer_text, "\"\r\n\r\n");
				buffer_write(argument1, buffer_text, string(v));
		}
		if (i < nKeys-1) {
			buffer_write(argument1, buffer_text, "\r\n--");
			buffer_write(argument1, buffer_text, argument3);
		}
	}
}
