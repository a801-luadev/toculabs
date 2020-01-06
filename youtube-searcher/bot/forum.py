import re
import time
import aiotfm
import aiohttp
import asyncio
try:
	import ujson as json
except ImportError:
	import json

prefix = "https://atelier801.com/"
user_agent = (
	"Mozilla/5.0 (Windows NT6.1) "
	"AppleWebKit/537.36 (KHTML, like Gecko) "
	"Chrome/63.0.3440.106 "
	"Safari/537.36"
)

class ForumClient:
	def __init__(self, name, password, host_list, host_ajax, loop=None):
		self.loop = loop or asyncio.get_event_loop()

		self.name = name
		self.password = password
		self.host_list = host_list
		self.host_ajax = host_ajax

		self.session = None
		self.logged = False

	async def start(self):
		self.session = aiohttp.ClientSession()
		await self.login()

	async def login(self):
		if self.logged:
			return True

		body = await self.post_page(
			"identification",
			referer="login",
			other_data={
				"rester_connecte": "on",
				"id": self.name,
				"pass": aiotfm.utils.shakikoo(self.password).decode(),
				"redirect": prefix
			}
		)
		body = json.loads(body)
		if body["supprime"] == "*":
			return True
		return False

	async def disconnect(self):
		self.logged = False
		await self.session.close()
		self.session = aiohttp.ClientSession()

	async def stop(self):
		await self.disconnect()

	async def get_keys(self, where):
		async with self.session.get(
			prefix + where,
			headers={"User-Agent": user_agent}
		) as response:
			match = re.search(r'<input type="hidden" name="(.+?)" value="(.+?)">', await response.text())
			if match is None:
				return
			return match.group(1, 2)

	async def post_page(self, page, *, referer, file=None, other_data={}, do_reset=True):
		keys = await self.get_keys(referer)
		if keys is None:
			if do_reset:
				await self.disconnect()
				if not await self.login():
					return
				return await self.post_page(page, referer=referer, file=file, other_data=other_data, do_reset=False)
			return

		headers = {
			"User-Agent": user_agent,
			"Accept": "application/json, text/javascript, */*; q=0.01",
			"Accept-Language": "en-US,en;q=0.9",
			"X-Requested-With": "XMLHttpRequest",
			"Referer": prefix + referer
		}

		data = aiohttp.FormData()
		if file is not None:
			data.add_field(
				"fichier",
				file["content"],
				filename=f"TocuLabs_YouTube_{file['name']}_{int(time.time() * 1000)}.{file['extension']}",
				content_type=file["content_type"]
			)
		for key, value in other_data.items():
			data.add_field(key, value)
		data.add_field(*keys)

		async with self.session.post(
			prefix + page,
			headers=headers,
			data=data
		) as resp:
			return await resp.text()

	async def get_page(self, page):
		async with self.session.get(
			prefix + page,
			headers={"User-Agent": user_agent}
		) as resp:
			return await resp.text()

	async def upload(self, name, extension, content_type, content, get_link=True):
		referer = self.host_list + self.name.replace("#", "%23")
		result = await self.post_page(
			self.host_ajax,
			referer=referer,
			file=dict(
				name=name,
				extension=extension,
				content_type=content_type,
				content=content
			)
		)
		if not result:
			raise EOFError

		if not get_link:
			return

		content = await self.get_page(referer)

		match = re.search(
			r"<td>TocuLabs_YouTube_" + re.escape(name) + r"_\d+\.{}<\/td>\s*<td>([a-z0-9]+\.{})<\/td>".format(extension, extension),
			content
		)
		if match is None:
			raise TypeError
		return match.group(1)