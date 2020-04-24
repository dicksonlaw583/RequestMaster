///@desc Set Request Master defaults here
// A bug in function handling is keeping this from being shorter, will uncomment defaults once fixed
//xhr_set_default_subject(xhr_subject_self);
//xhr_set_default_decoder(xhr_decoder_json);
//xhr_set_default_encoder(xhr_encoder_xwfu);
xhr_set_default_subject(function() { return xhr_subject_self(); });
xhr_set_default_decoder(function(d) { return xhr_decoder_json(d); });
xhr_set_default_encoder(function(d) { return xhr_encoder_xwfu(d); });