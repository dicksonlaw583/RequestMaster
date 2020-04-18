///@func __jsons_decode_undefined__(@seekrec)
///@param @seekrec
function __jsons_decode_undefined__(argument0) {
	if (string_copy(argument0.str, argument0.pos, 4) == "null") {
		argument0.pos += 3;
		return undefined;
	}
	throw new JsonStructParseException(argument0.pos, "Unexpected character in null");
}
