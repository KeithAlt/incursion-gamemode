
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "Guided Missle Blast"
ENT.Author = "Liam0102"
ENT.Category = "Halo"
ENT.Spawnable = false;
ENT.AdminSpawnable = false;
ENT.IsTorpedo = true;
if SERVER then
	AddCSLuaFile()
	function ENT:Initialize()
	
		self:SetModel("models/props_junk/PopCan01a.mdl");
		self:SetSolid(SOLID_VPHYSICS);
		self:SetMoveType(MOVETYPE_VPHYSICS);
		self:PhysicsInit(SOLID_VPHYSICS);
		self:StartMotionController();
		self:SetUseType(SIMPLE_USE);
		self:SetRenderMode(RENDERMODE_TRANSALPHA);
		self:SetColor(Color(255,255,255,1));
		self:StartMotionController();
		//self:SetCustomCollisionCheck(true)
		self:SetNWVector("Color",Vector(self.SpriteColour.r,self.SpriteColour.g,self.SpriteColour.b));

		self:SetNWInt("StartSize",self.StartSize or 20);
		self:SetNWInt("EndSize",self.EndSize or 15);
		
		self.Damage = self.Damage or 500;

		local phys = self:GetPhysicsObject();
		phys:SetMass(100);
		phys:EnableGravity(false);
		phys:Wake()
	end

    /*
	hook.Add("ShouldCollide","SW_TorpedoCollision", function(e1,e2)
		if((e1.IsTorpedo and e2.IsSWVehicle) or (e1.IsSWVehicle and e2.IsTorpedo)) then
			if(e1.IsTorpedo and e2 == e1.Shooter or e2.IsTorpedo and e1 == e2.Shooter) then
				return false;
			end	
		end
        return true;
	end);
	*/
    
	function ENT:PrepareTorpedo(e,s,vel)
		self.Shooter = e;
		e:EmitSound(s)
		self.Velocity = math.Clamp(vel,700,2000);
	end
	
	function ENT:Think()
		if(self.Targetting) then
			if(IsValid(self.Target)) then
				self:SetAngles((self.Target:GetPos() - self:GetPos()):Angle());	
			else
				self.Targetting = false;
			end		
		end
	end
	
	local FlightPhys = {
		secondstoarrive	= 1;
		maxangular		= 50000;
		maxangulardamp	= 10000000;
		maxspeed			= 1000000;
		maxspeeddamp		= 500000;
		dampfactor		= 0.8;
		teleportdistance	= 5000;
	};
	function ENT:PhysicsSimulate(phys,delta)

		local ang = self.Ang or self:GetForward():Angle();
		if(self.Targetting) then
			if(IsValid(self.Target)) then
				ang = (self.Target:GetPos() - self:GetPos()):Angle();	
			else
				self.Targetting = false;
			end		
		end
		FlightPhys.angle = ang;
		FlightPhys.pos = self:GetPos()+self:GetForward()*self.Velocity;
		FlightPhys.deltatime = delta;
		phys:ComputeShadowControl(FlightPhys);
	end
	
	function ENT:PhysicsCollide(data, physobj)
	
		if(IsValid(self.Shooter) and IsValid(data.HitEntity)) then
			if(data.HitEntity == self.Shooter) then
				return
			end
		end
	
		local pos = self:GetPos();
		local fx = EffectData()
			fx:SetOrigin(pos);
		util.Effect("HelicopterMegaBomb",fx,true,true);

		local e = data.HitEntity;
		if(IsValid(e) and e.IsSWVehicle) then
			if(self.Ion) then
				e.IonShots = 10;
			end
			e:TakeDamage(self.Damage);
		end
		self:Remove()
	end
	
end

if CLIENT then

	function ENT:Initialize()	
		self.FXEmitter = ParticleEmitter(self:GetPos())
	end
	
	function ENT:Draw()
		
		self:DrawModel();
		
		local normal = (self:GetForward() * -1):GetNormalized()
		local roll = math.Rand(-90,90)
		
		local StartSize = self:GetNWInt("StartSize");
		local EndSize = self:GetNWInt("EndSize");
		
		local sprite;
		local c = self:GetNWVector("Color");
		if(IsWhite) then
			sprite = "sprites/white_blast";
		else
			sprite = "sprites/bluecore";
		end

		local blue = self.FXEmitter:Add(sprite,self:GetPos())
		blue:SetVelocity(normal)
		blue:SetDieTime(0.05)
		blue:SetStartAlpha(255)
		blue:SetEndAlpha(255)
		blue:SetStartSize(StartSize)
		blue:SetEndSize(EndSize)
		blue:SetRoll(roll)
		blue:SetColor(c.x,c.y,c.z)
		
	end
end