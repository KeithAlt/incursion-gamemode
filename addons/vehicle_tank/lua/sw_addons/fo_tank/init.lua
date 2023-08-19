local Ang0 = Angle()
local Vec0 = Vector()
local Category = "Fallout Tank"
local Veh_Class = "prop_vehicle_jeep"
local Pas_Class = "prop_vehicle_prisoner_pod"
local Author = ""
local NiceName = "FalloutTank"
local BulletInfo = {}

if !SW_ADDON then
	SW_Addons.AutoReloadAddon(function() end)
	return
end

SW_ADDON.NetworkaddonID = "SW_"..SW_ADDON.Addonname
SW_ADDON.Category = Category
SW_ADDON.Author = Author
SW_ADDON.NiceName = NiceName

local V = {
	Name = "Tank",
	Class = "prop_vehicle_jeep",
	Category = Category,
	Author = "",
	Information = "Tank",
	Model = "models/sentry/tank_fo4.mdl",

	SW_Values_Tank = {},

	KeyValues = {
		vehiclescript = "scripts/vehicles/fallouttank.txt",
	},
}
list.Set("Vehicles", "FO_Tank", V)

function SW_ADDON:Spawn(ply, vehicle)

if !vehicle.VehicleTable then return end

local RF = RecipientFilter()
RF:AddAllPlayers()

if istable(vehicle.VehicleTable.SW_Values_Tank) then
	self:AddToEntList("FO_Tank", vehicle)
	vehicle.__IsFO_Tank = true
	vehicle.__Speed = 0
	vehicle.S_Tower = 0

	vehicle.Type = "anim"

	vehicle:SetHealth(15000)

	vehicle.__Idle = CreateSound(vehicle, "FO_Tank_Idle", RF)
	vehicle.__Drive = CreateSound(vehicle, "FO_Tank_Drive", RF)
	vehicle.__Tracks = CreateSound(vehicle, "FO_Tank_Tracks", RF)
	self:SoundEdit(vehicle.__Idle, 4, 0, 0, 0, 0)
	self:SoundEdit(vehicle.__Drive, 4, 0, 0, 0, 0)
	self:SoundEdit(vehicle.__Tracks, 4, 0, 0, 0, 0)

	vehicle:CallOnRemove("Stop_FO_Tank_Drive", function(f_ent)
		self:SoundEdit(f_ent.__Idle, 0)
		self:SoundEdit(f_ent.__Drive, 0)
		self:SoundEdit(f_ent.__Tracks, 0)
	end)
end

end

if SERVER then

function SW_ADDON:Think()
	self:ForEachInEntList("FO_Tank", function(addon, index, ent)
		if !ent.__IsFO_Tank then return end
		self:ThinkPerEnt(ent)
	end)
end

-- Reduces Entity health upon damage taken
function SW_ADDON:EntityTakeDamage(ent, dmgInfo)
	if !ent.__IsFO_Tank then return end
	ent:SetHealth(ent:Health() - dmgInfo:GetDamage())
end

