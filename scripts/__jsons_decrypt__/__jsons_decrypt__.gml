///@func _jsons_decrypt__(str, key)
///@param str
///@param key
function __jsons_decrypt__(argument0, argument1) {
	var buffer = buffer_base64_decode(argument0);
	__jsons_rc4__(buffer, string(argument1), 0, buffer_get_size(buffer));
	buffer_seek(buffer, buffer_seek_start, 0);
	var decoded = buffer_read(buffer, buffer_string);
	buffer_delete(buffer);
	return decoded;
}
