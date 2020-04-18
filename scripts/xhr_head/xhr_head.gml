///@func xhr_head(url, options)
///@param url
///@param options
function xhr_head(url, options) {
	//var url = argument0,
	//	options = argument1;
	return xhr_request("HEAD", url, "", options);
}