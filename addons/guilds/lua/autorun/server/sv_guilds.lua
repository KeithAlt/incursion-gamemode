AddCSLuaFile("guilds_config.lua")

util.AddNetworkString("GuildUpdate")
util.AddNetworkString("GuildOpenMenu")
util.AddNetworkString("GuildFullUpdate")
util.AddNetworkString("GuildCreateTerritory")
util.AddNetworkString("GuildRemoveTerritory")
util.AddNetworkString("GuildAddTerritorySpawn")
util.AddNetworkString("GuildRemoveTerritorySpawn")
util.AddNetworkString("GuildCreate")
util.AddNetworkString("GuildTransferOwner")
util.AddNetworkString("GuildPromote")
util.AddNetworkString("GuildInvite")
util.AddNetworkString("GuildInviteResponse")
util.AddNetworkString("GuildKick")
util.AddNetworkString("GuildLeave")
util.AddNetworkString("GuildDisband")
util.AddNetworkString("GuildDemote")
util.AddNetworkString("GuildSpawnClasses")
util.AddNetworkString("GuildUpdateSpawnClass")

--Data
function FalloutGuilds.Save()
    if !file.Exists("guilds", "DATA") then
        file.CreateDir("guilds")
    end

    file.Write("guilds/guilds.json", util.TableToJSON(FalloutGuilds.Guilds))
end

function FalloutGuilds.Load()
    FalloutGuilds.Guilds = util.JSONToTable(file.Read("guilds/guilds.json", "DATA") or "[]")

    --Wipe territories when the server loads data
	if gID && guild then
	    for gID, guild in pairs(FalloutGuilds.Guilds) do
	        for tID, territory in pairs(guild.territories) do
	            FalloutGuilds.Guilds[gID].territories[tID] = nil
	        end
	    end
	else
		return
	end

    FalloutGuilds.Save()
    FalloutGuilds.FullUpdate(player.GetAll())
end

function FalloutGuilds.Create(owner, name)
    local char = owner:getChar()

    if !char then return end

    local guild = {}
    guild.members = {}
    guild.territories = {}

    guild.members[char:getID()] = 2

    guild.name = name

    local id = table.insert(FalloutGuilds.Guilds, guild)

    char:setData("guildID", id)

    FalloutGuilds.Save()
    FalloutGuilds.NetworkToAll(id)

    return id
end

function FalloutGuilds.Disband(id)
    for charID, rank in pairs(FalloutGuilds.Guilds[id].members) do
        FalloutGuilds.RemoveMemberGID(charID)
    end

    FalloutGuilds.Guilds[id] = nil

    FalloutGuilds.Save()

    FalloutGuilds.FullUpdate(player.GetAll())
end

function FalloutGuilds.AddMember(id, member)
    local char = member:getChar()

    if !char then return end

    FalloutGuilds.Guilds[id].members[char:getID()] = 0
    char:setData("guildID", id)

    FalloutGuilds.Save()
    FalloutGuilds.NetworkToAll(id)
end

function FalloutGuilds.RemoveMemberGID(charID)
    if nut.char.loaded[charID] then
        nut.char.loaded[charID]:setData("guildID", nil)
    else
        nut.db.query("SELECT * FROM `nut_characters` WHERE `_id` = " .. charID .. ";", function(result)
            if istable(result) then
                local charData = result[1]
                local json = charData._data
                local dat  = util.JSONToTable(json)

                dat.guildID = nil
                json = util.TableToJSON(dat)

                nut.db.query("UPDATE `nut_characters` SET _data = '" .. json .. "' WHERE `_id` = " .. charID .. ";")
            end
        end)
    end
end

function FalloutGuilds.RemoveMember(id, charID)
    FalloutGuilds.Guilds[id].members[charID] = nil

    FalloutGuilds.RemoveMemberGID(charID)

    FalloutGuilds.Save()
    FalloutGuilds.NetworkToAll(id)
end

function FalloutGuilds.MakeOwner(id, member)
    local char = member:getChar()

    if !char then return end

    FalloutGuilds.Guilds[id].members[char:getID()] = 2
    FalloutGuilds.Guilds[id].members[FalloutGuilds.GetOwnerID(id)] = 1

    FalloutGuilds.NetworkToMembers(id)
