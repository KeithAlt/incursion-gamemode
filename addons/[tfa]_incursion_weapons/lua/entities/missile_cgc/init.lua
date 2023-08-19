AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/weapons/w_missile_launch.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetColor(Color(214, 132, 51, 255))

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
      phys:Wake()
    end

    self:SetModelScale(3, 0)
end

function ENT:Touch( t )
  t:TakeDamage(500, self, self) -- If Direct hit, do extra damage.
end

function ENT:PhysicsCollide( data, phys )
    if data.Speed > 50 then
        util.BlastDamage(self, self, self:GetPos(), 150--[[radius]], 300 --[[dmg]])

        local vPoint = self:GetPos()
        local effectdata = EffectData()
        effectdata:SetOrigin( vPoint )
        util.Effect( "Explosion", effectdata ) -- Taken from wiki

        self:EmitSound( "ambient/explosions/explode_" .. math.random( 1, 4 ) .. ".wav", 60)

        timer.Simple(0, function()
         self:Remove()
        end)
    end

end

