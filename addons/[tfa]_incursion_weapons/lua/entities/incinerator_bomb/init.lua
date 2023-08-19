AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local dieTime = 1

function ENT:Initialize()
    self:SetModel("models/hunter/misc/sphere075x075.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetNoDraw(true)

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
      phys:Wake()
    end

	timer.Simple(0, function()
		if IsValid(self) then
			ParticleEffectAttach("mr_fireball_01a_nofollower", PATTACH_POINT_FOLLOW, self, 0)
		end
	end)

	self.dietime = CurTime() + dieTime
end



function ENT:CreateBurn(ply)
	if !ply:IsPlayer() then return end
	if timer.Exists(ply:EntIndex() .. "INCINBURN") then return end
	if (ply:GetModel() == "models/visualitygaming/fallout/valentina_hellfire.mdl" or string.find(ply:GetModel(), "group211") or string.find(ply:GetModel(), "group518")) then return end

	local dmg = DamageInfo()
    dmg:SetAttacker(self.Owner)
    dmg:SetDamage(self.damage / 2)
	local deaths = ply:Deaths()

	timer.Create(ply:EntIndex() .. "INCINBURN", 1, 10, function()
		if not IsValid(ply) or not ply:Alive() or deaths < ply:Deaths() then
			timer.Remove(ply:EntIndex() .. "INCINBURN")
			return
		end

		ply:EmitSound("ambient/fire/ignite.wav")
		ply:TakeDamageInfo(dmg)
		ParticleEffectAttach("mr_fireball_01a_nofollower", PATTACH_POINT_FOLLOW, ply, 3)

		timer.Simple(.3, function()
			ply:StopParticles()
		end)
	end)
end

function ENT:Touch( ply )
	if (string.find(ply:GetModel(), "group211") or string.find(ply:GetModel(), "group518")) then return end
	if ply:IsPlayer() then
		ply:TakeDamage(self.damage, self.Owner, self.Owner)	
		self:CreateBurn(ply)
		self:Remove()
	end
end

function ENT:Think()
	if self.dietime <= CurTime() then
		self:Remove()
	end

	self:GetPhysicsObject():AddVelocity( self:GetForward() * 1000 )
end

function ENT:PhysicsCollide( data, phys )
	self:EmitSound("ambient/fire/ignite.wav")

	for _, v in ipairs(ents.FindInSphere(self:GetPos(), 70)) do
		if v:IsPlayer() and v:Alive() then
			self:CreateBurn(v)
		end
	end

	self:Remove()
end

hook.Add("PlayerShouldTakeDamage", "INCIN_RemovePropDamage", function(ent, attacker)
	if attacker and attacker:GetClass() == "incinerator_bomb" then return false end
end)

hook.Add("EntityTakeDamage", "incintest", function(ent, dmg)
	if dmg:GetAttacker() and dmg:GetAttacker():GetClass() == "incinerator_bomb" then
		dmg:SetDamage(0)
	end
end)