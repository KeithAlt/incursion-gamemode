-- Variables that are used on both client and server
SWEP.Gun = ("weapon_minefrag") -- must be the name of your swep but NO CAPITALS!
if (GetConVar(SWEP.Gun.."_allowed")) != nil then
	if not (GetConVar(SWEP.Gun.."_allowed"):GetBool()) then SWEP.Base = "bobs_blacklisted" SWEP.PrintName = SWEP.Gun return end
end
SWEP.Category				= "Fallout Sweps - Explosive Weapons"
SWEP.Author				= ""
SWEP.Contact				= ""
SWEP.Purpose				= ""
SWEP.Instructions				= ""
SWEP.MuzzleAttachment			= "1" 	-- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.ShellEjectAttachment			= "2" 	-- Should be "2" for CSS models or "1" for hl2 models
SWEP.PrintName				= "Frag Mine"		-- Weapon name (Shown on HUD)	
SWEP.Slot				= 4				-- Slot in the weapon selection menu
SWEP.SlotPos				= 26			-- Position in the slot
SWEP.DrawAmmo				= true		-- Should draw the default HL2 ammo counter
SWEP.DrawWeaponInfoBox			= false		-- Should draw the weapon info box
SWEP.BounceWeaponIcon   		= 	false	-- Should the weapon icon bounce?
SWEP.DrawCrosshair			= false		-- set false if you want no crosshair
SWEP.Weight				= 2			-- rank relative ot other weapons. bigger is better
SWEP.AutoSwitchTo			= true		-- Auto switch to if we pick it up
SWEP.AutoSwitchFrom			= true		-- Auto switch from if you pick up a better weapon

-- normal melee melee2 fist knife smg ar2 pistol rpg physgun grenade shotgun crossbow slam passive 
-- you're mostly going to use ar2, smg, shotgun or pistol. rpg and ar2 make for good sniper rifles

