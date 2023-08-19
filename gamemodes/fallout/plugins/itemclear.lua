// This is a tad bit gross, should be rewritten later, by Keith
PLUGIN.name = "Item Clear"
PLUGIN.author = "Vex"
PLUGIN.desc = "It does shit, STOP ASKING SO MANY QUESTIONS!"

local resetTime = (60 * 60) -- 1 Hour
local MapCleanupTime = (60 * 360) -- 6 Hours

local function ChatNotify(ply, string)
	jlib.Announce(ply, Color(255,0,0), "[WARNING] ", Color(255,155,155), string)
end

if (SERVER) then -- Quick and dirty, but it works.
	function PLUGIN:InitializedPlugins()
		timer.Create("clearWorldItemsWarning", resetTime - (60 * 10), 0, function() -- WORLD ITEMS CLEANUP
				ChatNotify(player.GetAll(),
					"World items will be cleared in 10 minutes!", Color(255,255,255),
					"\n● Cleared items will not be refunded if removed"
				)
		end)

		timer.Create("mapCleanupWarning", MapCleanupTime - (60 * 10), 0, function()  -- MAP CLEANUP
			ChatNotify(player.GetAll(),
				"Automatic map cleanup in 10 minutes!", Color(255,255,255),
				"\n● Cleared items/vehicles will not be refunded if removed"
			)
		end)

		timer.Create("clearWorldItemsWarningFinal", resetTime - 60, 0, function() -- WORLD ITEMS CLEANUP
			ChatNotify(player.GetAll(),
				"World items will be cleared in 60 seconds!", Color(255,255,255),
				"\n● Cleared items will not be refunded if removed"
			)

			timer.Simple(50, function()
				ChatNotify(player.GetAll(),
					"World items will be cleared in 10 seconds!", Color(255,255,255),
					"\n● Cleared items will not be refunded if removed"
				)
			end)
		end)

		timer.Create("mapCleanupWarningFinal", MapCleanupTime -  60, 0, function() -- MAP CLEANUP
			ChatNotify(player.GetAll(),
				"Automatic map cleanup in 60 seconds!", Color(255,255,255),
				"\n● Cleared items/vehicles will not be refunded if removed"
			)

			timer.Simple(50, function()
				ChatNotify(player.GetAll(),
					"Automatic map cleanup in 10 seconds!", Color(255,255,255),
					"\n● Cleared items/vehicles will not be refunded if removed"
				)
			end)
		end)

		timer.Create("clearWorldItems", resetTime, 0, function() -- WORLD ITEMS CLEANUP
			local amt = (#ents.FindByClass("nut_item") + #ents.FindByClass("farm_seed"))

			for index, item in pairs(ents.FindByClass("nut_item")) do
				item:Remove()
			end

			for index, seed in pairs(ents.FindByClass("farm_seed")) do
				seed:Remove()
			end

			jlib.Announce(player.GetAll(), Color(0,255,0), "[NOTICE] ", Color(155,255,155), "Item cleanup complete: ", Color(0,255,0), amt .. " items ", Color(155,255,155), "removed")
		end)

		timer.Create("AutomaticMapCleanup", MapCleanupTime, 0, function()  -- MAP CLEANUP
			jlib.Announce(player.GetAll(), Color(255,0,0), "[WARNING] ", Color(255,155,155), "Map cleanup inbound; brace for impact!")

			RunConsoleCommand("gmod_admin_cleanup")

			timer.Simple(1, function()
				jlib.Announce(player.GetAll(), Color(0,255,0), "[NOTICE] ", Color(155,255,155), "Map cleanup complete")
			end)
		end)
	end
end
