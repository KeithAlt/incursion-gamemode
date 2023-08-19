Armor = Armor or {}
Armor.Config = Armor.Config or {}
Armor.Author = "jonjo"

AddCSLuaFile("armor_config.lua")
include("armor_config.lua")

--Consts
Armor.Consts = Armor.Consts or {}
Armor.Consts.BodiesPath = "models/thespireroleplay/humans/"
Armor.Consts.HeadPath = "models/lazarusroleplay/heads/"
Armor.Consts.AccessoryPath = "models/lazarusroleplay/"
Armor.Consts.ValidSexes = {
	["male"] = true,
	["female"] = true,
	["ghoul"] = true
}
Armor.Consts.ValidRaces = {
	["caucasian"] = true,
	["hispanic"] = true,
	["african"] = true,
	["asian"] = true
}
Armor.Consts.RaceSkins = {
	["caucasian"] = 0,
	["african"] = 2,
	["hispanic"] = 4,
	["asian"] = 6
}
Armor.Consts.MinHeight = 5
Armor.Consts.MaxHeight = 6.3
Armor.Consts.AccessoryTypes = Armor.Consts.AccessoryTypes or {}
Armor.AccessoriesCached = Armor.AccessoriesCached or false

function Armor.CacheAccessoryTypes()
	for aID, accessory in pairs(Armor.Config.Accessories) do
		if accessory.type then
			Armor.Consts.AccessoryTypes[accessory.type] = true
		end
	end
end

if !Armor.AccessoriesCached then
	Armor.CacheAccessoryTypes()
	Armor.AccessoriesCached = true
end

--Player meta functions
Armor.PlayerMeta = Armor.PlayerMeta or FindMetaTable("Player")

local PLAYER = Armor.PlayerMeta

--Armor model group functions
function Armor.RenderOverride(s) -- FIXME: Can be throttled or optimized
	local parent = s:GetParent()

	if IsValid(parent) and !s:GetParent():GetNoDraw() then -- FIXME: Does this really need to run every frame?
		s:DrawModel()
		s:CreateShadow()
	else
		s:DestroyShadow()
	end
end

Armor.HookID = Armor.HookID or 0
Armor.LOS = Armor.LOS or {}

function Armor.MonitorCSEnt(csent)
	if !IsValid(csent) then return end

	local hookID = "CSEntMonitor" .. Armor.HookID
	csent.HookID = Armor.HookID

	Armor.HookID = Armor.HookID + 1

	local mdl = csent:GetModel()
	local skin = csent:GetSkin() or 0
	local ply = csent.ply
	local localPly = LocalPlayer()
	local maxDistSqr = Armor.Config.ExistanceDistance * Armor.Config.ExistanceDistance
	local csentType = csent.type
	local color = csent:GetColor()
	local id = csent.id
	ply.LOSIDs = ply.LOSIDs or {}

	local bodygroups = {}
	for i = 0, table.Count(csent:GetBodyGroups()) - 1 do
		bodygroups[i] = csent:GetBodygroup(i)
	end

	local scales = {}
	for i = 0, csent:GetBoneCount() - 1 do
		scales[i] = csent:GetManipulateBoneScale(i)
	end

	local invalidFor = 0
	local invalidTime = 0

	hook.Add("Think", hookID, function()
		local valid = IsValid(csent)

		if valid and csent.IsHead then
			bodygroups[2] = csent:GetBodygroup(2)
			bodygroups[3] = csent:GetBodygroup(3)
		end

		if !IsValid(ply) then
			invalidFor = invalidFor + 1
			invalidTime = invalidTime + RealFrameTime()

			if invalidTime > 30 then
				print("Removing " .. hookID .. " due to NULL player entity.")
				if valid then
					csent:Remove()
				end
				Armor.LOS[hookID] = nil
				hook.Remove("Think", hookID)
			-- else
			-- 	print("Allowing invalid monitor " .. hookID .. " to exist for " .. invalidFor .. " frame(s).")
			-- 	print("Invalid time: " .. invalidTime)
			end
			return
		else
			invalidFor = 0
			invalidTime = 0
		end

		local shouldRemove = hook.Run("ArmorShouldRemoveCSEnts", ply)

		if shouldRemove != false then
			local inLos = ply.InLOS and ply.InFrustum
			local inDist = localPly:GetPos():DistToSqr(ply:GetPos()) < maxDistSqr
			local shouldExist = inLos and inDist

			if !shouldExist and valid then
				//print("Removing CSEnt that is out of line of sight/too far", hookID)
				Armor.LOS[hookID] = true

				local LOSKey = csent.type

				if LOSKey then
					ply.LOSIDs[LOSKey] = hookID
				//else
					//print("CSEnt with unknown LOS ID:", mdl)
				end

				if ply.Accessories then
					ply.Accessories[csentType] = nil
				end
				csent:Remove()

				return
			elseif Armor.LOS[hookID] and !valid and shouldExist then
				//print("CSEnt has re-entered line of sight/distance", hookID)
				Armor.LOS[hookID] = nil
			end

			if Armor.LOS[hookID] then return end
		end

		if !valid then
			//if mdl then
				//print("Re-creating CSEnt with model " .. mdl)
			//end

			local newEnt = ClientsideModel(mdl, RENDERGROUP_OPAQUE)
			newEnt:SetParent(ply)
			newEnt:AddEffects(EF_BONEMERGE)
			newEnt:SetModel(mdl)
			newEnt:SetParent(ply)
			newEnt:Spawn()
			newEnt:SetSkin(skin)

			for i, v in pairs(bodygroups) do
				newEnt:SetBodygroup(i, v)
			end

			for i, v in pairs(scales) do
				newEnt:ManipulateBoneScale(i, v)
			end

			newEnt.RenderOverride = Armor.RenderOverride
			newEnt.ply = ply
			newEnt.type = csentType
			newEnt.id = id
			newEnt:SetColor(color)
			if csentType == "Arms" then
				newEnt.IsArms = true
				ply.Arms = newEnt
			elseif csentType == "Head" then
				newEnt.IsHead = true
				ply.Head = newEnt
			end

			if ply.Accessories and csentType != "Arms" and csentType != "Head" then
				ply.Accessories[csentType] = newEnt
			end

			hook.Remove("Think", hookID)
			Armor.MonitorCSEnt(newEnt)

			return
		end

		local plyRenderMode = ply:GetRenderMode()
		local plyRenderFX = ply:GetRenderFX()

		-- FIXME: Can be throttled or optimized
		-- If player's RenderMode differs from the default (RENDERMODE_NORMAL), change the csent to match
		if plyRenderMode != RENDERMODE_NORMAL and plyRenderMode != csentRenderMode then
			csent:SetRenderMode(plyRenderMode)
		elseif csentRenderMode != RENDERMODE_NONE then
			csent:SetRenderMode(RENDERMODE_NONE)
		end

		if plyRenderFX != csent:GetRenderFX() then
			csent:SetRenderFX(plyRenderFX)
		end

		if !IsValid(csent:GetParent()) then
			csent:SetParent(ply)
		end

		local npcEnt = ply:GetNWEntity("PCNPCEnt")
		if IsValid(npcEnt) then
			csent:SetParent(npcEnt)
			return
		end

		local body = ply:GetNWEntity("jDoll")
		local alive = ply:Alive() and !IsValid(ply.TranqRagdoll) and !IsValid(ply.falloverDoll)

		if !alive and IsValid(body) and csent:GetParent() != body then
			csent:SetParent(body)
		elseif alive and csent:GetParent() != ply then
			csent:SetParent(ply)
		end
	end)
end

function Armor.EndCSEntMonitor(csent)
	if !IsValid(csent) or !csent.HookID then return end
	hook.Remove("Think", "CSEntMonitor" .. csent.HookID)

	if IsValid(csent.ply) and csent.type and csent.ply.LOSIDs and csent.ply.LOSIDs[csent.type] == csent.HookID then
		csent.ply.LOSIDs[csent.type] = nil
	end

	Armor.LOS[csent.HookID] = nil
end

function Armor.EndCSEntMonitorByID(ply, id, aType)
	if id then
		hook.Remove("Think", id)

		if IsValid(ply) and aType and ply.LOSIDs and ply.LOSIDs[aType] == id then
			ply.LOSIDs[aType] = nil
		end

		Armor.LOS[id] = nil
	end
end

function PLAYER:MakeHead(force)
	if self:GetForceNoHead() and !force then return end

	util.PrecacheModel(self:GetHeadPath())

	if SERVER then
		net.Start("ArmorMakeHead")
			net.WriteEntity(self)
			net.WriteBool(force)
		net.Broadcast()
	end

	if CLIENT then
		self:RemoveHead()

		local head = (self:GetHeadPath() and ClientsideModel(self:GetHeadPath(), RENDERGROUP_OPAQUE)) or false

		if IsValid(head) then
			head:SetParent(self)
			head:AddEffects(EF_BONEMERGE)
			head:Spawn()
			head:SetSkin(self:GetHeadSkin())
			head.ply = self
			head.IsHead = true
			head.type = "Head"
			head.RenderOverride = Armor.RenderOverride

			self.Head = head
			Armor.MonitorCSEnt(head)
		end
	end
