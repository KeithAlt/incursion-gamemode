if( SERVER ) then
	AddCSLuaFile("shared.lua")
end

SWEP.Base				= "weapon_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel		= "models/zombie/arms/v_zombiearms.mdl"
SWEP.WorldModel		= ""
SWEP.ViewModelFOV 	= 50
SWEP.ViewModelFlip 	= false
SWEP.DrawCrosshair	= false

SWEP.Weight				= 1
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= false
SWEP.CSMuzzleFlashes	= false

SWEP.Primary 				= {}
SWEP.Primary.Damage			= 38
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 0.5
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Round 			= ("m9k_thrown_harpoon")

SWEP.Secondary 				= {}
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Delay		= 2
SWEP.Secondary.Damage		= 0
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.ReloadDelay	= 0
SWEP.AnimDelay		= 0
SWEP.AttackAnims	= {
	"fists_left",
	"fists_right"}

SWEP.PlayerModel	= nil
SWEP.WerewolfModel	= "models/player/keitho/madreghost.mdl"
SWEP.PlayerScale	= 1.0
SWEP.WerewolfScale	= 1.0 --Change the collision type of the werewolf

SWEP.HealthBonus	= 0
SWEP.HealAmount		= 1
SWEP.HealTimer		= 5
SWEP.HealId			= ""

SWEP.RunSpeed		= 300
SWEP.WalkSpeed		= 200
SWEP.SpeedModifier	= 1.3

SWEP.InfectChance	= 0.60
SWEP.InfectDuration	= 1 -- 5 x 12 = 60 seconds until infection turns to werewolfisms
SWEP.ToggleVFX		= false

SWEP.HitSound	= {
	"npc/zombie/claw_strike1.wav",
	"npc/zombie/claw_strike2.wav",
	"npc/zombie/claw_strike3.wav"}
SWEP.MissSound 	= {
	"weapons/iceaxe/iceaxe_swing1.wav",
	"npc/vort/claw_swing1.wav",
	"npc/vort/claw_swing2.wav"}
SWEP.FleshSound	= {
	"physics/flesh/flesh_squishy_impact_hard1.wav",
	"physics/flesh/flesh_squishy_impact_hard2.wav",
	"physics/flesh/flesh_squishy_impact_hard3.wav",
	"physics/flesh/flesh_squishy_impact_hard4.wav"}
SWEP.RoarSound	= {
	"ghost/gp-growl1.ogg",
	"ghost/gp-growl2.ogg",
	"ghost/gp-growl3.ogg"}
SWEP.AttackSound= {
	"ghost/gp-attack1.ogg",
	"ghost/gp-attack2.ogg",
	"ghost/gp-attack3.ogg",}
SWEP.SwingSound	= {
	"npc/zombie/claw_miss1.wav",
	"npc/zombie/claw_miss2.wav"}


if ( CLIENT ) then
	SWEP.PrintName	= "Ghost Infection"
	SWEP.Category	= "Claymore Gaming"
	SWEP.Author		= "Claymore Gaming"
	SWEP.Purpose	= "\nDamage: "..SWEP.Primary.Damage.." ("..(SWEP.Primary.Damage/SWEP.Primary.Delay).." DPS)\n\nReload: Transform to Ghoul\nHold E: Toggle Bloodvision\nRight-Click: Leap"
	SWEP.Slot		= 0
	SWEP.SlotPos	= 1
	SWEP.DrawAmmo	= false
end

function SWEP:Equip(owner)
	self:RegeneratingHealth(owner)
	timer.Simple(0.5, function()
		if !IsValid(self) then return end
		owner:SetActiveWeapon(self)
	end)
end

function SWEP:Deploy()
	self.Owner:falloutNotify("[ ! ]  You have contracted the Ghost Virus", "ui/addicteds.wav")
	self.Owner:ChatPrint("[ ! ]  You must obey any distinguishable Chimera Agents!")
	self.Owner:ChatPrint("	- Press 'R' to Transform, but choose the right moment")
	self.Owner:ChatPrint("	- Spread the Virus to other victims by attacking them")
	self.Owner:ChatPrint("	- Being killed at any point while Infected is not RDM")
	if game.MaxPlayers() < 2 then
		self.Owner:ChatPrint("Single Player Detected: Animations are unstable due to the game pausing, but SysTime() does not!")
		self.Owner:ChatPrint("Recommend running on server or playing in +2 Player mode, Local or Internet!")
	end
