///@func __multipart_write_subarray__(prefix, buffer, data, boundary)
///@param prefix
///@param buffer
///@param data
///@param boundary
function __multipart_write_subarray__(argument0, argument1, argument2, argument3) {
	var n = array_length(argument2);
	for (var i = 0; i < n; ++i) {
		var v = argument2[i];
		var ci = argument0 + "[" + string(i) + "]";
		switch (typeof(v)) {
			case "string":
				buffer_write(argument1, buffer_text, "\r\n");
				buffer_write(argument1, buffer_text, "Content-Disposition: form-data; name=\"");
				buffer_write(argument1, buffer_text, ci);
				buffer_write(argument1, buffer_text, "\"\r\n\r\n");
				buffer_write(argument1, buffer_text, v);
			break;
			case "struct":
				if (variable_struct_exists(v, "writeToMultipartBuffer") && is_method(v.writeToMultipartBuffer)) {
					v.writeToMultipartBuffer(argument1, ci, argument3);
				} else {
					__multipart_write_substruct__(ci, argument1, v, argument3);
				}
			break;
			case "array":
				__multipart_write_subarray__(ci, argument1, v, argument3);
			break;
			case "method": break;
			default:
				buffer_write(argument1, buffer_text, "\r\n");
				buffer_write(argument1, buffer_text, "Content-Disposition: form-data; name=\"");
				buffer_write(argument1, buffer_text, ci);
				buffer_write(argument1, buffer_text, "\"\r\n\r\n");
				buffer_write(argument1, buffer_text, string(v));
		}
		if (i < n-1) {
			buffer_write(argument1, buffer_text, "\r\n--");
			buffer_write(argument1, buffer_text, argument3);
		}
	}
}
