ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Base = "haloveh_base"
--ENT.Base = "adihover_base"
ENT.Type = "vehicle"

ENT.PrintName = "VB-02 Vertibird"
ENT.Author = "SGM and all_danger"
--- BASE AUTHOR: Liam0102 ---
ENT.Category = "Vertibirds"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = true;
ENT.AdminSpawnable = true;
ENT.EntModel = "models/sentry/vertibirds/vb02.mdl"
ENT.Vehicle = "fo3_vb02"
ENT.StartHealth = 9000;
ENT.Allegiance = "";

list.Set("Fallout Vehicles", ENT.PrintName, ENT);

if SERVER then

	AddCSLuaFile()
	ENT.FireSound = Sound("weapons/lightbolt.wav")
	ENT.NextUse = {Wings = CurTime(),Use = CurTime(),Fire = CurTime(),}
	--animation stuff ADI
	ENT.gear_open = 0
	ENT.door_open = 0
	ENT.layer_gears = nil
	ENT.layer_spin = nil
	ENT.layer_door = nil
	--
	--UI networking stuff ADI
	util.AddNetworkString("sv_send_vertibird_toggle_ui")
	util.AddNetworkString("cl_request_vertibird_motor_toggle")
	util.AddNetworkString("cl_request_vertibird_lock_toggle")
	util.AddNetworkString("cl_request_vertibird_seats")
	util.AddNetworkString("cl_request_vertibird_exit")
	--ENT:SetNWBool( "isDoor_locked", true )--here just for overview
	--ENT:SetNWBool( "isEngine_on", false )

	sound.Add( {
	name = "Enclave Broadcast 1",
	channel = CHAN_STREAM,
	volume = 100,
	level = 100,
	pitch = 100,
	sound = "broadcast/enclave_broadcast1.ogg"
	} )
	sound.Add( {
	name = "Enclave Broadcast 2",
	channel = CHAN_STREAM,
	volume = 100,
	level = 100,
	pitch = 100,
	sound = "broadcast/enclave_broadcast2.ogg"
	} )
	sound.Add( {
	name = "Enclave Broadcast 3",
	channel = CHAN_STREAM,
	volume = 100,
	level = 100,
	pitch = 100,
	sound = "broadcast/enclave_broadcast3.ogg"
	} )
	sound.Add( {
	name = "Enclave Broadcast 4",
	channel = CHAN_STREAM,
	volume = 100,
	level = 100,
	pitch = 100,
	sound = "broadcast/enclave_broadcast4.ogg"
	} )
--

