ITEM.name = "Ore Crate"
ITEM.model = "models/zerochain/props_mining/zrms_gravelcrate.mdl"
ITEM.desc = "A box that can be used to store various Mined Ore."

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
			local ent = ents.Create("zrms_gravelcrate")
			ent:SetPos(trace.HitPos + trace.HitNormal * 10)
			ent:Spawn()

            hook.Run("PlayerSpawnedSENT", client, ent)
		end;

		return true
	end,
}