AddCSLuaFile()
AddCSLuaFile("lockpickconfig.lua")

lockpickConfig = {}
include("lockpickconfig.lua")


SWEP.Author = "jonjo"
SWEP.Purpose = "Getting into places you shouldn't be."
SWEP.Instructions = "Left click to begin lockpicking."
SWEP.Category = "Claymore Gaming"

SWEP.Slot = 5
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/c_crowbar.mdl")
SWEP.WorldModel = Model("models/weapons/w_crowbar.mdl")
SWEP.UseHands = true

SWEP.PrintName = "Lockpick"

SWEP.Primary.ClipSize		 = -1
SWEP.Primary.DefaultClip	 = -1
SWEP.Primary.Automatic		 = false
SWEP.Primary.Ammo		     = "none"

SWEP.Secondary.ClipSize	     = -1
SWEP.Secondary.DefaultClip	 = -1
SWEP.Secondary.Automatic	 = false
SWEP.Secondary.Ammo		     = "none"

SWEP.Range = 80

if SERVER then
    util.AddNetworkString("LockpickSuccess")
    util.AddNetworkString("LockpickHalt")
end

if CLIENT then
    function surface.DrawTexturedRectRotatedPoint( x, y, w, h, rot, x0, y0 )
		local c = math.cos( math.rad( rot ) )
		local s = math.sin( math.rad( rot ) )
		local newx = y0 * s - x0 * c
		local newy = y0 * c + x0 * s

		surface.DrawTexturedRectRotated( x + newx, y + newy, w, h, rot )
	end
    surface.CreateFont("LockpickFont", {font = "Arial", size = 24})
end

local matLock = Material( "vgui/skyrim/lock1.png" )
local matLockinside = Material( "vgui/skyrim/lockinside.png" )
local matLockpick = Material( "vgui/skyrim/lockpick.png" )

local doors = {
	["func_door"] = true,
	["func_door_rotating"] = true,
	["prop_door_rotating"] = true,
	["func_movelinear"] = true,
}

local deployableDoor = { -- entity versions created by Vex
	["nut_anidoor_utillarge"] = true,
	["nut_anidoor_utilsmall"] = true,
}

local function IsDoor(ent)
    if !IsValid(ent) then return false end
    local class = ent:GetClass()

    return doors[class] or false
end

local function IsDeployableDoor(ent)
    if !IsValid(ent) then return false end
    local class = ent:GetClass()

    return deployableDoor[class] or false
end

function SWEP:Think() end

function SWEP:Reload() end

function SWEP:Initialize()
    self.FailedAttempts = 0
end

function SWEP:PrimaryAttack()
    if self.Owner.isLockpicking then return end
    local tr = self:GetOwner():GetEyeTrace()
    local ent = tr.Entity

    if tr.HitWorld or !IsValid(ent) or ent:GetPos():Distance(self.Owner:GetPos()) > self.Range then return end
    if !IsDoor(ent) and !IsDeployableDoor(ent) and !isfunction(ent.OnLockpicked) then return end

    local skillLevel = self.Owner:hasSkerk("lockpick")
    if !skillLevel then
        if CLIENT and IsFirstTimePredicted() then
            nut.util.notify("You require the lockpicking skill!")
        end
        return
    end

    local LockpickLevel = (IsDoor(ent) or IsDeployableDoor(ent)) and 2 or ent.LockpickLevel
    if LockpickLevel and LockpickLevel > skillLevel then
        if CLIENT and IsFirstTimePredicted() then
            nut.util.notify("You need level " .. LockpickLevel .. " lockpicking level to lockpick this!")
        end
        return
    end

    self:StartPicking(ent)
end
SWEP.SecondaryAttack = SWEP.PrimaryAttack

function SWEP:PlayPickSounds()
    if SERVER then return end
    self.nextPickSound = self.nextPickSound or 0
    if CurTime() > self.nextPickSound then
		surface.PlaySound("lockpicking/pickmovement_"..math.random(6)..".wav")
		self.nextPickSound = CurTime() + math.Rand(0.5, 1.5)
	end
