ITEM.name = "Bomber Airstrike Signal"
ITEM.model = "models/maxib123/binoculars.mdl"
ITEM.desc = "A signal strike that will call upon a B-29 Bomber to lay waste to your foes | This weapon can only be deployed during a raid or hostilities | This weapon can only be used once"

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
			local ent = ents.Create("m9k_planestrike")
			ent:SetPos(trace.HitPos + trace.HitNormal * 10)
			ent:Spawn()

            hook.Run("PlayerSpawnedSENT", client, ent)
		end;

		return true
	end,
}
