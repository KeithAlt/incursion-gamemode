SWEP.PrintName = "Pickaxe" -- The name of your SWEP
SWEP.AdminSpawnable = false -- Is the SWEP spawnable for admins?
SWEP.Spawnable = true -- Can everybody spawn this SWEP? - If you want only admins to spawn it, keep this false and admin spawnable true.

SWEP.ViewModelFOV = 55 -- How much of the weapon do you see?
SWEP.ViewModel = "models/zerochain/props_mining/zrms_v_pickaxe.mdl"
SWEP.WorldModel = "models/zerochain/props_mining/zrms_w_pickaxe.mdl"
SWEP.UseHands = false

SWEP.AutoSwitchTo = false -- When someone picks up the SWEP, should it automatically change to your SWEP?
SWEP.AutoSwitchFrom = true -- Should the weapon change to the a different SWEP if another SWEP is picked up?
SWEP.Slot = 1 -- Which weapon slot you want your SWEP to be in? (1 2 3 4 5 6)
SWEP.SlotPos = 1 -- Which part of that slot do you want the SWEP to be in? (1 2 3 4 5 6)
SWEP.HoldType = "melee2" -- How is the SWEP held? (Pistol SMG Grenade Melee)
SWEP.FiresUnderwater = false -- Does your SWEP fire under water?
SWEP.Weight = 5 -- Set the weight of your SWEP.
SWEP.DrawCrosshair = true -- Do you want the SWEP to have a crosshair?
SWEP.Category = "Nutscript"
SWEP.DrawAmmo = false -- Does the ammo show up when you are using it? True / False
SWEP.base = "weapon_base" --What your weapon is based on.
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Recoil = 1
SWEP.Primary.Delay = 1
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Recoil = 1
SWEP.Secondary.Delay = 1

-- How much could we harvest with 1 hit at max
SWEP.MaxHarvestRate = 2

-- Whats the time range between each hits
SWEP.MaxInterval = 0.7
SWEP.MinInterval = 0.5

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 8, "HarvestInterval")

	self:NetworkVar("Float", 0, "NextCoolDown")
	self:NetworkVar("Float", 1, "CoolDown")

	if (SERVER) then
		self:SetHarvestInterval(1)
		self:SetNextCoolDown(1)
		self:SetCoolDown(-1)
	end
end