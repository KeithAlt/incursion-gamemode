ITEM.name = "Watering Can"
ITEM.model = "models/props_junk/metalgascan.mdl"
ITEM.desc = "A can filled with water for your crops."

ITEM.functions.Use = {
	onRun = function(item)
		local client = item.player
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + (client:GetAimVector() * 96)
			data.filter = client
		local trace = util.TraceLine(data)

		if (trace.HitPos) then
			local ent = ents.Create("farm_water")
			ent:SetPos(trace.HitPos + trace.HitNormal * 10)
			ent:Spawn()
		end

		return true
	end
}