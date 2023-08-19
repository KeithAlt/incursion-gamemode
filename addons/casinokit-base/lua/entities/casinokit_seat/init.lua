AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model = "models/props_c17/chair_stool01a.mdl"
ENT.SeatLPos = Vector(0, -2, 33)
ENT.SeatLAng = Angle(0, 0, 0)

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
end

local function HandleRollercoasterAnimation(vehicle, player)
	return player:SelectWeightedSequence(ACT_GMOD_SIT_ROLLERCOASTER)
end

function ENT:Use(activator, caller)
	if IsValid(self.Seat) then return end

	if self.CanEnter and not self:CanEnter(caller) then return end

	local ent = ents.Create("prop_vehicle_prisoner_pod")
	ent:SetModel("models/nova/airboat_seat.mdl")
	ent:SetKeyValue("vehiclescript","scripts/vehicles/prisoner_pod.txt")
	
	-- limitview enabled here; then disabled 0.5 sec later
	-- this makes it so player looks at general fwd direction
	-- seteyeangles is too unreliable?? TODO find a better hack
	ent:SetKeyValue("limitview","1")

	ent:SetPos(self:LocalToWorld(self.SeatLPos))
	ent:SetAngles(self:LocalToWorldAngles(self.SeatLAng))
	ent:SetNotSolid(true)
	ent:SetNoDraw(true)

	ent.HandleAnimation = HandleRollercoasterAnimation

	ent:SetMoveType(MOVETYPE_NONE)
	ent:SetParent(self)

	ent:Spawn()
	ent:Activate()

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end

	ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

	ent.CKitSubSeat = true

	self.PlySeatEnterPos = caller:GetPos()

	caller:EnterVehicle(ent)
	timer.Simple(0.5, function()
		if not IsValid(ent) then return end
		ent:SetKeyValue("limitview","0")
	end)
	
	if self.OnEnter then self:OnEnter(caller) end

	self.Seat = ent
end

function ENT:RemovePlayer()
	local ply = self:GetSitter()
	if not IsValid(ply) then return end

	ply:ExitVehicle()
	ply:SetPos(self.PlySeatEnterPos)
	self.Seat:Remove()
end

hook.Add("CanExitVehicle", "CasinoKitSeatHook", function(ent, ply)
	if not ent.CKitSubSeat then return end
	
	local cseat = ent:GetParent()

	cseat:RemovePlayer()

	if cseat.OnLeave then cseat:OnLeave(ply) end

	return false
end)

local function PlayerLeftTable(ply)
	local ent = ply:GetVehicle()
	if not ent.CKitSubSeat then return end
	
	local cseat = ent:GetParent()

	ent:Remove()
	
	if cseat.OnLeave then cseat:OnLeave(ply) end
end
hook.Add("PlayerDeath", "CasinoKitSeatHook", PlayerLeftTable)
hook.Add("PlayerSilentDeath", "CasinoKitSeatHook", PlayerLeftTable)
hook.Add("PlayerDisconnected", "CasinoKitSeatHook", PlayerLeftTable)