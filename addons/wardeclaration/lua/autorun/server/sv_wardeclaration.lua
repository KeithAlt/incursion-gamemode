WARDECLARATION = WARDECLARATION or { }
WARDECLARATION.Cooldowns = { }
WARDECLARATION.Points = WARDECLARATION.Points or {}
WARDECLARATION.WarReasons = WARDECLARATION.WarReasons or {}

util.AddNetworkString( "WARDECLARATION_UPDATEUI" )
util.AddNetworkString( "WARDECLARATION_ADDTEAM" )
util.AddNetworkString( "WARDECLARATION_ADDASSISTER" )

util.AddNetworkString( "WARDECLARATION_SCOREBOARDTHREEWAY" )
util.AddNetworkString( "WARDECLARATION_LEAVESKIRMISH" )

util.AddNetworkString( "WARDECLARATION_REMOVEASSISTER" )
util.AddNetworkString( "WARDECLARATION_ATTACKEND" )
util.AddNetworkString( "WARDECLARATION_ATTACKCONFIRMATION" )
util.AddNetworkString( "WARDECLARATION_SCOREBOARDCLICK" )
util.AddNetworkString( "WARDECLARATION_SCOREBOARDCANCEL" )
util.AddNetworkString( "WARDECLARATION_SCOREBOARDASSIST" )
util.AddNetworkString( "WARDECLARATION_SCOREBOARDSTOPASSIST" )
util.AddNetworkString( "WARDECLARATION_BATTLEAMBIENCE" )

util.AddNetworkString( "WARDECLARATION_RequestFlagSpots" )
util.AddNetworkString( "WARDECLARATION_RemoveWarFlag" )
util.AddNetworkString( "WARDECLARATION_AddWarFlag" )

util.AddNetworkString( "WARDECLARATION_REQUESTREASONS" )
util.AddNetworkString( "WARDECLARATION_ACTIVATEWARREASON" )

util.AddNetworkString( "WARDECLARATION_HOSTILITIESRESET" )


function WARDECLARATION.SavePoints()
    if !file.Exists("declaration", "DATA") then
        file.CreateDir("declaration")
    end

    file.Write("declaration/points.json", util.TableToJSON(WARDECLARATION.Points))
end

function WARDECLARATION.LoadPoints()
	local data = util.JSONToTable(file.Read("declaration/points.json") or "[]")

	for faction, pos in pairs(data) do
        WARDECLARATION.Points[faction] = pos
	end
end

function WARDECLARATION.SaveReasons()
    if !file.Exists("declaration", "DATA") then
        file.CreateDir("declaration")
    end

    file.Write("declaration/reasons.json", util.TableToJSON(WARDECLARATION.WarReasons))
end

function WARDECLARATION.LoadReasons()
	local data = util.JSONToTable(file.Read("declaration/reasons.json") or "[]")

	for faction, reason in pairs(data) do
        WARDECLARATION.WarReasons[faction] = reason
	end
end

-- Get if a faction is core (FACTION.isCore)
function WARDECLARATION.IsCore(factionIndex)
	if !isnumber(factionIndex) then
		error("Invalid function argument; must be number type")
		return
	end

	return nut.faction.indices[factionIndex].isCore or false
end

-- Get if a faction is merchant (FACTION.isMerchant)
function WARDECLARATION.IsMerchant(factionIndex)
	if !isnumber(factionIndex) then
		error("Invalid function argument; must be number type")
		return
	end

	return nut.faction.indices[factionIndex].isMerchant or false
end

-- SV call to play ambient battle sounds
function WARDECLARATION.PlayAmbience( ply )
	net.Start( "WARDECLARATION_BATTLEAMBIENCE" )
	net.Send( ply )
end

net.Receive("WARDECLARATION_LEAVESKIRMISH", function(len, ply)
    if not ply:CanCallAttack() then return end

    WARDECLARATION.RemoveTeam(ply:Team())
end)

