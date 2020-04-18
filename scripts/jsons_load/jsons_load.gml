///@func jsons_load(fname)
///@param fname
function jsons_load(argument0) {
	var f = file_text_open_read(argument0),
		jsonstr = file_text_read_string(f);
	while (!file_text_eof(f)) {
		file_text_readln(f);
		jsonstr += "\n" + file_text_read_string(f);
	}
	file_text_close(f);
	return jsons_decode(jsonstr);
}
