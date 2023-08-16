

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

-- You can set pause between music.
local PAUSE = 2

local MUSIC =
{

	{
		Snd = Sound( "falloutradio/16tons.mp3" ),
		Dur = 155
	},

	{
		Snd = Sound( "falloutradio/aintmisbehavin.mp3" ),
		Dur = 238
	},

	{
		Snd = Sound( "falloutradio/aintthatakickinthehead.mp3" ),
		Dur = 154
	},

	{
		Snd = Sound( "falloutradio/akisstobuildadreamon.mp3" ),
		Dur = 181
	},

	{
		Snd = Sound( "falloutradio/anythinggoes.mp3" ),
		Dur = 203
	},

	{
		Snd = Sound( "falloutradio/atombombbaby.mp3" ),
		Dur = 136
	},

	{
		Snd = Sound( "falloutradio/bigiron.mp3" ),
		Dur = 241
	},

	{
		Snd = Sound( "falloutradio/bluemoon.mp3" ),
		Dur = 166
	},

	{
		Snd = Sound( "falloutradio/butcherpete.mp3" ),
		Dur = 308
	},

	{
		Snd = Sound( "falloutradio/civilization.mp3" ),
		Dur = 185
	},

	{
		Snd = Sound( "falloutradio/countryroads.mp3" ), -- TAKE ME HOME!
		Dur = 182
	},

	{
		Snd = Sound( "falloutradio/crawlout.mp3" ),
		Dur = 140
	},

	{
		Snd = Sound( "falloutradio/crazyhecallsme.mp3" ),
		Dur = 185
	},

	{
		Snd = Sound( "falloutradio/dontfencemein.mp3" ),
		Dur = 186
	},

	{
		Snd = Sound( "falloutradio/endoftheworld.mp3" ),
		Dur = 161
	},

	{
		Snd = Sound( "falloutradio/fairweatherfriend.mp3" ),
		Dur = 186
	},

	{
		Snd = Sound( "falloutradio/gentlepeople.mp3" ),
		Dur = 129
	},

	{
		Snd = Sound( "falloutradio/gunwasloaded.mp3" ),
		Dur = 160
	},

	{
		Snd = Sound( "falloutradio/heartachesbythenumber.mp3" ),
		Dur = 154
	},

	{
		Snd = Sound( "falloutradio/idontwanttosettheworldonfire.mp3" ),
		Dur = 184
	},

	{
		Snd = Sound( "falloutradio/itsalloverbutthecrying.mp3" ),
		Dur = 169
	},

	{
		Snd = Sound( "falloutradio/jinglejanglejingle.mp3" ),
		Dur = 197
	},

	{
		Snd = Sound( "falloutradio/johnnyguitar.mp3" ),
		Dur = 181
	},

	{
		Snd = Sound( "falloutradio/lonestar.mp3" ),
		Dur = 150
	},

	{
		Snd = Sound( "falloutradio/maybe.mp3" ),
		Dur = 170
	},

	{
		Snd = Sound( "falloutradio/mr5x5.mp3" ),
		Dur = 181
	},

	{
		Snd = Sound( "falloutradio/orangecolouredsky.mp3" ),
		Dur = 133
	},

	{
		Snd = Sound( "falloutradio/personality.mp3" ),
		Dur = 169
	},

	{
		Snd = Sound( "falloutradio/pistolpackinmama.mp3" ),
		Dur = 180
	},

	{
		Snd = Sound( "falloutradio/praisethelord.mp3" ),
		Dur = 155
	},

	{
		Snd = Sound( "falloutradio/rainmustfall.mp3" ),
		Dur = 190
	},

	{
		Snd = Sound( "falloutradio/rocket69.mp3" ),
		Dur = 163
	},

	{
		Snd = Sound( "falloutradio/sixtyminuteman.mp3" ),
		Dur = 150
	},

	{
		Snd = Sound( "falloutradio/uraniumfever.mp3" ),
		Dur = 139
	},

	{
		Snd = Sound( "falloutradio/wanderer.mp3" ),
		Dur = 167
	},

	{
		Snd = Sound( "falloutradio/waybackhome.mp3" ),
		Dur = 171
	},

	{
		Snd = Sound( "falloutradio/wonderfulguy.mp3" ),
		Dur = 113
	}

}

-- Do not edit these as it could corrupt this entity!
include('shared.lua')
function ENT:SpawnFunction(ply, tr)
	if (!tr.Hit) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	local ent = ents.Create("fallout_jukebox")
		ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	ent:SetName("Fallout Jukebox")
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
		local Mus = MUSIC[ math.random( 1, #MUSIC ) ]
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

	self:SetModel("models/mosi/fallout4/props/radio/jukebox.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)

	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)

	self.Entity:SetSolid(SOLID_VPHYSICS)


	local phys = self.Entity:GetPhysicsObject()


if (phys:IsValid()) then

		phys:Wake()

	end

end
