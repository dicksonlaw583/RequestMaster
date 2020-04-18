///@func xhr_set_default_decoder(decoder)
///@param decoder Function that accepts a string response from the server and returns a decoded result if successful, throw something if not
function xhr_set_default_decoder(decoder) {
	//var decoder = argument0;
	global.__reqm_default_decoder__ = is_undefined(decoder) ? xhr_decoder_none : decoder;
}

function xhr_decoder_none(d) {
	//var d = argument0;
	return d;
}

function xhr_decoder_json(d) {
	//var d = argument0;
	return jsons_decode(d);
}

function xhr_decoder_json_map(d) {
	//var d = argument0;
	var result = json_decode(d);
	if (result < 0) {
		throw "JSON decode failed";
	}
	return result;
}
