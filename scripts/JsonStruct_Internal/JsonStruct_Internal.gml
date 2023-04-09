///@func __jsons_decode_array__(seekrec, safe)
///@param {Struct} seekrec
///@param {Bool} safe Whether safe mode is enabled.
///@return {Array}
///@ignore
///@desc (INTERNAL: JsonStruct) Decode the upcoming array value.
function __jsons_decode_array__(seekrec, safe) {
	// Setup
	var result = [];
	var val, c;
	var i = 0;
	// Keep seeking for new content
	do {
		c = __jsons_decode_seek__(seekrec);
		if (c == "]") break;
		val = __jsons_decode_subcontent__(seekrec, safe);
		result[i++] = val;
		c = __jsons_decode_seek__(seekrec);
		if (c == ",") {
			continue;
		} else if (c == "]") {
			break;
		} else {
			throw new JsonStructParseException(seekrec.pos, "Expected , or ]");
		}
	} until (c == "]");
	// Done
	///Feather disable GM1045
	return result;
	///Feather enable GM1045
}

///@func __jsons_decode_bool__(seekrec)
///@param {Struct} seekrec
///@return {Bool}
///@ignore
///@desc (INTERNAL: JsonStruct) Decode the upcoming Boolean value.
function __jsons_decode_bool__(seekrec) {
	if (string_copy(seekrec.str, seekrec.pos, 4) == "true") {
		seekrec.pos += 3;
		return bool(true);
	}
	if (string_copy(seekrec.str, seekrec.pos, 5) == "false") {
		seekrec.pos += 4;
		return bool(false);
	}
	throw new JsonStructParseException(seekrec.pos, "Unexpected character in bool");
}

///@func __jsons_decode_real__(seekrec)
///@param {Struct} seekrec
///@return {Real}
///@ignore
///@desc (INTERNAL: JsonStruct) Decode the upcoming numeric value.
function __jsons_decode_real__(seekrec) {
	var i = seekrec.pos;
	var len = string_length(seekrec.str);
	var c = string_char_at(seekrec.str, i);
	// Determine starting state
	var state;
	switch (c) {
		case "+": case "-":
			state = 0;
		break;
		default:
			state = 1;
		break;
	}
	var str = c;
	++i;
	// Loop until no more digits found
	var done = false;
	for (i = i; !done && i <= len; ++i) {
		c = string_char_at(seekrec.str, i);
		// Parsing logic adapted from JSOnion
		switch (state) {
			//0: Found a sign, looking for a starting number
			case 0:
				switch (c) {
					case "0": case "1": case "2": case "3": case "4": case "5": case "6": case "7": case "8": case "9":
						str += c;
						state = 1;
					break;
					default:
						throw new JsonStructParseException(i, "Expecting a digit");
				}
			break;
			//1: Found a starting digit, looking for decimal dot, e, E, or more digits
			case 1:
				if (__jsons_is_whitespace__(c)) || (string_pos(c, ":,]}") > 0) {
					done = true;
					--i;
				} else {
					switch (c) {
						case "0": case "1": case "2": case "3": case "4": case "5": case "6": case "7": case "8": case "9":
							str += c;
						break;
						case ".":
							str += c;
							state = 2;
						break;
						case "e": case "E":
							str += c;
							state = 3;
						break;
						default:
							throw new JsonStructParseException(i, "Expecting a dot, e, E or a digit");
					}
				}
			break;
			//2: Found a decimal dot, looking for more digits
			case 2:
				switch (c) {
					case "0": case "1": case "2": case "3": case "4": case "5": case "6": case "7": case "8": case "9":
						str += c;
						state = -2;
					break;
					default:
						throw new JsonStructParseException(i, "Expecting a digit");
				}
			break;
			//-2: Found a decimal dot and a digit after it, looking for more digits, e, or E
			case -2:
				if (__jsons_is_whitespace__(c)) || (string_pos(c, ":,]}") > 0) {
					done = true;
					--i;
				} else {
					switch (c) {
						case "0": case "1": case "2": case "3": case "4": case "5": case "6": case "7": case "8": case "9":
							str += c;
						break;
						case "e": case "E":
							str += c;
							state = 3;
						break;
						default:
							throw new JsonStructParseException(i, "Expecting an e, E or a digit");
					}
				}
			break;
			//3: Found an e/E, looking for +, - or more digits
			case 3:
				switch (c) {
					case "+": case "-":
						str += c;
						state = 4;
					break;
					case "0": case "1": case "2": case "3": case "4": case "5": case "6": case "7": case "8": case "9":
						str += c;
						state = 5;
					break;
					default:
						throw new JsonStructParseException(i, "Expecting a +, - or a digit");
				}
			break;
			//4: Found an e/E exponent sign, looking for more digits
			case 4:
				switch (c) {
					case "0": case "1": case "2": case "3": case "4": case "5": case "6": case "7": case "8": case "9":
						str += c;
						state = 5;
					break;
					default:
						throw new JsonStructParseException(i, "Expecting a digit");
				}
			break;
			//5: Looking for final digits of the exponent
			case 5:
				if (__jsons_is_whitespace__(c)) || (string_pos(c, ":,]}") > 0) {
					done = true;
					--i;
				} else {
					switch (c) {
						case "0": case "1": case "2": case "3": case "4": case "5": case "6": case "7": case "8": case "9":
							str += c;
							state = 5;
						break;
						default:
							throw new JsonStructParseException(i, "Expecting a digit");
					}
				}
			break;
		}
	}
	// Set seeker's position to loop's end
	seekrec.pos = --i;
	// Am I still expecting more characters?
	if (done || state == 1 || state == -2 || state == 5) {
		return real(str);
	}
	// Error: Unexpected ending
	throw new JsonStructParseException(seekrec.pos, "Unexpected end of real");
}

