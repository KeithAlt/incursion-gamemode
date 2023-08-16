ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Base = "anim"
ENT.Type = "vehicle"
ENT.AutomaticFrameAdvance = true;
ENT.CriticalExplodeTime = 30 -- In seconds, how long till critical damage results in an explosion

ENT.IsHALOVehicle = true;

if SERVER then

function HALOCreateBulletStructure(dmg,color,nosplashdamage)
	if(color == "blue" and dmg/2 > 30) then
		dmg = 30;
	elseif(color == "blue" and dmg/2 <= 30) then
		dmg = dmg/2;
	end

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
			util.Effect( "m9k_nuke_disintegrate", fx, true )
			util.ScreenShake(tr.HitPos, 100, 100, 1, 500)

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
					if(tr.Entity.IsHALOVehicle) then
						tr.Entity.IonShots = tr.Entity.IonShots + 1;
					end
				end
			end
		end
	}
	return bullet;
end

local Should_Collisions = true;
local Should_LockOn = true;
local Should_HeliDamage = true;
local Should_AlwaysCorrect = false;
function ENT:HALO_LoadConfig()
	local Config_Exists = file.Exists( "halov/general.txt", "DATA" );
	if(Config_Exists) then
		local s = file.Read("halov/general.txt","DATA");
		local Configs = string.Split( s, ";" );
		local n = table.Count(Configs);
		for i=1,n do
			local c = string.Split(Configs[i], ":");
			if(c[1] == "CollisionDamage") then
				if(c[2] == "yes") then
					Should_Collisions = true;
				else
					Should_Collisions = false;
				end
			elseif(c[1] == "LockOn") then
				if(c[2] == "yes") then
					Should_LockOn = true;
				else
					Should_LockOn = false;
				end
			elseif(c[1] == "HeliDamage") then
				if(c[2] == "yes") then
					Should_HeliDamage = true;
				else
					Should_HeliDamage = false;
				end
			elseif(c[1] == "ForceAssist") then
				if(c[2] == "yes") then
					Should_AlwaysCorrect = true;
				else
					Should_AlwaysCorrect = false;
				end
			elseif(c[1] == "CollideTimer") then
				self.CollideTimer = tonumber(c[2]);
			elseif(c[1] == "CollisionMultiplier") then
				self.CollisionDamageMulti = tonumber(c[2]);
			end
		end

	end
end

ENT.NextUse = {Doors = CurTime(),Use = CurTime(),Fire = CurTime(),FireMode = CurTime(),FireBlast=CurTime(),DockCheck=CurTime(),Lock=CurTime(),AutoCorrect=CurTime()};
ENT.DeactivateInWater = true;

AddCSLuaFile();

function ENT:Initialize()
	self.FlightPhys = {
		secondstoarrive	 = 1,
		maxangular       = 5000,
		maxangulardamp   = 10000,
		maxspeed         = 1000000,
		maxspeeddamp     = 500000,
		dampfactor       = 0.8,
		teleportdistance = 5000
	}
	self:SetModel(self.EntModel);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	--self:StartMotionController();
	self:SetUseType(SIMPLE_USE);
	self:SetRenderMode(RENDERMODE_TRANSALPHA);
	self.PlayerActiveWeapon = "";
	if(!self.Weapons) then
		self:SpawnWeapons();
	end
	self.VehicleHealth = self.StartHealth;
	self.IonShots = 0;
	self.Overheat = 0;
	self.Overheated = false;
	self.Cooldown = 2;
	self.Acceleration = 1;
	self.PlayerArmor = 0;
	self.OverheatAmount = self.OverheatAmount or 50;
	self:SetNWInt("OverheatAmount",self.OverheatAmount);
	self:SetNWBool("Critical",self.CriticalDamage or false);

    if(!self.IsCapitalShip) then
       self.CanEject = true;
    end

	if(not self.Bullet) then
		self.Bullet = HALOCreateBulletStructure(75,"red");
	end


	self.Accel={
		FWD=0,
		RIGHT=0,
		UP=0,
	};
	self.Throttle = {
		FWD = 0,
		RIGHT = 0,
		UP = 0,
	};

	self.ShouldLock = true;
	self:SetNWBool("ShouldLock",self.ShouldLock);
	self:SetNWString("Allegiance",self.Allegiance);

	self.LastCollide = CurTime();
	self.CollideTimer = 1;
	self.CollisionDamageMulti = 1;

	if(self.LandDistance) then
		self:SetNWInt("LandDistance",self.LandDistance);
	end

	self.OGBoost = self.BoostSpeed;
	self.OGForward = self.ForwardSpeed;
	self.OGUp = self.UpSpeed;

	self.TakeOff = true;
	self:SetNWBool("TakeOff",self.TakeOff);

	if(self.CanStandby) then
		self.ShouldStandby = true;
	end

	self:SetNWInt("Health",self.StartHealth);
	self:SetNWInt("StartHealth",self.StartHealth);
	local mb, mb2 = self:GetModelBounds();
	self.Mass = ((mb2.x + mb2.y + mb2.z) - (mb.x + mb.y + mb.z))*10;
	self.ShipLength = (mb2.x - mb.x)/2;
	local phys = self:GetPhysicsObject();

    self.MaxAcceleration = math.floor((100 - math.ceil((mb-mb2):Length()/100))/10)*2;

	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(10000)
	end

	self:HALO_LoadConfig();
	self:ConfigVars();

	if(!Should_LockOn) then
		self.ShouldLock = false;
		self:SetNWBool("ShouldLock",false);
	end
end

function ENT:ConfigVars()
	local path = "halov/".. self:GetClass() ..".txt";
	local Config_Exists = file.Exists( path, "DATA" );
	if(Config_Exists) then
		local s = file.Read(path,"DATA");
		local Settings = string.Split(s,";");
		local n = table.Count(Settings);
		for i=1,n do
			if(Settings[i] != nil and Settings[i] != "") then
				local Key = string.gsub(string.Split(Settings[i],"=")[1],"%s", ""):upper();
				local Value = string.gsub(string.Split(Settings[i],"=")[2],"%s",""):upper();

				if(Key != nil and Key != "") then
					if(Key == "HEALTH") then
						self.VehicleHealth = tonumber(Value);
						self.StartHealth = tonumber(Value);
						self:SetNWInt("StartHealth",tonumber(Value));
						self:SetNWInt("Health",tonumber(Value));
					elseif(Key == "WEAPONDAMAGE") then
						self.Bullet = HALOCreateBulletStructure(tonumber(Value),string.Split(self.Bullet.TracerName,"_")[1]);
					elseif(Key == "FORWARDSPEED") then
						self.ForwardSpeed = tonumber(Value);
						self.OGForward = self.ForwardSpeed;
					elseif(Key == "BOOSTSPEED") then
						self.BoostSpeed = tonumber(Value);
						self.OGBoost = self.BoostSpeed;
					elseif(Key == "ACCELSPEED") then
						self.AccelSpeed = tonumber(Value);
					elseif(Key == "SPLASHDAMAGE") then
						local b = true;
						if(Value == "false") then
							b = false;
						end
						self.Bullet = HALOCreateBulletStructure(self.Bullet.Damage,string.Split(self.Bullet.TracerName,"_")[1],b);
					elseif(Key == "COLLISIONMULTIPLIER") then
						self.CollisionDamageMulti = tonumber(Value);
					end
				end
			end
		end
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
		e:GetPhysicsObject():EnableCollisions(false);
		e:GetPhysicsObject():EnableMotion(false);
		e:SetSolid(SOLID_NONE);
		e:AddFlags(FL_DONTTOUCH);
		e:SetColor(Color(255,255,255,0));
		e:SetParent(self);
		self.Weapons[k] = e;
	end

end

function ENT:OnRemove(p)

	if(self.Inflight and not self.Done) then
		self:Exit(); -- Let the player out
	end
	--
	for k,v in pairs(self.Seats or {}) do
		if IsValid(v) then
			v:Remove()
			v = nil
		end
	end
	--
	for k,v in pairs(self.Turrets or {}) do
		if IsValid(v) then
			v:Remove()
			v = nil
		end
	end
end

