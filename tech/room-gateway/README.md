# Room gateway script
 This is the room gateway directory! This script is used for a basic, fluid, efficient and fast communication between two rooms.<br>

# When to use
 The usage of this script is pretty clear:<br>
 Imagine you want to connect a bot to all the rooms in a module. To do so, you'd need too many bots without this script, and using a lot more of resources to do so.<br>
 With this script, all you need is just make a single bot and host a single room (called syncing/tunnel room). Instead of sending a bot to every room, you send a message from and to every room to this room, where the message will be forwarded to the bot (and back, if you keep the connection alive by using heartbeats).

# Examples
 There is an example in the [youtube mode](modes/youtube), which communicates with [Tocutobot](bots/tocutobot).