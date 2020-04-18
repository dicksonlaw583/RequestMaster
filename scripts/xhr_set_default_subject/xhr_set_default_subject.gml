///@func xhr_set_default_subject(subject)
///@param subject Instance ID, or xhr_subject_noone or xhr_subject_self, or function returning an instance ID and/or noone
function xhr_set_default_subject(subject) {
	//var subject = argument0;
	global.__reqm_default_subject__ = is_undefined(subject) ? noone : subject;
}

#macro xhr_subject_noone noone

function xhr_subject_self() {
	try {
		var result = id;
		if (id > 0) {
			return result;
		}
	} catch (ex) {}
	return noone;
}
