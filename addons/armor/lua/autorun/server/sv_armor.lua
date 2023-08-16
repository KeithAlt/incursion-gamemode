--Network strings
util.AddNetworkString("SetArmorGroup")
util.AddNetworkString("ArmorFaceUpdate")
util.AddNetworkString("ArmorAddAccessory")
util.AddNetworkString("ArmorRemoveAccessory")
util.AddNetworkString("ArmorResetAccessories")
util.AddNetworkString("ArmorBuild")
util.AddNetworkString("ArmorResetBuild")
util.AddNetworkString("ArmorCreateChar")
util.AddNetworkString("ArmorSurgeon")
util.AddNetworkString("ArmorSurgeonConfirm")
util.AddNetworkString("ArmorSurgeonFree")
util.AddNetworkString("ArmorOverrideArms")
util.AddNetworkString("ArmorMakeHead")
util.AddNetworkString("ArmorRemoveArms")
util.AddNetworkString("ArmorRemoveHead")

--Adding workshop content to auto DL
-- resource.AddWorkshop("2013271333")
-- resource.AddWorkshop("1535874639")
-- resource.AddWorkshop("1535879447")
-- resource.AddWorkshop("1535881513")
-- resource.AddWorkshop("1535886758")
-- resource.AddWorkshop("1535889447")
-- resource.AddWorkshop("1535891807")
-- resource.AddWorkshop("1535894523")
-- resource.AddWorkshop("1535901447")

--CVars
CreateConVar("Armor_BotDebug", 0, FCVAR_ARCHIVE, "Enables armor features for bots")

--Player meta functions
local PLAYER = Armor.PlayerMeta

--Networking
function PLAYER:NetworkAccessoriesTo(ply)
	if !ply.Accessories then return end

	for aType, id in pairs(ply.Accessories) do
		net.Start("ArmorAddAccessory")
			net.WriteString(id)
			net.WriteEntity(self)
		net.Send(ply)
	end
end

function PLAYER:NetworkArmorGroupTo(ply)
	net.Start("SetArmorGroup")
		net.WriteString(self:GetNW2String("ArmorGroup"))
		net.WriteEntity(self)
		net.WriteString(self:GetSex())
		net.WriteString(self:GetRace())
	net.Send(ply)
end

function PLAYER:NetworkArmsTo(ply)
	net.Start("ArmorOverrideArms")
		net.WriteEntity(self)
		net.WriteString(self.ArmsOverride)
	net.Send(ply)
end

function PLAYER:NetworkBuildTo(ply)
	if !self.Build then return end

	for k, build in pairs(Armor.BuildInfo) do
		if self.Build[k] and build != 1 then
			net.Start("ArmorBuild")
				net.WriteEntity(self)
				net.WriteString(k)
				net.WriteFloat(self.Build[k], 32)
			net.Send(ply)
		end
	end
end

--Character creation
Armor.ExpectedCharData = {
	["armorGroup"] = true,
	["sex"] = true,
	["gender"] = true,
	["race"] = true,
	["faceBodygroups"] = true,
	["hairColor"] = true,
	["build"] = true,
	["skin"] = true,
	["special"] = true,
	["height"] = true
}

