/* When we network new zones created on the server, need to network id as separate value of new zone as well. */
netstream.Hook("RequestCaptureZones", function(ply)
	if ply.HasInitialized then return end
	local plugin = nut.plugin.list["capture_zones"]

	local zones = {}
	for k,v in next, plugin.ActiveZones do
		zones[k] = {
			pos = v:GetPosition(),
			radius = v:GetRadius(),
			faction = v:GetFaction(),
		}
	end

	netstream.Start(ply, "ReceiveZones", zones)
	ply.HasInitialized = true
end)

function PLUGIN:SaveZones()
	local data = {}
	for k,v in next, self.ActiveZones do
		local spawns = {}
		for m,n in next, v:GetSpawns() do
			spawns[#spawns + 1] = {
				pos = n:GetPos()
			}
		end

		data[k] = {
			pos = v:GetPosition(),
			radius = v:GetRadius(),
			spawns = spawns,
			budget = v.DefaultBudget,
			max = v.MaxNPCs,
		}
	end

	self:setData(data)
end

function PLUGIN:LoadZones()
	local data = self:getData({})
	for k,v in next, data do
		local zone = self:CreateNewZone(v.pos, v.radius)
		zone.DefaultBudget = v.budget
		zone.MaxNPCs = v.max

		for m,n in next, v.spawns do
			local entity = ents.Create("zone_spawner")
			entity:SetPos(n.pos)
			entity:SetAngles(Angle(0,0,0))
			entity:Spawn()
		end
	end
	return data
end

function PLUGIN:OnLoaded()
	if #self.ActiveZones > 0 then return end

	self:LoadZones()
end

function PLUGIN:ShutDown()
	self:SaveZones()
end

function PLUGIN:GetSalaryAmount(ply, faction)
	local pay = faction.pay
	for k,v in next, self.ActiveZones do
		if v:GetFaction() and v:GetFaction() == faction.uniqueID then
			pay = pay * math.Round(nut.config.get("capture_zone_payment", 1), 1)
		end
	end

	return pay
end

-- DrVrej is an annoying little shit, and his code is terrible.
net.Receivers["VJSay"] = function() end
hook.Remove("PlayerInitialSpawn", "VJBaseSpawn")