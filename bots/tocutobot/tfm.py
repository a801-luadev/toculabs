import re
import aiotfm
import aiohttp
import asyncio
import urllib.parse
from bs4 import BeautifulSoup

def sanitize(string):
	return string.replace("&", "&0").replace("#", "&1")

class TfmClient(aiotfm.Client):
	def __init__(self, api_id, api_token, name, password, forum, *args, **kwargs):
		super().__init__(*args, **kwargs)

		self.api_id = api_id
		self.api_token = api_token
		self.name = name
		self.password = password
		self.forum = forum

		self.searching_task = None
		self.session = None
		self.listening = False

	async def start_running(self):
		self.session = aiohttp.ClientSession()

		await self.forum.start()
		await self.start(self.api_id, self.api_token)

	async def on_login_ready(self, online_players, community, country):
		print("Connected to Transformice. There are {} online players at the moment.".format(online_players))
		print("Logging in.")
		await self.login(self.name, self.password, encrypted=False, room="*#TocuLabs village")

	async def on_logged(self, id, username, played_time, community, pid):
		print("Logged in. Waiting to connect to the community platform.")

	async def on_ready(self):
		print("Connected to the community platform. Waiting 5 seconds to go to the tribehouse.")
		await asyncio.sleep(5.0)
		await self.enterTribe()

	async def on_login_result(self, *args):
		print(args)
		print("Could not connect to the game.")
		await self.stop()
		self.loop.stop()

	async def on_joined_room(self, room):
		if room.name[1] == "\x03":
			print("Joined the tribehouse. Loading the module.")
			await self.sendCommand("module toculabs")

	async def handle_packet(self, conn, packet):
		handled = await super().handle_packet(conn, packet)
		if handled:
			return True

		packet.pos = 0
		CCC = packet.readCode()

		if CCC == (6, 9): # tfm.exec.chatMessage
			msg = packet.readString()
			print("[Lua]", msg)

			if msg == b"loaded v2":
				print("Loaded the module. Listening for Lua input.")
				self.listening = True

		elif CCC == (29, 20): # ui.addTextArea
			id = packet.read32()
			if id == 1: # Break
				if self.searching_task is not None:
					self.searching_task.cancel()
				return

			query = packet.readUTF()[1:] # [1:] so the first character (?) is removed.
			print("Received query:", query)
			asyncio.ensure_future(self.search_wrapper(query))

		else:
			return False

		return True

	async def search_wrapper(self, query):
		self.searching_task = asyncio.Task(self.search(query))
		try:
			await self.searching_task
		except asyncio.CancelledError:
			print("Cancelled search.")

	async def search(self, query):
		async with self.session.get(
			"https://www.youtube.com/results?search_query={}".format(
				urllib.parse.quote(query, safe="/ ").replace(" ", "+")
			),
			headers={"User-Agent": "Mozilla/5.0"}
		) as response:
			soup = BeautifulSoup(await response.text(), "lxml")

		saved_ids, to_send = [], []
		for li in soup.find_all("li", class_=lambda css_class: css_class is None):
			await asyncio.sleep(0)
			thumbnail = li.find("img")
			title = li.find("a", title=True)
			channel = li.find("a", href=re.compile(r"^\/channel\/"))
			description = li.find("div", class_="yt-lockup-description")

			if thumbnail is None or title is None or channel is None or description is None:
				continue

			thumbnail = thumbnail["src"]
			title = title.string
			channel = channel.string
			description = "".join(description.strings)

			id = re.search(r"i\.ytimg\.com\/vi\/([^/]+)\/", thumbnail)
			if id is None:
				continue

			id = id.group(1)
			if id in saved_ids:
				continue
			else:
				saved_ids.append(id)

			to_send.extend([
				sanitize(id),
				sanitize(title),
				sanitize(channel),
				sanitize(description)
			])
			if len(saved_ids) >= 3:
				break

		await self.bulle.send(
			aiotfm.Packet.new(29, 21)
			.write32(0)
			.writeString("#".join(to_send) + "#")
		)

		for id in saved_ids:
			async with self.session.get((
				"https://{}.cloudimg.io/v7/"
				"i.ytimg.com/vi/{}/hqdefault.jpg"
				"?func=cover&width={}&height={}"
			).format("aofyzepepo", id, 82, 65)) as response:
				try:
					image_code = await self.forum.upload(id, "jpg", "image/jpeg", await response.read())
				except (EOFError, TypeError):
					return await self.bulle.send(
						aiotfm.Packet.new(29, 21)
						.write32(0)
						.writeString("BREAK")
					)
				await self.bulle.send(
					aiotfm.Packet.new(29, 21)
					.write32(0)
					.writeString(image_code)
				)

		await self.bulle.send(
			aiotfm.Packet.new(29, 21)
			.write32(0)
			.writeString("BREAK")
		)

	async def stop(self):
		self.main.close()
		if self.bulle is not None:
			self.bulle.close()
		await self.session.close()
		await self.forum.stop()