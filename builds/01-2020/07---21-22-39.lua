local github_link = "https://github.com/a801-luadev/toculabs"
local featured_rooms = {
	"bolodefchoco", "toculabs0youtube", "fortmice"
}
local available_modes = {
	"youtube"
}

local starting = string.sub(tfm.get.room.name, 1, 2)

local tribe, module_name, submode
local room_owner
local enabled_pw_setting = true
local flags = ""

--[[ File translations/init.lua ]]--
local translations, global_translations
translations = setmetatable({}, {
	__index = function()
		return translations.en
	end
})
global_translations = setmetatable({}, {
	__index = function()
		return global_translations.en
	end
})
--[[ File translations/global/en.lua ]]--
global_translations.en = {
	welcome = [[<vp>Welcome to <b>Tocu Laboratories</b>!
Contribute to us in GitHub: <b>%s</b>
Use [<d>!help</d>] to get more information.
• Join our official Discord server to get help with Lua and modules: <b>https://discord.gg/quch83R</b>
<d>Tip: You'd also check this room: <b>#%s</b>.</d>]],

	lang_set = "<j>Module language set to: [<d>English (en)</d>].",
	current_lang = "<j>Current module language: [<d>English (en)</d>].",

	help = "<vp>What is <b>Tocu Laboratories</b>?\n<j><d><b>Tocu Laboratories</b></d> is a module hosted by <d><b>Tocutoeltuco#0000</b></d>, used to publish and test stuff. You can see the project/submode list by typing <d><b>!modes</b></d> in the chat.\n<vp>Can I host something in the module?\n<j>Of course you can. You need to go to our github repository (<d><b>%s</b></d>), fork it and add your module here. In the README file you'll have all the information.\n<vp>What are the available commands?\n<j>You can use the <d><b>!commands</b></d> command to see them.",
	use_info = "<d>Tip: Use [<j>!info</j>] to get information about this submode.</d>",
	help_command_help = "Shows information about Tocu Laboratories. You can also use [<d>!help [command]</d>] to get more information about a command.",
	help_command_modes = "Shows available submodes.",
	help_command_info = "Shows information about the current submode, if any.",
	help_command_lang = "Sets your module language.",
	help_command_pw = "Sets the room password if possible.",
	help_command_commands = "Shows the available commands.",
	no_help_provided = "<r>The command [<d>!%s</d>] doesn't have any help text.",

	cant_set_pw = "<r>Can't set the password.",

	unknown_command = "<r>Unknown command [<d>!%s</d>].",
	invalid_syntax = "<r>Invalid syntax. Use [<d>!help %s</d>] to get more information.",

	new_password = "New room password: [<d>%s</d>].",
	password_removed = "The room password has been removed."
}
translations.en = global_translations.en

--[[ File global/event-handler.lua ]]--
local onEvent
do
	local events = {}

	function onEvent(name, callback)
		local evt
		if events[name] then
			evt = events[name]
		else
			evt = {_count = 0}
			events[name] = evt

			_G["event" .. name] = function(...)
				for index = 1, evt._count do
					if evt[index](...) == "break" then
						return
					end
				end
			end
		end

		evt._count = evt._count + 1
		evt[evt._count] = callback
	end
end
--[[ File global/translation-handler.lua ]]--
local player_langs = {}

local translatedChatMessage
do
	local chatMessage = tfm.exec.chatMessage
	function translatedChatMessage(what, who, ...)
		if not who then
			for player in next, player_langs do
				translatedChatMessage(what, player, ...)
			end
			return
		end
		local text = player_langs[who][what]
		if not text then
			text = "%" .. what .. "%"
		elseif select("#", ...) > 0 then
			done, text = pcall(string.format, text, ...)
			if not done then
				error(debug.traceback())
			end
		end
		chatMessage(text, who)
	end
end

onEvent("NewPlayer", function(player)
	player_langs[player] = translations[tfm.get.room.playerList[player].community]
end)
--[[ File global/command-handler.lua ]]--
local commands = {}

onEvent("ChatCommand", function(player, message)
	local cmd, args, counter = "", {}, 0
	for slice in string.gmatch(message, "%S+") do
		if counter == 0 then
			cmd = string.lower(slice)
		else
			args[counter] = slice
		end
		counter = counter + 1
	end

	if commands[cmd] then
		return commands[cmd](player, args, counter - 1)
	else
		translatedChatMessage("unknown_command", player, cmd)
	end
end)

system.disableChatCommandDisplay(nil)

commands.help = function(player, args, quantity)
	if quantity == 0 then
		translatedChatMessage("help", player, github_link)
		if player_langs[player].submode_info then
			translatedChatMessage("use_info", player)
		end
	else
		local searching = string.lower(args[1])

		if commands[searching] then
			local txt = player_langs[player]["help_command_" .. searching]

			if txt then
				tfm.exec.chatMessage("<j>[!" .. searching .. "]: <n>" .. txt, player)
			else
				translatedChatMessage("no_help_provided", player, cmd)
			end
		else
			translatedChatMessage("unknown_command", player, cmd)
		end
	end
end

commands.info = function(player, args, quantity)
	if player_langs[player].submode_info then
		translatedChatMessage("submode_info", player)
	end
end

commands.lang = function(player, args, quantity)
	if quantity == 0 then
		translatedChatMessage("current_lang", player)
	else
		player_langs[player] = translations[string.lower(args[1])]
		translatedChatMessage("lang_set", player)
	end
end

commands.pw = function(player, args, quantity)
	if player ~= room_owner then
		return translatedChatMessage("cant_set_pw", player)
	end

	if enabled_pw_setting then
		if quantity >= 1 then
			local password = table.concat(args, " ")
			tfm.exec.setRoomPassword(password)
			translatedChatMessage("new_password", player, password)
		else
			tfm.exec.setRoomPassword("")
			translatedChatMessage("password_removed", player)
		end
	else
		translatedChatMessage("cant_set_pw", player)
	end
end

commands.commands = function(player, args, quantity)
	local text, first = "<j>", true
	for command in next, commands do
		if first then
			first = false
		else
			text = text .. ", "
		end
		text = text .. "<d><b>!" .. command .. "</b></d>"
	end
	tfm.exec.chatMessage(text, player)
end

commands.modes = function(player, args, quantity)
	local text, first = "<j>", true
	for index, mode in next, available_modes do
		if first then
			first = false
		else
			text = text .. ", "
		end
		text = text .. "<d><b>#" .. (module_name or "toculabs") .. "0" .. mode .. "</b></d>"
	end
	tfm.exec.chatMessage(text, player)
end

if starting == "*\003" then
	tribe = string.sub(tfm.get.room.name, 3)

	if tribe == "Runtime error" then
		--[[ File youtube-searcher/room-gateway.lua ]]--
		--[[
			Here's how it does work:

			We use playerdata. To do so, we need to share a "stream channel" (the user).
			Transformice's playerdata does only work when the player we're requesting to load/save
			the data is online. And that's why we use Sharpiebot#0000 as the "stream channel",
			since it will always be online.

			We also need a communication protocol. Firstly we define our messages:
			Starting with - -> Dead communication
			Starting with _ -> Heartbeat (keep alive)
			Starting with ? -> Any room request
			Starting with ! -> Syncing room (tunnel) answer
			Every packet will have the expire date first, followed by a colon
			and then by the message. If the date expires, we set the "dead communication"
			message, just to warn any room that has acquired the lock, that it will be
			forcibly released once this "dead communication" message expires.

			Once we want to communicate, we need to make sure that no other room will
			overwrite our messages! To do so, we apply a "lock". If the player data is empty
			the lock is free, and any room can feel free to acquire it. They do so by
			setting their name as a message. Once they do it, they need to load the data
			and check if their name is still here. If it is, then no other room will try
			to overwrite our messages, and we can freely start our communication.
		]]

		local stream_bot = "Sharpiebot#0000"

		local acquire_stream
		local set_stream_failure_callback
		local set_stream_request_callback
		local send_stream_message
		local wait_stream_answer
		local toggle_heartbeat_system
		local release_stream
		do
			local heartbeat = false
			local last_message = 0
			local message_lifetime = 2500
			local heartbeat_every = 2000
			local next_heartbeat = 0
			local acquiring = false
			local request_callback = nil
			local failure_callback = nil
			local is_handler = false
			local answer_waiter, answer_args = nil, nil
			local acquire_waiter, acquire_args = nil, nil
			local time = os.time
			local unpack = table.unpack
			local room_name = tfm.get.room.name

			function acquire_stream(callback, ...)
				acquiring = true
				acquire_waiter, acquire_args = callback, {...}
			end

			function toggle_heartbeat_system(state)
				heartbeat = state
			end

			function wait_stream_answer(callback, ...)
				answer_waiter, answer_args = callback, {...}
			end

			function release_stream()
				system.savePlayerData(stream_bot, "")
			end

			function set_stream_request_callback(callback)
				request_callback = callback
			end

			function send_stream_message(prefix, message, when)
				when = when or time()
				system.savePlayerData(stream_bot, (when + message_lifetime) .. ":" .. prefix .. message)
			end

			function set_stream_failure_callback(callback)
				failure_callback = callback
			end

			local function try_heartbeat()
				local now = time()
				if heartbeat and now >= next_heartbeat then
					send_stream_message("_", "", now)
					next_heartbeat = now + heartbeat_every
				end
			end

			onEvent("PlayerDataLoaded", function(player, data)
				if player ~= stream_bot then return end

				local date, msg = string.match(data, "^(%d+):(.+)$")
				if date then
					date = tonumber(date)
					now = time()
					if date <= now then
						if msg == "-" then
							system.savePlayerData(stream_bot, "")
							date, msg = 0, ""
						else
							send_stream_message("-", "", now)
							date, msg = now + message_lifetime, "-"
						end
					elseif date <= last_message then
						return try_heartbeat()
					end
					last_message = date
				else
					date, msg = 0, ""
				end

				if msg == "-" then
					if failure_callback and (answer_waiter or request_callback) then
						answer_waiter = nil
						failure_callback()
					end
					return
				end

				if request_callback then
					request_callback(msg)
				else
					if acquiring then
						if msg == "" then
							send_stream_message("", room_name)
						elseif msg == room_name then
							acquiring = false
							acquire_waiter(unpack(acquire_args))
							acquire_waiter = nil
						end
					elseif answer_waiter and string.sub(msg, 1, 1) == "!" then
						local last_args = answer_args
						answer_waiter(msg, unpack(answer_args))
						if last_args == answer_args then
							answer_waiter = nil
						end
					end
				end
				try_heartbeat()
			end)
		end
		--[[ File youtube-searcher/tunnel.lua ]]--
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
	else
		--[[ File main/init.lua ]]--
		tfm.exec.disableAutoNewGame(true)
		tfm.exec.disableAutoShaman(true)
		tfm.exec.disableAfkDeath(true)
		tfm.exec.disableMortCommand(true)
		tfm.exec.newGame(7642505)
		tfm.exec.setGameTime(99999)

		onEvent("NewPlayer", function(player)
			tfm.exec.respawnPlayer(player)

			translatedChatMessage(
				"welcome",
				player,
				github_link,
				featured_rooms[math.random(#featured_rooms)]
			)
		end)

		onEvent("PlayerDied", tfm.exec.respawnPlayer)
	end
else
	local pos
	if starting == "*#" then
		module_name = string.match(tfm.get.room.name, "^%*#([a-z]+)")
		pos = #module_name + 3
	else
		module_name = string.match(tfm.get.room.name, "^[a-z][a-z]%-#([a-z]+)")
		pos = #module_name + 5
	end

	local numbers
	numbers, submode = string.match(tfm.get.room.name, "^(%d+)([a-z_]+)", pos)
	if numbers then
		flags = string.sub(tfm.get.room.name, pos + #numbers + #submode + 1)
	end

	if submode == "youtube" then
		--[[ File translations/youtube-searcher/en.lua ]]--
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
		--[[ File youtube-searcher/room-gateway.lua ]]--
		--[[
			Here's how it does work:

			We use playerdata. To do so, we need to share a "stream channel" (the user).
			Transformice's playerdata does only work when the player we're requesting to load/save
			the data is online. And that's why we use Sharpiebot#0000 as the "stream channel",
			since it will always be online.

			We also need a communication protocol. Firstly we define our messages:
			Starting with - -> Dead communication
			Starting with _ -> Heartbeat (keep alive)
			Starting with ? -> Any room request
			Starting with ! -> Syncing room (tunnel) answer
			Every packet will have the expire date first, followed by a colon
			and then by the message. If the date expires, we set the "dead communication"
			message, just to warn any room that has acquired the lock, that it will be
			forcibly released once this "dead communication" message expires.

			Once we want to communicate, we need to make sure that no other room will
			overwrite our messages! To do so, we apply a "lock". If the player data is empty
			the lock is free, and any room can feel free to acquire it. They do so by
			setting their name as a message. Once they do it, they need to load the data
			and check if their name is still here. If it is, then no other room will try
			to overwrite our messages, and we can freely start our communication.
		]]

		local stream_bot = "Sharpiebot#0000"

		local acquire_stream
		local set_stream_failure_callback
		local set_stream_request_callback
		local send_stream_message
		local wait_stream_answer
		local toggle_heartbeat_system
		local release_stream
		do
			local heartbeat = false
			local last_message = 0
			local message_lifetime = 2500
			local heartbeat_every = 2000
			local next_heartbeat = 0
			local acquiring = false
			local request_callback = nil
			local failure_callback = nil
			local is_handler = false
			local answer_waiter, answer_args = nil, nil
			local acquire_waiter, acquire_args = nil, nil
			local time = os.time
			local unpack = table.unpack
			local room_name = tfm.get.room.name

			function acquire_stream(callback, ...)
				acquiring = true
				acquire_waiter, acquire_args = callback, {...}
			end

			function toggle_heartbeat_system(state)
				heartbeat = state
			end

			function wait_stream_answer(callback, ...)
				answer_waiter, answer_args = callback, {...}
			end

			function release_stream()
				system.savePlayerData(stream_bot, "")
			end

			function set_stream_request_callback(callback)
				request_callback = callback
			end

			function send_stream_message(prefix, message, when)
				when = when or time()
				system.savePlayerData(stream_bot, (when + message_lifetime) .. ":" .. prefix .. message)
			end

			function set_stream_failure_callback(callback)
				failure_callback = callback
			end

			local function try_heartbeat()
				local now = time()
				if heartbeat and now >= next_heartbeat then
					send_stream_message("_", "", now)
					next_heartbeat = now + heartbeat_every
				end
			end

			onEvent("PlayerDataLoaded", function(player, data)
				if player ~= stream_bot then return end

				local date, msg = string.match(data, "^(%d+):(.+)$")
				if date then
					date = tonumber(date)
					now = time()
					if date <= now then
						if msg == "-" then
							system.savePlayerData(stream_bot, "")
							date, msg = 0, ""
						else
							send_stream_message("-", "", now)
							date, msg = now + message_lifetime, "-"
						end
					elseif date <= last_message then
						return try_heartbeat()
					end
					last_message = date
				else
					date, msg = 0, ""
				end

				if msg == "-" then
					if failure_callback and (answer_waiter or request_callback) then
						answer_waiter = nil
						failure_callback()
					end
					return
				end

				if request_callback then
					request_callback(msg)
				else
					if acquiring then
						if msg == "" then
							send_stream_message("", room_name)
						elseif msg == room_name then
							acquiring = false
							acquire_waiter(unpack(acquire_args))
							acquire_waiter = nil
						end
					elseif answer_waiter and string.sub(msg, 1, 1) == "!" then
						local last_args = answer_args
						answer_waiter(msg, unpack(answer_args))
						if last_args == answer_args then
							answer_waiter = nil
						end
					end
				end
				try_heartbeat()
			end)
		end
		--[[ File youtube-searcher/frontend.lua ]]--
		local request_video -- allocated here but defined in backend, so it can be used in frontend

		local images_data = {
			background = {id = "16f70f5ab9a.jpg", target = "_0", x = 0, y = 20},
			loading_search = {id = "16f70f968da.png", target = "#1001", x = -76, y = -58},
			loading_thumbnail = {id = "16f70fdfc06.png", x = -40, y = -31},
			separator_bar = {id = "16f710e4bf6.png", target = "!1", x = 20},

			video_thumbnail = {target = "!2", x = 10},

			invisible = {id = "16f7bad9cde.png"},

			popup_cover_left = {id = "16f7cd5f41f.jpg", target = "&1", x = 195, y = 23},
			popup_cover_right = {id = "16f7cd5f41f.jpg", target = "&1", x = 687, y = 23},
			popup_cover_top = {id = "16f7cd61361.jpg", target = "&1", x = 195, y = 23},
			popup_cover_bottom = {id = "16f7cde1a5b.jpg", target = "&1", x = 195, y = 55},

			search_icon = {id = "16f7cf485c3.png", target = "_1", x = 725, y = 30}
		}
		local mapName = "<j>Tocu Laboratories <bl>- Tocutoeltuco#0000   <g>|   <n>YouTube searcher<"

		local images = {}
		do
			local image_ids = {}
			for image in next, images_data do
				image_ids[image] = {_count = 0}
			end

			local addImage = tfm.exec.addImage
			local removeImage = tfm.exec.removeImage

			function images:load(which, who, target, y)
				local data = images_data[which]
				local id = addImage(data.id, target or data.target, data.x, y or data.y, who)
				local ids = image_ids[which]

				ids._count = ids._count + 1
				ids[ids._count] = id

				return id
			end

			function images:unload(which)
				local ids = image_ids[which]
				for index = 1, ids._count do
					removeImage(ids[index])
				end
				image_ids._count = 0
			end
		end

		local videos = {_count = 0}
		local searching = ""
		local requested_by = ""
		local state = 0 -- 0 (background only) | 1 (searching) | 2 (loading thumbnails) | 3 (fully completed)

		local function remove_video(index, video, player)
			for index = 1, video.thumbnail_ids._count do
				tfm.exec.removeImage(video.thumbnail_ids[index], player)
			end
			ui.removeTextArea(index, player)
			ui.removeTextArea(index * 10, player)
		end

		local function load_video(index, video, player)
			local load_data = images_data.loading_thumbnail
			local thumb_data = images_data.video_thumbnail
			local id
			if video.loading_thumbnail then
				id = tfm.exec.addImage(load_data.id, "#100" .. (index + 1), load_data.x, load_data.y, player)
			else
				id = tfm.exec.addImage(video.thumbnail_id, thumb_data.target, thumb_data.x, -25 + index * 110, player)
			end
			video.thumbnail_ids._count = video.thumbnail_ids._count + 1
			video.thumbnail_ids[video.thumbnail_ids._count] = id

			if index < videos._count then
				images:load("separator_bar", player, nil, 60 + index * 110)
			end

			ui.addTextArea(
				index,
				string.gsub(
					string.gsub(
						string.format(
							"<font size='14' color='#ffffff'>%s</font>\n<font size='10'>%s</font>\n\n<font size='11'>%s</font>",
							video.title,
							video.author,
							video.desc
						), "http", "ttp"
					), "://", "//"
				),
				player,
				115, (index > 1 and -30 or -20) + index * 110, -- The popup covers the first result if it is in -30.
				660, 85,
				0, 0, 0
			)
			ui.addTextArea(
				index * 10,
				"<a href='event:show_info'>\n\n\n\n\n\n",
				player,
				0, -35 + index * 110,
				800, 95,
				0, 0, 0
			)
		end

		local function update_video(index, video, player)
			remove_video(index, video, player)
			load_video(index, video, player)
		end

		local function show_interface(player)
			if #searching > 0 then
				ui.updateTextArea(0, "<a href='event:search'>" .. searching .. "</a>", player)
			else
				if player then
					ui.updateTextArea(0, "<a href='event:search'>" .. player_langs[player].click_to_search .. "</a>", player)
				else
					for player, lang in next, player_langs do
						ui.updateTextArea(0, "<a href='event:search'>" .. lang.click_to_search .. "</a>", player)
					end
				end
			end

			if state == 0 then
				images:unload("separator_bar")
				images:unload("loading_search")

				for index = 1, videos._count do
					remove_video(index, videos[index])
				end

			elseif state == 1 then
				for index = 1, videos._count do
					remove_video(index, videos[index])
				end

				images:unload("separator_bar")
				images:load("loading_search", player)

			elseif state == 2 or state == 3 then
				for index = 1, videos._count do
					update_video(index, videos[index], player)
				end

				images:unload("loading_search")
			end
		end

		onEvent("NewPlayer", function(player)
			translatedChatMessage(
				"welcome",
				player,
				github_link,
				featured_rooms[math.random(#featured_rooms)]
			)

			for obj = 1, 5 do
				tfm.exec.removeImage(
					tfm.exec.addImage(images_data.invisible.id, "#100" .. obj, 0, 0, player)
				) -- Removes the ground sprites
			end

			images:load("background", player)
			images:load("popup_cover_left", player)
			images:load("popup_cover_right", player)
			images:load("popup_cover_top", player)
			images:load("popup_cover_bottom", player)
			images:load("search_icon", player)
			ui.addTextArea(0, "<a href='event:search'>" .. player_langs[player].click_to_search .. "</a>", player, 212, 35, 475, 20, 0x1d1d1d)
			ui.setMapName(mapName)

			if state > 0 then
				translatedChatMessage("now_searching", player, searching, requested_by)
				show_interface(player)
			end
		end)

		onEvent("TextAreaCallback", function(id, player, callback)
			if callback == "show_info" then
				local video = videos[id / 10]

				if video then
					translatedChatMessage(
						"video_info", player,
						video.title,
						"https://youtu.be/" .. video.id,
						video.author,
						video.desc,
						video.thumbnail_id and ("http://images.atelier801.com/" .. video.thumbnail_id) or player_langs[player].not_loaded
					)
				else
					translatedChatMessage("internal_error", player)
				end
			elseif callback == "search" then
				ui.addPopup(0, 2, "", player, 200, 20, 500)
			end
		end)

		onEvent("PopupAnswer", function(id, player, answer)
			if answer == "" then return end

			if state == 1 or state == 2 then
				return translatedChatMessage("cant_search", player)
			end

			request_video(answer, player)
			translatedChatMessage("scheduled", player)
		end)

		commands.search = function(player, args, quantity)
			if quantity == 0 then
				translatedChatMessage("invalid_syntax", player, "search")
			else
				if state == 1 or state == 2 then
					return translatedChatMessage("cant_search", player)
				end

				request_video(table.concat(args, " "), player)
				translatedChatMessage("scheduled", player)
			end
		end

		tfm.exec.disableAutoNewGame(true)
		tfm.exec.disableAutoShaman(true)
		tfm.exec.disableAfkDeath(true)
		tfm.exec.disableMortCommand(true)
		tfm.exec.newGame(7671242)
		tfm.exec.setGameTime(99999)
		--[[ File youtube-searcher/backend.lua ]]--
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
				for id, title, author, desc in string.gmatch(string.sub(answer, 2), "([^#]+)#([^#]+)#([^#]+)#([^#]+)#") do
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
	else
		--[[ File main/init.lua ]]--
		tfm.exec.disableAutoNewGame(true)
		tfm.exec.disableAutoShaman(true)
		tfm.exec.disableAfkDeath(true)
		tfm.exec.disableMortCommand(true)
		tfm.exec.newGame(7642505)
		tfm.exec.setGameTime(99999)

		onEvent("NewPlayer", function(player)
			tfm.exec.respawnPlayer(player)

			translatedChatMessage(
				"welcome",
				player,
				github_link,
				featured_rooms[math.random(#featured_rooms)]
			)
		end)

		onEvent("PlayerDied", tfm.exec.respawnPlayer)
	end
end

for player in next, tfm.get.room.playerList do
	eventNewPlayer(player)
	if not room_owner then
		room_owner = player
	end
end
