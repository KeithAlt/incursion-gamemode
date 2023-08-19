ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Base = "haloveh_base"
ENT.Type = "vehicle"
ENT.PrintName = "Duchess Gambit"
ENT.Author = "Extra"
--- BASE AUTHOR: Liam0102 ---
ENT.Category = "Vertibirds"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.EntModel = "models/props/keitho/gambit.mdl"
ENT.FlyModel = "models/props/keitho/gambit_fly.mdl"
ENT.Vehicle = "fo4_gambit"
ENT.StartHealth = 50000 -- Health
ENT.Allegiance = ""
ENT.IsCapitalShip = true
ENT.MaxAngForce = 18
ENT.DontSpin = true
ENT.LockHover = true
list.Set("Fallout Vehicles", ENT.PrintName, ENT)

globalGambitList = globalGambitList or {}

if SERVER then
	--creates a ladder on the side of the vehicle
	function ENT:SpawnLadder(left)
		local ladder = ents.Create("base_gmodentity")
		ladder:SetModel("models/props_c17/metalladder002.mdl")
		--ladder:SetModelScale(2)
		local ladderPos

		if (left) then
			ladderPos = self:GetPos() + self:GetUp() * 130 + self:GetRight() * -190
			ladder:SetAngles(self:GetAngles() + Angle(0, 90, 0))
		else
			ladderPos = self:GetPos() + self:GetUp() * 130 + self:GetRight() * 180
			ladder:SetAngles(self:GetAngles() + Angle(0, 270, 0))
		end

		ladder:SetPos(ladderPos)
		ladder:SetSolid(SOLID_VPHYSICS)
		ladder:SetMoveType(MOVETYPE_NONE)
		ladder:SetParent(self)

		ladder.Use = function(_, activator)
			local ladderTop = ladder:GetPos() + ladder:GetUp() * 150
			local ladderBot = ladder:GetPos() + ladder:GetForward() * 50 + ladder:GetUp() * 10
			local activatorPos = activator:GetPos()

			if (ladderBot:DistToSqr(activatorPos) > ladderTop:DistToSqr(activatorPos)) then
				activator:SetPos(ladderBot) --go to bot if that's the furthest away
			else
				activator:SetPos(ladderTop) --go to top if that's the furthest away
			end
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

		self:DeleteOnRemove(ladder)
	end

	function ENT:thrusterFire(offset, index, left)
		local sideOffset

		if (left) then
			sideOffset = 200
		else
			sideOffset = -200
		end

		self.fires[index] = ents.Create("mr_effect32")
		self.fires[index]:SetPos(self:GetPos() + self:GetForward() * sideOffset + self:GetUp() * 100)
		self.fires[index]:SetAngles(Angle(-90, 0, 0))
		self.fires[index]:SetMoveType(MOVETYPE_NONE)
		self.fires[index]:FollowBone(self, index)
		self.fires[index]:Spawn()
		self.fires[index]:Activate()
	end

	--try not to stack these accidentally or you'll get persisting fire
	function ENT:thrusterDuration(duration, delay)
		timer.Simple(delay or 0, function()
			if (IsValid(self)) then
				util.ScreenShake(self:GetPos(), 50, 50, duration, 5000)

				--removes existing fires just in case
				if (self.fires) then
					for k, v in pairs(self.fires or {}) do
						SafeRemoveEntity(v)
					end

					self.fires = nil
				end

				self.fires = {}

				--creates the thruster fire
				local wings = {"wing_l_1", "wing_l_2", "wing_r_1", "wing_r_2"}

				for k, v in pairs(wings) do
					local bone = self:LookupBone(v)
					if bone == nil then break end
					local pos, ang = self:GetBonePosition(bone)

					--this stupid thing is done so it can be offset properly
					if (k <= 2) then
						self:thrusterFire(pos, bone, true) --left wings
					else
						self:thrusterFire(pos, bone, false) --right wings
					end
				end

				--deletes the thruster fire when timer expires
				timer.Simple(duration or 1, function()
					if (IsValid(self)) then
						for k, v in pairs(self.fires or {}) do
							SafeRemoveEntity(v)
						end

						self.fires = nil
					end
				end)
			end
		end)
	end

	function ENT:SongSequence()
		self:EmitSound("gambit/theboom.ogg", 511)
		self:thrusterDuration(1, 0)
		self:thrusterDuration(1, 2)
		self:thrusterDuration(1, 5)
		self:thrusterDuration(1, 8.25)
		self:thrusterDuration(1, 11.5)
		self:thrusterDuration(17, 42)
		self:thrusterDuration(1, 80)
		self:thrusterDuration(1, 82)
		self:thrusterDuration(1, 84)
		self:thrusterDuration(1, 86)
		self:thrusterDuration(1, 90)
		self:thrusterDuration(1, 94)
		self:thrusterDuration(1, 95)
		self:thrusterDuration(1, 97)
		self:thrusterDuration(1, 101)
		self:thrusterDuration(1.5, 106)
		self:thrusterDuration(12, 109)
		self:thrusterDuration(1, 148)
		self:thrusterDuration(1, 150)
		self:thrusterDuration(1, 152)
		self:thrusterDuration(1, 156)
		self:thrusterDuration(1, 158)
		self:thrusterDuration(1, 160)
		self:thrusterDuration(1, 162)
		self:thrusterDuration(1, 164)
		self:thrusterDuration(1.5, 168)
		self:thrusterDuration(2, 180)

		timer.Simple(180, function()
			self.songPlaying = nil
		end)
	end

	function ENT:Think()
		if (IsValid(self.Pilot) and self.Pilot:KeyDown(IN_SPEED) and self.Pilot:KeyDown(IN_ATTACK)) then
			if (not self.songPlaying) then
				self.songPlaying = true
				self:SongSequence()
			end
		end

		self.BaseClass.Think(self)
	end

	function ENT:FireWeapons()
	end

	ENT.FireSound = Sound("weapons/lightbolt.wav")

	ENT.NextUse = {
		Wings = CurTime(),
		Use = CurTime(),
		Fire = CurTime(),
		LockHover = CurTime()
	}

	AddCSLuaFile()

	function ENT:SpawnFunction(pl, tr)
		local e = ents.Create("fo4_gambit")
		e:SetPos(tr.HitPos + Vector(0, 0, 10))
		e:SetAngles(Angle(0, pl:GetAimVector():Angle().Yaw, 0))
		e:Spawn()
		e:Activate()

		return e
	end

	local al = 1

	function ENT:Initialize()
		self.factionSpawn = FACTION_CHILD
		self.MissileDelay = 0
		self:SetNWInt("Health", self.StartHealth)

		self.tblIndex = table.insert(globalGambitList, self)

		--
		self.WeaponLocations = {
			Left = self:GetPos() + self:GetForward() * 345 + self:GetUp() * 64 + self:GetRight() * -48,
			Right = self:GetPos() + self:GetForward() * 345 + self:GetUp() * 64 + self:GetRight() * -48
		}

		--
		self.TurretLocations = {
			[1] = {self:GetPos() + self:GetForward() * 50 + self:GetUp() * 225 + self:GetRight() * 165, self:GetAngles() + Angle(0, 90, 0)},
			[2] = {self:GetPos() + self:GetForward() * 50 + self:GetUp() * 225 - self:GetRight() * 165, self:GetAngles() + Angle(0, -90, 0)}
		}

		self:SpawnTurrets()
		self:SpawnLadder(true) --true for left side ladder
		self:SpawnLadder(false) --false for right side ladder
		--
		self.WeaponsTable = {}
		self.BoostSpeed = 250
		self.ForwardSpeed = 250
		self.UpSpeed = 200
		self.AccelSpeed = 1
		self.CanBack = false
		self.CanStrafe = true
		self.Cooldown = 2
		self.CanShoot = true
		self.DontOverheat = true
		self.FireSound = "weapons/shotgunsingle/wpn_singleshotgun_fire.wav"
		self.Bullet = HALOCreateBulletStructure(50, "red", false)
		self.FireDelay = 3
		self.NextBlast = 1
		self.AlternateFire = true

		self.FireGroup = {"Left", "Right"}

		self.ExitModifier = {
			x = 0,
			y = 280,
			z = 390
		}

		self.Hover = true

		self.SeatPos = {
			BackR = {self:GetPos() + self:GetForward() * -300 + self:GetUp() * 255 + self:GetRight() * 70, self:GetAngles() + Angle(0, 90, 0)},
			BackL = {self:GetPos() + self:GetForward() * -300 + self:GetUp() * 255 - self:GetRight() * 70, self:GetAngles() + Angle(0, -90, 0)},
			MidR = {self:GetPos() + self:GetForward() * -220 + self:GetUp() * 255 + self:GetRight() * 70, self:GetAngles() + Angle(0, 90, 0)},
			MidL = {self:GetPos() + self:GetForward() * -220 + self:GetUp() * 255 - self:GetRight() * 70, self:GetAngles() + Angle(0, -90, 0)},
			MidR2 = {self:GetPos() + self:GetForward() * -110 + self:GetUp() * 255 + self:GetRight() * 70, self:GetAngles() + Angle(0, 90, 0)},
			MidL2 = {self:GetPos() + self:GetForward() * -110 + self:GetUp() * 255 + self:GetRight() * -70, self:GetAngles() + Angle(0, -90, 0)},
			FrontR = {self:GetPos() + self:GetForward() * 280 + self:GetUp() * 255 + self:GetRight() * 50, self:GetAngles() + Angle(0, 90, 0)},
			FrontL = {self:GetPos() + self:GetForward() * 280 + self:GetUp() * 255 + self:GetRight() * -50, self:GetAngles() + Angle(0, -90, 0)}
		}

		self:SpawnSeats()
		self.HasLookaround = true
		self.PilotVisible = true

		self.PilotPosition = {
			x = 0,
			y = 300,
			z = 380
		}

		self.PilotAnim = "sit_rollercoaster"
		self.BaseClass.Initialize(self)
	end

	function ENT:OnRemove()
		table.remove(globalGambitList, self.tblIndex)
		self.BaseClass.OnRemove(self)
	end

	function ENT:SpawnTurrets()
		self.Turrets = {}

		for k, v in pairs(self.TurretLocations) do
			local e = ents.Create("weldable_seat1")
			e:SetPos(v[1])
			e:SetAngles(v[2] + Angle(0, -90, 0))
			e:Spawn()
			e:Activate()
			e:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			--e:SetParent( self )
			constraint.NoCollide(e, self, 0, 0)

			--
			timer.Simple(0, function()
				local base = e.Veh
				base.isGambitSeat = true
				base.isTurret = true
				--base:SetParent(self);
				constraint.NoCollide(base, self, 0, 0)
				local bone1 = self:LookupBone("root")
				local bone2 = base:LookupBone("airboat_seat_bone")
				constraint.Weld(self, base, bone1, bone2, 0, true, false)
			end)

			--e:GetPhysicsObject():EnableCollisions(false);
			--e:GetPhysicsObject():EnableMotion(false);
			self.Turrets[k] = e
			self:DeleteOnRemove(e)
		end
	end

	function ENT:SpawnSeats()
		self.Seats = {}

		for k, v in pairs(self.SeatPos) do
			local e = ents.Create("prop_vehicle_prisoner_pod")
			e:SetPos(v[1])
			e:SetAngles(v[2] + Angle(0, -90, 0))
			e:SetParent(self)
			e:SetModel("models/nova/airboat_seat.mdl")
			e:SetRenderMode(RENDERMODE_TRANSALPHA)
			e:SetColor(Color(255, 255, 255, 0))
			e:Spawn()
			e:Activate()
			e:SetUseType(USE_OFF)
			e:GetPhysicsObject():EnableMotion(false)
			e:GetPhysicsObject():EnableCollisions(false)
			e.isGambitSeat = true
			self.Seats[k] = e
			self:DeleteOnRemove(e)
		end
	end

	function ENT:Enter(p)
		self.BaseClass.Enter(self, p)
		p:SetNWEntity("fallout_veh", self)

		self:ToggleHover(false)

		if (IsValid(self.Pilot)) then
			self:SetModel(self.FlyModel)
		end
	end

	function ENT:Exit(kill)
		if IsValid(self.Pilot) then
			self.Pilot:SetNWEntity("fallout_veh", NULL)
			self:ToggleHover(true)
		end

		//self.Pilot = nil-- Sets the vehicle to no longer have a pilot
		self.BaseClass.Exit(self, kill)

		if (self.Land or self.TakeOff) then
			if not self.LockHover then
				self:SetModel(self.EntModel)
			end
		end
	end

	function ENT:ToggleHover(boolean)
		if boolean then
			self:SetModel(self.FlyModel)
			self:EmitSound("vehicles/falcon_fly.wav")

			local phys = self:GetPhysicsObject()
			phys:EnableMotion(false)
		else
			self:SetModel(self.EntModel)

			local phys = self:GetPhysicsObject()
			phys:EnableMotion(true)

			self:StopSound("vehicles/falcon_fly.wav")
		end
	end

	function ENT:Passenger(p, seat_num)
		if (self.NextUse.Use > CurTime()) then return end
		--
		local seat

		if seat_num then
			seat = self.Seats[seat_num]
		else
			for k, v in pairs(self.Seats) do
				if (v:GetPassenger(1) == NULL) then
					seat = v
					break
				end
			end
		end

		--
		p:EnterVehicle(seat)
		p:SetAllowWeaponsInVehicle(false)
	end

	function ENT:Use(p)
		if (not self.Inflight) then
			if (not p:KeyDown(IN_WALK)) then
				local ppos = self.PilotPosition
				local wheelpos = self:GetPos() + self:GetForward() * ppos.y + self:GetUp() * ppos.z
				local dist = p:GetPos():Distance(wheelpos)

				if dist <= 100 then
					self:Enter(p)
				end
			else
				self:Passenger(p)
			end
		else
			if (p ~= self.Pilot) then
				self:Passenger(p)
			end
		end
	end

	hook.Add("PlayerLeaveVehicle", "fo4_gambitExit", function(p, v)
		if (IsValid(p) and IsValid(v)) then
			if (v.isGambitSeat) then
				if v.isTurret then
					local newpos = v:GetPos() + v:GetUp() * 15 - v:GetForward() * 35
					p:SetPos(newpos)
				else
					p:SetNWEntity("fallout_veh", NULL)
					local newpos = v:GetPos() - v:GetUp() * 15 + v:GetForward() * 35
					p:SetPos(newpos)
				end
			end
		end
	end)