///@func __jsons_decode_seek__(seekrec)
///@param {Struct} seekrec
///@return {String}
///@ignore
///@desc (INTERNAL: JsonStruct) Seek to the next "hot" character and return it.
function __jsons_decode_seek__(seekrec) {
	var strlen = string_length(seekrec.str);
	var i;
	for (i = seekrec.pos+1; i <= strlen; ++i) {
		var c = string_char_at(seekrec.str, i);
		if (!__jsons_is_whitespace__(c)) {
			seekrec.pos = i;
			return c;
		}
	}
	seekrec.pos = i;
	return "";
}

///@func __jsons_decode_string__(seekrec)
///@param {Struct} seekrec
///@return {String}
///@ignore
///@desc (INTERNAL: JsonStruct) Decode the upcoming string value.
function __jsons_decode_string__(seekrec) {
	var buffer = buffer_create(64, buffer_grow, 1);
	var strlen = string_length(seekrec.str);
	// Build string starting from next character
	var foundEnd = false;
	var escapeMode = false;
	var i;
	for (i = seekrec.pos+1; !foundEnd && i <= strlen; ++i) {
		var c = string_char_at(seekrec.str, i);
		if (escapeMode) {
			switch (c) {
				case @'"': case @"'": case @'\': case "/":
					buffer_write(buffer, buffer_text, c);
				break;
				case "n":
					buffer_write(buffer, buffer_text, "\n");
				break;
				case "r":
					buffer_write(buffer, buffer_text, "\r");
				break;
				case "t":
					buffer_write(buffer, buffer_text, "\t");
				break;
				case "u":
					if (strlen-i < 5) {
						throw new JsonStructParseException(i, "Invalid \\uxxxx string escape sequence");
					}
					try {
						buffer_write(buffer, buffer_text, chr(__jsons_hex_to_decimal__(string_copy(seekrec.str, i+1, 4))));
					} catch (exc) {
						throw new JsonStructParseException(i, "Invalid hex " + string(exc) + " in \\uxxxx string escape sequence");
					}
					i += 4;
				break;
				case "b":
					buffer_write(buffer, buffer_text, "\b");
				break;
				case "f":
					buffer_write(buffer, buffer_text, "\f");
				break;
				case "v":
					buffer_write(buffer, buffer_text, "\v");
				break;
				case "a":
					buffer_write(buffer, buffer_text, "\a");
				break;
				default:
					throw new JsonStructParseException(i, "Invalid string escape sequence");
			}
			escapeMode = false;
		} else {
			switch (c) {
				case @'"': foundEnd = true; break;
				case @'\': escapeMode = true; break;
				default: buffer_write(buffer, buffer_text, c);
			}
		}
	}
	// Set seeker's position to loop's end
	--i;
	seekrec.pos = i;
	// Throw error if string continues past end without close
	if (!foundEnd) {
		throw new JsonStructParseException(seekrec.pos, "Expected \"");
	}
	// Done
	buffer_seek(buffer, buffer_seek_start, 0);
	var result = buffer_read(buffer, buffer_string);
	buffer_delete(buffer);
	
	///Feather disable GM1045
	return result;
	///Feather enable GM1045
}

