WIPEDAY = false -- defines if we want to relocate the map entities to a specific position.

-- type 'getpos' in console to get your position, Vector(x, y, z)
WIPEDAYPOS_VENDOR = Vector(-583.831726, -4562.346680, 1205.984009) -- Configured for cgc_capitalwasteland as of this comment
WIPEDAYPOS_WORKBENCH = Vector(-1853.628540, -3272.246826, 1212.214233) -- Configured for cgc_capitalwasteland as of this comment
WIPEDAYPOS_STORAGE = Vector(467.445190, -2585.925781, 1129.432861) -- Configured for cgc_capitalwasteland as of this comment

hook.Add("InitPostEntity", "LoadCommandsWipeUtil", function()
    nut.command.add( "getallworkbenches", {
        superAdminOnly = true,
        onRun = function( client, arguments )
            for k, v in ipairs(ents.FindByClass("workbench")) do
                v:SetPos( client:GetPos() )
                v:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
            end

            jlib.Announce(client, Color(255,0,0), "[WIPE WARNING]", Color(255, 255, 255), " Ensure you are disabling the wipe day variable before restarting!")
            jlib.Announce(client, Color(255,0,0), "[WIPE WARNING]", Color(255, 255, 255), " Ensure you are disabling the wipe day variable before restarting!")
            jlib.Announce(client, Color(255,0,0), "[WIPE WARNING]", Color(255, 255, 255), " Ensure you are disabling the wipe day variable before restarting!")
            return "Teleported all workbenches to your location."
        end
    } )

    nut.command.add( "getallvendors", {
        superAdminOnly = true,
        onRun = function( client, arguments )
            for k, v in ipairs(ents.FindByClass("nut_vendor")) do
                v:SetPos( client:GetPos() )
            end

            jlib.Announce(client, Color(255,0,0), "[WIPE WARNING]", Color(255, 255, 255), " Ensure you are disabling the wipe day variable before restarting!")
            jlib.Announce(client, Color(255,0,0), "[WIPE WARNING]", Color(255, 255, 255), " Ensure you are disabling the wipe day variable before restarting!")
            jlib.Announce(client, Color(255,0,0), "[WIPE WARNING]", Color(255, 255, 255), " Ensure you are disabling the wipe day variable before restarting!")
            return "Teleported all vendors to your location."
        end
    } )

    nut.command.add( "getall", {
        syntax = "<string class>",
        superAdminOnly = true,
        onRun = function( client, arguments )
            for k, v in ipairs(ents.FindByClass(arguments[1])) do
                v:SetPos( client:GetPos() )
            end

            return "Teleporting all entities by class '" .. arguments[1] .. "' to your location."
        end
    } )

    nut.command.add( "restockallvendors", {
        superAdminOnly = true,
        onRun = function( client, arguments )
            for k, v in ipairs(ents.FindByClass("nut_vendor")) do
                for id,_ in pairs(v.items) do
                    if v.items[id][2] and v.items[id][4] then
                        v.items[id][2] = v.items[id][4]
                    end
                end
            end

            return "Restocked all vendors."
        end
    } )

    nut.command.add( "resetallvendormoney", {
        superAdminOnly = true,
        syntax = "<int amount>",
        onRun = function( client, arguments )
            for k, v in ipairs(ents.FindByClass("nut_vendor")) do
                if v.money then
                    v.money = tonumber(arguments[1]) or 0
                end
            end

            return "Reset the money of all vendors to " .. (arguments[1] or 0)
        end
    } )
end)
