///@func __xwfu_byte_to_hex__(byte)
///@param byte
function __xwfu_byte_to_hex__(argument0) {
	var hexDigits = "0123456789ABCDEF";
	return "%" + string_char_at(hexDigits, (argument0>>4)+1) + string_char_at(hexDigits, (argument0&$F)+1)
}