end

function SWEP:Holster()
	local owner = self.Owner
end

function SWEP:OnRemove()
	self:RemoveSelf()
	return true
end

function SWEP:OnDrop()
	self:RemoveSelf()
	return true
end

function SWEP:RemoveSelf()
	local owner = self.Owner
	if owner != nil then
		self:MorphToHuman()
	end

	if !SERVER then return end
	if timer.Exists(self.HealId) then timer.Remove( self.HealId ) return end
	self:Remove()
end

function SWEP:Reload()
	if self.ReloadDelay > CurTime() then return end
	if self.PlayerModel == nil then return end
	self.ReloadDelay = CurTime() + 4
	self.Weapon:SetNextPrimaryFire( CurTime() + 2.5 )
	self.Weapon:SetNextSecondaryFire( CurTime() + 2.5 )

	if game.MaxPlayers() < 2 then self.AnimDelay = CurTime() + 4
	else self.AnimDelay = SysTime() + 4 end

	local owner = self.Owner
	if !owner:IsValid() then return end
	if !owner:Alive() then return end

	if owner:GetModel() != self.WerewolfModel
	then self:MorphToWerewolf()
	end
end

function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )


	if game.MaxPlayers() < 2 then self.AnimDelay = CurTime() + 0.45
	else self.AnimDelay = SysTime() + 0.4 end

	local owner = self.Owner
	if !owner:IsValid() then return end
	if !owner:Alive() then return end
	if owner:GetModel() == self.PlayerModel then
		self:Reload()
		return
	end

end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	if game.MaxPlayers() < 2 then self.AnimDelay = CurTime() + self.Primary.Delay
	else self.AnimDelay = SysTime() + self.Primary.Delay end

	local owner = self.Owner
	if !owner:IsValid() then return end
	if !owner:Alive() then return end
	if owner:GetModel() == self.PlayerModel then return end

	self:PrimaryAttackWerewolf(owner)
end

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

function SWEP:MorphToWerewolf()
	local owner = self.Owner
	if self.PlayerModel == nil then return end
	if owner:GetModel() == self.WerewolfModel then return end
	owner:SetModelScale( self.WerewolfScale, 3 )
	owner:SetModel( self.WerewolfModel )
	owner:EmitSound("ghost/gp-transform.ogg")

	if self.WerewolfScale > 1 then owner:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )
	else owner:SetCollisionGroup( COLLISION_GROUP_NONE ) end

	self:Roar( owner )

	if !owner:IsValid() then return end
	if !owner:Alive() then return end
	self:SetHoldType( "knife" )
	self:SendWeaponAnim(ACT_HL2MP_IDLE_KNIFE)

	self.Owner:EmitSound("eoti_idlegrowlloop", 350, math.random(23,40))

	self.Owner:SetRunSpeed(math.Clamp(self.RunSpeed*self.SpeedModifier, 450, 1000))
	self.Owner:SetWalkSpeed(math.Clamp(self.WalkSpeed*self.SpeedModifier, 375, 1000))

	self.ToggleVFX = false

	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "fists_draw" ) )
end

function SWEP:MorphToHuman()
	local owner = self.Owner
	if !IsValid(owner) or (owner:GetModel() and owner:GetModel() == self.PlayerModel) then return end

	owner:SetModelScale( self.PlayerScale, 3 )
	if self.PlayerModel != nil then owner:SetModel( self.PlayerModel ) end
	self:Roar( owner )

	if self.PlayerScale > 1 then owner:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )
	else owner:SetCollisionGroup( COLLISION_GROUP_NONE ) end

	owner:SetRunSpeed(self.WalkSpeed)
	owner:SetWalkSpeed(self.RunSpeed)

	if !owner:IsValid() then return end
	if !owner:Alive() then return end
	self:SetHoldType( "normal" )
	self:SendWeaponAnim(ACT_HL2MP_IDLE_KNIFE)

	owner:StopSound("eoti_idlegrowlloop")

	self.ToggleVFX = false

