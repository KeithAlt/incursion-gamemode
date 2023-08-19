PLUGIN.name = "Looter 4"
PLUGIN.author = "Vex"
PLUGIN.desc = "An advanced dynamic world loot system based off the Fallout series."

nut.looter = nut.looter or {}

nut.util.include("sv_plugin.lua")
nut.util.include("cl_plugin.lua")
nut.util.include("sv_tables.lua")

nut.command.add("lootcontainer", {
	superAdminOnly = true,
	syntax = "[string model]",
	onRun = function(client, arguments)
		if (!arguments[1]) then
			client:ChatPrint("You must provide a model!")
			return false
		elseif(!util.IsValidModel(arguments[1])) then
			client:ChatPrint(arguments[1].." is not a valid model!")
			return false
		end;

		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + (client:GetAimVector() * 96)
			data.filter = client
		local trace = util.TraceLine(data)

		if (trace.HitPos) then
			local ent = ents.Create("nut_loot_container_dynamic")
				ent:SetPos(trace.HitPos + trace.HitNormal * 10)
				ent:Spawn()
				ent:SetModel(arguments[1])
				ent:SetSolid(SOLID_VPHYSICS)
				ent:PhysicsInit(SOLID_VPHYSICS)

				local physObj = ent:GetPhysicsObject()

				if (IsValid(physObj)) then
					physObj:Wake()
					physObj:EnableMotion(false)
				end;
			end;
	end
})
