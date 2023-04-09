///@func jsons_real_encoder_detailed(val)
///@param {Real} val
///@return {String}
///@desc Return a detailed string-form encode of the given real value, including scientific notification if not an integer
function jsons_real_encoder_detailed(val) {
	// Return straight string if it is an integer
	if (frac(val) == 0) {
		return string(val);
	}

	// Compute scientific notation otherwise
	var mantissa, exponent;
	exponent = floor(log10(abs(val)));
	mantissa = string_replace_all(string_format(val/power(10,exponent), 15, 14), " ", "");
	var i, ca;
    i = string_length(mantissa);
	do {
		ca = string_char_at(mantissa, i);
		i -= 1;
	} until (ca != "0")
	if (ca != ".") {
		mantissa = string_copy(mantissa, 1, i+1);
	}
	else {
		mantissa = string_copy(mantissa, 1, i);
	}

	// Omit exponent if it is 0
	if (exponent != 0) {
		return mantissa + "e" + string(exponent);
	}
	else {
		return mantissa;
	}
}

///@func jsons_real_encoder_string_format(val)
///@param {Real} val
///@return {String}
///@desc Return the given real value in string form, with up to 15 decimal digits if needed
function jsons_real_encoder_string_format(val) {
	if (frac(val) == 0) return string(val);
	var result = string_replace_all(string_format(val, 30, 15), " ", "");
	var decimalPos = string_pos(".", result);
	var i;
	for (i = string_length(result); i > decimalPos && string_char_at(result, i) == "0"; --i) {}
	return string_copy(result, 0, i-(i==decimalPos));
}
