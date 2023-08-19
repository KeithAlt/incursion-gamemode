
local time = 0
local hold = 0
-------------------------------
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
-------------------------------
----------------
-- Initialize --
----------------

ENT.WeaponClass = ""
ENT.WeaponModel = ""
ENT.WeaponClip = 0

ENT.WeaponType = 1  -- 1 - пистолет, 2 - винтовка, 3 - нож, 4 - другое

local delay = 0

function ENT:Initialize()
	
	self.Entity:SetModel( self.WeaponModel )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON )
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	delay = CurTime() + 1.5
	
end

function ENT:PhysicsCollide(data,phys)

	if data.Speed > 50 then
		if self.WeaponType == 1 then
			self:EmitSound("HMC/Weapons/Drop_Gun_02.wav", 50, math.random(95, 105))
		elseif self.WeaponType == 2 then
			self:EmitSound("HMC/Weapons/Drop_Rifle_01.wav", 50, math.random(95, 105))
		elseif self.WeaponType == 3 then
			self:EmitSound("HMC/Weapons/Drop_Knife_01.wav", 50, math.random(95, 105))
		elseif self.WeaponType == 4 then
			self:EmitSound("HMC/Weapons/Drop_Item_01.wav", 50, math.random(95, 105))
		end
	end
	--local impulse = -data.Speed * data.HitNormal * 2 + (data.OurOldVelocity * -2)

end

------------
-- On use --
------------
function ENT:Use( activator, caller )
	if delay > CurTime() then return end
	local ply = activator
			if self.WeaponType == 1 then
				ply:EmitSound("HMC/Weapons/PickUp_Gun_01.wav", 50, math.random(95, 105))
			elseif ply.WeaponType == 2 then
				ply:EmitSound("HMC/Weapons/PickUp_Rifle_01.wav", 50, math.random(95, 105))
			elseif self.WeaponType == 3 then
				ply:EmitSound("HMC/Weapons/PickUp_Knife_01.wav", 50, math.random(95, 105))
			elseif self.WeaponType == 4 then
				ply:EmitSound("HMC/Weapons/PickUp_Item_01.wav", 50, math.random(95, 105))
			end
		ply:Give(self.WeaponClass, false)
		ply:GetWeapon(self.WeaponClass):SetClip1(self.WeaponClip)
	self.Entity:Remove()
end

/*
 DropItem - звук удара о землю для всяких свепов, которые не оружие (потом будут)
DropKnife - звук удара о землю для ножей
PickUpItem - для прочих свепов
PickUpKnife - для ножей
PickUpGun - для пистолетов
PickUpRifle - для винтовок и смг
_Guns/Gun_Drop5 - звук удара для винтовок и смг
_Guns/Gun_Drop6 - звук удара для пистолетов и их магазинов

*/
