///@func xhr_put(url, body, options)
///@param url
///@param body
///@param options
function xhr_put(url, body, options) {
	//var url = argument0,
	//	body = argument1;
	//	options = argument2;
	return xhr_request("PUT", url, body, options);
}