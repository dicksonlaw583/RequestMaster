function RequestBody(strc) constructor {
	data = strc;
	static addValue = function(k, v) {
		switch (instanceof(data)) {
			case "JsonStruct":
				data.set(k, v);
				break;
			default:
				variable_struct_set(data, k, v);
		}
	};
}

function JsonBody(strc) : RequestBody(strc) constructor {
	static setHeader = function(map) {
		map[? "Content-Type"] = "application/json";
	};
	static getBody = function() {
		return jsons_encode(data);
	};
	static cleanBody = function(body) {};
}

function StructBody(strc) : RequestBody(strc) constructor {
	static setHeader = function(map) {
		map[? "Content-Type"] = "application/json";
	};
	static getBody = function() {
		return json_stringify(data);
	};
	static cleanBody = function(body) {};
}

function XwfuBody(strc) : RequestBody(strc) constructor {
	static setHeader = function(map) {
		map[? "Content-Type"] = "application/x-www-form-urlencoded";
	};
	static getBody = function() {
		return xwfu_encode(data);
	};
	static cleanBody = function(body) {};
}

function MultipartBody(strc) : RequestBody(strc) constructor {
	mpdb = new MultipartDataBuilder(data);
	static setBoundary = function(boundary) {
		mpdb.boundary = boundary;
	};
	static setHeader = function(map) {
		mpdb.writeHeaderMap(map);
	};
	static getBody = function() {
		return mpdb.getBuffer();
	};
	static cleanBody = function(body) {
		buffer_delete(body);
	};
}
