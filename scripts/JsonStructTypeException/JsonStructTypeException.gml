///@class JsonStructTypeException(value)
///@param {Any} value The encountered value.
///@desc Exception for when JSON Struct tries to encode an unsupported value.
function JsonStructTypeException(value) constructor {
	#region Constructor properties
	self.value = value;
	#endregion
	
	///@func toString()
	///@return {string}
	///@desc Return a message describing the exception.
	static toString = function() {
		return "JSON Structs: Unsupported type " + typeof(value) + ": " + string(value);
	};
}
