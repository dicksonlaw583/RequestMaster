///@desc Setup
subject = REQM_DEFAULT_SUBJECT;
request = -1;
doneCallback = function(res) {};
failCallback = function(res) {};
progressCallback = function(loaded, total) {};
decoder = function(d) { return REQM_DEFAULT_DECODER(d) };
headers = ds_map_create();
