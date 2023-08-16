ITEM.name = "Cigarette"
ITEM.model = "models/llama/cig.mdl"
ITEM.desc = "A Big Boss pre-war quality cigarette"

ITEM.functions.use = {
	name = "Use",
	tip = "useTip",
	icon = "icon16/pencil.png",
	onRun = function(item)
		local client = item.player
		local data = {}
			data.filter = client
			if SERVER then
				client:Give("weapon_ciga")
				client:EmitSound("ui/loot_take" .. math.random(1,3) .. ".wav", 50)
			end
		return true
	end,
}
