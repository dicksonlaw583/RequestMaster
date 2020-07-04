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
	// Forced struct decoder
	method(self, function() {
		xhr_get(url, {
			params: { a: "foo", b: "bar" },
			decoder: jsons_decode_default,
			done: function(res) {
				assert_equal(res.data, {
					GET: { a: "foo", b: "bar" },
					POST: [],
					FILES: []
				}, "Request Master XHR basic GET request (forced struct) failed");
				nextTest();
			},
			fail: failCallback
		});
	}),
	// Forced JsonStruct decoder
	method(self, function() {
		xhr_get(url, {
			params: { a: "foo" },
			decoder: jsons_decode_conflict,
			done: function(res) {
				assert_equal(res.data, new JsonStruct(
					"GET", new JsonStruct("a", "foo"),
					"POST", [],
					"FILES", []
				), "Request Master XHR basic GET request (forced conflict) failed");
				nextTest();
			},
			fail: failCallback
		});
	}),
	// Forced json_decode decoder
	method(self, function() {
		xhr_get(url, {
			params: { a: "foo" },
			decoder: json_decode_to_map,
			done: function(res) {
				assert(ds_exists(res.data, ds_type_map), "Request Master XHR basic GET request (forced json_decode) failed: Map does not exist");
				assert_equal(res.data[? "GET"][? "a"], "foo", "Request Master XHR basic GET request (forced json_decode) failed");
				ds_map_destroy(res.data);
				nextTest();
			},
			fail: failCallback
		});
	}),
	// Basic relative URL request
	method(self, function() {
		// Split the test request URL to root-relpath form (url => <newUrlRoot>/<urlRelative>)
		var originalUrlRoot = xhr_url_root();
		var slashPos = 1;
		var nextSlashPos = string_pos_ext("/", url, 2);
		while (nextSlashPos) {
			slashPos = nextSlashPos;
			nextSlashPos = string_pos_ext("/", url, slashPos+1);
		}
		var newUrlRoot = string_copy(url, 1, slashPos);
		var urlRelative = string_delete(url, 1, slashPos);
		// Set the new root-relpath and make a request
		xhr_url_root(newUrlRoot);
		xhr_get(urlRelative, {
			params: { a: "foo", b: "bar" },
			done: function(res) {
				assert_equal(res.data, {
					GET: { a: "foo", b: "bar" },
					POST: [],
					FILES: []
				}, "Request Master XHR basic relative request failed");
				nextTest();
			},
			fail: failCallback
		});
		// Restore original root settings
		xhr_url_root(originalUrlRoot);
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