function ENT:Enter(p)

	if(not self.Inflight) then
		p:SetNetworkedEntity(self.Vehicle,self); --Set a networked entity as the name of the vehicle
		p:SetNetworkedBool("Flying"..self.Vehicle,true); --Set a bool on the player
		p:Spectate(OBS_MODE_CHASE); --Spectate the vehicle
		p:DrawWorldModel(false);
		p:DrawViewModel(false);
		p:SetRenderMode(RENDERMODE_TRANSALPHA);
		p:SetColor(Color(255,255,255,0));
		p:SetMoveType(MOVETYPE_NOCLIP);
		p:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE);
		for k,v in pairs(p:GetWeapons()) do
			table.insert(self.WeaponsTable, v:GetClass());
		end
		if(IsValid(p:GetActiveWeapon())) then
			self.PlayerActiveWeapon = p:GetActiveWeapon():GetClass();
		end

		self.WeaponAmmo = {}

		for k,v in pairs(p:GetWeapons()) do
			local tbl = {
				v:GetPrimaryAmmoType(),
				p:GetAmmoCount(v:GetPrimaryAmmoType()),
			};
			self.WeaponAmmo[k] = tbl;
		end

		if (p.isWepRaised and not p:isWepRaised()) then -- Custom check added by Keith : If player enters unholstered then raise their weapons to fire
			p:toggleWepRaised()
		end

		p:StripWeapons();
		self.PlayerHealth=p:Health();
		if(p:FlashlightIsOn()) then
			p:Flashlight(false); --Turn the player's flashlight off when Flying
		end
		self:SetNWBool("Flying" .. self.Vehicle,true);
		self:SetNWInt("HALO_MaxSpeed",self:GetTopSpeed());
		p:SetViewEntity(self)
		self:GetPhysicsObject():Wake();
		self:GetPhysicsObject():EnableMotion(true); --UnFreeze us
		self:StartMotionController()

		self.PlayerArmor = p:Armor();
		self.Inflight = true;
		self.Pilot = p;
		self.NextUse.Use = CurTime()+1;
		self:SetNWBool("EngineOn", true)

		self.StartPos = self:GetPos();
		self.LandPos = self:GetPos()+Vector(0,0,10);

		self.Accel.FWD = 0;
		self.Accel.RIGHT = 0;
		self.Accel.UP = 0;

		self:SetNWBool("Speed",self.Accel.FWD);

		p:SetNWInt("HALO_Health",self.VehicleHealth);
		p:SetNWInt("HALO_Overheat",self.Overheat);
		p:SetNWBool("HALO_Overheated",self.Overheated);
		p:SetNWBool("HALO_Critical",self.CriticalDamage or false);
		p:SetNWBool("HALO_ShouldLock",self.ShouldLock);
		p:SetNWBool("HALO_Speed",self.Accel.FWD);
		p:SetNWInt("HALO_MaxSpeed",self:GetTopSpeed());
		p:SetNWBool("HALO_Doors",self.Doors);


		p:SetEyeAngles(self.EnterAngles or self:GetAngles());

		if(self.PilotVisible and self.PilotPosition) then
			local pos = self:GetPos() + self:GetRight() * self.PilotPosition.x + self:GetForward() * self.PilotPosition.y + self:GetUp() * self.PilotPosition.z;
			self:SpawnPilot(pos);
		end
	end
end

function ENT:SpawnPilot(pos)

	if(IsValid(self.Pilot)) then
		local e = ents.Create("prop_physics");
		e:SetModel(self.Pilot:GetModel());
		e:SetPos(pos - Vector(0,0,20))
		local ang = self:GetAngles();
		if(self.PilotAngle) then
			ang = self:GetAngles() + self.PilotAngle;
		end
		e:SetAngles(ang)
		e:SetParent(self);
		e:Spawn();
		e:Activate();
		e:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE);

		e:SetSequence("Citizen4_Preaction")

		self.PilotAvatar = e;
		self:SetNWEntity("PilotAvatar",e);
	end
end

function ENT:GetTopSpeed()
	if(self.ForwardSpeed > self.BoostSpeed) then
		return self.ForwardSpeed;
	end
	return self.BoostSpeed;
end

function ENT:Exit(kill) --####### Get out @RononDex

	if (IsValid(self.Pilot)) then
		self.Pilot:UnSpectate();
		self.Pilot:DrawViewModel(true);
		self.Pilot:DrawWorldModel(true);
		self.Pilot:Spawn();
		self.Pilot:SetNWEntity(self.Vehicle,NULL)
		self.Pilot:SetNWBool("Flying"..self.Vehicle,false);

		if(self.ExitModifier) then
			self.ExitPos = self:GetPos() + (self:GetRight() * self.ExitModifier.x) + (self:GetForward() * self.ExitModifier.y + self:GetUp()* self.ExitModifier.z);
        else
            self.ExitPos = self:GetPos()+self:GetUp()*105+self:GetRight()*100+self:GetForward()*-80;
		end

		local pilot = self.Pilot
		local exitPos = self.ExitPos

		timer.Simple(0, function()
			if IsValid(pilot) then
				pilot:SetPos(exitPos)
			end
		end)

		self.Pilot:SetMoveType(MOVETYPE_WALK);
		self.Pilot:SetCollisionGroup(COLLISION_GROUP_PLAYER);
		self.Pilot:SetViewEntity( NULL )
		self.Pilot:SetHealth(self.PlayerHealth);
		self.Pilot:SetArmor(self.PlayerArmor);
		self.PilotAvatar:Remove(0)
		for k,v in pairs(self.WeaponsTable) do
			if(!self.Pilot:HasWeapon(tostring(v))) then
				self.Pilot:Give(tostring(v));
			end
		end
		if(self.PlayerActiveWeapon != "") then
			self.Pilot:SelectWeapon(self.PlayerActiveWeapon);
		end

		self.Pilot:StripAmmo();

		for k,v in pairs(self.WeaponAmmo) do
			self.Pilot:SetAmmo(v[2],v[1]);
		end
	end
	if(self.Doors) then
		self:ToggleDoors();
	end
	self.Inflight = false;
	self:SetNWEntity(self.Vehicle,nil);
	self:SetNWBool("Flying" .. self.Vehicle,false);

	table.Empty(self.WeaponsTable);
	table.Empty(self.WeaponAmmo);

	self.Pilot = nil

	self:StopMotionController()

	self.NextUse.Use = CurTime() + 1;
end

local al = 1;
function ENT:FireWeapons()
	if(self.NextUse.Fire < CurTime()) then
		for k,v in pairs(self.Weapons) do
            if(!IsValid(v)) then return end;
			local tr = util.TraceLine({
				start = self:GetPos(),
				endpos = self:GetPos()+self:GetForward()*10000,
				filter = {self},
			})

			local angPos = (tr.HitPos - v:GetPos())

			if(self.ShouldLock) then
				local e = self:FindTarget();
				if(IsValid(e)) then
					local tr = util.TraceLine( {
						start = v:GetPos(),
						endpos = e:GetPos(),
						filter = {self},
					} )
					if(!tr.HitWorld) then
						angPos = (e:GetPos() + e:GetUp()*(e:GetModelRadius()/3) + (self.LockOnOverride or Vector(0,0,0))) - v:GetPos();
					end

				end
			end

			self.Bullet.Attacker = self.Pilot or self;
			self.Bullet.Src		= v:GetPos();

			self.Bullet.Dir = angPos

            if(!self.Disabled) then
                if(self.AlternateFire) then
                    if(al == 1 and (k == self.FireGroup[1] or k == self.FireGroup[3])) then
                        v:FireBullets(self.Bullet)
                    elseif(al == 2 and (k == self.FireGroup[2] or k == self.FireGroup[4])) then
                        v:FireBullets(self.Bullet)
                    end
                else
                    v:FireBullets(self.Bullet)
                end
            end
		end
		al = al + 1;
		if(al == 3) then
			al = 1;
		end
		self:EmitSound(self.FireSound,100,math.random(90,110));
		self.NextUse.Fire = CurTime() + (self.FireDelay or 0.2)*0.8;
	end
end

