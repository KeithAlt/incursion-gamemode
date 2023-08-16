
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Base = "haloveh_base"
ENT.Type = "vehicle"

ENT.PrintName = "VB-01 Vertibird"
ENT.Author = "SGM / Extra"
--- BASE AUTHOR: Liam0102 ---
-- Edited by Extra
ENT.Category = "Vertibirds"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = true;
ENT.AdminSpawnable = true;

ENT.EntModel = "models/sentry/vertibirds/vb02_fo4.mdl"
ENT.FlyModel = "models/sentry/vertibirds/vb02_fo4_fly.mdl"
ENT.Vehicle = "fo4_vb02"
ENT.StartHealth = 7000;
ENT.Allegiance = "";

--MINI GUN
local minigun_bones = {
	["GunL"] = {"gun_l", "gun_l_barrel"},
	["GunR"] = {"gun_r", "gun_r_barrel"}
}
-- -- --

list.Set("Fallout Vehicles", ENT.PrintName, ENT);



if SERVER then
	resource.AddFile( "materials/vgui/minigun_c.png" )

	function ENT:SecondaryAttack()
	if self.SecondaryCooldown and self.SecondaryCooldown > CurTime() then return end
		self:EmitSound("npc/attack_helicopter/aheli_megabomb_siren1.wav")
		self.Pilot:ChatPrint("[ WARNING ]  Dropping smoke on bystanders does label you as optional KOS to them")

		timer.Simple(0.5, function()
			for i = 1, 3 do
				timer.Simple(i/1.5, function()
					if IsValid(self) then
						local gas_red = ents.Create("gb_sred")
						gas_red:SetModel("models/halokiller38/fallout/weapons/explosives/cryogrenade.mdl")
						gas_red:SetPos(self:GetPos() - Vector(0,0,50))
						gas_red:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
						gas_red:Spawn()
						gas_red:EmitSound("weapons/crossbow/fire1.wav", 100, 90)
						gas_red:Arm()
						gas_red:SetModel("models/halokiller38/fallout/weapons/explosives/cryogrenade.mdl")
						ParticleEffectAttach( "mr_jet_01a", 1, gas_red, 1 )
					end
				end)
			end
		end)

		self.SecondaryCooldown = CurTime() + 60

		timer.Simple(self.SecondaryCooldown, function()
			if IsValid(self) and IsValid(self.Pilot) then
				self:EmitSound("weapons/fatman/reload/kawaiidesu.wav")
				self.Pilot:falloutNotify("[ ! ]  Tactical smoke cover is ready", "ui/notify.mp3")
			end
		end)
	end

	function ENT:Think()
		  if (IsValid(self.Pilot)) then
				if self.Pilot:KeyDown(IN_SPEED) and self.lastDoor < CurTime() - 2 then
					if self.doorClose == 0 then
						self.doorClose = 1
						self:SetNWInt("doorClosed",1)
						self.lastDoor = CurTime()
						else
						self.doorClose = 0
						self:SetNWInt("doorClosed",0)
						self.lastDoor = CurTime()
						end
					end
				self.BaseClass.Think(self)
			end
		if (IsValid(self.Pilot) and self.Pilot:KeyDown(IN_ATTACK2) and (self.SecondaryAttack != nil)) then
			self:SecondaryAttack()
		end
	end

	ENT.FireSound = Sound("weapons/lightbolt.wav");
	ENT.NextUse = {Wings = CurTime(),Use = CurTime(),Fire = CurTime(),};

	AddCSLuaFile();
	function ENT:SpawnFunction(pl, tr)
		local e = ents.Create("fo4_vb02");
		e:SetPos(tr.HitPos + Vector(0,0,0));
		e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw,0));
		e:Spawn();
		e:Activate();
		return e;
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
			self.Bullet.Tracer = 1
			self.Bullet.TracerName = "tfa_tracer_incendiary"
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
		self.NextUse.Fire = CurTime() + 0;
	end
end