end

-- Places a clientside model accessory on a ragdoll
function Armor.AddAccessoryRagdoll(client, target, id)
	local accessoryTbl = Armor.Config.Accessories[id]
	local aType = accessoryTbl.type
	local mdl = accessoryTbl.model or Armor.GetAccessoryModel(accessoryTbl.unisex and "unisex" or client:GetSex(), id)
	util.PrecacheModel(mdl)

	if SERVER then
		if target:GetNW2Bool("SlotTaken" .. aType) then
			return
		end

		target.Accessories = target.Accessories or {}
		target.Accessories[aType] = id

		target:SetNW2Bool("SlotTaken" .. aType, true)
		target:SetNW2String(aType .. "Accessory", id)

		--[[
		net.Start("ArmorAddAccessory")
			net.WriteString(id)
			net.WriteEntity(self)
		net.Broadcast()
		--]]
	end

	if CLIENT then
		target.Accessories = target.Accessories or {}

		if !IsValid(target.Accessories[aType]) then
			local sex = client:GetSex()
			if sex == "ghoul" then
				sex = "male"
			end

			--[[
			Armor.EndCSEntMonitor(self.Accessories[aType])
			if self.LOSIDs then
				Armor.EndCSEntMonitorByID(self, self.LOSIDs[aType], aType)
			end
			--]]

			local accessory = IsValid(target.Accessories[aType]) and target.Accessories[aType] or ClientsideModel(mdl, RENDERGROUP_OPAQUE)
			accessory:SetModel(mdl)
			accessory:SetParent(target)
			accessory:AddEffects(EF_BONEMERGE)
			if isnumber(accessoryTbl.bodygroup) then
				accessory:SetBodygroup(0, accessoryTbl.bodygroup)
			elseif istable(accessoryTbl.bodygroup) then
				for i, v in ipairs(accessoryTbl.bodygroup) do
					accessory:SetBodygroup(i - 1, v)
				end
			end

			-- Requires further evaluation
			accessory:SetRenderMode(RENDERMODE_NONE) -- This does not make sense, but for some reason it works.

			accessory:Spawn()
			accessory:SetSkin(accessoryTbl.skin or 0)
			local scaleNum = accessoryTbl[(sex or "male") .. "Scale"] or 1
			local scale = Vector(scaleNum, scaleNum, scaleNum)
			for i = 0, accessory:GetBoneCount() - 1 do
				accessory:ManipulateBoneScale(i, scale)
			end
			accessory.ply = target
			accessory.RenderOverride = Armor.RenderOverride

			accessory.id = id
			accessory.type = aType

			--Armor.MonitorCSEnt(accessory)

			target.Accessories[aType] = accessory

			if IsValid(target.Head) then
				if accessoryTbl.hair == false then
					target.Head:SetBodygroup(2, 0)
				end

				if accessoryTbl.facialHair == false then
					target.Head:SetBodygroup(3, 0)
				end
			end
		else
			target.Accessories[aType]:SetModel(accessoryTbl.model or Armor.GetAccessoryModel(accessoryTbl.unisex and "unisex" or client:GetSex(), id))
		end
	end
end

function Armor.MakeHeadRagdoll(client, target, force)
	if client:GetForceNoHead() and !force then return end

	util.PrecacheModel(client:GetHeadPath())

	--[[
	if SERVER then
		net.Start("ArmorMakeHead")
			net.WriteEntity(target)
			net.WriteBool(force)
		net.Broadcast()
	end
	--]]

	if CLIENT then
		--target:RemoveHead()

		local head = (client:GetHeadPath() and ClientsideModel(client:GetHeadPath(), RENDERGROUP_OPAQUE)) or false

		if IsValid(head) then
			head:SetParent(target)
			head:AddEffects(EF_BONEMERGE)
			head:Spawn()
			head:SetSkin(client:GetHeadSkin())
			head.ply = target
			head.IsHead = true
			head.type = "Head"
			head.RenderOverride = Armor.RenderOverride

			target.Head = head
			--Armor.MonitorCSEnt(head)

			local bodygroups, color = client:GetFacialCustomization()
			
			if(bodygroups) then
				for i, v in pairs(bodygroups) do
					head:SetBodygroup(i, v)
				end
			end

			if(color) then
				head:SetColor(color)
			end
		end
	end
end

function Armor.MakeArmorRagdoll(client, target, group, skipMdl, sex, race, forceArms, forceHead)
	target.ArmsOverride = nil

	if sex then
		target:SetNW2String("ArmorSex", sex)
	end

	if race then
		target:SetNW2String("ArmorRace", race)
	end

	sex = sex or client:GetSex()
	local path = Armor.Consts.BodiesPath .. group .. "/"
	local bodyPath = path .. sex .. ".mdl"
	if sex == "ghoul" and !file.Exists(bodyPath, "GAME") then
		bodyPath = bodyPath:Replace("ghoul", "male")
	end
	local armsPath = path .. "/arms/" .. sex .. "_arm.mdl"

	util.PrecacheModel(bodyPath)
	util.PrecacheModel(armsPath)

	target.NoArmorLoop = true

	if SERVER then
		target:SetNW2String("ArmorGroup", group)

		if skipMdl != true then
			target.NoArmorLoop = true
			target:SetModel(bodyPath)
			target.NoArmorLoop = nil
		end

		--[[
		net.Start("SetArmorGroup")
			net.WriteString(group)
			net.WriteEntity(target)
			net.WriteString(target:GetSex())
			net.WriteString(target:GetRace())
			net.WriteBool(forceArms)
			net.WriteBool(forceHead)
		net.Broadcast()
		--]]
	end

	target.NoArmorLoop = nil
end

function PLAYER:SetArmorGroup(group, skipMdl, sex, race, forceArms, forceHead)
	self.ArmsOverride = nil

	if sex then
		self:SetNW2String("ArmorSex", sex)
	end

	if race then
		self:SetNW2String("ArmorRace", race)
	end

	sex = sex or self:GetSex()
	local path = Armor.Consts.BodiesPath .. group .. "/"
	local bodyPath = path .. sex .. ".mdl"
	if sex == "ghoul" and !file.Exists(bodyPath, "GAME") then
		bodyPath = bodyPath:Replace("ghoul", "male")
	end
	local armsPath = path .. "/arms/" .. sex .. "_arm.mdl"

	util.PrecacheModel(bodyPath)
	util.PrecacheModel(armsPath)

	self.NoArmorLoop = true

	if SERVER then
		self:SetNW2String("ArmorGroup", group)

		if skipMdl != true then
			self.NoArmorLoop = true
			self:SetModel(bodyPath)
			self.NoArmorLoop = nil
		end

		net.Start("SetArmorGroup")
			net.WriteString(group)
			net.WriteEntity(self)
			net.WriteString(self:GetSex())
			net.WriteString(self:GetRace())
			net.WriteBool(forceArms)
			net.WriteBool(forceHead)
		net.Broadcast()
	end

	if CLIENT then
		Armor.EndCSEntMonitor(self.Arms)
		if self.LOSIDs then
			Armor.EndCSEntMonitorByID(self, self.LOSIDs.Arms, "Arms")
		end

		if IsValid(self.Arms) then
			self.Arms:Remove()
		end

		local arms = (armsPath and ClientsideModel(armsPath, RENDERGROUP_OPAQUE)) or false

		if IsValid(arms) and (!self:GetForceNoArms() or forceArms) then
			arms:SetParent(self)
			arms:AddEffects(EF_BONEMERGE)
			arms:Spawn()
			arms:SetSkin(self:GetHeadSkin())
			arms.ply = self
			arms.IsArms = true
			arms.type = "Arms"
			arms.RenderOverride = Armor.RenderOverride

			Armor.MonitorCSEnt(arms)

			self.Arms = arms

			local hands = self:GetHands()
			hands:SetModel(path .. "arms.mdl")
		end

		if !IsValid(self.Head) then
			self:MakeHead(forceHead)
		end
	end

	self.NoArmorLoop = nil
end

