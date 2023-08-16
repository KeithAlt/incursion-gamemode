factionStoreConfig = {}
include("factionstore_config.lua")

hook.Add("InitPostEntity", "RegisterFactionStore", function()
    nut.item.registerInv("factionstore", factionStoreConfig.InvW, factionStoreConfig.InvH)
end)

function IsStaffFaction(ply)
    return nut.faction.indices[ply:getChar():getFaction()].uniqueID
end

local function IsOfficer(ply, ent) -- Is the player either an acceptable officer or a superadmin
	if ent:GetClass() != "faction-storage" then return false end
	return (ent:GetClasses() and ent:GetClasses()[ply:getChar():getClass()] and hcWhitelist.isHC(ply)) or ply:IsSuperAdmin() or false
end

properties.Add("FSUpdate", {
    ["MenuLabel"] = "Save position",
    ["MenuIcon"] = "icon16/arrow_refresh.png",
    ["Order"] = 10001,
    ["Filter"] = function(self, ent, ply)
		return IsOfficer(ply, ent)
    end,
    ["Action"] = function(self, ent, tr)
        self:MsgStart()
            net.WriteEntity(ent)
        self:MsgEnd()
    end,
    ["Receive"] = function(self, len, ply)
		local ent = net.ReadEntity()

		if not (ent:GetClasses() and ent:GetClasses()[ply:getChar():getClass()] and hcWhitelist.isHC(ply)) and not ply:IsSuperAdmin() then return end

        local id = ent.ID

        if !id then
			ply:notify("Can't update position of unconfigured faction storage")
			return
		end

		jlib.RequestBool("Save current faction storage position?", function(bool)
			if !bool then return end

			ply:SelectWeapon("nut_hands" or ply:GetWeapons()[1]) -- Addresses a physgun click annoyance issue

			jlib.Announce(ply, Color(255,255,0), "[INFORMATION]", Color(0,255,0), " Succesfully ", Color(255,255,155), "saved faction storage position!", Color(255,255,255), "\n· Your storage will now remain here until stowed")
			ply:notify("Faction storage postion saved")
			ent:EmitSound("ui/ui_items_gunsbig_up.mp3")
			sql.Query("UPDATE nut_factionstore SET pos = '" .. ent:GetPosSerialized() .. "', ang = '" .. ent:GetAngSerialized() .. "' WHERE _id = " .. id)
			DiscordEmbed(jlib.SteamIDName(ply) .. " has saved a faction storage [#" .. id .. "] into the world", "Faction Storage Save Log" , Color(255,255,0), "Admin")

		end, ply, "YES (SAVE)", "NO (CANCEL)")

    end
})

properties.Add("FSConfig", {
    ["MenuLabel"] = "[ADMIN] Configure",
    ["MenuIcon"] = "icon16/cog.png",
    ["Order"] = 10001,
    ["Filter"] = function(self, ent, ply)
		if ent:GetClass() != "faction-storage" then return false end
        return ply:IsSuperAdmin()
    end,
    ["Action"] = function(self, ent, tr)
        self:MsgStart()
            net.WriteEntity(ent)
        self:MsgEnd()
    end,
    ["Receive"] = function(self, len, ply)
        if !ply:IsSuperAdmin() then return end

        local ent = net.ReadEntity()

		if SERVER then
			net.Start("openFSConfigMenu")
				net.WriteEntity(ent)
			net.Send(ply)
		end
    end
})

properties.Add("FSStow", {
    ["MenuLabel"] = "Stow in Armory",
    ["MenuIcon"] = "icon16/door_in.png",
    ["Order"] = 10001,
    ["Filter"] = function(self, ent, ply)
		return IsOfficer(ply, ent)
    end,
    ["Action"] = function(self, ent, tr)
        self:MsgStart()
            net.WriteEntity(ent)
        self:MsgEnd()
    end,
    ["Receive"] = function(self, len, ply)
        local ent = net.ReadEntity()
        local id = ent.ID

        if !id then
			ply:notify("Can't stow an unconfigured faction storage")
			return
		end

		jlib.RequestBool("Stow your faction storage?", function(bool)
			if !bool then return end
			jlib.Announce(ply, Color(255,255,0), "[INFORMATION]", Color(0,255,0), " Succesfully ", Color(255,255,155), "stowed faction storage!", Color(255,255,255), "\n· Your storage and it's items can be re-deployed via the /factionmanagement menu")
			ply:notify("Faction storage has been stowed")
			ent:EmitSound("ui/ui_items_gunsbig_down.mp3")

			local pos = ent:GetPos()
			local effectdata = EffectData()
			effectdata:SetOrigin( pos )
			util.Effect( "flash_smoke", effectdata )

			ent:Remove()
			DiscordEmbed(jlib.SteamIDName(ply) .. " has stowed faction storage [#" .. id .. "] into their faction armory", "Faction Storage Stow Log" , Color(255,255,0), "Admin")
		end, ply, "YES (STOW)", "NO (CANCEL)")

    end
})

