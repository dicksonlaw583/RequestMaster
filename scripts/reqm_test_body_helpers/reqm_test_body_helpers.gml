///@func reqm_test_body_helpers()
function reqm_test_body_helpers() {
	var body;
	var map = ds_map_create();
	
	// JsonBody
	body = new JsonBody({
		hello: "world"
	});
	assert_equal(body.getBody(), @'{"hello":"world"}', "JsonBody.getBody() failed");
	body.setHeader(map);
	assert_equal(map[? "Content-Type"], "application/json", "JsonBody.setHeader(map) failed");
	body.cleanBody(@'{"hello":"world"}');
	ds_map_clear(map);
	
	// XwfuBody
	body = new XwfuBody({
		hello: "world"
	});
	assert_equal(body.getBody(), "hello=world", "XwfuBody.getBody() failed");
	body.setHeader(map);
	assert_equal(map[? "Content-Type"], "application/x-www-form-urlencoded", "XwfuBody.setHeader(map) failed");
	body.cleanBody("hello=world");
	ds_map_clear(map);
	
	// MultipartBody
	body = new MultipartBody({
		hello: "world"
	});
	body.setBoundary("abc");
	var buffer = body.getBody();
	assert_equal(buffer_get_string(buffer), "--abc\r\nContent-Disposition: form-data; name=\"hello\"\r\n\r\nworld\r\n--abc--\r\n", "MultipartBody.getBody() failed");
	body.setHeader(map);
	assert_equal(map[? "Content-Type"], "multipart/form-data; boundary=abc", "MultipartBody.setHeader(map) type failed");
	assert_equal(map[? "Content-Length"], "71", "MultipartBody.setHeader(map) size failed");
	body.cleanBody(buffer);
	assert_fail(buffer_exists(buffer), "MultipartBody.cleanBody(body) didn't clean up");
	ds_map_clear(map);
	
	// Cleanup
	ds_map_destroy(map);
}