function SW_ADDON:ThinkPerEnt(ent)
	local ply = ent:GetDriver()
	if !IsValid(ply) then return end
	if !ply:InVehicle() then return end
	local phys = ent:GetPhysicsObject()
	if !IsValid(phys) then return end

	if !ent.__Speed then return end

	local vec_rgt_p = self:VectorToLocalToWorld(ent, Vector(0,1000,0))
	local vec_rgt_m = self:VectorToLocalToWorld(ent, Vector(0,-1000,0))
	local dir_fwd = self:DirToLocalToWorld(ent, Ang0, "Forward")
	local dir_rgt = self:DirToLocalToWorld(ent, Ang0, "Right")
	local dir_up = self:DirToLocalToWorld(ent, Ang0, "Up")

	ent.__Speed = math.Clamp(ent.__Speed, -250, 400)

	if ent:IsEngineEnabled() then
		local Speed = self:GetForwardVelocity(ent)
		local UnitKmh = self:GetKPHSpeed(Speed)
		local Kmh = math.abs(UnitKmh)
		local pitch = math.Clamp(math.abs(Speed) * 0.2, 0, 165)

		self:SoundEdit(ent.__Idle, 2, 100+pitch/2, 0)
		self:SoundEdit(ent.__Drive, 2, pitch, 0)
		self:SoundEdit(ent.__Tracks, 2, pitch, 0)
	else
		self:SoundEdit(ent.__Idle, 2, 0, 0)
		self:SoundEdit(ent.__Drive, 2, 0, 0)
		self:SoundEdit(ent.__Tracks, 2, 0, 0)
		return
	end

	local FT = FrameTime()
	local plyang = ply:EyeAngles()
	plyang:Normalize()
	local Aim = plyang.p
	local AimPitch =  math.Clamp(Aim, -30, 10)
	local Tower = plyang.y-ent:GetAngles().y
	local W_Tower = math.Round((((Tower - ent.S_Tower) + 180) % 360 - 180),10)

	-- Move tank tower with aim
	if !ent.__FO_Tank_TowerLock then
		if W_Tower > 0 then
			ent.S_Tower = ent.S_Tower + 0.1*math.Min(W_Tower,15)
		elseif W_Tower < 0 then
			ent.S_Tower = ent.S_Tower + 0.1*math.Max(W_Tower,-15)
		end
		self:ChangePoseParameter(ent, -90+ent.S_Tower, "main_yaw")
		self:ChangePoseParameter(ent, 0-AimPitch, "main_pitch")
	end

	-- Right
	if ply:KeyDown(IN_MOVERIGHT) then
		phys:ApplyForceOffset(dir_fwd*25000, vec_rgt_p)
		phys:ApplyForceOffset(dir_fwd*-25000, vec_rgt_m)
	end

	-- Left
	if ply:KeyDown(IN_MOVELEFT) then
		phys:ApplyForceOffset(dir_fwd*-25000, vec_rgt_p)
		phys:ApplyForceOffset(dir_fwd*25000, vec_rgt_m)
	end

	-- Forward
	if ply:KeyDown(IN_FORWARD) then
		ent.__Speed = ent.__Speed + FT * 450
	end

	-- Backwards
	if ply:KeyDown(IN_BACK) then
		ent.__Speed = ent.__Speed - FT * 450
	end

	-- Brakes
	if ply:KeyDown(IN_JUMP) then
		if ent.__Speed >= 5 then
			ent.__Speed = ent.__Speed - FT * 1500
			if ent.__Speed <= 4 then
				ent.__Speed = 0
			end
		end

		if ent.__Speed <= -5 then
			ent.__Speed = ent.__Speed + FT * 1500
			if ent.__Speed >= -4 then
				ent.__Speed = 0
			end
		end
	end

	if ply:KeyDown(IN_ATTACK) then
		local Delay = ent.__FO_FireDelay or 0
		if (CurTime() - Delay) > 2.5 then
			ent.__FO_FireDelay = CurTime()

			for index, entInRange in pairs(ents.FindInSphere(ent:GetPos(), 1000)) do
				if entInRange:IsPlayer() and entInRange:Alive() then
					entInRange:ScreenFade(SCREENFADE.IN, Color(255, 175, 50, 75), 0.25, 0)
				end
			end

			util.ScreenShake(ent:GetPos(), 250, 100, 1, 1200)

			ent:EmitSound("vehicles/sgmcars/tank_fo4/fire.wav", 90, 100)
			ent:EmitSound("vehicles/sgmcars/tank_fo4/reload.wav", 90, 100)

			local Pos, Ang = ent:GetBonePosition(2)
			if !Pos or !Ang then return end

			for i = 1, 2 do
				local Bomb = self:MakeEnt("grenade_ar2", ply, ent, "Bomb")

				if IsValid(Bomb) then
					local muzzleFlashEffectPos = Pos + Ang:Forward()*200 + Ang:Right()*8*(-1)^i
					local muzzleFlashEffect = EffectData()
					muzzleFlashEffect:SetOrigin( muzzleFlashEffectPos )
					util.Effect( "Explosion", muzzleFlashEffect )

					Bomb:SetPos(Pos + Ang:Forward()*180 + Ang:Right()*8*(-1)^i)
					Bomb:SetAngles(Ang)
					Bomb:Spawn()
					Bomb:SetOwner(ply)
					Bomb:SetVelocity(Bomb:GetAngles():Forward()*3500)
					Bomb:SetModel("models/Items/AR2_Grenade.mdl")
					Bomb:SetModelScale(3)
					Bomb:SetGravity(1)

					local Trail = util.SpriteTrail(Bomb, 0, Color(120,120,120,255), false, 10, 35, 1, 1 / ( 10 + 35 ) * 0.5, "trails/smoke.vmt" )
					Trail:SetParent(Bomb)

					Bomb:CallOnRemove("FO_Tank_Extra_Explosion", function(f_ent)
						if !IsValid(f_ent) then return end
						if !IsValid(ply) then return end

						local effectdata = EffectData()
						effectdata:SetOrigin(f_ent:GetPos())
						util.Effect("effect_avehicle_enegyexplosion", effectdata, true, true)
						util.BlastDamage(f_ent, ply, f_ent:GetPos(), 200, 150)
						util.ScreenShake(f_ent:GetPos(), 250, 100, 1.5, 1000)
					end)
				end
			end
		end
	end

	local velocity
	if ent.__Speed >= 0 then
		if ent:GetAngles().r >= 50 then return end
		velocity = dir_rgt*-ent.__Speed - dir_up*ent.__Speed/50
	end
	if ent.__Speed <= -0 then
		if ent:GetAngles().r <= -50 then return end
		velocity = dir_rgt*-ent.__Speed - dir_up*ent.__Speed/50
	end

	phys:SetVelocity(velocity)
