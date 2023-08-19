include("shared.lua")
AddCSLuaFile("cl_init.lua")

function ENT:SpawnFunction(ply, tr, className)
    if !tr.Hit then return end

    local spawnPos = tr.HitPos + tr.HitNormal * 37
    local spawnAng = ply:EyeAngles()
    spawnAng.p = 0
    spawnAng.y = spawnAng.y + 180

    local ent = ents.Create(className)
    ent:SetPos(spawnPos)
    ent:SetAngles(spawnAng + Angle(0, 90, 0))
    ent:Spawn()
    ent:Activate()

    return ent
end

function ENT:Initialize()
    self:SetModel("models/props/keitho/fusiongenerator.mdl")
    self:SetBodygroup(self:FindBodygroupByName("core"), 1)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetPos(self:GetPos())
    self:PhysWake()
    //self:StartLoopingSound("OBJ_Workshop_GeneratorLarge_01_LOOP.wav")

    nut.item.newInv(0, "reactor", function(inv)
        inv.vars.isStorage = true
        inv.noSave = true
        inv.reactor = self
        self.inventory = inv
    end)
end

function ENT:Use(activator, caller)
    if caller == self:GetOwnership() and !self.Claimer then
        self:OpenMenu(caller)
    elseif nut.faction.indices[caller:getChar():getFaction()].uniqueID == self:GetFaction() and self:GetFactionAccess() then
        self:OpenMenu(caller)
    elseif caller == self:GetOwnership() and self.Claimer then
        caller:notify("You can't access a reactor while it's being claimed!")
    elseif IsValid(self:GetOwnership()) and !self.Claimer then
        self:AskClaim(caller)
    elseif IsValid(self:GetOwnership()) and self.Claimer then
        caller:notify("This reactor is already being claimed by someone!")
    elseif !IsValid(self:GetOwnership()) then
        self:SetOwnership(caller)
    end
end

function ENT:SetOwnership(ply)
    self:SetNWEntity("Owner", ply)

    local faction = nut.faction.indices[ply:getChar():getFaction()].uniqueID
    if faction == "wastelander" then faction = "" end

    self:SetFaction(faction)
    self:SetFactionAccess(false)
end

function ENT:OpenMenu(ply)
    net.Start("ReactorOpenMenu")
        net.WriteEntity(self)
        net.WriteInt(timer.TimeLeft("ReactorProduction" .. self:EntIndex()) or -1, 32)
    net.Send(ply)
end

function ENT:OpenInventory(ply)
    local inventory = self.inventory

    inventory:sync(ply)
    net.Start("ReactorOpenInv")
        net.WriteInt(inventory:getID(), 32)
    net.Send(ply)
end

function ENT:AskClaim(ply)
    net.Start("ReactorAsk")
        net.WriteEntity(self)
    net.Send(ply)
end

function ENT:StartClaim(ply)
    if ply.IsClaiming then
        ply:notify("You are already claiming a reactor!")
        return
    end

    local curOwner = self:GetOwnership()

    local timerID = "ReactorClaim" .. self:EntIndex()

    if self.Claimer or timer.Exists(timerID) then
        if !self.Claimer or self.Claimer != ply then
            ply:notify("This reactor is already being claimed by someone else!")
        end
        return
    end

    if IsValid(curOwner) then
        curOwner:notify("Your reactor is being claimed!")
    end

    net.Start("StartReactorClaim")
        net.WriteEntity(self:GetOwnership())
    net.Send(ply)

    net.Start("ReactorClaimStarted")
        net.WriteEntity(ply)
    net.Send(self:GetOwnership())

    timer.Create(timerID, fusionConfig.ClaimTime, 1, function()
        if !IsValid(ply) or !IsValid(self) then return end
        self:FinishClaim(ply)
    end)

    local hookID = "ReactorClaimDistance" .. self:EntIndex()
    hook.Add("Think", hookID, function()
        if !IsValid(ply) or !IsValid(self) then
            hook.Remove("Think", hookID)
            return
        end

        local distance = ply:GetPos():DistToSqr(self:GetPos())
        if distance > fusionConfig.ClaimRadius*fusionConfig.ClaimRadius then
            self:HaltClaim()
        end

        for k,v in pairs(ents.FindInSphere(self:GetPos(), fusionConfig.ClaimRadius)) do
            if v == self:GetOwnership() and v:Alive() then
                self:ChangeContested(true, ply)
                return
            end
        end

        if self.Contested then
            self:ChangeContested(false, ply)
        end
    end)

    ply.IsClaiming = true
    self.Claimer = ply
end

function ENT:ChangeContested(contested, ply)
    self.Contested = contested

    net.Start("ReactorContest")
        net.WriteBool(contested)
    net.Send(ply)

    if !timer.Exists("ReactorClaim" .. self:EntIndex()) then return end
    if contested then
        timer.Pause("ReactorClaim" .. self:EntIndex())
    else
        timer.UnPause("ReactorClaim" .. self:EntIndex())
    end
end

function ENT:HaltClaim()
    if timer.Exists("ReactorClaim" .. self:EntIndex()) then
        timer.Remove("ReactorClaim" .. self:EntIndex())
    end
    hook.Remove("Think", "ReactorClaimDistance" .. self:EntIndex())

    if IsValid(self:GetOwnership()) then
        net.Start("ReactorClaimHalted")
            net.WriteEntity(self.Claimer)
        net.Send(self:GetOwnership())
    end

    if IsValid(self.Claimer) then
        net.Start("HaltReactorClaim")
            net.WriteEntity(self:GetOwnership())
        net.Send(self.Claimer)

        self.Claimer.IsClaiming = false
    end

    self.Claimer = nil
end

function ENT:FinishClaim(ply)
    self:HaltClaim()
    if IsValid(ply) and ply:Alive() then
        self:SetOwnership(ply)
    end
end

function ENT:OnFueled()
    local timerID = "ReactorProduction" .. self:EntIndex()
    timer.Create(timerID, fusionConfig.ProductionTime, 0, function()
        if !IsValid(self) then
            timer.Remove(timerID)
            return
        end
        self:ProduceItem()
    end)
    self:EmitSound("Fusion_Start.wav")
    timer.Simple(2, function()
        self.SoundLoopID = self:StartLoopingSound("Fusion_Loop.wav")
    end)
end

function ENT:OnFuelEjected()
    timer.Remove("ReactorProduction" .. self:EntIndex())
    if self.SoundLoopID then
        self:StopLoopingSound(self.SoundLoopID)
        self.SoundLoopID = nil
    else
        timer.Simple(2, function()
            if self.SoundLoopID then
                self:StopLoopingSound(self.SoundLoopID)
                self.SoundLoopID = nil
            end
        end)
    end
    self:EmitSound("Fusion_Stop.wav")
end

function ENT:ProduceItem()
    nut.item.instance(0, "fusion_core", nil, nil, nil, function(item)
        self.inventory:add(item.id)
    end)

    self:SetFuel(math.max(self:GetFuel() - 1, 0))

    if self:GetFuel() < 1 then
        self:OnFuelEjected()
    end

    self:SetBodygroup(self:FindBodygroupByName("core"), 0)
end

function ENT:OnRemove()
    self:HaltClaim()
    timer.Remove("ReactorProduction" .. self:EntIndex())
end