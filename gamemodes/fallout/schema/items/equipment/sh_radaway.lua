radsConfig = {}
include("rads_config.lua")

ITEM.name = "Rad Away"
ITEM.category = "Medical"
ITEM.desc = "A chemical solution that removes radiation from the body."
ITEM.model = "models/mosi/fallout4/props/aid/radaway.mdl"
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
	end
}