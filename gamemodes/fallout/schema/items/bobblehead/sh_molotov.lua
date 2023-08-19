ITEM.name = "Firebomb"
ITEM.model = "models/weapons/tfa_nmrih/w_exp_molotov.mdl"
ITEM.desc = "A hand-made fire bomb."

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
			local ent = ents.Create("weapon_nmrih_molotov")
			ent:SetPos(trace.HitPos + trace.HitNormal * 15)
			ent:Spawn()

            hook.Run("PlayerSpawnedSENT", client, ent)
		end;

		return true
	end,
}
