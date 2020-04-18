///@func jsons_decrypt(jsonencstr, [deckey], [decfunc])
///@param jsonencstr
///@param [deckey]
///@param [decfunc]
function jsons_decrypt() {
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
	return jsons_decode(is_method(decfunc) ? decfunc(argument[0], deckey) : script_execute(decfunc, argument[0], deckey));
}