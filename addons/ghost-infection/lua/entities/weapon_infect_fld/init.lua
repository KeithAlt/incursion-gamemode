AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include( "shared.lua" )

--Basic code required to create the file--
function ENT:SpawnFunction( ply, tr, class )
	if ( !tr.Hit ) then return end
	local pos = tr.HitPos + tr.HitNormal * 4
	local ent = ents.Create( class )
	ent:SetPos( pos )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	self:SetModel( self.WorldModel )
	self:SetModelScale( 0.25 )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self:SetUseType( SIMPLE_USE )
	
	local phys = self:GetPhysicsObject()
	self.nodupe = true
	self.ShareGravgun = true

	phys:Wake()
end

function ENT:Remove()
end

function ENT:Think()
	if self:WaterLevel() > 0 then
		self:Remove()
	end
end

function ENT:Use( activator )
	if !IsValid(activator) then return end
	if !activator:IsPlayer() then return end
	if !activator:Alive() then return end
	if activator:HasWeapon("weapon_infect_fld") then return end
	if CLIENT then
		chat.AddText(
		Color( 0, 200, 0 ), "haha u just got infeected by the fl00d xdddd"
		) end
		
	activator:Give("weapon_infect_fld")
	activator:SetActiveWeapon(activator:GetWeapon("weapon_infect_fld"))
	self:Remove()
end