end

function SWEP:PlayTurnSound()
    if SERVER then return end
    self.nextTurnSound = self.nextTurnSound or 0
    if CurTime() > self.nextTurnSound then
		surface.PlaySound("lockpicking/cylinderturn_"..math.random(3)..".wav")
		self.nextTurnSound = CurTime() + math.Rand(1, 2)
		surface.PlaySound("lockpicking/cylindersqueak_"..math.random(3)..".wav")
	end
end

function SWEP:StartPicking(ent, first)
    if !self.Owner:hasSkerk("lockpick") then return end

    if self.IsOnCooldown or self.Owner.LockpickCD then
        if CLIENT and timer.Exists("LockpickCooldown" .. self.Owner:EntIndex()) and IsFirstTimePredicted() then
            nut.util.notify("You must wait " .. math.Round(timer.TimeLeft("LockpickCooldown" .. self.Owner:EntIndex())) .. " more seconds before attempting to lockpick again.")
        end
        return
    end

    ent:EmitSound("lockpicking/unlock_"..math.random(3)..".wav")
    self.Owner.isLockpicking = true
    self.LockpickEnt = ent

    if CLIENT then
        surface.PlaySound("lockpicking/enter.wav")
        local baseH = ScrH()/2.5
    	local baseW = baseH
        local insideH = baseH * 0.29
    	local insideW = insideH

        local lockAng = 0
        local newLockAng = 0
        local pickAng = 0
        local oldpickAng = 0
        local timeHeld = 0
        local canMove = true
        local correctAng = math.random(-10, -170)

        local frame = vgui.Create("DFrame")
        frame:SetTitle("")
        frame:ShowCloseButton(false)
        frame:MakePopup()
        frame:SetSize(ScrW() / 2, ScrH())
        frame:Center()
        frame.Paint = function(s, w, h)
            oldpickAng = pickAng
            newLockAng = math.Clamp(newLockAng, -90, 90)
            lockAng = Lerp(10 * RealFrameTime(), lockAng, newLockAng)

            local x, y = s:GetWide()/2 - baseW/2, s:GetWide() - baseH
            surface.SetDrawColor( color_black )
    		surface.DrawRect( x + baseW/4, y + baseH/4, baseW/2, baseH/2 )

            surface.SetDrawColor(200, 200, 200, 255)
    		surface.SetMaterial(matLock)
    		surface.DrawTexturedRect(x, y, baseW, baseH)

            x, y = x + baseW/2, y + baseH/2 + (insideH / 6)
            surface.SetDrawColor( 200, 200, 200, 255 )
    		surface.SetMaterial(matLockinside)
    		surface.DrawTexturedRectRotated(x, y, insideW, insideH, lockAng)

            local mX, mY = s:ScreenToLocal(gui.MouseX(), gui.MouseY())
			pickAng = math.deg(math.atan2(mY - y, mX - x))
			pickAng = math.Clamp(pickAng, -180, 0)

            surface.SetDrawColor(200, 200, 200, 255)
    		surface.SetMaterial(matLockpick)
    		surface.DrawTexturedRectRotatedPoint(x, y, baseW, 30, 180 - pickAng, baseW / 2, 0)

            if oldpickAng != pickAng then
                self:PlayPickSounds()
            end

            draw.SimpleText("Press Q to cancel", "LockpickFont", w/2, y + baseW/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
        end
        frame.Think = function(s)
            if input.IsKeyDown(KEY_Q) then
                s:Close()
                self:HaltPicking(false)
                return
            end

            if input.IsKeyDown(KEY_A) and canMove then
                canMove = false
                self:PlayTurnSound()
                newLockAng = (1 - (math.abs(pickAng - correctAng)) / 180) * -90
                if math.abs(pickAng - correctAng) < lockpickConfig.sweetSpotSize then
                    s:Close()
                    self:FinishPicking(ent)
                    return
                end
            elseif input.IsKeyDown(KEY_A) then
                timeHeld = timeHeld + RealFrameTime()
                if timeHeld >= lockpickConfig.failTime then
                    s:Close()
                    self:HaltPicking(true)
                    return
                end
            end

            if !input.IsKeyDown(KEY_A) and !canMove then
                newLockAng = 0
            end

            if !canMove and lockAng > -2 then
                canMove = true
            end
        end
    end
end

function SWEP:Think()
    if self.Owner.isLockpicking and (IsValid(self.LockpickEnt) and self.Owner:GetPos():DistToSqr(self.LockpickEnt:GetPos()) > 150*150) then
        self:HaltPicking(true)
    end
end

function SWEP:FinishPicking(ent)
    if SERVER then
        local ply = self.Owner
        if !ply.isLockpicking then return end
        local skillLevel = ply:hasSkerk("lockpick")

				if IsDeployableDoor(ent) and skillLevel >= 2 and (ent:getNetVar("open") != true) then
					ent.dummy:Fire("SetAnimation", "open", 0)
					ent:setNetVar("open", true)
					ent:EmitSound("fallout/doors/drs_metalutilitylarge_open.wav", 65)
					timer.Simple(2, function() ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS) end)
				end
        if IsDoor(ent) and skillLevel >= 1 then
            ent:Fire("Unlock")
            ent:Fire("Open")
        elseif isfunction(ent.OnLockpicked) and (ent.LockpickLevel and skillLevel >= ent.LockpickLevel) then
            ent:OnLockpicked(self.Owner)
        end
        self:HaltPicking(false)
    end
    ent:EmitSound("lockpicking/unlock_"..math.random(3)..".wav")
    if CLIENT then
        net.Start("LockpickSuccess")
            net.WriteEntity(ent)
            net.WriteEntity(self)
        net.SendToServer()
        self:HaltPicking(false)
    end
