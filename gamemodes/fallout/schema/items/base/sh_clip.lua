ITEM.name = "Clip Base"
ITEM.model = "models/Items/BoxSRounds.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.ammo = "pistol"
ITEM.rounds = 24

if (CLIENT) then
	function ITEM:paintOver(item, w, h)
		draw.SimpleText("Rounds: "..item.rounds, "DermaDefault", w , h - 5, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, color_black)
	end;
end;

ITEM.functions.use = {
	name = "Load",
	tip = "useTip",
	icon = "icon16/add.png",
	onRun = function(item)
		item.player:GiveAmmo(item.rounds, item.ammo)
		item.player:EmitSound("items/ammo_pickup.wav", 110)
		
		return true
	end,
}