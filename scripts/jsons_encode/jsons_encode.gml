///@func jsons_encode(val)
///@param val
///@desc Encode the given value into JSON.
function jsons_encode(argument0) {
	var buffer, result, siz;
	switch (typeof(argument0)) {
		case "number":
			return JSONS_REAL_ENCODER(argument0);
		break;
		case "int64": case "int32":
			return string(argument0);
		break;
		case "string":
			siz = string_length(argument0);
			buffer = buffer_create(32, buffer_grow, 1);
			buffer_write(buffer, buffer_text, @'"');
			for (var i = 1; i <= siz; ++i) {
				var c = string_char_at(argument0, i);
				switch (ord(c)) {
					case ord("\""): //"
						c = @'\"';
					break;
					case ord("\n"): //\n
						c = @'\n';
					break;
					case ord("\r"): //\r
						c = @'\r';
					break;
					case ord("\\"): //\
						c = @'\\';
					break;
					case ord("\t"): //\t
						c = @'\t';
					break;
					case ord("\v"): //\v
						c = @'\v';
					break;
					case ord("\b"): //\b
						c = @'\b';
					break;
					case ord("\a"): //\a
						c = @'\a';
					break;
				}
				buffer_write(buffer, buffer_text, c);
			}
			buffer_write(buffer, buffer_string, @'"');
		break;
		case "array":
			buffer = buffer_create(64, buffer_grow, 1);
			siz = array_length(argument0);
			buffer_write(buffer, buffer_text, "[");
			for (var i = 0; i < siz; ++i) {
				if (i > 0) buffer_write(buffer, buffer_text, ",");
				buffer_write(buffer, buffer_text, jsons_encode(argument0[i]));
			}
			buffer_write(buffer, buffer_string, "]");
		break;
		case "struct":
			buffer = buffer_create(64, buffer_grow, 1);
			var keys = variable_struct_get_names(argument0);
			siz = array_length(keys);
			buffer_write(buffer, buffer_text, "{");
			for (var i = 0; i < siz; ++i) {
				var k = keys[i];
				if (i > 0) buffer_write(buffer, buffer_text, ",");
				buffer_write(buffer, buffer_text, jsons_encode(k));
				buffer_write(buffer, buffer_text, ":");
				buffer_write(buffer, buffer_text, jsons_encode(variable_struct_get(argument0, k)));
			}
			buffer_write(buffer, buffer_string, "}");
		break;
		case "bool":
			return argument0 ? "true" : "false";
		break;
		case "undefined":
			return "null";
		break;
		default:
			throw new JsonStructTypeException(argument0);
		break;
	}
	// Only strings, arrays and struct to make their way here
	buffer_seek(buffer, buffer_seek_start, 0);
	var result = buffer_read(buffer, buffer_string);
	buffer_delete(buffer);
	return result;
}
