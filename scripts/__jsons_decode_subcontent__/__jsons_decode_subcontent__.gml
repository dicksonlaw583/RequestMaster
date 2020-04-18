///@func __jsons_decode_subcontent__(@seekrec)
///@param @seekrec
function __jsons_decode_subcontent__(argument0) {
	switch (ord(string_char_at(argument0.str, argument0.pos))) {
		case ord("{"):
			return __jsons_decode_struct__(argument0);
		break;
		case ord("["):
			return __jsons_decode_array__(argument0);
		break;
		case ord("\""):
			return __jsons_decode_string__(argument0);
		break;
		case ord("n"):
			return __jsons_decode_undefined__(argument0);
		break;
		case ord("t"): case ord("f"):
			return __jsons_decode_bool__(argument0);
		break;
		case ord("-"): case ord("1"): case ord("2"): case ord("3"): case ord("4"): case ord("5"): case ord("6"): case ord("7"): case ord("8"): case ord("9"): case ord("0"): case ord("+"):
			return __jsons_decode_real__(argument0);
		break;
		default:
			throw new JsonStructParseException(argument0.pos, "Unexpected character");
	}
}
