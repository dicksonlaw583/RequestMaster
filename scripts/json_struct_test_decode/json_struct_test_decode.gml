///@func json_struct_test_decode()
function json_struct_test_decode() {
	#region Undefined
	assert_equal(jsons_decode("null"), undefined);
	assert_equal(jsons_decode(" null "), undefined);
	#endregion
	
	#region Boolean
	assert_equal(jsons_decode("true"), bool(true));
	assert_equal(jsons_decode("false"), bool(false));
	#endregion
	
	#region Real
	assert_equal(jsons_decode("3.25"), 3.25);
	assert_equal(jsons_decode("-6.75"), -6.75);
	assert_equal(jsons_decode("583"), 583);
	assert_equal(jsons_decode("-583"), -583);
	assert_equal(jsons_decode("6.625e2"), 662.5);
	assert_equal(jsons_decode("-6.625E2"), -662.5);
	#endregion
	
	#region String
	assert_equal(jsons_decode(@'"Hello world!"'), "Hello world!");
	assert_equal(jsons_decode(@'"\"\\\n\r\t\v\b\a"'), "\"\\\n\r\t\v\b\a");
	assert_equal(jsons_decode(@'"Hello\nworld!"'), "Hello\nworld!");
	#endregion
	
	#region Array
	assert_equal(jsons_decode(@'[]'), []);
	assert_equal(jsons_decode(@'["one", 2, 3, true]'), ["one", 2, 3, bool(true)]);
	assert_equal(jsons_decode(@'["one", 2, 3, true,]'), ["one", 2, 3, bool(true)]);
	assert_equal(jsons_decode(@'["one", [2, 3, [4, 5, 6]], true]'), ["one", [2, 3, [4, 5, 6]], bool(true)]);
	assert_equal(jsons_decode(@'["one", [2, 3, [4, 5, 6,],], true]'), ["one", [2, 3, [4, 5, 6]], bool(true)]);
	#endregion
	
	#region Object
	assert_equal(jsons_decode(@'{}'), {});
	assert_equal(jsons_decode(@'{"foo": "bar", "baz": false}'), { foo: "bar", baz: bool(false) });
	assert_equal(jsons_decode(@'{"foo": "bar", "baz": false,}'), { foo: "bar", baz: bool(false) });
	assert_equal(jsons_decode(@'{"foo": "bar", "baz": { "qux": 385 }}'), { foo: "bar", baz: { qux: 385 } });
	assert_equal(jsons_decode(@'{"foo": "bar", "baz": { "qux": 385, }}'), { foo: "bar", baz: { qux: 385 } });
	#endregion
	
	#region Object (conflict mode)
	jsons_conflict_mode(true);
	assert_equal(jsons_decode(@'{}'), new JsonStruct());
	assert_equal(jsons_decode(@'{"foo": "bar", "baz": false}'), new JsonStruct("foo", "bar", "baz", bool(false)));
	assert_equal(jsons_decode(@'{"foo": "bar", "baz": false,}'), new JsonStruct("foo", "bar", "baz", bool(false)));
	assert_equal(jsons_decode(@'{"foo": "bar", "baz": { "qux": 385 }}'), new JsonStruct("foo", "bar", "baz", new JsonStruct("qux", 385)));
	assert_equal(jsons_decode(@'{"foo": "bar", "baz": { "qux": 385, }}'), new JsonStruct("foo", "bar", "baz", new JsonStruct("qux", 385)));
	assert_equal(jsons_decode(@'[{"foo": "bar", "baz": false}]'), [new JsonStruct("foo", "bar", "baz", bool(false))]);
	jsons_conflict_mode(false);
	#endregion
}