function PLAYER:OverrideArms(armsMdl, force)
	self.ArmsOverride = armsMdl

	if self:GetForceNoArms() and !force then return end

	if SERVER then
		net.Start("ArmorOverrideArms")
			net.WriteEntity(self)
			net.WriteString(armsMdl)
			net.WriteBool(force)
		net.Broadcast()
	end

	if CLIENT then
		Armor.EndCSEntMonitor(self.Arms)
		if self.LOSIDs then
			Armor.EndCSEntMonitorByID(self, self.LOSIDs.Arms, "Arms")
		end

		if IsValid(self.Arms) then
			self.Arms:SetModel(armsMdl)
			self.Arms:SetSkin(self:GetHeadSkin())
		else
			local arms = ClientsideModel(armsMdl, RENDERGROUP_OPAQUE)
			arms:SetParent(self)
			arms:AddEffects(EF_BONEMERGE)
			arms:Spawn()
			arms:SetSkin(self:GetHeadSkin())
			arms.ply = self
			arms.IsArms = true
			arms.type = "Arms"
			arms.RenderOverride = Armor.RenderOverride

			self.Arms = arms
		end

		Armor.MonitorCSEnt(self.Arms)
	end
end

function PLAYER:RemoveHead()
	if SERVER then
		net.Start("ArmorRemoveHead")
			net.WriteEntity(self)
		net.Broadcast()
	end

	if CLIENT then
		Armor.EndCSEntMonitor(self.Head)
		if self.LOSIDs then
			Armor.EndCSEntMonitorByID(self, self.LOSIDs.Head, "Head")
		end
		if IsValid(self.Head) then
			self.Head:Remove()
		end
		self.Head = nil
	end
end

function PLAYER:RemoveArms()
	if SERVER then
		net.Start("ArmorRemoveArms")
			net.WriteEntity(self)
		net.Broadcast()
	end

	if CLIENT then
		Armor.EndCSEntMonitor(self.Arms)
		if self.LOSIDs then
			Armor.EndCSEntMonitorByID(self, self.LOSIDs.Arms, "Arms")
		end
		if IsValid(self.Arms) then
			self.Arms:Remove()
		end
		self.Arms = nil
	end
end

function PLAYER:GetForceNoHead()
	return self:GetNW2Bool("ForceNoHead", false)
end

function PLAYER:SetForceNoHead(bool)
	local wasForced = self:GetForceNoHead()
	self:SetNW2Bool("ForceNoHead", bool)
	if bool then
		self:RemoveHead()
	elseif wasForced then
		local bodygroups, color = self:GetFacialCustomization()
		self:SetFacialCustomization(bodygroups, color, false, true)
	end
end

function PLAYER:GetForceNoArms()
	return self:GetNW2Bool("ForceNoArms", false)
end

function PLAYER:SetForceNoArms(bool)
	local wasForced = self:GetForceNoArms()
	self:SetNW2Bool("ForceNoArms", bool)
	if bool then
		self:RemoveArms()
	elseif wasForced then
		local armorGroup = self:GetArmorGroup()
		if self.ArmsOverride then
			self:OverrideArms(self.ArmsOverride, true)
		elseif armorGroup and armorGroup != "" then
			self:SetArmorGroup(armorGroup, true, nil, nil, true)
		end
	end
end

function PLAYER:GetArmorGroup()
	return self:GetNW2String("ArmorGroup")
end

function PLAYER:SetArmorBodygroups(bodygroups)
	if isnumber(bodygroups) then
		bodygroups = {bodygroups}
	end

	if SERVER then
		for i, v in ipairs(bodygroups) do
			self:SetBodygroup(i - 1, v)
		end
	end
end

function PLAYER:ArmorReset()
	if SERVER then
		self:SetNW2String("ArmorGroup", "")

		net.Start("SetArmorGroup")
			net.WriteString("")
			net.WriteEntity(self)
			net.WriteString(self:GetSex())
			net.WriteString(self:GetRace())
		net.Broadcast()
	end

	if CLIENT then
		self:RemoveArms()
		self:RemoveHead()
	end
end

--Get/set functions
function PLAYER:SetSex(sex)
	if SERVER then
		if !Armor.Consts.ValidSexes[sex] then
			return "Invalid sex"
		end

		self:SetNW2String("ArmorSex", sex)
	end
end

function PLAYER:GetSex()
	return self:GetNW2String("ArmorSex", "male")
end

function PLAYER:SetRace(race)
	if SERVER then
		if !Armor.Consts.ValidRaces[race] then
			return "Invalid race"
		end

		self:SetNW2String("ArmorRace", race)
	end
end

function PLAYER:GetRace()
	return self:GetNW2String("ArmorRace", "caucasian")
end

function PLAYER:GetFacialCustomization()
	return {0, self:GetNW2Int("ArmorHair"), self:GetNW2Int("ArmorFacialHair")}, Color(self:GetNW2Int("ArmorHairR"), self:GetNW2Int("ArmorHairG"), self:GetNW2Int("ArmorHairB"), 255)
end

function PLAYER:SetFacialCustomization(bodygroups, color, dontUpdate, forceHead)
	if SERVER then
		self:SetNW2Int("ArmorHair", bodygroups[2])
		self:SetNW2Int("ArmorFacialHair", bodygroups[3])
		self:SetNW2Int("ArmorHairR", color.r)
		self:SetNW2Int("ArmorHairG", color.g)
		self:SetNW2Int("ArmorHairB", color.b)

		if dontUpdate and !forceHead then return end

		net.Start("ArmorFaceUpdate")
			net.WriteTable(bodygroups)
			net.WriteTable(color)
			net.WriteBool(forceHead)
			net.WriteEntity(self)
		net.Broadcast()
	end

	if CLIENT then
		self:MakeHead(forceHead)

		if !IsValid(self.Head) then return end

		for i, v in pairs(bodygroups) do
			self.Head:SetBodygroup(i, v)
		end

		self.Head:SetColor(color)

		Armor.EndCSEntMonitor(self.Head)
		if self.LOSIDs then
			Armor.EndCSEntMonitorByID(self, self.LOSIDs.Head, "Head")
		end
		Armor.MonitorCSEnt(self.Head)
	end
end

function PLAYER:GetHeadPath()
	if self:GetSex() == "ghoul" then
		return "models/lazarusroleplay/heads/ghoul_default.mdl"
	else
		return Armor.Consts.HeadPath .. self:GetSex() .. "_" .. self:GetRace() .. ".mdl"
	end
end

function PLAYER:SetHeadSkin(skin)
	if SERVER then
		self:SetNW2Int("HeadSkin", skin)
	end
end

function PLAYER:GetHeadSkin()
	if self:GetSex() == "ghoul" then
		return self:GetNW2Int("HeadSkin")
	else
		return Armor.Consts.RaceSkins[self:GetRace()] + (self:GetNW2Int("BuildStrength", 1) > (1 + Armor.BuildInfo.Strength.Max) / 2 and 1 or 0)
	end
end

--Accessories
function PLAYER:AddAccessory(id)
	local accessoryTbl = Armor.Config.Accessories[id]
	local aType = accessoryTbl.type
	local mdl = accessoryTbl.model or Armor.GetAccessoryModel(accessoryTbl.unisex and "unisex" or self:GetSex(), id)
	util.PrecacheModel(mdl)

	if SERVER then
		if self:GetNW2Bool("SlotTaken" .. aType) then
			return
		end

		self.Accessories = self.Accessories or {}
		self.Accessories[aType] = id

		self:SetNW2Bool("SlotTaken" .. aType, true)
		self:SetNW2String(aType .. "Accessory", id)

		net.Start("ArmorAddAccessory")
			net.WriteString(id)
			net.WriteEntity(self)
		net.Broadcast()
	end

	if CLIENT then
		self.Accessories = self.Accessories or {}

		if !IsValid(self.Accessories[aType]) then
			local sex = self:GetSex()
			if sex == "ghoul" then
				sex = "male"
			end

			Armor.EndCSEntMonitor(self.Accessories[aType])
			if self.LOSIDs then
				Armor.EndCSEntMonitorByID(self, self.LOSIDs[aType], aType)
			end

			local accessory = IsValid(self.Accessories[aType]) and self.Accessories[aType] or ClientsideModel(mdl, RENDERGROUP_OPAQUE)
			accessory:SetModel(mdl)
			accessory:SetParent(self)
			accessory:AddEffects(EF_BONEMERGE)
			if isnumber(accessoryTbl.bodygroup) then
				accessory:SetBodygroup(0, accessoryTbl.bodygroup)
			elseif istable(accessoryTbl.bodygroup) then
				for i, v in ipairs(accessoryTbl.bodygroup) do
					accessory:SetBodygroup(i - 1, v)
				end
			end

			-- Requires further evaluation
			accessory:SetRenderMode(RENDERMODE_NONE) -- This does not make sense, but for some reason it works.

			accessory:Spawn()
			accessory:SetSkin(accessoryTbl.skin or 0)
			local scaleNum = accessoryTbl[(sex or "male") .. "Scale"] or 1
			local scale = Vector(scaleNum, scaleNum, scaleNum)
			for i = 0, accessory:GetBoneCount() - 1 do
				accessory:ManipulateBoneScale(i, scale)
			end
			accessory.ply = self
			accessory.RenderOverride = Armor.RenderOverride

			accessory.id = id
			accessory.type = aType

			Armor.MonitorCSEnt(accessory)

			self.Accessories[aType] = accessory

			if IsValid(self.Head) then
				if accessoryTbl.hair == false then
					self.Head:SetBodygroup(2, 0)
				end

				if accessoryTbl.facialHair == false then
					self.Head:SetBodygroup(3, 0)
				end
			end
		else
			self.Accessories[aType]:SetModel(accessoryTbl.model or Armor.GetAccessoryModel(accessoryTbl.unisex and "unisex" or self:GetSex(), id))
		end
	end
