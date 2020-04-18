///@func __xwfu_char__(char)
///@param char
// Source: http://stackoverflow.com/questions/1805802/php-convert-unicode-codepoint-to-utf-8
function __xwfu_char__(argument0) {    
	//1-byte
	if (argument0 <= $7F) {
		return __xwfu_byte_to_hex__(argument0);
	}
	//2-byte
	else if (argument0 <= $7FF) {
		return __xwfu_byte_to_hex__((argument0>>6)+192) + __xwfu_byte_to_hex__((argument0&63)+128);
	}
	//3-byte
	else if (argument0 <= $FFFF) {
		return __xwfu_byte_to_hex__((argument0>>12)+224) + __xwfu_byte_to_hex__(((argument0>>6)&63)+128) + __xwfu_byte_to_hex__((argument0&63)+128);
	}
	//4-byte
	else if (argument0 <= $1FFFFF) {
		return __xwfu_byte_to_hex__((argument0>>18)+240) + __xwfu_byte_to_hex__(((argument0>>12)&63)+128) + __xwfu_byte_to_hex__(((argument0>>6)&63)+128) + __xwfu_byte_to_hex__((argument0&63)+128);
	}
	//Too long
	else {
		show_error("Invalid character U+" + string(argument0), true)
	}
}
