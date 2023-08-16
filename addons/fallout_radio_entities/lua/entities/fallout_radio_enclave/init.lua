

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

-- You can set pause between music.
local PAUSE = 2


local MUSIC = 
{	

	{
		Snd = Sound( "falloutradio/eden/enclave_radio1.ogg" ),
		Dur = 196
	},
	
	{
		Snd = Sound( "falloutradio/eden/enclave_radio2.ogg" ),
		Dur = 108
	},
	
	{
		Snd = Sound( "falloutradio/eden/enclave_radio3.ogg" ),
		Dur = 66
	},
	
	{
		Snd = Sound( "falloutradio/eden/enclave_radio4.ogg" ),
		Dur = 22
	},
	
	{
		Snd = Sound( "falloutradio/eden/enclave_radio5.ogg" ),
		Dur = 69
	},
	
	{
		Snd = Sound( "falloutradio/eden/enclave_radio6.ogg" ),
		Dur = 56
	},
	
	{
		Snd = Sound( "falloutradio/eden/enclave_radio7.ogg" ),
		Dur = 143
	},
	
	{
		Snd = Sound( "falloutradio/eden/enclave_radio8.ogg" ),
		Dur = 68
	},
	
	{
		Snd = Sound( "falloutradio/eden/enclave_radio9.ogg" ),
		Dur = 78
	},

	{
		Snd = Sound( "falloutradio/eden/enclave_radio10.ogg" ),
		Dur = 98
	},
}

-- Do not edit these as it could corrupt this entity!
include('shared.lua')
function ENT:SpawnFunction(ply, tr)
	if (!tr.Hit) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	local ent = ents.Create("fallout_radio_enclave")
		ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
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
	local Mus = MUSIC[ math.random( 1, #MUSIC ) ]
	if (!self.On) then

		self:EmitSound("falloutradio/fx/pipboy_radio_off.mp3")
		self.On = true
		self.currentsound = Mus.Snd

		timer.Simple(0, function()
			self:EmitSound(self.currentsound)
		end)
	else 
		self.On = false
		self:StopSound(self.currentsound)
		timer.Simple(0, function()
			self:EmitSound("falloutradio/fx/pipboy_radio_off.mp3")
			self:SetSkin(0)
		end)
	end
end

function ENT:OnRemove()
	self:StopSound(self.currentsound)
end

function ENT:Initialize()


	self:SetModel("models/props_wasteland/speakercluster01a.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	self.On = true
	local Mus = MUSIC[ math.random( 1, #MUSIC ) ]
	self.currentsound = Mus.Snd
	self:EmitSound(self.currentsound)
	

end

