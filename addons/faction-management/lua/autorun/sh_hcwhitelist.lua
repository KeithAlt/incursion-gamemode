hcWhitelist = hcWhitelist or {}
hcWhitelist.config = hcWhitelist.config or {}
hcWhitelist.motds = hcWhitelist.motds or {}
hcWhitelist.idCache = hcWhitelist.idCache or {}
include("hcwhitelist_config.lua")

function hcWhitelist.consoleLog(msg, force)
    if force or hcWhitelist.config.debug then
        MsgC(Color(255, 178, 0), "[hcWhitelist] ", Color(255, 255, 255), msg .. "\n")
    end
end

hcWhitelist.Print = jlib.GetPrintFunction("[Faction Manager Log]", Color(0, 100, 255, 255))

hcWhitelist.FactionDeployables = {
/**
    ["uniqueid"] = {
        name = "Base Controller",
        model = "models/props_borealis/bluebarrel001.mdl",
        faction = FACTION_TALON,
        ent = "alydusbasesystems_basecontroller",
        canUse = function()
            return false
        end,
        callback = function(deploy, ply)
            print("callback")
            print(deploy, ply)
        end,
    },
**/
}

function hcWhitelist.log(msg, hcSteamID, targetSteamID, forceConsole)
    hcWhitelist.consoleLog(msg, forceConsole)
    if SERVER then
        local time = os.time()
        local logs = util.JSONToTable(file.Read("hcwhitelistlogs.txt") or "") or {}

        logs[#logs + 1] = {
            ["time"] = time,
            ["hcSteamID"] = hcSteamID,
            ["targetSteamID"] = targetSteamID,
            ["action"] = msg
        }

        while #logs > 3500 do
            table.remove(logs, 1)
        end

        local json = util.TableToJSON(logs)
        file.Write("hcwhitelistlogs.txt", json)
    else
        --If we're on the client just send the info to the server
        net.Start("hcLog")
            net.WriteString(msg)
            net.WriteString(hcSteamID)
            net.WriteString(targetSteamID)
            net.WriteBool(forceConsole)
        net.SendToServer()
    end
end
net.Receive("hcLog", function(len, ply)
    if !hcWhitelist.isNCO(ply) or !hcWhitelist.isHC(ply) then return end
    local msg           = net.ReadString()
    local hcSteamID     = net.ReadString()
    local targetSteamID = net.ReadString()
    local forceConsole  = net.ReadString()
    hcWhitelist.log(msg, hcSteamID, targetSteamID, forceConsole)
end)

function hcWhitelist.isHC(ply)
    return !ply:IsBot() and (nut.class.list[ply:getChar():getClass()].Officer or ply:IsSuperAdmin())
end

function hcWhitelist.isNCO(ply)
	return !ply:IsBot() and (hcWhitelist.isHC(ply) or nut.class.list[ply:getChar():getClass()].NCO)
end

function hcWhitelist.canOpenDeployable(ply)
    return true
end

function hcWhitelist.isCreature(ply)
	local class = ply:getChar():getClass()

	if class then
		return nut.class.list[class].IsCreature
	end
end

function hcWhitelist.isMutant(ply)
	local class = ply:getChar():getClass()

	if class then
		return nut.class.list[class].IsMutant
	end
end

function hcWhitelist.isRobot(ply)
	local class = ply:getChar():getClass()

	if class then
		return nut.class.list[class].IsRobot
	end
end

-- Kind of crude, checks if they are not a robot, mutant, or creature.
function hcWhitelist.isHuman(ply)
	local class = ply:getChar():getClass()

	if class then
		return !(nut.class.list[class].IsRobot or nut.class.list[class].IsMutant or nut.class.list[class].IsCreature)
	else --default to true if no class
		return true
	end
end

