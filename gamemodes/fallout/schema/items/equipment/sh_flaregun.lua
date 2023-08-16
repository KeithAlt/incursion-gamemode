ITEM.name = "Flare Gun"
ITEM.model = "models/halokiller38/fallout/weapons/misc/flaregun.mdl"
ITEM.desc = "A flare gun that can be used to display you position."

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
			local ent = ents.Create("weapon_vj_flaregun")
			ent:SetPos(trace.HitPos + trace.HitNormal * 10)
			ent:Spawn()

            hook.Run("PlayerSpawnedSENT", client, ent)
		end;

		return true
	end,
}
