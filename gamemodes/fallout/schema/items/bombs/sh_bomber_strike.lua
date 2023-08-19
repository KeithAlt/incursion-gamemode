ITEM.name = "Bomber Strike"
ITEM.model = "models/maxib123/binoculars.mdl"
ITEM.desc = "A bomber strike that will signal a Bomberbot to devestate a straight path ahead | This item can only be deployed on active combatants"

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