--creates a ladder on the side of the vehicle
function ENT:SpawnLadder(left)
	local ladder = ents.Create("base_gmodentity")
	ladder:SetModel("models/props_c17/metalladder002.mdl")
	ladder:SetNoDraw(true)
	--ladder:SetModelScale(2)
	local ladderPos

	if (left) then
		ladderPos = self:GetPos() + self:GetUp() * -20 + self:GetRight() * -200 + self:GetForward() * 115
		ladder:SetAngles(self:GetAngles() + Angle(-10, 90, 0))
	else
		ladderPos = self:GetPos() + self:GetUp() * -20 + self:GetRight() * 200 + self:GetForward() * 115
		ladder:SetAngles(self:GetAngles() + Angle(-10, 270, 0))
	end

	ladder:SetPos(ladderPos)
	ladder:SetSolid(SOLID_VPHYSICS)
	ladder:SetMoveType(MOVETYPE_NONE)
	ladder:SetParent(self)

	ladder.Use = function(_, activator)
		local ladderTop = ladder:GetPos() + ladder:GetUp() * 110 + ladder:GetForward() * -100
		local ladderBot = ladder:GetPos() + ladder:GetForward() * 50 + ladder:GetUp() * 10
		local activatorPos = activator:GetPos()

		if (ladderBot:DistToSqr(activatorPos) > ladderTop:DistToSqr(activatorPos)) then
			activator:SetPos(ladderBot) --go to bot if that's the furthest away
		else
			activator:SetPos(ladderTop) --go to top if that's the furthest away
		end
		ladder:EmitSound("player/footsteps/ladder" .. math.random(1,4) .. ".wav")
	end

	ladder:SetUseType(SIMPLE_USE)
	ladder:Spawn()
	ladder:Activate()
	--just in case
	local physObj = ladder:GetPhysicsObject()

	if (IsValid(physObj)) then
		ladder:GetPhysicsObject():EnableMotion(false)
		ladder:GetPhysicsObject():EnableCollisions(true)
	end

	if(!self.ladders) then
		self.ladders = {}
	end

	self.ladders[#self.ladders+1] = ladder

	self:DeleteOnRemove(ladder)
end

function ENT:RemoveLadders()
	if(self.ladders) then
		for k, v in pairs(self.ladders) do
			SafeRemoveEntity(v)
		end
	end
end

/**
function ENT:ToggleBroadcast() -- Cannot get this to work whatsoever
	self.delay = self.delay or CurTime()

	if SERVER and ( self:GetClass() == "fo3_vb02" and self:GetSkin() == 0) and self.delay <= CurTime() then -- ENCLAVE BROADCAST CODE, Scuffed but works
		self.songnum = "Enclave Broadcast " .. math.random(1,4)
		self:EmitSound(self.songnum)
		self.Pilot:ChatPrint("[ DEV ] Music starting")

		timer.Simple(4, function()
			self:StopSound(self.songnum)
			self.Pilot:ChatPrint("[ DEV ]  Music stopping")
		end)
	end
end
**/

-- -- --
--NUKES
--BY EXTRA
function ENT:SecondaryAttack()
	if self.NextNuke and self.NextNuke > CurTime() then return end
	self.NextNuke = CurTime() + 50
	-- --
	self:EmitSound("weapons/fatman/shoot.ogg")
	--
	local ang = self:GetAngles()
	local pos = self:GetPos()
	local vel = self:GetPhysicsObject():GetVelocity():Length2D()
	--
	pos = pos - ang:Up()*40
	local entPlasma = ents.Create("vb_mininuke")
	entPlasma:SetPos(pos)
	entPlasma:SetAngles(ang + Angle(-40,0,0))
	entPlasma:SetEntityOwner(self.Pilot)
	entPlasma:Spawn()
	entPlasma:Activate()

	local phys = entPlasma:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:ApplyForceCenter(ang:Forward() *(1500 + (vel*4)) - ang:Up()*500)
	end

	timer.Simple(50, function()
		if IsValid(self) then
			self:EmitSound("weapons/fatman/reload/kawaiidesu.wav")
		end
	end)
end
-- -- --
function ENT:Think()
	--landing gear ADI
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
	--end landing gear ADI
	--UI ADI toggle when in vehicle -- TODO currently only Pilot. bugged on second client? needs Base Think() change.
	--[[if(IsValid(self.Pilot) and (self.Base == "adihover_base")) then
		if(self.Pilot:KeyPressed(IN_USE)) then
			net.Start("sv_send_vertibird_toggle_ui")
			net.WriteEntity(self)
			net.Send(self.Pilot) --sends only to  player who activated
		end
	end--]]
	--end UI ADI

/**		if (IsValid(self.Pilot) and self.Pilot:KeyDown(IN_SPEED)) then -- Cannot get to work whatesoever
			self:ToggleBroadcast()
		end	**/

    if(IsValid(self.Pilot)) then
                if(self.Pilot:KeyDown(IN_ATTACK2) and self.NextUse.FireBlast < CurTime() and self.MissileDelay < CurTime()) then
				--print("shoot")
                    self.BlastPositions = {
                        self:GetPos()+self:GetForward()*345+self:GetUp()*64+self:GetRight()*-48, //1
						self:GetPos()+self:GetForward()*345+self:GetUp()*64+self:GetRight()*-48, //1
						self:GetPos()+self:GetForward()*345+self:GetUp()*64+self:GetRight()*-48, //1
                    }

					if SERVER then

						local dmg = DamageInfo()
						dmg:SetAttacker(self.Pilot or self)
						dmg:SetDamage(100 + (100 * (0.010 * self.Pilot:getSpecial("p"))))

						local explodeSounds = {
							"fo_sfx/explosion/grenade/frag/fx_explosion_grenade_frag_high_06.ogg",
							"fo_sfx/explosion/grenade/frag/fx_explosion_grenade_frag_high_01.ogg",
							"fo_sfx/explosion/grenade/frag/fx_explosion_grenade_frag_high_02.ogg",
							"fo_sfx/explosion/grenade/frag/fx_explosion_grenade_frag_high_04.ogg",
							"fo_sfx/explosion/grenade/frag/fx_explosion_grenade_frag_high_05.ogg",
						}
						for i=1, 5 do
							timer.Simple(i/5, function()
								self:EmitSound("weapons/missilelauncher/shoot.ogg", 100, 100, 30)
								local rocket = ents.Create("cgc_missile")
								rocket:SetPos(self:GetPos() + self:GetForward() * 500)
								rocket:Spawn()
								
								local think = rocket.Think
								local collide = rocket.PhysicsCollide
								rocket.Think = function()
									think(rocket)
									
									local phys = rocket:GetPhysicsObject()
									if IsValid(phys) then
										phys:SetVelocity( self:GetForward() * 999999 )
									end						
								end

								rocket.PhysicsCollide = function(data, phys)
									collide(data, phys)
									
									for k,v in ipairs(ents.FindInSphere(rocket:GetPos(), 300)) do // for some reason doesnt already do this, so we will do it here instead
										v:TakeDamageInfo(dmg)
									end

									self:EmitSound(explodeSounds[math.random(#explodeSounds)])
									ParticleEffect("vj_explosion2", rocket:GetPos(), Angle(0,0,0), nil)
								end
							end)
						end
					end

					self.MissileDelay = CurTime() + 15
                end

		if(self.NextUse.FireBlast < CurTime()) then
			self:SetNWBool("OutOfMissiles",false);
		end
        self:SetNWInt("Overheat",self.Overheat);
        self:SetNWBool("Overheated",self.Overheated);
    end

	--OVERWRITE BASE THINK to allow E-Menu in flight  --if you want to use base Think() do "self.BaseClass.Think(self)" adn uncomment overwrite
	--this code is just copied from haloveh_base and modified.
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

		if(IsValid(self.Pilot)) then -- Apparently this does nothing, I fucking hate this code
			if(IsValid(self.Pilot) and self.Pilot:KeyDown(IN_SPEED) and (self:GetSkin() == 0 or self:GetSkin() == 8) and (!self.broadcastCooldown or self.broadcastCooldown < CurTime())) then
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

			if(self.CanShoot and !self.WeaponsDisabled) then
				if(IsValid(self.Pilot)) then // I don't know why I need this here for a second check but when I don't it causes an error

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
	--END BASE THINK OVERWRITE

	self:NextThink( CurTime() ) -- ADI Set the next think to run as soon as possible, i.e. the next frame, for smooth animations.
	return true --ADI Apply NextThink call
end

function ENT:FireHALOV_fo3_vb02Blast(pos,gravity,vel,dmg,white,size,snd)
	local e = ents.Create("missle_blast");

	e.Damage = dmg or 600;
	e.IsWhite = white or false;
	e.StartSize = size or 20;
	e.EndSize = size*0.75 or 15;

	local sound = snd or Sound("weapons/rocket.wav");

	e:SetPos(pos);
	e:Spawn();
	e:Activate();
	e:Prepare(self,sound,gravity,vel);
	e:SetColor(Color(255,255,255,1));

end

function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("fo3_vb02");
	e:SetPos(tr.HitPos + Vector(0,0,120));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw+25,0));
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
			self.Bullet.Spread		= Vector(300,300,0)
			self.Bullet.Dir = angPos
			self.Bullet.Damage = 20 + self.Pilot:getSpecial("P") 

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
		if self.NextUse.FireSound == nil or self.NextUse.FireSound < CurTime() then
			self:EmitSound(self.FireSound, 75, 100, 0.4);
		end

		self.NextUse.Fire = CurTime() + 0.05 --adi fix. This was 0 before..wich would make it run every frame
	end
end

function ENT:Initialize()
	self:SetNWBool( "isDoor_locked", true )--default closed
	self.MissileDelay = 0
	self:SetNWInt("Health",self.StartHealth);
	self.WeaponLocations = {
		Left = self:GetPos()+self:GetForward()*385+self:GetUp()*30+self:GetRight()*-90,
		Right = self:GetPos()+self:GetForward()*385+self:GetUp()*30+self:GetRight()*-90,
	}
	self.WeaponsTable = {};
	self.BoostSpeed = 1100;
	self.ForwardSpeed = 1200;
	self.UpSpeed = 100;
	self.AccelSpeed = 5;
	self.CanBack = false;
	self.CanStrafe = false;
	self.Cooldown = 2;
	self.CanShoot = true;
	self.DontOverheat = true;
	self.FireSound = Sound("weapons/gatlinglaser/shoot.mp3");
	self.Bullet = HALOCreateBulletStructure(25,"red", false);
	self.FireDelay = 5;
	self.NextBlast = 1;
	self.AlternateFire = true;
	self.FireGroup = {"Left","Right",};
	self.ExitModifier = {x = 250, y = 150, z = 0};
    self.Hover = true;
	local get_pos_local = self:GetPos()
	local get_pos_x = self:GetForward()
	local get_pos_y = self:GetRight()
	local get_pos_z = self:GetUp()
	local get_ang = self:GetAngles()
	self.SeatPos = {
		FrontL ={get_pos_local+get_pos_x*204+get_pos_y*-42+get_pos_z*66,get_ang+Angle(0,0,0)},
		BackL =	{get_pos_local+get_pos_x*11+get_pos_y*-59+get_pos_z*132,get_ang+Angle(0,-85,0)},
		BackL2 ={get_pos_local+get_pos_x*-30+get_pos_y*-54+get_pos_z*132,get_ang+Angle(0,-85,0)},
		BackL3 ={get_pos_local+get_pos_x*-71+get_pos_y*-50+get_pos_z*132,get_ang+Angle(0,-85,0)},
		BackR =	{get_pos_local+get_pos_x*11+get_pos_y*59+get_pos_z*132,get_ang+Angle(0,85,0)},
		BackR2 ={get_pos_local+get_pos_x*-30+get_pos_y*54+get_pos_z*132,get_ang+Angle(0,85,0)},
		BackR3 ={get_pos_local+get_pos_x*-71+get_pos_y*50+get_pos_z*132,get_ang+Angle(0,85,0)},
	}
	self:SpawnSeats();
	self.HasLookaround = true;
	self.PilotVisible = true;
	self.PilotPosition = {x=-42,y=225,z=66};
	self.PilotAnim = "sit_rollercoaster"; --TODO never used?

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
		e.Isfo3_vb02Seat = true;
		e.fo3_vb02 = self;
		if(k == "FrontL") then
			self.DriverChair = k
            e.fo3_vb02FrontLSeat = true;
		elseif(k == "BackL") then
            e.fo3_vb02BackLSeat = true;
		elseif(k == "BackL2") then
            e.fo3_vb02BackL2Seat = true;
		elseif(k == "BackL3") then
            e.fo3_vb02BackL3Seat = true;
        elseif(k == "BackR") then
		    e.fo3_vb02BackRSeat = true;
		elseif(k == "BackR2") then
		    e.fo3_vb02BackR2Seat = true;
		elseif(k == "BackR3") then
		    e.fo3_vb02BackR3Seat = true;
		end
		self.Seats[k] = e;
	end

end

function ENT:Enter(p)
	self.BaseClass.Enter(self,p)
	if (IsValid(self.Pilot)) then --start motor animation
		if ( p == self.Pilot ) then
			if !self.layer_spin then
				self.layer_spin = self:AddLayeredSequence( self:LookupSequence("spin"), 0 )
			else
				self:SetLayerCycle(self.layer_spin,0)
				self:SetLayerPlaybackRate(self.layer_spin, 1.0)
			end
			jlib.Announce(p, Color(0, 255, 0, 255), "[INFORMATION] ", Color(255, 255, 0, 255), "Flight Controls: ",
				Color(255, 255, 255, 255), "\n· Right-click to fire missiles\n· Left-click to fire gun\n· R to drop mininuke\n· SHIFT to play music (if available)\n· ALT to swap view mode"
			)
		else
			self:Passenger(p)
		end
	end
end

function ENT:Exit(kill) --gets only called on Pilot- Passangers only leave seats
	self.BaseClass.Exit(self,kill);

	if IsValid(self.Pilot) then
		self.Pilot:SetRenderMode(RENDERMODE_TRANSALPHA);
		self.Pilot:SetColor(Color(255,255,255,255)); --ADI fixed base bug where Pilot is invisible after leaving
		self.Pilot = nil-- Sets the vehicle to no longer have a pilot
	end

    if(self.Land or self.TakeOff) then
		self:SetLayerPlaybackRate( self.layer_spin, 0 ) --stops motor animation
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
	if(not self:GetNWBool("Flying"..self.Vehicle) or p==self.Pilot ) then
		if(!p:KeyDown(IN_WALK)) then
			net.Start("sv_send_vertibird_toggle_ui")
			net.WriteEntity(self)
			net.Send(p) --sends only to activated player
		end
	end
end

hook.Add("PlayerLeaveVehicle", "fo3_vb02SeatExit", function(p,v)
	if(IsValid(p) and IsValid(v)) then
		if(v.Isfo3_vb02Seat) then
			if(v.fo3_vb02FrontLSeat) then

                local self = v:GetParent();
                p:SetPos(v:GetPos() + Vector(0,10,0) + self:GetForward());

			elseif(v.fo3_vb02BackRSeat) then
                p:SetPos(v:GetPos() + Vector(0,10,0) + self:GetForward());

			elseif(v.fo3_vb02BackR2Seat) then
                p:SetPos(v:GetPos() + Vector(0,10,0) + self:GetForward());

			elseif(v.fo3_vb02BackR3Seat) then
                p:SetPos(v:GetPos() + Vector(0,10,0) + self:GetForward());

			elseif(v.fo3_vb02BackLSeat) then
                p:SetPos(v:GetPos() + Vector(0,10,0) + self:GetForward());

			elseif(v.fo3_vb02BackL2Seat) then
                p:SetPos(v:GetPos() + Vector(0,10,0) + self:GetForward());

			elseif(v.fo3_vb02BackL3Seat) then
                p:SetPos(v:GetPos() + Vector(0,10,0) + self:GetForward());

			end
			p:SetNetworkedEntity("fo3_vb02",NULL);
            p:SetNetworkedEntity("fo3_vb02Seat",NULL);
		end
	end
end);

net.Receive( "cl_request_vertibird_seats", function( len, ply )
	local ent = net.ReadEntity()

	if IsValid(ent) then
		if ent:GetVehOwner() == ply then
			ent:Enter(ply)
		elseif not ent:GetNWBool("isDoor_locked") then
			ent:Enter(ply)
			ent:SetVehOwner(ply)
		else
			ply:falloutNotify("[!] The vertibird is locked", "ui/notify.mp3")
		end
	end
end)

net.Receive( "cl_request_vertibird_exit", function( len, ply )
	local self = net.ReadEntity()
	if IsValid(self) then
		if(self:GetNWBool("Flying"..self.Vehicle)) then
			self:Exit(false)
		end
	end
end)

net.Receive( "cl_request_vertibird_lock_toggle", function( len, ply )
	local self = net.ReadEntity() --get ENT/self reffrence
	if IsValid(self) and (!self.doorCooldown or CurTime() > self.doorCooldown) then
		if (self.door_open == 0 ) then
			if !self.layer_door then
				self.layer_door = self:AddLayeredSequence( self:LookupSequence("door_open"), 1 )
			else
				self:SetLayerSequence(self.layer_door, self:LookupSequence("door_open"))
				self:SetLayerCycle(self.layer_door,0)
				self:EmitSound("ambient/machines/wall_move1.wav", 35)
			end
			self.door_open = 1
			self:SetNWBool( "isDoor_locked", false )

			self:SpawnLadder(true)
			self:SpawnLadder(false)
		else
			self:SetLayerSequence(self.layer_door, self:LookupSequence("door_close"))
			self:SetLayerCycle(self.layer_door,0)
			self.door_open = 0
			self:SetNWBool( "isDoor_locked", true )
			self:EmitSound("ambient/machines/wall_move3.wav", 35)
			self:RemoveLadders()
		end
		self.doorCooldown = CurTime() + 3
	end
end)

end

if CLIENT then
	--UI materials ADI
	local ui_exit = Material("hud/all_danger/vertibird/ui_exit.png","noclamp smooth")
	local ui_lock_closed = Material("hud/all_danger/vertibird/ui_lock_closed.png","noclamp smooth")
	local ui_lock_open = Material("hud/all_danger/vertibird/ui_lock_open.png","noclamp smooth")
	local ui_seat = Material("hud/all_danger/vertibird/ui_seat.png","noclamp smooth")
	local ui_engin_off = Material("hud/all_danger/vertibird/ui_engin_off.png","noclamp smooth")
	local ui_engin_on = Material("hud/all_danger/vertibird/ui_engin_on.png","noclamp smooth")
	--end -- UI materials
	ENT.CanFPV = false;
	ENT.Sounds={
		Engine=Sound("vehicles/falcon_fly.wav"),
	}
	local UI_e_Frame
	local View = {}

	function adi_use_ui(ent_ref)
		UI_e_Frame = vgui.Create( "DFrame" )
		local fw, fh = ScrW()/(1920/250), ScrW()/(1920/80)
		local icon_size = fh --100
		local space = ScrW()/(1920/40)--40
		UI_e_Frame:SetSize( fw, fh )
		UI_e_Frame:SetTitle( "" )
		UI_e_Frame.lblTitle:SetVisible(false)
		UI_e_Frame:ShowCloseButton( false )
		UI_e_Frame:SetVisible( true )
		UI_e_Frame:SetDraggable( false )
		UI_e_Frame:SetScreenLock( false )
		UI_e_Frame:Center()
		UI_e_Frame:MakePopup()
		UI_e_Frame:SetKeyboardInputEnabled( false )

		UI_e_Frame.OnMousePressed = function(self,keyCode)
			if keyCode == MOUSE_RIGHT then
				UI_e_Frame:Close() --self refers here to UI_e_Frame not ENT
			end
		end
		UI_e_Frame.OnFocusChanged = function(self,focus)
			if not focus then
				UI_e_Frame:Close() --self refers here to UI_e_Frame not ENT
			end
		end

		UI_e_Frame.Paint = function( self, w, h )
			surface.SetDrawColor(0,0,0,255)--invisible UI_e_Frame
			surface.DrawRect( 0, 0, w, h )
		end
		---------Engin BUTTON-----------
			--[[
			local engin_button = vgui.Create( "DButton", UI_e_Frame )
			engin_button:SetText("")
			engin_button:SetSize(icon_size,icon_size)
			engin_button:SetPos(0,0)
			engin_button.motor_is_on = false --TODO change on Engine ona nd off
			engin_button.Paint = function( self, w, h )
				surface.SetDrawColor(255,255,255,255)
				if engin_button.motor_is_on then
					surface.SetMaterial(ui_engin_off)
				else
					surface.SetMaterial(ui_engin_on)
				end
					surface.DrawTexturedRect(0,0, w, h)
				return true
			end
			engin_button.DoClick = function()
				if engin_button.motor_is_on then
					engin_button.motor_is_on = false
				else
					engin_button.motor_is_on = true
				end
			end
			--]]
		---------lock BUTTON-----------
			local lock_button = vgui.Create( "DButton", UI_e_Frame )
			lock_button:SetText("")
			lock_button:SetSize(icon_size,icon_size)
			lock_button:SetPos(0,0)
			lock_button.Paint = function( self, w, h )
				surface.SetDrawColor(255,255,0,255)
				if ent_ref:GetNWBool("isDoor_locked") then
					surface.SetMaterial(ui_lock_closed)
				else
					surface.SetMaterial(ui_lock_open)
				end
					surface.DrawTexturedRect(0,0, w, h)
				return true
			end
			lock_button.DoClick = function()
				net.Start( "cl_request_vertibird_lock_toggle" )
				net.WriteEntity(ent_ref)
				net.SendToServer()
			end
		---------seat BUTTON-----------
			local seat_button = vgui.Create( "DButton", UI_e_Frame )
			seat_button:SetText("")
			seat_button:SetSize(icon_size,icon_size)
			seat_button:SetPos(icon_size,0)
			seat_button.Paint = function( self, w, h )
				surface.SetDrawColor(255,255,0,255)
				surface.SetMaterial(ui_seat)
				surface.DrawTexturedRect(0,0, w, h)
				return true
			end
			seat_button.DoClick = function()
				net.Start( "cl_request_vertibird_seats" )
				net.WriteEntity(ent_ref)
				net.SendToServer()
				UI_e_Frame:Close()
			end
		---------exit BUTTON-----------
			local exit_button = vgui.Create( "DButton", UI_e_Frame )
			exit_button:SetText("")
			exit_button:SetSize(icon_size,icon_size)
			exit_button:SetPos(icon_size*2,0)
			exit_button.Paint = function( self, w, h )
				surface.SetDrawColor(255,255,0,255)
				surface.SetMaterial(ui_exit)
				surface.DrawTexturedRect(0,0, w, h)
				return true
			end
			exit_button.DoClick = function()
				net.Start( "cl_request_vertibird_exit" )
				net.WriteEntity(ent_ref)
				net.SendToServer()
				UI_e_Frame:Close()
			end
		--END BUTTONS-----------
	end

	function ENT:Initialize()
		self.Emitter = ParticleEmitter(self:GetPos());
		self.BaseClass.Initialize(self);
	end

	function CalcView()
		local p = LocalPlayer();
		local self = p:GetNetworkedEntity("fo3_vb02", NULL)
		if(IsValid(self)) then
			local fpvPos = self:GetPos()+self:GetUp()*40+self:GetForward()*300+self:GetRight()*1;
			View = HALOVehicleView(self,1500,800,fpvPos,true);
			return View;
		end
	end
	hook.Add("CalcView", "fo3_vb02View", CalcView)

	function ENT:Effects()


		local p = LocalPlayer();
		local roll = math.Rand(-45,45);
		local normal = (self.Entity:GetRight() * -1):GetNormalized();
		local FWD = self:GetRight();
		local id = self:EntIndex();


	end

	function ENT:Think()
		local vector_speed = self:GetVelocity()
		local local_vector,local_angle = WorldToLocal(Vector(0,0,0) ,angle_zero, vector_speed, self:GetAngles()+Angle(0,180,180))
		local ver_speed = local_vector:ToTable() --local_vector[x]
		local ang_speed = vector_speed:ToTable()
		post_value = (ver_speed[1]/1400)+(ver_speed[2]/240)
		self:SetPoseParameter("wing_l",post_value)
		self:SetPoseParameter("wing_r",(ver_speed[1]/1400)-(ver_speed[2]/240))
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

	function fo3_vb02Reticle()
			local p = LocalPlayer()
			local self = p:GetNWEntity("fo3_vb02")

			if IsValid(self) then
				if (self.Base == "adihover_base") then --debug not using globals thx
					self:haloADI_HUD_DrawHull(self.StartHealth)
					self:haloADI_UNSCReticles(self)
					self:haloADI_BlastIcon(self,8)
				else
					---DEBUG
					--[[
					local position_test = self:GetPos()+self:GetForward()*345+self:GetUp()*64+self:GetRight()*-48
					cam.Start3D()
						render.DrawBox( position_test, Angle(0,0,0),Vector(0,0,0),Vector(30,30,30),Color( 255, 255, 255 ))
					cam.End3D()
					--]]
					---DEBUG
					HALO_HUD_DrawHull(self.StartHealth)
					HALO_UNSCReticles(self)
					HALO_BlastIcon(self,8)
				end
			end
		end
	hook.Add("HUDPaint", "fo3_vb02Reticle", fo3_vb02Reticle)

	net.Receive( "sv_send_vertibird_toggle_ui", function( len, ply )
		local ent_ref = net.ReadEntity()
		if IsValid( UI_e_Frame ) then
			UI_e_Frame:Close()
		else
			adi_use_ui(ent_ref)
		end
	end)

end

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "VehOwner")

	if SERVER then
		self:SetVehOwner(NULL)
	end
end
