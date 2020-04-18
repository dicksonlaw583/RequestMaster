///@desc Set Request Master defaults here
xhr_set_default_subject(function() { return xhr_subject_self(); });
xhr_set_default_decoder(function(d) { return xhr_decoder_json(d); });
xhr_set_default_encoder(function(d) { return xhr_encoder_xwfu(d); });