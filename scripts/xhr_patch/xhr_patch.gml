///@func xhr_patch(url, body, options)
///@param url
///@param body
///@param options
function xhr_patch(url, body, options) {
	//var url = argument0,
	//	body = argument1;
	//	options = argument2;
	return xhr_request("PATCH", url, body, options);
}