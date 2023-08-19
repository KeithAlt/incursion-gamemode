radsConfig = {}
include("rads_config.lua")

ITEM.name = "Rad-X"
ITEM.category = "Medical"
ITEM.desc = "Pills that make the user temporarily immune to radiation."
ITEM.model = "models/mosi/fallout4/props/aid/radx.mdl"
ITEM.price = radsConfig.radXPrice
ITEM.functions.Use = {
	onRun = function(item) //Only ran server-side
        //make the user temporarily immune to rads
        local ply = item.player
		if !ply.isImmune then
            ply.isImmune = true
            timer.Create("immuneTimer" .. ply:SteamID64(), radsConfig.radXImmuneTime, 1, function() //Make them no longer immune after 2 minutes
                ply.isImmune = false
				net.Start("radzones_updateImmune")
					net.WriteBool(ply.isImmune)
				net.Send(ply)
            end)
            nut.util.notify("You are now immune to all radiation for " .. radsConfig.radXImmuneTime .. " seconds.", ply)
        else //they're already immune
            nut.util.notify("You are still immune to radiation for another " .. math.ceil(timer.TimeLeft("immuneTimer" .. ply:SteamID64())) .. " seconds.", ply)
            return false
        end

		//Update client
		net.Start("radzones_updateImmune")
			net.WriteBool(ply.isImmune)
		net.Send(ply)
	end
}