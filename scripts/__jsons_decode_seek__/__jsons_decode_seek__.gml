///@func __jsons_decode_seek__(@seekrec)
///@param @seekrec
function __jsons_decode_seek__(argument0) {
	var strlen = string_length(argument0.str);
	for (var i = argument0.pos+1; i <= strlen; ++i) {
		var c = string_char_at(argument0.str, i);
		if (!__jsons_is_whitespace__(c)) {
			argument0.pos = i;
			return c;
		}
	}
	argument0.pos = i;
	return "";
}