SWEP.HoldType = "slam"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/v_slam.mdl"
SWEP.WorldModel = "models/halokiller38/fallout/weapons/mines/minefrag.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {
	["Bip01_L_Forearm"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Bip01_L_Hand"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["HandControlRotR"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["HandControlRotR1"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Detonator"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Slam_panel"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Bip01_L_Clavicle"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(30, 30, -30), angle = Angle(-180, 0, 0) },
	["HandControlRotGrandmaR"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Bip01_L_UpperArm"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Slam_base"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["HandControlRotParentR"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}
SWEP.Base				= "boh_gun_base"
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
SWEP.FiresUnderwater 		= true

SWEP.Primary.Sound			= Sound("")		-- Script that calls the primary fire sound
SWEP.Primary.RPM				= 10		-- This is in Rounds Per Minute
SWEP.Primary.ClipSize			= 1		-- Size of a clip
SWEP.Primary.DefaultClip		= 1		-- Bullets you start with
SWEP.Primary.KickUp				= 0		-- Maximum up recoil (rise)
SWEP.Primary.KickDown			= 0		-- Maximum down recoil (skeet)
SWEP.Primary.KickHorizontal		= 0		-- Maximum up recoil (stock)
SWEP.Primary.Automatic			= false		-- Automatic = true; Semi Auto = false
SWEP.Primary.Ammo			= "FragMine"				
-- pistol, 357, smg1, ar2, buckshot, slam, SniperPenetratedRound, AirboatGun
-- Pistol, buckshot, and slam always ricochet. Use AirboatGun for a metal peircing shotgun slug

SWEP.Primary.Round 			= ("weapon_minefrag")	--NAME OF ENTITY GOES HERE

SWEP.Secondary.IronFOV			= 0		-- How much you 'zoom' in. Less is more! 	

SWEP.Primary.NumShots	= 0		-- How many bullets to shoot per trigger pull
SWEP.Primary.Damage		= 0	-- Base damage per bullet
SWEP.Primary.Spread		= 0	-- Define from-the-hip accuracy (1 is terrible, .0001 is exact)
SWEP.Primary.IronAccuracy = 0 -- Ironsight accuracy, should be the same for shotguns
--none of this matters for IEDs and other ent-tossing sweps

-- Enter iron sight info and bone mod info below
SWEP.IronSightsPos = Vector(0, 0, 0)
SWEP.IronSightsAng = Vector(0, 0, 0)
SWEP.SightsPos = Vector(0, 0, 0)	-- These are the same as IronSightPos and IronSightAng
SWEP.SightsAng = Vector(0, 0, 0)	-- No, I don't know why
SWEP.RunSightsPos = Vector(0, 0, 0)
SWEP.RunSightsAng = Vector(0, 0, 0)

SWEP.VElements = {
	["mine"] = { type = "Model", model = "models/halokiller38/fallout/weapons/mines/minefrag.mdl", bone = "Bip01_R_Hand", rel = "", pos = Vector(7.074, 2.405, 1.266), angle = Angle(180, 38.566, 3.615), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["mine"] = { type = "Model", model = "models/halokiller38/fallout/weapons/mines/minefrag.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(6.682, 2.749, 0.504), angle = Angle(-6.685, -140.152, 180), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

function SWEP:PrimaryAttack()
	if self:CanPrimaryAttack() then	
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Weapon:SetNextPrimaryFire(CurTime()+1/(self.Primary.RPM/60))
	plant = self.Owner:GetViewModel():SequenceDuration()
	timer.Simple(plant, function() if not IsValid(self) then return end if IsValid(self.Owner) and IsValid(self.Weapon) then
		if self.Owner:Alive() and self.Owner:GetActiveWeapon():GetClass() == self.Gun then
			self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
				local tr = {}
				tr.start = self.Owner:GetShootPos()
				tr.endpos = self.Owner:GetShootPos() + 100 * self.Owner:GetAimVector()
				tr.filter = {self.Owner}
				local trace = util.TraceLine(tr)
				self:TakePrimaryAmmo(1)
				if (CLIENT) then return end
				proxy = ents.Create("m9k_frag")
				proxy:SetPos(trace.HitPos + trace.HitNormal)
				trace.HitNormal.z = -trace.HitNormal.z
				proxy:SetAngles(trace.HitNormal:Angle() - Angle(90, 180, 0))
				proxy.Owner = self.Owner
				proxy:Spawn()
			
			local boxes
			parentme = {}
			parentme[1] = "m9k_ammo_40mm"
			parentme[2] = "m9k_ammo_c4"
			parentme[3] = "m9k_ammo_frags"
			parentme[4] = "m9k_ammo_ieds"
			parentme[5] = "m9k_ammo_nervegas"
			parentme[6] = "m9k_ammo_nuke"
			parentme[7] = "m9k_ammo_proxmines"
			parentme[8] = "m9k_ammo_rockets"
			parentme[9] = "m9k_ammo_stickynades"
			parentme[10] = "m9k_ammo_357"
			parentme[11] = "m9k_ammo_ar2"
			parentme[12] = "m9k_ammo_buckshot"
			parentme[13] = "m9k_ammo_pistol"
			parentme[14] = "m9k_ammo_smg"
			parentme[15] = "m9k_ammo_sniper_rounds"
			parentme[16] = "m9k_ammo_winchester"
			parentme[17] = "m9k_ammo_fragmines"
			parentme[18] = "m9k_ammo_pulsemines"
			parentme[19] = "m9k_ammo_plasmamines"
			
				if trace.Entity != nil and trace.Entity:IsValid() then
					for k, v in pairs (parentme) do
						if trace.Entity:GetClass() == v then
							boxes = trace.Entity
						end
					end
				end
			
				if trace.Entity and trace.Entity:IsValid() then
					if trace.Entity and trace.Entity:IsValid() then
						if boxes and trace.Entity:GetPhysicsObject():IsValid() then
							proxy:SetParent(trace.Entity)
							trace.Entity.Planted = true
						elseif not trace.Entity:IsNPC() and not trace.Entity:IsPlayer() and trace.Entity:GetPhysicsObject():IsValid() then
							constraint.Weld(proxy, trace.Entity)
						end
					end
				else
					proxy:SetMoveType(MOVETYPE_NONE)
				end	
				if not trace.Hit then
					proxy:SetMoveType(MOVETYPE_VPHYSICS)
				end
			end
		self:CheckWeaponsAndAmmo()
		end end)
	end
end

function SWEP:CheckWeaponsAndAmmo()
	timer.Simple(self.Owner:GetViewModel():SequenceDuration(), function()
		if SERVER and IsValid(self.Weapon) then 
			if IsValid(self.Owner) and self.Weapon:GetClass() == self.Gun then
				if self.Weapon:Clip1() == 0 && self.Owner:GetAmmoCount( self.Weapon:GetPrimaryAmmoType() ) == 0 then
					self.Owner:StripWeapon(self.Gun)
				else
				self.Weapon:DefaultReload(ACT_VM_DRAW)
				end
			end
		end
	end)
end
		

function SWEP:SecondaryAttack()
end	
function SWEP:Think()
end
