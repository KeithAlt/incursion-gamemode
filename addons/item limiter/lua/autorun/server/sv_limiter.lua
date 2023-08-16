MsgC(Color(255,255,0), "[ITEM LIMITER] ", Color(255,255,255), "Initalizing item limiter system\n")

limiter = limiter or {}

local function log(msg)
	MsgC(Color(255,255,0), "[ITEM LIMITER] ", Color(255,255,255), msg .. "\n")
end

local function shouldCleanup()
	local items = ents.FindByClass("nut_item")
	local seeds = ents.FindByClass("farm_seed")
	local amt = (#items + #seeds)

	if amt >= nut.config.get("itemLimit") then
		return true
	end

	return false
end

hook.Add("InitPostEntity", "ItemLimiterTimerCreator", function()
	timer.Create( "WorldItemCleaner", nut.config.get("limitTime"), 0, function()
		if shouldCleanup() and !limiter.active then
			log("Performing flash item removal due to meeting max allowed edicts")
			jlib.Announce(player.GetAll(), Color(255,0,0), "[WARNING] ", Color(255,155,155), "Dropped items will be deleted in: ", Color(255,0,0), "60 seconds")

			limiter.active = true

			timer.Simple(51, function()
				jlib.Announce(player.GetAll(), Color(255,0,0), "[WARNING] ", Color(255,155,155), "Dropped items will be deleted in: ", Color(255,0,0), "10 seconds")
			end)

			timer.Simple(61, function()
				jlib.Announce(player.GetAll(), Color(255,0,0), "[WARNING] ", Color(255,155,155), "Clearing world items . . .")
				local amt = (#ents.FindByClass("nut_item") + #ents.FindByClass("farm_seed"))

				for index, item in pairs(ents.FindByClass("nut_item")) do
					item:Remove()
				end

				for index, seed in pairs(ents.FindByClass("farm_seed")) do
					seed:Remove()
				end

				jlib.Announce(player.GetAll(), Color(0,255,0), "[NOTICE] ", Color(155,255,155), "Item cleanup complete: ", Color(0,255,0), amt .. " items ", Color(155,255,155), "removed")
				log("Performed item cleanup with a removal count of: " .. amt)
				limiter.active = false
			end)
		else
			log("Passed item limiter check with a result of: " .. (#ents.FindByClass("nut_item") + #ents.FindByClass("farm_seed")) .. " / " .. nut.config.get("itemLimit") .. " item edicts")
		end
	end)
end)
