ITEM.name = "Transform Base"
ITEM.desc = ""
ITEM.model = "models/props_c17/lampShade001a.mdl"
ITEM.width = 1
ITEM.height = 1

--[[
ITEM.npc = "classname" --put the npc you want the item to transform them into here
ITEM.tscale = 1 --player scale by the end of the transformation before they get replaced by the thing
ITEM.duration = 5 --how many seconds the transformation takes
ITEM.tcolor = Color(255,255,255) --changes the color of the player to this during transformation
ITEM.tmaterial = "" --changes material to this during transformation
ITEM.sound = "" --plays a sound
--]]

ITEM.functions._use = { 
	name = "Use",
	tip = "useTip",
	icon = "icon16/book.png",
	onRun = function(item)
		local client = item.player
		local char = client:getChar()
		if(char and client:Alive()) then
			nut.plugin.list["transform"]:transformStart(client, item)
		end
	end,
	onCanRun = function(item) 
		return (!IsValid(item.entity)) --this means you have to have it in your inventory to use it
	end
}

function ITEM:preTransform(client)

end

function ITEM:postTransform(client)
	
end