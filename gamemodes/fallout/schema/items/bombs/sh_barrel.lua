ITEM.name = "Explosive Barrel"
ITEM.model = "models/props_c17/oildrum001_explosive.mdl"
ITEM.desc = "A barrel full of gun powder - can be damaged to explode."

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
			local ent = ents.Create("prop_physics")
			ent:SetModel("models/props_c17/oildrum001_explosive.mdl")
			ent:SetPos(trace.HitPos + trace.HitNormal * 10)
			ent:Spawn()
			ent:Activate()

            hook.Run("PlayerSpawnedSENT", client, ent)
		end;

		return true
	end,
}
