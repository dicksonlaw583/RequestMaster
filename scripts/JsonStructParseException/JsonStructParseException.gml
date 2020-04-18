// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function JsonStructParseException(_pos, _description) constructor {
	pos = _pos;
	description = _description;
	static toString = function() {
		return description + " at position " + string(pos)
	};
}
