function JsonStructTypeException(val) constructor {
	value = val;
	static toString = function() { return "JSON Structs: Unsupported type " + typeof(value) + ": " + string(value); };
}
