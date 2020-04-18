///@func json_struct_test_encrypt()
function json_struct_test_encrypt() {
	var got, expected;
	var key = "helloworld";
	var caesarEncrypt = function(str, key) {
		var result = "";
		var strlen = string_length(str);
		for (var i = 1; i <= strlen; ++i) {
			result += chr(ord(string_char_at(str, i))+key);
		}
		return result;
	};
	var caesarDecrypt = function(str, key) {
		var result = "";
		var strlen = string_length(str);
		for (var i = 1; i <= strlen; ++i) {
			result += chr(ord(string_char_at(str, i))-key);
		}
		return result;
	};
	
	#region RC4 should be sane
	expected = "foogoohoojoo";
	got = __jsons_encrypt__(expected, key);
	assert_not_equal(got, expected);
	assert_equal(__jsons_decrypt__(got, key), expected);
	#endregion
	
	#region jsons_encrypt(thing, [deckey], [decfunc]) and jsons_decrypt(jsonencstr, [deckey], [decfunc])
	expected = "foobar";
	got = jsons_encrypt(expected);
	assert_not_equal(got, expected);
	assert_equal(jsons_decrypt(got), expected);
	
	expected = {foo: "bar", goo: ["car", 777]};
	got = jsons_encrypt(expected);
	assert_not_equal(got, expected);
	assert_equal(jsons_decrypt(got), expected);
	
	expected = {foo: "bar", goo: ["car", 888]};
	got = jsons_encrypt(expected, key);
	assert_not_equal(got, expected);
	assert_equal(jsons_decrypt(got, key), expected);
	
	expected = bool(true);
	got = jsons_encrypt(expected, 1, caesarEncrypt);
	assert_equal(got, "usvf");
	assert_equal(jsons_decrypt(got, 1, caesarDecrypt), expected);
	#endregion
}