end

end
--
-- Entering the vehicle
function SW_ADDON:Enter(ply,vehicle)
	if CLIENT then return end

    if !IsValid(ply) then return end
    local vehicle = ply:GetVehicle()
    if !IsValid(vehicle) then return end

	if !vehicle.__IsFO_Tank then return end

	self:ViewEnt(ply)
	ply:setWepRaised(true) // helps against bug

	self:SoundEdit(vehicle.__Idle, 3, 0, 0, 1, 0)
	self:SoundEdit(vehicle.__Drive, 3, 0, 0, 1, 0)
	self:SoundEdit(vehicle.__Tracks, 3, 0, 0, 1, 0)
end

-- Exit the vehicle
function SW_ADDON:Leave(ply,vehicle)
	if CLIENT then return end

    if !IsValid(ply) then return end
    local vehicle = ply:GetVehicle()
    if !IsValid(vehicle) then return end

	if !vehicle.__IsFO_Tank then return end

	self:Exit_Seat(vehicle, ply, 130, 0, -30, 130 ,0, 20)

	if !self:Exit_Seat(vehicle, ply, 130, 0, -30, 130 ,0, 20) then
		self:Exit_Seat(vehicle, ply, -130, 0, -30, -130 ,0, 20)
	end

	self:ViewEnt(ply)
	ply:SetHealth(100)
	vehicle.__Speed = 0

	self:SoundEdit(vehicle.__Idle, 3, 0, 0, 0, 0)
	self:SoundEdit(vehicle.__Drive, 3, 0, 0, 0, 0)
	self:SoundEdit(vehicle.__Tracks, 3, 0, 0, 0, 0)
end

SW_ADDON:RegisterVehicleOrder("TowerLock", nil, function(self, ply, veh)
	if !veh.__IsFO_Tank then return end
	veh.__FO_Tank_TowerLock = !veh.__FO_Tank_TowerLock

	--veh:EmitSound("vehicles/sligwolf/generic/light.wav", 70, 100)
end)
SW_ADDON:RegisterKeySettings("TowerLock", KEY_LALT, 0.25, "Lock The Tower In Place", "")
