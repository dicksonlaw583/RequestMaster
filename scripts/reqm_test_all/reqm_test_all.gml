///@func reqm_test_all()
function reqm_test_all() {
	var timeA = current_time;
	
	json_struct_test_all();
	xwfu_struct_test_all();
	multipart_test_all();
	
	reqm_test_body_helpers();
	
	var timeB = current_time;
	show_debug_message("Request Master tests finished in " + string(timeB-timeA) + "ms.");
}