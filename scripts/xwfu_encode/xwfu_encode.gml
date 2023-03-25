///@func __xwfu_byte_to_hex__(byte)
///@param {real} byte The byte value to convert.
///@return {string}
///@ignore
///@desc (INTERNAL: xwfu_encode) Convert the given byte value into a hex string value.
function __xwfu_byte_to_hex__(byte) {
	var hexDigits = "0123456789ABCDEF";
	return "%" + string_char_at(hexDigits, (byte>>4)+1) + string_char_at(hexDigits, (byte&$F)+1)
}

///@func __xwfu_char__(char)
///@param {string} char The character to encode.
///@return {string}
///@ignore
///@desc (INTERNAL: xwfu_encode) Percentage-encode the given character.
///
///Reference: http://stackoverflow.com/questions/1805802/php-convert-unicode-codepoint-to-utf-8
function __xwfu_char__(char) {
	//1-byte
	if (char <= $7F) {
		return __xwfu_byte_to_hex__(char);
	}
	//2-byte
	else if (char <= $7FF) {
		return __xwfu_byte_to_hex__((char>>6)+192) + __xwfu_byte_to_hex__((char&63)+128);
	}
	//3-byte
	else if (char <= $FFFF) {
		return __xwfu_byte_to_hex__((char>>12)+224) + __xwfu_byte_to_hex__(((char>>6)&63)+128) + __xwfu_byte_to_hex__((char&63)+128);
	}
	//4-byte
	else if (char <= $1FFFFF) {
		return __xwfu_byte_to_hex__((char>>18)+240) + __xwfu_byte_to_hex__(((char>>12)&63)+128) + __xwfu_byte_to_hex__(((char>>6)&63)+128) + __xwfu_byte_to_hex__((char&63)+128);
	}
	//Too long
	else {
		throw "Invalid character U+" + string(char);
	}
}

///@func __xwfu_encode_string__(str)
///@param {string} str The string to encode
///@return {string}
///@ignore
///@desc (INTERNAL: xwfu_encode) Return the URL-encoded version of the string.
function __xwfu_encode_string__(str) {
	// Setup
	var strlen = string_length(str);
	var buffer = buffer_create(strlen, buffer_grow, 1);
	// For each character
	for (var i = 1; i <= strlen; ++i) {
		var c = string_char_at(str, i);
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
	// Feather disable once GM1045
	return result;
}

///@func __xwfu_encode_subarray__(prefix, val)
///@param {string} prefix The prefix of the entry.
///@param {Array} val The array to encode.
///@return {string}
///@ignore
///@desc (INTERNAL: xwfu_encode) Return the URL-encoded form of the given array.
function __xwfu_encode_subarray__(prefix, val) {
	// Error if size is 0
	var i, len, str;
	len = array_length(val);
	str = "";

	// Loop through all top-level keys
	for (i = 0; i < len; ++i) {
		// Entry separator
		if (i > 0) {
			str += "&";
		}
		// Add the "key" (if applicable) and value
		var v = val[i];
		switch (typeof(v)) {
			case "string":
				str += prefix + "%5B" + string(i) + "%5D=" + __xwfu_encode_string__(v);
			break;
			case "bool":
				str += prefix + "%5B" + string(i) + "%5D=" + (v ? "true" : "false");
			break;
			case "struct":
				str += __xwfu_encode_substruct__(prefix + "%5B" + string(i) + "%5D", v);
			break;
			case "array":
				str += __xwfu_encode_subarray__(prefix + "%5B" + string(i) + "%5D", v);
			break;
			case "method": break;
			default:
				str += prefix + "%5B" + string(i) + "%5D=" + __xwfu_encode_string__(string(v));
		}
	}

	// Done
	return str;
}

///@func __xwfu_encode_substruct__(prefix, val)
///@param {string} prefix The prefix of the entry.
///@param {Struct} val The struct to encode.
///@return {string}
///@ignore
///@desc (INTERNAL: xwfu_encode) Return the URL-encoded form of the given struct.
function __xwfu_encode_substruct__(prefix, val) {
	var i, len, k, ks, keys, str;
	var isConflict = instanceof(val) == "JsonStruct";
	keys = isConflict ? val.keys() : variable_struct_get_names(val);
	len = array_length(keys);
	str = "";

	// Loop through all top-level keys
	for (i = 0; i < len; ++i) {
		// Entry separator
		if (i > 0) {
			str += "&";
		}
		// Add the key (if applicable) and value
		k = keys[i];
		ks = __xwfu_encode_string__(k);
		var v = isConflict ? val.get(k) : variable_struct_get(val, k);
		switch (typeof(v)) {
			case "string":
				str += prefix + "%5B" + ks + "%5D=" + __xwfu_encode_string__(v);
			break;
			case "bool":
				str += prefix + "%5B" + ks + "%5D=" + (v ? "true" : "false");
			break;
			case "struct":
				str += __xwfu_encode_substruct__(prefix + "%5B" + ks + "%5D", v);
			break;
			case "array":
				str += __xwfu_encode_subarray__(prefix + "%5B" + ks + "%5D", v);
			break;
			case "method": break;
			default:
				str += prefix + "%5B" + ks + "%5D=" + __xwfu_encode_string__(string(v));
		}
	}

	return str;
}

///@func xwfu_encode(thing)
///@param {String,Struct} thing A string or struct
///@return {string}
///@desc Return a URL-encoded string of the given string or struct
function xwfu_encode(thing) {
	if (is_string(thing)) {
		return __xwfu_encode_string__(thing);
	} else if (is_struct(thing)) {
		var isConflict = instanceof(thing) == "JsonStruct";
		var keys = isConflict ? thing.keys() : variable_struct_get_names(thing);
		var nKeys = array_length(keys);
		var str = "";
		for (var i = 0; i < nKeys; ++i) {
			if (i > 0) {
				str += "&";
			}
			var k = keys[i];
			var v = isConflict ? thing.get(k) : variable_struct_get(thing, k);
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
		return __xwfu_encode_string__(string(thing));
	}
}
