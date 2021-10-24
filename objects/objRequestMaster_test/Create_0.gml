///@desc Generate requests
testNumber = 0;
timeStarted = current_time;

// Generic callbacks
failCallback = method(self, function(res) {
	show_message(res);
	show_error("Request Master XHR test #" + string(testNumber) + " failed.", true);
});
nextTest = method(self, function() {
	tests[++testNumber]();
});

// Set the URL here
event_user(14);

// Set download result
downloadFile = working_directory + "download_result.txt";
downloadBuffer = -1;
clearDownloadFile = function() {
	var f = file_text_open_write(downloadFile);
	file_text_close(f);
};
goodHash = "0b722c51dfc9da72c47c9ccb76825e8bb3aea581";
badHash = "0b722c51dfc9da72c47c9ccb76825e8bb3aea582";

// Define tests here
tests = [
	// Basic GET download request
	method(self, function() {
		clearDownloadFile();
		xhr_download(url, downloadFile, {
			params: { a: "foofoo" },
			done: function(res) {
				assert_equal([res.file, res.httpStatus, res.url, res.sha1Expected, res.sha1Received], [downloadFile, 200, url+"?a=foofoo", undefined, undefined], "Request Master XHR basic GET download request failed (response struct)");
				var expectedResult = {
					GET: { a: "foofoo" },
					POST: [],
					FILES: []
				};
				var bufferContents = buffer_read(res.data, buffer_text);
				assert_equal(json_parse(bufferContents), expectedResult, "Request Master XHR basic GET download request failed (buffer)");
				var fileBuffer = buffer_load(downloadFile);
				var fileContents = buffer_read(fileBuffer, buffer_text);
				buffer_delete(fileBuffer);
				assert_equal(json_parse(fileContents), expectedResult, "Request Master XHR basic GET download request failed (file)");
				clearDownloadFile();
				nextTest();
			},
			fail: failCallback
		});
	}),
	// Text GET download request
	method(self, function() {
		clearDownloadFile();
		xhr_download(url, downloadFile, {
			params: { a: "foofoo" },
			textMode: true,
			done: function(res) {
				assert_equal([res.file, res.httpStatus, res.url, res.sha1Expected, res.sha1Received], [downloadFile, 200, url+"?a=foofoo", undefined, undefined], "Request Master XHR text GET download request failed (response struct)");
				var expectedResult = {
					GET: { a: "foofoo" },
					POST: [],
					FILES: []
				};
				var bufferContents = buffer_read(res.data, buffer_text);
				assert_equal(json_parse(bufferContents), expectedResult, "Request Master XHR text GET download request failed (buffer)");
				var f = file_text_open_read(downloadFile);
				var fileContents = file_text_read_string(f);
				file_text_close(f);
				assert_equal(json_parse(fileContents), expectedResult, "Request Master XHR text GET download request failed (file)");
				clearDownloadFile();
				nextTest();
			},
			fail: failCallback
		});
	}),
	// Validated GET download request
	method(self, function() {
		clearDownloadFile();
		xhr_download(url, downloadFile, {
			params: { a: "foofoo" },
			sha1: goodHash,
			done: function(res) {
				assert_equal([res.file, res.httpStatus, res.url, res.sha1Expected, res.sha1Received], [downloadFile, 200, url+"?a=foofoo", goodHash, goodHash], "Request Master XHR validated GET download request failed (response struct)");
				var expectedResult = {
					GET: { a: "foofoo" },
					POST: [],
					FILES: []
				};
				var bufferContents = buffer_read(res.data, buffer_text);
				assert_equal(json_parse(bufferContents), expectedResult, "Request Master XHR validated GET download request failed (buffer)");
				var fileBuffer = buffer_load(downloadFile);
				var fileContents = buffer_read(fileBuffer, buffer_text);
				buffer_delete(fileBuffer);
				assert_equal(json_parse(fileContents), expectedResult, "Request Master XHR validated GET download request failed (file)");
				clearDownloadFile();
				nextTest();
			},
			fail: failCallback
		});
	}),
	// Advanced GET download buffer
	method(self, function() {
		downloadBuffer = buffer_create(16, buffer_grow, 1);
		xhr_download(url, downloadBuffer, {
			params: { a: "foofoo" },
			headers: [["Accept", "application/json"], ["Accept-Charset", "utf-8"]],
			sha1: goodHash,
			done: function(res) {
				assert_equal([res.file, res.httpStatus, res.url, res.sha1Expected, res.sha1Received], [undefined, 200, url+"?a=foofoo", goodHash, goodHash], "Request Master XHR advanced GET download buffer failed (response struct)");
				assert_equal(res.data, downloadBuffer, "Request Master XHR advanced GET download buffer different");
				assert_equal(buffer_tell(downloadBuffer), 0, "Request Master XHR advanced GET download buffer not back to start");
				var bufferContents = buffer_read(downloadBuffer, buffer_text);
				assert_equal(json_parse(bufferContents), {
					GET: { a: "foofoo" },
					POST: [],
					FILES: []
				}, "Request Master XHR advanced GET download buffer failed");
				buffer_delete(downloadBuffer);
				downloadBuffer = -1;
				nextTest();
			},
			fail: failCallback
		});
	}),
	// GET download buffer mismatch
	method(self, function() {
		downloadBuffer = buffer_create(16, buffer_grow, 1);
		xhr_download(url, downloadBuffer, {
			params: { a: "foofoo" },
			headers: [["Accept", "application/json"], ["Accept-Charset", "utf-8"]],
			sha1: badHash,
			done: failCallback,
			fail: function(res) {
				assert_equal([res.file, res.httpStatus, res.url, res.sha1Expected, res.sha1Received], [undefined, 200, url+"?a=foofoo", badHash, goodHash], "Request Master XHR GET download buffer mismatch failed (response struct)");
				assert_fail(res.isSha1Validated(), "Request Master XHR GET download buffer mismatch not detected");
				assert_equal(res.sha1Received, goodHash, "Request Master XHR GET download buffer mismatch received wrong SHA1");
				buffer_delete(downloadBuffer);
				downloadBuffer = -1;
				nextTest();
			}
		});
	}),
	// GET download file mismatch
	method(self, function() {
		var f = file_text_open_write(downloadFile);
		file_text_write_string(f, "INTACT");
		file_text_close(f);
		xhr_download(url, downloadFile, {
			params: { a: "foofoo" },
			headers: [["Accept", "application/json"], ["Accept-Charset", "utf-8"]],
			sha1: badHash,
			done: failCallback,
			fail: function(res) {
				assert_equal([res.file, res.httpStatus, res.url, res.sha1Expected, res.sha1Received], [downloadFile, 200, url+"?a=foofoo", badHash, goodHash], "Request Master XHR GET download file mismatch failed (response struct)");
				assert_fail(res.isSha1Validated(), "Request Master XHR GET download file mismatch not detected");
				assert_equal(res.sha1Received, goodHash, "Request Master XHR GET download file mismatch received wrong SHA1");
				var f = file_text_open_read(downloadFile);
				assert_equal(file_text_read_string(f), "INTACT", "Request Master XHR GET download file mismatch overwrote the file");
				file_text_close(f);
				clearDownloadFile();
				nextTest();
			}
		});
	}),
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
	// Basic PUT request
	method(self, function() {
		xhr_put(url, { c: "baz", d: "qux" }, {
			params: { a: "foo", b: "bar" },
			done: function(res) {
				var expected = {
					GET: { a: "foo", b: "bar" },
					POST: [],
					FILES: []
				};
				if (os_browser != browser_not_a_browser || os_type == os_operagx) {
					expected.POST = {
						c: "baz",
						d: "qux",
						_method: "PUT",
					};
				}
				assert_equal(res.data, expected, "Request Master XHR basic PUT request failed");
				nextTest();
			},
			fail: failCallback
		});
	}),
	// Basic PUT request with JsonStruct
	method(self, function() {
		xhr_put(url, new JsonStruct("c", "baz", "d", "qux"), {
			params: new JsonStruct("a", "foo", "b", "bar"),
			done: function(res) {
				var expected = {
					GET: { a: "foo", b: "bar" },
					POST: [],
					FILES: []
				};
				if (os_browser != browser_not_a_browser || os_type == os_operagx) {
					expected.POST = {
						c: "baz",
						d: "qux",
						_method: "PUT",
					};
				}
				assert_equal(res.data, expected, "Request Master XHR basic PUT request with JsonStruct failed");
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
			decoder: function(s) { return jsons_decode(s); },
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
			decoder: function(s) { return jsons_decode_safe(s); },
			done: function(res) {
				assert_equal(res.data, new JsonStruct(
					"GET", new JsonStruct("a", "foo"),
					"POST", [],
					"FILES", []
				), "Request Master XHR basic GET request (forced safe) failed");
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
		layer_background_blend(layer_background_get_id(layer_get_id("Background")), (global.__test_fails__ == 0) ? c_green : c_red);
		show_debug_message("Request Master XHR tests completed in " + string(current_time-timeStarted) + "ms.");
		instance_destroy();
	})
];

// Start running tests
tests[0]();
