AddCSLuaFile()

SWEP.PrintName = "Prop Vector Changer"
SWEP.Category = "Other"
SWEP.Author = "Keith"
SWEP.Purpose = ""
SWEP.Instructions = ""

SWEP.Slot = 0
SWEP.SlotPos = 4

SWEP.Spawnable = true

SWEP.ViewModel = Model( "models/weapons/v_hands.mdl" )
SWEP.WorldModel = Model( "models/weapons/w_grenade.mdl" )
SWEP.ViewModelFOV = 75
SWEP.DrawCrosshair 	= true
SWEP.UseHands = true
SWEP.ShowWorldModel = false
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.DrawAmmo = false

function SWEP:PrimaryAttack()
	local prop = self.Owner:GetEyeTrace().Entity
	self.Owner:ChatPrint("[ ! ]  Entity vector changed")
	prop:SetPos(prop:GetPos() - Vector(-6000,0,9000))
end

function SWEP:SecondaryAttack()
end

function SWEP:DrawHUD()
end

function SWEP:Reload()
end

function SWEP:IdleSound()
end