///@func __jsons_decode_struct__(seekrec, safe)
///@param {Struct} seekrec
///@param {Bool} safe Whether safe mode is enabled.
///@return {Struct}
///@ignore
///@desc (INTERNAL: JsonStruct) Decode the upcoming struct value.
function __jsons_decode_struct__(seekrec, safe) {
	// Setup
	///Feather disable GM1063
	var result = safe ? (new JsonStruct()) : {};
	///Feather enable GM1063
	var keyMode = true;
	var key, val, c;
	// Keep seeking for new content
	do {
		c = __jsons_decode_seek__(seekrec);
		// Accept only string keys in key mode
		if (keyMode) {
			if (c == "\"") {
				key = __jsons_decode_string__(seekrec);
				c = __jsons_decode_seek__(seekrec);
				if (c == ":") {
					keyMode = false;
				} else {
					throw new JsonStructParseException(seekrec.pos, "Expected :");
				}
			} else if (c == "}") {
				break;
			} else {
				throw new JsonStructParseException(seekrec.pos, "Expected string key");
			}
		}
		// Accept anything else in value mode
		else {
			val = __jsons_decode_subcontent__(seekrec, safe);
			if (safe) {
				result.set(key, val);
			} else {
				variable_struct_set(result, key, val);
			}
			c = __jsons_decode_seek__(seekrec);
			if (c == ",") {
				keyMode = true;
			} else if (c == "}") {
				break;
			} else {
				throw new JsonStructParseException(seekrec.pos, "Expected , or }")
			}
		}
	} until (c == "}");
	// Done
	return result;
}

///@func __jsons_decode_subcontent__(seekrec, safe)
///@param {Struct} seekrec
///@param {Bool} safe Whether safe mode is enabled.
///@return {Any}
///@ignore
///@desc (INTERNAL: JsonStruct) Decode the upcoming value.
function __jsons_decode_subcontent__(seekrec, safe) {
	switch (ord(string_char_at(seekrec.str, seekrec.pos))) {
		case ord("{"):
			return __jsons_decode_struct__(seekrec, safe);
		break;
		case ord("["):
			return __jsons_decode_array__(seekrec, safe);
		break;
		case ord("\""):
			return __jsons_decode_string__(seekrec);
		break;
		case ord("n"):
			return __jsons_decode_undefined__(seekrec);
		break;
		case ord("t"): case ord("f"):
			return __jsons_decode_bool__(seekrec);
		break;
		case ord("-"): case ord("1"): case ord("2"): case ord("3"): case ord("4"): case ord("5"): case ord("6"): case ord("7"): case ord("8"): case ord("9"): case ord("0"): case ord("+"):
			return __jsons_decode_real__(seekrec);
		break;
		default:
			throw new JsonStructParseException(seekrec.pos, "Unexpected character");
	}
}

///@func __jsons_decode_undefined__(seekrec)
///@param {Struct} seekrec
///@return {undefined}
///@ignore
///@desc (INTERNAL: JsonStruct) Decode the upcoming null value.
function __jsons_decode_undefined__(seekrec) {
	if (string_copy(seekrec.str, seekrec.pos, 4) == "null") {
		seekrec.pos += 3;
		return undefined;
	}
	throw new JsonStructParseException(seekrec.pos, "Unexpected character in null");
}

