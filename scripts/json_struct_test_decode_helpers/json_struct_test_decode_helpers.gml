///@func json_struct_test_decode_helpers()
function json_struct_test_decode_helpers() {
	var got, expected;
	
	#region __jsons_is_whitespace__(char)
	assert(__jsons_is_whitespace__(" "));
	assert(__jsons_is_whitespace__("\r"));
	assert(__jsons_is_whitespace__("\n"));
	assert(__jsons_is_whitespace__("\t"));
	assert_fail(__jsons_is_whitespace__("0"));
	assert_fail(__jsons_is_whitespace__("A"));
	#endregion
	
	#region __jsons_hex_to_decimal__(hexstr)
	assert_equal(__jsons_hex_to_decimal__("7f"), 127);
	assert_equal(__jsons_hex_to_decimal__("7F"), 127);
	assert_throws(function() {
		__jsons_hex_to_decimal__("7g")
	}, "7g");
	#endregion
	
	#region __jsons_decode_seek__(@seekrec)
	expected = { str: "\t 305", pos: 3 };
	got = { str: "\t 305", pos: 0 };
	assert_equal(__jsons_decode_seek__(got), "3");
	assert_equal(got, expected);
	
	expected = { str: "\r\n  \"foo\"", pos: 5 };
	got = { str: "\r\n  \"foo\"", pos: 1 };
	assert_equal(__jsons_decode_seek__(got), "\"");
	assert_equal(got, expected);
	
	expected = { str: "[-6, 5]", pos: 1 };
	got = { str: "[-6, 5]", pos: 0 };
	assert_equal(__jsons_decode_seek__(got), "[");
	assert_equal(got, expected);
	expected.pos = 2;
	assert_equal(__jsons_decode_seek__(got), "-");
	assert_equal(got, expected);
	#endregion
	
	#region __jsons_decode_bool__(@seekrec)
	expected = { str: "[57, true, false]", pos: 9 };
	got = { str: "[57, true, false]", pos: 6 };
	assert_equal(__jsons_decode_bool__(got), bool(true));
	assert_equal(got, expected);
	
	expected = { str: "[57, true, false]", pos: 16 };
	got = { str: "[57, true, false]", pos: 12 };
	assert_equal(__jsons_decode_bool__(got), bool(false));
	assert_equal(got, expected);
	
	expected = new JsonStructParseException(2, "Unexpected character in bool");
	got = { str: " tee", pos: 2 };
	assert_throws([function(g) {
		__jsons_decode_bool__(g);
	}, got], expected);
	#endregion
	
	#region __jsons_decode_undefined__(@seekrec)
	expected = { str: "null", pos: 4 };
	got = { str: "null", pos: 1 };
	assert_equal(__jsons_decode_undefined__(got), undefined);
	assert_equal(got, expected);
	
	expected = new JsonStructParseException(1, "Unexpected character in null");
	got = { str: "noob", pos: 1 };
	assert_throws([function(g) {
		__jsons_decode_undefined__(g);
	}, got], expected);
	#endregion
	
	#region __jsons_decode_string__(@seekrec)
	got = { str: @'"hello world"', pos: 1 };
	expected = { str: @'"hello world"', pos: 13 };
	assert_equal(__jsons_decode_string__(got), "hello world");
	assert_equal(got, expected);
	
	got = { str: @'[3, ""]', pos: 5 };
	expected = { str: @'[3, ""]', pos: 6 };
	assert_equal(__jsons_decode_string__(got), "");
	assert_equal(got, expected);
	
	got = { str: @' "\r\n\t\b\f\\\/\"\u000a\' + "'\"", pos: 2 };
	expected = { str: @' "\r\n\t\b\f\\\/\"\u000a\' + "'\"", pos: 27 };
	assert_equal(__jsons_decode_string__(got), "\r\n\t\b\f\\/\"\u000a'");
	assert_equal(got, expected);
	
	got = { str: @'"hello\nagain\nworld"', pos: 1 };
	expected = { str: @'"hello\nagain\nworld"', pos: 21 };
	assert_equal(__jsons_decode_string__(got), "hello\nagain\nworld");
	assert_equal(got, expected);
	#endregion
	
	#region __jsons_decode_real__(@seekrec)
	got = { str: "905 ", pos: 1 };
	expected = { str: "905 ", pos: 3 };
	assert_equal(__jsons_decode_real__(got), 905);
	assert_equal(got, expected);
	
	got = { str: "-905", pos: 1 };
	expected = { str: "-905", pos: 4 };
	assert_equal(__jsons_decode_real__(got), -905);
	assert_equal(got, expected);
	
	got = { str: "[6, 3.25]", pos: 5 };
	expected = { str: "[6, 3.25]", pos: 8 };
	assert_equal(__jsons_decode_real__(got), 3.25);
	assert_equal(got, expected);
	
	got = { str: "[6, -6.625]", pos: 5 };
	expected = { str: "[6, -6.625]", pos: 10 };
	assert_equal(__jsons_decode_real__(got), -6.625);
	assert_equal(got, expected);
	
	got = { str: "[6, 6.625e2]", pos: 5 };
	expected = { str: "[6, 6.625e2]", pos: 11 };
	assert_equal(__jsons_decode_real__(got), 662.5);
	assert_equal(got, expected);
	
	got = { str: "[6, -6.625E2]", pos: 5 };
	expected = { str: "[6, -6.625E2]", pos: 12 };
	assert_equal(__jsons_decode_real__(got), -662.5);
	assert_equal(got, expected);
	
	got = { str: "-", pos: 1 };
	expected = new JsonStructParseException(1, "Unexpected end of real");
	assert_throws([function(g) {
		__jsons_decode_real__(g);
	}, got], expected);
	
	got = { str: "- ", pos: 1 };
	expected = new JsonStructParseException(2, "Expecting a digit");
	assert_throws([function(g) {
		__jsons_decode_real__(g);
	}, got], expected);
	
	got = { str: "3foo", pos: 1 };
	expected = new JsonStructParseException(2, "Expecting a dot, e, E or a digit");
	assert_throws([function(g) {
		__jsons_decode_real__(g);
	}, got], expected);
	
	got = { str: "-3..", pos: 1 };
	expected = new JsonStructParseException(4, "Expecting a digit");
	assert_throws([function(g) {
		__jsons_decode_real__(g);
	}, got], expected);
	
	got = { str: "-3.5foo", pos: 1 };
	expected = new JsonStructParseException(5, "Expecting an e, E or a digit");
	assert_throws([function(g) {
		__jsons_decode_real__(g);
	}, got], expected);
	
	got = { str: " 6.25ex", pos: 2 };
	expected = new JsonStructParseException(7, "Expecting a +, - or a digit");
	assert_throws([function(g) {
		__jsons_decode_real__(g);
	}, got], expected);
	
	got = { str: " 6.25e-.", pos: 2 };
	expected = new JsonStructParseException(8, "Expecting a digit");
	assert_throws([function(g) {
		__jsons_decode_real__(g);
	}, got], expected);
	
	got = { str: " 6.25e-1a", pos: 2 };
	expected = new JsonStructParseException(9, "Expecting a digit");
	assert_throws([function(g) {
		__jsons_decode_real__(g);
	}, got], expected);
	#endregion
	
	#region __jsons_decode_array__(@seekrec)
	got = { str: @'[]', pos: 1 };
	expected = { str: @'[]', pos: 2 };
	assert_equal(__jsons_decode_array__(got), []);
	assert_equal(got, expected);
	
	got = { str: @'  ["foo", 583, null]', pos: 3 };
	expected = { str: @'  ["foo", 583, null]', pos: 20 };
	assert_equal(__jsons_decode_array__(got), ["foo", 583, undefined]);
	assert_equal(got, expected);
	
	got = { str: @'[3, ] ', pos: 1 };
	expected = { str: @'[3, ] ', pos: 5 };
	assert_equal(__jsons_decode_array__(got), [3]);
	assert_equal(got, expected);
	
	got = { str: @'["foo", "bar" "baz"]', pos: 1 };
	expected = new JsonStructParseException(15, "Expected , or ]");
	assert_throws([function(g) {
		__jsons_decode_array__(g);
	}, got], expected);
	
	got = { str: @'["foo", "bar"', pos: 1 };
	expected = new JsonStructParseException(14, "Expected , or ]");
	assert_throws([function(g) {
		__jsons_decode_array__(g);
	}, got], expected);
	#endregion
	
	#region __jsons_decode_struct__(@seekrec)
	got = { str: @' {}', pos: 2 };
	expected = { str: @' {}', pos: 3 };
	assert_equal(__jsons_decode_struct__(got), {});
	assert_equal(got, expected);
	
	got = { str: @'{"alpha": 111,"beta":2,"omega": "999" }', pos: 1 };
	expected = { str: @'{"alpha": 111,"beta":2,"omega": "999" }', pos: 39 };
	assert_equal(__jsons_decode_struct__(got), { alpha: 111, beta: 2, omega: "999" });
	assert_equal(got, expected);
	
	got = { str: @'{"alpha": 111,"beta":2,"omega": "888", }', pos: 1 };
	expected = { str: @'{"alpha": 111,"beta":2,"omega": "888", }', pos: 40 };
	assert_equal(__jsons_decode_struct__(got), { alpha: 111, beta: 2, omega: "888" });
	assert_equal(got, expected);
	
	got = { str: @'{"foo":"bar",}', pos: 1 };
	expected = { str: @'{"foo":"bar",}', pos: 14 };
	assert_equal(__jsons_decode_struct__(got), { foo: "bar" });
	assert_equal(got, expected);
	
	got = { str: @' {3:5}', pos: 2 };
	expected = new JsonStructParseException(3, "Expected string key");
	assert_throws([function(g) {
		__jsons_decode_struct__(g);
	}, got], expected);
	
	got = { str: @' {"foo" "bar"}', pos: 2 };
	expected = new JsonStructParseException(9, "Expected :");
	assert_throws([function(g) {
		__jsons_decode_struct__(g);
	}, got], expected);
	
	got = { str: @' {"foo":"bar" 905}', pos: 2 };
	expected = new JsonStructParseException(15, "Expected , or }");
	assert_throws([function(g) {
		__jsons_decode_struct__(g);
	}, got], expected);
	#endregion
	
	#region __jsons_decode_subcontent__(@seekrec)
	got = { str: @'[3, ["foo", {"bar":4,}], null, true]', pos: 5 };
	expected = { str: @'[3, ["foo", {"bar":4,}], null, true]', pos: 23 };
	assert_equal(__jsons_decode_subcontent__(got), ["foo", { bar: 4 }]);
	assert_equal(got, expected);
	
	got = { str: @'[3, ["foo", {"bar":4,}], null, true]', pos: 2 };
	expected = { str: @'[3, ["foo", {"bar":4,}], null, true]', pos: 2 };
	assert_equal(__jsons_decode_subcontent__(got), 3);
	assert_equal(got, expected);
	
	got = { str: @'[3, ["foo", {"bar":4,}], null, true]', pos: 6 };
	expected = { str: @'[3, ["foo", {"bar":4,}], null, true]', pos: 10 };
	assert_equal(__jsons_decode_subcontent__(got), "foo");
	assert_equal(got, expected);
	
	got = { str: @'[3, ["foo", {"bar":4,}], null, true]', pos: 26 };
	expected = { str: @'[3, ["foo", {"bar":4,}], null, true]', pos: 29 };
	assert_equal(__jsons_decode_subcontent__(got), undefined);
	assert_equal(got, expected);
	
	got = { str: @'[3, ["foo", {"bar":4,}], null, true]', pos: 32 };
	expected = { str: @'[3, ["foo", {"bar":4,}], null, true]', pos: 35 };
	assert_equal(__jsons_decode_subcontent__(got), bool(true));
	assert_equal(got, expected);
	
	got = { str: @'[3, ["foo", {"bar":4,}], null, true, false]', pos: 38 };
	expected = { str: @'[3, ["foo", {"bar":4,}], null, true, false]', pos: 42 };
	assert_equal(__jsons_decode_subcontent__(got), bool(false));
	assert_equal(got, expected);
	
	for (var ii = -1; ii <= 9; ++ii) {
		got = { str: string(ii), pos: 1 };
		expected = { str: string(ii), pos: ((ii == -1) ? 2 : 1) };
		assert_equal(__jsons_decode_subcontent__(got), ii);
		assert_equal(got, expected);
	}
	
	got = { str: "^", pos: 1 };
	expected = new JsonStructParseException(1, "Unexpected character");
	assert_throws([function(g) {
		__jsons_decode_subcontent__(g);
	}, got], expected);
	#endregion
}
