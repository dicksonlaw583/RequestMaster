///@func __xwfu_encode_subarray__(prefix, value)
///@param prefix
///@param value
function __xwfu_encode_subarray__(argument0, argument1) {
	// Error if size is 0
	var i, len, str;
	len = array_length(argument1);
	str = "";
	
	// Loop through all top-level keys
	for (var i = 0; i < len; ++i) {
		// Entry separator
		if (i > 0) {
			str += "&";
		}
		// Add the "key" (if applicable) and value
		var v = argument1[i];
		switch (typeof(v)) {
			case "string":
				str += argument0 + "%5B" + string(i) + "%5D=" + __xwfu_encode_string__(v);
			break;
			case "bool":
				str += argument0 + "%5B" + string(i) + "%5D=" + (v ? "true" : "false");
			break;
			case "struct":
				str += __xwfu_encode_substruct__(argument0 + "%5B" + string(i) + "%5D", v);
			break;
			case "array":
				str += __xwfu_encode_subarray__(argument0 + "%5B" + string(i) + "%5D", v);
			break;
			case "method": break;
			default:
				str += argument0 + "%5B" + string(i) + "%5D=" + __xwfu_encode_string__(string(v));
		}
	}
	
	// Done
	return str;
}