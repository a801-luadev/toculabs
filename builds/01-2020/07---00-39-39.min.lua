luamin v1.0.4 - https://mths.be/luamin

Usage:

	luamin [-c | --code] [snippet ...]
	luamin [-f | --file] [file ...]
	luamin [-a | --ast] [AST ...]
	luamin [-v | --version]
	luamin [-h | --help]

Examples:

	luamin -c 'a = ((1 + 2) - 3) * (4 / (5 ^ 6))'
	luamin -f foo.lua
	echo 'a = "foo" .. "bar"' | luamin -c
	luaparse --scope 'a = 42' | luamin -a
