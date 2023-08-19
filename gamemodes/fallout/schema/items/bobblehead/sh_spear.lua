ITEM.name = "Spear [DISABLED]"
ITEM.model = "models/weapons/w_harpooner.mdl"
ITEM.desc = "A set of 10 Spears | Good for hunting prey [ITEM HAS BEEN DISABLED BY DEV TEAM FOR BENCHMARKING]"

ITEM.functions.use = {
	name = "Use",
	tip = "useTip",
	icon = "icon16/pencil.png",
	onRun = function(item)
		local client = item.player
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + (client:GetAimVector() * 0)
			data.filter = client
		local trace = util.TraceLine(data)

		if (trace.HitPos) then
			local ent = ents.Create("")
			ent:SetPos(trace.HitPos + trace.HitNormal * 15)
			ent:Spawn()

            hook.Run("PlayerSpawnedSENT", client, ent)
		end;

		return true
	end,
}
