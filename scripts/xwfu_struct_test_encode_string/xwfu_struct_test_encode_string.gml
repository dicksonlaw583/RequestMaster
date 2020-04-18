///@func xwfu_struct_test_encode_string()
/* Tests adapted from JSOnion XWFU Converter Pack */
function xwfu_struct_test_encode_string() {
	var str, actual, expected;
	
	// Simple case 1
	str = "hello";
	expected = "hello";
	actual = xwfu_encode(str);
	assert_equal(actual, expected, "xwfu_encode() failed to encode simple case 1!");
	
	// Simple case 2
	str = "Hello World";
	expected = "Hello%20World";
	actual = xwfu_encode(str);
	assert_equal(actual, expected, "xwfu_encode() failed to encode simple case 2!");
	
	//One byte escape characters
    str = "$&+,/:;=?@ " + @'"' + @"'<>#%{}|\^~[]`!";
    expected = "%24%26%2B%2C%2F%3A%3B%3D%3F%40%20%22%27%3C%3E%23%25%7B%7D%7C%5C%5E%7E%5B%5D%60%21";
    actual = xwfu_encode(str);
    assert_equal(actual, expected, "xwfu_encode() failed to encode 1-byte escape characters!");
    
    //Mixed one-byte string
    str = "Hello World! Does E=mc^2?";
    expected = "Hello%20World%21%20Does%20E%3Dmc%5E2%3F";
    actual = xwfu_encode(str);
    assert_equal(actual, expected, "xwfu_encode() failed to encode mixed 1-byte escape and non-escape characters!");
    
    //Multi-byte escape characters
    //In sequence: Latin capital G with circumflex, hiragana O
    str = chr($011C) + chr($304A);
    expected = "%C4%9C%E3%81%8A";
    actual = xwfu_encode(str);
    assert_equal(actual, expected, "xwfu_encode() failed to encode multi-byte escape characters!");
    
    //Summative mix-up string
    str = "Hello World! Does E=mc^2?" + chr($011C) + chr($304A);
    expected = "Hello%20World%21%20Does%20E%3Dmc%5E2%3F%C4%9C%E3%81%8A";
    actual = xwfu_encode(str);
    assert_equal(actual, expected, "xwfu_encode() failed to encode summative mix-up string!");
}
