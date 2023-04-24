///@func buffer_get_string(buffer, [start])
///@param {Id.Buffer} buffer The buffer to work with
///@param {Real} [start] (optional) The position to start from
///@return {string}
///@desc (INTERNAL: Request Master) Return the buffer's contents as a raw string.
function buffer_get_string(buffer, start=0) {
	var oldPos = buffer_tell(buffer);
	buffer_seek(buffer, buffer_seek_start, start);
	var str = string(buffer_read(buffer, buffer_text));
	buffer_seek(buffer, buffer_seek_start, oldPos);
	return str;
}
