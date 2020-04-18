///@func __xwfu_encode_string__(str)
///@param str
///@desc Return the URL-encoded version of the string
function __xwfu_encode_string__(argument0) {
	// Setup
	var strlen = string_length(argument0);
	var buffer = buffer_create(strlen, buffer_grow, 1);
	// For each character
	for (var i = 1; i <= strlen; ++i) {
		var c = string_char_at(argument0, i);
		var oc = ord(c);
		// Single byte characters
		if (oc < 128) {
			switch (oc) {
				case ord("$"): c = "%24"; break;
				case ord("&"): c = "%26"; break;
				case ord("+"): c = "%2B"; break;
				case ord(","): c = "%2C"; break;
				case ord("/"): c = "%2F"; break;
				case ord(":"): c = "%3A"; break;
				case ord(";"): c = "%3B"; break;
				case ord("="): c = "%3D"; break;
				case ord("!"): c = "%21"; break;
				case ord("?"): c = "%3F"; break;
				case ord("@"): c = "%40"; break;
				case ord(" "): c = "%20"; break;
				case ord("\""): c = "%22"; break;
				case ord("'"): c = "%27"; break;
				case ord("<"): c = "%3C"; break;
				case ord(">"): c = "%3E"; break;
				case ord("#"): c = "%23"; break;
				case ord("%"): c = "%25"; break;
				case ord("{"): c = "%7B"; break;
				case ord("}"): c = "%7D"; break;
				case ord("|"): c = "%7C"; break;
				case ord("\\"): c = "%5C"; break;
				case ord("^"): c = "%5E"; break;
				case ord("~"): c = "%7E"; break;
				case ord("["): c = "%5B"; break;
				case ord("]"): c = "%5D"; break;
				case ord("`"): c = "%60"; break;
			}
		}
		// Multi-byte characters
		else {
			c = __xwfu_char__(oc);
		}
		buffer_write(buffer, buffer_text, c);
	}
	// Done
	buffer_write(buffer, buffer_u8, 0);
	buffer_seek(buffer, buffer_seek_start, 0);
	var result = buffer_read(buffer, buffer_string);
	buffer_delete(buffer);
	return result;
}