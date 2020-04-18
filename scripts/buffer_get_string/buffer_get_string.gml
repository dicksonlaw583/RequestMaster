///@func buffer_get_string(buffer, <length>, <start>)
///@param buffer
///@param <length> (optional) The maximum length of the string in bytes
///@param <start> (optional) The position to start from
function buffer_get_string() {
	var buffer = argument[0];
	var len = buffer_get_size(buffer);
	var start = 0;
	switch (argument_count) {
		case 3:
			start = argument[2];
		case 2:
			len = argument[1];
	}
	var oldPos = buffer_tell(buffer);
	buffer_seek(buffer, buffer_seek_start, start);
	var str = buffer_read(buffer, buffer_text);
	buffer_seek(buffer, buffer_seek_start, oldPos);
	return str;
}