function ENT:FindTarget()
	local corner1, corner2 = self:GetModelBounds();
	corner1 = self:LocalToWorld(corner1);
	corner2 = self:LocalToWorld(corner2) + self:GetForward()*10000;
	for k,v in pairs(ents.FindInBox(corner1,corner2)) do
		if(v.IsHALOVehicle and !v.DontLock and v != self and v.Allegiance != self.Allegiance) then
			return v;
		end
	end
	return NULL;

end

function ENT:ChangeAllegiance(al)
    self.Allegiance = al;
	self:SetNWString("Allegiance",al);
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
        self.Flashlight[i]:SetKeyValue( "farz", self.FlashlightDistance or 3000 )
        self.Flashlight[i]:SetKeyValue( "nearz", 6 )
        self.Flashlight[i]:SetKeyValue( "lightfov", 80 )

        local c = Color(255,255,255);
        local b = 1;
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

hook.Add("PlayerSwitchFlashlight","HALOVehicleSwitchFlashlight",function(p,e)
    local self = p:GetViewEntity();
    if(self.IsHALOVehicle and self.Inflight and self.HasFlashlight) then
        if(self.FlashlightOn) then
            self:RemoveFlashlight();
        else
            self:CreateFlashlight();
        end
        return false;
    end
end)

function ENT:Think()
	if(self.Inflight) then
        if(IsValid(self.Pilot)) then
            if(self.PilotOffset) then
                self.Pilot:SetPos(self:GetPos()+self:GetRight()*self.PilotOffset.x+self:GetForward()*self.PilotOffset.y+self:GetUp()*self.PilotOffset.z);
            else
                self.Pilot:SetPos(self:GetPos());
            end
        end

		if(IsValid(self.Pilot) and !self.Pilot:Alive()) then
			self:Bang();
		end


		if(self.IonShots >= (self.MaxIonShots or 20)) then
			self.CriticalDamage = true;
			self:SetNWBool("Critical",self.CriticalDamage);
			//self.Accel.FWD = 0;
			self:ResetThrottle();
			timer.Create(self.Vehicle .. "IonShotTimer" .. self:EntIndex() * math.random(1,1000), 10, 1, function()
				if(IsValid(self)) then
					self.CriticalDamage = false;
					self.IonShots = 0;
					self:SetNWBool("Critical",self.CriticalDamage);
					if(IsValid(self.Pilot)) then
						self.Pilot:SetNWBool("HALO_Critical",self.CriticalDamage);
					end
				end
			end);
		end

		if(IsValid(self.Pilot)) then

			if(self.Pilot:KeyDown(IN_USE)) then
				if(self.NextUse.Use < CurTime()) then
                    if(self.Pilot:KeyDown(IN_JUMP) and self.CanEject) then
                        self:Eject();
                    else
				        self:Exit(false);
                    end
				end
			end

			/**
			if(IsValid(self.Pilot) and self.Pilot:KeyDown(IN_DUCK) and self.Pilot:KeyDown(IN_RELOAD)) then
				self:ToggleAssist();
			end**/

			if(self.HasDoors) then
				if(IsValid(self.Pilot)) then
					if(self.Pilot:KeyDown(IN_SPEED) and self.NextUse.Doors < CurTime()) then
						self:ToggleDoors();
					end
				end
			end

			if(self.CanShoot and !self.WeaponsDisabled) then
				if(IsValid(self.Pilot)) then // I don't know why I need this here for a second check but when I don't it causes an error

					/**if(self.Pilot:KeyDown(IN_ATTACK) and self.Pilot:KeyDown(IN_RELOAD) and Should_LockOn) then
						self:ToggleLock();**/

					if (self.Pilot:KeyDown(IN_RELOAD)) then
						if (self.SecondaryAttack != nil) then
							self:SecondaryAttack()
						end
					end

					if (self.Pilot:KeyDown(IN_ATTACK) and self.NextUse.Fire < CurTime()) then
						if(((not self.Overheated and self.Overheat < (self.OverheatAmount or 50)) or self.DontOverheat) and !self.CriticalDamage) then
							self:FireWeapons();
							self.Overheat = self.Overheat + 2;
							self.Cooldown = 2;
						elseif(self.Overheated) then
							self.Overheat = self.Overheat - self.Cooldown;
							self.Cooldown = math.Approach(self.Cooldown,4,0.25);
						end
						self:Network_Overheating();
					else
						if(self.NextUse.Fire < CurTime()) then
							if(self.Overheat > 0) then
								self.Overheat = self.Overheat - self.Cooldown;
								self.Cooldown = math.Approach(self.Cooldown,4,0.25);
								self:Network_Overheating();
							end
						end
					end
				end

				if(self.Overheat >= (self.OverheatAmount or 50)) then
					self.Overheated = true;
					self:Network_Overheating();
				elseif(self.Overheat <= 0) then
					self.Overheated = false;
					self:Network_Overheating();
				end
			end


		end

        if(!self.DeactivateInWater) then
            if(self:WaterLevel() >= 1) then
                self.BoostSpeed = self.OGBoost/2;
                self.ForwardSpeed = self.OGForward/2;
            else
                self.BoostSpeed = self.OGBoost;
                self.ForwardSpeed = self.OGForward;
            end
        end
	end

end

function ENT:ToggleAssist()
	if(self.NextUse.AutoCorrect < CurTime()) then
		if(self.AutoCorrect) then
			self.AutoCorrect = false;
			self.Pilot:ChatPrint("Pilot-Assist: Disabled");
		else
			self.AutoCorrect = true;
			self.Pilot:ChatPrint("Pilot-Assist: Enabled");
		end
		self.NextUse.AutoCorrect = CurTime() + 1;
	end
end

function ENT:ToggleLock()
	if(!Should_LockOn) then return end;
	if(self.NextUse.Lock < CurTime()) then
		if(self.ShouldLock) then
			self.ShouldLock = false;
			self.Pilot:ChatPrint("Weapons Lock: Disabled");
		else
			self.ShouldLock = true;
			self.Pilot:ChatPrint("Weapons Lock: Enabled");
		end
		self.NextUse.Lock = CurTime() + 1;
		self:SetNWBool("ShouldLock",self.ShouldLock);
		if(IsValid(self.Pilot)) then
			self.Pilot:SetNWBool("HALO_ShouldLock",self.ShouldLock);
		end
	end
end

function ENT:Heal()
	local Health = self.VehicleHealth or self:GetNWInt("Health");
	local inc = self.StartHealth / 1000 * 0.5;
	if(Health < self.StartHealth) then
		if(self.StartHealth - Health < inc) then
			self:SetNWInt("Health",self.StartHealth);
			self.VehicleHealth = self.StartHealth;
		else
			self:SetNWInt("Health",Health+inc);
			self.VehicleHealth = Health + inc;
		end
	end
end

function ENT:Eject()
    if(IsValid(self.Pilot) and self.CanEject and !self.TakingOff and !self.Land) then
        local p = self.Pilot;
        self:Exit(false);
        p:SetVelocity(self:GetUp()*1500);
    else
        self:Exit(false);
    end
end

function ENT:Network_Overheating()

	self:SetNWInt("Overheat",self.Overheat);
	self:SetNWBool("Overheated",self.Overheated);
	if(IsValid(self.Pilot)) then
		self.Pilot:SetNWInt("HALO_Overheat",self.Overheat);
		self.Pilot:SetNWBool("HALO_Overheated",self.Overheated);
	end

end

