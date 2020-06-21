/**
Configure JSON Structs using these macros.
*/

//Specify the function to use for encoding real values here
//Available built-in values: string / jsons_real_encoder_string_format / jsons_real_encoder_detailed
//You can also specify the name of a function taking a single real argument and returning a string
#macro JSONS_REAL_ENCODER string

//Specify the default decoding mode for JSON objects here
//false: Decode to plain structs. Entries in JSON objects are retrieved via jsonobj.key
//true: Decode to JsonStruct structs. Entries in JSON objects are retrieved via jsonobj.get("key")
//Set to true when you expect to handle JSON containing keys that are invalid as instance variable names.
//Otherwise, leave it at false for the faster and more convenient syntax.
jsons_conflict_mode(false);