properties.Add("FSDelete", {
    ["MenuLabel"] = "[ADMIN] Delete from Database",
    ["MenuIcon"] = "icon16/cancel.png",
    ["Order"] = 10001,
    ["Filter"] = function(self, ent, ply)
		return ent:GetClass() == "faction-storage" and ply:IsSuperAdmin()
    end,
    ["Action"] = function(self, ent, tr)
        self:MsgStart()
            net.WriteEntity(ent)
        self:MsgEnd()
    end,
    ["Receive"] = function(self, len, ply)
		if !ply:IsSuperAdmin() then return end

        local ent = net.ReadEntity()
        local id = ent.ID

        if !id then
			ply:notify("Can't purge an unconfigured faction storage")
			return
		end

		jlib.RequestBool("This will FULLY delete the entity & data", function(bool)
			if !bool then return end
			jlib.RequestBool("This includes all items within! Continue?", function(bool2)
				if !bool2 then return end
				jlib.Announce(ply, Color(255,255,0), "[INFORMATION]", Color(255,255,255), " You deleted the faction storage from the database")
				ply:notify("Faction storage deleted from database")
				ent:EmitSound("ui/ui_items_gunsbig_down.mp3")

				local pos = ent:GetPos()
				local effectdata = EffectData()
				effectdata:SetOrigin( pos )
				util.Effect( "flash_smoke", effectdata )

				if ply:IsSuperAdmin() then
					local invID = ent.inventory:getID()
					sql.Query("DELETE FROM `nut_factionstore` WHERE `invID` LIKE " .. invID)
					ent:Remove()
					DiscordEmbed(jlib.SteamIDName(ply) .. " has FULLY DELETED faction storage [#" .. id .. "] from the database", "Faction Storage Deletion Log" , Color(255,0,0), "Admin")
				end

			end, ply, "YES (DELETE)", "NO (CANCEL)")
		end, ply, "DELETE", "CANCEL")
    end
})

/** -- NOTE: Removed due to high likelyhood this will be misued
properties.Add("Remove", { -- Replace the normal "Remove" property
    ["MenuLabel"] = "[ADMIN] Remove Instance",
    ["MenuIcon"] = "icon16/delete.png",
    ["Order"] = 10001,
    ["Filter"] = function(self, ent, ply)
		if ent:GetClass() != "faction-storage" then return false end
        return ply:IsSuperAdmin()
    end,
    ["Action"] = function(self, ent, tr)
        self:MsgStart()
            net.WriteEntity(ent)
        self:MsgEnd()
    end,
    ["Receive"] = function(self, len, ply)
        local ent = net.ReadEntity()

		jlib.RequestBool("This will only delete the entity, continue?", function(bool)
			if !bool then return end
			ent:Remove()
		end, ply,  "YES (REMOVE)", "NO (CANCEL)")
    end
})

**/


hook.Add("InitPostEntity", "factionStorageCommands", function()
	-- Locate a faction storage by a specific ID (if it exists) and offer via jlib.requestBool() the staff to teleport to it
	nut.command.add("findstorage", {
		syntax = "<number id>",
		adminOnly = true,
		onRun = function(client, arguments)
			local storageID = arguments[1]
			if(storageID) then
				for k, v in pairs(ents.FindByClass("faction-storage")) do
					if(v.ID == storageID) then
						jlib.RequestBool("Teleport to storage?", function()
							client:SetPos(v:GetPos())
						end, client, "Yes", "No", extendedMessage)

						return true
					end
				end
			end

			client:notify("Storage not found.")
			return false
		end
	})

	-- Despawn a faction storage (if it exists) & set the spawn state back to "spawnable" via deployables
	nut.command.add("resetstorage", {
		syntax = "<number id>",
		adminOnly = true,
		onRun = function(client, arguments)
			local storageID = arguments[1]
			if(storageID) then
				for k, v in pairs(ents.FindByClass("faction-storage")) do
					if(v.ID == storageID) then
						v:Remove()

						client:notify("Storage successfully reset.")
						return true
					end
				end
			end

			client:notify("Storage not found.")
			return false
		end
	})

	-- Despawn a faction storage (if it exists) & set the spawn state back to "spawnable" via deployables
	nut.command.add("factionstorage_data", {
		adminOnly = true,
		onRun = function(client)
			local entity = client:GetEyeTrace().Entity

			if !IsValid(entity) or entity:GetClass() != "faction-storage" then
				client:notify("Target entity is not a faction storage")
				return
			end

			jlib.Announce(client,
				Color(255,255,0), "[FACTION STORAGE] ", Color(255,255,155), "Information:",
				Color(255,255,255), "\n· FACTION: " .. (entity:GetFactionName() or "Unconfigured") ..
				"\n· STORAGE ID NUMBER: " .. (entity.ID or "Unconfigured") ..
				"\n· CLASSES:"
			)

			local classes = entity:GetClasses()

			if classes then
				for classIndex, classListing in pairs(classes) do
					client:ChatPrint("	|_ " .. (nut.class.list[classIndex].name or "[ERROR]"))
				end
			else
				client:ChatPrint("	|_ Unconfigured")
			end
		end
	})
end)
