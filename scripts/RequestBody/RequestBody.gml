///@func RequestBody(data)
///@param {Struct,Struct.JsonStruct} data
///@desc A generic Request Master request body.
function RequestBody(data) constructor {
	self.data = data;
	
	///@func addValue(k, v)
	///@param {string} k The key to add.
	///@param {Any} v The value to add.
	///@desc Add the given key-value pair to this request body.
	static addValue = function(k, v) {
		switch (instanceof(data)) {
			case "JsonStruct":
				data.set(k, v);
				break;
			default:
				variable_struct_set(data, k, v);
		}
	};
	
	///@func cleanBody()
	///@desc Do the cleanup routines for this request body.
	static cleanBody = function() {
		
	};
}

///@func JsonBody(data)
///@param {Struct,Struct.JsonStruct} data
///@desc An application/json request body encoded using JSON Structs.
function JsonBody(data) : RequestBody(data) constructor {
	///@func setHeader(map)
	///@param {Id.DsMap} map 
	///@desc Set headers applicable to this request body type in the given header map.
	static setHeader = function(map) {
		map[? "Content-Type"] = "application/json";
	};
	
	///@func getBody()
	///@return {String}
	///@desc Get the request body's contents as a string.
	static getBody = function() {
		return jsons_encode(data);
	};
}

///@func StructBody(data)
///@param {Struct} data 
///@desc An application/json request body encoded using json_stringify().
function StructBody(data) : RequestBody(data) constructor {
	///@func setHeader(map)
	///@param {Id.DsMap} map 
	///@desc Set headers applicable to this request body type in the given header map.
	static setHeader = function(map) {
		map[? "Content-Type"] = "application/json";
	};
	
	///@func getBody()
	///@return {String}
	///@desc Get the request body's contents as a string.
	static getBody = function() {
		return json_stringify(data);
	};
}

function XwfuBody(data) : RequestBody(data) constructor {
	///@func setHeader(map)
	///@param {Id.DsMap} map 
	///@desc Set headers applicable to this request body type in the given header map.
	static setHeader = function(map) {
		map[? "Content-Type"] = "application/x-www-form-urlencoded";
	};
	
	///@func getBody()
	///@return {String}
	///@desc Get the request body's contents as a string.
	static getBody = function() {
		return xwfu_encode(data);
	};
}

function MultipartBody(data) : RequestBody(data) constructor {
	self.mpdb = new MultipartDataBuilder(data);
	
	///@func setBoundary
	///@param {String} boundary The boundary string to use.
	///@desc Set this multipart/form-data request body's boundary string.
	static setBoundary = function(boundary) {
		mpdb.boundary = boundary;
	};
	
	///@func setHeader(map)
	///@param {Id.DsMap} map 
	///@desc Set headers applicable to this request body type in the given header map.
	static setHeader = function(map) {
		mpdb.writeHeaderMap(map);
	};
	
	///@func getBody()
	///@return {Id.Buffer}
	///@desc Get the request body's contents as a buffer.
	static getBody = function() {
		return mpdb.getBuffer();
	};
	
	///@func cleanBody()
	///@desc Do the cleanup routines for this request body.
	static cleanBody = function(body) {
		buffer_delete(body);
	};
}