end

if CLIENT then
	ENT.CanFPV = true

	ENT.Sounds = {
		Engine = Sound("vehicles/falcon_fly.wav")
	}

	function ENT:Initialize()
		self.Emitter = ParticleEmitter(self:GetPos())
		self.BaseClass.Initialize(self)
	end

	function ENT:OnRemove()
		self:StopSound("vehicles/falcon_fly.wav")
		self.Emitter:Finish()
		self.BaseClass.OnRemove(self)
	end

	local View = {}

	local function CalcView()
		local p = LocalPlayer()
		local self = p:GetNWEntity("fallout_veh", NULL)

		if (IsValid(self)) then
			local fpvPos = self:GetPos() + self:GetUp() * 443 + self:GetForward() * 256
			View = HALOVehicleView(self, 900, 450, fpvPos, true)

			return View
		end
	end

	hook.Add("CalcView", "fo4_gambitView", CalcView)

	function ENT:Think()
		local gearTrace = util.QuickTrace(self:GetPos(), (Vector(0, 0, -200)), {self})

		if (self:GetBodygroup(2) == 0 and not gearTrace.Hit) then
			self:SetBodygroup(2, 1)
		elseif (self:GetBodygroup(2) == 1 and gearTrace.Hit and self:GetNWInt("Speed") < 300) then
			self:SetBodygroup(2, 0)
		end

		local roll = 90 * (self:GetNWInt("Speed") / 250)

		local wings = {"wing_l_1", "wing_l_2", "wing_r_1", "wing_r_2"}

		for k, v in pairs(wings) do
			local bone = self:LookupBone(v)
			if bone == nil then break end
			self:ManipulateBoneAngles(bone, Angle(0, 0, roll))
		end

		--[[
		local p = LocalPlayer();
		local Flying = self:GetNWBool("Flying".. self.Vehicle);
		if(Flying) then
			self.VB02EnginePos = {
				self:GetPos()+self:GetRight()*-63+self:GetUp()*114+self:GetForward()*-85,
				self:GetPos()+self:GetRight()*14+self:GetUp()*114+self:GetForward()*-85,
			}
			self:Effects();
		end]]
		self.BaseClass.Think(self)
		--print(self.Pilot)
	end

	function fo4_gambitReticle()
		local p = LocalPlayer()
		local self = p:GetNWEntity("fallout_veh")

		if IsValid(self) then
			HALO_HUD_DrawHull(self.StartHealth)
			HALO_UNSCReticles(self)
			HALO_BlastIcon(self, 8)
		end
	end

	hook.Add("HUDPaint", "fo4_gambitReticle", fo4_gambitReticle)
end

if (SERVER) then
	--this respawns people at the airship if they're the specified faction.
	local function airshipSpawn(client)
		local char = client:getChar()

		if (char) then
			local faction = char:getFaction()

			for i, ent in ipairs(globalGambitList) do
				if IsValid(ent) and ent.factionSpawn and ent.factionSpawn == faction then
					jlib.CallAfterTicks(2, function()
						if IsValid(client) then
							client:SetPos(ent:GetPos() + ent:GetUp() * 250)
						end
					end)

					break
				end
			end
		end
	end

	hook.Add("PostPlayerLoadout", "airshipFactionSpawn", airshipSpawn)
end
