FalloutGuilds = FalloutGuilds or {}
FalloutGuilds.Guilds = FalloutGuilds.Guilds or {} --Each should have a members and territories sub table
FalloutGuilds.Config = FalloutGuilds.Config or {}

include("guilds_config.lua")

function FalloutGuilds.IsOwner(id, member)
    local char = member:getChar()

    if !char then
        return false
    end

    return FalloutGuilds.Guilds[id].members[char:getID()] == 2
end

function FalloutGuilds.IsOwnerAny(member)
    local char = member:getChar()

    if !char then
        return false
    end

    local _, guildID = FalloutGuilds.GetGuild(member)

    return guildID and FalloutGuilds.IsOwner(guildID, member) or false
end

function FalloutGuilds.IsOfficer(id, member)
    local char = member:getChar()

    if !char then
        return false
    end

    return FalloutGuilds.Guilds[id].members[char:getID()] > 0
end

function FalloutGuilds.IsMember(id, member)
    local char = member:getChar()

    if !char then
        return false
    end

    return isnumber(FalloutGuilds.Guilds[id].members[char:getID()])
end

function FalloutGuilds.GetOwnerID(id)
    if !FalloutGuilds.Guilds[id] then
        return
    end

    for charID, rank in pairs(FalloutGuilds.Guilds[id].members) do
        if rank == 2 then
            return charID
        end
    end
end

function FalloutGuilds.GetOwner(id)
    if !FalloutGuilds.Guilds[id] then
        return NULL
    end

    local charID = FalloutGuilds.GetOwnerID(id)

    local char = nut.char.loaded[charID]

    if char then
        return char:getPlayer()
    else
        return NULL
    end
end

function FalloutGuilds.GetGuild(ply)
    local char = ply:getChar()

    if !char then return end

    local guildID = char:getData("guildID", nil)

    if !guildID then return end

    local guild = FalloutGuilds.Guilds[guildID]

    return guild, guildID
end

function FalloutGuilds.ShouldGuildSpawn(ply)
    local guild = FalloutGuilds.GetGuild(ply)

    if !guild then return false end

	if table.Count(guild.members) < FalloutGuilds.Config.MinMembers then return false end

    local char = ply:getChar()
    local classID = char:getClass()
    local class = nut.class.list[classID]

    if !class then return false end

    local classUID = class.uniqueID

    return FalloutGuilds.Config.SpawnClasses[classUID] or false
end

function FalloutGuilds.RandomSpawn(id)
    local guild = FalloutGuilds.Guilds[id]

    local spawns = {}

    for tID, territory in pairs(guild.territories) do
        for sID, spawnPos in pairs(territory.spawns) do
            spawns[#spawns + 1] = spawnPos
        end
    end

    return #spawns > 0 and spawns[math.random(1, #spawns)] or nil
end

function FalloutGuilds.IsPointInTerritory(pos)
    for gID, guild in pairs(FalloutGuilds.Guilds) do
        for terrID, territory in pairs(guild.territories) do
            if pos:WithinAABox(territory.mins, territory.maxs) then
                return true, gID
            end
        end
    end

    return false
end

function FalloutGuilds.TerritoryOverlap(mins, maxs)
    for gID, guild in pairs(FalloutGuilds.Guilds) do
        for terrID, territory in pairs(guild.territories) do
            if mins.x < territory.maxs.x and maxs.x > territory.mins.x and mins.y < territory.maxs.y and maxs.y > territory.mins.y then
                return true
            end
        end
    end

    return false
end

function FalloutGuilds.TotalTerritoryArea(id)
    local guild = FalloutGuilds.Guilds[id]
    local territories = guild.territories

    local total = 0

    for tID, territory in pairs(territories) do
        local w = territory.maxs.x - territory.mins.x
        local l = territory.maxs.y - territory.mins.y

        local area = w * l

        total = total + area
    end

    return total
end

hook.Add("InitPostEntity", "GuildInit", function()
    nut.command.add("guild", {
        onRun = function(ply, args)
            local guild = FalloutGuilds.GetGuild(ply)

            if guild then
                local ids = "("

                for charID, rank in pairs(guild.members) do
                    ids = ids .. charID .. ", "
                end

                ids = string.sub(ids, 0, -3)

                ids = ids .. ")"

                nut.db.query("SELECT * FROM `nut_characters` WHERE `_id` IN " .. ids .. ";", function(members)
                    if members then
                        local membersData = {}

                        for _, member in pairs(members) do
                            membersData[#membersData + 1] = {
                                name    = member._name,
                                steamID = member._steamID,
                                charID  = tonumber(member._id),
                                rank    = guild.members[tonumber(member._id)]
                            }
                        end

                        net.Start("GuildOpenMenu")
                            net.WriteBool(true)
                            jlib.WriteCompressedTable(membersData)
                        net.Send(ply)
                    else
                        net.Start("GuildOpenMenu")
                            net.WriteBool(false)
                        net.Send(ply)
                    end
                end)
            else
                net.Start("GuildOpenMenu")
                    net.WriteBool(false)
                net.Send(ply)
            end
        end
    })

    nut.command.add("guildinvite", {
        onRun = function(ply, args)
            local name = table.concat(args, " ")
            local target = jlib.GetPlayer(name)

            local guild, gID = FalloutGuilds.GetGuild(ply)

            local isOfficer = guild and FalloutGuilds.IsOfficer(gID, ply)

            if guild and IsValid(target) and isOfficer then
                FalloutGuilds.Invite(target, gID)
            elseif !guild then
                ply:notify("You are not a member of a guild.")
            elseif !IsValid(target) then
                ply:notify("Target not found!")
            elseif !isOfficer then
                ply:notify("You must be an officer of your guild to do this!")
            end
        end
    })

	nut.command.add("guildspawnclasses", {
		adminOnly = true,
		onRun = function(ply)
            net.Start("GuildSpawnClasses")
			net.Send(ply)
        end
	})

	nut.command.add("guildremoveterritory", {
		adminOnly = true,
		onRun = function(ply)
			local guildID
			local territoryID
			local guild

			for id, guildData in pairs(FalloutGuilds.Guilds) do
				if guildData.territories then
					for terrID, terrData in pairs(guildData.territories) do
						if ply:GetPos():WithinAABox(Vector(terrData.mins), Vector(terrData.maxs)) then
							territoryID = terrID
							guildID = id
							guild = guildData
							break
						end
					end
				end
			end

			if !(guild or guildID or territoryID) then
				ply:notify("You are not within a guild's claimed area")
				return
			end

			jlib.RequestBool("Remove guild territory?", function(bool)
				if !bool then return end

				FalloutGuilds.Guilds[guildID].territories[territoryID] = nil
			    FalloutGuilds.Save()
			    FalloutGuilds.NetworkToMembers(guildID)

				ply:notify("Removed territory claim")
				jlib.Announce(ply, Color(255,0,0), "[GUILD] ", Color(255,155,155), "You've removed the claimed guild territory you're standing in")

			end, ply, "YES (REMOVE)", "NO (CANCEL)")
		end
	})
end)
