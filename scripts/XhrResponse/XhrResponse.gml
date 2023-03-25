///@func XhrResponse(data, decodeOk, decodeException, handle, headers, httpStatus, url)
///@param {any} data (if successful) The decoded result of the response.
///@param {bool} decodeOk Whether the decode was successful.
///@param {any} decodeException (if decode failed) The exception thrown by the decoder.
///@param {any} handle The asynchronous request ID.
///@param {Id.DsMap} headers A map containing the headers of the response.
///@param {string} httpStatus The HTTP status code of the response (e.g. 200).
///@param {string} url The URL being requested.
///@desc Information class for the result of a Request Master HTTP request.
function XhrResponse(data, decodeOk, decodeException, handle, headers, httpStatus, url) constructor {
	self.data = data;
	self.decodeOk = decodeOk;
	self.handle = handle;
	self.headers = headers;
	self.httpStatus = httpStatus;
	self.url = url;
	
	///@func isSuccessful()
	///@return {bool}
	///@desc Return whether the response is successful (i.e. 2xx).
	static isSuccessful = function() {
		return decodeOk && (real(httpStatus) div 100 == 2);
	};
}

/* vv Text decode helpers vv */
///@func json_decode_to_map(s)
///@param {string} s The string to decode.
///@return {Id.DsMap}
///@desc Decode the given string using json_decode(), throwing undefined when it fails.
function json_decode_to_map(s) {
	var result = json_decode(s);
	if (!ds_exists(result, ds_type_map)) throw undefined;
	return result;
}
/* ^^ Text decode helpers ^^ */
