AddCSLuaFile()

--[[
local function ragdollClean(ent, ragdoll)
    if !ent:IsNPC() then return end
    timer.Simple(3, function()
        if !IsValid(ragdoll) then return end
        ragdoll:SetSaveValue("m_bFadingOut", true)
        timer.Simple(3, function()
            if !IsValid(ragdoll) then return end
            ragdoll:Remove()
        end)
    end)
end
]]

if SERVER then
    local function ragdollCleanServer(ent)
        if !ent:IsRagdoll() then return end
        if ent:getNetVar("player", nil) then return end
        timer.Simple(300, function()
            if !IsValid(ent) then return end
            ent:SetSaveValue("m_bFadingOut", true)
            timer.Simple(3, function()
                if !IsValid(ent) then return end
                ent:Remove()
            end)
        end)
    end

    hook.Add("OnEntityCreated", "serverRagdollCleaner", ragdollCleanServer)
end

//if CLIENT then
//    hook.Add("CreateClientsideRagdoll", "clientRagdollCleaner", ragdollClean)
//end