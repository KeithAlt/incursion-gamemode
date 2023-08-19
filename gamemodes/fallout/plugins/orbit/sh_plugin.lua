PLUGIN.name = "Orbital Drop"
PLUGIN.author = "Vex"
PLUGIN.desc = "Orbital resource drops."

if SERVER then
	util.AddNetworkString("OrbitsSend")
end

local drops
drops = drops or {}

nut.command.add("orbitdrop", {
	superAdminOnly = true,
	syntax = "[none]",
	onRun = function(client, arguments)
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + (client:GetAimVector() * 96)
			data.filter = client
		local trace = util.TraceLine(data)

		drops[#drops + 1] = trace.HitPos

		client:ChatPrint("Drop location added!")
	end
})

nut.command.add("orbitshow", {
	superAdminOnly = true,
	syntax = "[none]",
	onRun = function(client, arguments)
		net.Start("OrbitsSend")
			net.WriteTable(drops)
		net.Send(client)

		client:SetNWBool("orbitsshown", !client:GetNWBool("orbitsshown", false))
	end
})

nut.command.add("orbitremove", {
	superAdminOnly = true,
	syntax = "[none]",
	onRun = function(client, arguments)
		local bestDist
		local bestDrop
		for k,pos in pairs(drops) do
			local dist = client:GetPos():DistToSqr(pos)
			if !bestDist or dist < bestDist then
				bestDist = bestDist
				bestDrop = k
			end
		end

		if !bestDrop then
			client:ChatPrint("No drop points found.")
		end

		table.remove(drops, bestDrop)

		net.Start("OrbitsSend")
			net.WriteTable(drops)
		net.Send(client)

		client:ChatPrint("Removed nearest orbital drop point.")
	end
})

if CLIENT then
	net.Receive("OrbitsSend", function(len, ply)
		drops = net.ReadTable()
	end)

	hook.Add("HUDPaint", "DrawOrbitPos", function()
		if !LocalPlayer():GetNWBool("orbitsshown", false) then return end

		cam.Start3D()
			for _,pos in pairs(drops) do
				render.SetColorMaterial()
				render.DrawSphere(Vector(pos.x, pos.y, pos.z - 12.5), 25, 50, 50, Color(0, 255, 255, 150))
			end
		cam.End3D()
	end)
end

if (SERVER) then
	function PLUGIN:SaveData()
		self:setData(drops)
	end;

	function PLUGIN:LoadData()
		drops = self:getData()
	end;

	function PLUGIN:InitializedPlugins()
		local rarities = {
			{"common", 24},
			{"uncommon", 15},
			{"rare", 19},
			{"epic", 21},
			{"exotic", 5},
			{"legendary", 2.45},
			{"mythic", 0.5},
			{"cosmic", 0.05},
			{"orbital", 13} -- Unique item table that only is available via orbital drops
		}

		nut.loot.registerTable("orbit", rarities, nut.loot.tables.master.items)

		timer.Create("OrbitDropTimer", 60 * 60, 0, function()
			if #drops == 0 then return end

			local drop = ents.Create("nut_orbit_beacon")
				drop:SetPos(table.Random(drops))
				drop:Spawn()

			for i, v in pairs(player.GetAll()) do
				v:falloutNotify("☢ An Orbital Drop is Inbound - 5 Minutes ☢", "fallout/orbit/standby.wav")
			end;
		end)
	end;
end;
