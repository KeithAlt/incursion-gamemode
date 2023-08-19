

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

-- You can set pause between music.
local PAUSE = 2

local MUSIC =
{
	{
		Snd = Sound( "falloutradio/idle_jazz.mp3" ),
		Dur = 900
	},
	{
		Snd = Sound( "falloutradio/bebop.mp3" ),
		Dur = 93
	}

}

-- Do not edit these as it could corrupt this entity!
include('shared.lua')
function ENT:SpawnFunction(ply, tr)
	if (!tr.Hit) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	local ent = ents.Create("fallout_jukebox_jazz")
		ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	ent:SetName("Fallout Jazz Jukebox")
	ent:SetSkin(0)
	ent.Damaged = false;
	self.On = false;
	self.Play = false;

	return ent
end
function ENT:Use(activator, ply)
	if activator:KeyDownLast(IN_USE) then return end
	if (self.Damaged == true) then return end
	if (not ply:IsPlayer()) then return end
	if (!self.On) then
	local Mus

		if math.random() == 0.01 then
			Mus = MUSIC[2]
		else
			Mus = MUSIC[1]
		end

		self.Sound = CreateSound(self.Entity, Mus.Snd )
		self.Sound:Play()
		self.On = true;
		self.Play = true;
		self.Duration = CurTime() + PAUSE + Mus.Dur
		self.Musicon = CurTime() + Mus.Dur
		self.Debug = 0
		self:EmitSound("ambient/levels/labs/coinslot1.wav")
		self:SetSkin(1)
	else
		self.Sound:Stop()
		self.On = false;
		self:EmitSound("buttons/lever8.wav")
		self:SetSkin(0)
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
	-- self.On = false;
	-- self.Damaged = true;
	-- if (self.Sound) then
		-- self.Sound:ChangePitch(65)
		-- self.Sound:FadeOut(10)
	-- end
end

function ENT:Initialize()
	self.On = false

	self:SetModel("models/mosi/fallout4/props/radio/jukebox_prewar.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)

	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)

	self.Entity:SetSolid(SOLID_VPHYSICS)


	local phys = self.Entity:GetPhysicsObject()


if (phys:IsValid()) then

		phys:Wake()

	end

end
