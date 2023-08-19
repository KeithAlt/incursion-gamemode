/*---------------------------------------------------------
Think
---------------------------------------------------------*/
function SWEP:Think()
	if self.Owner:KeyDown(IN_SPEED) then
				self:SetHoldType("normal")
	else
			self:SetHoldType(self.HoldType)
	end
	if self.MoveTime and self.MoveTime < CurTime() and SERVER then
		self.MoveTime = nil
	end
end


local ActIndex = {
	[ "pistol" ] 		= ACT_HL2MP_IDLE_PISTOL,
	[ "revolver" ] 		= ACT_HL2MP_IDLE_REVOLVER,
	[ "smg" ] 			= ACT_HL2MP_IDLE_SMG1,
	[ "grenade" ] 		= ACT_HL2MP_IDLE_GRENADE,
	[ "ar2" ] 			= ACT_HL2MP_IDLE_AR2,
	[ "shotgun" ] 		= ACT_HL2MP_IDLE_SHOTGUN,
	[ "rpg" ]	 		= ACT_HL2MP_IDLE_RPG,
	[ "physgun" ] 		= ACT_HL2MP_IDLE_PHYSGUN,
	[ "crossbow" ] 		= ACT_HL2MP_IDLE_CROSSBOW,
	[ "melee" ] 		= ACT_HL2MP_IDLE_MELEE,
	[ "slam" ] 			= ACT_HL2MP_IDLE_SLAM,
	[ "normal" ]		= ACT_HL2MP_IDLE,
	[ "fist" ]			= ACT_HL2MP_IDLE_FIST,
	[ "melee2" ]		= ACT_HL2MP_IDLE_MELEE2,
	[ "passive" ]		= ACT_HL2MP_IDLE_PASSIVE,
	[ "knife" ]			= ACT_HL2MP_IDLE_KNIFE
}

/*---------------------------------------------------------
Initialize
---------------------------------------------------------*/
function SWEP:Initialize()
self:SetHoldType( self.HoldType )
end