net.Receive("ArmorCreateChar", function(len, ply)
	local client = ply
	local data = jlib.ReadCompressedTable()

	local newData = {}

	local maxChars = hook.Run("GetMaxPlayerCharacter", client) or nut.config.get("maxChars", 5)
	local charList = client.nutCharList
	local charCount = table.Count(charList)

	if (charCount >= maxChars) then
		return netstream.Start(client, "charAuthed", "maxCharacters")
	end

	for k, v in pairs(data) do
		if k == "data" then continue end

		local info = nut.char.vars[k]

		if (!info or (!info.onValidate and info.noDisplay)) then
			data[k] = nil
		end
	end

	for k, v in SortedPairsByMemberValue(nut.char.vars, "index") do
		if k == "data" then continue end

		local value = data[k]

		if (v.onValidate) then
			local result = {v.onValidate(value, data, client)}

			if (result[1] == false) then
				return netstream.Start(client, "charAuthed", unpack(result, 2))
			else
				if (result[1] != nil) then
					data[k] = result[1]
				end

				if (v.onAdjust) then
					v.onAdjust(client, data, value, newData)
				end
			end
		end
	end

	for k, v in pairs(data.data) do
		if !Armor.ExpectedCharData[k] then
			return netstream.Start(client, "charAuthed", "Invalid char data")
		end
	end

	data.steamID = client:SteamID64()
	hook.Run("AdjustCreationData", client, data, newData)
	data = table.Merge(data, newData)

	if !data.data or !data.data.faceBodygroups or !Barber.CanUseHair(2, data.data.faceBodygroups[2], ply, data.sex) or !Barber.CanUseHair(3, data.data.faceBodygroups[3], ply, data.sex) then
		return netstream.Start(ply, "charAuthed", "Invalid hair choices")
	end

	local specialSum = jlib.TableSum(data.data.special)

	if data.data and data.data.special and specialSum > Armor.Config.SkillPoints then
		return netstream.Start(client, "charAuthed", "Invalid skills")
	end

	data.data.hasDefaultSkillPoints = true
	data.data.isCharacterCreationV2 = true
	data.data.isNewDesc = true

	local specialLeft = Armor.Config.SkillPoints - specialSum
	if specialLeft > 0 then
		data.data.skillPoints = specialLeft
	end

	data.data.height = Armor.FormatHeight(data.data.height)

	nut.char.create(data, function(id)
		if (IsValid(client)) then
			nut.char.loaded[id]:sync(client)

			netstream.Start(client, "charAuthed", client.nutCharList)
			MsgN("Created character '" .. id .. "' for " .. client:steamName() .. ".")
			hook.Run("OnCharCreated", client, nut.char.loaded[id])

			local char = nut.char.loaded[id]

			char:getInv():add(Armor.Config.DefaultClothing)
			char:setDesc(Armor.GenerateDescription(char) .. " | " .. string.sub(data.desc, 1, Armor.Config.DescLength))
		end
	end)
end)

net.Receive("ArmorSurgeon", function(len, ply)
	local char = nut.char.loaded[ply.EditingChar]

	if !char then
		ply:notify("No character found!")
		return
	end

	if char:getData("isCharacterCreationV2") and !char:hasMoney(Armor.Config.SurgeryCost) then
		ply:notify("You need at least " .. jlib.CommaNumber(Armor.Config.SurgeryCost) .. " caps to do this.")
		return
	end

	local data = jlib.ReadCompressedTable()

	data.data.armorGroup = Armor.GetGroupFromMdl(char:getModel()) or Armor.Config.DefaultBody
	local armorGroup = data.data.armorGroup

	for k, v in pairs(data.data) do
		if !Armor.ExpectedCharData[k] or k == "special" then continue end

		char:setData(k, v)
	end

	char:setModel(Armor.GetMdlFromGroup(armorGroup, data.data.sex))

	if char:getData("isCharacterCreationV2") then
		char:giveMoney(-Armor.Config.SurgeryCost)
	else
		char:setData("isCharacterCreationV2", true)
		local mdl = Armor.GetMdlFromGroup(Armor.Config.DefaultBody, data.data.sex)
		char:setModel(mdl)
		char:setData("newModel", mdl)
	end

	Armor.RegenerateDesc(char)
end)

net.Receive("ArmorSurgeonConfirm", function(len, ply)
	local char = ply:getChar()

	if !char then
		ply:notify("No character found!")
		return
	end

	if !char:hasMoney(Armor.Config.SurgeryCost) then
		ply:notify("You need at least " .. jlib.CommaNumber(Armor.Config.SurgeryCost) .. " caps to do this.")
		return
	end

	char:kick()

	ply.EditingChar = char:getID()

	net.Start("ArmorSurgeonConfirm")
		net.WriteInt(ply.EditingChar, 32)
		net.WriteBool(true)
	net.Send(ply)
end)

Armor.ReCreateAuth = Armor.ReCreateAuth or {}

function Armor.ReCreate(ply, callback)
	if !ply:getChar() then return end

	local ID = ply:getChar():getID()
	ply.EditingChar = ID
	Armor.ReCreateAuth[ID] = true
	ply.EditCallback = callback
	ply:getChar():kick()

	net.Start("ArmorSurgeonConfirm")
		net.WriteInt(ID, 32)
		net.WriteBool(false)
	net.Send(ply)
