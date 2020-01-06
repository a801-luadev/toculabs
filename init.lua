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

{% require "translations/init.lua" %}
{% require "translations/global/en.lua" %}

{% require "global/event-handler.lua" %}
{% require "global/translation-handler.lua" %}
{% require "global/command-handler.lua" %}

if starting == "*\003" then
	tribe = string.sub(tfm.get.room.name, 3)

	if tribe == "Runtime error" then
		{% require "youtube-searcher/room-gateway.lua" %}
		{% require "youtube-searcher/tunnel.lua" %}
	else
		{% require "main/init.lua" %}
	end
else
	local pos
	if starting == "*#" then
		module_name = string.match(tfm.get.room.name, "^%*#([a-z]+)")
		pos = #module_name + 3
	else
		module_name = string.match(tfm.get.room.name, "^[a-z][a-z]%-#([a-z]+)")
		pos = #module_name + 4
	end

	local numbers
	numbers, submode = string.match(tfm.get.room.name, "^(%d+)([a-z_]+)", pos)
	if numbers then
		flags = string.match(tfm.get.room.name, "^(.+)$", #numbers + #submode)
	end

	if submode == "youtube" then
		{% require "translations/youtube-searcher/en.lua" %}
		{% require "youtube-searcher/room-gateway.lua" %}
		{% require "youtube-searcher/frontend.lua" %}
		{% require "youtube-searcher/backend.lua" %}
	else
		{% require "main/init.lua" %}
	end
end

for player in next, tfm.get.room.playerList do
	eventNewPlayer(player)
	if not room_owner then
		room_owner = player
	end
end