///@func __jsons_decrypt__(str, key)
///@param {String} str Encrypted buffer in Base64 string form.
///@param {String} key The key to decrypt with.
///@return {String}
///@ignore
///@desc (INTERNAL: JsonStruct) Decrypt the Base64 string with the given key and return the plaintext string.
function __jsons_decrypt__(str, key) {
	var buffer = buffer_base64_decode(str);
	__jsons_rc4__(buffer, string(key), 0, buffer_get_size(buffer));
	buffer_seek(buffer, buffer_seek_start, 0);
	var decoded = buffer_read(buffer, buffer_string);
	buffer_delete(buffer);
	///Feather disable GM1045
	return decoded;
	///Feather enable GM1045
}

///@func __jsons_encode_formatted__(val, indent, currentDepth, maxDepth, colon, comma)
///@param {Any} val The value to encode.
///@param {String} indent The indentation to use.
///@param {Real} currentDepth The current nesting depth.
///@param {Real} maxDepth The maximum nesting depth to reach before reverting to no indentation.
///@param {String} colon The colon character sequence to use.
///@param {String} comma The comma character sequence to use.
///@return {String}
///@ignore
///@desc (INTERNAL: JsonStruct) Encode the value in formatted JSON.
function __jsons_encode_formatted__(val, indent, currentDepth, maxDepth, colon, comma) {
	var buffer, result, siz, currentIndent, fullIndent;
	switch (typeof(val)) {
		case "number":
			return JSONS_REAL_ENCODER(val);
		break;
		case "int64": case "int32":
			return string(val);
		break;
		case "string":
			siz = string_length(val);
			buffer = buffer_create(32, buffer_grow, 1);
			buffer_write(buffer, buffer_text, @'"');
			for (var i = 1; i <= siz; ++i) {
				var c = string_char_at(val, i);
				switch (ord(c)) {
					case ord("\""): //"
						c = @'\"';
					break;
					case ord("\n"): //\n
						c = @'\n';
					break;
					case ord("\r"): //\r
						c = @'\r';
					break;
					case ord("\\"): //\
						c = @'\\';
					break;
					case ord("\t"): //\t
						c = @'\t';
					break;
					case ord("\v"): //\v
						c = @'\v';
					break;
					case ord("\b"): //\b
						c = @'\b';
					break;
					case ord("\a"): //\a
						c = @'\a';
					break;
				}
				buffer_write(buffer, buffer_text, c);
			}
			buffer_write(buffer, buffer_string, @'"');
		break;
		case "array":
			currentIndent = (currentDepth < maxDepth) ? ("\n" + string_repeat(indent, currentDepth)) : "";
			fullIndent = (currentDepth < maxDepth) ? (currentIndent + indent) : "";
			buffer = buffer_create(64, buffer_grow, 1);
			siz = array_length(val);
			buffer_write(buffer, buffer_text, "[");
			for (var i = 0; i < siz; ++i) {
				if (i > 0) buffer_write(buffer, buffer_text, comma);
				buffer_write(buffer, buffer_text, fullIndent);
				buffer_write(buffer, buffer_text, __jsons_encode_formatted__(val[i], indent, currentDepth+1, maxDepth, colon, comma));
			}
			if (siz > 0) buffer_write(buffer, buffer_text, currentIndent);
			buffer_write(buffer, buffer_string, "]");
		break;
		case "struct":
			currentIndent = (currentDepth < maxDepth) ? ("\n" + string_repeat(indent, currentDepth)) : "";
			fullIndent = (currentDepth < maxDepth) ? (currentIndent + indent) : "";
			buffer = buffer_create(64, buffer_grow, 1);
			var isConflict = instanceof(val) == "JsonStruct";
			var keys = isConflict ? val.keys() : variable_struct_get_names(val);
			siz = array_length(keys);
			array_sort(keys, true);
			buffer_write(buffer, buffer_text, "{");
			for (var i = 0; i < siz; ++i) {
				var k = keys[i];
				if (i > 0) buffer_write(buffer, buffer_text, comma);
				buffer_write(buffer, buffer_text, fullIndent);
				buffer_write(buffer, buffer_text, jsons_encode(k));
				buffer_write(buffer, buffer_text, colon);
				buffer_write(buffer, buffer_text, __jsons_encode_formatted__(isConflict ? val.get(k) : variable_struct_get(val, k), indent, currentDepth+1, maxDepth, colon, comma));
			}
			if (siz > 0) buffer_write(buffer, buffer_text, currentIndent);
			buffer_write(buffer, buffer_string, "}");
		break;
		case "bool":
			return val ? "true" : "false";
		break;
		case "undefined":
			return "null";
		break;
		default:
			throw new JsonStructTypeException(val);
		break;
	}
	// Only strings, arrays and struct to make their way here
	buffer_seek(buffer, buffer_seek_start, 0);
	result = buffer_read(buffer, buffer_string);
	buffer_delete(buffer);
	return result;
}

