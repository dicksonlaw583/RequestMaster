///@desc Request testing
if (async_load[? "id"] == request) {
	switch (async_load[? "status"]) {
		case 1: break;
		case 0:
			assert_equal(jsons_decode(async_load[? "result"]), expected, "Request test " + string(currentTest-1) + " failed!");
			event_user(14);
		break;
		default:
			show_error("Request test " + string(currentTest-1) + " could not be completed.\n\nasync_load:\n" + json_encode(async_load), true);
	}
}
