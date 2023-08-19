local PLUGIN = PLUGIN

PLUGIN.name = "Animated Doors"
PLUGIN.author = "Vex"
PLUGIN.desc = "Super **SPECIAL** Doors!"

if (SERVER) then
	function PLUGIN:SaveData()
		--local data = {}

		--for _, v in pairs(ents.GetAll()) do
			--if (v:GetClass():match("anidoor")) then
				--table.insert(data, {v:GetClass(), v:GetPos(), v:GetAngles(), v:getNetVar("password", false)})
			--end;
		--end;

		--nut.data.set("anidoors", data)
	end;

	function PLUGIN:LoadData()
		--data = nut.data.get("anidoors")
		--if (!data) then return end;

		--for _, v in pairs(data) do
		--	local ent = ents.Create(v[1])
		--		ent:SetPos(v[2])
		--		ent:SetAngles(v[3])
		--		ent:Spawn()
		--		ent:setNetVar("password", v[4])

		--		local physObj = ent:GetPhysicsObject()

		--		if (IsValid(physObj)) then
		--			physObj:EnableMotion(false)
		--			physObj:Wake()
		--		end;
		--end;
	end;
end;

nut.command.add("pass", {
	syntax = "[string pass]",
	adminOnly = false,
	onRun = function(client, arguments)
		local entity = client:GetEyeTrace().Entity

		if (IsValid(entity) and entity:GetClass():match("anidoor")) then
			if entity:getNetVar("password") then
				client:falloutNotify("This door is already is password locked!", "ui/notify.mp3")
				return
			end
			entity:setNetVar("password", arguments[1])
			client:falloutNotify("Successfully added password to door: "  .. arguments[1], "ui/notify.mp3")
		else
			client:falloutNotify("You must be looking at a Door to apply a Password!", "ui/notify.mp3")
		end;
	end;
})

nut.command.add("key", {
	syntax = "[string pass] [string label]",
	adminOnly = false,
	onRun = function(client, arguments)
		local x, y, id = client:getChar():getInv():add("keycard", 1)

		if (id) then
			local item = client:getChar():getInv():getItemAt(x, y)
			item:setData("password", arguments[1])
			item:setData("label", arguments[2])
			client:falloutNotify("Keycard created with Password: "  .. arguments[1], "ui/notify.mp3")
		end;
	end;
})
