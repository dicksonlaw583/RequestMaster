///@desc Receive HTTP request
if (async_load[? "id"] == request) {
	if (subject != noone && !instance_exists(subject)) {
		instance_destroy();
		exit;
	}
	if (async_load[? "status"] == 1) {
		progressCallback(async_load[? "sizeDownloaded"], async_load[? "contentLength"]);
	} else {
		var response = new XhrDownloadResponse(buffer, filename, request, async_load[? "response_headers"], async_load[? "http_status"], async_load[? "url"], sha1Expected);
		var bufferSize = buffer_tell(buffer);
		if (response.isSuccessful()) {
			if (is_string(filename)) {
				buffer_save_ext(buffer, filename, 0, bufferSize);
			}
			buffer_seek(buffer, buffer_seek_start, 0);
			buffer_resize(buffer, bufferSize);
			doneCallback(response);
		} else {
			failCallback(response);
		}
		
		instance_destroy();
	}
}
