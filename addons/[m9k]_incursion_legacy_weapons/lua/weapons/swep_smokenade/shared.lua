SWEP.Author		= "Draco_2k"
SWEP.Category		= "Smoke"
SWEP.Purpose		= "Covers an area in a thick layer of smoke."
SWEP.Instructions		= "Left-Click: Throw big grenade   Right-Click: Throw small grenade"
SWEP.Spawnable		= true
SWEP.AdminSpawnable	= false

SWEP.ViewModel			= "models/weapons/v_grenade.mdl"
SWEP.WorldModel			= "models/weapons/w_grenade.mdl"

SWEP.HoldType			= "grenade"
SWEP.Primary.Automatic		= false
SWEP.Primary.ClipSize		= 5
SWEP.Primary.DefaultClip		= 5
SWEP.Primary.Ammo		= "none"
SWEP.Secondary.ClipSize		= 5
SWEP.Secondary.DefaultClip		= 5
SWEP.Secondary.Automatic		= false
SWEP.Secondary.Ammo		= "none"


//Precache stuff
function SWEP:Precache()

//Grenade model
util.PrecacheModel("models/dav0r/hoverball.mdl")

//Throwing sounds
util.PrecacheSound("weapons/ar2/ar2_reload_rotate.wav")

//Grenade sounds
util.PrecacheSound("weapons/grenade/tick1.wav")
util.PrecacheSound("weapons/ar2/npc_ar2_altfire.wav")
util.PrecacheSound("weapons/ar2/ar2_altfire.wav")

end


//PRIMARY FIRE
function SWEP:PrimaryAttack()

self.Weapon:SetNextPrimaryFire(CurTime() + 1.21)
self.Weapon:SetNextSecondaryFire(CurTime() + 1.21)
self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
//self.Owner:SetAnimation(PLAYER_ATTACK2)

if (SERVER) then
timer.Simple(0.157, function() if self:IsValid() then self:ThrowBigGrenade() end end)
end

end


//SECONDARY FIRE
function SWEP:SecondaryAttack()

self.Weapon:SetNextPrimaryFire(CurTime() + 1.02)
self.Weapon:SetNextSecondaryFire(CurTime() + 1.02)
self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
//self.Owner:SetAnimation(PLAYER_ATTACK2)

if (SERVER) then
timer.Simple(0.157, function() if self:IsValid() then self:ThrowSmallGrenade() end end)
end

end


//Play a nice sound on deploying
function SWEP:Deploy()
self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
return true
end


//Grenade throw function (Big)
function SWEP:ThrowBigGrenade()

	//Safeguard
	if !self || !self.Owner then return end

	//Create grenade
	local grenadeobj = ents.Create("sent_smokenade")
	grenadeobj:SetPos( self.Owner:GetShootPos() + Vector(0,0,-9.2) )
	grenadeobj:SetAngles( self.Owner:GetAimVector():Angle() )
	grenadeobj:SetPhysicsAttacker(self.Owner)
	grenadeobj:SetOwner(self.Owner)
	grenadeobj:Spawn()

	//Throw it
	grenadeobj:GetPhysicsObject():ApplyForceCenter( self.Owner:GetAimVector() * math.random(4620,4820) + Vector(0, 0, math.random(100,120)) )

	//Play throwing sound
	self.Owner:EmitSound( "weapons/ar2/ar2_reload_rotate.wav", 40, 100 )

end


//Grenade throw function (Small)
function SWEP:ThrowSmallGrenade()

	//Safeguard
	if !self || !self.Owner then return end

	//Create grenade
	local grenadeobj = ents.Create("sent_smokenade_small")
	grenadeobj:SetPos( self.Owner:GetShootPos() + Vector(0,0,-9.2) )
	grenadeobj:SetAngles( self.Owner:GetAimVector():Angle() )
	grenadeobj:SetPhysicsAttacker(self.Owner)
	grenadeobj:SetOwner(self.Owner)
	grenadeobj:Spawn()

	//Throw it
	grenadeobj:GetPhysicsObject():ApplyForceCenter( self.Owner:GetAimVector() * math.random(4620,4820) + Vector(0, 0, math.random(100,120)) )

	//Play throwing sound
	self.Owner:EmitSound( "weapons/ar2/ar2_reload_rotate.wav", 40, 100 )

end