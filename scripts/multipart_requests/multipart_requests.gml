///@func multipart_requests()
function multipart_requests() {
	with (instance_create_depth(0, 0, 0, obj_async_tester)) {
		url = "http://localhost/echo_request.php";
		tests = [
			// Sanity check
			function() {
				expected = {
					GET: [],
					POST: [],
					FILES: []
				};
				request = http_get(url);
			},
			// Simple request
			function() {
				expected = {
					GET: [],
					POST: {
						foo: "foobar",
						baz: "bazqux"
					},
					FILES: []
				};
				var mpdb = new MultipartDataBuilder({
					foo: "foobar",
					baz: "bazqux"
				});
				var body = mpdb.getBuffer();
				mpdb.writeHeaderMap(headers);
				//show_debug_message("BUFFER: " + buffer_get_string(body));
				//show_debug_message("HEADERS: " + json_encode(headers));
				request = http_request(url, "POST", headers, body);
				buffer_delete(body);
			},
			// Simple request with JsonStruct
			function() {
				expected = {
					GET: [],
					POST: {
						foo: "foobar",
						baz: "bazqux"
					},
					FILES: []
				};
				var mpdb = new MultipartDataBuilder(new JsonStruct(
					"foo", "foobar",
					"baz", "bazqux"
				));
				var body = mpdb.getBuffer();
				mpdb.writeHeaderMap(headers);
				//show_debug_message("BUFFER: " + buffer_get_string(body));
				//show_debug_message("HEADERS: " + json_encode(headers));
				request = http_request(url, "POST", headers, body);
				buffer_delete(body);
			},
			// Nested request 1
			function() {
				expected = {
					GET: [],
					POST: {
						foo: {
							bar: "BAR",
							baz: "BAZ",
							qux: ["WAA!", "HOO?"]
						},
						qux: ["waa", "hoo"]
					},
					FILES: []
				};
				var mpdb = new MultipartDataBuilder({
					foo: {
						bar: "BAR",
						baz: "BAZ",
						qux: ["WAA!", "HOO?"]
					},
					qux: ["waa", "hoo"]
				});
				var body = mpdb.getBuffer();
				mpdb.writeHeaderMap(headers);
				//show_debug_message("BUFFER: " + buffer_get_string(body));
				//show_debug_message("HEADERS: " + json_encode(headers));
				request = http_request(url, "POST", headers, body);
				buffer_delete(body);
			},
			// Nested request 1 with JsonStruct
			function() {
				expected = {
					GET: [],
					POST: {
						foo: {
							bar: "BAR",
							baz: "BAZ",
							qux: ["WAA!", "HOO?"]
						},
						qux: ["waa", "hoo"]
					},
					FILES: []
				};
				var mpdb = new MultipartDataBuilder(new JsonStruct(
					"foo", new JsonStruct(
						"bar", "BAR",
						"baz", "BAZ",
						"qux", ["WAA!", "HOO?"]
					),
					"qux", ["waa", "hoo"]
				));
				var body = mpdb.getBuffer();
				mpdb.writeHeaderMap(headers);
				//show_debug_message("BUFFER: " + buffer_get_string(body));
				//show_debug_message("HEADERS: " + json_encode(headers));
				request = http_request(url, "POST", headers, body);
				buffer_delete(body);
			},
			// Special request objects
			function() {
				expected = {
					GET: [],
					POST: {
						foo: {
							bar: "BAR",
							baz: "BAZ",
							qux: ["WAA!", "HOO?", "Goodbye World! Goodbye World!"]
						},
						qux: ["waa", "hoo"]
					},
					FILES: {
						foobar: {
							name: "goodbyeworld.txt",
							type: "text/plain",
							error: 0,
							size: 29,
							md5: "48b6cf09f29d7d537998fb244c003e22"
						},
						goo: {
							name: "helloworlddata.txt",
							type: "text/plain",
							error: 0,
							size: 26,
							md5: "65dba415785cacff6046ad8922d011db"
						},
						hoo: {
							name: "goodbyeworld2.txt",
							type: "text/plain",
							error: 0,
							size: 29,
							md5: "48b6cf09f29d7d537998fb244c003e22"
						},
					}
				};
				var bb = Buffer(buffer_text, "Goodbye World! Goodbye World!");
				var mpdb = new MultipartDataBuilder({
					foo: {
						bar: "BAR",
						baz: "BAZ",
						qux: ["WAA!", "HOO?", new BufferPart(bb)]
					},
					foobar: new StringFilePart("goodbyeworld.txt", "Goodbye World! Goodbye World!"),
					goo: (os_browser == browser_not_a_browser) ? new FilePart(working_directory + "helloworlddata.txt") : new StringFilePart("helloworlddata.txt", "Hello World!\r\nHello World!"),
					hoo: new BufferFilePart("goodbyeworld2.txt", bb),
					qux: ["waa", "hoo"]
				});
				var body = mpdb.getBuffer();
				mpdb.writeHeaderMap(headers);
				//show_debug_message("BUFFER: " + buffer_get_string(body));
				//show_debug_message("HEADERS: " + json_encode(headers));
				request = http_request(url, "POST", headers, body);
				buffer_delete(body);
				buffer_delete(bb);
			},
			// Special request objects with JsonStruct
			function() {
				expected = {
					GET: [],
					POST: {
						foo: {
							bar: "BAR",
							baz: "BAZ",
							qux: ["WAA!", "HOO?", "Goodbye World! Goodbye World!"]
						},
						qux: ["waa", "hoo"]
					},
					FILES: {
						foobar: {
							name: "goodbyeworld.txt",
							type: "text/plain",
							error: 0,
							size: 29,
							md5: "48b6cf09f29d7d537998fb244c003e22"
						},
						goo: {
							name: "helloworlddata.txt",
							type: "text/plain",
							error: 0,
							size: 26,
							md5: "65dba415785cacff6046ad8922d011db"
						},
						hoo: {
							name: "goodbyeworld2.txt",
							type: "text/plain",
							error: 0,
							size: 29,
							md5: "48b6cf09f29d7d537998fb244c003e22"
						},
					}
				};
				var bb = Buffer(buffer_text, "Goodbye World! Goodbye World!");
				var mpdb = new MultipartDataBuilder(new JsonStruct(
					"foo", {
						bar: "BAR",
						baz: "BAZ",
						qux: ["WAA!", "HOO?", new BufferPart(bb)]
					},
					"foobar", new StringFilePart("goodbyeworld.txt", "Goodbye World! Goodbye World!"),
					"goo", (os_browser == browser_not_a_browser) ? new FilePart(working_directory + "helloworlddata.txt") : new StringFilePart("helloworlddata.txt", "Hello World!\r\nHello World!"),
					"hoo", new BufferFilePart("goodbyeworld2.txt", bb),
					"qux", ["waa", "hoo"]
				));
				var body = mpdb.getBuffer();
				mpdb.writeHeaderMap(headers);
				//show_debug_message("BUFFER: " + buffer_get_string(body));
				//show_debug_message("HEADERS: " + json_encode(headers));
				request = http_request(url, "POST", headers, body);
				buffer_delete(body);
				buffer_delete(bb);
			},
		];
		event_user(14);
	}
}