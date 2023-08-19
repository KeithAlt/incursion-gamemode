AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Energy Strike"

function ENT:Initialize()
    if SERVER then
        --Physics
        self:SetModel("models/items/ar2_grenade.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        ParticleEffectAttach("nr_freighterflame_main", PATTACH_ABSORIGIN_FOLLOW, self, 0)
        local phys = self:GetPhysicsObject()

        if (phys:IsValid()) then
            phys:Wake()
            phys:SetVelocity(self:GetAngles():Forward() * 3000)
        end
    end
end

function ENT:PhysicsCollide(collide, phys)
	if SERVER then
		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetNormal( self:GetPos():GetNormal() )
		effectdata:SetEntity( self )
		util.Effect( "cball_explode", effectdata )

		util.BlastDamage(self, self.Owner, self:GetPos(), 300, 100)
	end
	self:Remove()
end
