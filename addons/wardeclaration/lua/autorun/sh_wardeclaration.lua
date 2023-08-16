WARDECLARATION = WARDECLARATION or {}
WARDECLARATION.Attacks = {}
WARDECLARATION.Types = {
    ["Raid"] = {
        time = 300, -- In Seconds.
        canAssist = true,
        canSkirmish = true,
        cooldown = 600,
        soundeffect = "forp/ui/warraid.ogg", -- Sound to play when the UI appears in the top right
        attackendsound = "fo_tracks/areas/scr/mus_scr_goodspringsstinger.ogg", -- Sound to play when the attack finishes.
        starterFunction = function(faction, caller)
        end,
    },
    ["War"] = {
        time = 600,
        canAssist = true,
        permaNLRSection = 25,
        cooldown = 1200,
        adminOnly = false,
		canDeclare = function(caller) return hcWhitelist.isHC(caller) end,
		requiresApproval = true, -- Does the attack type require staff approval
        soundeffect = "forp/ui/warwar.ogg", -- Sound to play when the UI appears in the top right
        attackendsound = "fo_tracks/areas/scr/mus_scr_goodspringsstinger.ogg", -- Sound to play when the attack finishes.
        starterFunction = function(faction, client)
            local enemyPoint = WARDECLARATION.Points[faction]
            local callerPoint = WARDECLARATION.Points[client:Team()]
            if !enemyPoint or !callerPoint then
                jlib.Announce(client, Color(255,0,0), "[ERROR] ", Color(255,155,155), (enemyPoint and "Your" or "Enemy") .. " faction does not have their war point set, contact B-Team.")
                return false
            end 

            client.warReady = nil

            local flag1 = ents.Create("dec_capturepoint")
            flag1:SetFaction(client:Team())
            flag1:SetPos( callerPoint )
            flag1:Spawn()
    
            local flag2 = ents.Create("dec_capturepoint")
            flag2:SetFaction(faction)
            flag2:SetPos( enemyPoint )
            flag2:Spawn()
            
            WARDECLARATION.Flags[#WARDECLARATION.Flags + 1] = flag1
            WARDECLARATION.Flags[#WARDECLARATION.Flags + 1] = flag2
            return true
        end,
    },
    ["Conquest"] = {
        time = 600,
        canAssist = false,
        cooldown = 3000,
        permaNLRSection = 25,
        adminOnly = false,
		canDeclare = function(caller) return hcWhitelist.isHC(caller) end,
		requiresApproval = true, -- Does the attack type require staff approval
        soundeffect = "forp/ui/hostilities.ogg", -- Sound to play when the UI appears in the top right
        attackendsound = "fo_tracks/areas/scr/mus_scr_goodspringsstinger.ogg", -- Sound to play when the attack finishes.
		postRequestFunction = function(faction, caller)
			jlib.RequestString("Your Discord ID:", function(text)
				if #text < 1 then
					caller:notify("Contact B-Team to organize")
					jlib.Announce(caller, Color(255,0,0), "[WARNING] ", Color(255,155,155), "It is critical that B-Team schedule this assault")
					return
				end

				caller:notify("Discord info submitted")
				jlib.Announce(caller, Color(255,0,0), "[WARNING] ", Color(255,155,155), "Ensure your privacy settings on Discord allows B-Team to message you")

				jlib.SendNotification(caller, "Conquest Information",
					"[ IMPORTANT ]\n\n- A conquest must be scheduled by B-Team\n- Your request has been sent to B-Team\n- Your conquest intent is now known to all"
				)

				DiscordEmbed(
					"**Discord ID of Requester: **" .. text .. "\n- Either contact this player directly or the faction leader & also the target faction to schedule the conquest battle\n- Use the /approvedeclare command on the attacking player requester",
					"📋 Conquest Query Submission 📋" , Color(255,0,0), "BTeamChat"
				)

				DiscordEmbed("Rumor spreads that a major attack will take place soon in the wasteland...", "⛈️ Calm before the storm... ⛈️", Color(255,0,0), "IncursionChat")
			end, caller, "Submit")


		end,
        starterFunction = function(faction, client)
            local enemyPoint = WARDECLARATION.Points[faction]
            local callerPoint = WARDECLARATION.Points[client:Team()]
            if !enemyPoint or !callerPoint then
                jlib.Announce(client, Color(255,0,0), "[ERROR] ", Color(255,155,155), (enemyPoint and "Your" or "Enemy") .. " faction does not have their war point set, contact B-Team.")
                return false
            end 

            client.warReady = nil
    
            local flag1 = ents.Create("dec_capturepoint")
            flag1:SetFaction(client:Team())
            flag1:SetPos( callerPoint )
            flag1:Spawn()
    
            local flag2 = ents.Create("dec_capturepoint")
            flag2:SetFaction(faction)
            flag2:SetPos( enemyPoint )
            flag2:Spawn()

            WARDECLARATION.Flags[#WARDECLARATION.Flags + 1] = flag1
            WARDECLARATION.Flags[#WARDECLARATION.Flags + 1] = flag2
            return true
        end,
    },
	["Hostilities"] = {
        time = 600,
        canAssist = false,
        cooldown = 1200,
        soundeffect = "forp/ui/warhostile.ogg", -- Sound to play when the UI appears in the top right
        attackendsound = "fo_tracks/areas/scr/mus_scr_goodspringsstinger.ogg", -- Sound to play when the attack finishes.
    },
}

-- TO MAKE A FACTION IMMUNE TO ATTACKS:
--FACTION.NotAttackable = true
-- MAKE A FACTION IMMUNE TO A TYPE OF ATTACK : (case sensitive)
--FACTION.RaidImmune = true

local plyMeta = FindMetaTable( "Player" )
function plyMeta:CanCallAttack( ) -- Adjust this accordingly
    return true
end

--[[
    ISINATTACK
    @faction : THE FACTION TO CHECK,

    - Returns both bool and type of attack if it is in an attack.
]]
-- typ/type is optional.
function WARDECLARATION.IsInAttack( faction )
    if table.IsEmpty(WARDECLARATION.Attacks) then return false end
    if WARDECLARATION.Attacks.participants == nil then return false end
    if istable(WARDECLARATION.Attacks.participants[faction]) then return true, WARDECLARATION.Attacks.type end

    for k, v in pairs(WARDECLARATION.Attacks.participants) do
        if v[faction] then 
            return true, WARDECLARATION.Attacks.type
        end
    end

    return false
end

function WARDECLARATION.IsAttackable( faction, attacktype, caller )
    if nut.faction.indices[faction][attacktype .. "Immune"] or nut.faction.indices[faction].NotAttackable then return false end
    if IsValid(caller) and nut.faction.indices[caller:Team()][attacktype .. "Immune"] or nut.faction.indices[caller:Team()].NotAttackable then return false end

    return true
end

// To check only if assisting
function WARDECLARATION.IsAssisting( faction )
    if WARDECLARATION.Attacks.calling == nil then return end

    for k,v in pairs(WARDECLARATION.Attacks.participants) do
        if v[faction] then return true end
    end

    return false
end


local function GetFactionFromName(client, str)
    for k, v in ipairs(nut.faction.indices) do
        if (nut.util.stringMatches(v.uniqueID, str) or nut.util.stringMatches(L(v.name, client), str)) then
            return v.index
        end
    end

    return false
end

hook.Add("InitPostEntity", "WarDeclarationInitalize", function()
    MsgC(Color(200, 200, 0), "[WAR DECLARATION] ", Color(255,255,255), "Initalizing war declaration system . . .\n")

    nut.command.add( "givewarreason", {
        superAdminOnly = true,
        syntax = "<string faction> <string enemy> <string reason>",
        onRun = function( client, arguments )
            local fac = GetFactionFromName(client, arguments[1])
            local enemyf = GetFactionFromName(client, arguments[2])
            local reason = arguments[3]
            if !fac then return "Couldn't find giving faction." end
            if !enemyf then return "Couldn't find enemy faction." end
    
            local rdata = WARDECLARATION.WarReasons[fac]
            if !rdata then
                WARDECLARATION.WarReasons[fac] = {}
            end
    
            local enemyData = WARDECLARATION.WarReasons[fac][enemyf]
            if !enemyData then
                WARDECLARATION.WarReasons[fac][enemyf] = {}
            end
    
    
            local rList = WARDECLARATION.WarReasons[fac][enemyf]
            rList[#rList + 1] = reason
    
            WARDECLARATION.SaveReasons()
            DiscordEmbed( client:Name() .. "(" .. client:SteamID() .. ") has granted " .. nut.faction.indices[fac].name .. " a war reason on " .. nut.faction.indices[enemyf].name .. " with reason: " .. reason, "⚔️ War Reason Grant Log ⚔️", Color(255, 0, 0), "BTeam")
            
            return "Gave " .. nut.faction.indices[fac].name .. " a war reason on " .. nut.faction.indices[enemyf].name
        end
    } )
    
    nut.command.add( "approvedeclare", {
        adminOnly = true,
        onRun = function( client, arguments )
			local target = client:GetEyeTrace().Entity

			if !IsValid(target) or !target:IsPlayer() then
				target = client
			end

			if !target.pendingDeclare then
				client:notify("Player has no pending declare request!")
				return
			end

			DiscordEmbed(
				"· **Staff Approver:** " .. jlib.SteamIDName(client) .. " approved a declaration for " .. target:Nick() .. " (" .. team.GetName(target:Team()) .. ")",
				"📋 Attack Approval Log 📋" , Color(255,255,0), "BTeamChat"
			)

			target.approvedDeclare = target.pendingDeclare
			target.pendingDeclare = nil

			target:notify("Declare request approved")
			client:notify("Approved the player's declare request")
			jlib.Announce(client, Color(0, 255, 0), "[DECLARE REQUEST] ", Color(255, 255, 155), target:Nick() .. "'s declare request has been approved", Color(255, 255, 255), "\n· Upon the player redeclaring; the battle will officially begin")
			jlib.Announce(target, Color(0, 255, 0), "[DECLARE REQUEST] ", Color(255, 255, 155), "Your declare request has been approved", Color(255, 255, 255), "\n· Upon redeclaring; the battle will officially begin")
        end
    } )

    nut.command.add( "startattack", {
        syntax = "<string type> <string faction>",
        onRun = function( client, arguments )
            local id
            local typ

            if arguments[1] == nil or arguments[2] == nil then
                client:notify("You are missing arguments.")
            end

            for k, v in ipairs( nut.faction.indices ) do
                if nut.util.stringMatches( v.name, arguments[2] ) or nut.util.stringMatches( v.uniqueID, arguments[2] ) then
                    id = v.index
                end
            end

            for k, v in pairs( WARDECLARATION.Types ) do
                if nut.util.stringMatches(k, arguments[1]) then
                    typ = k
                end
            end

            if WARDECLARATION.IsInAttack( id ) or WARDECLARATION.IsInAttack( client:Team( ) ) then
                client:notify( "This faction is already in an attack." )

                return
            else
                local val = id
                net.Start( "WARDECLARATION_ATTACKCONFIRMATION" )
                    net.WriteString( typ )
                    net.WriteInt( val, 8 ) -- faction id to attack
                net.Send( client )
            end
        end
    } )

    nut.command.add( "stopattack", {
        onRun = function( client, arguments )
            WARDECLARATION.StopAttack( client:Team( ), client )
        end
    } )

    nut.command.add( "startassist", {
        onRun = function( client, arguments )
            if nut.util.stringMatches( "attackers", arguments[1] ) then
                WARDECLARATION.AssistAttack( WARDECLARATION.Attacks.calling, client, "Attackers" )
            elseif nut.util.stringMatches( "defenders", arguments[1] ) then
                WARDECLARATION.AssistAttack( WARDECLARATION.Attacks.enemy, client, "Defenders" )
            end
        end
    } )


    nut.command.add( "stopassist", {
        onRun = function( client, arguments )
            local fac = WARDECLARATION.Attacks.calling
            WARDECLARATION.StopAssist( client, fac )
        end
    } )

    -- ADMIN COMMANDS
    nut.command.add( "resetattackcooldown", {
        adminOnly = true,
        onRun = function( client, arguments )
            local target = nut.command.findPlayer(client, table.concat(arguments, " "))

			if !target then
				jlib.Announce(client, Color(255,0,0), "[NOTICE] ", Color(255,255,255), " Enter the name of a player within the faction you wish to reset the attack the cooldowns of for this command!")
				return
			end

            if WARDECLARATION.HasCooldown(target:Team()) then
                WARDECLARATION.Cooldowns[target:Team()] = nil
                client:notify("The faction's cooldown has been reset.")
            else
                client:notify("Your faction does not have a cooldown.")
            end
        end
    } )

    nut.command.add( "resetwar", {
        adminOnly = true,
        onRun = function( client, arguments )
            WARDECLARATION.Attacks = { }
            WARDECLARATION.SyncWarUI()
        end
    } )

    -- FIXME: DEV COMMMANDS REMOVE BEFOR SHIP
    nut.command.add( "buildbots", {
        adminOnly = true,
        onRun = function( client, arguments )
            local amount = tonumber(arguments[1])

            for i = 0, amount do
                local bot = player.CreateNextBot("FACBOT_" .. i)
                bot:getChar():setFaction(client:Team())
            end
            client:notify("Created " .. amount .. " bots")
        end
    } )

    -- FIXME: DEV COMMMANDS REMOVE BEFOR SHIP
    nut.command.add( "removebots", {
        adminOnly = true,
        onRun = function( client, arguments )
            for k, v in ipairs(player.GetAll()) do
                if v:IsBot() then v:Kick(".") end
            end
        end
    } )

	MsgC(Color(200, 200, 0), "[WAR DECLARATION] ", Color(255,255,255), "Succesfully initalized war declaration system\n")


    for k, v in pairs(WARDECLARATION.Types) do
        MsgC(Color(255,255,0), "[WAR DECLARATION] ", Color(255,255,255), "WARDECLARATION > Initialized attack type: " .. k .. "\n")
        nut.config.add(k .. " - Minimum Players", 5, "Minimum amount required to be targeted by this attack", nil, {
            data = {min = 1, max = 100},
            category = "WAR DECLARATION",
        })
        nut.config.add(k .. " - Can Assist", true, "If this attack type can be assisted", nil, {
            category = "WAR DECLARATION",
        })
        nut.config.add(k .. " - Cooldown", 600, "Time before a faction can call another attack.", nil, {
            data = {min = 10, max = 3600},
            category = "WAR DECLARATION",
        })
        nut.config.add(k .. " - Time", 300, "How long the attack lasts.", nil, {
            data = {min = 10, max = 3600},
            category = "WAR DECLARATION",
        })

        nut.config.add(k .. " - Can Skirmish", false, "If the mode supports 3 teams.", nil, {
            category = "WAR DECLARATION",
        })

        
        if v.permaNLRSection then
            nut.config.add(k .. " - Perma NLR Time", 20, "The time frame the player should be ghosted if dying in percent.", nil, {
                data = {min = 0, max = 100},
                category = "WAR DECLARATION",
            })
        end
    end

/**
    nut.config.add("Conquest - Pop Ratio", 300, "What population ratio is required for an attacking faction to perform a conquest? (EX: 1:1)", nil, {
        data = {min = 1, max = 100},
        category = "WAR DECLARATION",
    })
**/

    MsgC(Color(200, 200, 0), "[WAR DECLARATION] ", Color(255,255,255), "War declaration system succesfully loaded\n")
end)
