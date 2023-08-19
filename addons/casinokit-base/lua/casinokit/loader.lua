CasinoKit = CasinoKit or {}

local function cl(file)
	if SERVER then AddCSLuaFile(file) end
	if CLIENT then
		return include(file)
	end
end
local function sv(file)
	if SERVER then
		return include(file)
	end
end
local function sh(file)
	return cl(file) or sv(file)
end

local function includeFiles(folder, acceptOnly)
	for _,fil in pairs(file.Find("casinokit/" .. folder .. "/*.lua", "LUA"), nil) do
		if fil:match("^sh_") and (not acceptOnly or acceptOnly == "sh") then sh(string.format("%s/%s", folder, fil)) end
		if fil:match("^cl_") and (not acceptOnly or acceptOnly == "cl") then cl(string.format("%s/%s", folder, fil)) end
		if fil:match("^sv_") and (not acceptOnly or acceptOnly == "sv") then sv(string.format("%s/%s", folder, fil)) end
	end
end

-- Libs
if SERVER then
	CasinoKit.metso = sv("_libs/metso.lua")
	sv("_libs/metso_setup.lua")
end
CasinoKit.tdui = cl("_libs/tdui.lua")
CasinoKit.middleclass = sh("_libs/middleclass.lua")

-- Main code
sh("util/oop.lua")
sh("util/mixins/events.lua")

cl("cl/util/bgworkshop.lua")
cl("cl/util/materialfetcher.lua")
cl("cl/util/soundfetcher.lua")

sv("custom/dealers.lua")
includeFiles("custom/dealers")
sh("custom/carddecks.lua")
includeFiles("custom/carddecks")
sh("custom/currencies.lua")
includeFiles("custom/currencies")
sh("custom/langs.lua")
includeFiles("custom/langs", "cl")

cl("admin/cl_ui.lua")
sv("admin/sv_config.lua")

sh("util/fn.lua")
sh("util/buffer.lua")
sh("util/timer.lua")
sv("util/rand.lua")

sh("game/card/suit.lua")
sh("game/card/rank.lua")
sh("game/card/card.lua")
sh("game/card/cardset.lua")
sv("game/card/deck.lua")
sh("game/card/handeval/handeval.lua")
sh("game/card/handeval/pokerhandeval.lua")

sv("economy/econ_backend.lua")
sv("economy/econ_admin.lua")
sh("economy/chip_ext.lua")
sv("economy/chip_xchange.lua")

sv("game/player.lua")
cl("game/player_cl.lua")
sv("game/game.lua")
cl("game/game_cl.lua")
sv("game/table.lua")

includeFiles("game/state")
includeFiles("game/impl")

sh("gmod/langprint.lua")
sv("gmod/persist.lua")
sh("gmod/persist_meta.lua")
sh("gmod/persist_prop.lua")
sh("gmod/downloads.lua")

cl("cl/util/nstable.lua")
cl("cl/chipmesh.lua")
cl("cl/dicemesh.lua")
cl("cl/tdui_skin.lua")
cl("cl/chipexchange.lua")
cl("cl/derma_skin.lua")

sv("tester.lua")
