AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Items/AR2_Grenade.mdl") 
	self:PhysicsInit(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	
	timer.Simple(15, function()
		SafeRemoveEntity(self)
	end)
	
	for k,v in pairs(ents.FindInSphere(self:GetPos(),150)) do
		if v:IsValid() and v:IsNPC() then
			v:LostEnemySound()
			v:ClearEnemyMemory()
			v:SetCondition( 11 )
			v:SetSchedule( 40 )
		end
			
	end
end

function ENT:Use(activator, caller)
	return false
end

function ENT:PhysicsCollide()
end