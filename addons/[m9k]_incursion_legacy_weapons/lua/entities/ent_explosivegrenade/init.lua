
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

/*---------------------------------------------------------
Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	self.Entity:SetModel("models/halokiller38/fallout/weapons/explosives/fraggrenade.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow( false )


	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.Entity:SetNetworkedString("Owner", "World")

	local phys = self.Entity:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
	end

	self.timer = CurTime() + 3
end

local exp

/*---------------------------------------------------------
Think
---------------------------------------------------------*/
function ENT:Think()
	if self.timer < CurTime() then

--	cbt_hcgexplode( self.Entity:GetPos(), 75, 200, 6)

	self:Explosion()
	end
end

/*---------------------------------------------------------
HitEffect
---------------------------------------------------------*/
function ENT:HitEffect()
	for k, v in pairs ( ents.FindInSphere( self.Entity:GetPos(), 600 ) ) do
		if v:IsValid() && v:IsPlayer() then
		end
	end
end

/*---------------------------------------------------------
Explosion
---------------------------------------------------------*/
function ENT:Explosion()
	self:EmitSound("fo_sfx/explosion/impact/fx_explosion_impact_dirt_0" .. math.random(1,3) .. ".ogg")

	local effectdata = EffectData()
	effectdata:SetOrigin( self.Entity:GetPos() )
	effectdata:SetScale(1)
	util.Effect( "effect_explosion_scaleable", effectdata )

	util.BlastDamage(self, self:GetOwner() or self, self:GetPos(), 800, 100)
	util.ScreenShake(self:GetPos(), 25, 25, 1, 1500)

	for k, v in pairs(ents.FindInSphere(self:GetPos(), 1500)) do
		if v:IsPlayer() and v:Alive() then
			v:ScreenFade(SCREENFADE.IN, Color(255, 210, 133, 75), 0.5, 0.5)

			if v:GetPos():Distance(self:GetPos()) < 500 and !v:GetMoveType(MOVETYPE_NOCLIP) then
				v:Knockout(self.Owner, true)
			end
		end
	end

	self:Remove()
end

/*---------------------------------------------------------
OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )
end


/*---------------------------------------------------------
Use
---------------------------------------------------------*/
function ENT:Use( activator, caller, type, value )
end


/*---------------------------------------------------------
StartTouch
---------------------------------------------------------*/
function ENT:StartTouch( entity )
end


/*---------------------------------------------------------
EndTouch
---------------------------------------------------------*/
function ENT:EndTouch( entity )
end


/*---------------------------------------------------------
Touch
---------------------------------------------------------*/
function ENT:Touch( entity )
end
