///@desc Set Request Master defaults here

/**
Set the default callback subject here. Valid values include:
- xhr_subject_noone: Run callbacks anonymously.
- xhr_subject_self: Run callbacks as the instance that started the request.
- Any instance ID.
- Any expression returning an instance ID.
*/
#macro REQM_DEFAULT_SUBJECT xhr_subject_self

/**
Set the default response text decoder here.
- No transform: string
- Decode JSON to plain structs via built-in: json_parse
- Decode JSON to plain structs via JSON Structs: jsons_decode
- Decode JSON to JsonStructs via JSON Structs: jsons_decode_safe
- Decode JSON to maps: jsons_decode_to_map
- Custom decode type: Specify the name of a function that takes a string and returns the decoded result, throwing an exception if unsuccessful
*/
#macro REQM_DEFAULT_DECODER json_parse

/**
Set the default body encoder here.
This will run when an untyped struct is passed as the body.
- URL-encoded body: XwfuBody
- Multipart form data body: MultipartBody
- JSON body via JSON Structs: JsonBody
- JSON body via built-in: StructBody
- Custom encode type: Specify the name of a constructor implementing body helper methods (i.e. setHeader(map), getBody(), cleanBody(body) --- see RequestBody for examples)
*/
#macro REQM_DEFAULT_ENCODER XwfuBody

/**
Set the default URL root here (including the final slash).
This will be prepended all relative request URLs (i.e. NOT an absolute URL that starts with "http:" or "https:").
*/
xhr_url_root("http://localhost/");
