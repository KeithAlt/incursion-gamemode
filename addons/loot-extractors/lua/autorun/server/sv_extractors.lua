AddCSLuaFile("extractors_config.lua")

util.AddNetworkString("StartExtractorClaim")
util.AddNetworkString("HaltExtractorClaim")
util.AddNetworkString("ExtractorOpenMenu")
util.AddNetworkString("ExtractorChangeProduction")
util.AddNetworkString("ExtractorRequestInv")
util.AddNetworkString("ExtractorOpenInv")
util.AddNetworkString("ExtractorAsk")
util.AddNetworkString("ExtractorConfirm")
util.AddNetworkString("ExtractorContest")
util.AddNetworkString("ExtractorClaimStarted")
util.AddNetworkString("ExtractorClaimHalted")

resource.AddSingleFile("materials/extractorenemy.png")
resource.AddSingleFile("sound/OBJ_Workshop_GeneratorLarge_01_LOOP.wav")

local function AlertStaff(msg)
    for k,v in pairs(player.GetAll()) do
        if v:IsAdmin() then
            v:ChatPrint(msg)
        end
    end
end

net.Receive("ExtractorChangeProduction", function(len, ply)
    local ent = net.ReadEntity()
    local uniqueID = net.ReadString()
    local name = net.ReadString()
    local alertString = "User " .. ply:Nick() .. " with SteamID " .. ply:SteamID() .. " is attempting to exploit extractors."
    if !extractorsConfig.Items[uniqueID] then AlertStaff(alertString) return end
    if ply != ent:GetOwnership() then AlertStaff(alertString) return end
    if ply:GetPos():DistToSqr(ent:GetPos()) > 250*250 then return end

    if ent:GetClass() != "loot_extractor" then return end
    ent:SetProduction(name, uniqueID)
end)

net.Receive("ExtractorRequestInv", function(len, ply)
    local ent = net.ReadEntity()
    if ply:GetPos():Distance(ent:GetPos()) > 150 then return end
    if ply != ent:GetOwnership() then return end
    ent:OpenInventory(ply)
end)

net.Receive("ExtractorConfirm", function(len, ply)
    local ent = net.ReadEntity()
    if ply:GetPos():Distance(ent:GetPos()) > 150 then return end
    ent:StartClaim(ply)
end)