///@desc Start the tests
if (currentTest < array_length(tests)) {
	tests[currentTest++]();
} else {
	layer_background_blend(layer_background_get_id(layer_get_id("Background")), c_green);
	show_debug_message("Request tests completed in " + string(current_time-timeStarted) + "ms.");
	instance_destroy();
}
