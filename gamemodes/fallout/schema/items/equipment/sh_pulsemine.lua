ITEM.name = "Cryo Mine Box"
ITEM.model = "models/Items/item_item_crate.mdl"
ITEM.desc = "A box of Cryo Mines containing 3 Mines."

ITEM.functions.use = {
	name = "Use",
	tip = "useTip",
	icon = "icon16/pencil.png",
	onRun = function(item)
		local client = item.player
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + (client:GetAimVector() * 96)
			data.filter = client
		local trace = util.TraceLine(data)

		if (trace.HitPos) then
			local ent = ents.Create("cgc_cryomine")
			ent:SetPos(trace.HitPos + trace.HitNormal * 10)
			ent:Spawn()

      hook.Run("PlayerSpawnedSENT", client, ent)
		end;

		return true
	end,
}
