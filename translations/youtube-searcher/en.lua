translations.en = setmetatable({
	cant_search = "<r>Can't make a search yet. Wait until the current one is fully loaded.",
	scheduled = "<j>Your search is now scheduled in the queue.",
	now_searching = "<j>Searching <d>%s</d>. Requested by <d>%s</d>",
	failure_searching = "<r>Something happened with the systems. Wait a minute and try to search again.",
	internal_error = "<r>Internal error.",
	video_info = "<j>Video title: <d>%s</d>\nLink: <d>%s</d>\nChannel: <d>%s</d>\nDescription: <d>%s</d>\nThumbnail: <d>%s</d>",
	not_loaded = "<r>not loaded</r>",
	click_to_search = "Click here to search"
}, {
	__index = global_translations.en
})