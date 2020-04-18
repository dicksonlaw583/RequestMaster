///@func multipart_test_all()
function multipart_test_all() {
	var timeA, timeB;
	timeA = current_time;
	multipart_test_encode_buffer();
	timeB = current_time;
	show_debug_message("Multipart buffer tests done in " + string(timeB-timeA) + "ms.");
}