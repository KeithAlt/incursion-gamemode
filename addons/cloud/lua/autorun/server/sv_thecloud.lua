util.AddNetworkString("TheCloudSendZones")
util.AddNetworkString("TheCloudZoneRemoved")

function TheCloud.Save()
    file.Write("thecloudzones.txt", util.TableToJSON(TheCloud.Zones))
end

function TheCloud.Load()
    local json = file.Read("thecloudzones.txt")

    if json then
        TheCloud.Zones = util.JSONToTable(json) or {}
    end
end

function TheCloud.BroadcastZones()
    net.Start("TheCloudSendZones")
        net.WriteTable(TheCloud.Zones)
    net.Broadcast()
end

function TheCloud.SendZones(ply)
    net.Start("TheCloudSendZones")
        net.WriteTable(TheCloud.Zones)
    net.Send(ply)
end

function TheCloud.FindNearestZone(pos)
    local nearestDist
    local nearest

    for k, v in pairs(TheCloud.Zones) do
        local centerX = (v.mins.x + v.maxs.x) / 2
        local centerY = (v.mins.y + v.maxs.y) / 2

        local center = Vector(centerX, centerY)
        local distance = center:Distance(pos)

        if !nearestDist or nearestDist > distance then
            nearestDist = distance
            nearest = k
        end
    end

    return nearest
end

function TheCloud.AddZone(mins, maxs, dmg)
    if mins.z > maxs.z then
        mins.z = mins.z + 500
    else
        maxs.z = maxs.z + 500
    end

    table.insert(TheCloud.Zones, {
        ["dmg"] = dmg,
        ["mins"] = mins,
        ["maxs"] = maxs
    })

    TheCloud.BroadcastZones()
    TheCloud.Save()
end

function TheCloud.RemoveZone(index)
    net.Start("TheCloudZoneRemoved")
        net.WriteTable(TheCloud.Zones[index])
    net.Broadcast()

    table.remove(TheCloud.Zones, index)

    TheCloud.BroadcastZones()
    TheCloud.Save()
end

timer.Create("CloudTick", 1, 0, function()
    for k, zone in pairs(TheCloud.Zones) do
        local plys = jlib.FindPlayersInBox(zone.mins, zone.maxs)

        for _, ply in pairs(plys) do
            local char = ply:getChar()
            if char then
                local faction = nut.faction.indices[char:getFaction()].uniqueID
                if TheCloud.Config.ImmuneFactions[faction] then
                    continue
                end
            end

            ply:TakeDamage(zone.dmg)
            char:setVar("DmgTakenFromCloud", char:getVar("DmgTakenFromCloud", 0) + zone.dmg)

            if char:getVar("DmgTakenFromCloud", 0) > TheCloud.Config.DamageForInfection then
                ply:Give(TheCloud.Config.InfectionSWEP)
                char:setVar("DmgTakenFromCloud", 0)
            end
        end
    end
end)

hook.Add("Initialize", "TheCloudLoad", function()
    TheCloud.Load()
end)

hook.Add("PlayerInitialSpawn", "TheCloudSendZones", function(ply)
    TheCloud.SendZones(ply)
end)