function ENT:Initialize()
	self:SetNWInt("Health",self.StartHealth);
	self.Gearup = 0;
	self.doorClose = 0;
	self.lastDoor = 0;
	self.WeaponLocations = {
		Left = self:GetPos()+self:GetForward()*284+self:GetUp()*81.9+self:GetRight()*-62.9,
		Right = self:GetPos()+self:GetForward()*284+self:GetUp()*81.9+self:GetRight()*62.9,
	}
	self.WeaponsTable = {};
	self.BoostSpeed = 1200;
	self.ForwardSpeed = 1200;
	self.UpSpeed = 100;
	self.AccelSpeed = 5;
	self.CanBack = false;
	self.CanStrafe = true;
	self.Cooldown = 2;
	self.CanShoot = true;
	self.DontOverheat = true;
	self.Bullet = HALOCreateBulletStructure(50,"unsc");
	self.FireDelay = 0.1;
	self.NextBlast = 1;
	self.AlternateFire = true;
	self.FireGroup = {"Left","Right",};
	self.ExitModifier = {x = 140, y = 270, z = 40};
    self.Hover = true;
	--MINI GUN CODE
	self.SeatPos = {
		FrontL = {self:GetPos()+self:GetForward()*195+self:GetRight()*-36+self:GetUp()*128,self:GetAngles()+Angle(0,0,0)},
		BackL = {self:GetPos()+self:GetForward()*50+self:GetRight()*-10+self:GetUp()*97,self:GetAngles()+Angle(0,0,0)},
		BackL2 = {self:GetPos()+self:GetForward()*50+self:GetRight()*10+self:GetUp()*97,self:GetAngles()+Angle(0,0,0)},
		--
		GunL = {self:GetPos()+self:GetForward()*120+self:GetRight()*-65+self:GetUp()*110,self:GetAngles()+Angle(0,90,0)},
		GunR = {self:GetPos()+self:GetForward()*120+self:GetRight()*55+self:GetUp()*110,self:GetAngles()+Angle(0,-90,0)},
	}

	self.MiniGuns = {}
	-- -- --
	self:SpawnSeats();
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
		e:SetColor(Color(255,255,255,0));
		e:Spawn();
		e:Activate();
		e:SetUseType(USE_OFF);
		e:GetPhysicsObject():EnableMotion(false);
		e:GetPhysicsObject():EnableCollisions(false);
		e.Isfo4_vb02Seat = true;
		e.fo4_vb02 = self;
		if(k == "FrontL") then
            e.fo4_vb02FrontLSeat = true;
		elseif(k == "BackL") then
            e.fo4_vb02BackLSeat = true;
		elseif(k == "BackL2") then
            e.fo4_vb02BackL2Seat = true;
		end
		--
		if k:find("Gun") then
			e.isGunner = true
			e.isR = k:find("R")
			e:SetNWString("gunnerName", k)
			self.MiniGuns[k] = e
		end
		--
		self.Seats[k] = e;
	end

end

function ENT:Enter(p)
    self.BaseClass.Enter(self,p);
	if(IsValid(self.Pilot)) then
		jlib.Announce(p, Color(0, 255, 0, 255), "[INFORMATION] ", Color(255, 255, 0, 255), "Flight Controls: ",
			Color(255, 255, 255, 255), "\n· Left-click to fire gun\n· R to drop smoke cover\n· SHIFT to toggle doors\n· ALT to swap view mode"
		)
        self:SetModel(self.FlyModel);
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

hook.Add("PlayerLeaveVehicle", "fo4_vb02SeatExit", function(p,v)
	if(IsValid(p) and IsValid(v)) then
		if(v.Isfo4_vb02Seat) then
			if(v.fo4_vb02FrontLSeat) then

                local self = v:GetParent();
                p:SetPos(self:GetPos()+self:GetForward()*270+self:GetUp()*40+self:GetRight()*-140);


			elseif(v.fo4_vb02BackLSeat) or v.isGunner and not v.isR then
                local self = v:GetParent();
                p:SetPos(self:GetPos()+self:GetForward()*50+self:GetUp()*20+self:GetRight()*-200);

			elseif(v.fo4_vb02BackL2Seat) or v.isGunner and v.isR then
                local self = v:GetParent();
                p:SetPos(self:GetPos()+self:GetForward()*50+self:GetUp()*20+self:GetRight()*200);

			end
			p:SetNetworkedEntity("fo4_vb02",NULL);
            p:SetNetworkedEntity("fo4_vb02Seat",NULL);
		end
	end
end);

end

