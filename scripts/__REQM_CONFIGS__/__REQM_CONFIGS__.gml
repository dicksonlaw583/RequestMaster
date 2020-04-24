///@desc Set Request Master defaults here

/**
Set the default callback subject here. Valid values include:
- xhr_subject_noone: Run callbacks anonymously.
- xhr_subject_self: Run callbacks as the instance that started the request.
- Any instance ID.
- Any anonymous method returning an instance ID.
*/
xhr_set_default_subject(xhr_subject_self);

/**
Set the default response text decoder here.
- No transform: function(d) { return d; }
- Decode JSON to structs: function(d) { return jsons_decode(d); }
- Decode JSON to maps (proceed on malformed response): function(d) { return json_decode(d); }
- Decode JSON to maps (fail on malformed response): function(d) { var m = json_decode(d); if (m < 0) throw "JSON decode failed"; return m; }
- Custom decode type: Specify an anonymous method taking string input and returning a decoded result
*/
xhr_set_default_decoder(function(d) { return jsons_decode(d); });

/**
Set the default body encoder here. This will run when an untyped struct is passed as the body.
- URL-encoded body: function(s) { return new XwfuBody(s); }
- Multipart form data body: function(s) { return new MultipartBody(s); }
- JSON body: function(s) { return new JsonBody(s); }
- Custom encode type: Specify an anonymous method taking struct input and returning a request body helper (see prebuilt examples for general form)
*/
xhr_set_default_encoder(function(s) { return new XwfuBody(s); });
