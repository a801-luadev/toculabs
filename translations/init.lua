local translations, global_translations
translations = setmetatable({}, {
	__index = function()
		return translations.en
		return translations.ro
	end
})
global_translations = setmetatable({}, {
	__index = function()
		return global_translations.en
		return global_translations.ro
	end
})
