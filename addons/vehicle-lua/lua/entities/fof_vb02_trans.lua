ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Base = "haloveh_base"
ENT.Type = "vehicle"

ENT.PrintName = "VB-02 Vertibird Transport"
ENT.Author = "SGM / Extra"
--- BASE AUTHOR: Liam0102 ---
-- Edited by Extra
ENT.Category = "Vertibirds"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = true;
ENT.AdminSpawnable = true;

ENT.EntModel = "models/sentry/vertibirds/vb02_trans.mdl"
ENT.FlyModel = "models/sentry/vertibirds/vb02_trans_fly.mdl"
ENT.Vehicle = "fof_vb02_trans"
ENT.StartHealth = 20000;
ENT.Allegiance = "";

ENT.DontSpin = true
ENT.LockHover = true

list.Set("Fallout Vehicles", ENT.PrintName, ENT);

if SERVER then
	function ENT:Think()
		--from fo3_vb02, it functioned when I put it here so I just left it
		local gearTrace=util.QuickTrace(self:GetPos(), (Vector(0,0,-400)), {self})
		if (self.gear_open == 0 && !gearTrace.Hit) then
			if !self.layer_gears then
				self.layer_gears = self:AddLayeredSequence( self:LookupSequence("gears_close"), 1 )
			else
				self:SetLayerSequence(self.layer_gears, self:LookupSequence("gears_close"))
				self:SetLayerCycle(self.layer_gears,0)
				self:EmitSound("ambient/machines/machine3.wav", 35)
			end
			self.gear_open = 1
		elseif (self.gear_open == 1 && gearTrace.Hit && self:GetNWInt("Speed") < 300) then
			self:SetLayerSequence(self.layer_gears, self:LookupSequence("gears_open"))
			self:EmitSound("ambient/machines/machine3.wav", 35)
			self:SetLayerCycle(self.layer_gears,0)
			self.gear_open = 0
		end

		if(IsValid(self.Pilot)) then
			--opens and closes doors
			if self.Pilot:KeyDown(IN_SPEED) and self.lastDoor < CurTime() - 2 then
				if self.doorClose == 0 then
					self.doorClose = 1
					self:DoorPropClosed(true)
					self:SetNWInt("doorClosed",1)

					self.lastDoor = CurTime()

				else
					self.doorClose = 0
					self:DoorPropClosed(false)
					self:SetNWInt("doorClosed",0)

					self.lastDoor = CurTime()
				end
			end
		end

		if(IsValid(self.Pilot) and self.Pilot:KeyDown(IN_RELOAD) and (self:GetSkin() == 0) and (!self.broadcastCooldown or self.broadcastCooldown < CurTime())) then
			if !self.isBroadcasting then
				self.Pilot:ChatPrint("Broadcasting propoganda . . .")
				self.isBroadcasting = "broadcast/enclave_broadcast" .. math.random(1,9) .. ".ogg"
				self:EmitSound(self.isBroadcasting, 130)
			else
				self.Pilot:ChatPrint("Stopping broadcast . . .")
				self:StopSound(self.isBroadcasting)
				self:EmitSound("broadcast/enclave_broadcast_break.ogg", 120, 150)
				self.isBroadcasting = nil
			end

			self.broadcastCooldown = CurTime() + 3
		end

		--think code from base, overwritten for weapon firerate purposes
		if(self.Inflight) then
			if(IsValid(self.Pilot)) then
				if(self.PilotOffset) then
					self.Pilot:SetPos(self:GetPos()+self:GetRight()*self.PilotOffset.x+self:GetForward()*self.PilotOffset.y+self:GetUp()*self.PilotOffset.z);
				else
					self.Pilot:SetPos(self:GetPos() + Vector(self:GetForward()*200,0,200));
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

				if(self.HasDoors) then
					if(IsValid(self.Pilot)) then
						if(self.Pilot:KeyDown(IN_SPEED) and self.NextUse.Doors < CurTime()) then
							self:ToggleDoors()
						end
					end
				end

				if(self.CanShoot and !self.WeaponsDisabled) then
					if(IsValid(self.Pilot)) then // I don't know why I need this here for a second check but when I don't it causes an error
						if (self.Pilot:KeyDown(IN_RELOAD)) then
							if (self.SecondaryAttack) then
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

		self:NextThink(CurTime())
		return true
	end

	ENT.FireSound = Sound("weapons/lightbolt.wav");
	ENT.NextUse = {Wings = CurTime(),Use = CurTime(),Fire = CurTime(),};

	AddCSLuaFile();
	function ENT:SpawnFunction(pl, tr)
		local e = ents.Create("fof_vb02_trans");
		e:SetPos(tr.HitPos + Vector(0,0,0));
		e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw,0));
		e:Spawn();
		e:Activate();
		return e;
	end

	local al = 1;--ADI looks wrong to me should be ENT.al i guess
	function ENT:FireWeapons()
		if(self.NextUse.Fire < CurTime()) then
			for k,v in pairs(self.Weapons) do
				if(!IsValid(v)) then return end;
				local tr = util.TraceLine({
					start = self:GetPos(),
					endpos = self:GetPos()+self:GetForward()*10000 + self:GetUp() * -5000,
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
				self.Bullet.Spread		= Vector(300,300,0)

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
			self.NextUse.Fire = CurTime() + 0.05 --adi fix. This was 0 before..wich would make it run every frame
		end
	end

	function ENT:Initialize()
		self:SetNWInt("Health",self.StartHealth);
		self.Gearup = 0;
		self.doorClose = 0;
		self.lastDoor = 0;
		self.WeaponLocations = {
			Left = self:GetPos()+self:GetForward()*404+self:GetUp()*81.9+self:GetRight()*-62.9,
			Right = self:GetPos()+self:GetForward()*404+self:GetUp()*81.9+self:GetRight()*62.9,
		}
		self.WeaponsTable = {};
		self.BoostSpeed = 600;
		self.ForwardSpeed = 600;
		self.UpSpeed = 100;
		self.AccelSpeed = 2.5;
		self.CanBack = false;
		self.CanStrafe = true;
		self.Cooldown = 2;
		self.CanShoot = true;
		self.DontOverheat = true;
		self.Bullet = HALOCreateBulletStructure(50,"red");
		self.FireDelay = 0.1;
		self.NextBlast = 1;
		self.AlternateFire = true;
		self.FireGroup = {"Left","Right",};
		self.ExitModifier = {x = 50, y = 65, z = 100};
		self.Hover = true;

		self.SeatPos = {
			FrontL = {self:GetPos()+self:GetForward()*295+self:GetRight()*-36+self:GetUp()*128,self:GetAngles()+Angle(0,0,0)},

			MidR1 = {self:GetPos() + self:GetForward() * 40 + self:GetRight() * 20 + self:GetUp() * 110, self:GetAngles() + Angle(0,-90,0)},
			MidR2 = {self:GetPos() + self:GetForward() * 15 + self:GetRight() * 20 + self:GetUp() * 110, self:GetAngles() + Angle(0,-90,0)},
			MidR3 = {self:GetPos() + self:GetForward() * -10 + self:GetRight() * 20 + self:GetUp() * 110, self:GetAngles() + Angle(0,-90,0)},
			MidR4 = {self:GetPos() + self:GetForward() * -35 + self:GetRight() * 20 + self:GetUp() * 110, self:GetAngles() + Angle(0,-90,0)},
			MidR5 = {self:GetPos() + self:GetForward() * -60 + self:GetRight() * 20 + self:GetUp() * 110, self:GetAngles() + Angle(0,-90,0)},

			MidL1 = {self:GetPos() + self:GetForward() * 40 + self:GetRight() * -10 + self:GetUp() * 110, self:GetAngles() + Angle(0,90,0)},
			MidL2 = {self:GetPos() + self:GetForward() * 15 + self:GetRight() * -10 + self:GetUp() * 110, self:GetAngles() + Angle(0,90,0)},
			MidL3 = {self:GetPos() + self:GetForward() * -10 + self:GetRight() * -10 + self:GetUp() * 110, self:GetAngles() + Angle(0,90,0)},
			MidL4 = {self:GetPos() + self:GetForward() * -35 + self:GetRight() * -10 + self:GetUp() * 110, self:GetAngles() + Angle(0,90,0)},
			MidL5 = {self:GetPos() + self:GetForward() * -60 + self:GetRight() * -10 + self:GetUp() * 110, self:GetAngles() + Angle(0,90,0)},
		}

		self:SpawnSeats()
		self:SpawnDoors()
		self:SpawnPilotDoor()
		self.HasLookaround = true;
		self.PilotVisible = true;
		self.PilotPosition = {x=30,y=220,z=135};
		self.PilotAnim = "sit_rollercoaster";

		self.BaseClass.Initialize(self);

	end

	function ENT:SpawnSeats()
		self.Seats = {};
		for k,v in pairs(self.SeatPos) do
			local e = ents.Create("prop_vehicle_prisoner_pod");
			e:SetPos(v[1]);
			e:SetAngles(v[2]+Angle(0,-90,0));
			e:SetParent(self);
			e:SetModel("models/nova/airboat_seat.mdl");
			e:SetRenderMode(RENDERMODE_TRANSALPHA);
			e:SetColor(Color(255,255,255,0)); --comment out this if you want seats to be visible
			e:Spawn();
			e:Activate();
			e:SetUseType(USE_OFF);
			e:GetPhysicsObject():EnableMotion(false);
			e:GetPhysicsObject():EnableCollisions(false);
			e.Isfof_vb02_transSeat = true;
			e.fof_vb02_trans = self;

			e.fof_vb02_transBackSeat = true;

			self.Seats[k] = e;
		end
	end

	--creates the props that represent the doors on the left and right sides
	function ENT:SpawnDoors()
		--position, angle, collision bool
		local doors = {
			d1Open = {self:GetPos() + self:GetUp() * 43 + self:GetRight() * 160 + self:GetForward() * -10, self:GetAngles() + Angle(-35,90,180), true},
			d1Closed = {self:GetPos() + self:GetUp() * 150 + self:GetRight() * 100 + self:GetForward() * -10, self:GetAngles() + Angle(90,0,90), false},

			d2Open = {self:GetPos() + self:GetUp() * 43 + self:GetRight() * -160 + self:GetForward() * -10, self:GetAngles() + Angle(35,90,180), true},
			d2Closed = {self:GetPos() + self:GetUp() * 150 + self:GetRight() * -100, self:GetAngles() + Angle(90,0,90), false},
		}

		self.doorProps = {}
		for k, v in pairs(doors) do
			local doorProp = ents.Create("prop_physics")
			doorProp:SetPos(v[1])
			doorProp:SetAngles(v[2])
			doorProp:SetParent(self);
			doorProp:SetModel("models/hunter/plates/plate3x5.mdl");
			doorProp:SetRenderMode(RENDERMODE_TRANSALPHA);

			doorProp:SetColor(Color(255,255,255,0)) --makes doors invisible

			if(v[3]) then
				doorProp.closed = true
			else
				doorProp.closed = false
			end

			doorProp:Spawn();
			doorProp:Activate();
			doorProp:GetPhysicsObject():EnableMotion(false);
			doorProp:GetPhysicsObject():EnableCollisions(false) --doesn't actually work on these for some reason

			--collision status
			if(v[3]) then
				doorProp:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
			else
				doorProp:SetCollisionGroup(COLLISION_GROUP_NONE)
			end

			doorProp.vb02_trans = self

			self.doorProps[#self.doorProps+1] = doorProp
		end
	end

	function ENT:SpawnPilotDoor()
		local doorPilot = ents.Create("base_gmodentity")
		doorPilot:SetPos(self:GetPos() + self:GetForward() * 88 + self:GetRight() * 20 + self:GetUp() * 130)
		doorPilot:SetAngles(self:GetAngles())
		doorPilot:SetParent(self);
		doorPilot:SetModel("models/props_c17/door01_left.mdl");
		doorPilot:SetRenderMode(RENDERMODE_TRANSALPHA);

		doorPilot:SetSolid(SOLID_VPHYSICS)
		doorPilot:SetMoveType(MOVETYPE_NONE)

		doorPilot:SetColor(Color(255,255,255,0)) --comment this out if you want door prop to be visible

		--puts people in the pilot seat
		doorPilot.Use = function(_, activator)
			if(!self.Pilot and !IsValid(self.Pilot)) then
				self:Enter(activator)
			end
		end
		doorPilot:SetUseType(SIMPLE_USE)

		doorPilot:Spawn();
		doorPilot:Activate();

		doorPilot:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
	end

	function ENT:DoorPropClosed(closed)
		for k, v in pairs(self.doorProps) do
			if(closed) then
				--colors are for debug purposes
				if(v.closed) then
					--v:SetColor(Color(255,255,255,255))
					v:SetCollisionGroup(COLLISION_GROUP_NONE)
				else
					--v:SetColor(Color(255,255,255,0))
					v:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
				end
			else
				if(v.closed) then
					--v:SetColor(Color(255,255,255,0))
					v:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
				else
					--v:SetColor(Color(255,255,255,255))
					v:SetCollisionGroup(COLLISION_GROUP_NONE)
				end
			end
		end
	end

	function ENT:Enter(p)
		self.BaseClass.Enter(self,p);
		if(IsValid(self.Pilot)) then
			self:SetModel(self.FlyModel);
			jlib.Announce(p, Color(0, 255, 0, 255), "[INFORMATION] ", Color(255, 255, 0, 255), "Flight Controls: ",
				Color(255, 255, 255, 255), "\n· Left-click to fire gun\n· SHIFT to open doors\n· R to play music (if available)\n· ALT to swap view mode"
			)
		end
	end

	function ENT:Exit(kill)
		self.BaseClass.Exit(self,kill);
		self.Pilot = nil-- Sets the vehicle to no longer have a pilot

		if(self.Land or self.TakeOff) then
			self:SetModel(self.EntModel);
		end
	end

	function ENT:Passenger(p)
		if(self.NextUse.Use > CurTime()) then return end;
		for k,v in pairs(self.Seats) do
			if(v:GetPassenger(1) == NULL) then
				p:EnterVehicle(v);
				p:SetAllowWeaponsInVehicle( false )
				return;
			end
		end
	end

	function ENT:Use(p)
		if(not self.Inflight) then
			if(!p:KeyDown(IN_WALK)) then
				local min = self:GetPos()+self:GetForward()*100+self:GetUp()*-40+self:GetRight()*-10
				local max = self:GetPos()+self:GetForward()*350+self:GetUp()*125+self:GetRight()*340
				for k,v in pairs(ents.FindInBox(min,max)) do
				   if(v == p) then
						self:Enter(p);
						break;
					end
				end
			else
				self:Passenger(p);
			end
		else
			if(p != self.Pilot) then
				self:Passenger(p);
			end
		end
	end

	hook.Add("PlayerLeaveVehicle", "fof_vb02_transSeatExit", function(p,v)
		if(IsValid(p) and IsValid(v)) then
			if(v.Isfof_vb02_transSeat) then
				if(v.fof_vb02_transBackSeat) then
					local self = v:GetParent();
					p:SetPos(v:GetPos()+v:GetForward()*40+self:GetUp()*20)
				else
					local self = v:GetParent()
					p:SetPos(self:GetPos()+self:GetForward()*270+self:GetUp()*40+self:GetRight()*-140)
				end

				p:SetNetworkedEntity("fof_vb02_trans",NULL);
				p:SetNetworkedEntity("fof_vb02_transSeat",NULL);
			end
		end
	end);

	--makes it so damage dealt to the prop doors is dealt to the vehicle itself
	hook.Add("EntityTakeDamage", "fof_vb02_trans_doorDamage", function(target, dmg)
		if(target.vb02_trans and IsValid(target.vb02_trans)) then
			target.vb02_trans:TakeDamageInfo(dmg)
		end
	end)
end

if CLIENT then

	ENT.CanFPV = true;
	ENT.Sounds={
		Engine=Sound("vehicles/falcon_fly.wav"),
	}

	function ENT:Initialize()
		self.Emitter = ParticleEmitter(self:GetPos());
		self.BaseClass.Initialize(self);
		self.Gearup = 0
		self.doorClose = 0
		self.gearSmooth = 0
		self.doorSmooth = 0
		self.nacelleSmooth = 0
	end

	local View = {};
	--had to modify the angle, so this is here now
	local function HALOVehicleViewVB02(self,dist,udist,fpv_pos,lookaround)
		local p = LocalPlayer();
		local pos,face;

		if(IsValid(self)) then
			if(self.IsFPV) then --removed a redundant bool from here
				pos = fpv_pos;
				face = self:GetAngles() + Angle(45,0,0); --adjusts the angle
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

	local View = {}
	function CalcView()
		local p = LocalPlayer();
		local self = p:GetNetworkedEntity("fof_vb02_trans", NULL)
		if(IsValid(self)) then
			local fpvPos = self:GetPos()+self:GetForward()*400;
			View = HALOVehicleViewVB02(self,1000,550,fpvPos,true);
			return View;
		end
	end
	hook.Add("CalcView", "fof_vb02_transView", CalcView)

	function ENT:Effects()
		local p = LocalPlayer();
		local roll = math.Rand(-45,45);
		local normal = (self.Entity:GetRight() * -1):GetNormalized();
		local FWD = self:GetRight();
		local id = self:EntIndex();

	end

	function ENT:Think()
		local gearTrace=util.QuickTrace(self:GetPos(), (Vector(0,0,-200)), {self})
		self.gearSmooth = Lerp(2*FrameTime(), self.gearSmooth, self.Gearup)
		self.nacelleSmooth = Lerp(4*FrameTime(), self.nacelleSmooth, (self:GetNWInt("Speed")/700)-0.3)
		self.doorSmooth = Lerp(1*FrameTime(), self.doorSmooth, self:GetNWInt("doorClosed"))


		if (!gearTrace.Hit) then
			self.Gearup = 1
		elseif (gearTrace.Hit && self:GetNWInt("Speed") < 300) then
			self.Gearup = 0
		end


		self:SetPoseParameter("nacelle",self.nacelleSmooth)
		self:SetPoseParameter("door_l",self.doorSmooth)
		self:SetPoseParameter("door_r",self.doorSmooth)
		self:SetPoseParameter("gear",self.gearSmooth)


		local p = LocalPlayer();
		local Flying = self:GetNWBool("Flying".. self.Vehicle);
		if(Flying) then
			self.VB02EnginePos = {
				self:GetPos()+self:GetRight()*-63+self:GetUp()*114+self:GetForward()*-85,
				self:GetPos()+self:GetRight()*14+self:GetUp()*114+self:GetForward()*-85,
			}
			self:Effects();
		end
		self.BaseClass.Think(self)
	end

	--MINI GUN CODE--
	--By Extra ^^

	local reticle = Material("hud/reticle_unsc.png", "noclamp smooth")
	function fof_vb02_transReticle()
		local ply = LocalPlayer()
		local veh = ply:GetVehicle()
		if not IsValid(veh) or veh:GetClass() != "prop_vehicle_prisoner_pod" then return end
		local parent = veh:GetParent()
		if not IsValid(parent) or parent:GetClass() != "fof_vb02_trans" then return end
		--
		local closed = parent:GetNWInt("doorClosed", 0)
		if closed == 1 then return end
		-- --
		local index = veh:GetNWString("gunnerName", "")
		if index == "" then return end
		--
		local aim_vec = ply:GetAimVector()
		local bones = minigun_bones
		local bone = bones[index][2]
		local pos = parent:GetBonePosition( parent:LookupBone(bone) ) + Vector(0,0,15)
		local tr = {
			start = pos,
			endpos = pos + aim_vec*1096,
			filter = {veh, parent}
		}
		--
		local trace = util.TraceLine(tr)
		local hitpos = trace.HitPos:ToScreen()
		local rw = ScrW()*.02

		surface.SetDrawColor(255,255,255)
		surface.SetMaterial(reticle)
		surface.DrawTexturedRect(hitpos.x - (rw/2), hitpos.y - (rw/2), rw, rw)
	end
	hook.Add("HUDPaint", "fof_vb02_transReticle", fof_vb02_transReticle)

	function fo3_vb01Reticle()
		local p = LocalPlayer();
		local self = p:GetNWEntity("fof_vb02_trans");
		if IsValid(self) then
			HALO_HUD_DrawHull(7000);
			VB02T_Reticles(self);
		end
	end
	hook.Add("HUDPaint", "fo3_vb01Reticle", fo3_vb01Reticle)

	function VB02T_Reticles(self)
		local tr = util.TraceLine( {
			start = self:GetPos(),
			endpos = self:GetPos() + self:GetForward()*10000 + self:GetUp() * -5000,
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
end
