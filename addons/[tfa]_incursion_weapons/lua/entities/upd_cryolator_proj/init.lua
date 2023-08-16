AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Items/combine_rifle_ammo01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetAngles(Angle(180, 0, 0))
	self:SetNoDraw(true)

	local phys = self:GetPhysicsObject()
	if ( !IsValid( phys ) ) then
		phys:Wake()
	end

	timer.Simple(0, function() -- Needs to be called on next tick
		ParticleEffectAttach("mr_jet_01a", 1, self, 1)
	end)
end

-- 		owner:EmitSound("physics/glass/glass_impact_bullet" .. math.random(4) .. ".wav")


function ENT:Explode()
	util.BlastDamage(self, self, self:GetPos(), 100, self.damage)
	util.ScreenShake(self:GetPos(), 25, 25, 5, 1000)

	local effect = EffectData()
	effect:SetOrigin(self:GetPos())
	util.Effect("cryo_explode", effect, true, true)

	self:EmitSound("weapons/plasmagrenade/plasma_grenade_explosion.ogg", 75, 110)

	for k, v in pairs(ents.FindInSphere(self:GetPos(), 1000)) do
		if v:IsPlayer() and v:Alive() and v:GetMoveType() != MOVETYPE_NOCLIP then

			if v:GetPos():Distance(self:GetPos()) < 400 then
				v:Freeze(true)
				v:SetColor(Color(100,100,200))
				v:EmitSound("physics/glass/glass_impact_bullet" .. math.random(4) .. ".wav", 75, 80)

				local target = v

				timer.Simple(0, function() -- Prevents a client side crash issue with screenfade overlap
					if target:Alive() then
						target:ScreenFade(SCREENFADE.IN, Color(155,155,255, 100), 0.5, 0.5)
					end
				end)

				timer.Simple(3, function()
					if IsValid(target) then
						target:Freeze(false)
						target:SetColor(Color(255,255,255))
						target:EmitSound("physics/glass/glass_impact_bullet" .. math.random(4) .. ".wav", 75, 100)
					end
				end)
			end
		end
	end

	-- Called on next tick
	timer.Simple(0, function()
		if !IsValid(self) then return end
		self:Remove()
	end)
end

function ENT:PhysicsCollide(data, phys)
	if (data.Speed > 60) then
		self:Explode()
	end
end
