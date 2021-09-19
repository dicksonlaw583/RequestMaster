///@desc Cleanup
ds_map_destroy(headers);
if (!is_undefined(filename)) {
	try {
		buffer_delete(buffer);
	} catch (ex) {
		if (buffer_exists(buffer)) {
			with (instance_create_depth(0, 0, 0, __obj_download_master_buffer_hitman__)) {
				buffer = other.buffer;
			}
		}
	}
}
