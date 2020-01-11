local bot_status = {}
local bot_loading = 0
local next_load = 0
local loaded_file = false
local need_save = false
local next_save = 0
local shown = false
local next_show = 0

tfm.exec.disableAutoNewGame(true)
tfm.exec.disableAutoShaman(true)
tfm.exec.disableAfkDeath(true)
tfm.exec.disableMortCommand(true)
tfm.exec.newGame(7642505)
tfm.exec.setGameTime(99999)

local function show_bots()
	shown = true
	next_show = os.time() + 60000

	local names, statuses = "", ""
	for bot, status in next, bot_status do
		names = names .. "\n" .. bot
		statuses = statuses .. "\n" .. (status and "<vp>online</vp>" or "<r>offline</r>")
	end

	ui.addTextArea(0, "", "Tocutoeltuco#0000", 20, 40, 760, 340, 0x324650, 1, 1, true)
	ui.addTextArea(1, "", "Tocutoeltuco#0000", 400, 40, 380, 340, 0x324650, 1, 1, true)
	ui.addTextArea(2, "", "Tocutoeltuco#0000", 20, 40, 760, 25, 1, 1, 1, true)
	ui.addTextArea(3, "<font size='16'>Bot name</font>\n" .. names, "Tocutoeltuco#0000", 20, 40, 380, 340, 0, 0, 0, true)
	ui.addTextArea(4, "<font size='16'>Status</font>\n" .. statuses, "Tocutoeltuco#0000", 400, 40, 380, 340, 0, 0, 0, true)
	ui.addTextArea(5, "<a href='event:close'><font size='16'>X</font></a>", "Tocutoeltuco#0000", 755, 40, 25, 25, 0xaa0000, 0xaa0000, 1, true)
end

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

commands.bots = function(player, args, quantity)
	if player ~= "Tocutoeltuco#0000" then return end

	bot_loading = 1
end

commands.add_bot = function(player, args, quantity)
	if player ~= "Tocutoeltuco#0000" then return end

	for index = 1, quantity do
		bot_status[args[index]] = false
	end
	need_save = true
end

commands.rem_bot = function(player, args, quantity)
	if player ~= "Tocutoeltuco#0000" then return end

	for index = 1, quantity do
		bot_status[args[index]] = nil
	end
	need_save = true
end

onEvent("FileLoaded", function(n, data)
	if n == "99" then
		for bot in string.gmatch(data, "%S+") do
			bot_status[bot] = false
		end
		loaded_file = true
	end
end)

onEvent("PlayerDataLoaded", function(bot)
	bot_status[bot] = true
	show_bots()
end)

onEvent("TextAreaCallback", function(id, player, cb)
	for _id = 0, 5 do
		ui.removeTextArea(_id, player)
	end
	shown = false
end)

onEvent("Loop", function()
	if os.time() >= next_load then
		system.loadFile(99)
		next_load = os.time() + 60000
	end
	if need_save and os.time() >= next_save then
		next_save = os.time() + 60000
		need_save = false
		local txt = ""
		for bot in next, bot_status do
			if txt == "" then
				txt = bot
			else
				txt = txt .. " " .. bot
			end
		end
		system.saveFile(txt, 99)
		tfm.exec.chatMessage("Saved data.")
	end

	if not loaded_file then return end

	if bot_loading == 1 then
		for bot in next, bot_status do
			system.loadPlayerData(bot)
			bot_status[bot] = false
		end
		bot_loading = 2
	elseif bot_loading == 2 then
		show_bots()
		bot_loading = 0
	end

	if shown and os.time() >= next_show then
		for bot in next, bot_status do
			system.loadPlayerData(bot)
			bot_status[bot] = false
		end
		show_bots()
	end
end)

if tfm.get.room.name == "*#toculabs0village" then
	bot_loading = 1
end