end

net.Receive("ArmorSurgeonFree", function(len, ply)
	local data = jlib.ReadCompressedTable()
	local char = nut.char.loaded[ply.EditingChar]

	if !char or (char:getData("isCharacterCreationV2") and !Armor.ReCreateAuth[char:getID()]) then
		ply:falloutNotify("You are not authorized to do this.")
		return
	end

	local armorGroup = Armor.GetGroupFromMdl(char:getModel()) or Armor.Config.DefaultBody
	local model = Armor.GetMdlFromGroup(armorGroup, data.data.sex)
	char:setModel(model)
	char:setData("newModel", model)

	for k, v in pairs(data.data) do
		if !Armor.ExpectedCharData[k] or k == "special" then continue end

		char:setData(k, v)
	end

	ply.EditingChar = nil
	Armor.ReCreateAuth[char:getID()] = nil

	if isfunction(ply.EditCallback) then
		ply.EditCallback()
	end
	ply.EditCallback = nil

	Armor.RegenerateDesc(char)
end)

--Syncing to players upon connect
hook.Add("PlayerInitialSpawn", "ArmorSync", function(newPly)
	jlib.CallAfterTicks(10, function()
		for i, ply in ipairs(player.GetAll()) do
			if ply.ArmsOverride then
				ply:NetworkArmsTo(newPly)
			end

			ply:NetworkBuildTo(newPly)
		end
	end)
end)

--Setting player's look based on their character settings
function Armor.CharacterSetup(ply, char, doMdl)
	char = char or ply:getChar()

	local mdl = char:getModel()

	ply:ArmorReset()
	ply:ResetAccessories()
	ply:ResetBuild()

	timer.Simple(0, function()
		local accessories = char:getData("accessories", {})
		local armorGroup = char:getData("armorGroup", Armor.GetGroupFromMdl(mdl))
		local sex = char:getData("sex", "male")
		local race = char:getData("race", "caucasian")
		local faceBodygroups = char:getData("faceBodygroups", {})
		local faceColor = char:getData("hairColor", Color(0, 0, 0, 255))
		local build = char:getData("build", {})
		local skin = char:getData("skin", 0)

		ply:SetHeadSkin(skin)
		ply:SetSex(sex)
		ply:SetRace(race)

		if !mdl:StartWith(Armor.Consts.BodiesPath) then
			ply:SetFacialCustomization(faceBodygroups, faceColor, true)

			return
		end

		timer.Simple(0, function()
			ply:SetFacialCustomization(faceBodygroups, faceColor)

			if armorGroup then
				ply:SetArmorGroup(armorGroup, doMdl != true)
			end

			jlib.CallAfterTicks(8, function()
				for aType, id in pairs(accessories) do
					ply:AddAccessory(id)
				end

				for _, item in pairs(char:getInv():getItems()) do
					if item.aID and item:getData("equipped", false) then
						ply:AddAccessory(item.aID)
					end
				end
			end)

			for k, b in pairs(build) do
				if Armor.BuildInfo[k] and b != 1 then
					ply:SetBuild(k, b)
				end
			end
		end)
	end)
end

hook.Add("PlayerLoadedChar", "ArmorForceCreation", function(ply, char, oldChar)
	if char:getData("newModel") then
		for k,v in pairs(char:getInv():getItems()) do
			if v.isArmor then
				v:setData("equipped", false)
			end
		end

		char:setData("oldMdl", nil)
		char:setModel(char:getData("newModel"))
		char:setData("newModel", nil)
	end

	if !char:getData("isCharacterCreationV2") and !Armor.Config.UseOldCharCreation[nut.faction.indices[char:getFaction()].uniqueID] then
		net.Start("ArmorSurgeon")
			net.WriteBool(true)
		net.Send(ply)

		ply:notify("You must re-customize your character as this character has not yet been upgraded to the new character customization.")
	end
end)

hook.Add("PlayerLoadedChar", "ArmorSync", function(ply, char, oldChar)
	Armor.CharacterSetup(ply, char, true)
end)

