///@func multipart_test_encode_buffer()
function multipart_test_encode_buffer() {
	var expected, got, gotString, mpdb, bb;
	
	// Simple
	expected = "------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		@'Content-Disposition: form-data; name="foo"' + "\r\n\r\n" +
		"foobar\r\n" +
		"------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		@'Content-Disposition: form-data; name="baz"' + "\r\n\r\n" +
		"bazqux\r\n" +
		"------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a--\r\n";
	mpdb = new MultipartDataBuilder({
		foo: "foobar",
		baz: "bazqux"
	});
	mpdb.boundary = "----b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a";
	got = mpdb.getBuffer();
	gotString = buffer_get_string(got);
	assert_contains(gotString, "------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		@'Content-Disposition: form-data; name="foo"' + "\r\n\r\n" +
		"foobar\r\n", "Simple encode buffer failed: foo");
	assert_contains(gotString, "------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		@'Content-Disposition: form-data; name="baz"' + "\r\n\r\n" +
		"bazqux\r\n", "Simple encode buffer failed: baz");
	assert_contains(gotString, "------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a--\r\n", "Simple encode buffer failed: footer");
	buffer_delete(got);
	
	// Simple 2 with JsonStruct
	expected = "------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		@'Content-Disposition: form-data; name="foo"' + "\r\n\r\n" +
		"foobar\r\n" +
		"------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		@'Content-Disposition: form-data; name="baz"' + "\r\n\r\n" +
		"bazqux\r\n" +
		"------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a--\r\n";
	///Feather disable GM1041
	mpdb = new MultipartDataBuilder(new JsonStruct(
		"foo", "foobar",
		"baz", "bazqux"
	));
	///Feather enable GM1041
	mpdb.boundary = "----b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a";
	got = mpdb.getBuffer();
	gotString = buffer_get_string(got);
	assert_contains(gotString, "------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		@'Content-Disposition: form-data; name="foo"' + "\r\n\r\n" +
		"foobar\r\n", "Simple encode buffer 2 failed: foo");
	assert_contains(gotString, "------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		@'Content-Disposition: form-data; name="baz"' + "\r\n\r\n" +
		"bazqux\r\n", "Simple encode buffer 2 failed: baz");
	assert_contains(gotString, "------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a--\r\n", "Simple encode buffer 2 failed: footer");
	buffer_delete(got);
	
	// Nested request 1
	expected = "------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		"Content-Disposition: form-data; name=\"foo[bar]\"\r\n\r\n" +
		"BAR\r\n" +
		"------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		"Content-Disposition: form-data; name=\"foo[baz]\"\r\n\r\n" +
		"BAZ\r\n" +
		"------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		"Content-Disposition: form-data; name=\"foo[qux][0]\"\r\n\r\n" +
		"WAA!\r\n" +
		"------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		"Content-Disposition: form-data; name=\"foo[qux][1]\"\r\n\r\n" +
		"HOO?\r\n" +
		"------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		"Content-Disposition: form-data; name=\"qux[0]\"\r\n\r\n" +
		"waa\r\n" +
		"------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		"Content-Disposition: form-data; name=\"qux[1]\"\r\n\r\n" +
		"hoo\r\n" +
		"------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a--\r\n";
	mpdb = new MultipartDataBuilder({
		foo: {
			bar: "BAR",
			baz: "BAZ",
			qux: ["WAA!", "HOO?"]
		},
		qux: ["waa", "hoo"]
	});
	mpdb.boundary = "----b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a";
	got = mpdb.getBuffer();
	gotString = buffer_get_string(got);
	assert_contains(gotString, "------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		"Content-Disposition: form-data; name=\"foo[bar]\"\r\n\r\n" +
		"BAR\r\n", "Nested encode buffer failed: foo[bar]");
	assert_contains(gotString, "------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		"Content-Disposition: form-data; name=\"foo[baz]\"\r\n\r\n" +
		"BAZ\r\n", "Nested encode buffer failed: foo[baz]");
	assert_contains(gotString, "------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		"Content-Disposition: form-data; name=\"foo[qux][0]\"\r\n\r\n" +
		"WAA!\r\n", "Nested encode buffer failed: foo[qux][0]");
	assert_contains(gotString, "------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		"Content-Disposition: form-data; name=\"foo[qux][1]\"\r\n\r\n" +
		"HOO?\r\n", "Nested encode buffer failed: foo[qux][1]");
	assert_contains(gotString, "------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		"Content-Disposition: form-data; name=\"qux[0]\"\r\n\r\n" +
		"waa\r\n", "Nested encode buffer failed: qux[0]");
	assert_contains(gotString, "------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		"Content-Disposition: form-data; name=\"qux[1]\"\r\n\r\n" +
		"hoo\r\n", "Nested encode buffer failed: qux[1]");
	assert_contains(gotString, "------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a--\r\n", "Nested encode buffer failed: footer");
	buffer_delete(got);
	
	// Nested request 2 with JsonStruct
	expected = "------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		"Content-Disposition: form-data; name=\"foo[bar]\"\r\n\r\n" +
		"BAR\r\n" +
		"------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		"Content-Disposition: form-data; name=\"foo[baz]\"\r\n\r\n" +
		"BAZ\r\n" +
		"------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		"Content-Disposition: form-data; name=\"foo[qux][0]\"\r\n\r\n" +
		"WAA!\r\n" +
		"------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		"Content-Disposition: form-data; name=\"foo[qux][1]\"\r\n\r\n" +
		"HOO?\r\n" +
		"------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		"Content-Disposition: form-data; name=\"qux[0]\"\r\n\r\n" +
		"waa\r\n" +
		"------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		"Content-Disposition: form-data; name=\"qux[1]\"\r\n\r\n" +
		"hoo\r\n" +
		"------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a--\r\n";
	///Feather disable GM1041
	mpdb = new MultipartDataBuilder(new JsonStruct(
		"foo", new JsonStruct(
			"bar", "BAR",
			"baz", "BAZ",
			"qux", ["WAA!", "HOO?"]
		),
		"qux", ["waa", "hoo"]
	));
	///Feather enable GM1041
	mpdb.boundary = "----b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a";
	got = mpdb.getBuffer();
	gotString = buffer_get_string(got);
	assert_contains(gotString, "------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		"Content-Disposition: form-data; name=\"foo[bar]\"\r\n\r\n" +
		"BAR\r\n", "Nested encode buffer 2 failed: foo[bar]");
	assert_contains(gotString, "------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		"Content-Disposition: form-data; name=\"foo[baz]\"\r\n\r\n" +
		"BAZ\r\n", "Nested encode buffer 2 failed: foo[baz]");
	assert_contains(gotString, "------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		"Content-Disposition: form-data; name=\"foo[qux][0]\"\r\n\r\n" +
		"WAA!\r\n", "Nested encode buffer 2 failed: foo[qux][0]");
	assert_contains(gotString, "------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		"Content-Disposition: form-data; name=\"foo[qux][1]\"\r\n\r\n" +
		"HOO?\r\n", "Nested encode buffer 2 failed: foo[qux][1]");
	assert_contains(gotString, "------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		"Content-Disposition: form-data; name=\"qux[0]\"\r\n\r\n" +
		"waa\r\n", "Nested encode buffer 2 failed: qux[0]");
	assert_contains(gotString, "------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a\r\n" +
		"Content-Disposition: form-data; name=\"qux[1]\"\r\n\r\n" +
		"hoo\r\n", "Nested encode buffer 2 failed: qux[1]");
	assert_contains(gotString, "------b8a1bca777d1cf07fbb4d6bf5066bd8469f1808a--\r\n", "Nested encode buffer 2 failed: footer");
	buffer_delete(got);
	
	// Special request objects
	expected = "------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"foobar\"; filename=\"goodbyeworld.txt\"\r\n" +
		"Content-Type: text/plain\r\n\r\n" +
		"Goodbye World! Goodbye World!\r\n" +
		"------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"foo[bar]\"\r\n\r\n" +
		"BAR\r\n" +
		"------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"foo[baz]\"\r\n\r\n" +
		"BAZ\r\n" +
		"------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"foo[qux][0]\"\r\n\r\n" +
		"WAA!\r\n" +
		"------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"foo[qux][1]\"\r\n\r\n" +
		"HOO?\r\n" +
		"------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"foo[qux][2]\"\r\n\r\n" +
		"Goodbye World! Goodbye World!\r\n" +
		"------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"goo\"; filename=\"helloworlddata.txt\"\r\n" +
		"Content-Type: text/plain\r\n\r\n" +
		"Hello World!\r\n" +
		"Hello World!\r\n" +
		"------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"hoo\"; filename=\"goodbyeworld2.txt\"\r\n" +
		"Content-Type: text/plain\r\n\r\n" +
		"Goodbye World! Goodbye World!\r\n" +
		"------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"qux[0]\"\r\n\r\n" +
		"waa\r\n" +
		"------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"qux[1]\"\r\n\r\n" +
		"hoo\r\n" +
		"------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be--\r\n";
	bb = Buffer(buffer_text, "Goodbye World! Goodbye World!");
	///Feather disable GM1063
	mpdb = new MultipartDataBuilder({
		foo: {
			bar: "BAR",
			baz: "BAZ",
			qux: ["WAA!", "HOO?", new BufferPart(bb)]
		},
		foobar: new StringFilePart("goodbyeworld.txt", "Goodbye World! Goodbye World!"),
		goo: (os_browser == browser_not_a_browser && os_type != os_operagx) ? new FilePart(working_directory + "helloworlddata.txt") : new TextFilePart(working_directory + "helloworlddata.txt"),
		hoo: new BufferFilePart("goodbyeworld2.txt", bb),
		qux: ["waa", "hoo"]
	});
	///Feather enable GM1063
	mpdb.boundary = "----c0a6329b1a8c7e2d8cc4b90919248fa416aff2be";
	got = mpdb.getBuffer();
	gotString = buffer_get_string(got);
	assert_contains(gotString, "------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"foo[bar]\"\r\n\r\n" +
		"BAR\r\n", "Special object encode buffer failed: foo[bar]");
	assert_contains(gotString, "------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"foo[baz]\"\r\n\r\n" +
		"BAZ\r\n", "Special object encode buffer failed: foo[baz]");
	assert_contains(gotString, "------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"foo[qux][0]\"\r\n\r\n" +
		"WAA!\r\n", "Special object encode buffer failed: foo[qux][0]");
	assert_contains(gotString, "------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"foo[qux][1]\"\r\n\r\n" +
		"HOO?\r\n", "Special object encode buffer failed: foo[qux][1]");
	assert_contains(gotString, "------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"foo[qux][2]\"\r\n\r\n" +
		"Goodbye World! Goodbye World!\r\n", "Special object encode buffer failed: foo[qux][2]");
	assert_contains(gotString, "------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"foobar\"; filename=\"goodbyeworld.txt\"\r\n" +
		"Content-Type: text/plain\r\n\r\n" +
		"Goodbye World! Goodbye World!\r\n", "Special object encode buffer failed: foobar");
	assert_contains(gotString, "------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"goo\"; filename=\"helloworlddata.txt\"\r\n" +
		"Content-Type: text/plain\r\n\r\n" +
		"Hello World!\r\n" +
		"Hello World!\r\n", "Special object encode buffer failed: goo");
	assert_contains(gotString, "------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"hoo\"; filename=\"goodbyeworld2.txt\"\r\n" +
		"Content-Type: text/plain\r\n\r\n" +
		"Goodbye World! Goodbye World!\r\n", "Special object encode buffer failed: hoo");
	assert_contains(gotString, "------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"qux[0]\"\r\n\r\n" +
		"waa\r\n", "Special object encode buffer failed: qux[0]");
	assert_contains(gotString, "------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"qux[1]\"\r\n\r\n" +
		"hoo\r\n", "Special object encode buffer failed: qux[1]");
	assert_contains(gotString, "------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be--\r\n", "Special object encode buffer failed: footer");
	buffer_delete(got);
	buffer_delete(bb);
	
	// Special request objects 2 with JsonStruct
	expected = "------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"foobar\"; filename=\"goodbyeworld.txt\"\r\n" +
		"Content-Type: text/plain\r\n\r\n" +
		"Goodbye World! Goodbye World!\r\n" +
		"------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"foo[bar]\"\r\n\r\n" +
		"BAR\r\n" +
		"------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"foo[baz]\"\r\n\r\n" +
		"BAZ\r\n" +
		"------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"foo[qux][0]\"\r\n\r\n" +
		"WAA!\r\n" +
		"------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"foo[qux][1]\"\r\n\r\n" +
		"HOO?\r\n" +
		"------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"foo[qux][2]\"\r\n\r\n" +
		"Goodbye World! Goodbye World!\r\n" +
		"------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"goo\"; filename=\"helloworlddata.txt\"\r\n" +
		"Content-Type: text/plain\r\n\r\n" +
		"Hello World!\r\n" +
		"Hello World!\r\n" +
		"------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"hoo\"; filename=\"goodbyeworld2.txt\"\r\n" +
		"Content-Type: text/plain\r\n\r\n" +
		"Goodbye World! Goodbye World!\r\n" +
		"------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"qux[0]\"\r\n\r\n" +
		"waa\r\n" +
		"------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"qux[1]\"\r\n\r\n" +
		"hoo\r\n" +
		"------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be--\r\n";
	bb = Buffer(buffer_text, "Goodbye World! Goodbye World!");
	///Feather disable GM1041
	mpdb = new MultipartDataBuilder(new JsonStruct(
		"foo", new JsonStruct(
			"bar", "BAR",
			"baz", "BAZ",
			"qux", ["WAA!", "HOO?", new BufferPart(bb)]
		),
		"foobar", new StringFilePart("goodbyeworld.txt", "Goodbye World! Goodbye World!"),
		///Feather disable GM1063
		"goo", (os_browser == browser_not_a_browser && os_type != os_operagx) ? new FilePart(working_directory + "helloworlddata.txt") : new TextFilePart(working_directory + "helloworlddata.txt"),
		///Feather enable GM1063
		"hoo", new BufferFilePart("goodbyeworld2.txt", bb),
		"qux", ["waa", "hoo"]
	));
	///Feather enable GM1041
	mpdb.boundary = "----c0a6329b1a8c7e2d8cc4b90919248fa416aff2be";
	got = mpdb.getBuffer();
	gotString = buffer_get_string(got);
	assert_contains(gotString, "------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"foo[bar]\"\r\n\r\n" +
		"BAR\r\n", "Special object encode buffer failed: foo[bar]");
	assert_contains(gotString, "------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"foo[baz]\"\r\n\r\n" +
		"BAZ\r\n", "Special object encode buffer failed: foo[baz]");
	assert_contains(gotString, "------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"foo[qux][0]\"\r\n\r\n" +
		"WAA!\r\n", "Special object encode buffer failed: foo[qux][0]");
	assert_contains(gotString, "------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"foo[qux][1]\"\r\n\r\n" +
		"HOO?\r\n", "Special object encode buffer failed: foo[qux][1]");
	assert_contains(gotString, "------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"foo[qux][2]\"\r\n\r\n" +
		"Goodbye World! Goodbye World!\r\n", "Special object encode buffer failed: foo[qux][2]");
	assert_contains(gotString, "------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"foobar\"; filename=\"goodbyeworld.txt\"\r\n" +
		"Content-Type: text/plain\r\n\r\n" +
		"Goodbye World! Goodbye World!\r\n", "Special object encode buffer failed: foobar");
	assert_contains(gotString, "------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"goo\"; filename=\"helloworlddata.txt\"\r\n" +
		"Content-Type: text/plain\r\n\r\n" +
		"Hello World!\r\n" +
		"Hello World!\r\n", "Special object encode buffer failed: goo");
	assert_contains(gotString, "------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"hoo\"; filename=\"goodbyeworld2.txt\"\r\n" +
		"Content-Type: text/plain\r\n\r\n" +
		"Goodbye World! Goodbye World!\r\n", "Special object encode buffer failed: hoo");
	assert_contains(gotString, "------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"qux[0]\"\r\n\r\n" +
		"waa\r\n", "Special object encode buffer failed: qux[0]");
	assert_contains(gotString, "------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be\r\n" +
		"Content-Disposition: form-data; name=\"qux[1]\"\r\n\r\n" +
		"hoo\r\n", "Special object encode buffer failed: qux[1]");
	assert_contains(gotString, "------c0a6329b1a8c7e2d8cc4b90919248fa416aff2be--\r\n", "Special object encode buffer failed: footer");
	buffer_delete(got);
	buffer_delete(bb);
	
	// TextFilePart: Default - Windows newlines
	mpdb = new MultipartDataBuilder({
		foo: new TextFilePart(working_directory + "helloworlddata.txt")
	});
	mpdb.boundary = "====";
	got = mpdb.getBuffer();
	gotString = buffer_get_string(got);
	assert_equal(gotString, "--====\r\n" +
		"Content-Disposition: form-data; name=\"foo\"; filename=\"helloworlddata.txt\"\r\n" +
		"Content-Type: text/plain\r\n\r\n" +
		"Hello World!\r\n" +
		"Hello World!"+
		"\r\n--====--\r\n", "TextFilePart failed: Default - Windows newlines");
	buffer_delete(got);
	
	// TextFilePart: Unix newlines
	mpdb = new MultipartDataBuilder({
		foo: new TextFilePart(working_directory + "helloworlddata.txt", { newline: "\n" })
	});
	mpdb.boundary = "====";
	got = mpdb.getBuffer();
	gotString = buffer_get_string(got);
	assert_equal(gotString, "--====\r\n" +
		"Content-Disposition: form-data; name=\"foo\"; filename=\"helloworlddata.txt\"\r\n" +
		"Content-Type: text/plain\r\n\r\n" +
		"Hello World!\n" +
		"Hello World!"+
		"\r\n--====--\r\n", "TextFilePart failed: Unix newlines");
	buffer_delete(got);
	
	// TextFilePart: Trailing Unix newlines
	mpdb = new MultipartDataBuilder({
		foo: new TextFilePart(working_directory + "helloworlddata.txt", { newline: "\n", trailingNewline: true })
	});
	mpdb.boundary = "====";
	got = mpdb.getBuffer();
	gotString = buffer_get_string(got);
	assert_equal(gotString, "--====\r\n" +
		"Content-Disposition: form-data; name=\"foo\"; filename=\"helloworlddata.txt\"\r\n" +
		"Content-Type: text/plain\r\n\r\n" +
		"Hello World!\n" +
		"Hello World!\n"+
		"\r\n--====--\r\n", "TextFilePart failed: Trailing Unix newlines");
	buffer_delete(got);
}