ITEM.name = "Orbital Strike"
ITEM.model = "models/halokiller38/fallout/weapons/explosives/c4det.mdl"
ITEM.desc = "An Orbital Strike of unknown origin. The word 'MODUS' can be found inscribed on the side | This weapon can be used any where for any reason | This weapon can only be used once | If the user DIES mid-deployment, the strike will stop."

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
			local ent = ents.Create("weapon_rainfirerocket")
			ent:SetPos(trace.HitPos + trace.HitNormal * 10)
			ent:Spawn()

            hook.Run("PlayerSpawnedSENT", client, ent)
		end;

		return true
	end,
}
