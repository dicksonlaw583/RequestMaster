///@func xwfu_struct_test_all()
function xwfu_struct_test_all() {
	var timeA, timeB;
	timeA = current_time;
	xwfu_struct_test_encode_string();
	xwfu_struct_test_encode();
	timeB = current_time;
	show_debug_message("XWFU Struct tests done in " + string(timeB-timeA) + "ms.");
}
