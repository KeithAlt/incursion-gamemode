SWEP.ViewModel = "models/Teh_Maestro/popcorn.mdl"
SWEP.WorldModel = "models/Teh_Maestro/popcorn.mdl"
SWEP.Spawnable			= true
SWEP.AdminOnly			= false

SWEP.Author = "Antimony51"
SWEP.Instructions	= "Left Click: Eat Popcorn\nRight Click: Throw Bucket"

SWEP.Primary.Clipsize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.Clipsize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false
SWEP.Slot				= 1
SWEP.SlotPos			= 1
SWEP.HoldType 			= "shotgun"

function SWEP:Deploy()
end

function SWEP:Think()
    if (self.Owner.ChewScale or 0) > 0 then
		if SERVER then
			if (CurTime() >= self.Owner.BiteStart+0.625 and self.Owner.BitesRem > 0) then
				self.Owner.BiteStart = CurTime()
				self.Owner.BitesRem = self.Owner.BitesRem - 1
				net.Start("Popcorn_Eat")
					net.WriteEntity(self.Owner)
					net.WriteFloat(math.Round(math.Rand(4,8)+self.Owner.BitesRem*8))
				net.Broadcast()
			end
		end
        self.Owner.ChewScale = math.Clamp((self.Owner.ChewStart+self.Owner.ChewDur - CurTime())/self.Owner.ChewDur,0,1)
    end
end

function SWEP:Initialize()
	util.PrecacheSound("crisps/eat.wav")
end

function SWEP:PrimaryAttack()
	if SERVER then
        self.Owner:EmitSound( "crisps/eat.wav", 60)
		self.Owner.BiteStart = 0
		self.Owner.BitesRem = 3
		net.Start("Popcorn_Eat_Start")
			net.WriteEntity(self.Owner)
		net.Broadcast()
	end
	self.Owner.ChewScale = 1
	self.Owner.ChewStart = CurTime()
	self.Owner.ChewDur = SoundDuration("crisps/eat.wav")
	self.Weapon:SetNextPrimaryFire(CurTime() + 12 )
end

function SWEP:SecondaryAttack()
	local bucket, att, phys, tr

	self.Weapon:SetNextSecondaryFire(CurTime() + 16)
    
    if CLIENT then
        return
    end
    
    self.Owner:EmitSound( "weapons/slam/throw.wav" )
	
	self.Owner:ViewPunch( Angle( math.Rand(-8,8), math.Rand(-8,8), 0 ) )
	
    bucket = ents.Create( "sent_popcorn_thrown" )
    bucket:SetOwner( self.Owner )
    bucket:SetPos( self.Owner:GetShootPos( ) )
    bucket:Spawn() 
    bucket:Activate()
	
    phys = bucket:GetPhysicsObject( )
        
    if IsValid( phys ) then
		phys:SetVelocity( self.Owner:GetPhysicsObject():GetVelocity() )
		phys:AddVelocity( self.Owner:GetAimVector( ) * 128 * phys:GetMass( ) )
		phys:AddAngleVelocity( VectorRand() * 128 * phys:GetMass( ) )
    end
	
	--[[
	if !self.Owner:IsAdmin() then
		self.Owner:StripWeapon("weapon_popcorn")
	end
	--]]
end
