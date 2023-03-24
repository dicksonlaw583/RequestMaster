///@func xwfu_struct_test_encode()
/* Tests adapted from JSOnion XWFU Converter Pack */
function xwfu_struct_test_encode() {
	var data, expected, actual;
	
	// Empty
	data = {};
	expected = "";
	actual = xwfu_encode(data);
	assert_equal(actual, expected, "xwfu_encode() failed to encode empty body!");
	data = new JsonStruct();
	expected = "";
	actual = xwfu_encode(data);
	assert_equal(actual, expected, "xwfu_encode() failed to encode empty JsonStruct body!");

	// One entry
	data = { waahoo: "woohah" };
	expected = "waahoo=woohah";
	actual = xwfu_encode(data);
	assert_equal(actual, expected, "xwfu_encode() failed to encode simple one-entry body!");
	///Feather disable GM1041
	data = new JsonStruct("waahoo", "woohah");
	///Feather enable GM1041
	expected = "waahoo=woohah";
	actual = xwfu_encode(data);
	assert_equal(actual, expected, "xwfu_encode() failed to encode simple one-entry JsonStruct body!");
	
	// Entry with escape characters in value
	data = { silly: "Hello World! Does E=mc^2?" };
	expected = "silly=Hello%20World%21%20Does%20E%3Dmc%5E2%3F";
	actual = xwfu_encode(data);
	assert_equal(actual, expected, "xwfu_encode() failed to encode entry with escape characters in value!");
	///Feather disable GM1041
	data = new JsonStruct("silly", "Hello World! Does E=mc^2?");
	///Feather enable GM1041
	expected = "silly=Hello%20World%21%20Does%20E%3Dmc%5E2%3F";
	actual = xwfu_encode(data);
	assert_equal(actual, expected, "xwfu_encode() failed to encode JsonStruct entry with escape characters in value!");
	
	// Multiple entries
	data = { one: 1, two: bool(true), three: "trois" };
	actual = xwfu_encode(data);
	assert_contains(actual, "one=1");
	assert_contains(actual, "two=true");
	assert_contains(actual, "three=trois");
	assert_equal(string_count("&", actual), 2);
	///Feather disable GM1041
	data = new JsonStruct("one", 1, "two", bool(true), "three", "trois");
	///Feather enable GM1041
	actual = xwfu_encode(data);
	assert_equal(actual, "one=1&two=true&three=trois");
	
	// Nested entries --- nested list
	data = { one: 1, two: { two: bool(true), three: "trois" }};
	actual = xwfu_encode(data);
	assert_contains(actual, "one=1");
	assert_contains(actual, "two%5Btwo%5D=true");
	assert_contains(actual, "two%5Bthree%5D=trois");
	assert_equal(string_count("&", actual), 2);
	///Feather disable GM1041
	data = new JsonStruct("one", 1, "two", new JsonStruct("two", bool(true), "three", "trois"));
	///Feather enable GM1041
	actual = xwfu_encode(data);
	assert_equal(actual, "one=1&two%5Btwo%5D=true&two%5Bthree%5D=trois");
	
	// Nested entries --- nested array
	data = { one: 1, two: ["deux", "trois", bool(true)] };
	actual = xwfu_encode(data);
	assert_contains(actual, "one=1");
	assert_contains(actual, "two%5B0%5D=deux&two%5B1%5D=trois&two%5B2%5D=true");
	assert_equal(string_count("&", actual), 3);
	///Feather disable GM1041
	data = new JsonStruct("one", 1, "two", ["deux", "trois", bool(true)]);
	///Feather enable GM1041
	actual = xwfu_encode(data);
	assert_equal(actual, "one=1&two%5B0%5D=deux&two%5B1%5D=trois&two%5B2%5D=true");
	// Nested entries --- nested array 2
	data = { one: 1, two: [["deux", "trois"], bool(true)] };
	actual = xwfu_encode(data);
	assert_contains(actual, "one=1");
	assert_contains(actual, "two%5B0%5D%5B0%5D=deux&two%5B0%5D%5B1%5D=trois&two%5B1%5D=true");
	assert_equal(string_count("&", actual), 3);
	///Feather disable GM1041
	data = new JsonStruct("one", 1, "two", [["deux", "trois"], bool(true)]);
	///Feather enable GM1041
	actual = xwfu_encode(data);
	assert_equal(actual, "one=1&two%5B0%5D%5B0%5D=deux&two%5B0%5D%5B1%5D=trois&two%5B1%5D=true");
}
