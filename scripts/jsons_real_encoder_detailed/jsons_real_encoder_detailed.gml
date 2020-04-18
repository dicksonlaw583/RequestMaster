///@func jsons_real_encoder_detailed(val)
///@param val
///@desc Return a detailed string-form encode of the given real value, including scientific notification if not an integer
function jsons_real_encoder_detailed(argument0) {
	// Return straight string if it is an integer
	if (frac(argument0) == 0) {
		return string(argument0);
	}
	
	// Compute scientific notation otherwise
	var mantissa, exponent;
	exponent = floor(log10(abs(argument0)));
	mantissa = string_replace_all(string_format(argument0/power(10,exponent), 15, 14), " ", "");
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