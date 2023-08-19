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
    ent:SetAngles(spawnAng)
    ent:Spawn()
    ent:Activate()

    return ent
end

function ENT:Initialize()
    self:SetModel("models/ams2/crusher_machine.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetPos(self:GetPos())
    self:PhysWake()
    self:StartLoopingSound("OBJ_Workshop_GeneratorLarge_01_LOOP.wav")

    nut.item.newInv(0, "extractor", function(inv)
        inv.vars.isStorage = true
        inv.noSave = true
        self.inventory = inv
    end)
end

function ENT:Use(activator, caller)
    if caller == self:GetOwnership() and !self.Claimer then
        self:OpenMenu(caller)
    elseif caller == self:GetOwnership() and self.Claimer then
        caller:notify("You can't access an extractor while it's being claimed!")
    elseif IsValid(self:GetOwnership()) and !self.Claimer then
        self:AskClaim(caller)
    elseif IsValid(self:GetOwnership()) and self.Claimer then
        caller:notify("This extractor is already being claimed by someone!")
    elseif !IsValid(self:GetOwnership()) then
        self:SetOwnership(caller)
    end
end

function ENT:SetOwnership(ply)
    self:SetNWEntity("Owner", ply)
end

function ENT:SetProduction(name, uniqueID)
    self:SetNWString("ProductionItem", name)
    self:SetNWString("ProductionItemID", uniqueID)

    timer.Create("ExtractorProduction" .. self:EntIndex(), extractorsConfig.Items[uniqueID].time, 0, function()
        if !IsValid(self) then return end
        self:ProduceItem()
    end)
end

function ENT:OpenMenu(ply)
    net.Start("ExtractorOpenMenu")
        net.WriteEntity(self)
    net.Send(ply)
end

function ENT:OpenInventory(ply)
    local inventory = self.inventory

    inventory:sync(ply)
    net.Start("ExtractorOpenInv")
        net.WriteInt(inventory:getID(), 32)
    net.Send(ply)
end

function ENT:AskClaim(ply)
    net.Start("ExtractorAsk")
        net.WriteEntity(self)
    net.Send(ply)
end

function ENT:StartClaim(ply)
    if ply.IsClaiming then
        ply:notify("You are already claiming an extractor!")
        return
    end

    local curOwner = self:GetOwnership()

    local timerID = "ExtractorClaim" .. self:EntIndex()

    if self.Claimer or timer.Exists(timerID) then
        if !self.Claimer or self.Claimer != ply then
            ply:notify("This extractor is already being claimed by someone else!")
        end
        return
    end

    if IsValid(curOwner) then
        curOwner:notify("Your extractor is being claimed!")
    end

    net.Start("StartExtractorClaim")
        net.WriteEntity(self:GetOwnership())
    net.Send(ply)

    net.Start("ExtractorClaimStarted")
        net.WriteEntity(ply)
    net.Send(self:GetOwnership())

    timer.Create(timerID, extractorsConfig.ClaimTime, 1, function()
        if !IsValid(ply) or !IsValid(self) then return end
        self:FinishClaim(ply)
    end)

    local hookID = "ExtractorClaimDistance" .. self:EntIndex()
    hook.Add("Think", hookID, function()
        if !IsValid(ply) or !IsValid(self) then
            hook.Remove("Think", hookID)
            return
        end

        local distance = ply:GetPos():DistToSqr(self:GetPos())
        if distance > extractorsConfig.ClaimRadius*extractorsConfig.ClaimRadius then
            self:HaltClaim()
        end

        local owner = self:GetOwnership()
        if owner:getChar() != nil then 
            for k,v in pairs(ents.FindInSphere(self:GetPos(), extractorsConfig.ClaimRadius)) do
                if v == self:GetOwnership() and v:Alive() then
                    self:ChangeContested(true, ply)
                    return
                end
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

    net.Start("ExtractorContest")
        net.WriteBool(contested)
    net.Send(ply)

    if !timer.Exists("ExtractorClaim" .. self:EntIndex()) then return end
    if contested then
        timer.Pause("ExtractorClaim" .. self:EntIndex())
    else
        timer.UnPause("ExtractorClaim" .. self:EntIndex())
    end
end

function ENT:HaltClaim()
    if timer.Exists("ExtractorClaim" .. self:EntIndex()) then
        timer.Remove("ExtractorClaim" .. self:EntIndex())
    end
    hook.Remove("Think", "ExtractorClaimDistance" .. self:EntIndex())

    if IsValid(self:GetOwnership()) then
        net.Start("ExtractorClaimHalted")
            net.WriteEntity(self.Claimer)
        net.Send(self:GetOwnership())
    end

    if IsValid(self.Claimer) then
        net.Start("HaltExtractorClaim")
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

function ENT:ProduceItem()
    nut.item.instance(0, self:GetProductionID(), nil, nil, nil, function(item)
        self.inventory:add(item.id)
    end)
end

function ENT:OnRemove()
    self:HaltClaim()
    timer.Remove("ExtractorProduction" .. self:EntIndex())
end