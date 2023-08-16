SWEP.Base = "dangumeleebase"
SWEP.AdminSpawnable = true
SWEP.AutoSwitchTo = false
SWEP.Slot = 0
SWEP.PrintName = "Chance's Knife"
SWEP.Author = "Lenny"
SWEP.Spawnable = true
SWEP.AutoSwitchFrom = false
SWEP.Weight = 5
SWEP.Category = "Fallout SWEPs - Melee Weapons"
SWEP.SlotPos = 1
SWEP.ViewModelFOV = 95
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/models/danguyen/c_oren_katana.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.UseHands = true
SWEP.CanThrow = false
SWEP.CanThrow = false
SWEP.WepName = "weapon_chanceknife_len_m2"
--STAT RATING (1-6)
SWEP.Type = 1 --1: Blade, 2: Axe, 3:Bludgeon, 4: Spear
SWEP.Strength = 6 -- 1-2: Small Weapons, 3-4: Medium Weapons (e.g crowbar), 5-6: Heavy Weapons (e.g Sledgehammers and Greatswords). Strength affects throwing distance and force
SWEP.Speed = 6 -- 1-2: Slow, 3-4: Decent, 5-6: Fast
SWEP.Tier = 1 -- General rating based on how good/doodoo the weapon is
--SWEPs are dumb (or I am) so we must state the weapon name again
--Stamina Costs
SWEP.PriAtkStamina = 2
SWEP.ThrowStamina = 5
SWEP.BlockStamina = 0
SWEP.ShoveStamina = 1
--Primary Attack Charge Values
SWEP.Charge = 0
SWEP.ChargeSpeed = 0.5
SWEP.DmgMin = 85
SWEP.DmgMax = 130
SWEP.Delay = 0.4
SWEP.TimeToHit = 0.05
SWEP.Range = 100
SWEP.Punch1 = Angle( -5, 10, 0 )
SWEP.Punch2 = Angle( -5, 0, -3 )
SWEP.HitFX = "BloodImpact"
SWEP.HitFX2 = ""
SWEP.IdleAfter = true
--Throwing Attack Charge Values
SWEP.Charge2 = 2
SWEP.ChargeSpeed2 = 0.5
SWEP.DmgMin2 = 50
SWEP.DmgMax2 = 70
SWEP.ThrowModel = "models/weapons/kitchenknife/kitchenknife.mdl"
SWEP.ThrowMaterial = ""
SWEP.ThrowScale = 1
SWEP.ThrowForce = 5000
SWEP.FixedThrowAng = Angle( 0, 0, 90 )
SWEP.SpinAng = Vector( 0, 5, 0 )
--HOLDTYPES
SWEP.AttackHoldType = "knife"
SWEP.Attack2HoldType = "knife"
SWEP.ChargeHoldType = "grenade"
SWEP.IdleHoldType = "knife"
SWEP.BlockHoldType = "slam"
SWEP.ShoveHoldType = "fist"
SWEP.ThrowHoldType = "grenade"
--SOUNDS
SWEP.SwingSound = ""
SWEP.ThrowSound = "spearthrow.mp3"
SWEP.Hit1Sound = "physics/body/body_medium_impact_hard1.wav"
SWEP.Hit2Sound = "physics/body/body_medium_impact_hard2.wav"
SWEP.Hit3Sound = "physics/body/body_medium_impact_hard3.wav"
SWEP.Impact1Sound = "slash1.wav"
SWEP.Impact2Sound = "slash1.wav"

SWEP.ViewModelBoneMods = {
    ["RW_Weapon"] = {
        scale = Vector( 0.039, 0.039, 0.039 ),
        pos = Vector( 0, 0, 0 ),
        angle = Angle( 0, 0, 0 )
    }
}

SWEP.NextFireShove = 0
SWEP.NextFireBlock = 0
SWEP.NextStun = 0
SWEP.DefSwayScale = 1.0
SWEP.DefBobScale = 1.0
SWEP.StunPos = Vector( 0, 0, 0 )
SWEP.StunAng = Vector( -16.181, 0, 47.136 )
SWEP.ShovePos = Vector( -6.633, -0.403, -1.005 )
SWEP.ShoveAng = Vector( -3.518, 70, -70 )
SWEP.RollPos = Vector( 0, 0, 0 )
SWEP.RollAng = Vector( 0, 0, 0 )
SWEP.WhipPos = Vector( 0, -10.252, 0 )
SWEP.WhipAng = Vector( 70, 0, 0 )
SWEP.ThrowPos = Vector( -4.624, -3.217, -2.613 )
SWEP.ThrowAng = Vector( 0, -90, -90 )
SWEP.FanPos = Vector( 5.23, -10.051, -3.62 )
SWEP.FanAng = Vector( 80, 16.884, 90 )
SWEP.WallPos = Vector( 0, 0, 0 )
SWEP.WallAng = Vector( 0, 0, 0 )

