SWEP.SprintBobMult = 1.5 -- More is more bobbing, proportionally.  This is multiplication, not addition.  You want to make this > 1 probably for sprinting.
SWEP.IronBobMult = 0.0 -- More is more bobbing, proportionally.  This is multiplication, not addition.  You want to make this < 1 for sighting, 0 to outright disable.
SWEP.IronBobMultWalk = 0.2 -- More is more bobbing, proportionally.  This is multiplication, not addition.  You want to make this < 1 for sighting, 0 to outright disable.

--[[
Function Name:  CalcView
Syntax: Don't ever call this manually.
Returns:  Nothing.
Notes:  Used to calculate view angles.
Purpose:  Feature
]]--'

local ta = Angle()
local v = Vector()

local m_AD = math.AngleDifference
local m_NA = math.NormalizeAngle

local l_LA = function(t,a1,a2)
	ta.p = m_NA( a1.p + m_AD(a2.p,a1.p)  * t )
	ta.y = m_NA( a1.y + m_AD(a2.y,a1.y)  * t )
	ta.r = m_NA( a1.r + m_AD(a2.r,a1.r)  * t )
	return ta
end

local l_LV = function(t,v1,v2)
	v = v1  + ( v2 - v1 ) * t
	return v * 1
end

SWEP.ViewHolProg = 0
SWEP.AttachmentViewOffset = Angle(0, 0, 0)
SWEP.ProceduralViewOffset = Angle(0, 0, 0)
local procedural_fadeout = 0.6
local procedural_vellimit = 5
local l_Lerp = Lerp
local l_mathApproach = math.Approach
local l_mathClamp = math.Clamp
local viewbob_intensity_cvar, viewbob_drawing_cvar, viewbob_reloading_cvar
viewbob_intensity_cvar = GetConVar("cl_tfa_viewbob_intensity")
viewbob_drawing_cvar = GetConVar("cl_tfa_viewbob_drawing")
viewbob_reloading_cvar = GetConVar("cl_tfa_viewbob_reloading")
local oldangtmp, oldpostmp
local mzang_fixed
local mzang_fixed_last
local mzang_velocity = Angle()
local progress = 0
local targint,targbool

