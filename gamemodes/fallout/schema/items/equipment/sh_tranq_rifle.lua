ITEM.name = "Tranquilizer Rifle"
ITEM.model = "models/weapons/v_winchester1873.mdl"
ITEM.desc = "A hand-made Tranquilizer Rifle | Good for capturing rogue slaves"

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
			local ent = ents.Create("weapon_tranqrifle")
			ent:SetPos(trace.HitPos + trace.HitNormal * 15)
			ent:Spawn()

            hook.Run("PlayerSpawnedSENT", client, ent)
		end;

		return true
	end,
}