///@func __jsons_encrypt__(str, key)
///@param {String} str Plaintext string.
///@param {String} key The key to encrypt with.
///@return {String}
///@ignore
///@desc (INTERNAL: JsonStruct) Encrypt the string with the given key and return the ciphertext Base64 string.
function __jsons_encrypt__(str, key) {
	var length = string_byte_length(str);
	var buffer = buffer_create(length+1, buffer_fixed, 1);
	buffer_write(buffer, buffer_string, str);
	__jsons_rc4__(buffer, string(key), 0, buffer_tell(buffer));
	var encoded = buffer_base64_encode(buffer, 0, length);
	buffer_delete(buffer);
	return encoded;
}

///@func __jsons_hex_to_decimal__(hexstr)
///@param {String} hexstr The hex number in string form.
///@return {Real}
///@ignore
///@desc (INTERNAL: JsonStruct) Return the numeric value of the given hex string value.
function __jsons_hex_to_decimal__(hexstr) {
	var hex_string, hex_digits;
	hex_string = string_lower(hexstr);
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
			throw hexstr;
		}
	}
	return num;
}

///@func __jsons_is_whitespace__(char)
///@param {String} char The given character.
///@ignore
///@desc Return whether the given character is a whitespace character
function __jsons_is_whitespace__(char) {
	switch (ord(char)) {
		case $0009:
		case $000A:
		case $000B:
		case $000C:
		case $000D:
		case $0020:
		case $0085:
		case $00A0:
		case $1680:
		case $180E:
		case $2000:
		case $2001:
		case $2002:
		case $2003:
		case $2004:
		case $2005:
		case $2006:
		case $2007:
		case $2008:
		case $2009:
		case $200A:
		case $2028:
		case $2029:
		case $202F:
		case $205F:
		case $3000:
			return true;
	}
	return false;
}

///@func __jsons_rc4__(buffer, key, offset, length)
///@param {Id.Buffer} buffer
///@param {String} key The key string.
///@param {Real} offset The byte offset to start encrypting at.
///@param {Real} length The number of bytes to encrypt.
///@return {Id.Buffer}
///@ignore
///@desc (INTERNAL: JsonStruct) Perform RC4 in-place on the given buffer and return it.
function __jsons_rc4__(buffer, key, offset, length) {
	var i, j, s, temp, keyLength, pos;
	s = array_create(256);
	keyLength = string_byte_length(key);
	for (i = 255; i >= 0; --i) {
		s[i] = i;
	}
	j = 0;
	for (i = 0; i <= 255; ++i) {
		j = (j + s[i] + string_byte_at(key, i mod keyLength)) mod 256;
		temp = s[i];
		s[i] = s[j];
		s[j] = temp;
	}
	i = 0;
	j = 0;
	pos = 0;
	buffer_seek(buffer, buffer_seek_start, offset);
	repeat (length) {
		i = (i+1) mod 256;
		j = (j+s[i]) mod 256;
		temp = s[i];
		s[i] = s[j];
		s[j] = temp;
		var currentByte = buffer_peek(buffer, pos++, buffer_u8);
		buffer_write(buffer, buffer_u8, s[(s[i]+s[j]) mod 256] ^ currentByte);
	}
	return buffer;
}
