util.AddNetworkString("SyncGroups")
util.AddNetworkString("GroupsOpenMenu")
util.AddNetworkString("GroupsCreate")
util.AddNetworkString("GroupsRemove")
util.AddNetworkString("GroupsPromote")
util.AddNetworkString("GroupsRename")
util.AddNetworkString("GroupsDisband")
util.AddNetworkString("GroupsInvite")
util.AddNetworkString("GroupsAcceptInvite")
util.AddNetworkString("GroupChat")
util.AddNetworkString("GroupsLeave")
util.AddNetworkString("GroupsBindChange")

resource.AddSingleFile("materials/mic_off_white_192x192.png")
resource.AddSingleFile("materials/mic_white_192x192.png")
resource.AddSingleFile("materials/group_ping.png")
resource.AddSingleFile("materials/star_white_18x18.png")

local function PlayerLeft(ply)
    local group = ply:GetGroup()
    if group then
        if group:GetOwner() == ply then
            group:Disband()
        else
            group:RemovePlayer(ply)
        end
    end
end

hook.Add("CharacterLoaded", "ClearGroup", function(id)
    local char = nut.char.loaded[id]
    local ply  = char:getPlayer()
    PlayerLeft(ply)
end)

hook.Add("PlayerDisconnected", "ClearGroup", PlayerLeft)

hook.Add("PlayerInitialSpawn", "SyncGroups", function(ply)
    net.Start("SyncGroups")
        net.WriteTable(GROUPS)
    net.Send(ply)
end)

net.Receive("GroupsCreate", function(len, ply)
    local name = net.ReadString()
    CreateGroup(ply, name)
end)

net.Receive("GroupsRemove", function(len, ply)
    local group = ply:GetGroup()
    if !group then return end

    local target = net.ReadEntity()
    group:RemovePlayer(target)
    ply:notify("Successfully removed " .. target:Nick() .. " from the group")
end)

net.Receive("GroupsPromote", function(len, ply)
    local newOwner = net.ReadEntity()
    local group = ply:GetGroup()
    if !group or newOwner:GetGroup() != group then return end

    group:SetOwner(newOwner)
    ply:notify("Successfully changed group owner")
end)

net.Receive("GroupsRename", function(len, ply)
    local group = ply:GetGroup()
    if !group then return end

    group:SetName(net.ReadString())
end)

net.Receive("GroupsAcceptInvite", function(len, ply)
    local sender = net.ReadEntity()
    local group = sender:GetGroup()
    if !group then return end

    group:AddPlayer(ply)
end)

net.Receive("GroupsDisband", function(len, ply)
    local group = ply:GetGroup()
    if !group then return end

    group:Disband()
end)

net.Receive("GroupsLeave", function(len, ply)
    local group = ply:GetGroup()
    if !group then return end

    group:RemovePlayer(ply)
end)

net.Receive("GroupsBindChange", function(len, ply)
    local key = net.ReadString()
    local val = net.ReadInt(32)

    ply["group" .. key .. "bind"] = val
end)

hook.Add("PlayerCanHearPlayersVoice", "GroupsChannel", function(listener, talker)
    if !(listener:GetNWBool("InGroupVC") and talker:GetNWBool("InGroupVC")) then return end

    local group = talker:GetGroup()
    if !group then return end

    if group:GetPlayers()[listener] then
        return true, false
    end
end)

hook.Add("PlayerButtonDown", "GroupVC", function(ply, key)
    if key == (ply.groupvoicebind or KEY_O) then
        ply:SetNWBool("InGroupVC", !ply:GetNWBool("InGroupVC"))
    end
end)

hook.Add("PlayerButtonDown", "GroupsPing", function(ply, key)
    if key == (ply.grouppingbind or KEY_P) then
        local group = ply:GetGroup()
        if !group then return end
        group:SetPing(ply)
    end
end)
