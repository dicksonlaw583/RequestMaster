///@func json_struct_test_real_encoders()
function json_struct_test_real_encoders() {
	//jsons_real_encoder_detailed(val)
	assert_equal(jsons_real_encoder_detailed(0), "0");
	assert_equal(jsons_real_encoder_detailed(64), "64");
	assert_equal(jsons_real_encoder_detailed(-64), "-64");
	assert_equal(jsons_real_encoder_detailed(322.5), "3.225e2");
	assert_equal(jsons_real_encoder_detailed(-6427.25), "-6.42725e3");
	
	//jsons_real_encoder_string_format(val)
	assert_equal(jsons_real_encoder_string_format(0), "0");
	assert_equal(jsons_real_encoder_string_format(6), "6");
	assert_equal(jsons_real_encoder_string_format(-6), "-6");
	assert_equal(jsons_real_encoder_string_format(3.25), "3.25");
	assert_equal(jsons_real_encoder_string_format(-6427.25), "-6427.25");
}
