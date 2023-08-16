if (SERVER) then
	AddCSLuaFile ("shared.lua")
	SWEP.Weight 			= 5
	SWEP.AutoSwitchTo 		= false
	SWEP.AutoSwitchFrom 		= false
end

if (CLIENT) then
	SWEP.PrintName 			= "Cryo Mine"
	SWEP.Slot 				= 4
	SWEP.SlotPos 			= 1
	SWEP.DrawAmmo 			= true
	SWEP.DrawCrosshair 		= false
	SWEP.ViewModelFOV			= 80
	SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes		= false
	SWEP.Category			= "Claymore Gaming"
	SWEP.IconLetter 			= "O"
	killicon.AddFont("cgc_nade", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ))
end

SWEP.Category			= "Claymore Gaming"
SWEP.HoldType				= "slam"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 			= true
SWEP.UseHands				= true
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_c4.mdl"
SWEP.ViewModelBoneMods = {
	["v_weapon.c4"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

SWEP.VElements = {
	["mine"] = { type = "Model", model = "models/halokiller38/fallout/weapons/mines/minefrag.mdl", bone = "v_weapon.c4", rel = "", pos = Vector(4.41, -0.686, -3.744), angle = Angle(0, 90, 0), size = Vector(1.064, 1.064, 1.064), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.WorldModel 				= ""
SWEP.ViewModelFlip 				= false
SWEP.ViewModelFOV				= 60
SWEP.Primary.ClipSize 			= 1
SWEP.Primary.DefaultClip 		= 3
SWEP.Primary.Automatic 			= false
SWEP.Primary.Ammo 			= "grenade"
SWEP.Secondary.ClipSize 		= -1
SWEP.Secondary.DefaultClip 		= -1
SWEP.Secondary.Automatic 		= false
SWEP.Secondary.Ammo 			= "none"
SWEP.Primed 				= 0
SWEP.Throw 					= CurTime()
SWEP.PrimaryThrow				= true
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:Holster()
	self.Primed = 0
	self.Throw = CurTime()
	self.Owner:DrawViewModel(true)
	return true
end


function SWEP:Reload()
	self.Owner:DrawViewModel(true)
	self.Weapon:DefaultReload(ACT_VM_DRAW)
end

function SWEP:Think()
	if ((self:Clip1() > 0)) then
		self.Owner:DrawViewModel(true)
	else
		self.Owner:DrawViewModel(false)
	end

	if self.Primed == 1 and not self.Owner:KeyDown(IN_ATTACK) and self.PrimaryThrow then
		if self.Throw < CurTime() then
			self.Primed = 2
			self.Throw = CurTime() + 1.
			self.Weapon:SendWeaponAnim(ACT_VM_THROW)
			self.Owner:SetAnimation(PLAYER_ATTACK1)

			timer.Simple( 0.35, function()
				if (!self or !IsValid(self)) then return end
				self:ThrowFar()
			end)
		end

	elseif self.Primed == 1 and not self.Owner:KeyDown(IN_ATTACK2) and not self.PrimaryThrow then
		if self.Throw < CurTime() then
			self.Primed = 2
			self.Throw = CurTime() + 1.5
			self.Weapon:SendWeaponAnim(ACT_VM_THROW)
			self.Owner:SetAnimation(PLAYER_ATTACK1)

			timer.Simple( 0.35, function()
				if (!self or !IsValid(self)) then return end
				self:ThrowShort()
			end)
		end
	end
end

function SWEP:ThrowFar()
	if self.Primed != 2 then return end
	local tr = self.Owner:GetEyeTrace()
	if (!SERVER) then return end

	local ent = ents.Create ("fo_cryo_mine")
	local v = self.Owner:GetShootPos()
	v = v + self.Owner:GetForward() * 3
	v = v + self.Owner:GetRight() * 3
	v = v + self.Owner:GetUp() * -3
	ent:SetPos( v )

	ent.GrenadeOwner = self.Owner
	ent:Spawn()

	local phys = ent:GetPhysicsObject()

	if !IsValid(phys) then self.Weapon:SendWeaponAnim(ACT_VM_DRAW) self.Primed = 0 return end

	if self.Owner:KeyDown( IN_FORWARD ) then
		self.Force = 800
	elseif self.Owner:KeyDown( IN_BACK ) then
		self.Force = 800
	elseif self.Owner:KeyDown( IN_MOVELEFT ) then
		self.Force = 800
	elseif self.Owner:KeyDown( IN_MOVERIGHT ) then
		self.Force = 800
	else
		self.Force = 800
	end

	phys:ApplyForceCenter(self.Owner:GetAimVector() * self.Force * 0.2 + Vector(0, 0, 0))
	self:TakePrimaryAmmo(1)

	timer.Simple(0.6, function()
		if self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
			self.Primed = 0
		else
			self.Primed = 0

		end
	end)
end

function SWEP:ThrowShort()
	if self.Primed != 2 then return end
	local tr = self.Owner:GetEyeTrace()
	if (!SERVER) then return end

	local ent = ents.Create ("ent_explosivegrenade")
	local v = self.Owner:GetShootPos()
	v = v + self.Owner:GetForward() * 2
	v = v + self.Owner:GetRight() * 3
	v = v + self.Owner:GetUp() * -3

	ent:SetPos( v )
	ent.GrenadeOwner = self.Owner
	ent:Spawn()

	local phys = ent:GetPhysicsObject()

	if !IsValid(phys) then self.Weapon:SendWeaponAnim(ACT_VM_DRAW) self.Primed = 0 return end

	if self.Owner:KeyDown( IN_FORWARD ) then
		self.Force = 200
	elseif self.Owner:KeyDown( IN_BACK ) then
		self.Force = 200
	elseif self.Owner:KeyDown( IN_MOVELEFT ) then
		self.Force = 200
	elseif self.Owner:KeyDown( IN_MOVERIGHT ) then
		self.Force = 200
	else
		self.Force = 200
	end

	phys:ApplyForceCenter(self.Owner:GetAimVector() * self.Force * 0.2 + Vector(0, 0, 0))
	self:TakePrimaryAmmo(1)

	timer.Simple(0.6, function()
		if self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
			self.Primed = 0
		else
			self.Primed = 0
		end
	end)
end

function SWEP:PrimaryAttack()
	if self.Throw < CurTime() and self.Primed == 0 and self:CanPrimaryAttack() then
		self.Weapon:SendWeaponAnim(ACT_VM_PULLPIN)
		self.Primed = 1
		self.Throw = CurTime() + 1
		self.PrimaryThrow = true
	end
end

function SWEP:SecondaryAttack()
	if self.Throw < CurTime() and self.Primed == 0 and self:CanPrimaryAttack() then
		self.Weapon:SendWeaponAnim(ACT_VM_PULLPIN)
		self.Primed = 1
		self.Throw = CurTime() + 1
		self.PrimaryThrow = false
	end
end

function SWEP:Deploy()
	if (self:Clip1() > 0) then
		self.Throw = CurTime() + 0.75
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		self.Owner:DrawViewModel(true)
	else
		self.Throw = CurTime() + 0.75
		self.Owner:DrawViewModel(false)
	end
end

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	draw.SimpleText(self.IconLetter, "CSSelectIcons", x + wide / 2, y + tall * 0.2, Color(255, 210, 0, 255), TEXT_ALIGN_CENTER)
end
