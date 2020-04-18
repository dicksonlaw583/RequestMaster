///@func __multipart_generate_boundary__()
function __multipart_generate_boundary__(){
	return "----" + sha1_string_unicode(string(date_current_datetime()));
}
