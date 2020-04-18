///@func __jsons_decode_string__(@seekrec)
///@param @seekrec
function __jsons_decode_string__(argument0) {
	var buffer = buffer_create(64, buffer_grow, 1);
	var strlen = string_length(argument0.str);
	// Build string starting from next character
	var foundEnd = false;
	var escapeMode = false;
	for (var i = argument0.pos+1; !foundEnd && i <= strlen; ++i) {
		var c = string_char_at(argument0.str, i);
		if (escapeMode) {
			switch (c) {
				case @'"': case @"'": case @'\': case "/":
					buffer_write(buffer, buffer_text, c);
				break;
				case "n":
					buffer_write(buffer, buffer_text, "\n");
				break;
				case "r":
					buffer_write(buffer, buffer_text, "\r");
				break;
				case "t":
					buffer_write(buffer, buffer_text, "\t");
				break;
				case "u":
					if (strlen-i < 5) {
						throw new JsonStructParseException(i, "Invalid \\uxxxx string escape sequence");
					}
					try {
						buffer_write(buffer, buffer_text, chr(__jsons_hex_to_decimal__(string_copy(argument0.str, i+1, 4))));
					} catch (exc) {
						throw new JsonStructParseException(i, "Invalid hex " + string(exc) + " in \\uxxxx string escape sequence");
					}
					i += 4;
				break;
				case "b":
					buffer_write(buffer, buffer_text, "\b");
				break;
				case "f":
					buffer_write(buffer, buffer_text, "\f");
				break;
				case "v":
					buffer_write(buffer, buffer_text, "\v");
				break;
				case "a":
					buffer_write(buffer, buffer_text, "\a");
				break;
				default:
					throw new JsonStructParseException(i, "Invalid string escape sequence");
			}
			escapeMode = false;
		} else {
			switch (c) {
				case @'"': foundEnd = true; break;
				case @'\': escapeMode = true; break;
				default: buffer_write(buffer, buffer_text, c);
			}
		}
	}
	// Set seeker's position to loop's end
	--i;
	argument0.pos = i;
	// Throw error if string continues past end without close
	if (!foundEnd) {
		throw new JsonStructParseException(argument0.pos, "Expected \"");
	}
	// Done
	buffer_seek(buffer, buffer_seek_start, 0);
	var result = buffer_read(buffer, buffer_string);
	buffer_delete(buffer);
	return result;
}
