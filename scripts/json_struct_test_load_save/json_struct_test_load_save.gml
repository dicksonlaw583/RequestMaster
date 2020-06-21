///@func json_struct_test_load_save()
function json_struct_test_load_save() {
	var fname = working_directory + "test.json";
	var fixture = {foo: [3, "four", undefined]};
	var conflictFixture = new JsonStruct("foo", [3, "four", undefined]);
	
	// jsons_save(fname, thing)
	jsons_save(fname, fixture);
	var f = file_text_open_read(fname);
	assert_equal(file_text_read_string(f), jsons_encode(fixture));
	file_text_close(f);
	
	// jsons_load(fname)
	assert_equal(jsons_load(fname), fixture);
	
	// jsons_load(fname) with conflict mode
	jsons_conflict_mode(true);
	assert_equal(jsons_load(fname), conflictFixture);
	jsons_conflict_mode(false);
	
	// Cleanup
	file_delete(fname);
}
