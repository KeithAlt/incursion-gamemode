
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.turretBaseModel="models/turret/mg_stand.mdl"

function ENT:CreateEmplacement()
	local turretBase=ents.Create("prop_physics")
	turretBase:SetModel(self.turretBaseModel)
	turretBase:SetAngles(self:GetAngles()+Angle(0,-90,0))
	turretBase:SetPos(self:GetPos()-Vector(0,0,0))
	turretBase:Spawn()
	self.turretBase=turretBase
	
	constraint.NoCollide(self.turretBase,self,0,0)
	
	local shootPos=ents.Create("prop_dynamic")
	shootPos:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	shootPos:SetAngles(self:GetAngles())
	shootPos:SetPos(self:GetPos()-Vector(0,0,0))
	shootPos:Spawn()
	shootPos:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self.shootPos=shootPos
	shootPos:SetParent(self)
    shootPos:Fire("setparentattachment","muzzle")
	shootPos:SetNoDraw(false)
	shootPos:DrawShadow(false)
	--shootPos:SetColor(Color(0,0,0,0))
	self:SetDTEntity(1,shootPos)
	
end


ENT.BasePos=Vector(0,0,0)
ENT.BaseAng=Angle(0,0,0)

ENT.OffsetPos=Vector(0,0,0)
ENT.OffsetAng=Angle(0,0,0)

ENT.Shooter=nil --player.GetHumans()[1]
ENT.ShooterLast=nil





function ENT:Initialize()
	
	self:SetModel("models/turret/mg_turret.mdl")
	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	
	local phys = self.Entity:GetPhysicsObject()
	
	if IsValid( phys ) then
	
		phys:Wake()
		phys:SetVelocity( Vector( 0, 0, 0 ) )
	end

	self.ShadowParams = {}
	
	self:StartMotionController()
	if not IsValid(self.turretBase) then
		self:CreateEmplacement()
	end
	self.ShotSound=Sound("hmg_heavy_turret")
	self:SetUseType(SIMPLE_USE)
	self.MuzzleAttachment=self:LookupAttachment("muzzle")
	self.HookupAttachment=self:LookupAttachment("hookup")
	self:DropToFloor()
	
	self.shootPos:SetRenderMode(RENDERMODE_TRANSCOLOR)
	self.shootPos:SetColor(Color(255,255,255,1))
	
	sound.Add(
	{
		name = "hmg_heavy_turret",
		channel = CHAN_WEAPON,
		volume = 0.7,
		soundlevel = "SNDLVL_GUNFIRE",
		pitchstart = 98,
		pitchend = 110,
		sound = "hturret/test.wav"
	})
	
end



function ENT:OnRemove()

	--> On remove fix!
	if self.Shooter != nil then

		net.Start("TurretBlockAttackToggle")
		net.WriteBit(false)
		net.Send(self.Shooter)
		self:SetShooter(nil)
		self:FinishShooting()
		self.Shooter=nil

	end
	
	SafeRemoveEntity(self.turretBase)
end

function ENT:StartShooting()
	self.Shooter:DrawViewModel(false)
	net.Start("TurretBlockAttackToggle")
	net.WriteBit(true)
	net.Send(self.Shooter)
end

function ENT:FinishShooting()
	if IsValid(self.ShooterLast) then
		self.ShooterLast:DrawViewModel(true)
		
		net.Start("TurretBlockAttackToggle")
		net.WriteBit(false)
		net.Send(self.ShooterLast)
		self.ShooterLast=nil
	end
end





function ENT:GetDesiredShootPos()
	local shootPos=self.Shooter:GetShootPos()
	local playerTrace=util.GetPlayerTrace( self.Shooter )
	playerTrace.filter={self.Shooter,self,self.turretBase}

	local shootTrace=util.TraceLine(playerTrace)
	return shootTrace.HitPos
end


function ENT:PhysicsSimulate( phys, deltatime )
	
	phys:Wake()
 
	self.ShadowParams.secondstoarrive = 0.01 
	self.ShadowParams.pos = self.BasePos + self.turretBase:GetUp()*42.2
	self.ShadowParams.angle =self.BaseAng+self.OffsetAng+Angle(0,0,0)
	self.ShadowParams.maxangular = 5000
	self.ShadowParams.maxangulardamp = 10000
	self.ShadowParams.maxspeed = 1000000 
	self.ShadowParams.maxspeeddamp = 10000
	self.ShadowParams.dampfactor = 0.8
	self.ShadowParams.teleportdistance = 200
	self.ShadowParams.deltatime = deltatime
 
	phys:ComputeShadowControl(self.ShadowParams)
	
 
end