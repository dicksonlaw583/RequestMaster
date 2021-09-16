#define xhr_download
///@func xhr_download(url, filename_or_buffer, options)
///@param url
///@param filename_or_buffer
///@param options
{
	var url = argument0,
		filename_or_buffer = argument1,
		options = argument2;
    
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
