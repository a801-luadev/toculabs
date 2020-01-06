try:
	# Try relative imports...
	from .forum import ForumClient
	from .tfm import TfmClient
except ImportError: # ... and if they do not work, make absolute ones
	from forum import ForumClient
	from tfm import TfmClient
import asyncio
import os

if __name__ == '__main__':
	api_id = os.getenv("TRANSFROMAGE_ID")
	api_token = os.getenv("TRANSFROMAGE_TOKEN")
	if api_id is None or not api_id.isdigit():
		raise TypeError("TRANSFROMAGE_ID environment variable must exist and be a number.")
	if api_token is None:
		raise TypeError("TRANSFROMAGE_TOKEN environment variable must exist.")

	tfm_name = os.getenv("TRANSFORMICE_BOT_NAME")
	tfm_pass = os.getenv("TRANSFORMICE_BOT_PASS")
	if tfm_name is None:
		raise TypeError("TRANSFORMICE_BOT_NAME environment variable must exist.")
	if tfm_pass is None:
		raise TypeError("TRANSFORMICE_BOT_PASS environment variable must exist.")

	atelier_name = os.getenv("ATELIER_BOT_NAME")
	atelier_pass = os.getenv("ATELIER_BOT_PASS")
	atelier_host_list = os.getenv("ATELIER_IMAGE_HOST_LIST")
	atelier_host_ajax = os.getenv("ATELIER_IMAGE_HOST_AJAX")
	if atelier_name is None:
		raise TypeError("ATELIER_BOT_NAME environment variable must exist.")
	if atelier_pass is None:
		raise TypeError("ATELIER_BOT_PASS environment variable must exist.")
	if atelier_host_list is None:
		raise TypeError("ATELIER_IMAGE_HOST_LIST environment variable must exist.")
	if atelier_host_ajax is None:
		raise TypeError("ATELIER_IMAGE_HOST_AJAX environment variable must exist.")

	loop = asyncio.get_event_loop()

	forum = ForumClient(atelier_name, atelier_pass, atelier_host_list, atelier_host_ajax, loop=loop)
	tfm = TfmClient(api_id, api_token, tfm_name, tfm_pass, forum, loop=loop)

	loop.run_until_complete(tfm.start_running())
	try:
		loop.run_forever()
	except KeyboardInterrupt:
		print(end="\r") # Removes ^C from the console
		print("Stopping bots...")
		loop.run_until_complete(tfm.stop())
		loop.close()