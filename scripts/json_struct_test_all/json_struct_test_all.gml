///@func json_struct_test_all()
function json_struct_test_all() {
	global.__json_struct_test_fails__ = 0;
	var timeA, timeB;
	timeA = current_time;
	json_struct_test_encode();
	json_struct_test_real_encoders();
	json_struct_test_decode_helpers();
	json_struct_test_decode();
	json_struct_test_clone();
	json_struct_test_encrypt();
	json_struct_test_load_save();
	json_struct_test_load_save_encrypted();
	timeB = current_time;
	show_debug_message("JSON Struct tests done in " + string(timeB-timeA) + "ms.");
	return global.__json_struct_test_fails__ == 0;
}
