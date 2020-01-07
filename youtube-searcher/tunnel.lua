local images = {_count = 0, _index = 0}
local waiting_images = false
local send_image = false

set_stream_request_callback(function(request)
	if string.sub(request, 1, 1) ~= "?" then return end

	if request == "?!" then
		if images._count > images._index then
			images._index = images._index + 1
			send_stream_message("!", images[images._index])
		else
			send_image = true
			toggle_heartbeat_system(true)
		end
	else
		waiting_images = false
		images._count = 0
		images._index = 0
		ui.addTextArea(0, request) -- send the request to the bot
		toggle_heartbeat_system(true)
	end
end)

set_stream_failure_callback(function()
	ui.addTextArea(1, "") -- cancel the request
	toggle_heartbeat_system(false)
end)

onEvent("TextAreaCallback", function(id, name, callback)
	if waiting_images then
		if not send_image then
			images._count = images._count + 1
			images[images._count] = callback
			return
		end
	else
		waiting_images = true
	end
	send_image = false
	toggle_heartbeat_system(false)
	send_stream_message("!", callback)
end)

onEvent("NewPlayer", function(player)
	tfm.exec.chatMessage("loaded v2", player)
end)

onEvent("Loop", function()
	system.loadPlayerData(stream_bot)
end)