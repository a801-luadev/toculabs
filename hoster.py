import os
import aiotfm
import asyncio

HOST_MINIFIED = False

class Bot(aiotfm.Client):
	def __init__(self, api_id, api_token, name, password, cmd, module_name, *args, **kwargs):
		super().__init__(*args, **kwargs)

		self.api_id = api_id
		self.api_token = api_token
		self.name = name
		self.password = password
		self.cmd = cmd + " " + module_name
		self.init_room = "*#" + module_name

	async def start_running(self):
		await self.start(self.api_id, self.api_token)
		await self.wait_for("on_login_ready", timeout=10.0)

		await self.login(self.name, self.password, encrypted=False, room=self.init_room)
		await self.wait_for("on_logged", timeout=10.0)
		print("Logged in.")

		await self.wait_for("on_joined_room", timeout=10.0)
		print("Joined the room.")
		await asyncio.sleep(3.0)

	async def host(self):
		print("Hosting the module.")
		path = "builds/latest{}.lua".format(HOST_MINIFIED and ".min" or "")

		with open(path, "rb") as file:
			script = file.read()
		with open("builds/hosted.lua", "wb") as file:
			file.write(script)
		await self.loadLua(script)
		await self.wait_for("on_lua_log", lambda msg: "Lua script loaded in" in msg, timeout=10.0)
		print("Loaded the script.")

		await self.sendCommand(self.cmd)
		print("Hosted the module.")

if __name__ == '__main__':
	api_id = os.getenv("TRANSFROMAGE_ID")
	api_token = os.getenv("TRANSFROMAGE_TOKEN")
	if api_id is None or not api_id.isdigit():
		raise TypeError("TRANSFROMAGE_ID environment variable must exist and be a number.")
	if api_token is None:
		raise TypeError("TRANSFROMAGE_TOKEN environment variable must exist.")

	name = os.getenv("ATELIER_BOT_NAME")
	password = os.getenv("ATELIER_BOT_PASS")
	if name is None:
		raise TypeError("ATELIER_BOT_NAME environment variable must exist.")
	if password is None:
		raise TypeError("ATELIER_BOT_PASS environment variable must exist.")

	host_cmd = os.getenv("HOST_COMMAND")
	module_name = os.getenv("MODULE_NAME")
	if host_cmd is None:
		raise TypeError("HOST_COMMAND environment variable must exist.")
	if password is None:
		raise TypeError("MODULE_NAME environment variable must exist.")

	loop = asyncio.get_event_loop()
	bot = Bot(api_id, api_token, name, password, host_cmd, module_name, loop=loop)
	loop.run_until_complete(bot.start_running())
	loop.run_until_complete(bot.host())
	bot.close()