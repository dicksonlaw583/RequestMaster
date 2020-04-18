///@func __jsons_decode_struct__(@seekrec)
///@param @seekrec
function __jsons_decode_struct__(argument0) {
	// Setup
	var result = {};
	var keyMode = true;
	var key, val, c;
	// Keep seeking for new content
	do {
		c = __jsons_decode_seek__(argument0);
		// Accept only string keys in key mode
		if (keyMode) {
			if (c == "\"") {
				key = __jsons_decode_string__(argument0);
				c = __jsons_decode_seek__(argument0);
				if (c == ":") {
					keyMode = false;
				} else {
					throw new JsonStructParseException(argument0.pos, "Expected :");
				}
			} else if (c == "}") {
				break;	
			} else {
				throw new JsonStructParseException(argument0.pos, "Expected string key");
			}
		}
		// Accept anything else in value mode
		else {
			val = __jsons_decode_subcontent__(argument0);
			variable_struct_set(result, key, val);
			c = __jsons_decode_seek__(argument0);
			if (c == ",") {
				keyMode = true;
			} else if (c == "}") {
				break;
			} else {
				throw new JsonStructParseException(argument0.pos, "Expected , or }")
			}
		}
	} until (c == "}");
	// Done
	return result;
}
