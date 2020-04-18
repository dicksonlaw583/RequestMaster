///@func jsons_decode(jsonstr)
///@param jsonstr
///@desc Decode the given JSON string back into GML 2020 native types
function jsons_decode(argument0) {
	// Seek to first active non-space character
	var seekrec = { str: argument0, pos: 0 };
	var c = __jsons_decode_seek__(seekrec);
	// Throw an exception if end of string reached without identifiable content
	if (c == "") throw new JsonStructParseException(seekrec.pos, "Unexpected end of string");
	// Decode to the correct type based on first sniffed character
	return __jsons_decode_subcontent__(seekrec);
}