function ENT:OnTakeDamage(dmg)
	if(dmg:GetInflictor():GetParent() == self) then return end;

	self.VehicleHealth = math.floor(self.VehicleHealth-(dmg:GetDamage()/2));

	self:SetNWInt("Health",self.VehicleHealth);
	if(IsValid(self.Pilot)) then
		self.Pilot:SetNWInt("HALO_Health",self.VehicleHealth);
	end

	if(self.VehicleHealth<=(self.StartHealth*0.33)) then
		self.HyperdriveDisabled = true;
	end

	if(self.VehicleHealth<(self.StartHealth*0.2)) then
		self.WeaponsDisabled = true;
	end

	if(self.VehicleHealth<(self.StartHealth*0.1)) then
		self.CriticalDamage = true;

		if IsValid(self.Pilot) then
			self.Pilot:SetNWBool("HALO_Critical",self.CriticalDamage);
		end

		if !self.crashing then
			self:EmitSound("ambient/machines/wall_crash1.wav")
			util.ScreenShake(self:GetPos(), 500, 500, 1, 500)
			ParticleEffectAttach("mr_hugefire_1a", PATTACH_POINT_FOLLOW, self, 1)
			self.crashing = true

			timer.Simple(self.CriticalExplodeTime, function()
				if IsValid(self) then
					self:DoFullExplode()
				end
			end)
		end
	end


	if((self.VehicleHealth)<=0 and !self.Done) then
		self:Bang() -- Go boom
	end
end

/*
concommand.Add("test_vb", function(ply)
local v;
for k,va in pairs(ents.FindInSphere(ply:GetPos(), 50)) do
	if va:GetClass() == "fo4_vb02" or va:GetClass() == "fo3_vb02" then
		v = va;
		break
	end
end
-- --
local dmg = DamageInfo()
dmg:SetDamage( 20000 )
dmg:SetDamage( 100000 )
dmg:SetAttacker( ply )
dmg:SetInflictor( ply )

v:TakeDamageInfo( dmg )
end)*/

function ENT:ToggleDoors()
	if(self.NextUse.Doors < CurTime()) then
		if(self.Doors) then
			self.Sequence = self:LookupSequence("idle");
			self.Doors = false;
		else
			self.Doors = true;
			self.Sequence = self:LookupSequence("attack");
		end
		self:ResetSequence(self.Sequence);
		//self:SetPlaybackRate(0.01);
		self:SetNWBool("Doors",self.Doors);
		if(IsValid(self.Pilot)) then
			self.Pilot:SetNWBool("HALO_Doors",self.Doors);
		end
		self.NextUse.Doors = CurTime() + 1;
	end
end


function ENT:Use(p)

	if(!self.Inflight and (self.NextUse.Use < CurTime())) then
		self:Enter(p);
	end
end

function ENT:TestLoc(pos)
    //For testing positions (Mainly for effects and weapons)
	local e = ents.Create("prop_physics");
	e:SetPos(pos);
	e:SetModel("models/props_junk/PopCan01a.mdl");
	e:Spawn();
	e:Activate();
	e:SetParent(self);

end

function ENT:FireBlast(pos,gravity,vel,dmg,white,size,snd)
	if(self.NextUse.FireBlast < CurTime()) then
		local e = ents.Create("plasma_blast");

		e.Damage = dmg or 600;
		e.IsWhite = white or false;
		e.StartSize = size or 20;
		e.EndSize = e.StartSize*0.75 or 15;


		local sound = snd or Sound("weapons/banshee_shoot.wav");

		e:SetPos(pos);
		e:Spawn();
		e:Activate();
		e:Prepare(self,sound,gravity,vel);
		e:SetColor(Color(255,255,255,1));

		self.NextUse.FireBlast = CurTime() + 3;

		self:SetNWInt("FireBlast",self.NextUse.FireBlast)
	end

end

function ENT:FireTorpedo(pos,target,vel,dmg,c,size,ion,snd)

	local e = ents.Create("guided_blast");

	e.Damage = dmg or 600;
	e.SpriteColour = c or Color(255,255,255,255);
	e.StartSize = size or 20;
	e.EndSize = e.StartSize*0.75 or 15;
	e.Ion = ion or false;

	local sound = snd or Sound("weapons/hornet_missle.wav");
	e:SetPos(pos);
	e:SetAngles(self:GetAngles())
	e:SetCollisionGroup(COLLISION_GROUP_PROJECTILE);

	e:PrepareTorpedo(self,sound,vel);
	e:SetColor(Color(255,255,255,1));
	e.Ang = self:GetAngles();

	if(IsValid(target)) then
		e.Target = target;
		e.Targetting = true;
	end
	e:Spawn();
	e:Activate();
    constraint.NoCollide(self,e,0,0)
end


function ENT:ResetThrottle()

	for k,v in pairs(self.Throttle) do
		self.Throttle[k] = 0;
	end

	for k,v in pairs(self.Accel) do
		self.Accel[k] = 0;
	end

	self.Acceleration = 1;
end

function ENT:Handbrake()

	for k,v in pairs(self.Throttle) do
		self.Throttle[k] = 0;
	end
	self.Accel.FWD = math.Approach(self.Accel.FWD,0,self.AccelSpeed*4)
	self.Handbraking = true;
end