net.Receive("WARDECLARATION_SCOREBOARDTHREEWAY", function(len, ply)
    if not ply:CanCallAttack() then return end

    if WARDECLARATION.HasCooldown(ply:Team()) then
        ply:notify("Your faction has an attack cooldown [" .. math.Round(WARDECLARATION.HasCooldown( ply:Team( ) ), 0) .. "s]")
        return
    end

    if table.Count(WARDECLARATION.Attacks.participants) >= 3 then
        ply:notify("A faction has already started a skirmish.")
        return
    end

    local typ = WARDECLARATION.Attacks.type

    if not nut.config.get(typ .. " - Can Assist") then
        ply:notify( "You can not start a skirmish in this type of attack." )
        return
    end

    WARDECLARATION.AddTeam(ply:Team(), ply)
end)

net.Receive( "WARDECLARATION_ATTACKCONFIRMATION", function( len, ply )
    local target = net.ReadInt( 8 )
    local typ = net.ReadString( )

    if ply:CanCallAttack( ) then
        WARDECLARATION.StartAttack( typ, target, ply )
    end
end )

net.Receive("WARDECLARATION_SCOREBOARDCLICK", function(len, ply)
    local typ = net.ReadString( )
    local target = net.ReadInt( 8 )

    if ply:CanCallAttack() then
        net.Start("WARDECLARATION_ATTACKCONFIRMATION")
            net.WriteString(typ)
            net.WriteInt(target, 8)
        net.Send(ply)
    end
end)

net.Receive("WARDECLARATION_SCOREBOARDCANCEL", function(len, ply)
    if ply:CanCallAttack() then
        WARDECLARATION.StopAttack(ply:Team(), ply)
    end
end)

net.Receive("WARDECLARATION_SCOREBOARDASSIST", function(len, ply)
    local target = net.ReadInt( 8 )

    if ply:CanCallAttack() then
        local typ = WARDECLARATION.Attacks.type

        if WARDECLARATION.HasCooldown(ply:Team()) then
            ply:notify("Your faction has an attack cooldown [" .. math.Round(WARDECLARATION.HasCooldown( ply:Team( ) ), 0) .. "s]")
            return
        end

        WARDECLARATION.AssistAttack(target, ply)
        WARDECLARATION.AddCooldown(CurTime() + (nut.config.get(typ .. " - Time") + nut.config.get(typ .. " - Cooldown")), ply:Team())
    end
end)

net.Receive("WARDECLARATION_SCOREBOARDSTOPASSIST", function(len, ply)
    if ply:CanCallAttack() then
        WARDECLARATION.StopAssist(ply, target)
    end
end)

local plyMeta = FindMetaTable( "Player" )

function plyMeta:SyncWarUI( )
    net.Start( "WARDECLARATION_UPDATEUI" )
        jlib.WriteCompressedTable( WARDECLARATION.Attacks )
    net.Send( self )
end

function WARDECLARATION.SyncWarUI()
    net.Start( "WARDECLARATION_UPDATEUI" )
        jlib.WriteCompressedTable( WARDECLARATION.Attacks )
    net.Broadcast()
end

