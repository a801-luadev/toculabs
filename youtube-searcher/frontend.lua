local request_video -- allocated here but defined in backend, so it can be used in frontend

local images_data = {
	background = {id = "16f70f5ab9a.jpg", target = "_0", x = 0, y = 20},
	loading_search = {id = "16f70f968da.png", target = "#1017", x = -76, y = -58},
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
		id = tfm.exec.addImage(load_data.id, "#10" .. (index + 17), load_data.x, load_data.y, player)
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

	for obj = 1, 9 do
		tfm.exec.removeImage(
			tfm.exec.addImage(images_data.invisible.id, "#100" .. obj, 0, 0, player)
		) -- Removes the ground sprites
	end
	for obj = 10, 20 do
		tfm.exec.removeImage(
			tfm.exec.addImage(images_data.invisible.id, "#10" .. obj, 0, 0, player)
		) -- Removes the ground and box sprites
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