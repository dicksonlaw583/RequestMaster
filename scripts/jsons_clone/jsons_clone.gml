///@func jsons_clone()
function jsons_clone(argument0) {
	var cloneResult, siz;
	switch (typeof(argument0)) {
		case "struct":
			cloneResult = {};
			var keys = variable_struct_get_names(argument0);
			siz = array_length(keys);
			for (var i = 0; i < siz; ++i) {
				var k = keys[i];
				variable_struct_set(cloneResult, k, jsons_clone(variable_struct_get(argument0, k)));
			}
			return cloneResult;
		break;
		case "array":
			siz = array_length(argument0);
			cloneResult = array_create(siz);
			for (var i = siz-1; i >= 0; --i) {
				cloneResult[i] = jsons_clone(argument0[i]);
			}
			return cloneResult;
		default:
			return argument0;
	}
}