--[[
    STARTING AN ATTACK WITH CERTAIN TYPE DEFINED IN sh_wardeclaration
    @typ : Type of attack, dictated in sh_wardeclaration.
    @faction : Faction that is starting the attack.
]]
function WARDECLARATION.StartAttack( typ, faction, client )
    if not client:CanCallAttack( ) then return end
    if WARDECLARATION.Types[typ] == nil then return end -- Missing type means missing data, return.
    if WARDECLARATION.Types[typ].adminOnly and not client:IsAdmin() then client:notify("You can not use this attack type.") return end
	if isfunction(WARDECLARATION.Types[typ].canDeclare) and WARDECLARATION.Types[typ].canDeclare(client, faction) == false then return end
    if WARDECLARATION.Attacks.calling != nil then client:notify("There is already an attack happening.") return end -- There must already be an attack.
    if faction == client:Team() then return end -- We dont want to attack ourselves
    if WARDECLARATION.IsInAttack( client:Team( ) ) then return end
    if WARDECLARATION.HasCooldown( client:Team( ) ) then client:notify("Your faction has an attack cooldown [" .. math.Round(WARDECLARATION.HasCooldown( client:Team( ) ), 0) .. "s]") return end
	if WARDECLARATION.HasCooldown( faction ) then client:notify("The target faction has an attack cooldown") return end

    if not WARDECLARATION.IsAttackable(faction, typ, client) then
        client:notify("You can not attack this faction.")
        return
    end

	if WARDECLARATION.Types[typ].requiresApproval and ((client.approvedDeclare != WARDECLARATION.Types[typ])) and !client.warReady then
		if client.pendingDeclare then
			client:notify("You already have a pending request")
			return
		end

		local declareType = typ
		local fac = faction
		local ply = client

		jlib.RequestBool("Staff approved request?", function(bool)
			if not bool then
				ply:notify("Contact staff to approve")
				ply.pendingDeclare = WARDECLARATION.Types[typ]
				jlib.Announce(ply, Color(255,0,0), "[WARNING] ", Color(255,155,155), "A staff member must come approve your request to begin the battle")
				return
			end

			jlib.RequestString("Reason for " .. declareType .. "?", function(text)
				if #text < 1 then
					ply:notify("Enter a reason you doofus!")
					jlib.Announce(ply, Color(255,0,0), "[WARNING] ", Color(255,155,155), "Your request has been cancelled due to no reason being submitted")
					return
				end

				jlib.AlertStaff(
					"A '" .. typ .. "' declaration has been requested by: " ..
					"\n· Player: " .. jlib.SteamIDName(ply) ..
					"\n· Faction: " .. team.GetName(ply:Team()) ..
					"\n· Target Faction: " .. nut.faction.indices[fac].name ..
					"\n· Reason: '" .. text .. "'" ..
					"\n\nAn Admin+ is needed to approve this declaration" ..
					"\nEnter '/approvedeclare' while looking @ the requesting player to do so"
				)

				DiscordEmbed(
					"· **Player:** " .. jlib.SteamIDName(ply) ..
					"\n\n· **Requesting Faction:** " .. team.GetName(ply:Team()) ..
					"\n\n· **Target Faction:** " .. nut.faction.indices[fac].name ..
					"\n\n· **Attack Type:** " .. typ ..
					"\n\n· **Reason:**\n```" .. text .. "```" ..
					"\n\n\n **WARNING: **``Leaking this request or using this info is meta-game & will result in immediate demotion & banning from the game.``",
					"📋 Attack Request Log 📋" , Color(255,0,0), "AdminChat"
				)

				ply.pendingDeclare = WARDECLARATION.Types[typ]

				if WARDECLARATION.Types[typ].postRequestFunction != nil then
					WARDECLARATION.Types[typ].postRequestFunction(faction, client)
				end
			end, ply, "Submit")
		end, client, "YES", "NO (Create request)")
		return
	elseif client.approvedDeclare then
		client.approvedDeclare = nil
	end

    if WARDECLARATION.Types[typ].starterFunction != nil then
        if WARDECLARATION.Types[typ].starterFunction(faction, client) == false then return end
    end

    -- Uncomment this if you want the attack requirement to affect the player too.
    --if not WARDECLARATION.IsAttackable(client:Team(), typ) then --
    --    client:notify("You can not attack this faction.")
    --    return
    --end
    -- Enable or disable this if you want the attacked to be immune for a bit.
    --if WARDECLARATION.HasCooldown(faction) then client:notify("The enemy faction has an attack cooldown.") return end

    WARDECLARATION.Attacks = {
        calling = client:Team(), // easy referencing
        enemy = faction,
        participants = { // any other team will be added here inteh same way [team] = {assisters} 
            [client:Team()] = {}, 
            [faction] = {}, 
        },
        assisters = { },
        enemies = { },
        starttime = os.time( ),
        type = typ,
        time = nut.config.get(typ .. " - Time"),
    }

	-- Immersive text/sound effects for battle declaration
	for index, player in pairs(player.GetAll()) do
		WARDECLARATION.PlayAmbience( player )
	end

    -- The time of the attack and the cooldown added together so time has been added afterwards as well.
    -- Enable or disable this if you want the attacked to be immune for a bit. !!SEE ABOVE TOO!!
    --WARDECLARATION.AddCooldown(CurTime() + (nut.config.get(typ .. " - Time") + nut.config.get(typ .. " - Cooldown")), faction)

	-- Create our attack cooldowns
    WARDECLARATION.AddCooldown(CurTime() + (nut.config.get(typ .. " - Time") + nut.config.get(typ .. " - Cooldown")), client:Team())
    WARDECLARATION.AddCooldown(CurTime() + (nut.config.get(typ .. " - Time") + nut.config.get(typ .. " - Cooldown")), faction)

	-- Discord logging
	DiscordEmbed("The " .. nut.faction.indices[client:Team()].name .. " has declared a " .. typ .. " on the " .. nut.faction.indices[faction].name, "☢ BATTLE NOTIFICATION ☢", Color(255,0,0), "IncursionChat")
	DiscordEmbed(jlib.SteamIDName(client) .. " has declared a " .. typ .. " on the " .. nut.faction.indices[faction].name, "💥 Attack Declaration Log 💥" , Color(255, 255, 0), "Admin")

    hook.Run( "WARDECLARATION_StartedAttack", typ, faction, client:Team( ) )
    WARDECLARATION.SyncWarUI()


    local tm = client:Team( )
    local caller = client
    local time = nut.config.get(typ .. " - Time")
    -- Stop the timer

    if typ == "War" or typ == "Conquest" then
        local percent = nut.config.get(typ .. " - Perma NLR Time")
        local permaNLRTime = time - (time * (percent / 100))
        timer.Simple(5, function()
            jlib.Announce(player.GetAll(), Color(255,0,0), "[WAR]", Color(255,255,255), " Perma NLR will start when the timer hits " .. permaNLRTime)
        end)

        timer.Create("AttackTimer", time - permaNLRTime, 1, function()
            jlib.Announce(player.GetAll(), Color(255,0,0), "[WAR]", Color(255,255,255), " Perma NLR has started . . .")
            WARDECLARATION.Attacks.PERMANLR = true
            timer.Create("AttackTimer", permaNLRTime, 1, function()
                WARDECLARATION.StopAttack( tm, caller )
            end)
        end)
    else
        timer.Create( "AttackTimer", time, 1, function( )
            WARDECLARATION.StopAttack( tm, caller )
        end )
    end
