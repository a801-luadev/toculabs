# Import required modules
import datetime
import os
import re

# Reading the script
with open("init.lua", "r") as file:
	script = file.read()

# Evaluating tags (building the code)
for indent, _open, tag, close in re.findall(r"\n((?:\t| )*)(\{%\s*)(.+?)(\s*%\})", script):
	args = tag.split(" ")
	cmd = args.pop(0).lower()

	if cmd == "require":
		path = eval(" ".join(args))
		content = "--[[ File {} ]]--".format(path)
		with open(path, "r") as file:
			content += "\n" + file.read()
		content = re.sub(r"\n", "\n{}".format(indent), content)

		script = script.replace(_open + tag + close, content, 1)
	else:
		raise TypeError("Unknown tag in init.lua: {}".format(cmd))

# Trim spaces before newlines
script = re.sub(r"[\t ]+\n", "\n", script)

# Create directory if it does not exist.
now = datetime.datetime.utcnow()
month_year = now.strftime("%m-%Y")
if not os.path.isdir("builds"):
	os.mkdir("builds")
if not os.path.isdir("builds/" + month_year):
	os.mkdir("builds/" + month_year)

# Save built script
path = "builds/{}/{}".format(month_year, now.strftime("%d---%H-%M-%S"))
with open(path + ".lua", "w") as file:
	file.write(script)
with open("builds/latest.lua", "w") as file:
	file.write(script)