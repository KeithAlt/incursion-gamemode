Barber = Barber or {}
Barber.Config = Barber.Config or {}
Barber.Print = jlib.GetPrintFunction("[Barber]")

AddCSLuaFile("barber_config.lua")
include("barber_config.lua")

Barber.Config.Chairs = jlib.Lookupify(Barber.Config.Chairs)
Barber.Config.HatTypes = jlib.Lookupify(Barber.Config.HatTypes)
for k, v in pairs(Barber.Config.VIPHairs) do Barber.Config.VIPHairs[k] = jlib.Lookupify(v) end
for k, v in pairs(Barber.Config.VIPBeards) do Barber.Config.VIPBeards[k] = jlib.Lookupify(v) end

local HAIR_GROUP = 2
local BEARD_GROUP = 3

-- VIP hairs permission
hook.Add("PostGamemodeLoaded", "PayPalSearch", function()
	Barber.Print("Adding VIP hairs permission")
	serverguard.permission:Add("VIP Hairs")
end)

function Barber.CanUseHair(group, hair, ply, sex)
	local vipTable
	sex = sex or ply:GetSex()

	if group == HAIR_GROUP then
		vipTable = Barber.Config.VIPHairs[sex]
	elseif group == BEARD_GROUP then
		vipTable = Barber.Config.VIPBeards[sex]
	end

	if vipTable and vipTable[hair] then
		return serverguard.player:HasPermission(ply, "VIP Hairs")
	end

	return true
end

function Barber.GetAllowedCuts(ply, group, count, sex)
	local allowedCuts = {}
	for i = 0, count - 1 do
		if Barber.CanUseHair(group, i, ply, sex) then
			table.insert(allowedCuts, i)
		end
	end

	return allowedCuts
end

-- Some checking functions
function Barber.IsBarberChair(ent)
	return IsValid(ent) and ent:IsVehicle() and Barber.Config.Chairs[ent:GetModel()]
end

function Barber.CanColorHead(ply)
	return ply:GetSex() != "ghoul"
end

-- Getters/setters
local PLAYER = FindMetaTable("Player")

function PLAYER:SetBarber(barber)
	self:SetNW2Entity("barber", barber)
end

function PLAYER:GetBarber()
	return self:GetNW2Entity("barber", NULL)
end

function PLAYER:SetHaircutCustomer(customer)
	self:SetNW2Entity("haircutCustomer", customer)
end

function PLAYER:GetHaircutCustomer()
	return self:GetNW2Entity("haircutCustomer", NULL)
end
