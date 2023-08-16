AddCSLuaFile()

ENT.Type      = "anim"
ENT.Base      = "base_gmodentity"

ENT.Category  = "Claymore Gaming"
ENT.PrintName = "Faction Storage"
ENT.Author    = "Claymore Gaming"

ENT.Spawnable = true

ENT.CannotRemove = true --stops entity from being removed by properties

function ENT:GetFactionID()
    return self:GetNWInt("FactionID", nil)
end

function ENT:GetFactionName()
    return self:GetNWString("FactionName", "none")
end

function ENT:GetClasses()
    return self:getNetVar("Classes", {})
end

if SERVER then
    function ENT:SpawnFunction(ply, tr, className)
        if ( !tr.Hit ) then return end

        local spawnPos = tr.HitPos + tr.HitNormal * 37
        local spawnAng = ply:EyeAngles()
        spawnAng.p = 0
        spawnAng.y = spawnAng.y + 180

        local ent = ents.Create(className)
        ent:SetPos(spawnPos)
        ent:SetAngles(spawnAng)
        ent:Spawn()
        ent:Activate()

        return ent
    end

    function ENT:Initialize()
        self:SetModel("models/llama/locker03.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        self:PhysWake()

        self.classes = self.classes or {}

        if self.InvID then
            nut.item.restoreInv(self.InvID, factionStoreConfig.InvW, factionStoreConfig.InvH, function(inv)
                self.inventory = inv
                inv.vars.isBag = "factionstore"
                inv.vars.ent = self

				if self.ID then
					FactionStorage.toggleStorSpawnByID(self.ID, false) -- FIXME/NOTE: Toggles spawn to '0'
				end

                if file.Exists("factionstorelogs/" .. self.InvID .. ".dat", "DATA") then --support for legacy data
                    local compressedData = file.Read("factionstorelogs/" .. self.InvID .. ".dat")

                    inv.vars.log = compressedData

                    if file.Exists("factionstorelogs/" .. self.InvID .. ".txt", "DATA") then
                        file.Delete("factionstorelogs/" .. self.InvID .. ".txt")
                    end
                elseif file.Exists("factionstorelogs/" .. self.InvID .. ".txt", "DATA") then
                    inv.vars.log = util.JSONToTable(file.Read("factionstorelogs/" .. self.InvID .. ".txt"))
                end
            end)
        else
            nut.item.newInv(0, "factionstore", function(inv)
                inv.vars.isStorage = true
                inv.vars.ent = self
                inv.vars.log = {}
                inv.noSave = false
                self.inventory = inv
            end)
        end
    end

    function ENT:Use(activator, caller)
        if caller:GetPos():DistToSqr(self:GetPos()) > 150*150 then return end
		--activator:ChatPrint("[DEBUG] Entity ID = " .. self.ID or "nil") -- DEBUG

        if self.IsUsed then
            caller:notify("Someone else is already using this.")
            return
        end

        local char = caller:getChar()
        local faction = char:getFaction()
        local class = char:getClass()

        if IsStaffFaction(caller) and caller:IsSuperAdmin() then
            self:OpenInventory(caller)
            return
        elseif faction == self:GetFactionID() and (self:GetClasses()["all"] or self:GetClasses()[class]) then
            self:OpenInventory(caller)
            return
        end
        caller:notify("You are not the right faction or class to use this!")
    end

    function ENT:OpenInventory(ply)
		if !self.ID then
			ply:notify("You cannot store items in an unsaved storage!")
			jlib.Announce(ply, Color(255,0,0), "[WARNING]", Color(255,255,255), " This faction storage is unconfigured & unsaved")
			return
		end

        local inventory = self.inventory

        inventory:sync(ply)
        net.Start("factionstoreOpenInv")
            net.WriteInt(inventory:getID(), 32)
            net.WriteEntity(self)
        net.Send(ply)

        self.IsUsed = true
        ply.factionStoreEnt = self
    end

    function ENT:Save()
        local classes = self:GetClasses()
        local uniqueIDs = {}
        for classID,_ in pairs(classes) do
            local class = nut.class.list[classID]
            table.insert(uniqueIDs, class.uniqueID)
        end

		local insert = {
            invID = self.inventory:getID(),
            pos = self:GetPosSerialized(),
            ang = self:GetAngSerialized(),
            faction = nut.faction.indices[self:GetFactionID()].uniqueID,
            classes = util.TableToJSON(uniqueIDs)
        }

		local columns = {}
		local values = {}

		for column, value in pairs(insert) do
			if isstring(value) then
				value = "'" .. value .. "'"
			end

			table.insert(columns, column)
			table.insert(values, value)
		end

		if !self.ID then
			sql.Query("INSERT INTO nut_factionstore (" .. table.concat(columns, ", ") .. ") VALUES (" .. table.concat(values, ", ") .. ")")
			self.ID = tonumber(sql.Query("SELECT last_insert_rowid()")[1]["last_insert_rowid()"])
			
			--print("Selecting")
			--PrintTable(sql.Query("SELECT * FROM nut_factionstore WHERE invID = " ..insert.invID))
			
			local query = "UPDATE nut_factionstore SET _id = " ..self.ID.. " WHERE invID = " ..insert.invID
			sql.Query(query)
			
			--print("Selecting 2")
			--PrintTable(sql.Query("SELECT * FROM nut_factionstore WHERE _id = " ..self.ID))
			
			--print("Finished save")
		else
			--print("Updating save")
		
			local query = "UPDATE nut_factionstore SET "
			for column, value in pairs(insert) do
				if isstring(value) then
					value = "'" .. value .. "'"
				end

				query = query .. column .. " = " .. value .. ", "
			end
			query = query:Trim(" ")
			query = query:Trim(",")
			query = query .. " WHERE _id = " .. self.ID
			sql.Query(query)
			print(query)
		end
    end

    function ENT:SetFaction(fac)
        if fac == -1 then return end

        self:SetNWInt("FactionID", fac)
        self:SetNWString("FactionName", nut.faction.indices[fac].name:lower())
    end

    function ENT:SetClasses(classes)
        self:setNetVar("Classes", classes)
    end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end

    function ENT:onShouldDrawEntityInfo()
        return true
    end

    function ENT:onDrawEntityInfo(alpha)
		local position = self:LocalToWorld(self:OBBCenter()):ToScreen()
		local x, y = position.x, position.y

		nut.util.drawText("Faction Storage", x, y, ColorAlpha(nut.config.get("color"), alpha), 1, 1, nil, alpha * 0.65)
		nut.util.drawText("A storage locker usable by members of the " .. self:GetFactionName() .. " faction.", x, y + 16, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
	end
end

function ENT:GetPosSerialized()
	local pos = self:GetPos()
	return util.TableToJSON({x = pos.x, y = pos.y, z = pos.z})
end

function ENT:GetAngSerialized()
	local ang = self:GetAngles()
	return util.TableToJSON({pitch = ang.pitch, yaw = ang.yaw, roll = ang.roll})
end

function ENT:OnRemove()
	if self.ID then
		FactionStorage.toggleStorSpawnByID(self.ID, true) -- FIXME/NOTE: Toggles spawn to '1'
	end
end
