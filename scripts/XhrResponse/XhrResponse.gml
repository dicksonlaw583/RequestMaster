///@func XhrResponse(data, decodeOk, decodeException, handle, headers, httpStatus, url)
///@param data
///@param decodeOk
///@param decodeException
///@param handle
///@param headers
///@param httpStatus
///@param url
function XhrResponse(_data, _decodeOk, _decodeException, _handle, _headers, _httpStatus, _url) constructor {
	data = _data;
	decodeOk = _decodeOk;
	handle = _handle;
	headers = _headers;
	httpStatus = _httpStatus;
	url = _url;
	static isSuccessful = function() {
		return decodeOk && (real(httpStatus) div 100 == 2);
	};
}

/* vv Text decode helpers vv */
function json_decode_to_map(s) {
	var result = json_decode(s);
	if (!ds_exists(result, ds_type_map)) throw undefined;
	return result;
}
/* ^^ Text decode helpers ^^ */
