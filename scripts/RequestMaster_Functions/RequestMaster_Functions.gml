#macro xhr_subject_noone noone
#macro xhr_subject_self -1

///@func xhr_delete(url, body, options)
///@param {String} url The URL to request.
///@param {Struct,String} body The request body to use.
///@param {Struct} options Specs for callbacks and additional properties. 
function xhr_delete(url, body, options) {
	return xhr_request("DELETE", url, body, options);
}

///@func xhr_download(url, filename_or_buffer, options)
///@param {String} url The URL to request.
///@param {String,Id.Buffer} filename_or_buffer The filename or buffer ID to save to.
///@param {Struct} options Specs for callbacks and additional properties.
function xhr_download(url, filename_or_buffer, options) {
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
    var daemon = instance_create_depth(0, 0, 0, __obj_download_master_daemon__);
	daemon.subject = REQM_DEFAULT_SUBJECT;
    
    // Get options
    var paramKeys = variable_struct_get_names(options);
    for (var i = array_length(paramKeys)-1; i >= 0; --i) {
		var paramKey = paramKeys[i];
		var paramVal = variable_struct_get(options, paramKey);
		switch (paramKey) {
			case "done": daemon.doneCallback = paramVal; break;
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
            case "sha1": daemon.sha1Expected = paramVal; break;
			case "subject":
				daemon.subject = paramVal;
				break;
			case "textMode": daemon.textMode = paramVal; break;
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
    
    // Set the request daemon's download target
    if (is_string(filename_or_buffer)) {
        daemon.filename = filename_or_buffer;
        daemon.buffer = buffer_create(1024, buffer_grow, 1)
    } else {
        daemon.filename = undefined;
        daemon.buffer = filename_or_buffer;
    }
    buffer_seek(daemon.buffer, buffer_seek_start, 0);
    
    // Set the request daemon's request
	var reqId = http_request(url, "GET", daemon.headers, daemon.buffer);
	daemon.request = reqId;
    
    // Return the request ID
	return reqId;
}

///@func xhr_get(url, options)
///@param {String} url The URL to request.
///@param {Struct} options Specs for callbacks and additional properties. 
function xhr_get(url, options) {
	return xhr_request("GET", url, "", options);
}

///@func xhr_head(url, options)
///@param {String} url The URL to request.
///@param {Struct} options Specs for callbacks and additional properties. 
function xhr_head(url, options) {
	return xhr_request("HEAD", url, "", options);
}

///@func xhr_options(url, options)
///@param {String} url The URL to request.
///@param {Struct} options Specs for callbacks and additional properties. 
function xhr_options(url, options) {
	return xhr_request("OPTIONS", url, "", options);
}

///@func xhr_patch(url, body, options)
///@param {String} url The URL to request.
///@param {Struct,String} body The request body to use.
///@param {Struct} options Specs for callbacks and additional properties. 
function xhr_patch(url, body, options) {
	return xhr_request("PATCH", url, body, options);
}

///@func xhr_post(url, body, options)
///@param {String} url The URL to request.
///@param {Struct} body The request body to use.
///@param {Struct} options Specs for callbacks and additional properties. 
function xhr_post(url, body, options) {
	return xhr_request("POST", url, body, options);
}

///@func xhr_put(url, body, options)
///@param {String} url The URL to request.
///@param {Struct,String} body The request body to use.
///@param {Struct} options Specs for callbacks and additional properties. 
function xhr_put(url, body, options) {
	return xhr_request("PUT", url, body, options);
}

///@func xhr_request(verb, url, body, options)
///@param {String} verb The HTTP verb to use.
///@param {String} url The URL to request.
///@param {Struct,String} body The request body to use.
///@param {Struct} options Specs for callbacks and additional properties. 
function xhr_request(verb, url, body, options) {
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

///@func xhr_trace(url, options)
///@param {String} url The URL to request.
///@param {Struct} options Specs for callbacks and additional properties. 
function xhr_trace(url, options) {
	return xhr_request("TRACE", url, "", options);
}

///@func xhr_url_root([urlRoot])
///@param {String|undefined} [urlRoot] (optional) The root URL path (including final slash)
///@return {String}
///@desc Set the default URL root if given, otherwise return the current default URL root.
function xhr_url_root(urlRoot=undefined) {
	if (!is_undefined(urlRoot)) {
		global.__reqm_url_root__ = urlRoot;
	}
	return global.__reqm_url_root__;
}
