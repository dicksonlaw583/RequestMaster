/// @description jsons_save(fname, thing)
/// @param fname
/// @param thing
function jsons_save(argument0, argument1) {
	var f = file_text_open_write(argument0);
	file_text_write_string(f, jsons_encode(argument1));
	file_text_close(f);
}
