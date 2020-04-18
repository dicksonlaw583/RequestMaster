///@func xhr_post(url, body, options)
///@param url
///@param body
///@param options
function xhr_post(url, body, options) {
	//var url = argument0,
	//	body = argument1;
	//	options = argument2;
	return xhr_request("POST", url, body, options);
}