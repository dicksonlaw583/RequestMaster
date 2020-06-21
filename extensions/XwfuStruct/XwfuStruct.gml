#define __xwfu_byte_to_hex__
///@func __xwfu_byte_to_hex__(byte)
///@param byte
{
	var hexDigits = "0123456789ABCDEF";
	return "%" + string_char_at(hexDigits, (argument0>>4)+1) + string_char_at(hexDigits, (argument0&$F)+1)
}

#define __xwfu_char__
///@func __xwfu_char__(char)
///@param char
// Source: http://stackoverflow.com/questions/1805802/php-convert-unicode-codepoint-to-utf-8
{
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

#define __xwfu_encode_string__
///@func __xwfu_encode_string__(str)
///@param str
///@desc Return the URL-encoded version of the string
{
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

#define __xwfu_encode_subarray__
///@func __xwfu_encode_subarray__(prefix, val)
///@param prefix
///@param val
{
	// Error if size is 0
	var i, len, str;
	len = array_length(argument1);
	str = "";

	// Loop through all top-level keys
	for (var i = 0; i < len; ++i) {
		// Entry separator
		if (i > 0) {
			str += "&";
		}
		// Add the "key" (if applicable) and value
		var v = argument1[i];
		switch (typeof(v)) {
			case "string":
				str += argument0 + "%5B" + string(i) + "%5D=" + __xwfu_encode_string__(v);
			break;
			case "bool":
				str += argument0 + "%5B" + string(i) + "%5D=" + (v ? "true" : "false");
			break;
			case "struct":
				str += __xwfu_encode_substruct__(argument0 + "%5B" + string(i) + "%5D", v);
			break;
			case "array":
				str += __xwfu_encode_subarray__(argument0 + "%5B" + string(i) + "%5D", v);
			break;
			case "method": break;
			default:
				str += argument0 + "%5B" + string(i) + "%5D=" + __xwfu_encode_string__(string(v));
		}
	}

	// Done
	return str;
}

#define __xwfu_encode_substruct__
///@func __xwfu_encode_substruct__(prefix, val)
///@param prefix
///@param val
{
	var i, len, k, ks, keys, str;
	var isConflict = instanceof(argument1) == "JsonStruct";
	keys = isConflict ? argument1.keys() : variable_struct_get_names(argument1);
	len = array_length(keys);
	str = "";

	// Loop through all top-level keys
	for (var i = 0; i < len; ++i) {
		// Entry separator
		if (i > 0) {
			str += "&";
		}
		// Add the key (if applicable) and value
		k = keys[i];
		ks = __xwfu_encode_string__(k);
		var v = isConflict ? argument1.get(k) : variable_struct_get(argument1, k);
		switch (typeof(v)) {
			case "string":
				str += argument0 + "%5B" + ks + "%5D=" + __xwfu_encode_string__(v);
			break;
			case "bool":
				str += argument0 + "%5B" + ks + "%5D=" + (v ? "true" : "false");
			break;
			case "struct":
				str += __xwfu_encode_substruct__(argument0 + "%5B" + ks + "%5D", v);
			break;
			case "array":
				str += __xwfu_encode_subarray__(argument0 + "%5B" + ks + "%5D", v);
			break;
			case "method": break;
			default:
				str += argument0 + "%5B" + ks + "%5D=" + __xwfu_encode_string__(string(v));
		}
	}

	return str;
}

#define xwfu_encode
///@func xwfu_encode(thing)
///@param thing A string or struct
///@desc Return a URL-encoded string of the given string or struct
{
	if (is_string(argument0)) {
		return __xwfu_encode_string__(argument0);
	} else if (is_struct(argument0)) {
		var isConflict = instanceof(argument0) == "JsonStruct";
		var keys = isConflict ? argument0.keys() : variable_struct_get_names(argument0);
		var nKeys = array_length(keys);
		var str = "";
		for (var i = 0; i < nKeys; ++i) {
			if (i > 0) {
				str += "&";
			}
			var k = keys[i];
			var v = isConflict ? argument0.get(k) : variable_struct_get(argument0, k);
			var ks = __xwfu_encode_string__(k);
			switch (typeof(v)) {
				case "string":
					str += ks + "=" + __xwfu_encode_string__(v);
				break;
				case "bool":
					str += ks + "=" + (v ? "true" : "false");
				break;
				case "struct":
					str += __xwfu_encode_substruct__(ks, v);
				break;
				case "array":
					str += __xwfu_encode_subarray__(ks, v);
				break;
				case "method": break;
				default:
					str += ks + "=" + __xwfu_encode_string__(string(v));
			}
		}
		return str;
	} else {
		return __xwfu_encode_string__(string(argument0));
	}
}
