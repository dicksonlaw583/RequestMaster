///@desc Self-destruct if subject lost
if (subject != noone && !instance_exists(subject)) {
	instance_destroy();
}
