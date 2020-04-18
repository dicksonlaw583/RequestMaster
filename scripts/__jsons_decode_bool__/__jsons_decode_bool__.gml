///@func __jsons_decode_bool__(@seekrec)
///@param @seekrec
function __jsons_decode_bool__(argument0) {
	if (string_copy(argument0.str, argument0.pos, 4) == "true") {
		argument0.pos += 3;
		return bool(true);
	}
	if (string_copy(argument0.str, argument0.pos, 5) == "false") {
		argument0.pos += 4;
		return bool(false);
	}
	throw new JsonStructParseException(argument0.pos, "Unexpected character in bool");
}
