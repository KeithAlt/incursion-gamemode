

local function commands()
    nut.command.add( "charsetlevel", {
        superAdminOnly = true,
        syntax = "<string target> <int level> <bool reset>",
        onRun = function( ply, arguments )
            local target = nut.command.findPlayer( client, arguments[1] )
            if not IsValid(target) then return end
            local char = target:getChar( )
            if char == nil then return end
            if tonumber(arguments[2]) == nil then return end
            local level = tonumber(arguments[2])

            char:setData( "level", level )
            char:setData( "XP", nut.leveling.requiredXP( level ) )
            char:setData( "skillPoints", level + ( Armor and Armor.Config.SkillPoints ) )

            local reset = tobool(arguments[3])
            if isbool(reset) and reset then
                char:setData( "skerks", { } ) -- Reset players skills
                char:setData( "special", { } ) -- Reset players SPECIAL
                ply:notify( "You have set the level of " .. target:GetName( ) .. " to " .. level ..  " and reset their skills + specials.")
                jlib.AlertStaff(
                    jlib.SteamIDName(ply) .. " has set " .. jlib.SteamIDName(target) .. "'s character level to " ..  level .. " and reset their skills/specials."
                )
                local txt = jlib.SteamIDName(ply) .. " has set " .. jlib.SteamIDName(target) .. "'s character ( " .. char:getName() .. " ) " .. " level to " .. level .. " and reset their points."
                DiscordEmbed(txt, "🧍 Character Change Log 🧍", Color(255, 0, 0), "BTeam")
            else
                ply:notify( "You have set the level of " .. target:GetName( ) .. " to " .. level )
                jlib.AlertStaff(
                    jlib.SteamIDName(ply) .. " has set " .. jlib.SteamIDName(target) .. "'s character level to " ..  level
                )
                local txt = jlib.SteamIDName(ply) .. " has set " .. jlib.SteamIDName(target) .. "'s character ( " .. char:getName() .. " ) " .. " level to " .. level
                DiscordEmbed(txt, "🧍 Character Change Log 🧍", Color(255, 0, 0), "BTeam")
            end
        end
    } )

    nut.command.add( "charsetpoints", {
        superAdminOnly = true,
        syntax = "<string target> <int points>",
        onRun = function( ply, arguments )
            local target = nut.command.findPlayer( client, arguments[1] )
            if not IsValid(target) then return end
            local char = target:getChar( )
            if char == nil then return end
            if tonumber(arguments[2]) == nil then return end
            local level = arguments[2]

            char:setData( "skillPoints", level )
            ply:notify( "You have set the skillpoints of " .. target:GetName( ) .. " to " .. level )
            jlib.AlertStaff(
                jlib.SteamIDName(ply) .. " has set " .. jlib.SteamIDName(target) .. "'s character SPECIAL points to " ..  level
            )
            local txt = jlib.SteamIDName(ply) .. " has set " .. jlib.SteamIDName(target) .. "'s character ( " .. char:getName() .. " ) " .. " special points to " .. level
            DiscordEmbed(txt, "🧍 Character Change Log 🧍", Color(255, 0, 0), "BTeam")
        end
    } )

    nut.command.add( "charaddpoints", {
        superAdminOnly = true,
        syntax = "<string target> <int points>",
        onRun = function( ply, arguments )
            local target = nut.command.findPlayer( client, arguments[1] )
            if not IsValid(target) then return end
            local char = target:getChar( )
            if char == nil then return end
            if tonumber(arguments[2]) == nil then return end
            local level = arguments[2]
            local data = char:getData( "skillPoints" )

            char:setData( "skillPoints", data + level )
            ply:notify( "You have added " .. level .. " points to " .. target:GetName( ) .. " ( Current: " .. data + level .. " )" )
            jlib.AlertStaff(
                jlib.SteamIDName(ply) .. " has added " .. level .. " points to : " ..  jlib.SteamIDName(target) .. "'s character "
            )
            local txt = jlib.SteamIDName(ply) .. " has added " .. level .. " points to " .. jlib.SteamIDName(target) .. "'s character ( " .. char:getName() .. " ) "
            DiscordEmbed(txt, "🧍 Character Change Log 🧍", Color(255, 0, 0), "BTeam")
        end
    } )

    nut.command.add( "charreset", {
        superAdminOnly = true,
        syntax = "<string target>",
        onRun = function( ply, arguments )
            local target = nut.command.findPlayer( client, arguments[1] )
            if not IsValid(target) then return end
            local char = target:getChar( )
            if char == nil then return end

            char:setData( "level", 0 )
            char:setData( "XP", 0 )
            char:setData( "skillPoints", 0 )
            char:setData( "skerks", { } )
            char:setData( "special", { } )
            ply:notify( "You have reset " .. target:GetName() .. " to default." )
            jlib.AlertStaff(
                jlib.SteamIDName(ply) .. " has reset " .. jlib.SteamIDName(target) .. "'s character "
            )
            local txt = jlib.SteamIDName(ply) .. " has reset " .. jlib.SteamIDName(target) .. "'s character ( " .. char:getName() .. " ) "
            DiscordEmbed(txt, "🧍 Character Change Log 🧍", Color(255, 0, 0), "BTeam")
        end
    } )
end
hook.Add( "InitPostEntity", "UTILCOMMANDS___", commands)