local ZAxis = Vector(0,0,1);
ENT.Roll = 0;
function ENT:PhysicsSimulate( phys, deltatime )
	local FWD = self.ForwardDir or self.Entity:GetForward();
	local UP = self:GetUp() or ZAxis;
	local RIGHT = FWD:Cross(UP):GetNormalized();
	if(!self.Done and !self.Tractored and (!self.DeactivateInWater or (self.DeactivateInWater and self:WaterLevel() < 3))) then
        if(self.Inflight and IsValid(self.Pilot)) then
            local pos = self:GetPos();
            if(!self.CriticalDamage) then
                if(self.Pilot:KeyDown(IN_FORWARD)) then
                    self.Accel.FWD = math.Approach(self.Accel.FWD,self.ForwardSpeed,self.AccelSpeed)
                elseif(self.Pilot:KeyDown(IN_BACK)) then
                    self.Accel.FWD = math.Approach(self.Accel.FWD,(self.ForwardSpeed/2)*-1,self.AccelSpeed)
                else
                    self.Accel.FWD = math.Approach(self.Accel.FWD,0,self.AccelSpeed)
                end

                if(self.CanRoll) then
                    if(self.Pilot:KeyDown(IN_MOVERIGHT)) then
                        self.Roll = self.Roll + 3;
                    elseif(self.Pilot:KeyDown(IN_MOVELEFT)) then
                        self.Roll = self.Roll - 3;
                    elseif(self.Pilot:KeyDown(IN_RELOAD)) then
                        self.Roll = 0;
                    end
                elseif(self.CanStrafe) then
                    if(self.Pilot:KeyDown(IN_MOVERIGHT)) then
                        self.Accel.RIGHT = math.Approach(self.Accel.RIGHT,self.UpSpeed/1.2,self.AccelSpeed)
                        self.Roll = 20;
                    elseif(self.Pilot:KeyDown(IN_MOVELEFT)) then
                        self.Accel.RIGHT = math.Approach(self.Accel.RIGHT,(self.UpSpeed/1.2)*-1,self.AccelSpeed)
                        self.Roll = -20;
                    else
                        self.Accel.RIGHT = math.Approach(self.Accel.RIGHT,0,self.AccelSpeed)
                        self.Roll = 0;
                    end
                end


                if(self.Pilot:KeyDown(IN_JUMP) and !self.Pilot:KeyDown(IN_RELOAD)) then
                    self.Accel.UP = math.Approach(self.Accel.UP,self.UpSpeed,self.AccelSpeed)
                elseif(self.Pilot:KeyDown(IN_DUCK) and !self.Pilot:KeyDown(IN_RELOAD)) then
                    self.Accel.UP = math.Approach(self.Accel.UP,-self.UpSpeed,self.AccelSpeed)
                else
                    self.Accel.UP = math.Approach(self.Accel.UP,0,self.AccelSpeed)
                end


            end
            self:SetNWInt("Speed",self.Accel.FWD);
            if(IsValid(self.Pilot)) then
                self.Pilot:SetNWInt("HALO_Speed",self.Accel.FWD);
            end

            if(!self.Hover) then
                if(self.Accel.FWD <= 50 and self.Accel.FWD >= -50 and self.Accel.RIGHT <= 50 and self.Accel.RIGHT >= -50 and self.Accel.UP <= 50 and self.Accel.UP >= -50) then return end;
            end

            local velocity = self:GetVelocity();
            local aim = self.Pilot:GetAimVector();
            local ang = aim:Angle();
            local weight_roll = (phys:GetMass()/100)/1.5

            local ExtraRoll = math.Clamp(math.deg(math.asin(self:WorldToLocal(pos + aim).y)),-25-weight_roll,25+weight_roll); -- Extra-roll - When you move into curves, make the shuttle do little curves too according to aerodynamic effects
            local mul = math.Clamp((velocity:Length()/1700),0,1); -- More roll, if faster.
            local ExtraRoll = math.Clamp(math.deg(math.asin( self:WorldToLocal(pos + aim).y)),-25-weight_roll,25+weight_roll); -- Extra-roll - When you move into curves, make the shuttle do little curves too according to aerodynamic effects
			local mul = math.Clamp((velocity:Length()/1700),0,1); -- More roll, if faster.

            local oldRoll = ang.Roll;
            ang.Roll = (ang.Roll + self.Roll - ExtraRoll*mul) % 360;
            if (ang.Roll!=ang.Roll) then ang.Roll = oldRoll; end -- fix for nan values that cause despawing/crash.

			if self.MaxAngForce then
				self.FlightPhys.maxangular = self.MaxAngForce
			end

			if self.LockHover then
				ang.p = 0
			end

            if(self.HasLookaround) then
                if(self.Pilot:KeyPressed(IN_SCORE) or self.Pilot:KeyReleased(IN_SCORE)) then
                    self.Pilot:SetEyeAngles(self:GetAngles());
                end

                if(!self.Pilot:KeyDown(IN_SCORE)) then
                    self.FlightPhys.angle = ang;
                end
            else
                self.FlightPhys.angle = ang;
            end

            self.FlightPhys.deltatime = deltatime;

            local newZ;
            if(self.AutoCorrect or Should_AlwaysCorrect) then
                local heightTrace = util.TraceLine({
                    start = self:GetPos(),
                    endpos = self:GetPos()+Vector(0,0,-100),
                    filter = {self:GetChildEntities()},
                })
                if(heightTrace.Hit) then
                    local nextPos = self:GetPos()+(FWD*self.Accel.FWD)+(UP*self.Accel.UP)+(RIGHT*self.Accel.RIGHT);
                    if(nextPos.z <= heightTrace.HitPos.z + 100) then
                        newZ = heightTrace.HitPos.z + 100;
                        self.Accel.FWD = math.Clamp(self.Accel.FWD,0,1000);
                    end
                end

                local forwardTrace = util.TraceLine({
                    start = self:GetPos(),
                    endpos = self:GetPos()+self:GetForward()*(self.ShipLength+100),
                    filter = {self:GetChildEntities()},
                })

                if(forwardTrace.Hit) then
                    self.Accel.FWD = 0;
                end

            end
            phys:Wake();
            local fPos = pos+(FWD*self.Accel.FWD)+(UP*self.Accel.UP);
            if(self.CanStrafe) then
                fPos = fPos+(RIGHT*self.Accel.RIGHT);
            end

            if(newZ) then
                self.FlightPhys.pos = Vector(fPos.x,fPos.y,newZ);
            else
                self.FlightPhys.pos = fPos;
            end

            if(!self.CriticalDamage and !self.BeingWarped) then
                phys:ComputeShadowControl(self.FlightPhys);
            end
		elseif self.LockHover then
            if(!self.CriticalDamage and !self.BeingWarped) then
				self.FlightPhys.deltatime = deltatime;
				self.FlightPhys.angle = self.StandbyAngles or Angle(0,self:GetAngles().y,0);
                self.FlightPhys.deltatime = deltatime;
                self.FlightPhys.pos = self:GetPos()+UP;
                phys:ComputeShadowControl(self.FlightPhys);
            end
        else
            if(self.ShouldStandby and self.CanStandby) then
                self.FlightPhys.angle = self.StandbyAngles or Angle(0,self:GetAngles().y,0);
                self.FlightPhys.deltatime = deltatime;
                self.FlightPhys.pos = self:GetPos()+UP;
                phys:ComputeShadowControl(self.FlightPhys);
            end
        end
	end
end


function HALOVehStandbyPickup(p,e)
	if(IsValid(e) and e.IsHALOVehicle) then
		if(e.CanStandby) then
			e.ShouldStandby = false;
		end
	end
end
hook.Add( "PhysgunPickup", "HALOVehStandbyPickup", HALOVehStandbyPickup )

function HALOVehStandbyDrop(p,e)
	if(IsValid(e) and e.IsHALOVehicle) then
		if(e.CanStandby) then
			e.ShouldStandby = true;
		end
	end
end
hook.Add("PhysgunDrop", "HALOVehStandbyDrop", HALOVehStandbyDrop);

function ENT:PhysicsCollide(cdat, phys)

	if (self.PhysCollFunc) then
		self:PhysCollFunc(cdat, phys)
	end

	if(self.LastCollide < CurTime() and Should_Collisions and !cdat.HitEntity:IsPlayer()) then
		local mass = (cdat.HitEntity:GetClass() == "worldspawn") and 1000 or cdat.HitObject:GetMass() --if it's worldspawn use 1000 (worldspawns physobj only has mass 1), else normal mass

		local s = cdat.TheirOldVelocity:Length();
		if(s < 0) then
			s = s * -1;
		elseif(s == 0) then
			s = 1;
		end
		local dmg = (cdat.OurOldVelocity:Length()*s*math.Clamp(mass, 0, 1000))/1000;

		dmg = dmg * self.CollisionDamageMulti;

		self.Accel.FWD = math.Clamp(self.Accel.FWD - dmg,0, self.Accel.FWD);
		self.Throttle.FWD = math.Clamp(self.Throttle.FWD - dmg,0, self.Throttle.FWD);
		self:TakeDamage(dmg)
		self.LastCollide = CurTime() + self.CollideTimer;

	end
end

-- -- --
--SPINNING
--BY EXTRA
function ENT:PhysCollFunc()
if not self.Done or self.FullExplode then return end
-- --
self:DoFullExplode()
end

function ENT:DoFullExplode()
	if self.FullExplode then return end
	--
	local hook_id = "VBSPIN_"..self:GetCreationID().."_spin"
	hook.Remove("Think", hook_id)
	timer.Destroy("HOOK_Rem_"..hook_id)
	--
	self:SetColor(Color(0,0,0))
	self.FullExplode = true
	if(self.Inflight) then
		self:Exit(true); --Let the player out...
	end

	local ent = ents.Create( "env_explosion" )
	ent:SetPos( self:GetPos() )
	ent:SetOwner( self )
	ent:Spawn()
	ent:SetKeyValue( "iMagnitude", "450" )
	ent:Fire( "Explode", 0, 0 )

	for k,v in pairs(ents.FindInSphere(self:GetPos(),300)) do
		if(IsValid(v) and v != self) then
			if((v.IsHALOVehicle and !v.Done) or (!v.IsHALOVehicle and v:GetParent() != self)) then
				local dist = (self:GetPos() - v:GetPos()):Length();
				v:TakeDamage(math.Clamp(500 - dist,100,500));
			end
		end
	end
	--
	local fx = EffectData();
	fx:SetOrigin(self:GetPos());
	fx:SetMagnitude(1000)
	util.Effect("Explosion",fx,true,true);

	local fx1 = EffectData();
	fx1:SetOrigin(self:GetPos());
	fx1:SetAngles(Angle(0,0,90))
	fx1:SetScale(1.5)
	util.Effect("haloexplosion",fx,true,true);
	--
	util.ScreenShake(self:GetPos(), 1000, 1000, 3, 1000)
	--
	timer.Simple(0.5, function()
		if IsValid(self) then
			local ent = ents.Create( "env_explosion" )
			ent:SetPos( self:GetPos() )
			ent:SetOwner( self )
			ent:Spawn()
			ent:SetKeyValue( "iMagnitude", "450" )
			ent:Fire( "Explode", 0, 0 )

			local effectData = EffectData()
			effectData:SetScale(1)
			effectData:SetOrigin(self:GetPos())
			util.Effect( "nuke_blastwave_fallout", effectData )
			--
			self:Remove()
		end
	end)
end