function hcWhitelist.getClasses(faction) --Get all classes associated with a given faction
    local classes = {}
    for i = 1, #nut.class.list do
        local class = nut.class.list[i]

        if class.faction == faction then
            classes[#classes + 1] = class
        end
    end
    return classes
end

function hcWhitelist.uniqueIDToID(uniqueID) --Get a class numeric ID from the uniqueID
	if hcWhitelist.idCache[uniqueID] then
		return hcWhitelist.idCache[uniqueID]
	end

    for i = 1, #nut.class.list do
        local class = nut.class.list[i]
        if class.uniqueID == uniqueID then
			hcWhitelist.idCache[uniqueID] = i
            return i
        end
    end
end

function hcWhitelist.getDefaultClass(faction) --Gets default class of a given faction
    for i = 1, #nut.class.list do
        local class = nut.class.list[i]

        if class.faction == faction and class.isDefault then
            return class
        end
    end
end

function hcWhitelist.getMOTD(uniqueID)
    return hcWhitelist.motds[uniqueID]
end

hook.Add("InitPostEntity", "hcWhiteInit", function() --ns will be ready by this point
    hcWhitelist.consoleLog("Loading commands", true)

    nut.command.add("factionmanagement", {
        syntax = "",
        onRun = function(ply, args)
            if !ply:IsSuperAdmin() and !hcWhitelist.isNCO(ply) then --Check they are an HC class
                ply:notify("You must be a high command member of your current faction to do this!")
                return
            end

            local timeRemaining = (ply.nextHCOpen or 0) - CurTime()

            if ply:IsSuperAdmin() then
                timeRemaining = 0
            end

            if timeRemaining > 0 then --Only allow them to use this command once every 30s
                ply:notify("You must wait " .. math.Round(timeRemaining) .. "s before you can use this command again.")
                return
            end

            ply.nextHCOpen = CurTime() + 30

            local faction = nut.faction.indices[ply:getChar():getFaction()].uniqueID
            hcWhitelist.GetFactionMembers(faction, ply)
        end
    })

    nut.command.add("factionmotd", {
        syntax = "",
        onRun = function(ply, args)
            net.Start("hcShowMOTD")
            net.Send(ply)
        end
    })

    nut.command.add("factionmanagementlogs", {
        syntax = "",
        superAdminOnly = true,
        onRun = function(ply, args)
            if !ply:IsSuperAdmin() then return end

            local json = file.Read("hcwhitelistlogs.txt")

            if !json then
                ply:notify("No logs found!")
                return
            end

            local data = util.Compress(json)
            local len  = #data

            net.Start("hcViewLogs")
                net.WriteUInt(len, 32)
                net.WriteData(data, len)
            net.Send(ply)
        end
    })

    nut.command.add("fixclasses", {
        syntax = "",
        superAdminOnly = true,
        onRun = function(ply, args)
            hcWhitelist.fixClasses()
        end
    })

    nut.command.add("checknodefault", {
        syntax = "",
        superAdminOnly = true,
        onRun = function(ply, args)
            for _, faction in pairs(nut.faction.indices) do
                if !hcWhitelist.getDefaultClass(faction.index) then
                    local str = "Faction " .. faction.name .. " does not have a default class"
                    hcWhitelist.consoleLog(str, true)
                    ply:ChatPrint(str)
                end
            end
        end
    })

    nut.command.add("managefaction", {
        syntax = "<faction uniqueID>",
        superAdminOnly = true,
        onRun = function(ply, args)
            local uniqueID = args[1]
            local faction = nut.faction.teams[uniqueID]

            if !faction then
                ply:ChatPrint("No faction found with uniqueID " .. uniqueID)
            end

            hcWhitelist.GetFactionMembers(faction.uniqueID, ply)
        end
    })

    nut.command.add("setbenchspawn", { -- Set a workbench "spawn bool" manually
        syntax = "<true / false>",
        superAdminOnly = true,
        onRun = function(ply, args)
			local id = tonumber(args[1]) or false
            local bool = tobool(args[2]) or false

			if !isnumber(id) then
				jlib.Announce(ply, Color(255,0,0), "[WARNING] ", Color(255,200,200), "Your 1st command argument must be workbench ID number!")
				return
			elseif !isbool(bool) then
				jlib.Announce(ply, Color(255,0,0), "[WARNING] ", Color(255,200,200), "Your 2nd command argument must be a true or false!")
				return
			end

			for edicts, ent in pairs(ents.FindByClass("workbench")) do
				if ent.benchID and ent.benchID == id then

					jlib.RequestBool("Workbench[#" .. id .. "] exists! Continue?", function(confirmBool)
						if !confirmBool then return end

						ent:Remove()
						jlib.Announce(ply, Color(255,0,0), "[NOTICE] ", Color(255,200,200), "You sent the workbench back to the faction armory")
						DiscordEmbed(ply:Nick() .. " ( " .. ply:SteamID() .. " ) has toggled the spawn state of workbench[" .. id .. "] to: " .. tostring(bool):upper() .. " ( manually)", "🔧 Workbench Spawn Toggle Log 🔧", Color(255, 125, 0, 255), "Admin")

					end, ply, "YES (SET:" .. tostring(bool):upper() .. ")", "NO (CANCEL)")

					return
				end
			end

			Workbenches.ChangeSpawnStateByID(id, bool)
			jlib.Announce(ply, Color(255,0,0), "[NOTICE] ", Color(255,200,200), "You set the spawn state of workbench[#" .. id .. "] to: " .. tostring(bool))
			DiscordEmbed(ply:Nick() .. " ( " .. ply:SteamID() .. " ) has toggled the spawn state of workbench[" .. id .. "] to: " .. tostring(bool):upper() .. " ( manually)", "🔧 Workbench Spawn Toggle Log 🔧", Color(255, 125, 0, 255), "Admin")
        end
    })

    nut.command.add("setstoragespawn", { -- Set a faction storage "spawn bool" manually
        syntax = "<true / false>",
        superAdminOnly = true,
        onRun = function(ply, args)
			local id = tonumber(args[1]) or false
            local bool = tobool(args[2]) or false

			if !isnumber(id) then
				jlib.Announce(ply, Color(255,0,0), "[WARNING] ", Color(255,200,200), "Your 1st command argument must be storage ID number!")
				return
			elseif !isbool(bool) then
				jlib.Announce(ply, Color(255,0,0), "[WARNING] ", Color(255,200,200), "Your 2nd command argument must be a true or false!")
				return
			end

			for edicts, ent in pairs(ents.FindByClass("faction-storage")) do
				if ent.ID and ent.ID == id then

					jlib.RequestBool("Storage[#" .. id .. "] exists! Continue?", function(confirmBool)
						if !confirmBool then return end

						ent:Remove()

						jlib.Announce(ply, Color(255,0,0), "[NOTICE] ", Color(255,200,200), "You sent the faction storage back to the faction armory")
						DiscordEmbed(ply:Nick() .. " ( " .. ply:SteamID() .. " ) has toggled the spawn state of storage[" .. id .. "] to: " .. tostring(bool):upper() .. " ( manually)", "🔧 Faction Storage Spawn Toggle Log 🔧", Color(255, 125, 0, 255), "Admin")

					end, ply, "YES (SET:" .. tostring(bool):upper() .. ")", "NO (CANCEL)")

					return
				end
			end

			FactionStorage.toggleStorSpawnByID(id, bool)
			jlib.Announce(ply, Color(255,0,0), "[NOTICE] ", Color(255,200,200), "You set the spawn state of storage[#" .. id .. "] to: " .. tostring(bool))
			DiscordEmbed(ply:Nick() .. " ( " .. ply:SteamID() .. " ) has toggled the spawn state of storage[" .. id .. "] to: " .. tostring(bool):upper() .. " ( manually)", "🔧 Faction Storage Spawn Toggle Log 🔧", Color(255, 125, 0, 255), "Admin")
        end
    })

	if SERVER then -- Initialize deployable tables
		hcWhitelist.initalizeDeployables()
	end
end)

--Add options to context menu
properties.Add("hcWhitelist", {
    ["MenuLabel"] = "Recruit into faction",
    ["MenuIcon"] = "icon16/accept.png",
    ["Order"] = 10001,
    ["PrependSpacer"] = true,
    ["Filter"] = function(self, ent)
        return ent:IsPlayer() and hcWhitelist.isNCO(LocalPlayer()) and LocalPlayer():getChar():getFaction() != ent:getChar():getFaction()
    end,
    ["MenuOpen"] = function(self, option, ent, tr)
        option:SetText("Recruit into " .. nut.faction.indices[LocalPlayer():getChar():getFaction()].name)
    end,
    ["Action"] = function(self, ent, tr)
		local frame = vgui.Create("DFrame")
        frame:SetTitle("Select a Class")
        frame:SetSize(450, 125)
        frame:Center()
        frame:MakePopup()
        frame:SetBackgroundBlur(true)

        local selection = vgui.Create("DComboBox", frame)
        selection:SetValue("Classes")
        selection:SetWide(130)
        selection:Center()

        local classes = hcWhitelist.getClasses(LocalPlayer():getChar():getFaction())
        for i = 1, #classes do
            local class = classes[i]

			if hcWhitelist.isHC(LocalPlayer()) or (hcWhitelist.isNCO(LocalPlayer()) and !class.NCO and !class.Officer) then
				selection:AddChoice(class.name, class.index)
			end
        end

        local confirm = vgui.Create("DButton", frame)
        confirm:SetText("OK")
        confirm:Center()
        confirm:MoveBelow(selection, 10)
        confirm.DoClick = function(s)
            local _, classID = selection:GetSelected()
            if !classID then -- If no class ID, send a -1 to show that there is no class selected.
				classID = -1
            end

            self:MsgStart()
                net.WriteEntity(ent)
                net.WriteInt(classID, 32)
            self:MsgEnd()

            frame:Close()
        end
    end,
    ["Receive"] = function(self, len, ply)
        local target = net.ReadEntity()
		local classID = net.ReadInt(32)

        if IsValid(target) and target:IsPlayer() and hcWhitelist.isNCO(ply) then
            if ply:getChar():getFaction() == target:getChar():getFaction() then
                ply:notify("This player is already a member of your faction!")
                return
            end

			local class
			if(classID != -1) then
				class = nut.class.list[classID]

				-- Verifies that they can be transferred into the faction. If they cannot, notifies user.
				local failed = false
				if class.IsMutant and !hcWhitelist.isMutant(target) then -- Only mutants can go into mutant classes.
					failed = true
				elseif class.IsRobot and !hcWhitelist.isRobot(target) then -- Only robots can go into robot classes.
					failed = true
				elseif class.IsCreature and !hcWhitelist.isCreature(target) then -- Only creatures can go into creature classes.
					failed = true
				end

				-- Failure notification
				if(failed) then
					jlib.Announce(ply, Color(255,0,0), "[NOTICE] ", Color(255,155,155), "You cannot transfer players to a class that doesn't match their species/race!\n· Humans cannot be class transfered into a Creature, Robot or Super Mutant class and vice versa\n· Players can be transformed into a desired species via a transformer in the world\n· If this is a mistake please contact staff")
					return
				end
			end

			-- Faction changing
            local faction = nut.faction.indices[ply:getChar():getFaction()]

            hcWhitelist.setFaction(target:getChar():getID(), faction.uniqueID, ply)

			-- Class changing, can't do this before faction changing so it's awkwardly down here.
			if(class) then
				if classID == target:getChar():getClass() then
					ply:notify(target:Nick() .. " is already a " .. class.name .. "!")
					return
				end

				hcWhitelist.setClass(target:getChar():getID(), classID, ply)
			end

			local className = (class and class.name) or "Unclassed"
            ply:notify("Successfully transfered to " .. faction.name .. " as " .. className .. ".")
            target:notify(ply:Nick() .. " has transfered you to " .. faction.name .. " as " .. className .. ".")
			hcWhitelist.log(ply:Nick() .. " has changed " .. target:Nick() .. "'s faction to " .. faction.uniqueID .. " and class to " .. className, ply:SteamID64(), target:SteamID64(), true)
        end
    end
})

properties.Add("hcKick", {
    ["MenuLabel"] = "Discharge from faction",
    ["MenuIcon"] = "icon16/delete.png",
    ["Order"] = 10001,
    ["PrependSpacer"] = true,
    ["Filter"] = function(self, ent)
        return ent:IsPlayer() and hcWhitelist.isNCO(LocalPlayer()) and LocalPlayer():getChar():getFaction() == ent:getChar():getFaction()
    end,
    ["MenuOpen"] = function(self, option, ent, tr)
        option:SetText("Discharge from " .. nut.faction.indices[LocalPlayer():getChar():getFaction()].name)
    end,
    ["Action"] = function(self, ent, tr)
        self:MsgStart()
            net.WriteEntity(ent)
        self:MsgEnd()
    end,
    ["Receive"] = function(self, len, ply)
        local target = net.ReadEntity()

        if IsValid(target) and target:IsPlayer() and hcWhitelist.isNCO(ply) then
            if ply:getChar():getFaction() != target:getChar():getFaction() then
                ply:notify("This player is not a member of your faction!")
                return
            end

            local faction = nut.faction.teams.wastelander

            hcWhitelist.setFaction(target:getChar():getID(), faction.uniqueID, ply)
            hcWhitelist.log(ply:Nick() .. " has changed " .. target:Nick() .. "'s faction to " .. faction.uniqueID, ply:SteamID64(), target:SteamID64(), true)

            ply:notify("Successfully transfered to " .. faction.name .. ".")
            target:notify(ply:Nick() .. " has transfered you to " .. faction.name .. ".")
        end
    end
})

properties.Add("hcRename", {
    ["MenuLabel"] = "Rename",
    ["MenuIcon"] = "icon16/page_edit.png",
    ["Order"] = 10002,
    ["Filter"] = function(self, ent)
        return ent:IsPlayer() and hcWhitelist.isNCO(LocalPlayer()) and nut.faction.indices[ent:getChar():getFaction()].uniqueID == nut.faction.indices[LocalPlayer():getChar():getFaction()].uniqueID
    end,
    ["Action"] = function(self, ent, tr)
        self:MsgStart()
            net.WriteEntity(ent)
        self:MsgEnd()
    end,
    ["Receive"] = function(self, len, ply)
        local target = net.ReadEntity()

        if IsValid(target) and target:IsPlayer() and hcWhitelist.isNCO(ply) and nut.faction.indices[target:getChar():getFaction()].uniqueID == nut.faction.indices[ply:getChar():getFaction()].uniqueID then
            ply:requestString("Rename", "New Name", function(text)
                hcWhitelist.log(ply:Nick() .. " changed " .. target:Nick() .. "'s name to " .. text .. ".", ply:SteamID64(), target:SteamID64(), true)

                ply:notify("Successfully changed " .. target:Nick() .. "'s name to " .. text .. ".")

                hcWhitelist.setName(target:getChar():getID(), text, ply)
            end, target:Nick())
        end
    end
})

properties.Add("hcClassChange", {
    ["MenuLabel"] = "Change class",
    ["MenuIcon"] = "icon16/user_edit.png",
    ["Order"] = 10003,
    ["Filter"] = function(self, ent)
		return ent:IsPlayer() and hcWhitelist.isNCO(LocalPlayer()) and nut.faction.indices[ent:getChar():getFaction()].uniqueID == nut.faction.indices[LocalPlayer():getChar():getFaction()].uniqueID
    end,
    ["Action"] = function(self, ent, tr)
        local frame = vgui.Create("DFrame")
        frame:SetTitle("Select a Class")
        frame:SetSize(450, 125)
        frame:Center()
        frame:MakePopup()
        frame:SetBackgroundBlur(true)

        local selection = vgui.Create("DComboBox", frame)
        selection:SetValue("Classes")
        selection:SetWide(130)
        selection:Center()

        local classes = hcWhitelist.getClasses(LocalPlayer():getChar():getFaction())
        for i = 1, #classes do
            local class = classes[i]

			if hcWhitelist.isHC(LocalPlayer()) or (hcWhitelist.isNCO(LocalPlayer()) and !class.NCO and !class.Officer) then
				selection:AddChoice(class.name, class.index)
			end
        end

        local confirm = vgui.Create("DButton", frame)
        confirm:SetText("OK")
        confirm:Center()
        confirm:MoveBelow(selection, 10)
        confirm.DoClick = function(s)
            local _, classID = selection:GetSelected()
            if !classID then
                frame:Close()
                return
            end

            self:MsgStart()
                net.WriteEntity(ent)
                net.WriteInt(classID, 32)
            self:MsgEnd()

            frame:Close()
        end
    end,
    ["Receive"] = function(self, len, ply)
        local target = net.ReadEntity()
        local classID = net.ReadInt(32)

        if IsValid(target) and target:IsPlayer() and hcWhitelist.isNCO(ply) and nut.faction.indices[target:getChar():getFaction()].uniqueID == nut.faction.indices[ply:getChar():getFaction()].uniqueID then
            local class = nut.class.list[classID]

            if classID == target:getChar():getClass() then
                ply:notify(target:Nick() .. " is already a " .. class.name .. "!")
                return
            end

			-- Verifies that they can be transferred into the faction. If they cannot, notifies user.
			local failed = false
			if class.IsMutant and !hcWhitelist.isMutant(ply) then -- Only mutants can go into mutant classes.
				failed = true
			elseif class.IsRobot and !hcWhitelist.isRobot(ply) then -- Only robots can go into robot classes.
				failed = true
			elseif class.IsCreature and !hcWhitelist.isCreature(ply) then -- Only creatures can go into creature classes.
				failed = true
			end

			-- Failure notification
			if(failed) then
				jlib.Announce(ply, Color(255,0,0), "[NOTICE] ", Color(255,155,155), "You cannot transfer players to a class that doesn't match their species/race!\n· Humans cannot be class transfered into a Creature, Robot or Super Mutant class and vice versa\n· Players can be transformed into a desired species via a transformer in the world\n· If this is a mistake please contact staff")
				return
			end

            hcWhitelist.setClass(target:getChar():getID(), classID, ply)

            target:notify(ply:Nick() .. " has changed your class to " .. class.name .. ".")
            ply:notify("Successfully changed " .. target:Nick() .. "'s class to " .. class.name .. ".")

            hcWhitelist.log(ply:Nick() .. " has changed " .. target:Nick() .. "'s class to " .. class.name, ply:SteamID64(), target:SteamID64(), true)
        end
    end
})
