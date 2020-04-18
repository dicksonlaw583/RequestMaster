///@func jsons_encrypt(thing, [enckey], [encfunc])
///@param thing
///@param [enckey]
///@param [encfunc]
function jsons_encrypt() {
	var enckey = "theJsonEncryptedKey",
		encfunc = __jsons_encrypt__;//function(v, k) { return __jsons_encrypt__(v, k); };
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
