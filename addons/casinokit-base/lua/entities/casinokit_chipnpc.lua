AddCSLuaFile()

ENT.CasinoKitPersistable = true
ENT.Base 			= "casinokit_npc"
ENT.RenderGroup = RENDERGROUP_BOTH
DEFINE_BASECLASS("casinokit_npc")

ENT.Spawnable = true
ENT.Category = "Casino Kit"
ENT.PrintName = "Chip Exchange Npc"

ENT.Model = "models/thespire/fallout/robots/securitron.mdl"

local voiceLine = {
	[0] = "npc/mrgutsy/dialogueunderworld_hello_00031916_1.wav",
	[1] = "npc/mrgutsy/dialoguecitadel_greeting_000bcc05_1.mp3",
	[2] = "npc/mrgutsy/genericrobot_greeting_0008300f_1.mp3",
	[3] = "npc/mrgutsy/genericrobot_guardtrespass_0008301a_1.mp3"
}

if CLIENT then
	function ENT:DrawTranslucent()
		if LocalPlayer():EyePos():Distance(self:GetPos()) > 512 then return end
		self:DrawOverheadText(CasinoKit.L("chip_exchange"))
	end

	function ENT:Draw()
		-- If localplayer is nearby do look op
		if LocalPlayer():EyePos():Distance(self:GetPos()) < 512 then
			self:LookAroundIdly()
		end

		BaseClass.Draw(self)
	end
end

function ENT:Use(ply)
	ply:ConCommand("casinokit_chipexchange_npc " .. self:EntIndex())

	if self.delay and self.delay <= CurTime() then
		self:EmitSound(voiceLine[math.random(0,#voiceLine)], 75, 93, 110)
	end

	self.delay = CurTime() + 2
end

function ENT:CustomInit()
	self:SetSequence( "idle_subtle" )
	self:SetSkin(7)
end
