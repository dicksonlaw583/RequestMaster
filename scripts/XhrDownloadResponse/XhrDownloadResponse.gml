///@func XhrDownloadResponse(data, file, handle, headers, httpStatus, url, sha1Expected)
///@param data
///@param file
///@param handle
///@param headers
///@param httpStatus
///@param url
///@param sha1Expected
function XhrDownloadResponse(_data, _file, _handle, _headers, _httpStatus, _url, _sha1Expected) constructor {
	data = _data;
	file = _file;
	handle = _handle;
	headers = _headers;
	httpStatus = _httpStatus;
	url = _url;
	sha1Expected = _sha1Expected;
	sha1Received = undefined;
	static isSuccessful = function() {
		return (real(httpStatus) div 100 == 2) && isSha1Validated();
	};
	static isSha1Validated = function() {
		if (!is_undefined(sha1Expected) && is_undefined(sha1Received)) {
			sha1Received = buffer_sha1(data, 0, buffer_tell(data));
		}
		return is_undefined(sha1Expected) || sha1Expected == sha1Received;
	};
}