function SWEP:AttackAnimation( )
    self.Weapon.AttackAnimRate = 1.1
    self.Owner:EmitSound( "slash1.wav" )
    self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
end

function SWEP:AttackAnimation2( )
    self.Weapon.AttackAnimRate = 1.6
    self.Punch1 = Angle( 0, -15, 0 )
    self.Weapon:SendWeaponAnim( ACT_VM_HITRIGHT )
    self.Owner:EmitSound( "slash1.wav" )
end

one = true
two = false
three = false

function SWEP:AttackAnimationCOMBO( )
    self.Weapon.AttackAnimRate = 1.6

    if one == true then
        self.Owner:EmitSound( "slash1.wav" )
        self.Punch1 = Angle( 0, -10, 0 )
        self.Weapon:SendWeaponAnim( ACT_VM_PULLBACK )
        one = false
        two = true
        three = false
    elseif two == true then
        self.Owner:EmitSound( "slash1.wav" )
        self.Punch1 = Angle( 5, 10, 0 )
        self.Weapon:SendWeaponAnim( ACT_VM_MISSLEFT )
        one = false
        two = false
        three = true
    elseif three == true then
        self.Owner:EmitSound( "slash1.wav" )
        self.Punch1 = Angle( 5, 10, 0 )
        self.Weapon:SendWeaponAnim( ACT_VM_PULLBACK_HIGH )
        one = true
        two = false
        three = false
    end
end

function SWEP:AttackAnimation3( )
    self.Weapon:SendWeaponAnim( ACT_VM_HITRIGHT )
end

SWEP.SiphonAmount = 10 -- How much to heal per attack.
function SWEP:AtkExtra( )
    local tr = util.TraceLine( {
        start = self.Owner:GetShootPos( ),
        endpos = self.Owner:GetShootPos( ) + self.Owner:GetAimVector( ) * self.Range,
        filter = self.Owner,
        mask = MASK_SHOT_HULL
    } )

    if ( not IsValid( tr.Entity ) ) then
        tr = util.TraceHull( {
            start = self.Owner:GetShootPos( ),
            endpos = self.Owner:GetShootPos( ) + self.Owner:GetAimVector( ) * self.Range,
            filter = self.Owner,
            mins = Vector( -1, -1, 0 ),
            maxs = Vector( 1, 1, 0 ),
            mask = MASK_SHOT_HULL
        } )
    end

    local ply = self.Owner
    local hit = false

    if ( IsValid( tr.Entity ) and ( tr.Entity:IsNPC( ) or tr.Entity:IsPlayer( ) ) ) then
        local hp = ply:Health( )
        if hp >= ply:GetMaxHealth( ) then return end
		if math.random(0,4) >= 2 then -- If more than 1 then heal, prevent spam healing to make someone in high dr unkillable.
			--if ( hp + self.SiphonAmount ) >= ply:GetMaxHealth( ) then
				local newhp = math.Clamp(hp + self.SiphonAmount, 0, ply:GetMaxHealth())
				ply:SetHealth( newhp )
			--else
			--	ply:SetHealth( ply:Health( ) + self.SiphonAmount )
				-- Add a message here if needed.
			--end
        end

        hit = true
    end
end

SWEP.VElements = {
    ["element_name"] = {
        type = "Model",
        model = "models/Halokiller38/fallout/weapons/Melee/chancesknife.mdl",
        bone = "RW_Weapon",
        rel = "",
        pos = Vector( 0.3, -0.19, -5.2 ),
        angle = Angle( 0, 180, 0 ),
        size = Vector( 1.15, 1.15, 1.15 ),
        color = Color( 255, 255, 255, 255 ),
        surpresslightning = false,
        material = "",
        skin = 0,
        bodygroup = { }
    }
}

SWEP.WElements = {
    ["element_name"] = {
        type = "Model",
        model = "models/Halokiller38/fallout/weapons/Melee/chancesknife.mdl",
        bone = "ValveBiped.Bip01_R_Hand",
        rel = "",
        pos = Vector( 2.8, 1.229, 4.18 ),
        angle = Angle( 180, -90.003, 0 ),
        size = Vector( 1, 1, 1 ),
        color = Color( 255, 255, 255, 255 ),
        surpresslightning = false,
        material = "",
        skin = 0,
        bodygroup = { }
    }
}