end

function FalloutGuilds.MakeOfficer(id, member)
    local char = member:getChar()

    if !char then return end

    FalloutGuilds.Guilds[id].members[char:getID()] = 1

    FalloutGuilds.Save()
    FalloutGuilds.NetworkToMembers(id)
end

function FalloutGuilds.MakeOfficerByID(id, charID)
    FalloutGuilds.Guilds[id].members[charID] = 1

    FalloutGuilds.Save()
    FalloutGuilds.NetworkToMembers(id)
end

function FalloutGuilds.MakeMemberByID(id, charID)
    FalloutGuilds.Guilds[id].members[charID] = 0

    FalloutGuilds.Save()
    FalloutGuilds.NetworkToMembers(id)
end

hook.Add("Initialize", "GuildLoad", FalloutGuilds.Load)

--Networking
function FalloutGuilds.NetworkToMembers(id)
    local guild = FalloutGuilds.Guilds[id]

    local plys = {}

    for charID, rank in pairs(guild.members) do
        local char = nut.char.loaded[charID]

        if char then
            local ply = char:getPlayer()

            if IsValid(ply) then
                table.insert(plys, ply)
            end
        end
    end

    net.Start("GuildUpdate")
        net.WriteUInt(id, 32)
        jlib.WriteCompressedTable(guild)
    net.Send(plys)
end

function FalloutGuilds.NetworkToAll(id)
    net.Start("GuildUpdate")
        net.WriteUInt(id, 32)
        jlib.WriteCompressedTable(FalloutGuilds.Guilds[id])
    net.Broadcast()
end

function FalloutGuilds.FullUpdate(ply)
    net.Start("GuildFullUpdate")
        jlib.WriteCompressedTable(FalloutGuilds.Guilds)
    net.Send(ply)
end
hook.Add("PlayerInitialSpawn", "GuildsPlayerInit", FalloutGuilds.FullUpdate)

net.Receive("GuildCreateTerritory", function(len, ply)
    local char = ply:getChar()

    if !char then return end

    local guildID = char:getData("guildID")

    if !guildID then return end
    if !FalloutGuilds.Guilds[guildID] then return end
    if !FalloutGuilds.IsOwner(guildID, ply) or table.Count(FalloutGuilds.Guilds[guildID].members) < FalloutGuilds.Config.MinMembers or table.Count(FalloutGuilds.Guilds[guildID].territories) >= FalloutGuilds.Config.MaxTerritories then return end

    local mins = net.ReadVector()
    local maxs = net.ReadVector()
    local name = net.ReadString()

    if #name <= 0 then return end

    local area = (maxs.x - mins.x) * (maxs.y - mins.y)
    if FalloutGuilds.TotalTerritoryArea(guildID) + area > FalloutGuilds.Config.MaxArea then
        ply:notify("Area too big!")
        return
    end

    local terrID = string.Replace(name:lower(), " ", "_")

    FalloutGuilds.Guilds[guildID].territories[terrID] = {mins = mins, maxs = maxs, name = name, spawns = {}, owner = guildID}

    FalloutGuilds.Save()
    FalloutGuilds.NetworkToAll(guildID)

	DiscordEmbed(jlib.SteamIDName(ply) .. " has created & claimed new territory (" .. name .. ") for their guild", "🏴󠁧󠁢󠁥󠁮󠁧󠁿 Guild Territory Claim Log 🏴󠁧󠁢󠁥󠁮󠁧󠁿" , Color(255,255,0), "Admin")
	jlib.AlertStaff(jlib.SteamIDName(ply) .. " has created & claimed new territory (" .. name .. ") for their guild")
    ply:notify("Territory created")
end)

net.Receive("GuildRemoveTerritory", function(len, ply)
    local char = ply:getChar()

    if !char then return end

    local guildID = char:getData("guildID")

    if !guildID then return end
    if !FalloutGuilds.Guilds[guildID] then return end
    if !FalloutGuilds.IsOwner(guildID, ply) then return end

    local terrID = net.ReadString()

    FalloutGuilds.Guilds[guildID].territories[terrID] = nil

    FalloutGuilds.Save()
    FalloutGuilds.NetworkToAll(guildID)

    ply:notify("Territory removed")
end)

