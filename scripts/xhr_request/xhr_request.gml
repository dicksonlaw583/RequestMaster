///@func xhr_request(verb, url, body, options)
///@param verb
///@param url
///@param body
///@param options
function xhr_request(verb, url, body, options) {
	//var verb = argument0,
	//	url = argument1,
	//	body = argument2,
	//	options = argument3;
	
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