--MINI GUN FIRE--
--By Extra
function FO4MiniGuns_Fire(ply, key)
	local veh = ply:GetVehicle()
	if not IsValid(veh) or veh:GetClass() != "prop_vehicle_prisoner_pod" then return end
	local parent = veh:GetParent()
	if not IsValid(parent) or parent:GetClass() != "fo4_vb02" then return end
	--
	local closed = parent:GetNWInt("doorClosed", 0)
	if closed == 1 then return end
	-- --
	local index = veh:GetNWString("gunnerName", "")
	if index == "" then return end
	--
	local bones = minigun_bones
	local bone = bones[index][2]

	local rate = 0.100
	local timer_id = "ExtraMG_Fire: "..ply:SteamID64()

	ply:EmitSound("weapon_minigun_windup.mp3")

	timer.Simple(1, function()
		if veh.ShootSound != nil then veh.ShootSound:Stop() end
		veh.ShootSound = CreateSound(veh, "npc/combine_gunship/gunship_fire_loop1.wav")
		veh.ShootSound:Play()
		veh.ShootSound:ChangeVolume(1)
		timer.Create(timer_id, rate, 0, function()
			if not IsValid(parent) or not IsValid(ply) or not ply:KeyDown(IN_ATTACK) then
				timer.Destroy(timer_id)
				--
				if veh.ShootSound != nil then
					veh.ShootSound:Stop()
				end
			return end

			local pos = parent:GetBonePosition( parent:LookupBone(bone) ) + Vector(0,0,15)
			local aim_vec = ply:GetAimVector()
			--

			local fx = EffectData()
			fx:SetOrigin(pos + (aim_vec*40) )
			fx:SetNormal(aim_vec)
			util.Effect("effect_vb_gunsmoke",fx)

			local perc = ply:getSpecial("P")

			local bullet = {}
			bullet.Dir = aim_vec
			bullet.Src = pos
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 1
			bullet.TracerName = "tfa_tracer_incendiary"
			bullet.Force = 10
			bullet.HullSize = 5
			bullet.Attacker = ply
			bullet.Damage = 20 + ( perc  ) 

			bullet.AmmoType = "pistol"
			bullet.IgnoreEntity = {veh, parent}

			ply:FireBullets(bullet)
			util.ScreenShake(ply:GetPos(), 0.5, 0.5, 0.5, 25 )
		end)
	end)
end

hook.Add("KeyPress", "FO4MiniGuns_Fire", FO4MiniGuns_Fire)
-- -- --


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

	local View = {}
	function CalcView()

		local p = LocalPlayer();
		local self = p:GetNetworkedEntity("fo4_vb02", NULL)
		if(IsValid(self)) then
			local fpvPos = self:GetPos()+self:GetUp()*165+self:GetForward()*195+self:GetRight()*36;
			View = HALOVehicleView(self,1000,550,fpvPos,true);
			return View;
		end
	end
	hook.Add("CalcView", "fo4_vb02View", CalcView)

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
		self.doorSmooth = Lerp(2*FrameTime(), self.doorSmooth, self:GetNWInt("doorClosed"))


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
	function fo4_vb02Reticle()
		local ply = LocalPlayer()
		local veh = ply:GetVehicle()
		if not IsValid(veh) or veh:GetClass() != "prop_vehicle_prisoner_pod" then return end
		local parent = veh:GetParent()
		if not IsValid(parent) or parent:GetClass() != "fo4_vb02" then return end
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
	hook.Add("HUDPaint", "fo4_vb02Reticle", fo4_vb02Reticle)


	function FO4MiniGuns_Move()
		local ply = LocalPlayer()
		local veh = ply:GetVehicle()
		if not IsValid(veh) or veh:GetClass() != "prop_vehicle_prisoner_pod" then return end
		local parent = veh:GetParent()
		if not IsValid(parent) then return end
		if parent:GetClass() != "fo4_vb02" then return end
		--
		local index = veh:GetNWString("gunnerName", "")
		if index == "" then return end
		-- --
		local closed = parent:GetNWInt("doorClosed", 0)
		local bones = minigun_bones

		if closed == 1 then
			if veh.manipulatedGun == true then
				for _, bone_name in pairs(bones[index]) do
					local bone_id = parent:LookupBone(bone_name)
					parent:ManipulateBoneAngles(bone_id, Angle( 0,0,0 ))
				end
				--
				veh.manipulatedGun = false
			end
			return
		end
		-- --
		local plyAng = ply:EyeAngles()
		for _, bone_name in pairs(bones[index]) do
			local bone_id = parent:LookupBone(bone_name)

			parent:ManipulateBoneAngles(bone_id, Angle( -(plyAng.y - 90),0, -( plyAng.p )) )
		end
		veh.manipulatedGun = true
	end

	hook.Add("Think", "fo4_miniguns_move", FO4MiniGuns_Move)


	function fo3_vb01Reticle()
			local p = LocalPlayer();
			local self = p:GetNWEntity("fo4_vb02");
			if IsValid(self) then
				HALO_HUD_DrawHull(7000);
				HALO_UNSCReticles(self);
			end
		end
	hook.Add("HUDPaint", "fo3_vb01Reticle", fo3_vb01Reticle)

	-- -- --
end
