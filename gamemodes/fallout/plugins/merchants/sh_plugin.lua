PLUGIN.name = "Merchants"
PLUGIN.author = "Vex"
PLUGIN.desc = "A plugin, why do we even need to fill this in anyway?"

nut.merchants = {}

nut.util.include("sv_plugin.lua")
nut.util.include("cl_plugin.lua")

nut.command.add("editinstance", {
	syntax = "",
	superAdminOnly = true,
	onRun = function(client, arguments)
		if (SERVER) then
			local entity = client:GetEyeTraceNoCursor().Entity

			if (entity) then
				if (entity:GetClass() == "nut_merchant") then
					local instance = nut.merchants.instances[entity:getNetVar("instance")] or false
					netstream.Start(client, "merchantInstanceUI", entity:getNetVar("instance"), instance, entity)
				else
					client:ChatPrint("That entity is not a merchant.")
				end;
			else
				client:ChatPrint("You are not looking at a valid entity.")
			end;
		end;
	end;
})

nut.command.add("managetemplates", {
	syntax = "",
	superAdminOnly = true,
	onRun = function(client, arguments)
		if (SERVER) then
			netstream.Start(client, "merchantTemplateUI", nut.merchants.templates)
		end;
	end;
})

function PLUGIN:LoadData()
	nut.merchants.templates = nut.data.get("merchants_templates", {}, false, true)
	nut.merchants.instances = nut.data.get("merchants_instances", {}, false, false)

	for i, v in pairs(nut.merchants.instances) do
		local merchant = ents.Create("nut_merchant")
			merchant:SetPos(v.pos)
			merchant:SetAngles(v.ang)
			merchant:Spawn()
			merchant:SetModel(v.model)

		merchant:setNetVar("instance", i)
	end;
end;