end

function SWEP:Roar(owner)
	timer.Simple(0.15, function()
		if !owner:IsValid() then return end
		if !owner:Alive() then return end
		if SERVER and not CLIENT then
			owner:DoAnimationEvent(ACT_GMOD_GESTURE_TAUNT_ZOMBIE)
			owner:EmitSound(table.Random(self.RoarSound), 100,math.random(75,95))
		end
	end)
end

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

function SWEP:RegeneratingHealth(owner)
	local hp, maxhp

	self.HealId  = math.random(165, 73623)
	self.HealId = "WEAPON_INFECT_FLD"..self.HealId..owner:Name()

	timer.Create(self.HealId , self.HealTimer, 0, function()
		if !SERVER
		or !self:IsValid()
		or !timer.Exists( self.HealId )
		then return end

		hp = owner:Health()
		maxhp = (owner:GetMaxHealth() + self.HealthBonus or 100 + self.HealthBonus)
		if maxhp < hp then return end
		owner:SetHealth(math.Clamp( hp + self.HealAmount, 0, maxhp ))
	end)
end

function SWEP:PrimaryAttackWerewolf(owner)
	local tr, trace, vm, anim

	--------------------------
	vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "fists_idle_01" ) )

	anim = self.AttackAnims[ math.random( 1, 2 ) ]

	timer.Simple( 0, function()
		if ( !IsValid( self ) || !IsValid( self.Owner ) || !self.Owner:GetActiveWeapon() || self.Owner:GetActiveWeapon() != self ) then return end

		vm = self.Owner:GetViewModel()
		vm:ResetSequence( vm:LookupSequence( anim ) )
	end )

	owner:DoAnimationEvent(ACT_GMOD_GESTURE_RANGE_FRENZY)
	if SERVER then
		owner:EmitSound(table.Random(self.SwingSound))
		owner:EmitSound(table.Random(self.AttackSound), 60)
	end

	------------------------

	tr = {}
	tr.start = owner:GetShootPos()
	tr.endpos = owner:GetShootPos() + ( owner:GetAimVector() * 95 )
	tr.filter = owner
	tr.mask = MASK_SHOT
	trace = util.TraceLine( tr )

	if ( trace.Hit ) then

		if trace.Entity:IsPlayer()
		or string.find(trace.Entity:GetClass(),"npc")
		or string.find(trace.Entity:GetClass(),"prop_ragdoll") then
			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
			bullet = {}
			bullet.Num    = 1
			bullet.Src    = owner:GetShootPos()
			bullet.Dir    = owner:GetAimVector()
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 0
			bullet.Force  = 1
			bullet.Damage = self.Primary.Damage
			owner:FireBullets(bullet)
			self:Infection(trace.Entity)
			self.Weapon:EmitSound(table.Random(self.FleshSound),75)
		else
			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
			bullet = {}
			bullet.Num    = 1
			bullet.Src    = owner:GetShootPos()
			bullet.Dir    = owner:GetAimVector()
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 0
			bullet.Force  = 1
			bullet.Damage = self.Primary.Damage
			owner:FireBullets(bullet)
			util.Decal("ManhackCut", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal)
			self.Weapon:EmitSound(table.Random(self.HitSound),75)
		end
	else
		self.Weapon:EmitSound(table.Random(self.MissSound),75)
	end

	timer.Simple( 0.06, function() owner:ViewPunch( Angle( -2, -2,  0 ) ) end )
	timer.Simple( 0.23, function() owner:ViewPunch( Angle(  3,  1,  0 ) ) end )
end

