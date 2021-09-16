#define __jsons_decode_array__
///@func __jsons_decode_array__(@seekrec, safe)
///@param @seekrec
///@param safe
{
	// Setup
	var result = [];
	var val, c;
	var i = 0;
	// Keep seeking for new content
	do {
		c = __jsons_decode_seek__(argument0);
		if (c == "]") break;
		val = __jsons_decode_subcontent__(argument0, argument1);
		result[i++] = val;
		c = __jsons_decode_seek__(argument0);
		if (c == ",") {
			continue;
		} else if (c == "]") {
			break;
		} else {
			throw new JsonStructParseException(argument0.pos, "Expected , or ]");
		}
	} until (c == "]");
	// Done
	return result;
}

#define __jsons_decode_bool__
///@func __jsons_decode_bool__(@seekrec)
///@param @seekrec
{
	if (string_copy(argument0.str, argument0.pos, 4) == "true") {
		argument0.pos += 3;
		return bool(true);
	}
	if (string_copy(argument0.str, argument0.pos, 5) == "false") {
		argument0.pos += 4;
		return bool(false);
	}
	throw new JsonStructParseException(argument0.pos, "Unexpected character in bool");
}

#define __jsons_decode_real__
///@func __jsons_decode_real__(@seekrec)
///@param @seekrec
{
	var i = argument0.pos;
	var len = string_length(argument0.str);
	var c = string_char_at(argument0.str, i);
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
		c = string_char_at(argument0.str, i);
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
	argument0.pos = --i;
	// Am I still expecting more characters?
	if (done || state == 1 || state == -2 || state == 5) {
		return real(str);
	}
	// Error: Unexpected ending
	throw new JsonStructParseException(argument0.pos, "Unexpected end of real");
}

#define __jsons_decode_seek__
///@func __jsons_decode_seek__(@seekrec)
///@param @seekrec
{
	var strlen = string_length(argument0.str);
	for (var i = argument0.pos+1; i <= strlen; ++i) {
		var c = string_char_at(argument0.str, i);
		if (!__jsons_is_whitespace__(c)) {
			argument0.pos = i;
			return c;
		}
	}
	argument0.pos = i;
	return "";
}

