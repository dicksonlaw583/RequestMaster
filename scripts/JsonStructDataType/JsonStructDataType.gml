function JsonStruct() constructor {
	if (argument_count == 1) {
		var keys = variable_struct_get_names(argument[0]);
		var nKeys = array_length(keys);
		_data = array_create(nKeys*2);
		var ii = 0;
		for (var i = 0; i < nKeys; ++i) {
			var k = keys[i];
			_data[ii] = k;
			_data[ii+1] = variable_struct_get(argument[0], k);
			ii += 2;
		}
	} else {
		if (argument_count % 2 == 1) show_error("Expected an even number of arguments, got " + string(argument_count) + ".", true);
		_data = array_create(argument_count);
		for (var i = 0; i < argument_count; ++i) {
			_data[i] = argument[i];
		}
	}
	
	static get = function(key) {
		for (var i = array_length(_data)-2; i >= 0; i -= 2) {
			if (_data[i] == key) return _data[i+1];
		}
		return undefined;
	};
	
	static set = function(key, value) {
		var imax = array_length(_data);
		for (var i = 0; i < imax; i += 2) {
			if (_data[@i] == key) {
				_data[@i+1] = value;
				return self;
			}
		}
		_data[@i+1] = value;
		_data[@i] = key;
		return self;
	}
	
	static keys = function() {
		var result = array_create(array_length(_data) div 2);
		var imax = array_length(_data);
		var ii = 0;
		for (var i = 0; i < imax; i += 2) {
			result[ii] = _data[i];
			++ii;
		}
		return result;
	}
	
	static size = function() {
		return array_length(_data) div 2;
	}
}
