///@func jsons_load_encrypted(fname, [deckey], [decfunc])
///@param fname
///@param [deckey]
///@param [decfunc]
function jsons_load_encrypted() {
	var deckey = "theJsonEncryptedKey",
		decfunc = __jsons_decrypt__;//function(v, k) { return __jsons_decrypt__(v, k); };
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
