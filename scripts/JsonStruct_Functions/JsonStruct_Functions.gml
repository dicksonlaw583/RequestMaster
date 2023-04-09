///@func jsons_clone(thing)
///@param {Any} thing The value to clone.
///@return {Any}
///@desc Return a deep clone of the given thing.
function jsons_clone(thing) {
	var cloneResult, siz;
	switch (typeof(thing)) {
		case "struct":
			if (instanceof(thing) == "JsonStruct") {
				cloneResult = new JsonStruct();
				var keys = thing.keys();
				siz = array_length(keys);
				for (var i = 0; i < siz; ++i) {
					var k = keys[i];
					cloneResult.set(k,  jsons_clone(thing.get(k)));
				}
			} else {
				cloneResult = {};
				var keys = variable_struct_get_names(thing);
				siz = array_length(keys);
				for (var i = 0; i < siz; ++i) {
					var k = keys[i];
					variable_struct_set(cloneResult, k, jsons_clone(variable_struct_get(thing, k)));
				}
			}
			return cloneResult;
		break;
		case "array":
			siz = array_length(thing);
			cloneResult = array_create(siz);
			for (var i = siz-1; i >= 0; --i) {
				cloneResult[i] = jsons_clone(thing[i]);
			}
			return cloneResult;
		default:
			return thing;
	}
}

///@func jsons_decode(jsonstr)
///@param {String} jsonstr The JSON string to decode.
///@return {Any}
///@desc Decode the given JSON text.
function jsons_decode(jsonstr) {
	// Seek to first active non-space character
	var seekrec = { str: jsonstr, pos: 0 };
	var c = __jsons_decode_seek__(seekrec);
	// Throw an exception if end of string reached without identifiable content
	if (c == "") throw new JsonStructParseException(seekrec.pos, "Unexpected end of string");
	// Decode to the correct type based on first sniffed character
	return __jsons_decode_subcontent__(seekrec, false);
}

///@func jsons_decode_safe(jsonstr)
///@param {String} jsonstr The JSON string to decode.
///@return {Any}
///@desc Decode the given JSON text, but use JsonStruct to represent JSON objects.
function jsons_decode_safe(jsonstr) {
	// Seek to first active non-space character
	var seekrec = { str: jsonstr, pos: 0 };
	var c = __jsons_decode_seek__(seekrec);
	// Throw an exception if end of string reached without identifiable content
	if (c == "") throw new JsonStructParseException(seekrec.pos, "Unexpected end of string");
	// Decode to the correct type based on first sniffed character
	return __jsons_decode_subcontent__(seekrec, true);
}

///@func jsons_decrypt(jsonencstr, [deckey], [decfunc])
///@param {String} jsonencstr The Base64 ciphertext string.
///@param {String} [deckey] (Optional) The decryption key to use.
///@param {Function} [decfunc] (Optional) The decryption function to use.
///@return {Any}
///@desc Decrypt the given encrypted JSON text, then decode it as JSON and return the result.
///
///You may optionally specify the key, or a custom function/script taking a string input and key and returning a string.
function jsons_decrypt(jsonencstr, deckey="theJsonEncryptedKey", decfunc=__jsons_decrypt__) {
	return jsons_decode(is_method(decfunc) ? decfunc(jsonencstr, deckey) : script_execute(decfunc, jsonencstr, deckey));
}

///@func jsons_decrypt_safe(jsonencstr, [deckey], [decfunc])
///@param {String} jsonencstr The Base64 ciphertext string.
///@param {String} [deckey] (Optional) The decryption key to use.
///@param {Function} [decfunc] (Optional) The decryption function to use.
///@return {Any}
///@desc Decrypt the given encrypted JSON text, then decode it as JSON and return the result. JsonStruct will be used to represent JSON objects instead of untyped structs. 
///
///You may optionally specify the key, or a custom function/script taking a string input and key and returning a string.
function jsons_decrypt_safe(jsonencstr, deckey="theJsonEncryptedKey", decfunc=__jsons_decrypt__) {
	return jsons_decode_safe(is_method(decfunc) ? decfunc(jsonencstr, deckey) : script_execute(decfunc, jsonencstr, deckey));
}

