function XwfuTypeException(_val, _msg) constructor {
	val = _val;
	msg = _msg;
	static toString = function() {
		return msg + ": " + string(val);
	};
}
