///@func __jsons_encrypt__(str, key)
///@param str
///@param key
function __jsons_encrypt__(argument0, argument1) {
	var length = string_byte_length(argument0);
	var buffer = buffer_create(length+1, buffer_fixed, 1);
	buffer_write(buffer, buffer_string, argument0);
	__jsons_rc4__(buffer, string(argument1), 0, buffer_tell(buffer));
	var encoded = buffer_base64_encode(buffer, 0, length);
	buffer_delete(buffer);
	return encoded;
}