end

function WARDECLARATION.AddTeam( faction, client )
    if WARDECLARATION.IsInAttack( faction ) then
        client:notify("You are already part of this battle.")
        return
    end

    if not client:CanCallAttack() then return end

    local canSkirmish = nut.config.get(WARDECLARATION.Attacks.type .. " - Can Skirmish")
    if !canSkirmish then
        client:notify("This type does not support skirmishes.")
        return 
    end

    WARDECLARATION.Attacks.participants[faction] = {}

    net.Start("WARDECLARATION_ADDTEAM")
        net.WriteInt(faction, 8)
    net.Broadcast()

    WARDECLARATION.AddCooldown(CurTime() + (nut.config.get(typ .. " - Time") + nut.config.get(typ .. " - Cooldown")), client:Team())
end

function WARDECLARATION.RemoveTeam(faction)
    if WARDECLARATION.Attacks.calling == faction or WARDECLARATION.Attacks.enemy == faction then return end

    // list of factions who are assisting the faction
    local factionList = WARDECLARATION.Attacks.participants[faction]
    WARDECLARATION.Attacks.participants[faction] = nil

    net.Start("WARDECLARATION_LEAVESKIRMISH")
        net.WriteInt(faction, 8)
        net.WriteTable(factionList)
    net.Broadcast()
