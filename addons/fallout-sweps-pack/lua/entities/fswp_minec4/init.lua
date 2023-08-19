AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "shared.lua" );
include( "shared.lua" );

function ENT:Initialize()
	self:SetModel( "models/halokiller38/fallout/weapons/explosives/c4.mdl" );
	self.Entity:PhysicsInit( SOLID_VPHYSICS );
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS );
	self.Entity:SetSolid( SOLID_VPHYSICS );
	self.Entity:SetUseType( SIMPLE_USE );
	self.Entity:GetPhysicsObject():Wake();
	self.Entity:GetPhysicsObject():SetMass( 500 );
	self.ArmSound = "weapons/pinpull.wav";
	self.Entity:GetPhysicsObject():EnableMotion(true);
	self.Detonated = false;
	self.SpawnedTime = CurTime();
end;

function ENT:Use(player)
player:Give("weapon_minec4")
self:Remove();
end

function ENT:OnTakeDamage( damage )
	self:Detonate();
end;

function ENT:Detonate()
	if self.Detonated then return end;
	self:EmitSound(self.ArmSound);
	local MineExplode = ents.Create("env_explosion");
	MineExplode:SetPos(self:GetPos());
	MineExplode:Spawn();
	MineExplode:SetKeyValue("iMagnitude", "115");
	MineExplode:Fire("explode");
	self:Remove();
	self.Detonated = true;
end;
