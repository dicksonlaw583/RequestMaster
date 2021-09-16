/**
Configure JSON Structs using these macros.
*/

//Specify the function to use for encoding real values here
//Available built-in values: string / jsons_real_encoder_string_format / jsons_real_encoder_detailed
//You can also specify the name of a function taking a single real argument and returning a string
#macro JSONS_REAL_ENCODER string

//Specify the default formatting for jsons_encode_formatted and jsons_save_formatted
//You can specify fixed values or expressions containing global variables for these
#macro JSONS_FORMATTED_COMMA ", "
#macro JSONS_FORMATTED_COLON ": "
#macro JSONS_FORMATTED_INDENT "\t"
#macro JSONS_FORMATTED_MAX_DEPTH infinity
