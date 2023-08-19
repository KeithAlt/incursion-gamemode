

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

-- You can set pause between music.
local PAUSE = 2
local MUSIC =
{
	{
		Snd = Sound( "broadcast/enclave_broadcast1.ogg" ),
		Dur = 197
	},
	{
		Snd = Sound( "broadcast/enclave_broadcast2.ogg" ),
		Dur = 185
	},
	{
		Snd = Sound( "broadcast/enclave_broadcast3.ogg" ),
		Dur = 169
	},
	{
		Snd = Sound( "broadcast/enclave_broadcast4.ogg" ),
		Dur = 183
	},
	{
		Snd = Sound( "broadcast/enclave_broadcast5.ogg" ),
		Dur = 207
	},
	{
		Snd = Sound( "broadcast/enclave_broadcast6.ogg" ),
		Dur = 86
	},
	{
		Snd = Sound( "broadcast/enclave_broadcast7.ogg" ),
		Dur = 246
	},
	{
		Snd = Sound( "broadcast/enclave_broadcast8.ogg" ),
		Dur = 366
	},
	{
		Snd = Sound( "broadcast/enclave_broadcast9.ogg" ),
		Dur = 360
	},
}

-- Do not edit these as it could corrupt this entity!
include('shared.lua')

function ENT:Use(activator, ply)
	if activator:KeyDownLast(IN_USE) then return end
	if (self.Damaged == true) then return end
	if (not ply:IsPlayer()) then return end
	if (!self.On) then
		local Mus = MUSIC[ math.random( 1, #MUSIC ) ]
		self.Sound = CreateSound(self.Entity, Mus.Snd )
		self.Sound:SetSoundLevel(95)
		self.Sound:Play()
		self.On = true;
		self.Play = true;
		self.Duration = CurTime() + PAUSE + Mus.Dur
		self.Musicon = CurTime() + Mus.Dur
		self.Debug = 0
		self:EmitSound("buttons/lever7.wav")
	else
		self.Sound:Stop()
		self.On = false;
		self:EmitSound("buttons/lever8.wav")
	end
end

function ENT:Think()
	if (not self.Damaged == true) and (self.On == true) then
		if CurTime() > self.Musicon then
				self.Play = false;
				self.Sound:Stop()
				self.Debug = CurTime() + PAUSE
				if (CurTime() > self.Duration) and (self.On == true) then
					self.Play = true;
					self.Sound:Stop()
					local Mus = MUSIC[ math.random( 1, #MUSIC ) ]
					self.Sound = CreateSound(self.Entity, Mus.Snd )
					self.Sound:Play()
					self.Musicon = CurTime() + Mus.Dur
					self.Duration = CurTime() + PAUSE + Mus.Dur
				end
			if CurTime() > self.Debug and (self.Sound) then
					self.Sound:ChangePitch(99)
					self.Sound:ChangePitch(100)
					self.Debug = CurTime() + PAUSE
			end
		end
	end
	-- if (self:WaterLevel() > 0) then
		-- util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 1000, 10)
		-- local effectdata = EffectData()
		-- effectdata:SetOrigin( self.Entity:GetPos() )
 		-- util.Effect( "Explosion", effectdata, true, true )
		-- self.Entity:Remove()
	-- end
	self:NextThink(1)
end

function ENT:OnRemove()
	if (self.Sound) then
		self.Sound:Stop()
	end
end

function ENT:OnTakeDamage(dmg)
end

function ENT:Initialize()
	self.On = false
	self:SetModel("models/weapons/keitho/turrets/workshopsiren.mdl")
	self:SetModelScale(1.5)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	local phys = self.Entity:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
	end
end
