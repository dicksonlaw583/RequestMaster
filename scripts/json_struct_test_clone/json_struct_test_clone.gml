///@func json_struct_test_clone()
function json_struct_test_clone() {
	var got, fixture;
	
	#region Non-cloneable types
	assert_equal(jsons_clone(583), 583);
	assert_equal(jsons_clone("foo"), "foo");
	assert_equal(jsons_clone(bool(true)), bool(true));
	assert_equal(jsons_clone(undefined), undefined);
	#endregion
	
	#region Array
	fixture = [];
	got = jsons_clone(fixture);
	assert_equal(got, fixture);
	fixture[0] = 3;
	assert_equal(fixture, [3]);
	assert_not_equal(got, [3]);
	
	fixture = [1, 2, 3];
	got = jsons_clone(fixture);
	assert_equal(got, fixture);
	fixture[0] = 11;
	assert_equal(fixture, [11, 2, 3]);
	assert_not_equal(got, [11, 2, 3]);
	
	fixture = [1, [2, 3], 4];
	got = jsons_clone(fixture);
	assert_equal(got, fixture);
	fixture[1][0] = 22;
	assert_equal(fixture, [1, [22, 3], 4]);
	assert_not_equal(got, [1, [22, 3], 4]);
	#endregion
	
	#region Struct
	fixture = {};
	got = jsons_clone(fixture);
	assert_equal(got, fixture);
	fixture.foo = "bar";
	assert_equal(fixture, {foo: "bar"});
	assert_not_equal(got, {foo: "bar"});
	
	fixture = {foo: "bar"};
	got = jsons_clone(fixture);
	assert_equal(got, fixture);
	fixture.baz = 555;
	assert_equal(fixture, {foo: "bar", baz: 555});
	assert_not_equal(got, {foo: "bar", baz: 555});
	
	fixture = {foo: "bar", goo: { hoo: "car" }};
	got = jsons_clone(fixture);
	assert_equal(got, fixture);
	fixture.goo.joo = 777;
	assert_equal(fixture, {foo: "bar", goo: { hoo: "car", joo: 777 }});
	assert_not_equal(got, {foo: "bar", goo: { hoo: "car", joo: 777 }});
	#endregion
	
	#region Mixed
	fixture = [1, {foo: 2}, 3];
	got = jsons_clone(fixture);
	assert_equal(got, fixture);
	fixture[1].foo = 22;
	assert_equal(fixture, [1, {foo: 22}, 3]);
	assert_not_equal(got, [1, {foo: 22}, 3]);
	
	fixture = {foo: "bar", goo: ["car", 777]};
	got = jsons_clone(fixture);
	assert_equal(got, fixture);
	fixture.goo[1] = 888;
	assert_equal(fixture, {foo: "bar", goo: ["car", 888]});
	assert_not_equal(got, {foo: "bar", goo: ["car", 888]});
	#endregion
}