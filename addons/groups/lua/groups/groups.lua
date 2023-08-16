local PLAYER = FindMetaTable("Player")

function PLAYER:GetGroup()
    for id, group in pairs(GROUPS) do
        setmetatable(group, GroupsMeta) --For client-side where it might not be set yet
        if group:GetPlayers()[self] then
            return group
        end
    end
end

function PLAYER:GroupChat(message, sender)
    if CLIENT then
        chat.AddText(Color(100, 255, 100, 255), "[GROUP] ", Color(240, 240, 0, 255), sender:Nick() .. ": ", Color(255, 255, 255, 255), message)
    else
        net.Start("GroupChat")
            net.WriteString(message)
            net.WriteEntity(sender)
        net.Send(self)
    end
end

GroupsMeta = {}
GROUPS = {}

groupsConfig.Colors = {
    Color(255, 0, 0, 255),
    Color(0, 100, 255, 255),
    Color(0, 255, 50, 255),
    Color(255, 255, 0, 255),
    Color(255, 0, 157),
    Color(0, 195, 255),
    Color(67, 0, 145),
    Color(145, 7, 224)
}

local function SyncGroups()
    net.Start("SyncGroups")
        net.WriteTable(GROUPS)
    net.Broadcast()
end

function GroupsMeta:Init(name, owner)
    self.players = {[owner] = "owner"}
    self.name = name

    self.ID = table.insert(GROUPS, self)

    SyncGroups()
end

function GroupsMeta:SetName(name)
    for k,v in pairs(GROUPS) do
        if v:GetName() == name then
            return
        end
    end

    self.name = name

    SyncGroups()
end

function GroupsMeta:GetName()
    return self.name
end

function GroupsMeta:GetPlayers()
    return self.players
end

function GroupsMeta:SetOwner(ply)
    local curOwner = self:GetOwner()
    local plys = self:GetPlayers()
    plys[curOwner] = "normal"
    plys[ply] = "owner"
    self.players = plys
    SyncGroups()
end

function GroupsMeta:GetOwner()
    for ply, rank in pairs(self.players) do
        if rank == "owner" then return ply end
    end
end

function GroupsMeta:AddPlayer(ply, isOwner)
    if ply:GetGroup() == nil and table.Count(self:GetPlayers()) < groupsConfig.MaxPlayers then
        self.players[ply] = "normal"

        SyncGroups()
    end
end

function GroupsMeta:RemovePlayer(ply)
    self.players[ply] = nil

    SyncGroups()
end

function GroupsMeta:SetPing(ply)
    local pos = ply:GetEyeTraceNoCursor().HitPos
    local curPos = ply:GetNW2Vector("GroupPing", false)
    if curPos and curPos:Distance(pos) <= 10 then
        ply:SetNW2Vector("GroupPing", nil)
        return
    end
    ply:SetNW2Vector("GroupPing", pos)
end

function GroupsMeta:GetPings()
    local pings = {}
    local i = 1
    for ply, rank in pairs(self.players) do
        if !IsValid(ply) then continue end
        local pos = ply:GetNW2Vector("GroupPing", false)
        if !pos then i = i + 1 continue end
        pings[groupsConfig.Colors[i]] = pos
        i = i + 1
    end
    return pings
end

function GroupsMeta:Disband()
    for ply, ranks in pairs(self:GetPlayers()) do
        self:RemovePlayer(ply)
    end
    GROUPS[self.ID] = nil

    SyncGroups()
end

GroupsMeta.__index = GroupsMeta

function CreateGroup(owner, name)
    if owner:GetGroup() != nil then
        owner:notify("You are already apart of a group.")
        return
    end

    for k,v in pairs(GROUPS) do
        if v:GetName() == name then
            owner:notify("There is already a group that exists with this name.")
            return
        end
    end

    local group = {}
    setmetatable(group, GroupsMeta)
    group:Init(name, owner)

    owner:notify("Successfully created group")

    return group
end