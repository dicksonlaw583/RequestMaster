///@desc Receive HTTP request
if (async_load[? "id"] == request) {
	if (subject != noone && !instance_exists(subject)) {
		instance_destroy();
		exit;
	}
	if (async_load[? "status"] == 1) {
		progressCallback(async_load[? "sizeDownloaded"], async_load[? "contentLength"]);
	} else {
		var decodedResult = undefined,
			decodeOk = false,
			decodeException = undefined;
		try {
			decodedResult = is_undefined(decoder) ? async_load[? "result"] : (is_method(decoder) ? decoder(async_load[? "result"]) : script_execute(decoder, async_load[? "result"]));
			decodeOk = true;
		} catch (ex) {
			decodedResult = undefined;
			decodeOk = false;
			decodeException = ex;
		}
		var response = new XhrResponse(decodedResult, decodeOk, decodeException, request, async_load[? "response_headers"], async_load[? "http_status"], async_load[? "url"]);
		
		if (response.isSuccessful()) {
			doneCallback(response);
		} else {
			failCallback(response);
		}
		
		instance_destroy();
	}
}
