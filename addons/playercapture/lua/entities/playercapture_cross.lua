AddCSLuaFile()

--Shared
ENT.Type      = "anim"
ENT.Base      = "base_gmodentity"

ENT.PrintName = "Cross"
ENT.Category  = "Claymore Gaming"
ENT.Author    = "jonjo"
ENT.crucifixKillTime = 180 -- Amount of time until the person dies automatically while on cross
ENT.Spawnable = true

if SERVER then --Server-side
    playercaptureConfig = playercaptureConfig or {}
    include("playercapture_config.lua")

    function ENT:Initialize()
        self:SetModel("models/fallout/architecture/thefort/nv_crucifix.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
    end

    function ENT:Use(activator, caller)
        if !self.CapturedPly then --Capture the calling ply
            caller:Crucify(self)
            self.CapturedPly = caller
			self:EmitSound("ambient/materials/wood_creak" .. math.random(1,6) .. ".wav")
			caller:falloutNotify("You are mounted on a crucifix . . .", "ui/badkarma.ogg")
			caller:ChatPrint("[ ! ]  You will bleed to death in 3 minutes if not saved")

			timer.Simple((self.crucifixKillTime or 180)/2, function()
				if IsValid(caller) && self.CapturedPly then
					caller:falloutNotify("You feel light headed from the blood loss . . .", "ui/badkarma.ogg")
				end
			end)

			timer.Create("crossDeathCountdown", self.crucifixKillTime or 180, 1,  function() -- Kill function
				if IsValid(caller) && self.CapturedPly then
					self.CapturedPly:UnAttatch()
					self.CapturedPly = nil
					self.user = nil
					caller:SetPos(self:GetPos() + Vector(0,0,40))
					caller:falloutNotify("You bled to death on the cross . . .")
					if SERVER then
						caller:Kill()
					end
				end
			end)
        elseif caller != self.CapturedPly then --Free the ply that is captured
            if timer.Exists("playercapture_freeTimer" .. self:EntIndex()) then return end --Already being freed
            if caller.isCaptured then return end --Don't let captured players free each other
            if caller:GetPos():Distance(self:GetPos()) > 150 then return end --Caller is too far
            self.user = caller
            net.Start("playercapture_startFree") --Start the HUD on the caller
                net.WriteInt(playercaptureConfig.timeToFree, 16)
            net.Send(caller)
            timer.Create("playercapture_freeTimer" .. self:EntIndex(), playercaptureConfig.timeToFree, 1, function()
                self.CapturedPly:UnAttatch()
                self.CapturedPly = nil
                self.user = nil
				timer.Remove("crossDeathCountdown")
            end)
        end
    end

    function ENT:Think() --Halt the freeing if the player is farther than 150 units
        if !self.user then return end
        if !IsValid(self.user) then --User probably DC/ed while freeing, halt the free
            self.user = nil
            if timer.Exists("playercapture_freeTimer" .. self:EntIndex()) then
                timer.Remove("playercapture_freeTimer" .. self:EntIndex())
            end
            return
        end

        if self.user:GetPos():Distance(self:GetPos()) > 150 or self.user:GetEyeTrace().Entity != self then
            timer.Remove("playercapture_freeTimer" .. self:EntIndex())

            net.Start("playercapture_haltFree") --Stop the HUD on the caller
            net.Send(self.user)
            self.user = nil
        end
    end

    function ENT:OnRemove() --Remove npc/timer
        if timer.Exists("playercapture_freeTimer" .. self:EntIndex()) then timer.Remove("playercapture_freeTimer" .. self:EntIndex()) end
        if self.user then net.Start("playercapture_haltFree") net.Send(self.user) end
        if self.CapturedPly then self.CapturedPly:UnAttatch() end
    end
end


if CLIENT then --Client-side
    function ENT:Draw()
        self:DrawModel()
    end
end