end

function PLAYER:RemoveAccessory(id)
	local accessoryTbl = Armor.Config.Accessories[id]
	local aType = accessoryTbl.type

	if SERVER then
		self.Accessories = self.Accessories or {}
		self.Accessories[aType] = nil

		self:SetNW2Bool("SlotTaken" .. aType, false)
		self:SetNW2String(aType .. "Accessory", nil)

		net.Start("ArmorRemoveAccessory")
			net.WriteString(id)
			net.WriteEntity(self)
		net.Broadcast()
	end

	if CLIENT and self.Accessories and IsValid(self.Accessories[aType]) then
		if IsValid(self.Accessories[aType]) then
			Armor.EndCSEntMonitor(self.Accessories[aType])
		elseif self.LOSIDs then
			Armor.EndCSEntMonitorByID(self, self.LOSIDs[aType], aType)
		end

		self.Accessories[aType]:Remove()
		self.Accessories[aType] = nil

		if IsValid(self.Head) then
			local anyHair, anyFacial = Armor.GetAnyHair(self)

			if accessoryTbl.hair == false and !anyHair then
				self.Head:SetBodygroup(2, self:GetFacialCustomization()[2])
			end

			if accessoryTbl.facialHair == false and !anyFacial then
				self.Head:SetBodygroup(3, self:GetFacialCustomization()[3])
			end
		end
	end
end

function PLAYER:ResetAccessories()
	if SERVER then
		for aType, id in pairs(self.Accessories or {}) do
			self:SetNW2Bool("SlotTaken" .. aType, false)
			self:SetNW2String(aType .. "Accessory", nil)
		end

		self.Accessories = {}

		net.Start("ArmorResetAccessories")
			net.WriteEntity(self)
		net.Broadcast()
	end

	if CLIENT and self.Accessories then
		for aType, csEnt in pairs(self.Accessories or {}) do
			if IsValid(csEnt) then
				Armor.EndCSEntMonitor(csEnt)
				csEnt:Remove()
			end

			self.Accessories[aType] = nil
		end

		for k, v in pairs(self.LOSIDs or {}) do
			if k != "Head" and k != "Arms" then
				Armor.EndCSEntMonitorByID(self, v, k)
			end
		end
	end
end

