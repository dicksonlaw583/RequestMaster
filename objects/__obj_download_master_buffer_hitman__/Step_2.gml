///@desc Try to hit the targeted buffer
try {
    buffer_delete(buffer);
} catch (ex) {
} finally {
    show_debug_message("DownloadMaster hitman cleaned up buffer " + string(buffer));
    instance_destroy();
}