function SWEP:SetHoldType( t )
	local index = ActIndex[ t ]
	if (index == nil) then
		Msg( "SWEP:SetHoldType - ActIndex[ \""..t.."\" ] isn't set! (defaulting to normal)\n" )
		t = "normal"
	end
	self.ActivityTranslate = {}
	self.ActivityTranslate [ ACT_MP_STAND_IDLE ] 				= index
	self.ActivityTranslate [ ACT_MP_WALK ] 						= index+1
	self.ActivityTranslate [ ACT_MP_RUN ] 						= index+2
	self.ActivityTranslate [ ACT_MP_CROUCH_IDLE ] 				= index+3
	self.ActivityTranslate [ ACT_MP_CROUCHWALK ] 				= index+4
	self.ActivityTranslate [ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] 	= index+5
	self.ActivityTranslate [ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = index+5
	self.ActivityTranslate [ ACT_MP_RELOAD_STAND ]		 		= index+6
	self.ActivityTranslate [ ACT_MP_RELOAD_CROUCH ]		 		= index+6
	self.ActivityTranslate [ ACT_MP_JUMP ] 						= index+7
	self.ActivityTranslate [ ACT_RANGE_ATTACK1 ] 				= index+8
	if t == "normal" then
		self.ActivityTranslate [ ACT_MP_JUMP ] = ACT_HL2MP_JUMP_SLAM
	end
	if t == "passive" then
		self.ActivityTranslate [ ACT_MP_CROUCH_IDLE ] = ACT_HL2MP_CROUCH_IDLE
	end
	if t == "knife" || t == "melee2" then
		self.ActivityTranslate [ ACT_MP_CROUCH_IDLE ] = nil
	end
	self:SetupWeaponHoldTypeForAI( t )
	self._InternalHoldType = t
end


function SWEP:Think()
	if self.Owner:KeyDown(IN_SPEED) then
				self:SetHoldType("normal")
	else
			self:SetHoldType(self.HoldType)
	end
	if self.MoveTime and self.MoveTime < CurTime() and SERVER then
		self.MoveTime = nil
	end
end










SWEP.Category			= "Fallout Sweps - Throwing Weapons"
SWEP.Author				= ""
SWEP.Contact				= ""
SWEP.Purpose				= ""
SWEP.Instructions				= ""
SWEP.MuzzleAttachment			= "1" 	-- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.ShellEjectAttachment			= "2" 	-- Should be "2" for CSS models or "1" for hl2 models
SWEP.PrintName				= "Knife Spear"		-- Weapon name (Shown on HUD)	
SWEP.Slot				= 0				-- Slot in the weapon selection menu
SWEP.SlotPos				= 103			-- Position in the slot
SWEP.DrawAmmo				= false		-- Should draw the default HL2 ammo counter
SWEP.DrawWeaponInfoBox			= false		-- Should draw the weapon info box
SWEP.BounceWeaponIcon   		= 	false	-- Should the weapon icon bounce?
SWEP.DrawCrosshair			= false		-- set false if you want no crosshair
SWEP.Weight				= 1			-- rank relative ot other weapons. bigger is better
SWEP.AutoSwitchTo			= true		-- Auto switch to if we pick it up
SWEP.AutoSwitchFrom			= true		-- Auto switch from if you pick up a better weapon
SWEP.HoldType 				= "melee"		-- how others view you carrying the weapon
-- normal melee melee2 fist knife smg ar2 pistol rpg physgun grenade shotgun crossbow slam passive 
-- you're mostly going to use ar2, smg, shotgun or pistol. rpg and ar2 make for good sniper rifles

SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false

SWEP.ViewModelFOV			= 70
SWEP.ViewModelFlip			= false
--SWEP.ViewModel				= "models/weapons/v_invisib.mdl"	-- Weapon view model
SWEP.WorldModel				= "models/Halokiller38/fallout/weapons/Melee/knifespear.mdl"	-- Weapon world model
SWEP.Base				= "boh_gun_base"
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
SWEP.FiresUnderwater 		= false
SWEP.ShowWorldModel			= true

SWEP.Primary.Sound			= Sound("")		-- Script that calls the primary fire sound
SWEP.Primary.RPM				= 60		-- This is in Rounds Per Minute
SWEP.Primary.ClipSize			= 1		-- Size of a clip
SWEP.Primary.DefaultClip		= 1		-- Bullets you start with
SWEP.Primary.KickUp				= 0		-- Maximum up recoil (rise)
SWEP.Primary.KickDown			= 0		-- Maximum down recoil (skeet)
SWEP.Primary.KickHorizontal		= 0		-- Maximum up recoil (stock)
SWEP.Primary.Automatic			= false		-- Automatic = true; Semi Auto = false
SWEP.Primary.Ammo			= "Knife_Spear"				
-- pistol, 357, smg1, ar2, buckshot, slam, SniperPenetratedRound, AirboatGun
-- Pistol, buckshot, and slam always ricochet. Use AirboatGun for a metal peircing shotgun slug

SWEP.Primary.Round 			= ("ent_halo_knifespear")	--NAME OF ENTITY GOES HERE

SWEP.Secondary.IronFOV			= 60		-- How much you 'zoom' in. Less is more! 	

SWEP.Primary.NumShots	= 0		-- How many bullets to shoot per trigger pull
SWEP.Primary.Damage		= 0	-- Base damage per bullet
SWEP.Primary.Spread		= 0	-- Define from-the-hip accuracy (1 is terrible, .0001 is exact)
SWEP.Primary.IronAccuracy = 0 -- Ironsight accuracy, should be the same for shotguns
--none of this matters for IEDs and other ent-tossing sweps

-- Enter iron sight info and bone mod info below
SWEP.IronSightsPos = Vector(0, -12.952, -2.951)
SWEP.IronSightsAng = Vector(64.835, 0, 0)
SWEP.SightsPos = Vector(0, -12.952, -2.951)
SWEP.SightsAng = Vector(64.835, 0, 0)
SWEP.RunSightsPos = Vector(0, 12.295, 10.656)
SWEP.RunSightsAng = Vector(-145, 3.5, 0)



SWEP.WElements = {
	["element_name"] = { type = "Model", model = "models/Halokiller38/fallout/weapons/Melee/knifespear.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.348, 1.661, -15.995), angle = Angle(180, -180, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

if file.Exists( "models/weapons/v_knife_t.mdl", "GAME" ) then
	SWEP.ViewModel				= "models/weapons/v_knife_t.mdl"	-- Weapon view model
		SWEP.VElements = {
			["element_name"] = { type = "Model", model = "models/Halokiller38/fallout/weapons/Melee/knifespear.mdl", bone = "v_weapon.knife_Parent", rel = "", pos = Vector(-2.072, -8.018, 4.151), angle = Angle(39.28, -16.566, 2.506), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
		}
		SWEP.ViewModelBoneMods = {
		["v_weapon.Knife_Handle"] = { scale = Vector(1, 1, 1), pos = Vector(-30, 30, -30), angle = Angle(0, 0, 0) },
		["v_weapon.Right_Arm"] = { scale = Vector(1, 1, 1), pos = Vector(-30, 30, 30), angle = Angle(0, 0, 0) }
		}
else
	SWEP.ViewModel				= "models/weapons/v_invisib.mdl"	-- Weapon view model
		SWEP.VElements = {
			["element_name"] = { type = "Model", model = "models/Halokiller38/fallout/weapons/Melee/knifespear.mdl", bone = "Da Machete", rel = "", pos = Vector(-16.342, -0.5, 26.829), angle = Angle(28.08, -34.35, -3.268), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
		}
		SWEP.ViewModelBoneMods = {
		["l-upperarm"] = { scale = Vector(1, 1, 1), pos = Vector(-7.286, 1.628, 7.461), angle = Angle(7.182, 0, 0) },
		["r-upperarm-movement"] = { scale = Vector(1, 1, 1), pos = Vector(-30, -30, -30), angle = Angle(0, 0, 0) },
		["l-upperarm-movement"] = { scale = Vector(1, 1, 1), pos = Vector(3.615, 0.547, 4.635), angle = Angle(-45.929, -39.949, -76.849) },
		["l-forearm"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-3.932, -42.389, 171.466) },
		["r-upperarm"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(7.336, 0, 0) },
		["lwrist"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-47.502, -5.645, 0.551) }
		}

end





/*---------------------------------------------------------
   Name: SWEP:TranslateActivity()
   Desc: Translate a player's activity into a weapon's activity.
	   So for example, ACT_HL2MP_RUN becomes ACT_HL2MP_RUN_PISTOL
	   depending on how you want the player to be holding the weapon.
---------------------------------------------------------*/
function SWEP:TranslateActivity(act)

	if (self.Owner:IsNPC()) then
		if (self.ActivityTranslateAI[act]) then
			return self.ActivityTranslateAI[act]
		end

		return -1
	end

	if (self.ActivityTranslate[act] != nil) then
		return self.ActivityTranslate[act]
	end
	
	return -1
end


function SWEP:PrimaryAttack()
	self:FireRocket()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Weapon:SetNextPrimaryFire(CurTime()+1/(self.Primary.RPM/60))	
	self.Weapon:EmitSound(Sound("Weapon_Knife.Slash"))
	self.Weapon:TakePrimaryAmmo(1)
	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
	self:CheckWeaponsAndAmmo()
end

function SWEP:FireRocket()
	pos = self.Owner:GetShootPos()
	if SERVER then
	local rocket = ents.Create(self.Primary.Round)
	if !rocket:IsValid() then return false end
	rocket:SetAngles(self.Owner:GetAimVector():Angle())
	rocket:SetPos(pos)
	rocket:SetOwner(self.Owner)
	rocket:Spawn()
	rocket.Owner = self.Owner
	rocket:Activate()
	eyes = self.Owner:EyeAngles()
		local phys = rocket:GetPhysicsObject()
			phys:SetVelocity(self.Owner:GetAimVector() * 2000)
	end
		if SERVER and !self.Owner:IsNPC() then
		local anglo = Angle(-10, -5, 0)		
		self.Owner:ViewPunch(anglo)
		end

end

function SWEP:CheckWeaponsAndAmmo()

	if SERVER and self.Weapon != nil and ((gmod.GetGamemode().Name == "Murderthon 9000") or GetConVar("DebugM9K"):GetBool()) then 
		timer.Simple(.1, function() 
			if SERVER then 
				if not IsValid(self) then return end
				if self.Owner == nil then return end
				self.Owner:StripWeapon(self.Gun)
			end
		end)
	return end

	if SERVER and self.Weapon != nil then 
		if self.Weapon:Clip1() == 0 && self.Owner:GetAmmoCount( self.Weapon:GetPrimaryAmmoType() ) == 0 then
			timer.Simple(.1, function() if SERVER then if not IsValid(self) then return end
				if self.Owner == nil then return end
				self.Owner:StripWeapon(self.Gun)
			end end)
		else
			self:Reload()
		end
	end
end

function SWEP:Reload()
	if not IsValid(self) then return end if not IsValid(self.Owner) then return end
	
	if self.Owner:IsNPC() then
		self.Weapon:DefaultReload(ACT_VM_RELOAD)
	return end
	
	if self.Owner:KeyDown(IN_USE) then return end
		self.Weapon:DefaultReload(ACT_VM_DRAW) 
	
	if !self.Owner:IsNPC() then
		if self.Owner:GetViewModel() == nil then self.ResetSights = CurTime() + 3 else
		self.ResetSights = CurTime() + self.Owner:GetViewModel():SequenceDuration() 
		end
	end
end

function SWEP:SecondaryAttack()
return false
end	

function SWEP:Think()
end