function SWEP:Infection(dmg)
	if !(math.random(0.01,1.00) >= self.InfectChance) then return end
	if !dmg:IsValid() then return end
	if !dmg:IsPlayer() then return end
	if !dmg:Alive() then return end
	if dmg:HasWeapon(self:GetClass()) then return end

	local id, step, cnt, rgb
	id = "WerewolfInfectionTimer_"..dmg:Name()
	step = math.floor(230/self.InfectDuration)
	if timer.Exists(id) then return end

	cnt = 0
	dmg:SetRenderMode( RENDERMODE_TRANSALPHA )
	if SERVER then dmg:ChatPrint("You have been infected by a Ghost, you will turn in "..(self.InfectDuration*5).." seconds.") end
	dmg:EmitSound("eoti_idlegrowlloop", 350, math.random(23,40))

	timer.Create(id, 0.3, self.InfectDuration, function()
		if !self:IsValid()
		or !dmg:IsValid()
		or !dmg:IsPlayer()
		or !dmg:Alive()
		or dmg:HasWeapon(self:GetClass())
		or !timer.Exists(id)
		then
			dmg:SetColor( Color(255,255,255) )
			dmg:SetRenderMode( RENDERMODE_NORMAL )
			timer.Destroy(id)
			return false
		end

		rgb = 255 - (cnt * step)
		cnt = cnt + 1
		dmg:SetColor( Color(rgb,rgb,rgb) )

		if cnt < self.InfectDuration then return end
		if not SERVER and CLIENT then return end

		dmg:StopSound("eoti_idlegrowlloop")
		dmg:Give(self:GetClass())
		dmg:SetColor( Color(255,255,255) )
		dmg:SetRenderMode( RENDERMODE_NORMAL )
		timer.Destroy(id)
		return true
	end)
end

function SWEP:Think()
	local t
	if game.MaxPlayers() < 2 then t = CurTime()
	else t = SysTime() end
	if self.AnimDelay > t then return true end

	local owner, primary
	owner = self.Owner
	primary = (self:GetNextPrimaryFire() - CurTime())

	if self.PlayerModel == nil then
		self.PlayerModel = ""..self.Owner:GetModel()
		self.PlayerScale = self.Owner:GetModelScale() or 1
		self.WalkSpeed = owner:GetWalkSpeed()
		self.RunSpeed = owner:GetRunSpeed()
		return true
	elseif owner:KeyDown(IN_USE) then
		pos = self.Owner:GetShootPos()
		if self.CoolDown then return end

		if SERVER then
			pos = self.Owner:GetShootPos()

			local rocket = ents.Create("ent_halo_combatknife")
			if !rocket:IsValid() then return false end
			self.Owner:SetAnimation( PLAYER_ATTACK1 )
			self.Owner:ChatPrint("Your harpoon will regenerate in 10 seconds.")
			rocket:SetAngles(self.Owner:GetAimVector():Angle())
			rocket:SetPos(pos)
			rocket:SetOwner(self.Owner)
			rocket:Spawn()
			rocket.Owner = self.Owner
			rocket:Activate()

			eyes = self.Owner:EyeAngles()

			local phys = rocket:GetPhysicsObject()
			phys:SetVelocity(self.Owner:GetAimVector() * 2000)
			owner:EmitSound(table.Random(self.RoarSound), 100,math.random(100,100))
			owner:EmitSound(table.Random(self.RoarSound), 100,math.random(100,100))

			self.CoolDown = true

			timer.Simple(10, function()
				self.Owner:ChatPrint("Your harpoon has regenerated.")
				self.CoolDown = nil
			end)

			elseif owner:GetModel() == self.PlayerModel then
				owner:SetRunSpeed(self.RunSpeed)
				owner:SetWalkSpeed(self.WalkSpeed)
				self.AnimDelay = t + 0.45
				return true
			elseif owner:KeyDown(IN_FORWARD) and !owner:KeyDown(IN_DUCK) then
				owner:SetRunSpeed(math.Clamp(self.RunSpeed*self.SpeedModifier, 450, 1000))
				owner:SetWalkSpeed(math.Clamp(self.WalkSpeed*self.SpeedModifier, 375, 1000))
				owner:DoAnimationEvent(ACT_HL2MP_RUN_FAST)
				self.AnimDelay = t + 0.60
				return true
			elseif t + primary > t then
				self.AnimDelay = primary + 0.05
				return true
			end
	end
	self.AnimDelay = t + 0.5
end
