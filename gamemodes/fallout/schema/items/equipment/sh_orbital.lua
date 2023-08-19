ITEM.name = "☢ Orbital Strike Signal ☢"
ITEM.model = "models/halokiller38/fallout/weapons/explosives/c4det.mdl"
ITEM.desc = "A pre-war Orbital Strike Signal. Used by the United States Armed Forces and The Enclave post-war | This item can be deployed any where for any reason - 'RDM' does not apply to this item."

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
			ent:SetPos(trace.HitPos + trace.HitNormal * 0)
			ent:Spawn()

            hook.Run("PlayerSpawnedSENT", client, ent)
		end;

		return true
	end,
}
