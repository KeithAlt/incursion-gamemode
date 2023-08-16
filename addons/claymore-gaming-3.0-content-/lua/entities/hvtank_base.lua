ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Base = "base_anim"
ENT.Type = "vehicle"

ENT.PrintName = "Hover Base"
ENT.Author = "Liam0102"
ENT.Category = "Others"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false;
ENT.AdminSpawnable = false;
ENT.IsSWVehicle = true;
ENT._IsSpeederVehicle = true;

local classes = {
	"chimera_tank",
}
function IsSWSpeeder(class)

	for k,v in pairs(classes) do
		if(v == class) then
			return true;
		end
	end
	return false;

end
if SERVER then
function HVTANKCreateBulletStructure(dmg,color,nosplashdamage)

    local noion = false;
    if(color == "blue_noion") then
        color = "blue";
        noion = true;
    end

	local bullet = {
		Spread		= Vector(0.001,0.001,0),
		Damage		= dmg*1.25,
		Force		= dmg,
		TracerName	= color .. "_tracer_fx",
		Callback = function(p,tr,damage)
			local self = damage:GetInflictor():GetParent();

			util.Decal( "fadingscorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal );
			local fx = EffectData()
				fx:SetOrigin(tr.HitPos);
				fx:SetNormal(tr.HitNormal);
			util.Effect( "StunstickImpact", fx, true )

			if(Should_HeliDamage) then
				local e = tr.Entity;
				if(e:GetClass() == "npc_helicopter" or e:GetClass() == "npc_combinegunship") then
					local health = e:Health();
					local new_health = health - dmg;
					if(new_health <= 0) then
						e:Input("SelfDestruct")
					else
						e:SetHealth(health - dmg);
					end
				end
			end
			if(IsValid(self) and self != tr.Entity) then
				if(!nosplashdamage) then
					util.BlastDamage( self, self.Pilot or self, tr.HitPos, dmg*1.5, dmg*0.66)
				end

				if(color == "blue" and !noion) then
					if(tr.Entity.IsSWVehicle) then
						tr.Entity.IonShots = tr.Entity.IonShots + 1;
					end
				end
			end
		end
	}
	return bullet;
end
ENT.NextUse = {Use = CurTime(),Fire = CurTime(),FireBlast=CurTime(),Engine=CurTime(),Boost=CurTime(),};
ENT.FireSound = Sound("weapons/xwing_shoot.wav");
ENT.StartHover = 100;

AddCSLuaFile();

function ENT:Initialize()

	self:SetModel(self.EntModel);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	self:StartMotionController();
	self:SetUseType(SIMPLE_USE);
	self:SetRenderMode(RENDERMODE_TRANSALPHA);
	self.Hover = true;

	self:SetNWInt("Health",self.StartHealth);
	self.HoverAmount = 100;

	self.Accel={
		FWD=0,
		RIGHT=0,
		UP=0,
	};

	self.ShouldStandby = true;
	self.EngineOn = true;

	self.UseGroundTraces = false;
	self.StandbyHoverMod = 1;
	self.StandbyHover = 0;

	if(!self.SpeederClass) then
		self.SpeederClass = 1;
	end

	local phys = self:GetPhysicsObject()

	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(100000)
	end
end

ENT.Flashlight = {};
function ENT:CreateFlashlight()

    local i = 1;
    for k,v in pairs(self.Flashlights) do
        self.Flashlight[i] = ents.Create( "env_projectedtexture" )
        self.Flashlight[i]:SetParent(self)

        self.Flashlight[i]:SetLocalPos(v[1])
        self.Flashlight[i]:SetLocalAngles(v[2])

        self.Flashlight[i]:SetKeyValue( "enableshadows", 1 )
        self.Flashlight[i]:SetKeyValue( "farz", self.FlashlightDistance or 1000 )
        self.Flashlight[i]:SetKeyValue( "nearz", 12 )
        self.Flashlight[i]:SetKeyValue( "lightfov", 60 )

        local c = Color(255,255,255);
        local b = 0.7;
        self.Flashlight[i]:SetKeyValue( "lightcolor", Format( "%i %i %i 255", c.r * b, c.g * b, c.b * b ) )
        self.Flashlight[i]:Spawn()
        self.Flashlight[i]:Input( "SpotlightTexture", NULL, NULL, "effects/flashlight001" )
        i = i+1;
    end
    self.FlashlightOn = true;
end

function ENT:RemoveFlashlight()

   if(IsValid(self.Flashlight[1])) then
        for k,v in pairs(self.Flashlight) do
            v:Remove();

        end
        table.Empty(self.Flashlight);
    end
    self.FlashlightOn = false;
end

function ENT:SpeederClassing()
	local mod = 1;
	if(self.SpeederClass == 2) or (self.SpeederClass == 3) then
		//Probes
		local fs = self.ForwardSpeed;

		if(fs < 0) then
			fs = fs * -1;
			mod = -1;
		end
		if(fs > 500) then
			self.ForwardSpeed = 400*mod;
		end

		local ms = self.BoostSpeed;
		if(ms < 0) then ms = ms*-1 end;
		if(ms > fs * 1.5) then
			self.BoostSpeed = (fs * 1.5)*mod;
		end
	end
end


function ENT:TestLoc(pos)

	local e = ents.Create("prop_physics");
	e:SetPos(pos);
	e:SetModel("models/Boba_Fett/props/orb.mdl");
	e:Spawn();
	e:Activate();
	e:SetParent(self);

end


function ENT:OnRemove()

	if(self.Inflight and not self.Destroyed) then
		if(IsValid(self.Pilot)) then
			self:Exit(true,false);
		end
		if(IsValid(self.Passenger)) then
			self:Exit(false,false);
		end
	end
end

ENT.DriverFPV = false;
ENT.PassengerFPV = false;
function ENT:Enter(p,driver)
	self:SetNWInt("MaxSpeed",self.BoostSpeed);
	p:SetNWInt("SW_Speeder_MaxSpeed",self.BoostSpeed)
	self:SpeederClassing();
	if(self.NextUse.Use < CurTime()) then
		p:SetNWEntity(self.Vehicle,self);
		p:SetNetworkedBool("Flying"..self.Vehicle,true);

		if(driver) then
			p:EnterVehicle(self.DriverChair);
            self.DriverChair:SetThirdPersonMode(self.DriverFPV);
			self:SetNWBool("Flying" .. self.Vehicle,true);
			self.Pilot = p;
			p:SetNWEntity("DriverSeat",self.DriverChair);
			self.Inflight = true;
			self:Rotorwash(true);
			self:GetPhysicsObject():Wake();
			self:GetPhysicsObject():EnableMotion(true);
			self:StartMotionController()
		else
            if(IsValid(self.PassengerChair)) then
                p:EnterVehicle(self.PassengerChair);
                self.DriverChair:SetThirdPersonMode(self.PassengerFPV);
                self.Passenger = p;
                p:SetNWEntity("PassengerSeat",self.PassengerChair);
            end
		end

		self.NextUse.Use = CurTime()+1;
	end
end

function ENT:Exit(driver,kill)
	if(driver) then
		if(IsValid(self.Pilot)) then
			self.Pilot:SetNetworkedBool("Flying"..self.Vehicle,false);
			self.Pilot:SetNWEntity(self.Vehicle,NULL);
			self.Pilot:SetNWEntity("DriverSeat",NULL);
			if(self.ExitModifier) then
				self.Pilot:SetPos(self:GetPos() + self:GetRight() * self.ExitModifier.x + self:GetForward() * self.ExitModifier.y + self:GetUp() * self.ExitModifier.z);
			else
				self.Pilot:SetPos((self:GetPos()+self:GetUp()*20+self:GetForward()*5+self:GetRight()*-85) or self.ExitPos);
			end
			if (kill) then self.Pilot:Kill(); end
            self.DriverFPV = self.DriverChair:GetThirdPersonMode();
            self.DriverChair:SetThirdPersonMode(false);
            self.Pilot:ExitVehicle(self.DriverChair);
		end
		self.num = 0;
		self.Accel.FWD = 0;
		self.Pilot = NULL;
		self.Inflight = false;
		self:Rotorwash(false);
		self:SetNWEntity(self.Vehicle,nil);
		self:SetNWBool("Flying" .. self.Vehicle,false);

		self.Accel.FWD = 0;
	else
		if(IsValid(self.Passenger)) then
			self.Passenger:SetNWBool("Flying"..self.Vehicle,false);
			self.Passenger:SetNWEntity(self.Vehicle,NULL)
			self.Passenger:SetNWEntity("PassengerSeat",NULL);
			if(self.ExitModifier) then
				self.Passenger:SetPos(self:GetPos() + self:GetRight() * -self.ExitModifier.x + self:GetForward() * self.ExitModifier.y + self:GetUp() * self.ExitModifier.z);
			else
				self.Passenger:SetPos((self:GetPos()+self:GetUp()*20+self:GetForward()*5+self:GetRight()*-85) or self.ExitPos);
			end
			if(kill) then self.Passenger:Kill() end;
            self.PassengerFPV = self.PassengerChair:GetThirdPersonMode();
            self.PassengerChair:SetThirdPersonMode(false);
		end
		self.Passenger = NULL;
	end
	self.NextUse.Use = CurTime() + 1;
end



function ENT:Think()
	if(IsValid(self.Passenger)) then
		if(self.Passenger:GetVehicle() != self.PassengerChair) then
			self:Exit(false,false);
		end
	end
	if(self.Inflight) then

		if(IsValid(self.Pilot)) then
			if(self.Pilot:GetVehicle() != self.DriverChair) then
				self:Exit(true,false);
			end
		end



		if(IsValid(self.Pilot)) then
			if(self.Pilot:KeyDown(IN_USE)) then
				if(self.NextUse.Use < CurTime()) then
					self:Exit(true,false);
				end
			end

            if(self.Pilot:KeyDown(IN_RELOAD) and self.HasFlashlight) then
                if(self.FlashlightOn) then
                    self:RemoveFlashlight();
                else
                    self:CreateFlashlight();
                end
            end

			if(self.Pilot:KeyDown(IN_SPEED) and self.SpeederClass == 1) then
				self:Boost();
			end

			if(self.CanShoot) then
				if(self.Pilot:KeyDown(IN_ATTACK)) then
					self:FireWeapons();
				end
			end

			/*
			if(self.Pilot:KeyDown(IN_RELOAD)) then
				self.EngineOn = false;
			else
				self.EngineOn = true;
			end
			*/
		end

		if(self.Boosting and self.BoostTimer < CurTime()) then
			self.Boosting = false;
		end
	end

end

function ENT:Use(p)

	if(not self.Inflight) then
		if(p:KeyDown(IN_WALK)) then
			if(IsValid(self.PassengerChair)) then
				self:Enter(p,false);
			end
		else
			self:Enter(p,true);
		end
	else
		if(not IsValid(self.Passenger)) then
			self:Enter(p,false);
		end
	end

end

hook.Add("PlayerEnteredVehicle","SWSpeederUse", function(p, e)
	if(IsValid(e) and IsValid(p) and p:IsPlayer()) then
		local speeder = e:GetParent();
		if(IsValid(speeder) and speeder.IsSWVehicle) then
			if(e.IsspeederChair) then
				if(!IsValid(speeder.Pilot) and !speeder.Inflight) then
					speeder:Enter(p,true);
				end
			elseif(e.speederPassenger) then
				if(!IsValid(speeder.Passenger)) then
					speeder:Enter(p,false);
				end
			end
		end
	end
end);

function ENT:SpawnChairs(pos,ang,pass,pos2,ang2,pod)

	local e = ents.Create("prop_vehicle_prisoner_pod");
	e:SetPos(pos);
	e:SetAngles(ang);
	e:SetParent(self);
	if(!pod) then
		e:SetModel("models/nova/airboat_seat.mdl");
	else
		e:SetModel("models/vehicles/prisoner_pod_inner.mdl");
	end
	e:SetRenderMode(RENDERMODE_TRANSALPHA);
	e:SetColor(Color(255,255,255,0));
	e:Spawn();
	e:Activate();
	e:GetPhysicsObject():EnableMotion(false);
	e:GetPhysicsObject():EnableCollisions(false);
	if(self.SeatClass) then
		e:SetVehicleClass(self.SeatClass);
	end
	e:SetUseType(USE_OFF);
	e.DrivingAnimType = 2;
	e.IsSpeederChair = true;
	self.DriverChair = e;


	if(pass) then
		local e = ents.Create("prop_vehicle_prisoner_pod");
		e:SetPos(pos2);
		e:SetAngles(ang2);
		e:SetParent(self);
		e:SetModel("models/nova/airboat_seat.mdl");
		e:SetUseType(USE_OFF);
		e:SetRenderMode(RENDERMODE_TRANSALPHA);
		e:SetColor(Color(255,255,255,0));
		e:Spawn();
		e:Activate();
		e:GetPhysicsObject():EnableMotion(false);
		e:GetPhysicsObject():EnableCollisions(false);
		self.PassengerChair = e;
		e.SpeederPassenger = true;
	end
end

function ENT:SpawnWeapons()
	self.Weapons = {};
	for k,v in pairs(self.WeaponLocations) do
		local e = ents.Create("prop_physics");
		e:SetModel("models/props_junk/PopCan01a.mdl");
		e:SetPos(v);
		e:Spawn();
		e:Activate();
		e:SetRenderMode(RENDERMODE_TRANSALPHA);
		e:SetSolid(SOLID_NONE);
		e:GetPhysicsObject():EnableCollisions(false);
		e:GetPhysicsObject():EnableMotion(false);
		e:AddFlags(FL_DONTTOUCH);
		e:SetColor(Color(255,255,255,0));
		e:SetParent(self);
		self.Weapons[k] = e;
	end

end

ENT.BoostTimer = CurTime();
function ENT:Boost()

	if(self.NextUse.Boost < CurTime()) then
		self.Accel.FWD = self.BoostSpeed;
		self.Boosting = true;
		self:EmitSound(Sound("vehicles/speeder_boost4.wav"),85,100,1,CHAN_VOICE)
		self.BoostTimer = CurTime()+5;
		self.NextUse.Boost = CurTime() + 10;
	end
end

function ENT:FireWeapons()

	if(self.NextUse.Fire < CurTime()) then
		for k,v in pairs(self.Weapons) do

			local tr = util.TraceLine({
				start = self:GetPos(),
				endpos = self:GetPos()+self.Pilot:GetAimVector():Angle():Forward()*10000,
				filter = {self},
			})

			local angPos = (tr.HitPos - v:GetPos())

			self.Bullet.Src		= v:GetPos();
			self.Bullet.Attacker = self.Pilot or self;
			self.Bullet.Dir = angPos;

			v:FireBullets(self.Bullet)
		end
		self:EmitSound(self.FireSound, 120, math.random(90,110));
		self.NextUse.Fire = CurTime() + (self.FireDelay or 0.3);
	end
end

function ENT:FireBlast(pos,gravity,vel,ang)
	if(self.NextUse.FireBlast < CurTime()) then
		local e = ents.Create("cannon_blast");
		e:SetPos(pos);
		e:Spawn();
		e:Activate();
		e:Prepare(self,Sound("weapons/n1_cannon.wav"),gravity,vel,ang);
		e:SetColor(Color(255,255,255,1));

		self.NextUse.FireBlast = CurTime() + 3;
	end

end


function ENT:RunTraces()
	self.FrontTrace = util.TraceLine({
		start = self.FrontPos,
		endpos = self.FrontPos + self:GetUp()*-10000,
		filter = {self,self.DriverChair,self.PassengerChair},
		mask = MASK_SOLID,
	});

	self.BackTrace = util.TraceLine({
		start = self.BackPos,
		endpos = self.BackPos + self:GetUp()*-10000,
		filter = {self,self.DriverChair,self.PassengerChair},
		mask = MASK_SOLID,
	});

	self.MiddleTrace = util.TraceLine({
		start = self.MiddlePos,
		endpos = self.MiddlePos + self:GetUp()*-10000,
		filter = {self,self.DriverChair,self.PassengerChair},
		mask = MASK_SOLID,
	});

	self.WaterTrace = util.TraceLine({
		start = self.FrontPos,
		endpos = self.FrontPos + self:GetUp()*-10000,
		filter = {self,self.DriverChair,self.PassengerChair},
		mask = MASK_WATER,
	});

end

local FlightPhys={
	secondstoarrive	= 0.5;
	maxangular		= 50000;
	maxangulardamp	= 100000;
	maxspeed			= 1000000;
	maxspeeddamp		= 500000;
	dampfactor		= 1;
	teleportdistance	= 5000;
};
local ZAxis = Vector(0,0,1);
ENT.Roll = 0;
ENT.YawAccel = 0;
ENT.num = 0;
function ENT:PhysicsSimulate( phys, deltatime )
	//if(IsValid(self.Pilot) and self.Pilot:KeyDown(IN_WALK)) then return end;
	local UP = ZAxis;
	local RIGHT = self.RightDir;
	local FWD = self.FWDDir;
	local worldZ;
	self:RunTraces();

	if(!self.Tractored) then
		if(self.Inflight and IsValid(self.Pilot)) then
			/*
			local h = ((self.FrontTrace.HitPos.z - self:GetPos().z) + (self.MiddleTrace.HitPos.z - self:GetPos().z) + (self.BackTrace.HitPos.z - self:GetPos().z)) / 3;
			if(h < -500) then
				return
			end
			*/

			if(self.EngineOn) then
				-- Accelerate

				if(self.Boosting) then
					self.num = self.BoostSpeed;
					util.ScreenShake(self.DriverChair:GetPos(),5,60,0.1,100)
				elseif(self.Pilot:KeyDown(IN_FORWARD)) then
					self.num = self.ForwardSpeed;
				elseif(self.Pilot:KeyDown(IN_BACK)) then
					self.num = -self.ForwardSpeed;
				elseif(self.Pilot:KeyDown(IN_FORWARD) and self.Pilot:KeyDown(IN_SPEED) and self.SpeederClass == 2) then
					self.num = self.BoostSpeed;
                else
                    self.num = 0;
				end
				self.Accel.FWD =  math.Approach(self.Accel.FWD,self.num,self.AccelSpeed);

				self:SetNWInt("Speed",self.Accel.FWD);
				if(IsValid(self.Pilot)) then
					self.Pilot:SetNWInt("SW_Speeder_Speed",self.Accel.FWD);
				end

				phys:Wake();

				local saveangle = self.Pilot:GetAimVector():Angle()
	            local aim = saveangle;
				local ang = Angle(0,aim.y,0);
				ang = ang + self.ExtraRoll;
				if(!self.WaterTrace.Hit and self.UseGroundTraces) then
					ang = ang + (self.PitchMod or Angle(0,0,0));
				end

				worldZ = self:GetHover();

				if(!self.CriticalDamage) then
					FlightPhys.angle = ang; --+ Vector(90 0, 0)
					FlightPhys.pos = Vector(self:GetPos().x,self:GetPos().y,worldZ)+(FWD*self.Accel.FWD)+(RIGHT*self.Accel.RIGHT)+(UP*self.Accel.UP);
				else
					FlightPhys.angle = ang;
					FlightPhys.pos = Vector(self:GetPos().x,self:GetPos().y,worldZ)+(FWD*-20)
				end
				FlightPhys.deltatime = deltatime;
				phys:ComputeShadowControl(FlightPhys);
			end
		else
			if(self.ShouldStandby) then

				phys:Wake();
				worldZ = self:GetHover(true);
				FlightPhys.angle = Angle(0,self:GetAngles().y,0);
				FlightPhys.pos = Vector(self:GetPos().x,self:GetPos().y,worldZ-(self.StandbyHoverAmount or (self.HoverAmount/1.5)));
				FlightPhys.deltatime = deltatime;
				phys:ComputeShadowControl(FlightPhys);
			end
		end
	end
end

function SWSpeederStandbyPickup(p,e)
	if(IsValid(e) and e.IsSWVehicle) then
		e.ShouldStandby = false;
	end
end
hook.Add( "PhysgunPickup", "SWSpeederStandbyPickup", SWSpeederStandbyPickup )

function SWSpeederStandbyDrop(p,e)
	if(IsValid(e) and e.IsSWVehicle) then
		e.ShouldStandby = true;
	end
end
hook.Add("PhysgunDrop", "SWSpeederStandbyDrop", SWSpeederStandbyDrop);


function ENT:GetHover(standby)
	local worldZ = 0;

	if(not self.WaterTrace.Hit or (self.WaterTrace.Hit and self.FrontTrace.Hit and (self.WaterTrace.HitPos.z < self.FrontTrace.HitPos.z) and self:WaterLevel() < 1)) then
		self.UseGroundTraces = true;
		if(self.FrontTrace.Hit and self.BackTrace.Hit) then

			if(!standby) then
				if(self.FrontTrace.HitPos.z >= self.BackTrace.HitPos.z) then
					self.HoverAmount = self.StartHover + (self.FrontTrace.HitPos.z - self.BackTrace.HitPos.z)*(self.HoverMod or 1);
				else
					self.HoverAmount = self.StartHover - (self.BackTrace.HitPos.z - self.FrontTrace.HitPos.z)*(self.HoverMod or 1);
				end
			else
				self.HoverAmount = self.StartHover;
			end

			self.HoverAmount = math.Clamp(self.HoverAmount,0,250);

			if(self.FrontTrace.HitPos.z >= self.BackTrace.HitPos.z and self.FrontTrace.HitPos.z >= self.MiddleTrace.HitPos.z) then
				worldZ = self.FrontTrace.HitPos.z+self.HoverAmount;
			elseif(self.MiddleTrace.HitPos.z >= self.BackTrace.HitPos.z and self.MiddleTrace.HitPos.z >= self.FrontTrace.HitPos.z) then
				worldZ = self.MiddleTrace.HitPos.z+self.HoverAmount;
			elseif(self.BackTrace.HitPos.z >= self.FrontTrace.HitPos.z and self.BackTrace.HitPos.z >= self.MiddleTrace.HitPos.z) then
				worldZ = self.BackTrace.HitPos.z+self.HoverAmount;
			end

		end

	else
		self.UseGroundTraces = false;
		if(self.FrontTrace.Hit) then
			if(self.FrontTrace.HitPos.z < self.WaterTrace.HitPos.z) then
				worldZ = self.WaterTrace.HitPos.z+self.StartHover;
			end
		end
	end

	if(!self.NoWobble) then
		if(self.StandbyHover <= -3) then
			self.StandbyHoverMod = 1;
		elseif(self.StandbyHover >= 3) then
			self.StandbyHoverMod = -1;
		end
		self.StandbyHover = math.Approach(self.StandbyHover,3*self.StandbyHoverMod,0.025*self.StandbyHoverMod);

		return worldZ + self.StandbyHover;
	end
	return worldZ;
end

function ENT:Rotorwash(b)

	if(b) then
		if(!IsValid(self.RotorWash)) then
			local e = ents.Create("env_rotorwash_emitter");
			e:SetPos(self:GetPos());
			e:SetParent(self);
			e:Spawn();
			e:Activate();
			self.RotorWash = e;
		end
	else
		if(IsValid(self.RotorWash)) then
			self.RotorWash:Remove();
			self.RotorWash:Fire("Kill");
		end
	end
end

function ENT:Bang(p)

	self:EmitSound(Sound("explosion.mp3"),100,100);
	local fx = EffectData();
		fx:SetOrigin(self:GetPos());
	util.Effect("chimeraexplosion",fx);

	if(self.Inflight) then
		if(IsValid(self.Pilot)) then
			if(!self.Pilot:HasGodMode()) then
				self:Exit(true,true); --Let the player out...
			else
				self:Exit(true,false);
			end
		end
		if(IsValid(self.Passenger)) then
			if(!self.Passenger:HasGodMode()) then
				self:Exit(false,true);
			else
				self:Exit(false,false);
			end
		end
	end
	self.Done = true;
	self:Remove();

end

function ENT:PhysicsCollide(cdat, phys)


	local ephys = cdat.HitEntity:GetPhysicsObject();

	if((cdat.DeltaTime)>0.5) then
		local mass = (cdat.HitEntity:GetClass() == "worldspawn") and 1000 or cdat.HitObject:GetMass() --if it's worldspawn use 1000 (worldspawns physobj only has mass 1), else normal mass
		local dmg = (cdat.Speed*cdat.Speed*math.Clamp(mass, 0, 1000))/1000000
		self.Accel.FWD = math.Approach(self.Accel.FWD,self.Accel.FWD / dmg,100*((ephys:GetVelocity():Length()+1)/ephys:GetMass()));
		self:TakeDamage(dmg)
	end
end

function ENT:OnTakeDamage(dmg)

	local health=self:GetNetworkedInt("Health")-(dmg:GetDamage()/2)

	self:SetNWInt("Health",health);

	if(health<100) then
		self.CriticalDamage = true;
		self:SetNWBool("CriticalDamage",true);
	end


	if((health)<=0) then
		self:Bang()
	end
end


end

if CLIENT then

	function ENT:Initialize()

		self.FXEmitter = ParticleEmitter(self:GetPos());

		self.StandbySounds = Sound("ambient/atmosphere/ambience_base.wav");
		self.SoundsOn = {}
		if (self.Sounds and self.Sounds.Engine) then
			self.EngineSound = self.EngineSound or CreateSound(self.Entity,self.Sounds.Engine);
			self.StandbySound = self.StandbySound or CreateSound(self.Entity,self.StandbySounds);
		end

		surface.CreateFont( "HUD_Health", {
			font = "Aurebesh",
			size = 12,
			weight = 1000,
			blursize = 0,
			scanlines = 0,
			antialias = true,
			underline = false,
			italic = false,
			strikeout = false,
			symbol = false,
			rotary = false,
			shadow = false,
			additive = false,
			//outline = true,
			outline = false,
		} )

		surface.CreateFont( "HUD_Crosshair", {
			font = "Default",
			size = 24,
			weight = 250,
			blursize = 0,
			scanlines = 0,
			antialias = false,
			underline = false,
			italic = false,
			strikeout = false,
			symbol = false,
			rotary = false,
			shadow = false,
			additive = false,
			outline = true,
		} )
	end

	function ENT:Draw() self:DrawModel() end;

	function ENT:OnRemove()
		if (self.EngineSound) then
			self.EngineSound:Stop();
		end

		if(self.StandbySound) then
			self.StandbySound:Stop();
		end
	end

	function ENT:StartClientsideSound(mode)
		if(not self.SoundsOn[mode]) then
			if(mode == "Engine" and self.EngineSound) then
				self.EngineSound:Stop();
				self.EngineSound:SetSoundLevel(110);
				self.EngineSound:PlayEx(100,100);
			elseif(mode == "Standby" and self.StandbySound) then
				self.StandbySound:Stop();
				self.StandbySound:SetSoundLevel(66);
				self.StandbySound:PlayEx(1,200);
			end
			self.SoundsOn[mode] = true;
		end
	end

	function ENT:StopClientsideSound(mode)
		if(self.SoundsOn[mode]) then
			if(mode == "Engine" and self.EngineSound) then
				self.EngineSound:FadeOut(2);
			elseif(mode == "Standby" and self.StandbySound) then
				self.StandbySound:FadeOut(2);
			end
			self.SoundsOn[mode] = nil;
		end
	end

	local Health = 0;
	local Speed = 0;
	local MaxSpeed = 0;
	function ENT:Think()

		local p = LocalPlayer();
		local SpeederActive = self:GetNWBool("Flying" ..self.Vehicle);

		if(SpeederActive) then
			local IsDriver = p:GetNWEntity(self.Vehicle) == self.Entity;
			-- Normal behaviour for Pilot or people who stand outside
			self:StartClientsideSound("Engine");
			--#########  Now add Pitch etc
			local velo = self.Entity:GetVelocity();
			local pitch = self.Entity:GetVelocity():Length();
			local doppler = 0;
			-- For the Doppler-Effect!
			if(not IsDriver) then
				-- Does the vehicle fly to the player or away from him?
				local dir = (p:GetPos() - self.Entity:GetPos());
				doppler = velo:Dot(dir)/(150*dir:Length());
			end


			Speed = p:GetNWInt("SW_Speeder_Speed") or self:GetNWInt("Speed");
			MaxSpeed = p:GetNWInt("SW_Speeder_MaxSpeed") or self:GetNWInt("MaxSpeed");

			if(self.SoundsOn.Engine) then

				spd = Speed;
				mspd = MaxSpeed;
				if(spd < 0) then
					spd = Speed * -1;
					mspd = MaxSpeed * -1;
				end

				self.EngineSound:ChangePitch(math.Clamp(60 + pitch/25,75,100) + doppler,0);
			end
			//self:StopClientsideSound("Standby");

			Health = self:GetNWInt("Health");

		else
			self:StopClientsideSound("Engine");
			/*
			if(IsValid(self)) then
				self:StartClientsideSound("Standby");
			else
				self:StopClientsideSound("Standby");
			end
			*/
		end

	end

	function ENT:Effects(pos,boost)

		local p = LocalPlayer();
		local roll = math.Rand(-45,45);
		local normal = (self.Entity:GetRight() * -1):GetNormalized();
		local FWD = self:GetRight();
		for k,v in pairs(pos) do
			if(boost) then
				if(p:KeyDown(IN_SPEED) or k == "Left" or k == "Right") then
					local heatwv = self.FXEmitter:Add("sprites/heatwave",v);
					heatwv:SetVelocity(normal*2);
					heatwv:SetDieTime(0.1);
					heatwv:SetStartAlpha(255);
					heatwv:SetEndAlpha(255);
					heatwv:SetStartSize(10);
					heatwv:SetEndSize(8);
					heatwv:SetColor(255,255,255);
					heatwv:SetRoll(roll);
				end
			else
				local heatwv = self.FXEmitter:Add("sprites/heatwave",v);
				heatwv:SetVelocity(normal*2);
				heatwv:SetDieTime(0.1);
				heatwv:SetStartAlpha(255);
				heatwv:SetEndAlpha(255);
				heatwv:SetStartSize(10);
				heatwv:SetEndSize(8);
				heatwv:SetColor(255,255,255);
				heatwv:SetRoll(roll);
			end
		end
	end

	function HVTANK_DrawHull(StartHealth)

		surface.SetFont("HUD_Health");
		local w = ScrW()/100*20;
		local h = w / 4;

		local x = ScrW() - w - w/2.5;
		local y = ScrH() / 1.2;

		local per = ((Health/StartHealth)*100)/100;

		surface.SetDrawColor( color_white )
		surface.SetMaterial( Material( "hud/chimera_hull/hp_frame_under.png", "noclamp" ) )

		surface.DrawTexturedRectUV( x, y, w, h, 0, 0, 1, 1 )

		if(Critical) then
			if(Health > StartHealth * 0.1) then
				surface.SetDrawColor(Color(50,120,255,255));
			else
				surface.SetDrawColor(Color(255,35,35,255));
			end
		end

		local barX = x + w * 0.02832;
		local barY = y + h * 0.27343;
		local barW = w * 0.90625;
		local barH = h * 0.4;
		surface.SetMaterial( Material( "hud/chimera_hull/hp_bar.png", "noclamp" ) )
		surface.DrawTexturedRectUV( barX, barY, barW*(per*0.6), barH, 0, 0, per, 1 )

		surface.SetMaterial( Material( "hud/chimera_hull/hp_frame_over.png", "noclamp" ) )
		surface.SetDrawColor( color_white )
		surface.DrawTexturedRectUV( x, y, w, h, 0, 0, 1, 1 )

		health = math.Round(Health/StartHealth*100);
		health = health .. "%";
		local tW, tH = surface.GetTextSize(health);


		surface.SetTextColor(Color(255,255,255,255));
		x = x + w * 0.2775;
		y = y - tH / 2 + h * 0.1

		surface.SetTextPos(x,y + tH/2);
		surface.DrawText(health)

	end

	function HVTANK_DrawSpeedometer()

		local n = Speed;
		local ms = MaxSpeed;
		local reversed = false;
		if(ms < 0) then
			reversed = true;
			ms = ms * -1;
		end


		local c = color_white;
		if(reversed) then
			if(n > 0) then
				c = Color(255,50,50,255);
			end
		else
			if(n < 0) then
				c = Color(255,50,50,255);
				n = n * -1;
			end
		end
		if(n < 0) then
			n = n * -1;
		end

			local w = ScrW()/100*20;
		local h = w / 4;

		local x = ScrW() - w - w/2.5;
		local y = ScrH() / 4*3;

		local per = ((n/ms)*100)/100;

		surface.SetDrawColor(color_white)
		surface.SetMaterial( Material( "hud/chimera_speed/speed_frame_under.png", "noclamp" ) )
		surface.DrawTexturedRectUV( x, y, w, h, 0, 0, 1, 1 )

		local barX = x + w * 0.01953125;
		local barY = y + h * 0.234375;
		local barW = w * 0.9541015625;
		local barH = h * 0.53515625;
		surface.SetDrawColor(c)
		surface.SetMaterial( Material( "hud/chimera_speed/speed_bar.png", "noclamp" ) )
		surface.DrawTexturedRectUV( barX, barY, barW*per, barH, 0, 0, per, 1 )

		surface.SetDrawColor(color_white)
		surface.SetMaterial( Material( "hud/chimera_speed/speed_frame_over.png", "noclamp" ) )
		surface.DrawTexturedRectUV( x, y, w, h, 0, 0, 1, 1 )

		local blur = Speed/1000*-1;
		//DrawMotionBlur( 0.2, blur, 0.01 )


	end

	function HVTANK_Reticles(self,WeaponsPos)
		local p = LocalPlayer();

		for i=1,table.Count(WeaponsPos) do
			local tr = util.TraceLine( {
				start = WeaponsPos[i],
				endpos = WeaponsPos[i] + p:GetAimVector():Angle():Forward()*10000,
				filter = {self},
			} )




			local material = "hud/chimera_reticle.png"
			local vpos = tr.HitPos;
			if(IsValid(tr.Entity)) then
				if(IsSWSpeeder(tr.Entity:GetClass()) and tr.Entity != self) then
					material = "hud/chimera_reticle.png"
				end
			end
			local screen = vpos:ToScreen();

			local x,y;
			for k,v in pairs(screen) do
				if k=="x" then
					x = v;
				elseif k=="y" then
					y = v;
				end
			end


			local x,y;
			for k,v in pairs(screen) do
				if k=="x" then
					x = v;
				elseif k=="y" then
					y = v;
				end
			end


			local w = ScrW()/100*2;
			local h = w;
			surface.SetDrawColor( color_white )
			surface.SetMaterial( Material( material, "noclamp" ) )
			surface.DrawTexturedRectUV( x - w/2 , y - h/2, w, h, 0, 0, 1, 1 )

		end
	end

end
