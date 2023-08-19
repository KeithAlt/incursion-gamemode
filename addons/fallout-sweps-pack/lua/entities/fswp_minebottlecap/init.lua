AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "shared.lua" );
include( "shared.lua" );

function ENT:Initialize()
	self:SetModel( "models/halokiller38/fallout/weapons/mines/bottlecapmine.mdl" );
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
	self.timeleft = CurTime() + 3
end;

function ENT:Use(player)
player:Give("weapon_minebottlecap")
self:Remove();
end

function ENT:OnTakeDamage( damage )
	self:Detonate();
end;

function ENT:Touch( ent )
	if ent:IsPlayer() or ent:IsNPC() then
		if self.SpawnedTime + 1.2 > CurTime() then return end;
		self:Detonate();
	end;
end;

 function ENT:Think()
	
	if not IsValid(self) then return end
	if not IsValid(self.Entity) then return end

	if self.timeleft < CurTime() then
 	for k, v in pairs ( ents.FindInSphere( self.Entity:GetPos(), 100 ) ) do		
		if v:IsPlayer() || v:IsNPC() then					// If its alive then
		local trace = {}						// Make sure there's not a wall in between
		trace.start = self.Entity:GetPos()
		trace.endpos = v:GetPos()			// Trace to the torso
		trace.filter = self.Entity
		local tr = util.TraceLine( trace )				// If the trace hits a living thing then
		if tr.Entity:IsPlayer() || tr.Entity:IsNPC() then self:Detonate() end 
		end
	end	
	end

	self.Entity:NextThink( CurTime() )
	return true
end

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