function ENT:Bang()
	if self.Done then return end
	--
	self:Ignite(60)

	self:EmitSound("veh/vb-blow.wav")

	ParticleEffectAttach( "mr_bigfire_1", PATTACH_ABSORIGIN_FOLLOW, self, 1 )
	-- --
	local hook_id = "VBSPIN_"..self:GetCreationID().."_spin"
	self.Done = true

	if self.DontSpin then return end
	-- --
	local hook_id = "VBSPIN_"..self:GetCreationID().."_spin"
	hook.Add("Think", hook_id, function()
		if !IsValid(self) then
			hook.Remove("Think", hook_id)
			return
		end
		-- --
		local ang = self:GetAngles()
		//self:SetAngles( Angle(ang.p, ang.y + 1, ang.r + 1) )
		local phys = self:GetPhysicsObject()
		phys:AddAngleVelocity( Vector(3, 0, math.random(2,7)) )
		phys:AddVelocity( Vector(math.random(-6, 6), math.random(-4, 4), 0) )
	end)

	timer.Create("HOOK_Rem_"..hook_id, 25, 1, function()
		hook.Remove("Think", hook_id)
	end)
end
-- -- --

end

function ENT:GetChildEntities()
	local filter = {};

	local i = 1;
	for k,v in pairs(ents.GetAll()) do
		if(v:GetParent() == self) then
			filter[i] = v;
			i = i+1;
		end
	end
	filter[i] = self;

	local p;
	if CLIENT then
		p = LocalPlayer();
	elseif SERVER then
		if(IsValid(self.Pilot)) then
			p = self.Pilot;
		end
	end
	if(IsValid(p)) then
		filter[i+1] = p;
	end
	return filter;
end