function SWEP:CalcView(ply, pos, ang, fov)
	if not ang then return end
	if ply ~= LocalPlayer() then return end
	local vm = ply:GetViewModel()
	if not IsValid(vm) then return end
	if not CLIENT then return end
	local ftv = math.max(FrameTime(), 0.001)
	local viewbobintensity = 0.2 * viewbob_intensity_cvar:GetFloat()

	holprog = TFA.Enum.HolsterStatus[self:GetStatus()] and 1 or 0
	self.ViewHolProg = math.Approach(self.ViewHolProg, holprog, ftv / 5)

	oldpostmp = pos * 1
	oldangtmp = ang * 1
	if self.Idle_Mode == TFA.Enum.IDLE_LUA or self.Idle_Mode == TFA.Enum.IDLE_BOTH then
		pos, ang = self:CalculateBob(pos, ang, -viewbobintensity, true)
		if not ang or not pos then return oldangtmp, oldpostmp end
	end

	if self.CameraAngCache then
		self.CameraAttachmentScale = self.CameraAttachmentScale or 1
		ang:RotateAroundAxis(ang:Right(), (self.CameraAngCache.p + self.CameraOffset.p) * viewbobintensity * 5 * self.CameraAttachmentScale)
		ang:RotateAroundAxis(ang:Up(), (self.CameraAngCache.y + self.CameraOffset.y) * viewbobintensity * 5 * self.CameraAttachmentScale)
		ang:RotateAroundAxis(ang:Forward(), (self.CameraAngCache.r + self.CameraOffset.r) * viewbobintensity * 3 * self.CameraAttachmentScale)
		-- - self.MZReferenceAngle--WorldToLocal( angpos.Pos, angpos.Ang, angpos.Pos, oldangtmp + self.MZReferenceAngle )
		--* progress )
		--self.ProceduralViewOffset.p = l_mathApproach(self.ProceduralViewOffset.p, 0 , l_mathClamp( procedural_pitchrestorefac - math.min( math.abs( self.ProceduralViewOffset.p ), procedural_pitchrestorefac ) ,1,procedural_pitchrestorefac)*ftv/5 )
		--self.ProceduralViewOffset.y = l_mathApproach(self.ProceduralViewOffset.y, 0 , l_mathClamp( procedural_pitchrestorefac - math.min( math.abs( self.ProceduralViewOffset.y ), procedural_pitchrestorefac ) ,1,procedural_pitchrestorefac)*ftv/5 )
		--self.ProceduralViewOffset.r = l_mathApproach(self.ProceduralViewOffset.r, 0 , l_mathClamp( procedural_pitchrestorefac - math.min( math.abs( self.ProceduralViewOffset.r ), procedural_pitchrestorefac ) ,1,procedural_pitchrestorefac)*ftv/5 )
	else
		local vb_d, vb_r, idraw, ireload, ihols, stat
		stat = self:GetStatus()
		idraw = stat == TFA.Enum.STATUS_DRAWING
		ihols = TFA.Enum.HolsterStatus[stat]
		ireload = TFA.Enum.ReloadStatus[stat]
		vb_d = viewbob_drawing_cvar:GetBool()
		vb_r = viewbob_reloading_cvar:GetBool()

		targbool = ( vb_d and idraw ) or ( vb_r and ireload ) or ( self.GetBashing and self:GetBashing() ) or ( stat == TFA.Enum.STATUS_SHOOTING and self.ViewBob_Shoot )
		targbool = targbool and not ( ihols and self.ProceduralHolsterEnabled )
		targint = targbool and 1 or 0
		if stat == TFA.Enum.STATUS_RELOADING_SHOTGUN_END or stat == TFA.Enum.STATUS_RELOADING or stat == TFA.Enum.STATUS_SHOOTING then
			targint = math.min(targint, 1-vm:GetCycle() )
		end
		progress = l_Lerp(ftv * 15, progress, targint)

		local att = self.MuzzleAttachmentRaw or vm:LookupAttachment(self.MuzzleAttachment)

		if not att then
			att = 1
		end

		local angpos = vm:GetAttachment(att)

		if angpos then
			mzang_fixed = vm:WorldToLocalAngles(angpos.Ang)
			mzang_fixed:Normalize()
		end

		self.ProceduralViewOffset:Normalize()

		if mzang_fixed_last then
			local delta = mzang_fixed - mzang_fixed_last
			delta:Normalize()
			mzang_velocity = mzang_velocity + delta * (2 * (1 - self.ViewHolProg))
			mzang_velocity.p = l_mathApproach(mzang_velocity.p, -self.ProceduralViewOffset.p * 2, ftv * 20)
			mzang_velocity.p = l_mathClamp(mzang_velocity.p, -procedural_vellimit, procedural_vellimit)
			self.ProceduralViewOffset.p = self.ProceduralViewOffset.p + mzang_velocity.p * ftv
			self.ProceduralViewOffset.p = l_mathClamp(self.ProceduralViewOffset.p, -90, 90)
			mzang_velocity.y = l_mathApproach(mzang_velocity.y, -self.ProceduralViewOffset.y * 2, ftv * 20)
			mzang_velocity.y = l_mathClamp(mzang_velocity.y, -procedural_vellimit, procedural_vellimit)
			self.ProceduralViewOffset.y = self.ProceduralViewOffset.y + mzang_velocity.y * ftv
			self.ProceduralViewOffset.y = l_mathClamp(self.ProceduralViewOffset.y, -90, 90)
			mzang_velocity.r = l_mathApproach(mzang_velocity.r, -self.ProceduralViewOffset.r * 2, ftv * 20)
			mzang_velocity.r = l_mathClamp(mzang_velocity.r, -procedural_vellimit, procedural_vellimit)
			self.ProceduralViewOffset.r = self.ProceduralViewOffset.r + mzang_velocity.r * ftv
			self.ProceduralViewOffset.r = l_mathClamp(self.ProceduralViewOffset.r, -90, 90)
		end

		self.ProceduralViewOffset.p = l_mathApproach(self.ProceduralViewOffset.p, 0, (1 - progress) * ftv * -self.ProceduralViewOffset.p)
		self.ProceduralViewOffset.y = l_mathApproach(self.ProceduralViewOffset.y, 0, (1 - progress) * ftv * -self.ProceduralViewOffset.y)
		self.ProceduralViewOffset.r = l_mathApproach(self.ProceduralViewOffset.r, 0, (1 - progress) * ftv * -self.ProceduralViewOffset.r)
		mzang_fixed_last = mzang_fixed
		local ints = viewbob_intensity_cvar:GetFloat()
		ang:RotateAroundAxis(ang:Right(), l_Lerp(progress, 0, -self.ProceduralViewOffset.p) * ints)
		ang:RotateAroundAxis(ang:Up(), l_Lerp(progress, 0, self.ProceduralViewOffset.y / 2) * ints)
		ang:RotateAroundAxis(ang:Forward(), Lerp(progress, 0, self.ProceduralViewOffset.r / 3) * ints)
	end

	return pos, LerpAngle(self.ViewHolProg, ang, oldangtmp), fov
end