end

--[[
    Stop a current attack for a faction. Used in force stopping and whenever an attack is cancelled by a faction.
    Only usable by the faction that started the attack to stop it.
    See WARDECLARATION.StopAssist for assists.

    @faction : Faction that started the attack.
]]
function WARDECLARATION.StopAttack( faction, client )
    if not WARDECLARATION.IsInAttack( faction ) then
        client:notify( "You have not called an attack." )
        return
    end
    if not client:CanCallAttack() then return end

    if WARDECLARATION.Attacks.calling ~= faction then return end
    timer.Remove( "AttackTimer" ) -- Remove the timer as well!
    WARDECLARATION.Attacks = {} -- Remove the faction entry
    WARDECLARATION.SyncWarUI()

    hook.Run("WARDECLARATION_AttackEnded", client, faction)
end

function WARDECLARATION.EndAttack( faction )
    timer.Remove( "AttackTimer" ) -- Remove the timer as well!
    WARDECLARATION.Attacks = {} -- Remove the faction entry
    WARDECLARATION.SyncWarUI()


    for k, v in ipairs(WARDECLARATION.Flags) do
        if IsValid(v) then
            v:Remove()
        end
    end

    WARDECLARATION.Flags = nil
    hook.Run("WARDECLARATION_AttackEnded", client, faction)
end

--[[
    ASSISTING AN ATTACK
    @faction : THE FACTION TO ASSIST,
    @callerFaction : THE FACTION ASSISTING faction.
]]
function WARDECLARATION.AssistAttack( faction, ply )
    if table.IsEmpty(WARDECLARATION.Attacks) then
        ply:notify("There is currently no attack happening.")
        return
    end

    if not WARDECLARATION.IsInAttack( faction ) then
        ply:notify("The faction is not in an attack.")
        return
    end

    if WARDECLARATION.IsInAttack( ply:Team( ) ) then
        ply:notify( "You are already in an attack." )
        return
    end

    if not nut.config.get(WARDECLARATION.Attacks.type .. " - Can Assist") then
        ply:notify( "You can not assist in this type of attack." )
        return
    end

    if WARDECLARATION.Attacks.participants[faction] == nil then 
        ply:notify("That faction is not a main attacker.")
        return
    end

    // assisting
    WARDECLARATION.Attacks.participants[faction][ply:Team()] = true
    net.Start( "WARDECLARATION_ADDASSISTER" )
        net.WriteInt( faction, 8 ) // faction to assist
        net.WriteInt( ply:Team( ), 8 ) // team that is assisting
    net.Broadcast( )

    //WARDECLARATION.SyncWarUI()
end

--[[
    STOP ASSIST
    @ply : The player calling to stop the assist or leave as a main faction,
]]
function WARDECLARATION.StopAssist( ply )

    local plyfac = ply:Team()
    
    if not WARDECLARATION.IsInAttack( plyfac ) then return end
    if WARDECLARATION.Attacks.enemy == plyfac or WARDECLARATION.Attacks.calling == plyfac then return end

    for k, v in pairs(WARDECLARATION.Attacks.participants) do
        if v[plyfac] then
            v[plyfac] = nil
            
            net.Start( "WARDECLARATION_REMOVEASSISTER" )
                net.WriteInt( plyfac, 8 )
            net.Broadcast( )
            
            //WARDECLARATION.SyncWarUI()
            break
        end
    end

    return false
end

function WARDECLARATION.AddCooldown( time, faction )
    if WARDECLARATION.Cooldowns[faction] != nil then return end
    WARDECLARATION.Cooldowns[faction] = time
end

