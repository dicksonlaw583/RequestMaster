///@func xhr_trace(url, options)
///@param url
///@param options
function xhr_trace(url, options) {
	//var url = argument0,
	//	options = argument1;
	return xhr_request("TRACE", url, "", options);
}