#define xhr_set_default_decoder
///@func xhr_set_default_decoder(decoder)
///@param decoder Function that accepts a string response from the server and returns a decoded result if successful, throw something if not
{
	var decoder = argument0;
	global.__reqm_default_decoder__ = is_undefined(decoder) ? xhr_decoder_none : decoder;
}

#define xhr_decoder_none
{
	var d = argument0;
	return d;
}

#define xhr_decoder_json
{
	var d = argument0;
	return jsons_decode(d);
}

#define xhr_decoder_json_map
{
	var d = argument0;
	var result = json_decode(d);
	if (result < 0) {
		throw "JSON decode failed";
	}
	return result;
}

#define xhr_set_default_encoder
///@func xhr_set_default_encoder(body_type)
///@param body_type function that takes a raw body content and returns a formatted body object
{
	var body_type = argument0;
	global.__reqm_default_encoder__ = is_undefined(body_type) ? xhr_encoder_xwfu : body_type;
}

#define xhr_encoder_json
{
	var s = argument0;
	return new JsonBody(s);
}

#define xhr_encoder_xwfu
{
	var s = argument0;
	return new XwfuBody(s);
}

#define xhr_encoder_multipart
{
	var s = argument0;
	return new MultipartBody(s);
}

#define xhr_set_default_subject
///@func xhr_set_default_subject(subject)
///@param subject Instance ID, or xhr_subject_noone or xhr_subject_self, or function returning an instance ID and/or noone
{
	var subject = argument0;
	global.__reqm_default_subject__ = is_undefined(subject) ? noone : subject;
}

#define xhr_subject_self
{
	try {
		var result = id;
		if (id > 0) {
			return result;
		}
	} catch (ex) {}
	return noone;
}

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

	// Create request daemon
	var daemon = instance_create_depth(0, 0, 0, __obj_request_master_daemon__);

	// Defaults
	var encoder = global.__reqm_default_encoder__;
	verb = string_upper(verb);

	// Get options
	var paramKeys = variable_struct_get_names(options);
	var overriddenSubject = false;
	for (var i = array_length(paramKeys)-1; i >= 0; --i) {
		var paramKey = paramKeys[i];
		var paramVal = variable_struct_get(options, paramKey);
		switch (paramKey) {
			case "decoder":
				if (is_undefined(paramVal)) {
					daemon.decoder = xhr_decoder_none;
				} else {
					daemon.decoder = paramVal;
				}
				break;
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
				daemon.subject = is_method(paramVal) ? paramVal() : paramVal;
				overriddenSubject = true;
				break;
		}
	}
	if (!overriddenSubject) {
		daemon.subject = is_method(global.__reqm_default_subject__) ? global.__reqm_default_subject__() : global.__reqm_default_subject__;
	}

	// Extract body
	var bodyContent, bodyHelper;
	if (is_struct(body)) {
		bodyHelper = (instanceof(body) == "struct") ? encoder(body) : body;
		bodyContent = bodyHelper.getBody();
	} else {
		bodyHelper = undefined;
		bodyContent = body;
	}

	// HTML5 only: If verb is not GET or POST, HEAD, OPTIONS or TRACE, stick _method parameter and change verb to POST
	if (os_browser != browser_not_a_browser) {
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
