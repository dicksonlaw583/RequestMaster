///@func __jsons_hex_to_decimal__(hexstr)
///@param hexstr
///@desc Return the numeric value of the given hex string value
function __jsons_hex_to_decimal__(argument0) {
	var hex_string, hex_digits;
	hex_string = string_lower(argument0);
	hex_digits = "0123456789abcdef";

	//Convert digit-by-digit
	var i, len, digit_value, num;
	len = string_length(hex_string);
	num = 0;
	for (i=1; i<=len; i+=1) {
		digit_value = string_pos(string_char_at(hex_string, i), hex_digits)-1;
		if (digit_value >= 0) {
			num *= 16;
			num += digit_value;
		} 
		//Unknown character
		else {
			throw argument0;
		}
	}
	return num;
}
