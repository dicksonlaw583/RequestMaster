///@class JsonStructParseException(pos, description)
///@param {real} pos String position at which the failure occurred.
///@param {string} description A description of the type of failure.
///@desc Exception for when JSON Struct fails to parse a string.
function JsonStructParseException(pos, description) constructor {
	#region Constructor properties
	self.pos = pos;
	self.description = description;
	#endregion
	
	///@func toString()
	///@return {string}
	///@desc Return a string message describing this exception.
	static toString = function() {
		return description + " at position " + string(pos);
	};
}
