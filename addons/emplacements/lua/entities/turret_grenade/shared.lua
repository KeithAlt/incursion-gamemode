ENT.Type 			= "anim"
ENT.Base 			= "base_anim"

ENT.Category		= "Emplacements"
ENT.PrintName 		= "40MM HE Turret"
ENT.Author			= "Wolly/BOT_09"
ENT.Spawnable		= true
ENT.AdminSpawnable	= false

ENT.TurretFloatHeight=3
ENT.TurretModelOffset=Vector(0,0,44)
ENT.TurretTurnMax=0.7

ENT.LastShot=0
ENT.ShotInterval=0.7


function ENT:SetupDataTables()
	self:DTVar("Entity",0,"Shooter")
	self:DTVar("Entity",1,"ShootPos")
end

function ENT:SetShooter(plr)
	self.Shooter=plr
	self:SetDTEntity(0,plr)
end

function ENT:GetShooter(plr)
	if SERVER then
		return self.Shooter
	elseif CLIENT then
		return self:GetDTEntity(0)
	end
end


function ENT:Use(plr)
	
	if not self:ShooterStillValid() then
		self:SetShooter(plr)
		self:StartShooting()
		self.ShooterLast=plr
		
		
	else
		if plr==self.Shooter then
			self:SetShooter(nil)
			self:FinishShooting()
			
		end
	end
end


function ENT:ShooterStillValid()
	local shooter=nil
	if SERVER then
		shooter=self.Shooter
	elseif CLIENT then
		shooter=self:GetDTEntity(0)
	end
	
	return IsValid(shooter) and shooter:Alive() and ((self:GetPos()+self.TurretModelOffset):Distance(shooter:GetShootPos())<=90)
end



function ENT:DoShot()
	
	
	if self.LastShot+self.ShotInterval<CurTime() then
		if SERVER then
			
			local effectPosAng=self:GetAttachment(self.MuzzleAttachment)
			local vPoint = effectPosAng.Pos
			local effectdata = EffectData()
			effectdata:SetStart( vPoint )
			effectdata:SetOrigin( vPoint )
			effectdata:SetAngles(effectPosAng.Ang + Angle(0,-90,0))
			effectdata:SetEntity(self)
			effectdata:SetScale( 1 )
			util.Effect( "MuzzleEffect", effectdata )
			
		--elseif SERVER then
			self:EmitSound(self.ShotSound,50,100)
			
			
		end
		
		if IsValid(self.shootPos) and SERVER then

			local nade = ents.Create("turret_40mm_frag")
			local attachAng=self:GetAttachment(self.MuzzleAttachment)
			nade:SetPos(self.shootPos:GetPos())
			nade:SetAngles(self:GetAngles() + Angle(self:GetAngles().p,-90,0))
			nade:Spawn()
			nade:SetOwner(self.Shooter)
			nade.flightvector = self:GetRight() *35
			--self:GetPhysicsObject():ApplyForceCenter( self:GetRight()*-10000 )
			--[[local b = ents.Create( "info_target" )
			if (IsValid(b)) then
				b:SetPos( self.Shooter:GetEyeTrace( ).HitPos )
				b:Spawn( )
				--nade:Launch()
				nade:PointAtEntity( b )
				b:Remove( )
			end]]--
			
			
		end
		
		self.LastShot=CurTime()
	end
	
end



function ENT:Think()
	
	if not IsValid(self.turretBase) and SERVER then
		SafeRemoveEntity(self)
	else
		--[[if IsValid(self.shootPos) or self.shootPos==NULL then
			if CLIENT then
				
				self.shootPos=self:GetDTEntity(1)
			elseif SERVER then
				
				self:SetDTEntity(1,self.shootPos)
			end
		end]]
		if IsValid(self) then
			
			if SERVER then
				self.BasePos=self.turretBase:GetPos()
				self.OffsetPos=self.turretBase:GetAngles():Up()*1
			end
			
			if self:ShooterStillValid() then
			
				if SERVER then
					local offsetAng=(self:GetAttachment(self.MuzzleAttachment).Pos-self:GetDesiredShootPos()):GetNormal()
					local offsetDot=(self.turretBase:GetAngles():Right()*-1):DotProduct(offsetAng)
					local HookupPos=self:GetAttachment(self.HookupAttachment).Pos
					if offsetDot>=self.TurretTurnMax then
						local offsetAngNew=offsetAng:Angle()
						offsetAngNew:RotateAroundAxis(offsetAngNew:Up(),-90)
						
						self.OffsetAng=offsetAngNew
						
					end
				end
				
				local pressKey=IN_BULLRUSH
				if CLIENT and game.SinglePlayer() then
					pressKey=IN_ATTACK
					
				end
				
				self.Firing=self:GetShooter():KeyDown(pressKey)
				
			else
				self.Firing=false
				if SERVER then
					self.OffsetAng=self.turretBase:GetAngles()
					
					self:SetShooter(nil)
					self:FinishShooting()
				end
			end
			
			if self.Firing then
				self:DoShot()
			end
			self:NextThink(CurTime())
			return true
		end
	end
end	