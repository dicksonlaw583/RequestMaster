///@func jsons_real_encoder_string_format(val)
///@param val
///@desc Return the given real value in string form, with up to 15 decimal digits if needed
function jsons_real_encoder_string_format(argument0) {
	if (frac(argument0) == 0) return string(argument0);
	var result = string_replace_all(string_format(argument0, 30, 15), " ", "");
	var decimalPos = string_pos(".", result);
	for (var i = string_length(result); i > decimalPos && string_char_at(result, i) == "0"; --i) {}
	return string_copy(result, 0, i-(i==decimalPos));
}
