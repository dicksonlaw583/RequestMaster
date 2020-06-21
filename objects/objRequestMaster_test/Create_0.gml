///@desc Generate requests
testNumber = 0;
timeStarted = current_time;

// Generic callbacks
failCallback = method(self, function(res) {
	show_error("Request Master XHR test #" + string(testNumber) + " failed.", true);
});
nextTest = method(self, function() {
	tests[++testNumber]();
});

// Set the URL here
event_user(14);

// Define tests here
tests = [
	// Basic GET request
	method(self, function() {
		xhr_get(url, {
			params: { a: "foo", b: "bar" },
			done: function(res) {
				assert_equal(res.data, {
					GET: { a: "foo", b: "bar" },
					POST: [],
					FILES: []
				}, "Request Master XHR basic GET request failed");
				nextTest();
			},
			fail: failCallback
		});
	}),
	// Basic GET request with JsonStruct
	method(self, function() {
		xhr_get(url, {
			params: new JsonStruct("a", "foo", "b", "bar"),
			done: function(res) {
				assert_equal(res.data, {
					GET: { a: "foo", b: "bar" },
					POST: [],
					FILES: []
				}, "Request Master XHR basic GET request with JsonStruct failed");
				nextTest();
			},
			fail: failCallback
		});
	}),
	// Basic POST request
	method(self, function() {
		xhr_post(url, { c: "baz", d: "qux" }, {
			params: { a: "foo", b: "bar" },
			done: function(res) {
				assert_equal(res.data, {
					GET: { a: "foo", b: "bar" },
					POST: { c: "baz", d: "qux" },
					FILES: []
				}, "Request Master XHR basic POST request failed");
				nextTest();
			},
			fail: failCallback
		});
	}),
	// Basic POST request with JsonStruct
	method(self, function() {
		xhr_post(url, new JsonStruct("c", "baz", "d", "qux"), {
			params: new JsonStruct("a", "foo", "b", "bar"),
			done: function(res) {
				assert_equal(res.data, {
					GET: { a: "foo", b: "bar" },
					POST: { c: "baz", d: "qux" },
					FILES: []
				}, "Request Master XHR basic POST request with JsonStruct failed");
				nextTest();
			},
			fail: failCallback
		});
	}),
	// File POST request
	method(self, function() {
		xhr_post(url, new MultipartBody({
			baz: "BAZ",
			qux: new StringFilePart("goodbyeworld.txt", "Goodbye World! Goodbye World!")
		}), {
			params: { foo: "bar" },
			done: function(res) {
				assert_equal(res.data, {
					GET: { foo: "bar" },
					POST: { baz: "BAZ" },
					FILES: {
						qux: {
							name: "goodbyeworld.txt",
							type: "text/plain",
							error: 0,
							size: 29,
							md5: "48b6cf09f29d7d537998fb244c003e22"
						}
					}
				}, "Request Master XHR file POST request failed");
				nextTest();
			},
			fail: failCallback
		});
	}),
	// File POST request with JsonStruct
	method(self, function() {
		xhr_post(url, new MultipartBody(new JsonStruct(
			"baz", "BAZ",
			"qux", new StringFilePart("goodbyeworld.txt", "Goodbye World! Goodbye World!")
		)), {
			params: { foo: "bar" },
			done: function(res) {
				assert_equal(res.data, {
					GET: { foo: "bar" },
					POST: { baz: "BAZ" },
					FILES: {
						qux: {
							name: "goodbyeworld.txt",
							type: "text/plain",
							error: 0,
							size: 29,
							md5: "48b6cf09f29d7d537998fb244c003e22"
						}
					}
				}, "Request Master XHR file POST request with JsonStruct failed");
				nextTest();
			},
			fail: failCallback
		});
	}),
	// File POST request (alt), using encoder
	method(self, function() {
		xhr_post(url, {
			baz: "BAZ",
			qux: new StringFilePart("goodbyeworld.txt", "Goodbye World! Goodbye World!")
		}, {
			params: { foo: "bar" },
			encoder: function(strc) { return new MultipartBody(strc); },
			done: function(res) {
				assert_equal(res.data, {
					GET: { foo: "bar" },
					POST: { baz: "BAZ" },
					FILES: {
						qux: {
							name: "goodbyeworld.txt",
							type: "text/plain",
							error: 0,
							size: 29,
							md5: "48b6cf09f29d7d537998fb244c003e22"
						}
					}
				}, "Request Master XHR file POST request (ALT) failed");
				nextTest();
			},
			fail: failCallback
		});
	}),
	// File POST with headers and changed decoder
	method(self, function() {
		xhr_post(url, {
			bar: "baz"
		}, {
			headers: [["Accept", "application/json"], ["Accept-Charset", "utf-8"]],
			decoder: undefined,
			done: function(res) {
				assert_equal(res.data, @'{"GET":[],"POST":{"bar":"baz"},"FILES":[]}', "Request Master XHR file POST request with headers and changed decoder failed");
				nextTest();
			},
			fail: failCallback
		});
	}),
	// Done: Stop defining tests just above here
	method(self, function() {
		layer_background_blend(layer_background_get_id(layer_get_id("Background")), c_green);
		show_debug_message("Request Master XHR tests completed in " + string(current_time-timeStarted) + "ms.");
		instance_destroy();
	})
];

// Start running tests
tests[0]();
