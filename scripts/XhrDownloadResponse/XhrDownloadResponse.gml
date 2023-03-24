///@func XhrDownloadResponse(data, file, handle, headers, httpStatus, url, sha1Expected)
///@param {any} data
///@param {string,undefined} file
///@param {any} handle
///@param {Id.DsMap} headers
///@param {string} httpStatus
///@param {string} url
///@param {string,undefined} sha1Expected
function XhrDownloadResponse(data, file, handle, headers, httpStatus, url, sha1Expected=undefined) constructor {
	self.data = data;
	self.file = file;
	self.handle = handle;
	self.headers = headers;
	self.httpStatus = httpStatus;
	self.url = url;
	self.sha1Expected = sha1Expected;
	sha1Received = undefined;
	
	///@func isSuccessful()
	///@return {bool}
	///@desc Return whether the response is successful (i.e. 2xx).
	static isSuccessful = function() {
		return (real(httpStatus) div 100 == 2) && isSha1Validated();
	};
	
	///@func isSha1Validated()
	///@return {bool}
	///@desc Return whether the SHA1 hash validation passed.
	///
	///If no SHA1 hash is given, always return true.
	static isSha1Validated = function() {
		if (!is_undefined(sha1Expected) && is_undefined(sha1Received)) {
			sha1Received = buffer_sha1(data, 0, buffer_tell(data));
		}
		return is_undefined(sha1Expected) || sha1Expected == sha1Received;
	};
}