#define __jsons_decode_string__
///@func __jsons_decode_string__(@seekrec)
///@param @seekrec
{
	var buffer = buffer_create(64, buffer_grow, 1);
	var strlen = string_length(argument0.str);
	// Build string starting from next character
	var foundEnd = false;
	var escapeMode = false;
	for (var i = argument0.pos+1; !foundEnd && i <= strlen; ++i) {
		var c = string_char_at(argument0.str, i);
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
						buffer_write(buffer, buffer_text, chr(__jsons_hex_to_decimal__(string_copy(argument0.str, i+1, 4))));
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
	argument0.pos = i;
	// Throw error if string continues past end without close
	if (!foundEnd) {
		throw new JsonStructParseException(argument0.pos, "Expected \"");
	}
	// Done
	buffer_seek(buffer, buffer_seek_start, 0);
	var result = buffer_read(buffer, buffer_string);
	buffer_delete(buffer);
	return result;
}

#define __jsons_decode_struct__
///@func __jsons_decode_struct__(@seekrec, safe)
///@param @seekrec
///@param safe
{
	// Setup
	var result = argument1 ? (new JsonStruct()) : {};
	var keyMode = true;
	var key, val, c;
	// Keep seeking for new content
	do {
		c = __jsons_decode_seek__(argument0);
		// Accept only string keys in key mode
		if (keyMode) {
			if (c == "\"") {
				key = __jsons_decode_string__(argument0);
				c = __jsons_decode_seek__(argument0);
				if (c == ":") {
					keyMode = false;
				} else {
					throw new JsonStructParseException(argument0.pos, "Expected :");
				}
			} else if (c == "}") {
				break;
			} else {
				throw new JsonStructParseException(argument0.pos, "Expected string key");
			}
		}
		// Accept anything else in value mode
		else {
			val = __jsons_decode_subcontent__(argument0, argument1);
			if (argument1) {
				result.set(key, val);
			} else {
				variable_struct_set(result, key, val);
			}
			c = __jsons_decode_seek__(argument0);
			if (c == ",") {
				keyMode = true;
			} else if (c == "}") {
				break;
			} else {
				throw new JsonStructParseException(argument0.pos, "Expected , or }")
			}
		}
	} until (c == "}");
	// Done
	return result;
}

#define __jsons_decode_subcontent__
///@func __jsons_decode_subcontent__(@seekrec, safe)
///@param @seekrec
///@param safe
{
	switch (ord(string_char_at(argument0.str, argument0.pos))) {
		case ord("{"):
			return __jsons_decode_struct__(argument0, argument1);
		break;
		case ord("["):
			return __jsons_decode_array__(argument0, argument1);
		break;
		case ord("\""):
			return __jsons_decode_string__(argument0);
		break;
		case ord("n"):
			return __jsons_decode_undefined__(argument0);
		break;
		case ord("t"): case ord("f"):
			return __jsons_decode_bool__(argument0);
		break;
		case ord("-"): case ord("1"): case ord("2"): case ord("3"): case ord("4"): case ord("5"): case ord("6"): case ord("7"): case ord("8"): case ord("9"): case ord("0"): case ord("+"):
			return __jsons_decode_real__(argument0);
		break;
		default:
			throw new JsonStructParseException(argument0.pos, "Unexpected character");
	}
}

#define __jsons_decode_undefined__
///@func __jsons_decode_undefined__(@seekrec)
///@param @seekrec
{
	if (string_copy(argument0.str, argument0.pos, 4) == "null") {
		argument0.pos += 3;
		return undefined;
	}
	throw new JsonStructParseException(argument0.pos, "Unexpected character in null");
}

#define __jsons_decrypt__
///@func __jsons_decrypt__(str, key)
///@param str
///@param key
{
	var buffer = buffer_base64_decode(argument0);
	__jsons_rc4__(buffer, string(argument1), 0, buffer_get_size(buffer));
	buffer_seek(buffer, buffer_seek_start, 0);
	var decoded = buffer_read(buffer, buffer_string);
	buffer_delete(buffer);
	return decoded;
}

#define __jsons_encode_formatted__
///@func __jsons_encode_formatted__(val, indent, currentDepth, maxDepth, colon, comma)
///@param val
///@param indent
///@param currentDepth
///@param maxDepth
///@param colon
///@param comma
{
	var buffer, result, siz, currentIndent, fullIndent;
	switch (typeof(argument0)) {
		case "number":
			return JSONS_REAL_ENCODER(argument0);
		break;
		case "int64": case "int32":
			return string(argument0);
		break;
		case "string":
			siz = string_length(argument0);
			buffer = buffer_create(32, buffer_grow, 1);
			buffer_write(buffer, buffer_text, @'"');
			for (var i = 1; i <= siz; ++i) {
				var c = string_char_at(argument0, i);
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
			currentIndent = (argument2 < argument3) ? ("\n" + string_repeat(argument1, argument2)) : "";
			fullIndent = (argument2 < argument3) ? (currentIndent + argument1) : "";
			buffer = buffer_create(64, buffer_grow, 1);
			siz = array_length(argument0);
			buffer_write(buffer, buffer_text, "[");
			for (var i = 0; i < siz; ++i) {
				if (i > 0) buffer_write(buffer, buffer_text, argument5);
				buffer_write(buffer, buffer_text, fullIndent);
				buffer_write(buffer, buffer_text, __jsons_encode_formatted__(argument0[i], argument1, argument2+1, argument3, argument4, argument5));
			}
			if (siz > 0) buffer_write(buffer, buffer_text, currentIndent);
			buffer_write(buffer, buffer_string, "]");
		break;
		case "struct":
			currentIndent = (argument2 < argument3) ? ("\n" + string_repeat(argument1, argument2)) : "";
			fullIndent = (argument2 < argument3) ? (currentIndent + argument1) : "";
			buffer = buffer_create(64, buffer_grow, 1);
			var isConflict = instanceof(argument0) == "JsonStruct";
			var keys = isConflict ? argument0.keys() : variable_struct_get_names(argument0);
			siz = array_length(keys);
			array_sort(keys, true);
			buffer_write(buffer, buffer_text, "{");
			for (var i = 0; i < siz; ++i) {
				var k = keys[i];
				if (i > 0) buffer_write(buffer, buffer_text, argument5);
				buffer_write(buffer, buffer_text, fullIndent);
				buffer_write(buffer, buffer_text, jsons_encode(k));
				buffer_write(buffer, buffer_text, argument4);
				buffer_write(buffer, buffer_text, __jsons_encode_formatted__(isConflict ? argument0.get(k) : variable_struct_get(argument0, k), argument1, argument2+1, argument3, argument4, argument5));
			}
			if (siz > 0) buffer_write(buffer, buffer_text, currentIndent);
			buffer_write(buffer, buffer_string, "}");
		break;
		case "bool":
			return argument0 ? "true" : "false";
		break;
		case "undefined":
			return "null";
		break;
		default:
			throw new JsonStructTypeException(argument0);
		break;
	}
	// Only strings, arrays and struct to make their way here
	buffer_seek(buffer, buffer_seek_start, 0);
	var result = buffer_read(buffer, buffer_string);
	buffer_delete(buffer);
	return result;
}

#define __jsons_encrypt__
///@func __jsons_encrypt__(str, key)
///@param str
///@param key
{
	var length = string_byte_length(argument0);
	var buffer = buffer_create(length+1, buffer_fixed, 1);
	buffer_write(buffer, buffer_string, argument0);
	__jsons_rc4__(buffer, string(argument1), 0, buffer_tell(buffer));
	var encoded = buffer_base64_encode(buffer, 0, length);
	buffer_delete(buffer);
	return encoded;
}

#define __jsons_hex_to_decimal__
///@func __jsons_hex_to_decimal__(hexstr)
///@param hexstr
///@desc Return the numeric value of the given hex string value
{
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

#define __jsons_is_whitespace__
///@func __jsons_is_whitespace__(char)
///@param char
///@desc Return whether the given character is a whitespace character
{
	switch (ord(argument0)) {
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

#define __jsons_rc4__
///@func __jsons_rc4__(@buffer, key, offset, length)
///@param buffer
///@param key
///@param offset
///@param length
{
	var i, j, s, temp, keyLength, pos;
	s = array_create(256);
	keyLength = string_byte_length(argument1);
	for (var i = 255; i >= 0; --i) {
		s[i] = i;
	}
	j = 0;
	for (var i = 0; i <= 255; ++i) {
		j = (j + s[i] + string_byte_at(argument1, i mod keyLength)) mod 256;
		temp = s[i];
		s[i] = s[j];
		s[j] = temp;
	}
	i = 0;
	j = 0;
	pos = 0;
	buffer_seek(argument0, buffer_seek_start, argument2);
	repeat (argument3) {
		i = (i+1) mod 256;
		j = (j+s[i]) mod 256;
		temp = s[i];
		s[i] = s[j];
		s[j] = temp;
		var currentByte = buffer_peek(argument0, pos++, buffer_u8);
		buffer_write(argument0, buffer_u8, s[(s[i]+s[j]) mod 256] ^ currentByte);
	}
	return argument0;
}

#define jsons_clone
///@func jsons_clone(val)
{
	var cloneResult, siz;
	switch (typeof(argument0)) {
		case "struct":
			if (instanceof(argument0) == "JsonStruct") {
				cloneResult = new JsonStruct();
				var keys = argument0.keys();
				siz = array_length(keys);
				for (var i = 0; i < siz; ++i) {
					var k = keys[i];
					cloneResult.set(k,  jsons_clone(argument0.get(k)));
				}
			} else {
				cloneResult = {};
				var keys = variable_struct_get_names(argument0);
				siz = array_length(keys);
				for (var i = 0; i < siz; ++i) {
					var k = keys[i];
					variable_struct_set(cloneResult, k, jsons_clone(variable_struct_get(argument0, k)));
				}
			}
			return cloneResult;
		break;
		case "array":
			siz = array_length(argument0);
			cloneResult = array_create(siz);
			for (var i = siz-1; i >= 0; --i) {
				cloneResult[i] = jsons_clone(argument0[i]);
			}
			return cloneResult;
		default:
			return argument0;
	}
}

#define jsons_decode
///@func jsons_decode(jsonstr)
///@param jsonstr
///@desc Decode the given JSON string back into GML 2020 native types
{
	// Seek to first active non-space character
	var seekrec = { str: argument0, pos: 0 };
	var c = __jsons_decode_seek__(seekrec);
	// Throw an exception if end of string reached without identifiable content
	if (c == "") throw new JsonStructParseException(seekrec.pos, "Unexpected end of string");
	// Decode to the correct type based on first sniffed character
	return __jsons_decode_subcontent__(seekrec, false);
}

#define jsons_decode_safe
///@func jsons_decode_safe(jsonstr)
///@param jsonstr
///@desc Decode the given JSON string back into GML 2020 native types and JsonStruct structs
{
	// Seek to first active non-space character
	var seekrec = { str: argument0, pos: 0 };
	var c = __jsons_decode_seek__(seekrec);
	// Throw an exception if end of string reached without identifiable content
	if (c == "") throw new JsonStructParseException(seekrec.pos, "Unexpected end of string");
	// Decode to the correct type based on first sniffed character
	return __jsons_decode_subcontent__(seekrec, true);
}

#define jsons_decrypt
///@func jsons_decrypt(jsonencstr, [deckey], [decfunc])
///@param jsonencstr
///@param [deckey]
///@param [decfunc]
{
	var deckey = "theJsonEncryptedKey",
		decfunc = function(v, k) { return __jsons_decrypt__(v, k); };//__jsons_decrypt__;
	switch (argument_count) {
		case 3:
			decfunc = argument[2];
		case 2:
			deckey = argument[1];
		case 1:
			break;
		default:
			show_error("Expected 1-3 arguments, got " + string(argument_count) + ".", true);
			break;
	}
	return jsons_decode(is_method(decfunc) ? decfunc(argument[0], deckey) : script_execute(decfunc, argument[0], deckey));
}

#define jsons_decrypt_safe
///@func jsons_decrypt_safe(jsonencstr, [deckey], [decfunc])
///@param jsonencstr
///@param [deckey]
///@param [decfunc]
{
	var deckey = "theJsonEncryptedKey",
		decfunc = function(v, k) { return __jsons_decrypt__(v, k); };//__jsons_decrypt__;
	switch (argument_count) {
		case 3:
			decfunc = argument[2];
		case 2:
			deckey = argument[1];
		case 1:
			break;
		default:
			show_error("Expected 1-3 arguments, got " + string(argument_count) + ".", true);
			break;
	}
	return jsons_decode_safe(is_method(decfunc) ? decfunc(argument[0], deckey) : script_execute(decfunc, argument[0], deckey));
}

#define jsons_encode
///@func jsons_encode(val)
///@param val
///@desc Encode the given value into JSON.
{
	var buffer, result, siz;
	switch (typeof(argument0)) {
		case "number":
			return JSONS_REAL_ENCODER(argument0);
		break;
		case "int64": case "int32":
			return string(argument0);
		break;
		case "string":
			siz = string_length(argument0);
			buffer = buffer_create(32, buffer_grow, 1);
			buffer_write(buffer, buffer_text, @'"');
			for (var i = 1; i <= siz; ++i) {
				var c = string_char_at(argument0, i);
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
			buffer = buffer_create(64, buffer_grow, 1);
			siz = array_length(argument0);
			buffer_write(buffer, buffer_text, "[");
			for (var i = 0; i < siz; ++i) {
				if (i > 0) buffer_write(buffer, buffer_text, ",");
				buffer_write(buffer, buffer_text, jsons_encode(argument0[i]));
			}
			buffer_write(buffer, buffer_string, "]");
		break;
		case "struct":
			buffer = buffer_create(64, buffer_grow, 1);
			var isConflict = instanceof(argument0) == "JsonStruct";
			var keys = isConflict ? argument0.keys() : variable_struct_get_names(argument0);
			siz = array_length(keys);
			buffer_write(buffer, buffer_text, "{");
			for (var i = 0; i < siz; ++i) {
				var k = keys[i];
				if (i > 0) buffer_write(buffer, buffer_text, ",");
				buffer_write(buffer, buffer_text, jsons_encode(k));
				buffer_write(buffer, buffer_text, ":");
				buffer_write(buffer, buffer_text, jsons_encode(isConflict ? argument0.get(k) : variable_struct_get(argument0, k)));
			}
			buffer_write(buffer, buffer_string, "}");
		break;
		case "bool":
			return argument0 ? "true" : "false";
		break;
		case "undefined":
			return "null";
		break;
		default:
			throw new JsonStructTypeException(argument0);
		break;
	}
	// Only strings, arrays and struct to make their way here
	buffer_seek(buffer, buffer_seek_start, 0);
	var result = buffer_read(buffer, buffer_string);
	buffer_delete(buffer);
	return result;
}

#define jsons_encode_formatted
///@func jsons_encode_formatted(val, [indent], [maxDepth], [colon], [comma])
///@param val
///@param [indent]
///@param [maxDepth]
///@param [colon]
///@param [comma]
{
	var val = argument[0];
	var indent = (argument_count > 1) ? argument[1] : JSONS_FORMATTED_INDENT;
	var maxDepth = (argument_count > 2) ? argument[2] : JSONS_FORMATTED_MAX_DEPTH;
	var colon = (argument_count > 3) ? argument[3] : JSONS_FORMATTED_COLON;
	var comma = (argument_count > 4) ? argument[4] : JSONS_FORMATTED_COMMA;
	return __jsons_encode_formatted__(val, indent, 0, maxDepth, colon, comma);
}

#define jsons_encrypt
///@func jsons_encrypt(thing, [enckey], [encfunc])
///@param thing
///@param [enckey]
///@param [encfunc]
{
	var enckey = "theJsonEncryptedKey",
		encfunc = function(v, k) { return __jsons_encrypt__(v, k); };//__jsons_encrypt__;
	switch (argument_count) {
		case 3:
			encfunc = argument[2];
		case 2:
			enckey = argument[1];
		case 1:
			break;
		default:
			show_error("Expected 1-3 arguments, got " + string(argument_count) + ".", true);
			break;
	}
	return is_method(encfunc) ? encfunc(jsons_encode(argument[0]), enckey) : script_execute(encfunc, jsons_encode(argument[0]), enckey);
}

#define jsons_load
///@func jsons_load(fname)
///@param fname
{
	var f = file_text_open_read(argument0),
		jsonstr = file_text_read_string(f);
	while (!file_text_eof(f)) {
		file_text_readln(f);
		jsonstr += "\n" + file_text_read_string(f);
	}
	file_text_close(f);
	return jsons_decode(jsonstr);
}

#define jsons_load_safe
///@func jsons_load_safe(fname)
///@param fname
{
	var f = file_text_open_read(argument0),
		jsonstr = file_text_read_string(f);
	while (!file_text_eof(f)) {
		file_text_readln(f);
		jsonstr += "\n" + file_text_read_string(f);
	}
	file_text_close(f);
	return jsons_decode_safe(jsonstr);
}

#define jsons_load_encrypted
///@func jsons_load_encrypted(fname, [deckey], [decfunc])
///@param fname
///@param [deckey]
///@param [decfunc]
{
	var deckey = "theJsonEncryptedKey",
		decfunc = function(v, k) { return __jsons_decrypt__(v, k); };//__jsons_decrypt__;
	switch (argument_count) {
		case 3:
			decfunc = argument[2];
		case 2:
			deckey = argument[1];
		case 1:
			break;
		default:
			show_error("Expected 1-3 arguments, got " + string(argument_count) + ".", true);
			break;
	}
	var f = file_text_open_read(argument[0]),
		jsonstr = file_text_read_string(f);
	while (!file_text_eof(f)) {
		file_text_readln(f);
		jsonstr += "\n" + file_text_read_string(f);
	}
	file_text_close(f);
	return jsons_decrypt(jsonstr, deckey, decfunc);
}

#define jsons_load_encrypted_safe
///@func jsons_load_encrypted_safe(fname, [deckey], [decfunc])
///@param fname
///@param [deckey]
///@param [decfunc]
{
	var deckey = "theJsonEncryptedKey",
		decfunc = function(v, k) { return __jsons_decrypt__(v, k); };//__jsons_decrypt__;
	switch (argument_count) {
		case 3:
			decfunc = argument[2];
		case 2:
			deckey = argument[1];
		case 1:
			break;
		default:
			show_error("Expected 1-3 arguments, got " + string(argument_count) + ".", true);
			break;
	}
	var f = file_text_open_read(argument[0]),
		jsonstr = file_text_read_string(f);
	while (!file_text_eof(f)) {
		file_text_readln(f);
		jsonstr += "\n" + file_text_read_string(f);
	}
	file_text_close(f);
	return jsons_decrypt_safe(jsonstr, deckey, decfunc);
}

#define jsons_real_encoder_detailed
///@func jsons_real_encoder_detailed(val)
///@param val
///@desc Return a detailed string-form encode of the given real value, including scientific notification if not an integer
{
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

#define jsons_real_encoder_string_format
///@func jsons_real_encoder_string_format(val)
///@param val
///@desc Return the given real value in string form, with up to 15 decimal digits if needed
{
	if (frac(argument0) == 0) return string(argument0);
	var result = string_replace_all(string_format(argument0, 30, 15), " ", "");
	var decimalPos = string_pos(".", result);
	for (var i = string_length(result); i > decimalPos && string_char_at(result, i) == "0"; --i) {}
	return string_copy(result, 0, i-(i==decimalPos));
}

#define jsons_save
/// @description jsons_save(fname, thing)
/// @param fname
/// @param thing
{
	var f = file_text_open_write(argument0);
	file_text_write_string(f, jsons_encode(argument1));
	file_text_close(f);
}

#define jsons_save_encrypted
///@func jsons_save_encrypted(fname, thing, [enckey], [encfunc])
///@param fname
///@param thing
///@param [enckey]
///@param [encfunc]
{
	var enckey = "theJsonEncryptedKey",
		encfunc = function(v, k) { return __jsons_encrypt__(v, k); };//__jsons_encrypt__;
	switch (argument_count) {
		case 4:
			encfunc = argument[3];
		case 3:
			enckey = argument[2];
		case 2:
			break;
		default:
			show_error("Expected 2-4 arguments, got " + string(argument_count) + ".", true);
			break;
	}
	var f = file_text_open_write(argument[0]);
	file_text_write_string(f, jsons_encrypt(argument[1], enckey, encfunc));
	file_text_close(f);
}

#define jsons_save_formatted
///@func jsons_save_formatted(fname, val, [indent], [maxDepth], [colon], [comma])
///@param fname
///@param val
///@param [indent]
///@param [maxDepth]
///@param [colon]
///@param [comma]
{
	var val = argument[1];
	var indent = (argument_count > 2) ? argument[2] : JSONS_FORMATTED_INDENT;
	var maxDepth = (argument_count > 3) ? argument[3] : JSONS_FORMATTED_MAX_DEPTH;
	var colon = (argument_count > 4) ? argument[4] : JSONS_FORMATTED_COLON;
	var comma = (argument_count > 5) ? argument[5] : JSONS_FORMATTED_COMMA;
	var output = __jsons_encode_formatted__(val, indent, 0, maxDepth, colon, comma);
	var f = file_text_open_write(argument[0]);
	file_text_write_string(f, output);
	file_text_close(f);
}
