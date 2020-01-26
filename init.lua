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

{% require-package "translations" %}
{% require-package "global" %}

if starting == "*\003" then
	tribe = string.sub(tfm.get.room.name, 3)

	if tribe == "TocuLabs 1" then
		{% require-package "bots/tocutobot" %}
	else
		{% require-package "modes/main" %}
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
		{% require-package "modes/youtube" %}
	else
		{% require-package "modes/main" %}
	end
end

for player in next, tfm.get.room.playerList do
	eventNewPlayer(player)
	if not room_owner then
		room_owner = player
	end
end
