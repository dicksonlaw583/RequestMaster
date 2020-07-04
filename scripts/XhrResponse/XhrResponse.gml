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
function jsons_decode_default(s) {
	var result;
	// Store previous conflict mode settings
	var prevConflictMode = global.__jsons_conflict_mode__;
	jsons_conflict_mode(false);
	// Try decode
	try {
		result = jsons_decode(s);
	} catch (ex) {
		jsons_conflict_mode(prevConflictMode);
		throw ex;
	}
	// Restore previous conflict mode settings and return
	jsons_conflict_mode(prevConflictMode);
	return result;
}

function jsons_decode_conflict(s) {
	var result;
	// Store previous conflict mode settings
	var prevConflictMode = global.__jsons_conflict_mode__;
	jsons_conflict_mode(true);
	// Try decode
	try {
		result = jsons_decode(s);
	} catch (ex) {
		jsons_conflict_mode(prevConflictMode);
		throw ex;
	}
	// Restore previous conflict mode settings and return
	jsons_conflict_mode(prevConflictMode);
	return result;
}

function json_decode_to_map(s) {
	var result = json_decode(s);
	if (!ds_exists(result, ds_type_map)) throw undefined;
	return result;
}
/* ^^ Text decode helpers ^^ */
