///@func json_struct_test_encode()
function json_struct_test_encode() {
	
	// Encode numbers
	assert_equal(jsons_encode(3.25), "3.25");
	assert_equal(jsons_encode(-2.75), "-2.75");
	assert_equal(jsons_encode(583), "583");
	assert_equal(jsons_encode(int64(-583)), "-583");
	
	// Encode strings
	assert_equal(jsons_encode("Hello world!"), @'"Hello world!"');
	assert_equal(jsons_encode("\"\\\n\r\t\v\b\a"), @'"\"\\\n\r\t\v\b\a"');
	assert_equal(jsons_encode("Hello\nworld!"), @'"Hello\nworld!"');
	
	// Encode booleans
	assert_equal(jsons_encode(bool(true)), "true");
	assert_equal(jsons_encode(bool(false)), "false");
	
	// Encode undefined
	assert_equal(jsons_encode(undefined), "null");
	
	// Encode arrays
	assert_equal(jsons_encode([]), "[]");
	assert_equal(jsons_encode([999]), "[999]");
	assert_equal(jsons_encode([3.25, -2.75, "Hello world!", bool(true), undefined]), @'[3.25,-2.75,"Hello world!",true,null]');

	// Encode structs
	assert_equal(jsons_encode({}), "{}");
	assert_equal(jsons_encode({abc: "def"}), @'{"abc":"def"}');
	var structEncoded = jsons_encode({abc: "def", ghi: 583});
	assert(structEncoded == @'{"abc":"def","ghi":583}' || structEncoded == @'{"ghi":583,"abc":"def"}');
	
	// Encode structs (conflict mode)
	jsons_conflict_mode(true);
	assert_equal(jsons_encode(new JsonStruct()), "{}");
	assert_equal(jsons_encode(new JsonStruct("abc", "def")), @'{"abc":"def"}');
	assert_equal(jsons_encode(new JsonStruct("abc", "def", "ghi", 583)), @'{"abc":"def","ghi":583}');
	jsons_conflict_mode(false);
	
	// Encode mixed
	assert_equal(jsons_encode({foo: [3.25, -2.75, "Hello world!", bool(true), undefined]}), @'{"foo":[3.25,-2.75,"Hello world!",true,null]}');

	// Encode unsupported type
	assert_throws_instance_of(function() {
		jsons_encode(function(a, b) { return a+b; });
	}, "JsonStructTypeException");
}
