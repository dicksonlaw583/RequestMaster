///@func jsons_save_encrypted(fname, thing, [enckey], [encfunc])
///@param fname
///@param thing
///@param [enckey]
///@param [encfunc]
function jsons_save_encrypted() {
	var enckey = "theJsonEncryptedKey",
		encfunc = __jsons_encrypt__;//function(v, k) { return __jsons_encrypt__(v, k); };
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
