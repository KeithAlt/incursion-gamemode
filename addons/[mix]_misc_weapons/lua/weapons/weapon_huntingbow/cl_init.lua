include("shared.lua")

SWEP.Slot = 2
SWEP.SlotPos = 10

SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

SWEP.DrawWeaponInfoBox = false
SWEP.BounceWeaponIcon = false

SWEP.SwayScale = 0
SWEP.BobScale = 0

SWEP.RenderGroup = RENDERGROUP_OPAQUE

function SWEP:DrawHUD()
	return false
end

function SWEP:FreezeMovement()
	return false
end

function SWEP:OnRestore()

end

function SWEP:OnRemove()

end

local _ang = Angle(0, 0, 0)

SWEP.VMOrigin = Vector(0, 0, 0)

SWEP.BobCycle = 0

SWEP.BobPos  = Vector(0, 0, 0)
SWEP.BobPos2 = Vector(0, 0, 0)

local vm_origin = Vector(0, 0, 0)
local vm_angles = Angle(0, 0, 0)

SWEP.AimOrigin = Vector(-6, -3, 1)
SWEP.AimAngles = Angle(1, 0, -45)

SWEP.AimMult  = 0
SWEP.AimMult2 = 0

SWEP.LastAimState = false

SWEP.SpeedMult = 0
SWEP.SideSpeed = 0

SWEP.LastAngles = Angle(0, 0, 0)
SWEP.AimFOV = 25

function SWEP:PreDrawViewModel(vm, wep, ply)
	local CT, FT = CurTime(), FrameTime()
	local EP, EA = EyePos(),  EyeAngles()

	vm:InvalidateBoneCache()
	local vm_angles = vm:GetAngles()

	vm:SetAngles(_ang)

		self.AttData  = vm:GetAttachment(1)
		self.VMOrigin = vm:GetPos()

	vm:SetAngles(vm_angles)

	local noclip = self.Owner:GetMoveType() == MOVETYPE_NOCLIP
	local onGround = self.Owner:IsOnGround() or noclip

	local state = self.dt.WepState

	if (state == self.STATE_PULLED or state == self.STATE_RELEASE) and self.Owner:KeyDown(IN_ATTACK2) then
		self.AimMult  = math.Approach(self.AimMult, 1, FT * 8)
		self.AimMult2 = Lerp(FT * 15, self.AimMult2, self.AimMult)

		if not self.LastAimState then
			self:EmitSound("Weapon_HuntingBow.ZoomIn")
			self.LastAimState = true
		end
	else
		self.AimMult  = math.Approach(self.AimMult, 0, FT * 8)
		self.AimMult2 = Lerp(FT * 15, self.AimMult2, self.AimMult)

		if self.LastAimState then
			self:EmitSound("Weapon_HuntingBow.ZoomOut")
			self.LastAimState = false
		end
	end

	local speed_max = self.Owner:GetWalkSpeed()

	local vel   = self.Owner:GetVelocity()
	local speed = math.min(vel:Length2D() / speed_max, 1.5)

	self.SpeedMult = Lerp(FT * 10, self.SpeedMult, (noclip or not onGround) and 0 or speed)
	self.BobCycle = self.BobCycle + FT * self.SpeedMult * 15

	self.SprintMult = math.Clamp(self.SpeedMult - 1, 0, 1) / 0.5

	local bob_mult = 1 - self.AimMult2 * 0.6

	local pose    = vm:GetPoseParameter("idle_pose")
	local pose_to = math.Round(self.AimMult2, 3)

	if pose ~= pose_to then
		vm:SetPoseParameter("idle_pose", pose_to)
		vm:InvalidateBoneCache()
	end


	self.BobPos.x = Lerp(FT * 15, self.BobPos.x, math.sin(self.BobCycle * 0.5) * self.SpeedMult * bob_mult)
	self.BobPos.y = Lerp(FT * 15, self.BobPos.y, math.cos(self.BobCycle)       * self.SpeedMult * bob_mult)

	self.BobPos2.x = Lerp(FT * 15, self.BobPos2.x, math.sin(self.BobCycle * 0.5 + 45) * self.SpeedMult * bob_mult)
	self.BobPos2.y = Lerp(FT * 15, self.BobPos2.y, math.cos(self.BobCycle       + 45) * self.SpeedMult * bob_mult)

	self.LastAngles = LerpAngle(FT * 15, self.LastAngles, EA)

	local side_speed = math.Clamp(vel:DotProduct(EA:Right()), -speed_max, speed_max) / speed_max
	self.SideSpeed   = Lerp(FT * 5, self.SideSpeed, noclip and 0 or (side_speed * bob_mult * 4))
