local load_stream_data = false

local deserializing_values = {
	["&0"] = "&",
	["&1"] = "#"
}
local function deserialize(txt)
	return string.gsub(txt, "&%d", deserializing_values)
end

local on_stream_answer
function on_stream_answer(answer, answer_id)
	if answer_id == 1 then
		state = 2

		videos._count = 0
		for id, title, author, desc in string.gmatch(answer, "([^#]+)#([^#]+)#([^#]+)#([^#]+)#") do
			videos._count = videos._count + 1
			videos[videos._count] = {
				id = deserialize(id),
				title = deserialize(title),
				author = deserialize(author),
				desc = deserialize(desc),
				loading_thumbnail = true,
				thumbnail_id = nil,
				thumbnail_ids = {_count = 0}
			}
		end

		show_interface()
		if videos._count == 0 then
			state = 3
			return
		end
		send_stream_message("?", "!")
		wait_stream_answer(on_stream_answer, 2)
	else
		local index = answer_id - 1
		local video = videos[index]
		video.loading_thumbnail = false
		video.thumbnail_id = string.sub(answer, 2)

		update_video(index, video)

		if answer_id <= videos._count then
			send_stream_message("?", "!")
			wait_stream_answer(on_stream_answer, answer_id + 1)
		else
			release_stream()
			load_stream_data = false
			state = 3
		end
	end
end

local function on_stream_acquired(video, requester)
	searching, requested_by = video, requester
	translatedChatMessage("now_searching", nil, video, requester)
	show_interface()

	send_stream_message("?", video)
	wait_stream_answer(on_stream_answer, 1)
end

function request_video(video, requester)
	state = 1
	load_stream_data = true
	acquire_stream(on_stream_acquired, video, requester)
end

set_stream_failure_callback(function()
	if state == 1 then
		state = 0
		searching = ""
		show_interface()
	else
		state = 3
		images:unload("loading_thumbnail")
	end
	load_stream_data = false
	translatedChatMessage("failure_searching")
end)

onEvent("Loop", function()
	if load_stream_data then
		system.loadPlayerData(stream_bot)
	end
end)