function WARDECLARATION.HasCooldown( faction )
    if WARDECLARATION.Cooldowns[faction] == nil then return end

    if WARDECLARATION.Cooldowns[faction] >= CurTime() then
        return WARDECLARATION.Cooldowns[faction] - CurTime()
    end

    if WARDECLARATION.Cooldowns[faction] <= CurTime() then
        WARDECLARATION.Cooldowns[faction] = nil -- Remove the cooldown
        return false
    end

    return false
end

-- PlayerInitialSpawn is not very reliable with networking so we do it this way instead + icons load properly
hook.Add("PlayerLoadedChar", "WARDECLARATION_LoadCharRetrieve", function(client, new, old)
    if old == nil and WARDECLARATION.Attacks.calling != nil then
        client:SyncWarUI()
    end
end)

hook.Add("InitPostEntity", "WARDECLARATION_Setup", function()
    WARDECLARATION.Attacks = { }
    WARDECLARATION.Cooldowns = { }

    WARDECLARATION.LoadPoints()
    WARDECLARATION.LoadReasons()
end)


net.Receive("WARDECLARATION_RequestFlagSpots", function(len, ply)
    net.Start("WARDECLARATION_RequestFlagSpots")
        jlib.WriteCompressedTable(WARDECLARATION.Points)
    net.Send(ply)
end)

function WARDECLARATION.RemoveFlag(flag, ply)
    if WARDECLARATION.Points[flag] == nil then return end
    WARDECLARATION.Points[flag] = nil
    WARDECLARATION.SavePoints()

    net.Start("WARDECLARATION_RemoveWarFlag")
        net.WriteInt(flag, 8)
    net.Send(ply)
end

net.Receive("WARDECLARATION_REQUESTREASONS", function(len, ply)
    local data = WARDECLARATION.WarReasons[ply:Team()]
    if !data then return end

    net.Start("WARDECLARATION_REQUESTREASONS")
        jlib.WriteCompressedTable(data)
    net.Send(ply)
end)

net.Receive("WARDECLARATION_ACTIVATEWARREASON", function(len, ply)
    if ply.warReady then return end
    if !hcWhitelist.isHC(ply) then return end

    local fac = net.ReadInt(8)
    local id = net.ReadInt(6)
    
    WARDECLARATION.WarReasons[ply:Team()][fac][id] = nil

    if #WARDECLARATION.WarReasons[ply:Team()][fac] == 0 then
        WARDECLARATION.WarReasons[ply:Team()][fac] = nil
    end

    ply.warReady = fac
    ply:falloutNotify("[WAR] You have activated a war reason . . .", "ui/ui_experienceup.mp3")
    DiscordEmbed( ply:getChar():getName() .. " has activated a war reason on " .. nut.faction.indices[fac].name, "War Reason Activation Log", Color(255, 0, 0), "Admin")
end)

net.Receive("WARDECLARATION_HOSTILITIESRESET", function(len, ply)
    if !WARDECLARATION.IsInAttack(ply:Team()) then return end
    ply:Kill()

    local zone = Dismemberment.GetDismembermentZone(HITGROUP_HEAD)
    Dismemberment.Dismember(ply, zone.Bone, zone.Attachment, zone.ScaleBones, zone.Gibs, IsValid(ply) and ply:GetForward() or VectorRand())

end)


