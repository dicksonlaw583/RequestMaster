///@desc Receive HTTP request
if (async_load[? "id"] == request) {
	var theSubject = (subject == noone) ? id : subject;
	var _progressCallback = progressCallback;
	var _doneCallback = doneCallback;
	var _failCallback = failCallback;
	var _decoder = decoder;
	if (!instance_exists(theSubject)) {
		instance_destroy();
		exit;
	}
	if (async_load[? "status"] == 1) {
		_progressCallback(async_load[? "sizeDownloaded"], async_load[? "contentLength"]);
	} else {
		var decodedResult = undefined,
			decodeOk = false,
			decodeException = undefined;
		try {
			decodedResult = _decoder(async_load[? "result"]);
			decodeOk = true;
		} catch (ex) {
			decodedResult = undefined;
			decodeOk = false;
			decodeException = ex;
		}
		var response = new XhrResponse(decodedResult, decodeOk, decodeException, request, async_load[? "response_headers"], async_load[? "http_status"], async_load[? "url"]);
		
		if (response.isSuccessful()) {
			_doneCallback(response);
		} else {
			_failCallback(response);
		}
		
		instance_destroy();
	}
}
