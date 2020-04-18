///@func xwfu_encode(thing)
///@param thing A string or struct
///@desc Return a URL-encoded string of the given string or struct
function xwfu_encode(argument0) {
	if (is_string(argument0)) {
		return __xwfu_encode_string__(argument0);
	} else if (is_struct(argument0)) {
		var keys = variable_struct_get_names(argument0);
		var nKeys = array_length(keys);
		var str = "";
		for (var i = 0; i < nKeys; ++i) {
			if (i > 0) {
				str += "&";
			}
			var k = keys[i];
			var v = variable_struct_get(argument0, k);
			var ks = __xwfu_encode_string__(k);
			switch (typeof(v)) {
				case "string":
					str += ks + "=" + __xwfu_encode_string__(v);
				break;
				case "bool":
					str += ks + "=" + (v ? "true" : "false");
				break;
				case "struct":
					str += __xwfu_encode_substruct__(ks, v);
				break;
				case "array":
					str += __xwfu_encode_subarray__(ks, v);
				break;
				case "method": break;
				default:
					str += ks + "=" + __xwfu_encode_string__(string(v));
			}
		}
		return str;
	} else {
		return __xwfu_encode_string__(string(argument0));
	}
}
