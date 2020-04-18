///@func __jsons_decode_array__(@seekrec)
///@param @seekrec
function __jsons_decode_array__(argument0) {
	// Setup
	var result = [];
	var val, c;
	var i = 0;
	// Keep seeking for new content
	do {
		c = __jsons_decode_seek__(argument0);
		if (c == "]") break;
		val = __jsons_decode_subcontent__(argument0);
		result[i++] = val;
		c = __jsons_decode_seek__(argument0);
		if (c == ",") {
			continue;
		} else if (c == "]") {
			break;
		} else {
			throw new JsonStructParseException(argument0.pos, "Expected , or ]");
		}
	} until (c == "]");
	// Done
	return result;
}
