# Youtube mode
 This is the youtube mode directory! Here is the source code of the `#toculabs0youtube` room.<br>
 In this mode you'll have a little interface where you can search videos on youtube.

# Structure
 The [backend.lua](modes/youtube/backend.lua) and [frontend.lua](modes/youtube/frontend.lua) files are used in every `youtube` room.<br>
 The [tunnel.lua](modes/youtube/tunnel.lua) file is used on a special room where [Tocutobot](bots/tocutobot) is, so it can answer requests.<br>
 This mode requires the [room-gateway](tech/room-gateway) script so the tunnel and other rooms can communicate, and each request goes to Tocutobot.