end

local function util_NormalizeAngles(a)
	a.p = math.NormalizeAngle(a.p)
	a.y = math.NormalizeAngle(a.y)
	a.r = math.NormalizeAngle(a.r)
	return a
end

local cam = {
	origin = Vector(0, 0, 0),
	angles = Angle(0, 0, 0)
}

function SWEP:GetViewModelPosition(origin, angles)
	if self.SprintMult == nil then return end
	local EA = EyeAngles()

	local sway_p = math.NormalizeAngle(self.LastAngles.p - EA.p) * 0.2
	local sway_y = math.NormalizeAngle(self.LastAngles.y - EA.y) * 0.2

	vm_origin.x = self.BobPos.x * 0.33 + self.ShakeX * 0.1 + sway_y * 0.1 + self.SideSpeed * 0.33
	vm_origin.y = self.BobPos2.y * 0.2 + self.BobPos2.x * self.SprintMult * 0.66
	vm_origin.z = self.BobPos.y * 0.43 - self.ShakeY * 0.1 + sway_p * 0.1

	vm_angles.p = -self.BobPos2.y + self.ShakeY - sway_p
	vm_angles.y = -self.BobPos2.x * 0.25 + self.ShakeX + sway_y
	vm_angles.r =  self.BobPos2.x * 0.5 + self.SideSpeed

	local Right   = angles:Right()
	local Up      = angles:Up()
	local Forward = angles:Forward()

	angles:RotateAroundAxis(Right,   vm_angles.p)
	angles:RotateAroundAxis(Up,      vm_angles.y)
	angles:RotateAroundAxis(Forward, vm_angles.r)

	origin = origin + (vm_origin.x + cam.origin.x) * Right
	origin = origin + (vm_origin.y + cam.origin.y) * Forward
	origin = origin + (vm_origin.z + cam.origin.z) * Up

	return origin, angles
end

function SWEP:CalcView(ply, origin, angles, fov)
	if ply:GetViewEntity() ~= ply then
		return
	end

	local vm = self.Owner:GetViewModel()

	if IsValid(vm) then
		local vm_origin = vm:GetPos()
		local att = self.AttData

		if att then
			cam.origin.x = att.Pos.x - self.VMOrigin.x
			cam.origin.y = att.Pos.y - self.VMOrigin.y
			cam.origin.z = att.Pos.z - self.VMOrigin.z

			cam.angles.p = math.NormalizeAngle(att.Ang.r)
			cam.angles.y = math.NormalizeAngle(att.Ang.y - 90)
			cam.angles.r = math.NormalizeAngle(att.Ang.p)
		end
	end

	local angles_p = cam.angles.p + self.BobPos.y  * 0.25 + self.ShakeX * 0.25
	local angles_y = cam.angles.y - self.BobPos.x  * 0.25 + self.ShakeY * 0.25
	local angles_r = cam.angles.r + self.BobPos2.x * 0.25

	angles:RotateAroundAxis(angles:Right(), angles_p)
	angles:RotateAroundAxis(angles:Up(), angles_y)
	angles:RotateAroundAxis(angles:Forward(), angles_r)

	origin = origin + (cam.origin.x) * angles:Right()
	origin = origin + (cam.origin.y) * angles:Forward()
	origin = origin + (cam.origin.z) * angles:Up()

	return origin, angles, fov
end

function SWEP:TranslateFOV(current_fov)
	return current_fov - (self.AimMult2 * self.AimFOV)
end

function SWEP:DrawWorldModelTranslucent()
	self:DrawModel()
end

function SWEP:AdjustMouseSensitivity()
	local current_fov    = self.Owner:GetFOV()
	local translated_fov = self:TranslateFOV(current_fov)

	return translated_fov / current_fov
end

function SWEP:GetTracerOrigin()
	return
end
