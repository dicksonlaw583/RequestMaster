///@func xhr_get(url, options)
///@param url
///@param options
function xhr_get(url, options) {
	//var url = argument0,
	//	options = argument1;
	return xhr_request("GET", url, "", options);
}