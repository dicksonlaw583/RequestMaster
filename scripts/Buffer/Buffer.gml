///@func Buffer(...)
function Buffer() {
	var length = -1,
	lb = undefined,
	alignment = 1;
	// Load from file if specified
	if (is_string(argument[0]) && string_length(argument[0]) > 1) {
		var offset = 0;
		// Capture arguments
		switch (argument_count) {
			// Buffer("filename", length, offset)
			case 3:
				offset = argument[2];
			// Buffer("filename", length)
			case 2:
				length = argument[1]
			// Buffer("filename")
			case 1:
			break;
			// Invalid number of arguments for file syntax
			default:
				show_error("Expected 1 to 3 arguments for file-loading syntax, got " + string(argument_count) + ".", true);
			break;
		}
		// Start reading
		if (!file_exists(argument[0])) {
			show_error("File does not exist: " + argument[0], true);
		}
		if (length < 0 && offset == 0) {
			return buffer_load(argument[0]);
		}
		var f = file_bin_open(argument[0], 0),
			fsize = file_bin_size(f);
		if (offset < 0) {
			offset += fsize;
			if (offset < 0) {
				show_error("Cannot seek " + string(offset) + " bytes left from end of file, only has " + string(fsize) + " bytes.", true);
			}
		}
		if (length < 0) {
			length = fsize-offset;
		}
		lb = buffer_create(length, buffer_grow, 1);
		file_bin_seek(f, offset);
		repeat (length) {
			buffer_write(lb, buffer_u8, file_bin_read_byte(f));
		}
		file_bin_close(f);
		return lb;
	}
	// Otherwise, revert to element-by-element
	// Even number of arguments: Alignment 1
	// Buffer(...<type, value>...)
	// Odd number of arguments: Alignment specified
	// Buffer(alignment, ...<type, value>...)
	var startindex = 0;
	if (argument_count mod 2 == 1) {
		startindex = 1;
		alignment = argument[0];
	}
	length = 0;
	for (var i = startindex; i < argument_count; i += 2) {
		switch (argument[i]) {
			case buffer_text:
				length += string_byte_length(argument[i+1]);
			break;
			case buffer_string:
				length += string_byte_length(argument[i+1])+1;
			break;
			default:
				length += buffer_sizeof(argument[i]);
			break;
		}
	}
	lb = buffer_create(length, buffer_grow, 1);
	for (var i = startindex; i < argument_count; i += 2) {
		buffer_write(lb, argument[i], argument[i+1]);
	}
	return lb;
}