local function getRandomSpawn(id)
	local ownedAreas = Areas.GetOwnership(id)
	if (ownedAreas) then
		local posSpawns = {}
		-- Finds all the areas that have spawns in the list.
		for k, area in pairs(ownedAreas) do
			local spawns = area:GetSpawns()
			if (!table.IsEmpty(spawns)) then
				posSpawns[#posSpawns + 1] = area
			end
		end

		-- Selects a random area and then selects a random spawn from it.
		local randomArea = table.Random(posSpawns)

		if (randomArea) then
			local randomSpawn = table.Random(randomArea:GetSpawns())

			if (randomSpawn) then
				return randomSpawn
			end
		end
	end
end

hook.Add("PlayerLoadout", "WARDEC_PermaNLREnable", function(ply)
    if WARDECLARATION.Attacks.PERMANLR and WARDECLARATION.IsInAttack(ply:Team()) then
        ply:falloutNotify("[!] You have been ghosted. (PERMA NLR)")
        ply:GodEnable()
        ply:SetRenderMode(RENDERMODE_TRANSCOLOR)
        ply:SetColor(Color(255, 255, 255, 150))
        ply.PermaNLR = true

        local spawnLocation = getRandomSpawn(nut.faction.indices[ply:Team()].uniqueID)
        local distSqr = 600 * 600
        if !ply:IsAdmin() then
            timer.Create(ply:EntIndex() .. "-DistPermaNLR", 3, 0, function()
                if !IsValid(ply) or !WARDECLARATION.IsInAttack(ply:Team()) then
                    timer.Remove(ply:EntIndex() .. "-DistPermaNLR")
                    return
                end
                
                if ply:GetPos():DistToSqr(spawnLocation) > distSqr then
                    ply:SetPos(spawnLocation)
                    ply:falloutNotify("[!] You can not go that far from spawn.")
                end
            end)
        else
            jlib.Announce(ply, Color(255, 0, 0), "[WAR] ", Color(255, 255, 255), "You are immune to PermaNLR effects due to staff duties, do not abuse this.")
        end
    elseif !WARDECLARATION.Attacks.PERMANLR and ply.PermaNLR then
        ply:falloutNotify("[!] You have been un-ghosted.")
        ply:GodDisable()
        ply:SetRenderMode(RENDERMODE_NORMAL)
        ply.PermaNLR = nil

        timer.Remove(ply:EntIndex() .. "-DistPermaNLR")
        hook.Run("PlayerLoadout", ply)
    end
end)

// Just copied from spawnrpotect
hook.Add("EntityTakeDamage", "WARDEC_PermaNLRDamageNegation", function(ent, dmg)
    local attacker = dmg:GetAttacker()
    if IsValid(attacker) and attacker:IsPlayer() and attacker.PermaNLR then
        ent:falloutNotify("That player is ghosted due to PermaNLR.")
        return true
    end
end)

hook.Add( "WeaponEquip", "WARDEC_DisableWeapon", function( weapon, ply )
    if ply.PermaNLR and WARDECLARATION.IsInAttack(ply:Team()) and !ply:IsAdmin() then
        weapon:Remove()

        if !isnumber(ply.nextwepequipnotif) or ply.nextwepequipnotif < CurTime() then
            ply:falloutNotify("You can not equip any SWEPs whilst ghosted.")
        end

        ply.nextwepequipnotif = CurTime() + 1
    end
end )

hook.Add("PlayerUse", "WARDEC_DisableUse", function(ply, ent)
    if ply.PermaNLR and WARDECLARATION.IsInAttack(ply:Team()) and !ply:IsAdmin() then
        if ply.nextpermanlrnotification != nil and ply.nextpermanlrnotification > CurTime() then return false end 
        
        ply:falloutNotify("You can not interact with anything whilst ghosted.")
        ply.nextpermanlrnotification = CurTime() + 3
        return false
    end
end)

hook.Add("WARDECLARATION_AttackEnded", "WARDEC_DisableGhosting", function(ply, faction)
    if WARDECLARATION.Flags == nil or #WARDECLARATION.Flags <= 0 then return end
    for k, v in ipairs(WARDECLARATION.Flags) do
        if IsValid(v) then
            v:Remove()
        end
    end
    WARDECLARATION.Flags = {}

    for k, v in ipairs(player.GetAll()) do
        if v.PermaNLR then
            ply:falloutNotify("[!] You have been un-ghosted.")
            ply:GodDisable()
            ply:SetRenderMode(RENDERMODE_NORMAL)
            ply.PermaNLR = nil

            timer.Remove(ply:EntIndex() .. "-DistPermaNLR")
            hook.Run("PlayerLoadout", ply)
        end
    end
end)