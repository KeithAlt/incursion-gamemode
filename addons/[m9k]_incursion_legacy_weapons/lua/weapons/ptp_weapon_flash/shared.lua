if (SERVER) then
  
	AddCSLuaFile ("shared.lua")
	SWEP.Weight 			= 5
	SWEP.AutoSwitchTo 		= false
	SWEP.AutoSwitchFrom 		= false
end

if (CLIENT) then

	SWEP.PrintName 			= "Flash Grenade"
	SWEP.Slot 				= 4
	SWEP.SlotPos 			= 1
	SWEP.DrawAmmo 			= true
	SWEP.DrawCrosshair 		= false
	SWEP.ViewModelFOV		= 60
	SWEP.ViewModelFlip		= false
	SWEP.UseHands			= true
	SWEP.CSMuzzleFlashes	= false

	SWEP.IconLetter 		= "P"
	killicon.AddFont("ptp_weapon_flash", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ))
end

SWEP.Category			= "Counter-Strike Grenades"

SWEP.Base 					= "ptp_weapon_grenade"

SWEP.HoldType				= "grenade"

SWEP.Contact 				= ""
SWEP.Purpose 				= ""

SWEP.Spawnable 				= true
SWEP.AdminSpawnable 			= true

SWEP.ViewModel 				= "models/weapons/cstrike/c_eq_flashbang.mdl"
SWEP.WorldModel 				= "models/weapons/w_eq_flashbang.mdl"

SWEP.Primary.ClipSize 			= 1
SWEP.Primary.DefaultClip 		= 1
SWEP.Primary.Automatic 			= true
SWEP.Primary.Ammo 			= "grenade"

SWEP.Secondary.ClipSize 		= -1
SWEP.Secondary.DefaultClip 		= -1
SWEP.Secondary.Automatic 		= true
SWEP.Secondary.Ammo 			= "none"

/*---------------------------------------------------------
ThrowFar
---------------------------------------------------------*/
function SWEP:ThrowFar()

	if self.Primed != 2 then return end

	local tr = self.Owner:GetEyeTrace()

	if (!SERVER) then return end

	local ent = ents.Create ("ent_flashgrenade")

			local v = self.Owner:GetShootPos()
				v = v + self.Owner:GetForward() * 1
				v = v + self.Owner:GetRight() * 3
				v = v + self.Owner:GetUp() * 1
			ent:SetPos( v )

	ent:SetAngles(Angle(math.random(1,100),math.random(1,100),math.random(1,100)))
	ent.GrenadeOwner = self.Owner
	ent:Spawn()

	local phys = ent:GetPhysicsObject()
	if !IsValid(phys) then self.Weapon:SendWeaponAnim(ACT_VM_DRAW) self.Primed = 0 return end

	if self.Owner:KeyDown( IN_FORWARD ) then
		self.Force = 3200
	elseif self.Owner:KeyDown( IN_BACK ) then
		self.Force = 2100
	elseif self.Owner:KeyDown( IN_MOVELEFT ) then
		self.Force = 2500
	elseif self.Owner:KeyDown( IN_MOVERIGHT ) then
		self.Force = 2500
	else
		self.Force = 2500
	end

	phys:ApplyForceCenter(self.Owner:GetAimVector() *self.Force *1.2 + Vector(0,0,200) )
	phys:AddAngleVelocity(Vector(math.random(-500,500),math.random(-500,500),math.random(-500,500)))

	self:TakePrimaryAmmo(1)
	-- self:Reload()

	timer.Simple(0.6,
	function()

		if self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
			--self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
			self.Primed = 0
		else
			self.Primed = 0
		--	self.Weapon:Remove()
		--	self.Owner:ConCommand("lastinv")
		end
	end)
end

/*---------------------------------------------------------
ThrowShort
---------------------------------------------------------*/
function SWEP:ThrowShort()

	if self.Primed != 2 then return end

	local tr = self.Owner:GetEyeTrace()

	if (!SERVER) then return end

	local ent = ents.Create ("ent_flashgrenade")

			local v = self.Owner:GetShootPos()
				v = v + self.Owner:GetForward() * 2
				v = v + self.Owner:GetRight() * 3
				v = v + self.Owner:GetUp() * -3
			ent:SetPos( v )

	ent:SetAngles(Angle(math.random(1,100),math.random(1,100),math.random(1,100)))
	ent.GrenadeOwner = self.Owner
	ent:Spawn()

	local phys = ent:GetPhysicsObject()
	if !IsValid(phys) then self.Weapon:SendWeaponAnim(ACT_VM_DRAW) self.Primed = 0 return end

	if self.Owner:KeyDown( IN_FORWARD ) then
		self.Force = 1100
	elseif self.Owner:KeyDown( IN_BACK ) then
		self.Force = 300
	elseif self.Owner:KeyDown( IN_MOVELEFT ) then
		self.Force = 700
	elseif self.Owner:KeyDown( IN_MOVERIGHT ) then
		self.Force = 700
	else
		self.Force = 700
	end

	phys:ApplyForceCenter(self.Owner:GetAimVector() * self.Force * 2 + Vector(0, 0, 0))
	phys:AddAngleVelocity(Vector(math.random(-500,500),math.random(-500,500),math.random(-500,500)))

	self:TakePrimaryAmmo(1)
	-- self:Reload()

	timer.Simple(0.6,
	function()

		if self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
			--self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
			self.Primed = 0
		else
			self.Primed = 0
		--	self.Weapon:Remove()
		--	self.Owner:ConCommand("lastinv")
		end
	end)
end