net.Receive("GuildAddTerritorySpawn", function(len, ply)
    local char = ply:getChar()

    if !char then return end

    local guildID = char:getData("guildID")

    if !guildID then return end
    if !FalloutGuilds.Guilds[guildID] then return end
    if !FalloutGuilds.IsOwner(guildID, ply) then return end

    local terrID = net.ReadString()
    local pos = net.ReadVector()

    if table.Count(FalloutGuilds.Guilds[guildID].territories[terrID].spawns) >= FalloutGuilds.Config.MaxSpawns then
        ply:notify("Reached maximum spawns per territory!")
        return
    end

    table.insert(FalloutGuilds.Guilds[guildID].territories[terrID].spawns, pos)

    FalloutGuilds.Save()
    FalloutGuilds.NetworkToMembers(guildID)

    ply:notify("Created new territory spawn")
end)

net.Receive("GuildRemoveTerritorySpawn", function(len, ply)
    local char = ply:getChar()

    if !char then return end

    local guildID = char:getData("guildID")

    if !guildID then return end
    if !FalloutGuilds.Guilds[guildID] then return end
    if !FalloutGuilds.IsOwner(guildID, ply) then return end

    local terrID = net.ReadString()
    local spawnID = net.ReadUInt(32)

    FalloutGuilds.Guilds[guildID].territories[terrID].spawns[spawnID] = nil

    FalloutGuilds.Save()
    FalloutGuilds.NetworkToMembers(guildID)

    ply:notify("Removed territory spawn")
end)

--Spawning
hook.Add("PlayerSpawn", "GuildSpawns", function(ply)
	if FalloutGuilds.ShouldGuildSpawn(ply) && ply.verifyGuildSpawn then
		ply:ScreenFade(SCREENFADE.IN, Color(0,0,0,255), 2, 2) -- Extend dark screen until guild spawn
		jlib.CallAfterTicks(25, function() -- Required delay to resposition correctly (✨magic✨)
	        local spawn = FalloutGuilds.RandomSpawn(ply:getChar():getData("guildID"))
	        if spawn then
				ply:SetPos(spawn)
	        end
			ply.verifyGuildSpawn = nil
		end)
	end
end)

--Verify guild respawn
hook.Add("PostPlayerDeath", "GuildVerify", function(ply)
	if FalloutGuilds.ShouldGuildSpawn(ply) then
		ply.verifyGuildSpawn = true
	end
end)

--Guild management
net.Receive("GuildCreate", function(len, ply)
    if !FalloutGuilds.GetGuild(ply) then
        local name = net.ReadString()

        if #name < 4 then
            ply:notify("Name must be at least 4 characters.")
            return
        end

        FalloutGuilds.Create(ply, name)

		DiscordEmbed(jlib.SteamIDName(ply) .. " has created a new guild (" .. name .. ")", "🏴󠁧󠁢󠁥󠁮󠁧󠁿 Guild Creation Log 🏴󠁧󠁢󠁥󠁮󠁧󠁿" , Color(255,0,0), "Admin")
		jlib.AlertStaff(jlib.SteamIDName(ply) .. " has created a new guild (" .. name .. ")")
        ply:notify("Guild created")
    end
end)

net.Receive("GuildPromote", function(len, ply)
    local _, guildID = FalloutGuilds.GetGuild(ply)
    local charID = net.ReadInt(32)
    if !FalloutGuilds.IsOfficer(guildID, ply) then return end

    FalloutGuilds.MakeOfficerByID(guildID, charID)

    ply:notify("Guild member promoted")
end)

net.Receive("GuildDemote", function(len, ply)
    local _, guildID = FalloutGuilds.GetGuild(ply)
    local charID = net.ReadInt(32)

    if !FalloutGuilds.IsOfficer(guildID, ply) then return end

    FalloutGuilds.MakeMemberByID(guildID, charID)

    ply:notify("Guild member demoted")
end)

