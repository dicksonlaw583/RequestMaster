///@func __xwfu_encode_substruct__(prefix, val)
///@param prefix
///@param val
function __xwfu_encode_substruct__(argument0, argument1) {
	var i, len, k, ks, keys, str;
	keys = variable_struct_get_names(argument1);
	len = array_length(keys);
	str = "";
	
	// Loop through all top-level keys
	for (var i = 0; i < len; ++i) {
		// Entry separator
		if (i > 0) {
			str += "&";
		}
		// Add the key (if applicable) and value
		k = keys[i];
		ks = __xwfu_encode_string__(k);
		var v = variable_struct_get(argument1, k);
		switch (typeof(v)) {
			case "string":
				str += argument0 + "%5B" + ks + "%5D=" + __xwfu_encode_string__(v);
			break;
			case "bool":
				str += argument0 + "%5B" + ks + "%5D=" + (v ? "true" : "false");
			break;
			case "struct":
				str += __xwfu_encode_substruct__(argument0 + "%5B" + ks + "%5D", v);
			break;
			case "array":
				str += __xwfu_encode_subarray__(argument0 + "%5B" + ks + "%5D", v);
			break;
			case "method": break;
			default:
				str += argument0 + "%5B" + ks + "%5D=" + __xwfu_encode_string__(string(v));
		}
	}
	
	return str;
}