hook.Add("PlayerLoadedChar", "DefaultSkillPoints", function(ply, char, oldChar)
	if !char:getData("hasDefaultSkillPoints", false) then
		char:setData("skillPoints", char:getData("skillPoints", 0) + Armor.Config.SkillPoints)
		char:setData("hasDefaultSkillPoints", true)
		ply:ChatPrint("Your character has been given " .. Armor.Config.SkillPoints .. " skill points.")
	end
end)

hook.Add("PlayerLoadedChar", "ArmorOnRemove", function(ply, char, oldChar)
	if oldChar then
		for _, item in pairs(oldChar:getInv():getItems()) do
			if item.isjArmor and item.configTbl.OnRemove then
				item.configTbl.OnRemove(ply)
			end
		end

		-- Re-enable sprint for them
		ply:SprintEnable()
	end
end)

hook.Add("GetFallDamage", "ArmorProtect", function(ply, speed)
	if ply.EquippedArmor then
		local tbl = Armor.Config.Bodies[ply.EquippedArmor]

		if tbl.noFall then
			return 0
		end
	end
end)

--Automatically make all bots use armor groups when they spawn
hook.Add("PlayerInitialSpawn", "ArmorBotSetup", function(ply)
	if GetConVar("Armor_BotDebug"):GetBool() then
		jlib.CallAfterTicks(6, function()
			if IsValid(ply) and ply:IsBot() then
				local accessoryIDs = table.GetKeys(Armor.Config.Accessories)
				local races = table.GetKeys(Armor.Consts.ValidRaces)
				local sexs = table.GetKeys(Armor.Consts.ValidSexes)
				local _, armorGroups = file.Find("models/thespireroleplay/humans/*", "GAME")

				for k, v in pairs(armorGroups) do
					if !v:StartWith("group") then
						table.remove(armorGroups, k)
					end
				end

				local sex = sexs[math.random(#sexs)]
				local race = races[math.random(#races)]
				local armorGroup = armorGroups[math.random(#armorGroups)]
				local bodygroups = {0, math.random(0, 21), math.random(0, 20), 0}
				local color = ColorRand()
				local accessory = accessoryIDs[math.random(#accessoryIDs)]

				print("Spawning bot with random armor values")
				print("-------------------------------------")
				print("Sex: " .. sex)
				print("Race: " .. race)
				print("Armor Group: " .. armorGroup)
				print("Hair: " .. bodygroups[2])
				print("Facial Hair: " .. bodygroups[3])
				print("Hair Color: " .. tostring(color))
				print("Accessory: " .. accessory)
				print("-------------------------------------")

				ply:SetSex(sex)
				ply:SetRace(race)
				timer.Simple(0, function()
					ply:SetArmorGroup(armorGroup)
					ply:SetFacialCustomization(bodygroups, color)
				end)
				ply:AddAccessory(accessory)
			end
		end)
	end
end)

function Armor.CheckForLegacyDuplicates()
	for legacyID, _ in pairs(nut.armor.armors) do
		legacyID = "armor_" .. legacyID

		for newID, _ in pairs(Armor.Config.Bodies) do
			if newID == legacyID then
				print("Armor with ID " .. newID .. " exists in both legacy and new armor systems.")
			end
		end
	end
end

--RunSpeed helper
function Armor.GetRunSpeed(ply)
	local char = ply:getChar()
	local runSpeed = nut.config.get("runSpeed") + (char and char:getAttrib("stm", 0) or 0)

	if ply.EquippedArmor then
		local armorTbl = Armor.Config.Bodies[ply.EquippedArmor]
		return runSpeed * (((armorTbl.speed or 0) / 100) + 1)
	elseif char and char:getArmor() then
		local armorTbl = nut.armor.armors[char:getArmor().type]
		return runSpeed * (((armorTbl.speedBoost or 0) / 100) + 1)
	end

	return runSpeed
end

-- Human check
function Armor.IsHuman(char)
	local mdl = char:getData("oldMdl", nil) and char:getData("oldMdl") or char:getModel()
	return mdl:StartWith(Armor.Consts.BodiesPath) or mdl:StartWith("group")
end

-- New descriptions
function Armor.GenerateDescription(char)
	if !Armor.IsHuman(char) then
		return ""
	end

	local desc = "%s | %s | %sft Tall | %s | %s"

	local sex = char:getData("sex", "male")
	local race = char:getData("race", "caucasian")
	local build = char:getData("build", {})
	build.Fat = build.Fat or 1
	build.Strength = build.Strength or 1

	desc = string.format(desc,
		jlib.UpperFirstChar(sex),
		jlib.UpperFirstChar(race),
		char:getData("height", nil) or math.Round(math.Rand(Armor.Consts.MinHeight, Armor.Consts.MaxHeight), 2),
		build.Strength >= 1.05 and "Strong Build" or (build.Strength < 0.95 and "Weak Build" or "Average Build"),
		build.Fat >= 1.2 and "Overweight" or (build.Fat < 1.1 and "Underweight" or "Average Weight")
	)

	char:setData("generatedDesc", desc)

	return desc
end

function Armor.RegenerateDesc(char)
	local generatedDesc = char:getData("generatedDesc", "")
	char.BrandEdit = true

	if #generatedDesc > 0 then
		generatedDesc = generatedDesc .. " | "
		local fullDesc = char:getDesc()
		local customDesc = table.concat(fullDesc:Split(generatedDesc))

		char:setDesc(customDesc)
	end

	char:setDesc(Armor.GenerateDescription(char) .. " | " .. char:getDesc())
	char.BrandEdit = nil
end

hook.Add("PlayerLoadedChar", "NewDesc", function(ply, char, oldChar)
	if !char:getData("isNewDesc", false) and Armor.IsHuman(char) then
		char:setDesc(Armor.GenerateDescription(char) .. " | " .. string.sub(char:getDesc(), 1, Armor.Config.DescLength))
		char:setData("isNewDesc", true)
	end

	if !char:getData("height", nil) and Armor.IsHuman(char) then
		ply:falloutNotify("Choose a height for your character")
		jlib.RequestFloat("Character Height", function(float)
			char:setData("height", Armor.FormatHeight(float))
			char:setData("generatedDesc", nil)
			if char:getData("isNewDesc", false) then
				local split = string.Split(char:getDesc(), "|")
				char:setDesc(Armor.GenerateDescription(char) .. " | " .. string.Trim(split[#split]))
			else
				char:setDesc(Armor.GenerateDescription(char) .. " | " .. string.sub(char:getDesc(), 1, Armor.Config.DescLength))
			end
		end, Armor.Consts.MinHeight, Armor.Consts.MaxHeight, 2, ply)
	end
end)

function Armor.SetRace(ply, newRace)
	if !Armor.Consts.ValidRaces[newRace] then
		error("Invalid race")
	end

	ply:SetRace(newRace)

	local char = ply:getChar()
	char:setData("race", newRace)
end

function Armor.SetSex(ply, newSex)
	if !Armor.Consts.ValidSexes[newSex] then
		error("Invalid sex")
	end

	ply:SetSex(newSex)

	local char = ply:getChar()
	char:setData("sex", newSex)
end

function Armor.SetSkin(ply, newSkin)
	if !isnumber(newSkin) or newSkin < 0 or newSkin > 6 then
		error("Invalid skin")
	end

	ply:SetHeadSkin(newSkin)

	local char = ply:getChar()
	char:setData("skin", newSkin)
end

function Armor.SetHairColor(ply, newHairColor)
	if !IsColor(newHairColor) then
		error("Invalid color")
	end

	ply:SetNW2Int("ArmorHairR", newHairColor.r)
	ply:SetNW2Int("ArmorHairG", newHairColor.g)
	ply:SetNW2Int("ArmorHairB", newHairColor.b)

	local char = ply:getChar()
	char:setData("hairColor", newHairColor)
end

-- Unequip heavy weapons post unequip of PA and no skill
function Armor.ValidateHeavyWeapons(ply)
	local char = ply:getChar()

	if char and !ply:hasSkerk("heavyweapons") then
		for _, item in pairs(char:getInv():getItems()) do
			if item.PA and item.isSwep and item:getData("equipped", false) == true then
				item.player = ply
				item.functions.UnEquip.onRun(item)
				ply:notify("Your " .. (item.name or "heavy weapon") .. " has been unequipped")
			end
		end
	end
end
