///@desc Cleanup
ds_map_destroy(headers);
if (!is_undefined(filename)) {
	buffer_delete(buffer);
}