end

if SERVER then
    net.Receive("LockpickSuccess", function(len, ply)
        local ent = net.ReadEntity()
        local wep = net.ReadEntity()

        if wep.Owner:GetPos():DistToSqr(wep.LockpickEnt:GetPos()) > 150*150 or !wep.Owner.isLockpicking then return end
        wep:FinishPicking(ent)
    end)

    net.Receive("LockpickHalt", function(len, ply)
        local failed = net.ReadBool()
        local wep = net.ReadEntity()

		if !IsValid(wep) or !isfunction(wep.HaltPicking) then
			return
		end

        if IsValid(wep) then
			wep:HaltPicking(failed)
		end
    end)
end

function SWEP:HaltPicking(failed)
    self.Owner.isLockpicking = false
    self.LockpickEnt = nil
    if CLIENT then
        net.Start("LockpickHalt")
            net.WriteBool(failed)
            net.WriteEntity(self)
        net.SendToServer()
    end
    if failed then
		self.FailedAttempts = self.FailedAttempts + 1
		local lockpicks = (lockpickConfig.amtOfTries - self.FailedAttempts)
        if CLIENT then
            surface.PlaySound("lockpicking/pickbreak_"..math.random(3)..".wav")
        end

		if SERVER && (lockpicks > 0) then
			self.Owner:falloutNotify("[ ! ]  You have " .. lockpicks .. " lockpicks left", "ui/notify.mp3")
		end

        if self.FailedAttempts >= lockpickConfig.amtOfTries then
            self:StartCooldown()
        end
    end
end

function SWEP:StartCooldown()
	if SERVER then
		self.Owner:falloutNotify("[ ! ]  You have ran out of lockpicks")
	end

    self.IsOnCooldown = true
    self.Owner.LockpickCD = true
    local ply = self.Owner
    local wep = self
    timer.Create("LockpickCooldown" .. self.Owner:EntIndex(), lockpickConfig.cooldown, 1, function()
        if IsValid(ply) then
            ply.LockpickCD = nil

            if IsValid(wep) then
                self.IsOnCooldown = false
                self.FailedAttempts = 0
            end
        end
    end)

end

function SWEP:OnRemove()
    self:HaltPicking()
end
