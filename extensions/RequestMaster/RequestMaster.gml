#define xhr_delete
///@func xhr_delete(url, body, options)
///@param url
///@param body
///@param options
{
	var url = argument0,
		body = argument1;
		options = argument2;
	return xhr_request("DELETE", url, body, options);
}

#define xhr_get
///@func xhr_get(url, options)
///@param url
///@param options
{
	var url = argument0,
		options = argument1;
	return xhr_request("GET", url, "", options);
}

#define xhr_head
///@func xhr_head(url, options)
///@param url
///@param options
{
	var url = argument0,
		options = argument1;
	return xhr_request("HEAD", url, "", options);
}

#define xhr_options
///@func xhr_options(url, options)
///@param url
///@param options
{
	var url = argument0,
		options = argument1;
	return xhr_request("OPTIONS", url, "", options);
}

#define xhr_patch
///@func xhr_patch(url, body, options)
///@param url
///@param body
///@param options
{
	var url = argument0,
		body = argument1;
		options = argument2;
	return xhr_request("PATCH", url, body, options);
}

#define xhr_post
///@func xhr_post(url, body, options)
///@param url
///@param body
///@param options
{
	var url = argument0,
		body = argument1;
		options = argument2;
	return xhr_request("POST", url, body, options);
}

#define xhr_put
///@func xhr_put(url, body, options)
///@param url
///@param body
///@param options
{
	var url = argument0,
		body = argument1;
		options = argument2;
	return xhr_request("PUT", url, body, options);
}

#define xhr_request
///@func xhr_request(verb, url, body, options)
///@param verb
///@param url
///@param body
///@param options
{
	var verb = argument0,
		url = argument1,
		body = argument2,
		options = argument3;

	// Prepend the URL root if url is relative
	var urlIsRelative = true;
	var urlFirstSlashPos = string_pos("/", url);
	if (urlFirstSlashPos) {
		var urlFirstPart = string_copy(url, 1, urlFirstSlashPos-1);
		urlIsRelative = urlFirstPart != "https:" && urlFirstPart != "http:";
	}
	if (urlIsRelative) {
		url = xhr_url_root()+url;
	}

	// Create request daemon
	var daemon = instance_create_depth(0, 0, 0, __obj_request_master_daemon__);
	daemon.subject = REQM_DEFAULT_SUBJECT;

	// Defaults
	var encoder = function(s) { return new REQM_DEFAULT_ENCODER(s); };
	verb = string_upper(verb);

	// Get options
	var paramKeys = variable_struct_get_names(options);
	for (var i = array_length(paramKeys)-1; i >= 0; --i) {
		var paramKey = paramKeys[i];
		var paramVal = variable_struct_get(options, paramKey);
		switch (paramKey) {
			case "decoder": daemon.decoder = paramVal; break;
			case "done": daemon.doneCallback = paramVal; break;
			case "encoder": encoder = paramVal; break;
			case "fail": daemon.failCallback = paramVal; break;
			case "headers":
				if (is_array(paramVal)) {
					for (var ii = array_length(paramVal)-1; ii >= 0; --ii) {
						daemon.headers[? paramVal[ii][0]] = paramVal[ii][1];
					}
				} else {
					ds_map_copy(daemon.headers, paramVal);
				}
				break;
			case "params":
				url += "?" + xwfu_encode(paramVal);
				break;
			case "progress": daemon.progressCallback = paramVal; break;
			case "subject":
				daemon.subject = paramVal;
				break;
		}
	}
	switch (daemon.subject) {
		case noone: break;
		case -1:
			try {
				daemon.subject = id;
			} catch (ex) {
				daemon.subject = noone;
			}
		default:
			daemon.doneCallback = method(daemon.subject, daemon.doneCallback);
			daemon.failCallback = method(daemon.subject, daemon.failCallback);
			daemon.progressCallback = method(daemon.subject, daemon.progressCallback);
	}

	// Extract body
	var bodyContent, bodyHelper;
	if (is_struct(body)) {
		bodyHelper = variable_struct_exists(body, "getBody") ? body : encoder(body);
		// HTML5 only: If verb is not GET or POST, HEAD, OPTIONS or TRACE, stick _method parameter and change verb to POST
		if (os_browser != browser_not_a_browser || os_type == os_operagx) {
			switch (verb) {
				case "GET": case "POST": break; case "HEAD": case "OPTIONS": case "TRACE":
				break;
				default:
					if (is_struct(bodyHelper)) {
						bodyHelper.addValue("_method", verb);
						verb = "POST";
					}
			}
		}
		bodyContent = bodyHelper.getBody();
	} else {
		bodyHelper = undefined;
		bodyContent = body;
	}

	// Attach additional headers from body helper if applicable
	if (is_struct(bodyHelper)) {
		bodyHelper.setHeader(daemon.headers);
	}

	// Set the request daemon's request
	var reqId = http_request(url, verb, daemon.headers, bodyContent);
	daemon.request = reqId;

	// Clean up if applicable
	if (is_struct(bodyHelper)) {
		bodyHelper.cleanBody(bodyContent);
	}

	// Return the request ID
	return reqId;
}

#define xhr_trace
///@func xhr_trace(url, options)
///@param url
///@param options
{
	var url = argument0,
		options = argument1;
	return xhr_request("TRACE", url, "", options);
}

#define xhr_url_root
///@func xhr_url_root(<urlRoot>)
///@param <urlRoot> (optional) The root URL path (including final slash)
///@desc Set the default URL root if given, otherwise return the current default URL root.
{
	switch (argument_count) {
		case 0: break;
		case 1: global.__reqm_url_root__ = argument[0]; break;
		default:
			show_error("Expected 0 or 1 arguments, got " + string(argument_count) + ".", true);
	}
	return global.__reqm_url_root__;
}
