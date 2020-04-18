///@func xhr_delete(url, body, options)
///@param url
///@param body
///@param options
function xhr_delete(url, body, options) {
	//var url = argument0,
	//	body = argument1;
	//	options = argument2;
	return xhr_request("DELETE", url, body, options);
}