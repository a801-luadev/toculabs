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
		translatedChatMessage("help", player)
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