///@func jsons_encode(thing)
///@param {Any} thing The value to encode into JSON.
///@return {String}
///@desc Encode the given thing as JSON.
function jsons_encode(thing) {
	var buffer, result, siz;
	switch (typeof(thing)) {
		case "number":
			return JSONS_REAL_ENCODER(thing);
		break;
		case "int64": case "int32":
			return string(thing);
		break;
		case "string":
			siz = string_length(thing);
			buffer = buffer_create(32, buffer_grow, 1);
			buffer_write(buffer, buffer_text, @'"');
			for (var i = 1; i <= siz; ++i) {
				var c = string_char_at(thing, i);
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
			siz = array_length(thing);
			buffer_write(buffer, buffer_text, "[");
			for (var i = 0; i < siz; ++i) {
				if (i > 0) buffer_write(buffer, buffer_text, ",");
				buffer_write(buffer, buffer_text, jsons_encode(thing[i]));
			}
			buffer_write(buffer, buffer_string, "]");
		break;
		case "struct":
			buffer = buffer_create(64, buffer_grow, 1);
			var isConflict = instanceof(thing) == "JsonStruct";
			var keys = isConflict ? thing.keys() : variable_struct_get_names(thing);
			siz = array_length(keys);
			buffer_write(buffer, buffer_text, "{");
			for (var i = 0; i < siz; ++i) {
				var k = keys[i];
				if (i > 0) buffer_write(buffer, buffer_text, ",");
				buffer_write(buffer, buffer_text, jsons_encode(k));
				buffer_write(buffer, buffer_text, ":");
				buffer_write(buffer, buffer_text, jsons_encode(isConflict ? thing.get(k) : variable_struct_get(thing, k)));
			}
			buffer_write(buffer, buffer_string, "}");
		break;
		case "bool":
			return thing ? "true" : "false";
		break;
		case "undefined":
			return "null";
		break;
		default:
			throw new JsonStructTypeException(thing);
		break;
	}
	// Only strings, arrays and struct to make their way here
	buffer_seek(buffer, buffer_seek_start, 0);
	result = buffer_read(buffer, buffer_string);
	buffer_delete(buffer);
	///Feather disable GM1045
	return result;
	///Feather enable GM1045
}

///@func jsons_encode_formatted(thing, [indent], [maxDepth], [colon], [comma])
///@param {Any} thing The value to encode.
///@param {String} [indent] (Optional) The indentation to use.
///@param {Real} [maxDepth] (Optional) The maximum nesting depth to reach before reverting to no indentation.
///@param {String} [colon] (Optional) The colon character sequence to use.
///@param {String} [comma] (Optional) The comma character sequence to use.
///@return {String}
///@desc Encode the value in pretty-printed JSON.
function jsons_encode_formatted(thing, indent=JSONS_FORMATTED_INDENT, maxDepth=JSONS_FORMATTED_MAX_DEPTH, colon=JSONS_FORMATTED_COLON, comma=JSONS_FORMATTED_COMMA) {
	return __jsons_encode_formatted__(thing, indent, 0, maxDepth, colon, comma);
}

///@func jsons_encrypt(thing, [enckey], [encfunc])
///@param {Any} thing The value to encode.
///@param {String} [enckey] (Optional) The encryption key to use.
///@param {Function} [encfunc] (Optional) The encryption function to use.
///@return {String}
///@desc Encode the given thing as JSON and return the encrypted result.
///
///You may optionally specify the key, or a custom function/script taking a string input and key and returning a string.
function jsons_encrypt(thing, enckey="theJsonEncryptedKey", encfunc=__jsons_encrypt__) {
	return is_method(encfunc) ? encfunc(jsons_encode(thing), enckey) : script_execute(encfunc, jsons_encode(thing), enckey);
}

///@func jsons_load(fname)
///@param {String} fname The name of the file.
///@return {Any}
///@desc Load from the given file, decode its contents as JSON and return the result.
function jsons_load(fname) {
	var f = file_text_open_read(fname),
		jsonstr = file_text_read_string(f);
	while (!file_text_eof(f)) {
		file_text_readln(f);
		jsonstr += "\n" + file_text_read_string(f);
	}
	file_text_close(f);
	return jsons_decode(jsonstr);
}

///@func jsons_load_safe(fname)
///@param {String} fname The name of the file.
///@return {Any}
///@desc Load from the given file, decode its contents as JSON and return the result. JsonStruct will be used to represent JSON objects instead of untyped structs.
function jsons_load_safe(fname) {
	var f = file_text_open_read(fname),
		jsonstr = file_text_read_string(f);
	while (!file_text_eof(f)) {
		file_text_readln(f);
		jsonstr += "\n" + file_text_read_string(f);
	}
	file_text_close(f);
	return jsons_decode_safe(jsonstr);
}

///@func jsons_load_encrypted(fname, [deckey], [decfunc])
///@param {String} fname The name of the file.
///@param {String} [deckey] (Optional) The decryption key to use.
///@param {Function} [decfunc] (Optional) The decryption function to use.
///@return {Any}
///@desc Load from the given encrypted file, decode its decrypted contents as JSON, then return the result.
///
///You may optionally specify the key, and/or a custom function/script taking a string input and key and returning a string.
function jsons_load_encrypted(fname, deckey="theJsonEncryptedKey", decfunc=__jsons_decrypt__) {
	var f = file_text_open_read(fname),
		jsonstr = file_text_read_string(f);
	while (!file_text_eof(f)) {
		file_text_readln(f);
		jsonstr += "\n" + file_text_read_string(f);
	}
	file_text_close(f);
	return jsons_decrypt(jsonstr, deckey, decfunc);
}

///@func jsons_load_encrypted_safe(fname, [deckey], [decfunc])
///@param {String} fname The name of the file.
///@param {String} [deckey] (Optional) The decryption key to use.
///@param {Function} [decfunc] (Optional) The decryption function to use.
///@return {Any}
///@desc Load from the given encrypted file, decode its decrypted contents as JSON, then return the result. JsonStruct will be used to represent JSON objects instead of untyped structs.
///
///You may optionally specify the key, and/or a custom function/script taking a string input and key and returning a string.
function jsons_load_encrypted_safe(fname, deckey="theJsonEncryptedKey", decfunc=__jsons_decrypt__) {
	var f = file_text_open_read(fname),
		jsonstr = file_text_read_string(f);
	while (!file_text_eof(f)) {
		file_text_readln(f);
		jsonstr += "\n" + file_text_read_string(f);
	}
	file_text_close(f);
	return jsons_decrypt_safe(jsonstr, deckey, decfunc);
}

///@description jsons_save(fname, thing)
///@param {String} fname The name of the file.
///@param {Any} thing The value to encode.
///@desc Save the given thing into the given file as JSON.
function jsons_save(fname, thing) {
	var f = file_text_open_write(fname);
	file_text_write_string(f, jsons_encode(thing));
	file_text_close(f);
}

///@func jsons_save_encrypted(fname, thing, [enckey], [encfunc])
///@param {String} fname The name of the file.
///@param {Any} thing The value to encode.
///@param {String} [enckey] (Optional) The encryption key to use.
///@param {Function} [encfunc] (Optional) The encryption function to use.
///@desc Save the given thing into the given file as encrypted JSON.
///
///You may optionally specify the key, and/or a custom function/script taking a string input and key and returning a string.
function jsons_save_encrypted(fname, thing, enckey="theJsonEncryptedKey", encfunc=__jsons_encrypt__) {
	var f = file_text_open_write(fname);
	file_text_write_string(f, jsons_encrypt(thing, enckey, encfunc));
	file_text_close(f);
}

///@func jsons_save_formatted(fname, val, [indent], [maxDepth], [colon], [comma])
///@param {String} fname The name of the file.
///@param {Any} val The value to encode.
///@param {String} [indent] (Optional) The indentation to use.
///@param {Real} [maxDepth] (Optional) The maximum nesting depth to reach before reverting to no indentation.
///@param {String} [colon] (Optional) The colon character sequence to use.
///@param {String} [comma] (Optional) The comma character sequence to use.
///@desc Save the given thing into the given file as pretty-printed JSON.
function jsons_save_formatted(fname, val, indent=JSONS_FORMATTED_INDENT, maxDepth=JSONS_FORMATTED_MAX_DEPTH, colon=JSONS_FORMATTED_COLON, comma=JSONS_FORMATTED_COMMA) {
	var output = __jsons_encode_formatted__(val, indent, 0, maxDepth, colon, comma);
	var f = file_text_open_write(fname);
	file_text_write_string(f, output);
	file_text_close(f);
}
