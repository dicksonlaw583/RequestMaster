///@func xwfu_struct_requests()
function xwfu_struct_requests() {
	with (instance_create_depth(0, 0, 0, obj_async_tester)) {
		url = "http://localhost/echo_request.php";
		tests = [
			// Sanity test
			function() {
				expected = {
					GET: [],
					POST: [],
					FILES: []
				};
				request = http_get(url);
			},
			// Simple GET
			function() {
				expected = {
					GET: { waahoo: "woohah", foo: "bar" },
					POST: [],
					FILES: []
				};
				request = http_get(url + "?" + xwfu_encode({
					waahoo: "woohah",
					foo: "bar"
				}));
			},
			// Simple POST
			function() {
				expected = {
					GET: [],
					POST: { waahoo: "woohah", foo: "bar" },
					FILES: []
				};
				request = http_post_string(url, xwfu_encode({
					waahoo: "woohah",
					foo: "bar"
				}));
			},
			// Nested mixed request
			function() {
				expected = {
					GET: {
						one: "1",
						two: {
							two: "2",
							three: "trois"
						}
					},
					POST: {
						one: "1",
						two: [
							["deux", "trois"],
							"2"
						]
					},
					FILES: []
				};
				request = http_post_string(url + "?" + xwfu_encode({
					one: 1,
					two: {
						two: 2,
						three: "trois"
					}
				}), xwfu_encode({
					one: 1,
					two: [
						["deux", "trois"],
						2
					]
				}));
			}
		];
		event_user(14);
	}
}
