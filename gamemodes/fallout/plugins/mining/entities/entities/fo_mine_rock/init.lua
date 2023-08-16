local PLUGIN = PLUGIN

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	if (not tr.Hit) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 1
	local ent = ents.Create(self.ClassName)
	local angle = ply:GetAimVector():Angle()
	angle = Angle(0, angle.yaw, 0)
	angle:RotateAroundAxis(angle:Up(), 180)
	ent:SetAngles(angle)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()
	self:SetModel("models/zerochain/props_mining/zrms_resource_point.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:DrawShadow(false)

	local physicsObject = self:GetPhysicsObject()
	if ( IsValid(physicsObject) ) then
		physicsObject:Wake()
		physicsObject:EnableMotion(false)
	end

	self.PhysgunDisabled = true

	self.RefreshAmount = self.RefreshAmount or PLUGIN.DefaultRefreshAmount
	self.RefreshRate = self.RefreshRate or PLUGIN.DefaultRefreshRate
end

local function createEffectTable(effect, sound, parent, angle, position, attach)
	net.Start("zrmine_FX")
	local effectInfo = {}
	effectInfo.effect = effect
	effectInfo.sound = sound
	effectInfo.pos = position
	effectInfo.ang = angle
	effectInfo.parent = parent
	effectInfo.attach = attach
	net.WriteTable(effectInfo)
	net.SendPVS(parent:GetPos())
end

function ENT:Think()
	if ( self.NextRefresh && CurTime() > self.NextRefresh ) then
		self:setNetVar("mineHp", self:getNetVar("mineMaxHp", PLUGIN.DefaultMaxHp))
		self:SetCustomCollisionCheck(false) -- Disable the custom collision check that makes the rock not solid when empty
		createEffectTable("zrms_ore_refresh", nil, self, self:GetAngles(), self:GetPos())
		self.NextRefresh = nil
	end

	self:NextThink(CurTime() + 1)
end