net.Receive("GuildTransferOwner", function(len, ply)
    local _, guildID = FalloutGuilds.GetGuild(ply)
    local charID = net.ReadInt(32)

    local char = nut.char.loaded[charID]
    if !char then ply:notify("The member must be online to perform this action") return end
    local target = char:getPlayer()
    if !IsValid(target) then ply:notify("The member must be online to perform this action") return end
    if target:getChar():getID() != charID then ply:notify("The member must be online to perform this action") return end

    if !FalloutGuilds.IsOwner(guildID, ply) then return end

    FalloutGuilds.MakeOwner(guildID, target)

    ply:notify("Guild ownership transfered")
end)

net.Receive("GuildKick", function(len, ply)
    local _, guildID = FalloutGuilds.GetGuild(ply)
    local charID = net.ReadInt(32)

    if !FalloutGuilds.IsOfficer(guildID, ply) then return end

    FalloutGuilds.RemoveMember(guildID, charID)

    ply:notify("Guild member kicked")
end)

net.Receive("GuildLeave",  function(len, ply)
    local _, guildID = FalloutGuilds.GetGuild(ply)
    local charID = ply:getChar():getID()

    FalloutGuilds.RemoveMember(guildID, charID)

    ply:notify("Guild left")
end)

net.Receive("GuildDisband", function(len, ply)
    local _, guildID = FalloutGuilds.GetGuild(ply)

    if !FalloutGuilds.IsOwner(guildID, ply) then return end

    FalloutGuilds.Disband(guildID)

    ply:notify("Guild disbanded")
end)

function FalloutGuilds.Invite(ply, guildID)
    net.Start("GuildInvite")
        net.WriteInt(guildID, 32)
    net.Send(ply)

    ply.guildInvite = guildID

    timer.Create("GuildInviteTimeout", 35, 1, function()
        ply.guildInvite = nil
    end)
end

net.Receive("GuildInvite", function(len, ply)
    local _, guildID = FalloutGuilds.GetGuild(ply)
    local target = net.ReadEntity()

    if !FalloutGuilds.IsOfficer(guildID, ply) then return end
    if FalloutGuilds.IsOwnerAny(target) then
        ply:notify("This person is already an owner of another guild!")
        return
    end

    FalloutGuilds.Invite(target, guildID)

    ply:notify("Guild invite sent")
end)

net.Receive("GuildInviteResponse", function(len, ply)
    local guildID = ply.guildInvite

    if FalloutGuilds.IsOwnerAny(ply) then
        ply:notify("You are already an owner of a guild!")
        return
    end

    if !guildID then
        ply:notify("Server couldn't find invite.")
        return
    end

    FalloutGuilds.AddMember(guildID, ply)
end)

--Disallow prop spawning in enemy territory
hook.Add("PlayerSpawnProp", "GuildTerritory", function(ply, model)
    local inTerritory, guildID = FalloutGuilds.IsPointInTerritory(ply:GetEyeTrace().HitPos)
    if inTerritory and guildID != ply:getChar():getData("guildID") then
        ply:notify("You can't spawn props in enemy territory!")
        return false
    end
end)

--Dynamic spawn classes
function FalloutGuilds.SaveSpawnClasses()
	file.Write("falloutguildsspawnclasses.json", util.TableToJSON(FalloutGuilds.Config.SpawnClasses))
end

function FalloutGuilds.LoadSpawnClasses()
	if file.Exists("falloutguildsspawnclasses.json", "DATA") then
		FalloutGuilds.Config.SpawnClasses = util.JSONToTable(file.Read("falloutguildsspawnclasses.json"))
	end
end

function FalloutGuilds.NetworkSpawnClasses(ply)
	net.Start("GuildUpdateSpawnClass")
		jlib.WriteCompressedTable(FalloutGuilds.Config.SpawnClasses)
	net.Send(ply)
end

FalloutGuilds.LoadSpawnClasses()

net.Receive("GuildSpawnClasses", function(len, ply)
	if ply:IsAdmin() then
		local spawnClasses = jlib.ReadCompressedTable()
		FalloutGuilds.Config.SpawnClasses = spawnClasses
		FalloutGuilds.SaveSpawnClasses()
		FalloutGuilds.NetworkSpawnClasses(player.GetAll())
	end
end)

hook.Add("PlayerInitialSpawn", "NetworkSpawnClasses", FalloutGuilds.NetworkSpawnClasses)
