///@func xhr_set_default_encoder(body_type)
///@param body_type function that takes a raw body content and returns a formatted body object
function xhr_set_default_encoder(body_type) {
	//var body_type = argument0;
	global.__reqm_default_encoder__ = is_undefined(body_type) ? xhr_encoder_xwfu : body_type;
}

function xhr_encoder_json(s) {
	//var s = argument0;
	return new JsonBody(s);
}

function xhr_encoder_xwfu(s) {
	//var s = argument0;
	return new XwfuBody(s);
}

function xhr_encoder_multipart(s) {
	//var s = argument0;
	return new MultipartBody(s);
}
