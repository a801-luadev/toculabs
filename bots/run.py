import asyncio
import importlib

bots = (
	"tocutobot",
)
for bot in bots:
	globals()[bot] = importlib.import_module(bot)

if __name__ == '__main__':
	loop = asyncio.get_event_loop()

	print("Setting up...")
	for bot in bots:
		globals()[bot].setup(loop)
	print("Starting...")
	for bot in bots:
		globals()[bot].start(loop)

	try:
		print("Running...")
		loop.run_forever()
	except KeyboardInterrupt:
		print(end="\r") # Removes ^C from the console
		print("Stopping bots...")
		for bot in bots:
			globals()[bot].stop(loop)
		loop.close()