if CLIENT then

	function ENT:Draw()
		self:DrawModel()
		local avatar = self:GetNWEntity("PilotAvatar");
		if(IsValid(avatar)) then
			local p = LocalPlayer();
			local Flying = p:GetNWBool("Flying"..self.Vehicle);
			if(Flying and (HALO_GetFPV() or self:GetFPV())) then
				avatar:SetNoDraw(true);
			else
				avatar:DrawModel();
			end
		end
	end

	local ShipName = "";
	local ShouldFPV;
	function ENT:Initialize()
		self.FlightPhys = {
			secondstoarrive	 = 1,
			maxangular       = 5000,
			maxangulardamp   = 10000,
			maxspeed         = 1000000,
			maxspeeddamp     = 500000,
			dampfactor       = 0.8,
			teleportdistance = 5000
		}
		ShipName = self.Vehicle;
		self.FXEmitter = ParticleEmitter(self:GetPos())
		self.SoundsOn = {}
		if (self.Sounds and self.Sounds.Engine) then
			self.EngineSound = self.EngineSound or CreateSound(self.Entity,self.Sounds.Engine);
		end
		FPV = false;
		surface.CreateFont( "HUD_Health", {
			font = "Aurebesh",
			size = ScrH()/60,
			weight = 1000,
			blursize = 0,
			scanlines = 0,
			antialias = false,
			underline = false,
			italic = false,
			strikeout = false,
			symbol = true,
			rotary = false,
			shadow = false,
			additive = true,
			//outline = true,
			outline = false,
		} )

		ShouldFPV = self.CanFPV;
		if(FPV and !self.IsFPV) then
			FPV = false;
		end

		LocalPlayer().HALO_ViewDistance = LocalPlayer().HALO_ViewDistance or 0;
		self.Filter = self:GetChildEntities();
	end


	local Health = 1000;
	local Overheat = 0;
	local Overheated = false;
	local FPV = false;
	local Critical = false;
	local ShouldLock = true;
	local OverheatAmount = 50;
	local Doors = false;
	local Land = false;
	local TakeOff = false;
	ENT.NextView = CurTime();
	ENT.NextHide = CurTime();
	function ENT:Think()

		local p = LocalPlayer();
		local Flying = self:GetNWBool("Flying".. self.Vehicle);
		local IsFlyingHalo = p:GetNWBool("Flying"..self.Vehicle);
		//local Doors = self:GetNWBool("Doors");


		local IsDriver = p:GetNWEntity(self.Vehicle) == self.Entity;
		if IsFlyingHalo or (self:GetNWBool("EngineOn") and p:GetPos():DistToSqr(self:GetPos()) <= 1000000) then
			local avatar = self:GetNWEntity("PilotAvatar");
			if(IsValid(avatar)) then
				self:Draw();
				local count = table.Count(self.Filter);
				if(!IsValid(self.Filter[count+1])) then
					self.Filter[count+1] = avatar;
				end
			end
			p.IsFlyingHalo = IsFlyingHalo;
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
			if(self.SoundsOn.Engine) then
				self.EngineSound:ChangePitch(math.Clamp(60 + pitch/25,75,100) + doppler,0);
			end
			if(self.CanFPV) then
				if(p:KeyDown(IN_WALK)) then
					if(self.NextView < CurTime()) then
						if(self.IsFPV) then
							FPV = false;
							self.IsFPV = false;
						else
							FPV = true;
							self.IsFPV = true;
						end

						self.NextView = CurTime() + 1;
					end
				end
			end

			if(ShouldFPV != self.CanFPV) then
				ShouldFPV = self.CanFPV;
			end


			Overheat = p:GetNWInt("HALO_Overheat") or self:GetNWInt("Overheat");
			Overheated = p:GetNWBool("HALO_Overheated") or self:GetNWBool("Overheated");
			Critical = p:GetNWBool("HALO_Critical") or self:GetNWBool("Critical");
			ShouldLock = p:GetNWBool("HALO_ShouldLock") or self:GetNWBool("ShouldLock");
			OverheatAmount = self:GetNWInt("OverheatAmount");

			if(!p.HALO_HideHud) then
				Health = p:GetNWInt("HALO_Health") or self:GetNWInt("Health");
				Speed = p:GetNWInt("HALO_Speed") or self:GetNWInt("Speed");
				MaxSpeed = p:GetNWInt("HALO_MaxSpeed") or self:GetNWInt("MaxSpeed");
				Doors = p:GetNWBool("HALO_Doors") or self:GetNWBool("Doors");
				LandDistance = self:GetNWInt("LandDistance");
			end

			if(input.IsMouseDown(MOUSE_MIDDLE)) then
				p.HALO_ViewDistance = 0;
			elseif(input.IsKeyDown(KEY_H) and self.NextHide < CurTime() and !p.HALOVehicles_IsChatting) then
				if(p.HALO_HideHud) then
					p.HALO_HideHud = false;
				else
					p.HALO_HideHud = true;
				end
				self.NextHide = CurTime() + 1;
			end
			Land = p:GetNWBool("HALO_Land") or self:GetNWBool("Land");
			TakeOff = p:GetNWBool("HALO_TakeOff") or self:GetNWBool("TakeOff");

			if(self.EnginePos and self.EnginePos[1]) then
				if(Health <= self.StartHealth * 0.4) then
					local pos = self.EnginePos[1];
					self:Smoke(true,pos);
				end
			end
		else
			self:StopClientsideSound("Engine");
			p.IsFlyingHalo = false;
		end


		self.Allegiance = self:GetNWString("Allegiance");
	end

	function ENT:Smoke(b,pos)

		local p = LocalPlayer();
		local v = p:GetNetworkedEntity(self.Vehicle,NULL);

		if(b) and (IsValid(v) and v==self) then
			local fwd = self:GetForward()
			local vel = self:GetVelocity()
			local roll = math.Rand(-90,90)

			local particle = self.FXEmitter:Add("effects/blood2",pos)
			particle:SetVelocity(vel - 500*fwd)
			particle:SetDieTime(0.75)
			particle:SetStartAlpha(200)
			particle:SetEndAlpha(0)
			particle:SetStartSize(14)
			particle:SetEndSize(20)
			particle:SetColor(40,40,40)
			particle:SetRoll(roll)

			--self.Emitter:Finish()
		end
	end


	function ENT:EngineEffects(sprite,color)

		local normal = (self:GetForward() * -1):GetNormalized()
		local roll = math.Rand(-90,90)
		local id = self:EntIndex();

		for k,v in pairs(self.EnginePos) do
			local red = self.FXEmitter:Add(sprite,v)
			red:SetVelocity(normal)
			red:SetDieTime(FrameTime()*1.25)
			red:SetStartAlpha(color.a)
			red:SetEndAlpha(color.a)
			red:SetStartSize(14)
			red:SetEndSize(10)
			red:SetRoll(roll)
			red:SetColor(color.r,color.g,color.b)

			local dynlight = DynamicLight((id + 4096) * k);
			dynlight.Pos = v;
			dynlight.Brightness = 5;
			dynlight.Size = 200;
			dynlight.Decay = 1024;
			dynlight.R = color.r;
			dynlight.G = color.g;
			dynlight.B = color.b;
			dynlight.DieTime = CurTime()+1;
		end
	end

	hook.Add("StartChat","HALO_StartChat",function()
		LocalPlayer().HALOVehicles_IsChatting = true;
	end)

	hook.Add("FinishChat","HALO_FinishChat",function()
		LocalPlayer().HALOVehicles_IsChatting = false;
	end)

	hook.Add("PlayerBindPress","HALO_MouseWheel", function( p, bind, pressed )

		if(p.IsFlyingHalo) then
			if(bind == "invnext") then
				p.HALO_ViewDistance = p.HALO_ViewDistance + 5;
			elseif(bind == "invprev") then
				p.HALO_ViewDistance = p.HALO_ViewDistance - 5;
			end
			p.HALO_ViewDistance = math.Clamp(p.HALO_ViewDistance,-500,500)
		end

	end);


	function ENT:OnRemove()
		if (self.EngineSound) then
			self.EngineSound:Stop();
		end
		FPV = false;
		if(IsValid(self.FXEmitter)) then
			self.FXEmitter:Finish();
		end
	end

	function ENT:StartClientsideSound(mode)
		if(not self.SoundsOn[mode]) then
			if(mode == "Engine" and self.EngineSound) then
				self.EngineSound:Stop();
				self.EngineSound:SetSoundLevel(100);
				self.EngineSound:PlayEx(100,100);
			end
			self.SoundsOn[mode] = true;
		end
	end

	--################# Stops a sound clientside @aVoN
	function ENT:StopClientsideSound(mode)
		if(self.SoundsOn[mode]) then
			if(mode == "Engine" and self.EngineSound) then
				self.EngineSound:FadeOut(2);
			end
			self.SoundsOn[mode] = nil;
		end
	end

	local View = {};
	function HALOVehicleView(self,dist,udist,fpv_pos,lookaround)
		local p = LocalPlayer();
		local pos,face;

		if(IsValid(self)) then
			if(self.IsFPV and ShouldFPV) then
				pos = fpv_pos;
				face = self:GetAngles() + Angle(45,0,0);
				if(lookaround and p:KeyPressed(IN_SCORE)) then
					p:SetEyeAngles(Angle(0,0,0))
				end
				if(lookaround and p:KeyDown(IN_SCORE) and !p:KeyPressed(IN_SCORE)) then
					local eAngles = p:EyeAngles();
					local newAng = self:GetAngles()+eAngles;
					face = Angle(newAng.p,math.Clamp(newAng.y,self:GetAngles().y-90,self:GetAngles().y+90),newAng.r);
				end
			else
				local aim = LocalPlayer():GetAimVector();
				//aim:Rotate(self:GetAngles())
				local tpos = self:GetPos()+self:GetUp()*udist+aim:GetNormal()*-(dist+p.HALO_ViewDistance);
				local tr = util.TraceLine({
					start = self:GetPos(),
					endpos = tpos,
					filter = self.Filter,
				})
				pos = tr.HitPos or tpos;
			//	pos = self:GetPos()+self:GetUp()*udist+self:GetForward()*-(dist+p.HALO_ViewDistance);
				face = ((self:GetPos() + Vector(0,0,100))- pos):Angle();
			//	face = self:GetAngles();
			end
			View.origin = pos;
			View.angles = face;
			return View;
		end

	end

	function HALO_CovenantReticles(self)


		local tr = util.TraceLine( {
			start = self:GetPos(),
			endpos = self:GetPos() + self:GetForward()*10000,
			filter = {self},
		} )

		surface.SetTextColor( 255, 255, 255, 255 );

		local vpos = tr.HitPos;
		local material = "hud/reticle_cov.png"
		surface.SetMaterial( Material( material, "noclamp" ) )
		if(ShouldLock) then
			local Lock = HALO_ReticleLock(self);
			if(Lock) then
				vpos = Lock
				material = "hud/reticle_cov_lock.png"

			end;
		end

		local x,y = HALO_XYIn3D(vpos);


		//surface.SetTextPos( x, y );
		//surface.DrawText( "+" );
		local w = ScrW()/100*2;
		local h = w;
		surface.SetDrawColor( color_white )
		surface.SetMaterial( Material( material, "noclamp" ) )
		surface.DrawTexturedRectUV( x - w/2 , y - h/2, w, h, 0, 0, 1, 1 )
	end

	function HALO_HeavyReticles(self)


		local tr = util.TraceLine( {
			start = self:GetPos(),
			endpos = self:GetPos() + self:GetForward()*10000,
			filter = {self},
		} )

		surface.SetTextColor( 255, 255, 255, 255 );

		local vpos = tr.HitPos;
		local material = "hud/reticle_heavy.png"
		surface.SetMaterial( Material( material, "noclamp" ) )
		if(ShouldLock) then
			local Lock = HALO_ReticleLock(self);
			if(Lock) then
				vpos = Lock
				material = "hud/reticle_heavy.png"

			end;
		end

		local x,y = HALO_XYIn3D(vpos);


		//surface.SetTextPos( x, y );
		//surface.DrawText( "+" );
		local w = ScrW()/100*2;
		local h = w;
		surface.SetDrawColor( color_white )
		surface.SetMaterial( Material( material, "noclamp" ) )
		surface.DrawTexturedRectUV( x - w/2 , y - h/2, w, h, 0, 0, 1, 1 )
	end

	function HALO_UNSCReticles(self)


		local tr = util.TraceLine( {
			start = self:GetPos(),
			endpos = self:GetPos() + self:GetForward()*10000,
			filter = {self},
		} )

		surface.SetTextColor( 255, 255, 255, 255 );

		local vpos = tr.HitPos;
		local material = "hud/reticle_unsc.png"
		surface.SetMaterial( Material( material, "noclamp" ) )
		if(ShouldLock) then
			local Lock = HALO_ReticleLock(self);
			if(Lock) then
				vpos = Lock
				material = "hud/reticle_unsc_lock.png"

			end;
		end

		local x,y = HALO_XYIn3D(vpos);


		//surface.SetTextPos( x, y );
		//surface.DrawText( "+" );
		local w = ScrW()/100*2;
		local h = w;
		surface.SetDrawColor( color_white )
		surface.SetMaterial( Material( material, "noclamp" ) )
		surface.DrawTexturedRectUV( x - w/2 , y - h/2, w, h, 0, 0, 1, 1 )
	end

	function HALO_BlastIcon(self,delay)

		local time = self:GetNWInt("FireBlast");
		if(time - CurTime() > 0) then
			surface.SetDrawColor( color_white )
			if(!delay) then
				delay = 3;
			end

			local w = ScrW()/100*3.5;
			local h = ScrH()/100*1.75;
			//surface.SetDrawColor(color_white);
			local tr = util.TraceLine({
				start = self:GetPos(),
				endpos = self:GetPos() + self:GetForward()*10000,
				filter = {self},
			})

			surface.SetTextColor( 255, 255, 255, 255 );

			local vpos = tr.HitPos;
			if(ShouldLock) then
				local Lock = HALO_ReticleLock(self);
				if(Lock) then
					vpos = Lock
				end;
			end
			local x,y = HALO_XYIn3D(vpos);

			local per = (time-CurTime())/delay;

			surface.SetMaterial( Material( "hud/hmissile_outline.png", "noclamp" ) )
			surface.DrawTexturedRectUV( x - w/2, y - ScrW()/100*2, w, h, 0, 0, 1, 1 )

			surface.SetMaterial( Material( "hud/hmissile_icon.png", "noclamp" ) )
			surface.DrawTexturedRectUV( x - w/2, y - ScrW()/100*2, w*per, h, 0, 0, per, 1 )
		end

	end

	function HALO_ReticleLock(self)
		if(!ShouldLock) then return false end;
		local bounds1,bounds2 = self:GetModelBounds();
		for l,w in pairs(ents.FindInBox(self:LocalToWorld(bounds1),self:LocalToWorld(bounds2)+self:GetForward()*10000)) do
			if(w.IsHALOVehicle and !w.DontLock and w != self and w:GetNWString("Allegiance") != self.Allegiance) then
				tr = util.TraceLine({
					start = self:GetPos(),
					endpos = w:GetPos(),
					filter = self,
				})
				if(!tr.HitWorld) then
					local vpos = w:GetPos()+w:GetUp()*(w:GetModelRadius()/3);
					return vpos;

				end
			end
		end
		return false;
	end

	function HALO_HUD_DrawHull(StartHealth)

		if(LocalPlayer().HALO_HideHud) then return end;

		surface.SetFont("HUD_Health");
		local w = ScrW()/3.5;
		local h = w / 8;

		local x = ScrW() / 2.8;
		local y = ScrH() / 40;

		local per = ((Health/StartHealth)*100)/100;

		surface.SetDrawColor( color_white )
		surface.SetMaterial( Material( "hud/hull/hpbar_under.png", "noclamp" ) )

		surface.DrawTexturedRectUV( x, y, w, h, 0, 0, 1, 1 )

		if(Critical) then
			if(Health > StartHealth * 0.1) then
				surface.SetDrawColor(Color(50,120,255,255));
			else
				surface.SetDrawColor(Color(255,35,35,255));
			end
		end

		local barX = x + w * 0.003;
		local barY = y + h * 0;
		local barW = w * 0.993;
		local barH = h * 1;
		surface.SetMaterial( Material( "hud/hull/hpbar.png", "noclamp" ) )
		surface.DrawTexturedRectUV( barX, barY, barW*per, barH, 0, 0, per, 1 )

		surface.SetMaterial( Material( "hud/hull/hpbar_frame.png", "noclamp" ) )
		surface.SetDrawColor( color_white )
		surface.DrawTexturedRectUV( x, y, w, h, 0, 0, 1, 1 )
	end

	function HALO_HUD_DrawSpeedometer()

		if(LocalPlayer().HALO_HideHud) then return end;

		local n = Speed;
		local c = color_white;
		if(n < 0) then
			c = Color(255,50,50,255);
			n = n * -1;
		end


		local w = ScrW()/4;
		local h = w / 9;

		local x = ScrW() / 2.67;
		local y = ScrH() / 11;

		local per = math.Clamp(((n/MaxSpeed)*100)/100,0,1);

		surface.SetDrawColor(color_white)
		surface.SetMaterial( Material( "hud/speedo/speed_empty.png", "noclamp" ) )
		surface.DrawTexturedRectUV( x, y, w, h, 0, 0, 1, 1 )

		local barX = x + w * 0.003;
		local barY = y + h * 0;
		local barW = w * 0.993;
		local barH = h * 1;
		surface.SetDrawColor(c)
		surface.SetMaterial( Material( "hud/speedo/speed.png", "noclamp" ) )
		surface.DrawTexturedRectUV( barX, barY, barW*per, barH, 0, 0, per, 1 )

		surface.SetDrawColor(color_white)
		surface.SetMaterial( Material( "hud/speedo/speed_frame.png", "noclamp" ) )
		surface.DrawTexturedRectUV( x, y, w, h, 0, 0, 1, 1 )
	end

	function HALO_HUD_DrawOverheating(self)

		//surface.SetFont("HUD_Overheat");
		if(Overheated) then
			surface.SetDrawColor(255,0,0,255);
		else
			if(Overheat > 0 and Overheat <= 16) then
				surface.SetDrawColor(128,255,0,255);
			elseif(Overheat > 16 and Overheat <= 32) then
				surface.SetDrawColor(255,255,0,255);
			else
				surface.SetDrawColor(255,128,0,255);
			end
		end

		local w = ScrW()/100*3.5;
		local h = ScrH()/100*0.5;
		//surface.SetDrawColor(color_white);
		local tr = util.TraceLine( {
			start = self:GetPos(),
			endpos = self:GetPos() + self:GetForward()*10000,
			filter = {self},
		} )

		//surface.SetTextColor( 255, 255, 255, 255 );

		local vpos = tr.HitPos;
		if(ShouldLock) then
			local Lock = HALO_ReticleLock(self);
			if(Lock) then
				vpos = Lock
			end;
		end
		local x,y = HALO_XYIn3D(vpos);


		local o = (Overheat/50)*100;
		local per = o/100;

		//surface.SetMaterial( Material( "hud/overheat_bar.png", "noclamp" ) )
		//surface.DrawTexturedRectUV( x - w/2, y + ScrW()/100*2 - h/2, w, h, 0, 0, per, 1 )
		w = w*per;
		surface.DrawRect(x - w/2,y+ScrW()/100*1.5,w,h)

	end

	local Glass = surface.GetTextureID("models/props_c17/frostedglass_01a_dx60");
	function HALO_HUD_FPV(HUD)
		surface.SetTexture(Glass);
		surface.SetDrawColor(255,255,255,50);
		surface.DrawTexturedRect(0,0,ScrW()*10,ScrH());

		surface.SetTexture(HUD) -- Print the texture to the screen
		surface.SetDrawColor(255,255,255,255) -- Colour of the HUD
		surface.DrawTexturedRect(0,0,ScrW(),ScrH()) -- Position, Size

	end

	local compassBack = surface.GetTextureID("hud/halo_compass_bg");
	local compassDisk = surface.GetTextureID("hud/halo_compass_disk");
	local locator = surface.GetTextureID("hud/halo_compass_ping");
	function HALO_HUD_Compass(self,fpvX,fpvY)

		if(LocalPlayer().HALO_HideHud) then return end;

		local p = LocalPlayer();

		local size = ScrW()/10;

		local x,y;
		if(self:GetFPV()) then
			x = ScrW()/2;
			y = ScrH()/4*3.1;
			if(fpvX) then
				x = fpvX;
			end
			if(fpvY) then
				y = fpvY;
			end
		else
			x = size*1;
			y = x*4.6;
		end

		surface.SetTexture(compassBack);
		surface.SetDrawColor(255,255,255,255);
		surface.DrawTexturedRectRotated( x,y, size, size, 0);

		local rotate = (self:GetAngles().y - 90)*-1;

		local al = HALO_LightOrDark(self.Allegiance);
		local maxDist = 5000;
		local ships = ents.FindInSphere(self:GetPos(),maxDist);
		for k,v in pairs(ships) do
			if(IsValid(v) and v.IsHALOVehicle and v != self and !v.IsCapitalShip) then

				local alleg = HALO_LightOrDark(v.Allegiance);
				if(al != alleg) then

					local dist = (self:GetPos() - v:GetPos()):Length() / maxDist;
					local a = 1 - dist;

					surface.SetDrawColor(255,255,255,255*a) -- Colour of the HUD
					local r = (((self:GetPos() - v:GetPos()):Angle().y)-90) + rotate - 180;
					surface.SetTexture(locator) -- Print the texture to the screen
					surface.DrawTexturedRectRotated( x,y, size, size, r)
				end
			end
		end

		surface.SetDrawColor(255,255,255,255) -- Colour of the HUD
		surface.SetTexture(compassDisk) -- Print the texture to the screen
		surface.DrawTexturedRectRotated( x,y, size, size, rotate)

	end

	function HALO_LightOrDark(allegiance)

		if(allegiance == "Covenant" or allegiance == "Forerunner") then
			return "Dark";
		elseif(allegiance == "UNSC") then
			return "Light";
		end
		return "Neutral";
	end

	function HALO_XYIn3D(pos)
		local screen = pos:ToScreen();
		local x,y;
		for k,v in pairs(screen) do
			if k=="x" then
				x = v;
			elseif k=="y" then
				y = v;
			end
		end
		return x,y;
	end

	function ENT:GetFPV()
		return self.IsFPV;
	end

	function HALO_GetFPV()
		return FPV;
	end
end
