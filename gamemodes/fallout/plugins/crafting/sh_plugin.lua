nut.crafting = {}

PLUGIN.name = "Crafting 4.0"
PLUGIN.author = "Vex"
PLUGIN.desc = "A new and improved version of crafting, how cool."

nut.util.include("sv_plugin.lua")

if (CLIENT) then
	netstream.Hook("craftingUI", function(recipes)
		vgui.Create("nutCrafting"):open(recipes)
	end)
end;