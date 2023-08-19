
SWEP.PrintName = ""
   
SWEP.Author = "danguyen"
SWEP.Contact = ""
SWEP.Purpose = "penis."
SWEP.Instructions = ""
 
SWEP.Category = "Melee Arts 2"
 
SWEP.Spawnable= true
SWEP.AdminSpawnable= true
SWEP.AdminOnly = false
 
SWEP.ShotEffect = ""
 
SWEP.ViewModelFOV = 80
SWEP.ViewModel = ""
SWEP.WorldModel = ""
SWEP.ViewModelFlip = true
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false
 
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false
 
SWEP.Slot = 3
SWEP.SlotPos = 1
 
SWEP.UseHands = true
 
SWEP.HoldType = "grenade"
 
SWEP.DrawCrosshair = false
 
SWEP.DrawAmmo = true
 
SWEP.ReloadSound = ""
 
SWEP.Base = "weapon_base"
 
SWEP.LuaShells = true
SWEP.ShellName = " "
SWEP.DisableMuzzle = 1

SWEP.Primary.Sound = Sound("weapons/smg1/smg1_fire1.wav")
SWEP.Primary.Damage = 1
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = -1
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Spread = 0
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = 1
SWEP.Primary.Delay = 0.07
SWEP.Primary.Force = 10
SWEP.Primary.Cone = 0
 
SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
 
SWEP.CSMuzzleFlashes = false
 
function SWEP:Equip()
	self.Owner:PrintMessage(HUD_PRINTCENTER,"This is just to show the tier color codes. It's not a weapon, sorry doc")
	self.Owner:StripWeapon("matierthing")
end