function PLAYER:GetAccessories()
	local accessories = {}

	for aType, _ in pairs(Armor.Consts.AccessoryTypes) do
		local accessoryID = self:GetNW2String(aType .. "Accessory")

		if accessoryID != "" then
			accessories[#accessories + 1] = accessoryID
		end
	end

	if SERVER then
		return accessories
	else
		return accessories, self.Accessories or {}
	end
end

function Armor.GetAccessoryModel(sex, id)
	local tbl = Armor.Config.Accessories[id]

	local rootPath = tbl.rootPath or Armor.Consts.AccessoryPath


	if tbl.sex or sex == "unisex" then
		return rootPath .. tbl.pathType .. "/" .. tbl.modelType .. ".mdl"
	end

	if sex == "ghoul" then
		sex = "male"
	end

	if tbl[sex .. "Suffix"] or tbl[sex .. "Prefix"] then
		return rootPath .. tbl.pathType .. "/" .. (tbl[sex .. "Prefix"] or "") .. tbl.modelType .. (tbl[sex .. "Suffix"] or "") .. ".mdl"
	else
		return rootPath .. tbl.pathType .. "/" .. sex:sub(1, 1) .. "_" .. tbl.modelType .. ".mdl"
	end
end

function Armor.GetGroupFromMdl(mdl)
	local str = string.Split(mdl, "/")[4]
	if str and str:StartWith("group") then
		return str
	end
end

function Armor.GetMdlFromGroup(group, sex)
	if sex != "male" and sex != "female" then sex = "male" end
	return Armor.Consts.BodiesPath .. group .. "/" .. sex .. ".mdl"
end

--Bone setup
function Armor.BoneSetup(ply, bones)
	if !istable(bones) or !IsValid(ply) then return end

	local oldScales = {}

	for boneName, scaleVector in pairs(bones) do
		local boneID = ply:LookupBone(boneName)

		if !boneID then print("Invalid bone " .. boneName) return end

		local currentScale = ply:GetManipulateBoneScale(boneID)

		oldScales[boneName] = currentScale

		if currentScale != scaleVector then
			ply:ManipulateBoneScale(boneID, scaleVector)
		end
	end

	return oldScales
end

function Armor.PrintBones(ply)
	for i = 0, ply:GetBoneCount() - 1 do
		print(ply:GetBoneName(i))
	end
end

function Armor.ClassCheck(ply)
	local char = ply:getChar()
	local classIndex = char and char:getClass()
	if char and classIndex then
		local class = nut.class.list[classIndex]
		if class.NoArmor then
			return false
		end
	end

	return true
end

--Item setup
function Armor.ItemSetup()
	--Accessories
	for id, tbl in pairs(Armor.Config.Accessories) do
		local sexStr = ""

		if tbl.sex then
			sexStr = " [" .. jlib.UpperFirstChar(tbl.sex) .. "]"
		end

		local ITEM = nut.item.register(id, nil, false, nil, true)
		ITEM.name  = tbl.name .. sexStr .. " ◇"
		ITEM.model = tbl.itemModel or tbl.model or Armor.GetAccessoryModel("male", id)
		ITEM.desc  = tbl.desc .. "\n- Armor Piece ◇"
		ITEM.bodygroup = tbl.bodygroup
		ITEM.noDrop = !isstring(tbl.itemModel)
		ITEM.skin = tbl.itemModelSkin
		ITEM.aID = id
		ITEM.powerarmor = tbl.powerarmor
		ITEM.isjArmor = true
		ITEM.configTbl = tbl

		ITEM.functions.Equip = {
			name = "Equip",
			icon = "icon16/tick.png",
			onRun = function(item)
				local ply = item.player or item:getOwner()

				local curInv = nut.item.inventories[item.invID]
				if(curInv and curInv.vars.isBag) then
					ply:falloutNotify("You can't equip items in bags.")
					return false
				end

				if !Armor.IsHuman(ply:getChar()) then
					ply:notify("You need to be human to wear these accessories.")
					return false
				end

				if !Armor.ClassCheck(ply) then
					ply:notify("You cannot wear armor as this class.")
					return false
				end

				if item.powerarmor and !ply:WearingPA() then
					ply:notify("You must be wearing power armor to equip this.")
					return false
				end

				if tbl.sex and tbl.sex != (ply:GetSex() == "ghoul" and "male" or ply:GetSex()) then
					ply:notify("This item is only applicable to " .. tbl.sex .. "s.")
					return false
				end
				
				local equippedArmor = Armor.Config.Bodies[ply.EquippedArmor or ""]
				if equippedArmor and equippedArmor.cannotWear and equippedArmor.cannotWear[tbl.type] then
					ply:notify("You cannot wear this with " .. equippedArmor.name:lower() .. ".")
					return false
				end

				for aType, aID in pairs(ply.Accessories or {}) do
					local aTbl = Armor.Config.Accessories[aID]

					if (tbl.cannotWear and tbl.cannotWear[aType]) or (aTbl.cannotWear and aTbl.cannotWear[tbl.type]) then
						ply:notify("You cannot wear this with " .. aTbl.name:lower() .. ".")
						return false
					end
				end

				ply:EmitSound("ui/ui_items_generic_up_0" .. math.random(1,4) .. ".mp3")
				ply:AddAccessory(id)
				item:setData("equipped", true)

				if tbl.noBuild == true then
					ply:ResetBuild()
				end

				if tbl.noHead then
					ply:SetForceNoHead(true)
				end

				if tbl.noArms then
					ply:SetForceNoArms(true)
				end

				if tbl.speed then
					local speedMod = (tbl.speed / 100) + 1

					ply:SetWalkSpeed(ply:GetWalkSpeed() * speedMod)
					ply:SetRunSpeed(ply:GetRunSpeed() * speedMod)
				end

				if tbl.OnWear then tbl.OnWear(ply, item) end

				return false
			end,
			onCanRun = function(item)
				local ply = item.player or item:getOwner()
				local hookResult = hook.Run("CanEquipArmor", item, ply)
				if hookResult != nil then return hookResult end
				return !IsValid(item.entity) and !item:getData("equipped", false) and (!ply.Accessories or !ply.Accessories[tbl.type]) and (!ply:getChar() or !ply:getChar():getArmor())
			end
		}

		ITEM.functions.Unequip = {
			name = "Unequip",
			icon = "icon16/cross.png",
			onRun = function(item)
				local ply = item.player or item:getOwner()

				ply:EmitSound("ui/ui_items_generic_up_0" .. math.random(1,4) .. ".mp3")
				ply:RemoveAccessory(id)
				item:setData("equipped", false)

				if tbl.noBuild == true and ply.Build then
					for k, v in pairs(ply.Build) do
						ply:SetBuild(k, v)
					end
				end

				if tbl.speed then
					local speedMod = (tbl.speed / 100) + 1

					ply:SetWalkSpeed(ply:GetWalkSpeed() / speedMod)
					ply:SetRunSpeed(ply:GetRunSpeed() / speedMod)
				end

				local equippedArmor = Armor.Config.Bodies[ply.EquippedArmor or ""]

				if tbl.noHead then
					local noHead = false

					for aType, aID in pairs(ply.Accessories or {}) do
						local aTbl = Armor.Config.Accessories[aID]

						if aTbl.noHead then
							noHead = true
							break
						end
					end

					if equippedArmor and (equippedArmor.head or equippedArmor.noHead) then
						noHead = true
					end

					if noHead == false then
						ply:SetForceNoHead(noHead)
					end
				end

				if tbl.noArms then
					local noArms = false

					for aType, aID in pairs(ply.Accessories or {}) do
						local aTbl = Armor.Config.Accessories[aID]

						if aTbl.noArms then
							noArms = true
							break
						end
					end

					if equippedArmor and equippedArmor.path and !equippedArmor.armsModel then
						noArms = true
					end

					if noArms == false then
						ply:SetForceNoArms(noArms)
					end
				end

				if tbl.OnRemove then tbl.OnRemove(ply, item) end

				return false
			end,
			onCanRun = function(item)
				return !IsValid(item.entity) and item:getData("equipped", false)
			end
		}

		ITEM:hook("drop", function(item)
			if item:getData("equipped") then
				item.player:notify("You cannot drop this while it's equipped")

				return false
			end
		end)

		function ITEM:onCanBeTransfered(oldInventory, newInventory)
			return !self:getData("equipped")
		end

		function ITEM:onLoadout()
			if self:getData("equipped") and SERVER and !self.WornThisTick then

				self.WornThisTick = true
				timer.Simple(0, function() if self then self.WornThisTick = false end end)

				jlib.CallAfterTicks(8, function()
					local ply = self.player or self:getOwner()

					if IsValid(ply) then
						ply:AddAccessory(id)

						if tbl.noBuild == true then
							ply:ResetBuild()
						end

						if tbl.speed then
							local speedMod = (tbl.speed / 100) + 1

							ply:SetWalkSpeed(ply:GetWalkSpeed() * speedMod)
							ply:SetRunSpeed(ply:GetRunSpeed() * speedMod)
						end

						if tbl.noHead then
							ply:SetForceNoHead(true)
						end

						if tbl.noArms then
							ply:SetForceNoArms(true)
						end

						if tbl.OnRemove then tbl.OnRemove(ply, self) end
						if tbl.OnWear then tbl.OnWear(ply, self) end
					end
				end)
			end
		end

		function ITEM:paintOver(item, w, h)
			if item:getData("equipped") then
				surface.SetDrawColor(110, 255, 110, 100)
			else
				surface.SetDrawColor(255, 110, 110, 100)
			end

			surface.DrawRect(w - 16, h - 16, 12, 12)

			surface.SetDrawColor(wRarity.Config.Rarities[tbl.rarity or 1].color)
			surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
		end

		function ITEM:getDesc()
			return self.desc ..
			string.format("\n- Damage Resistance: %s%%\n- Speed Boost: %s%%\n- Fall Protection: %s\n- Protection Areas: %s\n- Wearable By: %s",
			tbl.damage or 0, tbl.speed or 0, tbl.noFall and "Yes" or "No", tbl.head and "Head" or "Body", tbl.sex and jlib.UpperFirstChar(tbl.sex) .. "s" or "Everyone")
		end
	end

	for id, tbl in pairs(Armor.Config.Bodies) do
		local sexStr = ""

		if tbl.sex then
			sexStr = " [" .. jlib.UpperFirstChar(tbl.sex) .. "]"
		end

		local ITEM = nut.item.register(id, nil, false, nil, true)
		ITEM.name  = tbl.name .. sexStr .. " ◇"
		ITEM.model = tbl.itemModel or tbl.model
		ITEM.desc  = tbl.desc .. "\n- Armor Piece ◇"
		ITEM.bodygroup = tbl.bodygroup
		ITEM.noDrop = !isstring(tbl.itemModel)
		ITEM.skin = tbl.itemModelSkin
		ITEM.noCore = tbl.noCore
		ITEM.powerarmor = tbl.powerarmor
		ITEM.isjArmor = true
		ITEM.configTbl = tbl

		ITEM.isModdable = true

		ITEM.functions.Equip = {
			name = "Equip",
			icon = "icon16/tick.png",
			onRun = function(item)
				local ply = item.player or item:getOwner()
				local char = ply:getChar()

				if !char then return end

				local curInv = nut.item.inventories[item.invID]
				if(curInv and curInv.vars.isBag) then
					ply:falloutNotify("You can't equip items in bags.")
					return false
				end

				if !Armor.IsHuman(ply:getChar()) then
					ply:notify("You need to be human to wear these clothes.")
					return false
				end

				if !Armor.ClassCheck(ply) then
					ply:notify("You cannot wear armor as this class.")
					return false
				end

				local sex = ply:GetSex()
				if sex == "ghoul" then
					sex = "male"
				end

				if tbl.sex and tbl.sex != (sex == "ghoul" and "male" or sex) then
					ply:notify("This item is only applicable to " .. tbl.sex .. "s.")
					return false
				end

				for aType, aID in pairs(ply.Accessories or {}) do
					local aTbl = Armor.Config.Accessories[aID]

					if (tbl.cannotWear and tbl.cannotWear[aType]) or (aTbl.cannotWear and aTbl.cannotWear[tbl.type]) then
						ply:notify("You cannot wear this with " .. aTbl.name:lower() .. ".")
						return false
					end
				end

				if tbl.powerarmor and !char:getData("PATraining") then
					ply:notify("You don't have the required training to wear this armor.")
					return false
				end

				local mdl = ply:GetModel()
				local split = mdl:Split("/")
				if split[4] and split[4]:StartWith("group") then
					mdl = split[4]
				end

				ply:EmitSound("ui/ui_items_generic_up_0" .. math.random(1,4) .. ".mp3")
				item:setData("oldModel", mdl)

				if tbl.path then
					ply.NoArmorLoop = true
					ply:SetModel(tbl.path)
					ply:ArmorReset()

					if !tbl.head and !tbl.noHead then
						local anyHair, anyFacial = Armor.GetAnyHair(ply)
						local bodygroups, color = ply:GetFacialCustomization()
						if tbl.hair == false or anyHair then
							bodygroups[2] = nil
						end

						if tbl.facialHair or anyFacial then
							bodygroups[3] = nil
						end

						net.Start("ArmorFaceUpdate")
							net.WriteTable(bodygroups)
							net.WriteTable(color)
							net.WriteBool(!ply:GetForceNoHead())
							net.WriteEntity(ply)
						net.Broadcast()
					end

					ply.NoArmorLoop = nil
				elseif tbl.modelType then
					ply:SetArmorGroup(tbl.modelType, nil, nil, nil, !ply:GetForceNoArms())
				end

				if tbl.armsModel then
					jlib.CallAfterTicks(2, function()
						ply:OverrideArms(tbl.armsModel)
					end)
				end

				local scaleNums = tbl[(sex or "male") .. "Scale"] or {}
				local oldScales = Armor.BoneSetup(ply, scaleNums)
				item:setData("oldScales", oldScales)

				ply:SetArmorBodygroups(tbl.bodygroup or 0)
				item:setData("equipped", true)
				ply.EquippedArmor = id
				ply:SetNW2Bool("EquippedArmor", true)
				ply:SetSkin(tbl.skin or 0)

				if tbl.noBuild == true then
					ply:ResetBuild()
				end

				if tbl.speed then
					local speedMod = (tbl.speed / 100) + 1

					ply:SetWalkSpeed(ply:GetWalkSpeed() * speedMod)
					ply:SetRunSpeed(ply:GetRunSpeed() * speedMod)
				end

				if tbl.OnWear then tbl.OnWear(ply, item) end

				if tbl.powerarmor then

					if tbl.damage > 75 then
						ply:ClearChemEffects()
					end

					if !tbl.noCore then
						if item:getData("power", 0) <= 0 then
							ply.ArmorWasSprintEnabled = ply.ArmorWasSprintEnabled == nil and ply:IsSprintEnabled() or ply.ArmorWasSprintEnabled
							ply:SprintDisable()
						end

						local timerID = ply:SteamID64() .. "_PA"

						timer.Create(timerID, 35, 0, function()
							if !IsValid(ply) or !item then
								timer.Remove(timerID)
								return
							end

							local power = item:getData("power", 0)
							
							if (power - 1) == 0 then
								ply:falloutNotify("[!] Your fusion core has run out of power . . .")
							end

							power = math.Clamp(power - 1, 0, 100)
							item:setData("power", power)

							if power > 0 and power < 10 then
								ply:falloutNotify("[!] Your fusion core is running low. (" .. power .. "%)", "ui/notify.mp3")
							end

							if power <= 0 then
								ply.ArmorWasSprintEnabled = ply.ArmorWasSprintEnabled == nil and ply:IsSprintEnabled() or ply.ArmorWasSprintEnabled
								ply:SprintDisable()
							end
						end)
					end
					
					ply:SetNW2Bool("WearingPA", true)
					ply.isImmune = true -- Immune to radiation
					ply:falloutNotify("You are now immune to radiation")
					ply:falloutNotify("You now invoke & resist more fear")
					ply:SetBloodColor(BLOOD_COLOR_MECH) -- Change blood color
					ply.fearResist = 1.5 -- Increased fear resistance
					ply.fearPower = 0.75 -- Increase fear power
				end

				-- Armor mods from legacy system
				for i, v in pairs(item:getData("mods", {})) do
					if (nut.armor.mods[v]) then
						nut.armor.mods[v].OnRemove(ply, item)
						nut.armor.mods[v].OnEquip(ply, item)
					end
				end

				return false
			end,
			onCanRun = function(item)
				local ply = item.player or item:getOwner()
				local hookResult = hook.Run("CanEquipArmor", item, ply)
				if hookResult != nil then return hookResult end
				return !IsValid(item.entity) and !item:getData("equipped", false) and !ply:GetNW2Bool("EquippedArmor") and (!ply:getChar() or !ply:getChar():getArmor())
			end
		}

		ITEM.functions.Unequip = {
			name = "Unequip",
			icon = "icon16/cross.png",
			onRun = function(item)
				local ply = item.player or item:getOwner()
				local char = ply:getChar()

				if item.powerarmor then
					for k, accessory in pairs(ply.Accessories) do
						local aTbl = Armor.Config.Accessories[accessory]
						if aTbl.powerarmor then
							local aItem = char:getInv():hasItem(accessory)
							if aItem then
								aItem.functions.Unequip.onRun(aItem)
							end
						end
					end
					Armor.ValidateHeavyWeapons(ply) -- Unequips heavy weapons if no skill
				end

				ply:EmitSound("ui/ui_items_generic_up_0" .. math.random(1,4) .. ".mp3")
				//ply:ArmorReset()
				ply.EquippedArmor = nil
				ply:SetNW2Bool("EquippedArmor", false)

				local oldMdl = item:getData("oldModel") or Armor.Config.DefaultBody
				if oldMdl:StartWith("group") then
					ply:SetArmorGroup(oldMdl)
				else
					ply:SetModel(oldMdl)
					ply:SetSkin(0)
				end
				item:setData("equipped", false)

				local anyHair, anyFacial = Armor.GetAnyHair(ply)

				if tbl.hair == false and !anyHair then
					local bodygroups, color = ply:GetFacialCustomization()
					bodygroups[3] = nil

					net.Start("ArmorFaceUpdate")
						net.WriteTable(bodygroups)
						net.WriteTable(color)
						net.WriteBool(!ply:GetForceNoHead())
						net.WriteEntity(ply)
					net.Broadcast()
				end

				if tbl.facialHair == false and !anyFacial then
					local bodygroups, color = ply:GetFacialCustomization()
					bodygroups[2] = nil

					net.Start("ArmorFaceUpdate")
						net.WriteTable(bodygroups)
						net.WriteTable(color)
						net.WriteBool(!ply:GetForceNoHead())
						net.WriteEntity(ply)
					net.Broadcast()
				end

				if tbl.head == true then
					ply:SetFacialCustomization(ply:GetFacialCustomization())
				end

				if tbl.noBuild == true and ply.Build then
					for k, v in pairs(ply.Build) do
						ply:SetBuild(k, v)
					end
				end

				if tbl.speed then
					local speedMod = (tbl.speed / 100) + 1

					ply:SetWalkSpeed(ply:GetWalkSpeed() / speedMod)
					ply:SetRunSpeed(ply:GetRunSpeed() / speedMod)
				end

				if tbl.OnRemove then tbl.OnRemove(ply, item) end

				ply:SetNW2Bool("WearingPA", false)

				if tbl.powerarmor then
					timer.Remove(ply:SteamID64() .. "_PA")
					ply:SetBloodColor(BLOOD_COLOR_RED)

					ply.isImmune = ply:RadImmunity(true) -- Affirm rad immunity state
					ply.fearResist = nut.class.list[ply:getChar():getFaction()].fearResist or nut.config.get("fearRPdefaultFearResist")
					ply.fearPower = nut.class.list[ply:getChar():getFaction()].fearPower or nut.config.get("fearRPdefaultFearPower")
				end

				if tbl.powerarmor and !tbl.noCore and item:getData("power", 0) <= 0 and ply.ArmorWasSprintEnabled != nil then
					ply:SetSprintEnabled(ply.ArmorWasSprintEnabled)
					ply.ArmorWasSprintEnabled = nil
				end

				local oldScales = item:getData("oldScales", {})
				Armor.BoneSetup(ply, oldScales)
				item:setData("oldScales", {})

				-- Armor mods from legacy system
				for i, v in pairs(item:getData("mods", {})) do
					if (nut.armor.mods[v]) then
						nut.armor.mods[v].OnRemove(ply, item)
					end
				end

				return false
			end,
			onCanRun = function(item)
				return !IsValid(item.entity) and item:getData("equipped", false)
			end
		}

		ITEM.functions.zCore = {
			name = "Replace core",
			onRun = function(item)
				local ply = item.player or item:getOwner()
				local char = ply:getChar()

				if !char then return false end

				local core = char:getInv():hasItem("fusion_core")

				if core then
					core:remove()
					item:setData("power", 125)
					ply:falloutNotify("☑ Fusion Core replaced", "shelter/sfx/energycollect_sequence.ogg")
					ply:SetSprintEnabled(ply.ArmorWasSprintEnabled)
					ply.ArmorWasSprintEnabled = nil
				end

				return false
			end,
			onCanRun = function(item)
				return (!IsValid(item.entity) and item.powerarmor and !item.noCore) or false
			end
		}

		ITEM:hook("drop", function(item)
			if item:getData("equipped") then
				item.player:notify("You cannot drop this while it's equipped")

				return false
			end
		end)

		function ITEM:onCanBeTransfered(oldInventory, newInventory)
			return !self:getData("equipped")
		end

		function ITEM:onLoadout()
			if self:getData("equipped") and SERVER and !self.WornThisTick then

				self.WornThisTick = true
				timer.Simple(0, function() if self then self.WornThisTick = false end end)

				jlib.CallAfterTicks(8, function()
					local ply = self.player or self:getOwner()

					if IsValid(ply) then
						ply.EquippedArmor = id
						ply:SetNW2Bool("EquippedArmor", true)

						if tbl.path then
							ply.NoArmorLoop = true
							ply:SetModel(tbl.path)
							ply:ArmorReset()

							if !tbl.head and !tbl.noHead then
								local anyHair, anyFacial = Armor.GetAnyHair(ply)
								local bodygroups, color = ply:GetFacialCustomization()
								if tbl.hair == false or anyHair then
									bodygroups[2] = nil
								end

								if tbl.facialHair or anyFacial then
									bodygroups[3] = nil
								end

								net.Start("ArmorFaceUpdate")
									net.WriteTable(bodygroups)
									net.WriteTable(color)
									net.WriteBool(!ply:GetForceNoHead())
									net.WriteEntity(ply)
								net.Broadcast()
							end

							ply.NoArmorLoop = nil
						elseif tbl.modelType then
							ply:SetArmorGroup(tbl.modelType)
						end

						if tbl.armsModel then
							jlib.CallAfterTicks(2, function()
								ply:OverrideArms(tbl.armsModel)
							end)
						end

						ply:SetSkin(tbl.skin or 0)

						if tbl.noBuild == true then
							ply:ResetBuild()
						end

						if tbl.speed then
							local speedMod = (tbl.speed / 100) + 1

							ply:SetWalkSpeed(ply:GetWalkSpeed() * speedMod)
							ply:SetRunSpeed(ply:GetRunSpeed() * speedMod)
						end

						if tbl.powerarmor then
							ply:SetNW2Bool("WearingPA", true)
						end

						local scaleNums = tbl[(sex or "male") .. "Scale"] or {}
						local oldScales = Armor.BoneSetup(ply, scaleNums)
						self:setData("oldScales", oldScales)

						-- Armor mods from legacy system
						for i, v in pairs(self:getData("mods", {})) do
							if (nut.armor.mods and nut.armor.mods[v]) then
								nut.armor.mods[v].OnRemove(ply, self)
								nut.armor.mods[v].OnEquip(ply, self)
							end
						end

						if tbl.OnRemove then tbl.OnRemove(ply, self) end
						if tbl.OnWear then tbl.OnWear(ply, self) end
					end
				end)
			end
		end

		function ITEM:paintOver(item, w, h)
			if item:getData("equipped") then
				surface.SetDrawColor(110, 255, 110, 100)
			else
				surface.SetDrawColor(255, 110, 110, 100)
			end

			surface.DrawRect(w - 16, h - 16, 12, 12)

			surface.SetDrawColor(wRarity.Config.Rarities[tbl.rarity or 1].color)
			surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
		end

		local lowpower = "color(255, 0, 0)"
		local mediumpower = "color(255, 123, 0)"
		local highpower = "color(55, 255, 0)"

		function ITEM:getDesc()
			local desc = self.desc ..
			string.format("\n- Damage Resistance: %s%%\n- Speed Boost: %s%%\n- Fall Protection: %s\n- Protection Areas: %s\n- Wearable By: %s",
			tbl.damage or 0, tbl.speed or 0, tbl.noFall and "Yes" or "No", tbl.head and "Everywhere" or "Body", tbl.sex and jlib.UpperFirstChar(tbl.sex) .. "s" or "Everyone")

			if (table.Count(self:getData("mods", {})) > 0) then
				desc = desc.."\n\n[ MODULATORS ]"
				for i, v in pairs(self:getData("mods", {})) do
					desc = desc.."\n - "..((nut.armor.mods[v] and nut.armor.mods[v].ArmorDesc()) or "")
				end
			end

			
			if tbl.powerarmor and !tbl.noCore then
				desc = desc .. "\n\n<color(255,0,0)>[FUSION CORE DATA]</color>\n"

				if self:getData("power", 0) > 0 then
					local color = "color(255, 255, 255)"
					local percent = self:getData("power", 0) 

					if percent > 40 and percent < 60 then
						color = mediumpower
					elseif percent < 30 then
						color = lowpower
					else
						color = highpower
					end

					desc = desc .. "POWER: " .. "<" .. color .. ">" .. percent .. "</color>" .. "%"
				else
					desc = desc .. "POWER: " .. "<" .. lowpower .. ">" .. "EMPTY" .. "</color>"
				end
			end

			return desc
		end
	end
end

hook.Add("InitPostEntity", "ArmorItemSetup", Armor.ItemSetup)
if nut and nut.item and nut.item.register then Armor.ItemSetup() end

if !Armor.FactionModelsSetup then
	hook.Add("PlayerSpawn", "ArmorModelSetup", function()
		for k, faction in pairs(nut.faction.teams) do
			if !Armor.Config.UseOldCharCreation[k] then
				print("Setting up models for " .. faction.name)

				table.insert(faction.models, 1, Armor.Consts.BodiesPath .. Armor.Config.DefaultBody .. "/male.mdl")
				table.insert(faction.models, 2, Armor.Consts.BodiesPath .. Armor.Config.DefaultBody .. "/female.mdl")
			end
		end

		Armor.FactionModelsSetup = true

		hook.Remove("PlayerSpawn", "ArmorModelSetup")
	end)
end

hook.Add("EntityTakeDamage", "ArmorProtect", function(ply, dmg)
	if !IsValid(ply) or !ply:IsPlayer() then return end

	local hit = ply:LastHitGroup()

	for aType, id in pairs(ply.Accessories or {}) do
		local tbl = Armor.Config.Accessories[id]

		if tbl.damage and ((hit != HITGROUP_HEAD and !tbl.head) or (hit == HITGROUP_HEAD and tbl.head)) then
			dmg:ScaleDamage(1 - (tbl.damage / 100))
		end
	end

	if ply.EquippedArmor then
		local tbl = Armor.Config.Bodies[ply.EquippedArmor]

		if tbl.damage and (hit != HITGROUP_HEAD or tbl.head) then
			dmg:ScaleDamage(1 - (tbl.damage / 100))
		end
	end
end)


// needs to run after initialization of gamemode
hook.Add("InitPostEntity", "ArmorInitializeNutHooks", function()
	// f1'd
	hook.Add("OnCharKicked", "ArmorReset", function(ply)
		ply.EquippedArmor = nil

		if ply:GetNW2Bool("EquippedArmor") then
			ply:SetNW2Bool("EquippedArmor", false)
		end

		if ply:GetNW2Bool("WearingPA") then
			ply:SetNW2Bool("WearingPA", false)
		end
		
		if ply:getNetVar("powerArmor") then
			ply:setNetVar("powerArmor", nil)
		end

		// remove fusion core timer
		if timer.Exists(ply:SteamID64() .. "_PA") then
			timer.Remove(ply:SteamID64() .. "_PA")
		end
	end)
	
	hook.Add("PlayerFootstep", "ArmorFootsteps", function(ply)
		if ply.EquippedArmor then
			local tbl = Armor.Config.Bodies[ply.EquippedArmor]

			if tbl then
				if isstring(tbl.footstep) then
					ply:EmitSound(tbl.footstep)
					return true
				elseif istable(tbl.footstep) then
					ply:EmitSound(tbl.footstep[math.random(1, #tbl.footstep)])
					return true
				elseif isfunction(tbl.footstep) then
					ply:EmitSound(tbl.footstep())
					return true
				elseif tbl.footstep == false then
					return true
				end
			end
		end
	end)
end)

--Replace SetModel function
local ENTITY = Armor.EntityMeta or FindMetaTable("Entity")
ENTITY.OldSetModel = ENTITY.OldSetModel or ENTITY.SetModel

function ENTITY:SetModel(mdl)
	if !IsValid(self) then
		return
	end

	self:OldSetModel(mdl)

	if self.NoArmorLoop then return end

	if IsValid(self) and self:IsPlayer() then
		if mdl and mdl:StartWith(Armor.Consts.BodiesPath) then
			local group = Armor.GetGroupFromMdl(mdl)

			self.NoArmorLoop = true
			self:SetArmorGroup(group, true)

			if SERVER then
				timer.Simple(0, function()
					Armor.CharacterSetup(self)
					self.NoArmorLoop = nil
				end)
			else
				self.NoArmorLoop = nil
			end
		else
			self:ArmorReset()
			self:ResetAccessories()
			self:ResetBuild()
		end
	end
end

--Build stuff
Armor.BuildInfo = {
	["Fat"] = {
		["Bones"] = {
			"ValveBiped.Bip01_Spine",
			"ValveBiped.Bip01_Spine1"
		},
		["Min"] = 1,
		["Max"] = 1.25,
		["Bodyparts"] = {
			"upper_body"
		},
		["Dimensions"] = {"x", "z"}
	},
	["Strength"] = {
		["Bones"] = {
			"ValveBiped.Bip01_R_Clavicle",
			"ValveBiped.Bip01_L_Clavicle",
			"ValveBiped.Bip01_R_UpperArm",
			"ValveBiped.Bip01_L_UpperArm"
		},
		["Min"] = 0.9,
		["Max"] = 1.1,
		["Bodyparts"] = {
			"left_arm",
			"right_arm"
		},
		["Dimensions"] = {"x", "y"}
	}
}

function PLAYER:SetBuild(var, value)
	local tbl = Armor.BuildInfo[var]

	if !tbl then return end

	value = math.Clamp(value, tbl.Min, tbl.Max)

	if SERVER then
		net.Start("ArmorBuild")
			net.WriteEntity(self)
			net.WriteString(var)
			net.WriteFloat(value)
		net.Broadcast()

		self.Build = self.Build or {}
		self.Build[var] = value

		self:SetNW2Int("Build" .. var, value)
	end

	if CLIENT then
		for i, bone in ipairs(tbl.Bones) do
			local modVector = Vector(1, 1, 1)

			for _, v in ipairs(tbl.Dimensions) do
				modVector[v] = value
			end

			local boneID = self:LookupBone(bone)

			if !boneID then return end

			self:ManipulateBoneScale(boneID, modVector)
		end
	end
end

function PLAYER:ResetBuild()
	if SERVER then
		net.Start("ArmorResetBuild")
			net.WriteEntity(self)
		net.Broadcast()
	end

	if CLIENT then
		for k, tbl in pairs(Armor.BuildInfo) do
			for _, bone in pairs(tbl.Bones) do
				local boneID = self:LookupBone(bone)

				if !boneID then continue end

				self:ManipulateBoneScale(boneID, Vector(1, 1, 1))
			end
		end
	end
end

--PA Check
function PLAYER:WearingPA()
	return self:getNetVar("powerArmor") or self:GetNW2Bool("WearingPA")
end

--Weapon accessories
hook.Add("PlayerSwitchWeapon", "WeaponAccessories", function(ply, oldWep, newWep)
	local newAccessory = IsValid(newWep) and Armor.Config.WeaponAccessories[newWep:GetClass()]
	local oldAccessory = IsValid(oldWep) and Armor.Config.WeaponAccessories[oldWep:GetClass()]
	local newType = newAccessory and Armor.Config.Accessories[newAccessory].type
	local oldType = oldAccessory and Armor.Config.Accessories[oldAccessory].type

	if newAccessory and newType and !ply:GetNW2Bool("SlotTaken" .. newType) then
		ply:AddAccessory(newAccessory)
		ply:SetNW2Bool("SlotTaken" .. newType, false)
	end

	if oldAccessory and oldType and !ply:GetNW2Bool("SlotTaken" .. oldType) then
		ply:RemoveAccessory(oldAccessory)
	end
end)

hook.Add("PlayerSpawn", "ArmorDisablePA", function(ply)
	local armor = ply.EquippedArmor

	jlib.CallAfterTicks(8, function() -- FIXME/NOTE: Required due to spaghet / FIXME: Replace default values with CLASS VALUE CHECKS
		if armor and Armor.Config.Bodies[armor].powerarmor then
			ply:SetNW2Bool("WearingPA", true)
			ply.isImmune = true -- Immune to radiation
			ply.fearResist = 1.5 -- Increased fear resistance
			ply.fearPower = 0.75 -- Increase fear power
			ply:falloutNotify("You are immune to radiation")
			ply:falloutNotify("You invoke & resist more fear")
		end
	end)
end)

hook.Add("PlayerSpawn", "ArmorReset", function(ply)
	jlib.CallAfterTicks(1, function() -- FIXME/NOTE: Ensure this doesn't fuck up other hooks due to execution order
		ply.EquippedArmor = nil
		ply:SetNW2Bool("EquippedArmor", false)
	end)
end)

hook.Add("PlayerLoadedCharacter", "ArmorResetVariables_CharChange", function(ply, char, lastChar)
	local armor = ply.EquippedArmor

	jlib.CallAfterTicks(8, function() -- FIXME/NOTE: Required due to spaghet / FIXME: Replace default values with CLASS VALUE CHECKS
		if armor then
			if Armor.Config.Bodies[armor].powerarmor then
				ply:SetNW2Bool("WearingPA", true)
				ply.isImmune = true -- Immune to radiation
				ply.fearResist = 1.5 -- Increased fear resistance
				ply.fearPower = 0.75 -- Increase fear power
				ply:falloutNotify("You are immune to radiation")
				ply:falloutNotify("You invoke & resist more fear")
			else
				ply:SetNW2Bool("WearingPA", false)
				ply.isImmune = ply:RadImmunity(true) -- Affirm rad immunity state
				ply.fearResist = nut.class.list[char:getFaction()].fearResist or nut.config.get("fearRPdefaultFearResist")
				ply.fearPower = nut.class.list[char:getFaction()].fearPower or nut.config.get("fearRPdefaultFearPower")
			end
		end
	end)

end)

--Precaching
function Armor.PrecachePath(path)
	local files, dirs = file.Find(path .. "/*", "GAME")
	for i, f in ipairs(files) do
		if f:EndsWith(".mdl") then
			print("Precaching model '" .. path .. "/" .. f .. "'.")
			util.PrecacheModel(path .. "/" .. f)
		end
	end

	for i, d in ipairs(dirs) do
		Armor.PrecachePath(path .. "/" .. d)
	end
end

function Armor.PrecachePaths()
	print("Precaching armor models")
	local time = SysTime()

	for i, path in ipairs(Armor.Config.PrecachePaths) do
		Armor.PrecachePath(path)
	end

	print("Finished armor model precache, took: " .. (SysTime() - time) .. "s")
end
if CLIENT then
	hook.Add("Initialize", "ArmorPrecache", Armor.PrecachePaths)
end

function Armor.GetAnyHair(ply)
	local anyHair = false
	local anyFacial = false

	if SERVER then
		for slot, accessoryID in pairs(ply.Accessories or {}) do
			local accessoryTbl = Armor.Config.Accessories[accessoryID]
			if accessoryTbl.hair == false then
				anyHair = true
			end

			if accessoryTbl.facialHair == false then
				anyFacial = true
			end

			if anyHair and anyFacial then break end
		end
	else
		for _, ent in pairs(ply.Accessories) do
			if Armor.Config.Accessories[ent.id].hair == false then
				anyHair = true
			end

			if Armor.Config.Accessories[ent.id].facialHair == false then
				anyFacial = true
			end

			if anyHair and anyFacial then break end
		end
	end

	return anyHair, anyFacial
end

function Armor.PAFootstep()
	return "fallout/powerarmor/step_" .. math.random(1, 4) .. ".wav"
end

-- New descriptions
hook.Add("InitPostEntity", "NewDescCmd", function()
	nut.command.add("chardesc", {
		syntax = "",
		onRun = function(ply)
			if ply.charDescCooldown and ply.charDescCooldown > CurTime() then return end
			local char = ply:getChar()

			jlib.RequestString("Enter your new desc.", function(arguments)

				if #arguments > Armor.Config.DescLength then
					jlib.Announce(ply, Color(255,0,0), "[META] ", Color(255,180,180), "Description must be at most " .. Armor.Config.DescLength .. " characters long.")
					ply:notify("Description change declined")
					return
				elseif #arguments < Armor.Config.DescLenMin then
					jlib.Announce(ply, Color(255,0,0), "[META] ", Color(255,180,180), "Description must be at least " .. Armor.Config.DescLenMin .. " characters long.")
					ply:notify("Description change declined")
					return
				end

				local desc
				if Armor.IsHuman(char) then
					desc = Armor.GenerateDescription(char) .. " | " .. arguments
				else
					desc = arguments
				end

				local info = nut.char.vars.desc
				local result, fault, count = info.onValidate(arguments)

				if (result == false) then
					return "@" .. fault, count
				end

				DiscordEmbed(ply:Nick() .. " ( " .. ply:SteamID() .. " ) " .. "has changed their description from - " .. ply:getChar():getDesc() .. " - to - " .. arguments, "Character Description Change Log" , Color(255,255,0), "Admin")

				ply:getChar():setDesc(desc)
				jlib.Announce(ply, Color(255,0,0), "[META] ", Color(255,180,180), "Your full character description is now:", Color(255,255,255), "\n● " .. ply:getChar():getDesc() .. "\n● Remember: descriptions are known IC details about your character")
				ply:notify("Description changed")
			end, ply, "Apply")

		end
	})
end)

-- Prevents equip if player is in pill
hook.Add("CanEquipArmor", "ArmorNoPills", function(item, ply)
	if SERVER and pk_pills and IsValid(pk_pills.getMappedEnt(ply)) then return false end
end)

-- SetMaterial
if SERVER then
	util.AddNetworkString("ArmorSetSubMaterial")
end

function Armor.SetSubMaterial(ply, part, id, mat)
	if SERVER then
		net.Start("ArmorSetSubMaterial")
			net.WriteEntity(ply)
			net.WriteString(part)
			net.WriteUInt(id, 32)
			net.WriteString(mat)
		net.Broadcast()
	else
		ply[part]:SetSubMaterial(id, mat)
	end
end

if CLIENT then
	net.Receive("ArmorSetSubMaterial", function()
		local ply = net.ReadEntity()
		local part = net.ReadString()
		local id = net.ReadUInt(32)
		local mat = net.ReadString()

		Armor.SetSubMaterial(ply, part, id, mat)
	end)
end

if SERVER then
	util.AddNetworkString("ArmorSetMaterial")
end

function Armor.SetMaterial(ply, part, mat)
	if SERVER then
		net.Start("ArmorSetSubMaterial")
			net.WriteEntity(ply)
			net.WriteString(part)
			net.WriteString(mat)
		net.Broadcast()
	else
		ply[part]:SetMaterial(mat)
	end
end

if CLIENT then
	net.Receive("ArmorSetSubMaterial", function()
		local ply = net.ReadEntity()
		local part = net.ReadString()
		local mat = net.ReadString()

		Armor.SetMaterial(ply, part, mat)
	end)
end

-- Height format util
function Armor.FormatHeight(height)
	return math.Round(math.Clamp(height, Armor.Consts.MinHeight, Armor.Consts.MaxHeight), 2)
end
