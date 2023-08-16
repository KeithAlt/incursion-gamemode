if SERVER then
	-- The server preferred language
	CreateConVar("casinokit_svlanguage", "en", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY))
	return
end

-- Language registration functions
local langs = CasinoKit._languages or {}
CasinoKit._languages = {}

function CasinoKit.doesLanguageExist(lang)
	return not not langs[lang]
end
function CasinoKit.getAvailableLanguages()
	local langkeys = {}
	for k,_ in pairs(langs) do
		table.insert(langkeys, k)
	end
	return langkeys
end
function CasinoKit.getLanguageObject(lang)
	langs[lang] = langs[lang] or {}
	return langs[lang]
end

-- Language change listeners
local listeners = {}
function CasinoKit.addLanguageChangeListener(listener)
	table.insert(listeners, listener)
end

-- Convar stuff
local cvar_svlang = CreateConVar("casinokit_svlanguage", "en", bit.bor(FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE))
local cvar_cllang = CreateConVar("casinokit_language", "", bit.bor(FCVAR_ARCHIVE))

local activeLanguage, activeLanguageObj
function CasinoKit.getActiveLanguage()
	return activeLanguage
end
function CasinoKit.getActiveLanguageObject()
	return activeLanguageObj
end
function CasinoKit.updateActiveLanguage()
	local function setActiveLang(id)
		activeLanguage = id
		activeLanguageObj = CasinoKit.getLanguageObject(id)
	end

	local cllang = cvar_cllang:GetString()
	if cllang ~= "" and CasinoKit.doesLanguageExist(cllang) then
		setActiveLang(cllang)
		return
	end

	local svlang = cvar_svlang:GetString()
	if CasinoKit.doesLanguageExist(svlang) then
		setActiveLang(svlang)
		return
	end

	-- Things are bad; no languages specified in either of cvars exist. Fallback time!
	setActiveLang("en")
end
function CasinoKit.getFallbackLanguageObject()
	return langs.en
end

-- Set active language variables instantly
CasinoKit.updateActiveLanguage()
hook.Add("InitPostEntity", "CasinoKit_LoadActiveLanguage", CasinoKit.updateActiveLanguage)

local function cvarListener()
	local oldLanguage = CasinoKit.getActiveLanguage()
	CasinoKit.updateActiveLanguage()

	local newLanguage = CasinoKit.getActiveLanguage()
	if oldLanguage ~= newLanguage then
		for _,l in pairs(listeners) do
			l(oldLanguage, newLanguage)
		end
	end
end
cvars.AddChangeCallback("casinokit_svlanguage", cvarListener)
cvars.AddChangeCallback("casinokit_language", cvarListener)

-- Language translation functions
function CasinoKit.getLanguagePhrase(key, default)
	error("CALLING DEPRECATED getLanguagePhrase!!")
end

local function ParseLanguageKey(key, params)
	local cond, body, elseBody = key:match("if (.-) then '(.-)' else '(.-)'")
	if cond then
		local id, operand = cond:match("(%w+) != (%d)")
		if id and params[id] then
			if params[id] ~= tonumber(operand) then
				return body
			else
				return elseBody
			end
		end
	end

	return params[key] or string.format("[NOT SPECIFIED: %s]", key)
end

-- Translate a single language key
function CasinoKit.L(str, params)
	if params and type(params) ~= "table" then
		return "[INVALID PARAMS]"
	end

	local lang = CasinoKit.getActiveLanguageObject()

	local format = lang[str]

	-- Attempt to use fallback language if needed
	if not format then
		local fallbackLang = CasinoKit.getFallbackLanguageObject()
		format = fallbackLang and fallbackLang[str]
	end

	if format then
		params = params or {}
		return string.gsub(format, "{([^}]*)}", function(key)
			return ParseLanguageKey(key, params)
		end), nil -- ,nil because gsub returns number
	end

	return str
end

-- Translate phrase containing multiple language keys
function CasinoKit.ML(str, params)
	return string.gsub(str, "#([%a_]+)", function(key)
		return CasinoKit.L(key, params)
	end)
end