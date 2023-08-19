radsConfig = {}
include("rads_config.lua")

ITEM.name = "Cleansing Powder"
ITEM.category = "Medical"
ITEM.desc = "A powdered solution created and used by Caesar's Legion to remove radiation damage."
ITEM.model = "models/fallout/healingpowder.mdl"
ITEM.price = radsConfig.radAwayPrice
ITEM.functions.Use = {
	onRun = function(item) //Only ran server-side
        //increase the players max health up to a maximum of what it initally was before the radiation was taken

        local ply = item.player
        //If they don't have any rads notify then and don't use the item
        if !ply.rads or ply.rads <= 0 then
            nut.util.notify("You don't have any rads.", ply)
            return false
        end

        //If they have some rads remove some of their rads and increase their max health
        ply.rads = ply.rads - radsConfig.restoreAmount
        if ply.rads < 0 then ply.rads = 0 end //minimum of 0 so we dont end up giving them more max hp
        ply:SetMaxHealth(ply.originalMaxHealth - ply.rads)

        nut.util.notify("You now have " .. ply.rads .. " rads.", ply)

		//Update the client
		net.Start("radzones_updateRads")
	        net.WriteInt(ply.rads, 16)
	    net.Send(ply)

		if !ply.isImmune then
            ply.isImmune = true
            timer.Create("immuneTimer" .. ply:SteamID64(), 30, 1, function() //Make them no longer immune after 2 minutes
                ply.isImmune = false
            end)
            nut.util.notify("You are now immune to all radiation for 30 seconds.", ply)
        else //they're already immune
            nut.util.notify("You are still immune to radiation for another " .. math.ceil(timer.TimeLeft("immuneTimer" .. ply:SteamID64())) .. " seconds.", ply)
            return false
        end
	end
}
