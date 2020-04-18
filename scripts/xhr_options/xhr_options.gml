///@func xhr_options(url, options)
///@param url
///@param options
function xhr_options(url, options) {
	//var url = argument0,
	//	options = argument1;
	return xhr_request("OPTIONS", url, "", options);
}