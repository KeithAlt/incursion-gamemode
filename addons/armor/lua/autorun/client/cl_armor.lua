--Initial connect sync/setup
hook.Add("InitPostEntity", "ArmorSetup", function()
	for i, ply in ipairs(player.GetAll()) do
		if ply:GetArmorGroup() != "" then
			ply:SetArmorGroup(ply:GetArmorGroup())

			ply:SetFacialCustomization(ply:GetFacialCustomization())

			-- local hasHead = IsValid(ply.Head)

			for _, accessoryID in ipairs(ply:GetAccessories()) do
				ply:AddAccessory(accessoryID)

				-- if hasHead then
				-- 	local aTbl = Armor.Config.Accessories[accessoryID]

				-- 	if aTbl.hair == false then
				-- 		ply.Head:SetBodygroup(2, 0)
				-- 	end

				-- 	if aTbl.facialHair == false then
				-- 		ply.Head:SetBodygroup(3, 0)
				-- 	end
				-- end
			end
		end
	end
end)

--Networking
net.Receive("SetArmorGroup", function()
	local group = net.ReadString()
	local ply = net.ReadEntity()
	local sex = net.ReadString()
	local race = net.ReadString()
	local forceArms = net.ReadBool()
	local forceHead = net.ReadBool()

	if !IsValid(ply) then return end

	if group == "" then
		ply:ArmorReset()
		return
	end

	ply:SetArmorGroup(group, nil, sex, race, forceArms, forceHead)
end)

net.Receive("ArmorFaceUpdate", function()
	local bodygroups = net.ReadTable()
	local color = net.ReadTable()
	local forceHead = net.ReadBool()
	local ply = net.ReadEntity()

	if !IsValid(ply) then return end

	ply:SetFacialCustomization(bodygroups, color, nil, forceHead)
end)

net.Receive("ArmorAddAccessory", function()
	local id = net.ReadString()
	local ply = net.ReadEntity()

	if !IsValid(ply) then return end

	ply:AddAccessory(id)
end)

net.Receive("ArmorRemoveAccessory", function()
	local id = net.ReadString()
	local ply = net.ReadEntity()

	if !IsValid(ply) then return end

	ply:RemoveAccessory(id)
end)

net.Receive("ArmorResetAccessories", function()
	local ply = net.ReadEntity()

	if !IsValid(ply) then return end

	ply:ResetAccessories()
end)

net.Receive("ArmorBuild", function()
	local ply = net.ReadEntity()
	local var = net.ReadString()
	local value = net.ReadFloat()

	if !IsValid(ply) then return end

	ply:SetBuild(var, value)
end)

net.Receive("ArmorResetBuild", function()
	local ply = net.ReadEntity()

	if !IsValid(ply) then return end

	ply:ResetBuild()
end)

net.Receive("ArmorOverrideArms", function()
	local ply = net.ReadEntity()
	local mdl = net.ReadString()
	local force = net.ReadBool()

	if !IsValid(ply) then return end

	ply:OverrideArms(mdl, force)
end)

net.Receive("ArmorSurgeon", function()
	local skipWarning = net.ReadBool()

	if skipWarning then
		net.Start("ArmorSurgeonConfirm")
		net.SendToServer()
	else
		Derma_Query("This will unload your character and allow you to change their look.", "", "OK", function()
			net.Start("ArmorSurgeonConfirm")
			net.SendToServer()
		end, "Cancel")
	end
end)

net.Receive("ArmorSurgeonConfirm", function()
	local charID = net.ReadInt(32)
	local cost = net.ReadBool()

	if IsValid(nut.gui.char) then
		nut.gui.char:Remove()
		nut.gui.char = nil
	end

	if IsValid(nut.plugin.list.motd.boxPanel) then
		nut.plugin.list.motd.boxPanel:Remove()
		nut.plugin.list.motd.boxPanel = nil
	end

	if IsValid(nut.menuSound) then
		nut.menuSound:Stop()
		nut.menuSound = nil
	end

	local pnl = vgui.Create("CharacterCustomization")
	pnl:MakePopup()
	pnl:SetSurgeon(true)
	pnl.Cost = cost
	pnl.char = nut.char.loaded[charID]
end)

net.Receive("ArmorMakeHead", function()
	local ply = net.ReadEntity()
	local bool = net.ReadBool()
	ply:MakeHead(bool)
end)

net.Receive("ArmorRemoveHead", function()
	local ply = net.ReadEntity()
	ply:RemoveHead()
end)

net.Receive("ArmorRemoveArms", function()
	local ply = net.ReadEntity()
	ply:RemoveArms()
end)

--Viewmodel hands
function Armor.UpdateViewModelHands(ply, group)
	local path = Armor.Config.ViewmodelArms or (Armor.Consts.BodiesPath .. group .. "/arms.mdl")

	if IsValid(ply) then
		local hands = ply:GetHands()
		hands:SetModel(path)
	end
end

gameevent.Listen("player_spawn")
hook.Add("player_spawn", "ArmorViewmodelHands", function(dat)
	local ply = Player(dat.userid)

	if !IsValid(ply) then return end

	local group = ply:GetNW2String("ArmorGroup")

	if group != "" then
		jlib.CallAfterTicks(3, function()
			Armor.UpdateViewModelHands(ply, group)
		end)
	end
end)

--Customization menu
function Armor.PrepareFrames()
	Armor.SPECIALFrames = {}
	Armor.SPECIALCache = {}

	local dir = "materials/armorui/"

	local _, dirs =  file.Find(dir .. "*", "GAME")

	for _, v in pairs(dirs) do
		local fullDir = dir .. v .. "/"
		local images = file.Find(fullDir .. "*.png", "GAME")

		local sortedImages = {}

		for _, image in pairs(images) do
			local split = string.Split(image:StripExtension(), "-")
			local frameNumber = split[1]

			sortedImages[tonumber(frameNumber)] = image
		end

		local j = 1

		for _, image in pairs(sortedImages) do
			local imgPath = fullDir .. image

			local split = string.Split(image:StripExtension(), "-")
			local frameNumber = split[1]
			local frameCount = split[2]

			Armor.SPECIALCache[v] = Armor.SPECIALCache[v] or {}
			Armor.SPECIALCache[v][frameNumber] = Armor.SPECIALCache[v][frameNumber] or Material(imgPath)
			local frame = Armor.SPECIALCache[v][frameNumber]

			Armor.SPECIALFrames[v] = Armor.SPECIALFrames[v] or {}

			for i = j, j + (frameCount - 1) do
				Armor.SPECIALFrames[v][i] = frame
				j = j + 1
			end
		end
	end
end
Armor.PrepareFrames()

function Armor.PrepareSounds()
	Armor.SPECIALSounds = {}

	for _, fileName in pairs(file.Find("sound/armorui/*.wav", "GAME")) do
		Armor.SPECIALSounds[fileName:StripExtension()] = "armorui/" .. fileName
	end
end
Armor.PrepareSounds()

Armor.PanelDefaults = {
	["Sex"] = "male",
	["HairColor"] = Color(255, 217, 94, 255),
	["FaceBodygroups"] = {0, 3, 0, 0}
}

Armor.SexDefaults = {
	["male"] = {
		["HairColor"] = Color(255, 217, 94, 255),
		["FaceBodygroups"] = {0, 3, 0, 0}
	},
	["female"] = {
		["HairColor"] = Color(255, 217, 94, 255),
		["FaceBodygroups"] = {0, 6, 0, 0}
	}
}

surface.CreateFont("ArmorUI", {font = "Roboto", size = math.min(ScreenScale(9), 25), weight = 500})
surface.CreateFont("ArmorUISmall", {font = "Roboto", size = math.min(ScreenScale(6), 25), weight = 500})

function Armor.RandomName()
	local f = {
		"Addison", "Ashley", "Arron", "Bailey", "Blaine",
		"Casey", "Corey", "Darren", "Emerson", "Evan", "Florian",
		"Haiden", "Hayley", "Jamie", "Jesse", "Kiley",
		"Kerry", "Kelsey", "London", "Lee", "Lonnie",
		"Marley", "Morgan", "MacKenzie", "Payton", "Parker",
		"Reese", "Reed", "Robin", "Regan", "Sean",
		"Skylar", "Skye", "Sydney", "Shay", "Silver",
		"Taylor", "Tory", "Tyne", "Weasley", "Wynne"
	}

	local l = {
		"Smith", "Jones", "Brown", "Johnson", "Williams",
		"Miller", "Taylor", "Wilson", "Davis", "White",
		"Clark", "Hall", "Thomas", "Thompson", "Moore",
		"Hill", "Walker", "Anderson", "Wright", "Martin",
		"Wood", "Allen", "Robinson", "Lewis", "Scott",
		"Young", "Jackson", "Adams", "Tryniski", "Green",
		"Evans", "King", "Baker", "John", "Harris",
		"Roberts", "Campbell", "James", "Stewart", "Lee"
	}

	return table.Random(f), table.Random(l)
end

Armor.PanelMaterials = {}

for _, f in pairs(file.Find("materials/charactercreation/*.png", "GAME")) do
	Armor.PanelMaterials[string.StripExtension(f)] = Material("charactercreation/" .. f)
end

local PANEL = {}

function PANEL:Init()
	if IsValid(nut.gui.charBuilder) then
		nut.gui.charBuilder:Remove()
	end

	nut.gui.charBuilder = self

	if IsValid(self:GetParent()) then
		self:SetSize(self:GetParent():GetWide(), self:GetParent():GetTall())
	else
		self:SetSize(ScrW(), ScrH())
	end
	self:Center()

	self.Options = {}
	self.Options.Sex = Armor.PanelDefaults.Sex or "male"
	self.Options.Race = Armor.PanelDefaults.Race or "caucasian"
	self.Options.Build = Armor.PanelDefaults.Build or {}
	self.Options.FaceBodygroups = Armor.PanelDefaults.FaceBodygroups or {0, 0, 0, 0}
	self.Options.HairColor = Armor.PanelDefaults.HairColor or Color(255, 255, 255, 255)
	self.Options.SPECIAL = {S = 0, P = 0, E = 0, C = 0, I = 0, A = 0, L = 0}
	self.CSEnts = {}
	self.Editing = {}
	self.NSData = {
		["desc"] = "An average wastelander traveling the wastes.",
		["model"] = 1
	}
	self.NSData.faction = self.NSData.faction or nut.faction.teams.wastelander.index

	local pnl = self:Add("DPanel")
	pnl:SetSize(self:GetWide(), self:GetTall())
	pnl:Center()

	local preview = pnl:Add("DModelPanel")
	preview:SetSize(pnl:GetWide(), pnl:GetTall())
	preview.Setup = function(s)
		for i, e in ipairs(self.CSEnts) do
			if IsValid(e.Ent) then
				e.Ent:Remove()
			end
		end

		local headPath
		if self.Options.Sex == "ghoul" then
			headPath = "models/lazarusroleplay/heads/ghoul_default.mdl"
		else
			headPath = Armor.Consts.HeadPath .. self.Options.Sex .. "_" .. self.Options.Race .. ".mdl"
		end

		if s:GetModel() != headPath then
			s:SetModel(headPath)
		end
		s:SetColor(self.Options.HairColor)

		local ent = s.Entity

		ent:ResetSequence(2)
		ent:SetAngles(Angle(0, s.StartDiff or 0, 0))

		for i, v in ipairs(self.Options.FaceBodygroups) do
			ent:SetBodygroup(i, v)
		end

		for k, v in pairs(self.Options.Build) do
			for i, boneName in ipairs(Armor.BuildInfo[k].Bones) do
				local modVector = Vector(1, 1, 1)

				for _, b in pairs(Armor.BuildInfo[k].Dimensions or {}) do
					modVector[b] = v
				end

				ent:ManipulateBoneScale(ent:LookupBone(boneName), modVector)
			end
		end

		local bodyEnt
		if self.Clothes then
			local clothes = Armor.Config.Bodies[Armor.Config.DefaultClothing]
			bodyEnt = ClientsideModel(Armor.Consts.BodiesPath .. clothes.modelType .. "/" .. self.Options.Sex .. ".mdl", RENDERGROUP_OPAQUE)
			bodyEnt:SetSkin(clothes.skin or 0)
			bodyEnt:SetBodygroup(0, clothes.bodygroup or 0)
		else
			bodyEnt = ClientsideModel(Armor.Consts.BodiesPath .. Armor.Config.DefaultBody .. "/" .. self.Options.Sex .. ".mdl", RENDERGROUP_OPAQUE)
		end
		bodyEnt:SetParent(ent)
		bodyEnt:AddEffects(EF_BONEMERGE)
		table.insert(self.CSEnts, {["Ent"] = bodyEnt})

		local armsEnt
		if self.Clothes then
			local clothes = Armor.Config.Bodies[Armor.Config.DefaultClothing]
			armsEnt = ClientsideModel(Armor.Consts.BodiesPath .. clothes.modelType .. "/arms/" .. self.Options.Sex .. "_arm.mdl", RENDERGROUP_OPAQUE)
		else
			armsEnt = ClientsideModel(Armor.Consts.BodiesPath .. Armor.Config.DefaultBody .. "/arms/" .. self.Options.Sex .. "_arm.mdl", RENDERGROUP_OPAQUE)
		end
		armsEnt:SetParent(ent)
		armsEnt:AddEffects(EF_BONEMERGE)

		local skin
		if self.Options.Sex != "ghoul" then
			skin = Armor.Consts.RaceSkins[self.Options.Race]
			if (self.Options.Build.Strength or 1) > (1 + Armor.BuildInfo.Strength.Max) / 2 then
				skin = skin + 1
			end
		else
			skin = self.Options.GhoulSkin or 0
		end

		armsEnt:SetSkin(skin)

		preview.armsEnt = armsEnt

		table.insert(self.CSEnts, {["Ent"] = armsEnt, ["Color"] = {1, 1, 1}})

        s.LayoutEntity = function() s:RunAnimation() end
    end
	preview.ZoomOnBone = function(s, bone, distance, smooth, speed, callback)
		hook.Remove("Think", "ZoomOnBone")

		local ent = s.Entity

		local boneNum
		if isstring(bone) then
			boneNum = ent:LookupBone(bone)
		elseif isnumber(bone) then
			boneNum = bone
		end

		if !boneNum then return end

		s:SetFOV(90)
		local bonePos = ent:GetBonePosition(boneNum)
		local finalPos = bonePos + distance

		if smooth then
			local curPos

			hook.Add("Think", "ZoomOnBone", function()
				ent = IsValid(ent) and ent or s.Entity

				if !IsValid(s) or !IsValid(ent) then
					hook.Remove("Think", "ZoomOnBone")
					return
				end

				curPos = s:GetCamPos()
				local dist = curPos:Distance(finalPos)
				local remaining = finalPos - curPos
				local adjust = remaining * (RealFrameTime() * (speed or 2))

				s:SetCamPos(curPos + adjust)
				s:SetLookAt(bonePos)
				ent:SetEyeTarget(s:GetCamPos())

				if dist < 0.001 then
					hook.Remove("Think", "ZoomOnBone")

					if isfunction(callback) then
						callback()
					end

					return
				end
			end)
		else
			s:SetLookAt(bonePos)
			s:SetCamPos(finalPos)
			ent:SetEyeTarget(s:GetCamPos())
		end

		preview.LookingAtBone = boneNum
	end
	preview.OnRemove = function()
		hook.Remove("Think", "ZoomOnBone")
	end
	preview:Setup()
	preview:SetAmbientLight(Color(160, 160, 160, 255))
	preview:ZoomOnBone("ValveBiped.Bip01_Pelvis", Vector(80, 0, 0))

	--Hacky shit to color each model in the panel differently
	preview.Paint = function(s, w, h)
		if (!IsValid(s.Entity)) then return end

		local x, y = s:LocalToScreen(0, 0)

		s:LayoutEntity(s.Entity)

		local ang = s.aLookAngle
		if !ang then
			ang = (s.vLookatPos - s.vCamPos):Angle()
		end

		cam.Start3D(s.vCamPos, ang, s.fFOV, x, y, w, h, 5, s.FarZ)
			//render.SuppressEngineLighting(true)
			render.SetLightingOrigin(s.Entity:GetPos())
			render.ResetModelLighting(s.colAmbientLight.r / 255, s.colAmbientLight.g / 255, s.colAmbientLight.b / 255)
			render.SetBlend((s:GetAlpha() / 255) * (s.colColor.a / 255))

			for i, e in ipairs(self.CSEnts) do
				if IsValid(e.Ent) then
					if e.Color and self.Options.Sex != "ghoul" then
						render.SetColorModulation(unpack(e.Color))
					else
						render.SetColorModulation(1, 1, 1)
					end
					e.Ent:DrawModel()
				end
			end

			if self.Options.Sex != "ghoul" then
				render.SetColorModulation(s.colColor.r / 255, s.colColor.g / 255, s.colColor.b / 255)
			end

			s:DrawModel()

			render.SuppressEngineLighting(false)
		cam.End3D()

		s.LastPaint = RealTime()
	end

	preview.OnMousePressed = function(s, btn)
		if btn == MOUSE_LEFT then
			if s.CurPosX then
				s.CurPosX = nil
				s.StartDiff = s.diff
			else
				s.CurPosX = input.GetCursorPos()
			end
		end

		if btn == MOUSE_RIGHT then
			if preview.LookingAtBone != preview.Entity:LookupBone("ValveBiped.Bip01_Head1") then
				preview:ZoomOnBone("ValveBiped.Bip01_Head1", Vector(20, 0, 0), true)
			else
				preview:ZoomOnBone("ValveBiped.Bip01_Pelvis", Vector(80, 0, 0))
			end
		end
	end

	preview.OnMouseReleased = function(s, btn)
		if btn == MOUSE_LEFT then
			s.CurPosX = nil
			s.StartDiff = s.diff
		end
	end

	preview.Think = function(s)
		if s.CurPosX then
			local x, _ = input.GetCursorPos()
			s.diff = (s.StartDiff or 0) + (s.CurPosX - x)

			s.Entity:SetAngles(Angle(0, s.diff, 0))
		end
	end

	local optionsFrame = self:Add("UI_DFrame")
	optionsFrame:SetTitle("Options")
	optionsFrame:SetSize(self:GetWide() * 0.2, self:GetTall() * 0.7)
	optionsFrame:SetPos(self:GetWide() - optionsFrame:GetWide() - 35, 0)
	optionsFrame:CenterVertical()

	local optionsPnl = optionsFrame:Add("DScrollPanel")
	optionsPnl:Dock(FILL)
	optionsPnl.AddSpacer = function(s)
		local spacer = s:Add("DPanel")
		spacer:SetTall(4)
		spacer.Paint = function(_, w, h)
			surface.SetDrawColor(Color(0, 0, 0, 255))
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(nut.gui.palette.color_primary)
			surface.DrawRect(1, 1, w - 2, h - 2)
		end
		spacer:DockMargin(0, 1, 0, 1)
		spacer:Dock(TOP)
	end

	local origX, origY = 2560, 1440
	local xMod, yMod = ScrW() / origX, ScrH() / origY

	local fW, fH = 278 * xMod, 283 * yMod
	local pad = 80

	local falloutBoy = optionsPnl:Add("DPanel")
	falloutBoy:SetSize(fW + pad, fH + pad)
	falloutBoy.Paint = function(s, w, h)
		s.Pulsate = s.Pulsate or 255
		s.Increasing = s.Increasing or false
		s.Col = s.Col or table.Copy(nut.gui.palette.color_primary)

		for name, material in pairs(Armor.PanelMaterials) do
			if name:EndsWith("_broken") then continue end

			if self.Editing[name] then
				surface.SetDrawColor(s.Col)
				surface.SetMaterial(Armor.PanelMaterials[name .. "_broken"])
			else
				surface.SetDrawColor(nut.gui.palette.color_primary)
				surface.SetMaterial(material)
			end

			surface.DrawTexturedRect((w / 2) - (fW / 2), (h / 2) - (fH / 2), fW, fH)
		end

		//DisableClipping(true)
		surface.SetDrawColor(Color(0, 0, 0))
		surface.DrawOutlinedRect(2, 2, w - 1, h - 1)

		surface.SetDrawColor(nut.gui.palette.color_primary)
		surface.DrawOutlinedRect(0, 0, w, h)
		surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
		//DisableClipping(false)

		local change = RealFrameTime() * 200

		if s.Increasing then
			s.Pulsate = s.Pulsate + change

			if s.Pulsate >= 255 then
				s.Increasing = false
			end
		else
			s.Pulsate = s.Pulsate - change

			if s.Pulsate <= 255 * 0.2 then
				s.Increasing = true
			end
		end

		s.Col.a = math.Clamp(s.Pulsate, 0, 255)
	end
	falloutBoy:Dock(TOP)
	falloutBoy:Center()

	local raceChoice = 1
	local raceBtn = optionsPnl:Add("UI_DButton")

	local skinChoice = 0

	local function RaceDoClickGhoul()
		-- Skip 3
		if skinChoice == 2 then
			skinChoice = skinChoice + 2
		else
			skinChoice = skinChoice + 1
		end

		if skinChoice >= preview.Entity:SkinCount() then
			skinChoice = 0
		end

		preview.Entity:SetSkin(skinChoice)
		preview.armsEnt:SetSkin(skinChoice)
		self.Options.GhoulSkin = skinChoice
	end

	local function RaceDoClickOther()
		raceChoice = raceChoice + 1
		if raceChoice > table.Count(Armor.Consts.ValidRaces) then
			raceChoice = 1
		end

		self.Options.Race = table.GetKeys(Armor.Consts.ValidRaces)[raceChoice]
		preview:Setup()
		raceBtn:SetText("Race: " .. jlib.UpperFirstChar(self.Options.Race))

		self:SetEditing({"head", "right_arm", "left_arm"})
		preview:ZoomOnBone("ValveBiped.Bip01_Pelvis", Vector(80, 0, 0))
	end

	raceBtn:SetText("Race: " .. jlib.UpperFirstChar(self.Options.Race))
	raceBtn.DoClick = RaceDoClickOther
	raceBtn.Think = function(s)
		if self.Options.Sex == "ghoul" and s.Setting != "ghoul" then
			s.DoClick = RaceDoClickGhoul
			s:SetText("Skin")
		elseif self.Options.Sex != "ghoul" and s.Setting == "ghoul" then
			s.DoClick = RaceDoClickOther
			s:SetText("Race: " .. jlib.UpperFirstChar(self.Options.Race))
		end

		s.Setting = self.Options.Sex
	end
	raceBtn:Dock(TOP)
	raceBtn:SetFont("ArmorUI")

	optionsPnl:AddSpacer()

	local ply = LocalPlayer()
	local allowedHairs = Barber.GetAllowedCuts(ply, 2, preview.Entity:GetBodygroupCount(2), self.Options.Sex)
	local allowedBeards = Barber.GetAllowedCuts(ply, 3, preview.Entity:GetBodygroupCount(3), self.Options.Sex)

	local hairChoice = 1
	local actualHairChoice = 0
	local hairBtn = optionsPnl:Add("UI_DButton")
	hairBtn:SetText("Hair")
	hairBtn.OnMousePressed = function(s, keycode)
		if keycode == MOUSE_LEFT then
			hairChoice = hairChoice + 1
		elseif keycode == MOUSE_RIGHT then
			hairChoice = hairChoice - 1
		end

		if hairChoice > #allowedHairs then
			hairChoice = 1
		elseif hairChoice <= 0 then
			hairChoice = #allowedHairs
		end

		actualHairChoice = allowedHairs[hairChoice]

		self.Options.FaceBodygroups[2] = actualHairChoice
		preview:Setup()

		self:SetEditing({"head"})
		surface.PlaySound("fallout/ui/ui_select.wav")
		preview:ZoomOnBone("ValveBiped.Bip01_Head1", Vector(20, 0, 0), true)
	end
	hairBtn:Dock(TOP)
	hairBtn:SetFont("ArmorUI")

	optionsPnl:AddSpacer()

	local faceHairChoice = 1
	local actualFacialHairChoice = 0
	local faceHairBtn = optionsPnl:Add("UI_DButton")
	faceHairBtn:SetText("Facial Hair")
	faceHairBtn.OnMousePressed = function(s, keycode)
		if keycode == MOUSE_LEFT then
			faceHairChoice = faceHairChoice + 1
		elseif keycode == MOUSE_RIGHT then
			faceHairChoice = faceHairChoice - 1
		end

		if faceHairChoice > #allowedBeards then
			faceHairChoice = 1
		elseif faceHairChoice < 0 then
			faceHairChoice = #allowedBeards
		end

		actualFacialHairChoice = allowedBeards[faceHairChoice]

		self.Options.FaceBodygroups[3] = actualFacialHairChoice
		preview:Setup()

		self:SetEditing({"head"})
		surface.PlaySound("fallout/ui/ui_select.wav")
		preview:ZoomOnBone("ValveBiped.Bip01_Head1", Vector(20, 0, 0), true)
	end
	faceHairBtn:Dock(TOP)
	faceHairBtn:SetFont("ArmorUI")

	optionsPnl:AddSpacer()

	for buildType, info in pairs(Armor.BuildInfo) do
		local slider = optionsPnl:Add("DNumSlider")
		slider:SetText(buildType)
		slider:SetMin(info.Min)
		slider:SetMax(info.Max)
		slider:SetValue(1)
		slider.Label:SetFont("ArmorUI")
		slider.Label:SetTextColor(nut.gui.palette.text_primary)
		slider.Label:SetExpensiveShadow(1, Color(0, 0, 0))
		slider.OnValueChanged = function(s, mod)
			local ent = preview.Entity

			for i, boneName in ipairs(info.Bones) do
				local modVector = Vector(1, 1, 1)

				for _, v in pairs(info.Dimensions or {}) do
					modVector[v] = mod
				end

				ent:ManipulateBoneScale(ent:LookupBone(boneName), modVector)
			end

			self.Options.Build[buildType] = mod

			if buildType == "Strength" and self.Options.Sex != "ghoul" then
				local skin = Armor.Consts.RaceSkins[self.Options.Race]
				if mod > (1 + Armor.BuildInfo.Strength.Max) / 2 then
					skin = skin + 1
				end
				preview.armsEnt:SetSkin(skin)
			end

			self:SetEditing(info.Bodyparts)
			preview:ZoomOnBone("ValveBiped.Bip01_Pelvis", Vector(80, 0, 0))
		end
		slider:Dock(TOP)

		optionsPnl:AddSpacer()
	end

	local heightSlider = optionsPnl:Add("DNumSlider")
	heightSlider:SetText("Height")
	heightSlider:SetDecimals(2)
	heightSlider:SetMin(Armor.Consts.MinHeight)
	heightSlider:SetMax(Armor.Consts.MaxHeight)
	heightSlider:SetValue((Armor.Consts.MinHeight + Armor.Consts.MaxHeight) / 2)
	heightSlider.Label:SetFont("ArmorUI")
	heightSlider.Label:SetTextColor(nut.gui.palette.text_primary)
	heightSlider.Label:SetExpensiveShadow(1, Color(0, 0, 0))
	heightSlider:Dock(TOP)

	optionsPnl:AddSpacer()

	local bodyToggle = optionsPnl:Add("UI_DButton")
	bodyToggle:SetText("Toggle Clothes")
	bodyToggle:Dock(TOP)
	bodyToggle:SetFont("ArmorUI")
	bodyToggle.DoClick = function(s)
		if self.Clothes then
			self.Clothes = nil
			preview:Setup()
		else
			self.Clothes = true
			preview:Setup()
		end
	end

	optionsPnl:AddSpacer()

	local hairColorBtn = optionsPnl:Add("UI_DButton")
	hairColorBtn:SetText("Hair Color")
	hairColorBtn.DoClick = function()
		if IsValid(self.HairMixer) then
			self.HairMixer:Remove()
			self.HairMixer = nil
			return
		end

		local mFrame = optionsPnl:Add("DPanel")
		mFrame:SetSize(267,186)
		mFrame:Dock(TOP)

		local mixer = mFrame:Add("DColorMixer")
		mixer:Dock(FILL)
		mixer:SetPalette(false)
		mixer:SetAlphaBar(false)
		mixer:SetColor(Color(0, 0, 0, 255))

		mixer.ValueChanged =  function(s, col)
			self.Options.HairColor = col
			preview:SetColor(col)
		end

		self.HairMixer = mFrame

		self:SetEditing({"head"})
		preview:ZoomOnBone("ValveBiped.Bip01_Head1", Vector(20, 0, 0), true)
	end
	hairColorBtn:Dock(TOP)
	hairColorBtn:SetFont("ArmorUI")

	local controlsPanel = self:Add("UI_DPanel_Horizontal")
	controlsPanel:SetSize(self:GetWide() * 0.3, self:GetTall() * 0.035)
	controlsPanel:SetPos(0, self:GetTall() - controlsPanel:GetTall() - 35)
	controlsPanel:CenterHorizontal()

	local j = -1
	for sex, _ in pairs(Armor.Consts.ValidSexes) do
		local sexBtn = controlsPanel:Add("UI_DButton")
		sexBtn:SetText(jlib.UpperFirstChar(sex))
		sexBtn.DoClick = function()
			if istable(Armor.SexDefaults[sex]) then
				for k, v in pairs(Armor.SexDefaults[sex]) do
					self.Options[k] = v
				end
			end

			self.Options.Sex = sex
			preview:Setup()

			self:SetEditing({"head", "left_arm", "right_arm", "left_leg", "right_leg", "upper_body"})
			preview:ZoomOnBone("ValveBiped.Bip01_Pelvis", Vector(80, 0, 0))

			allowedHairs = Barber.GetAllowedCuts(ply, 2, preview.Entity:GetBodygroupCount(2), self.Options.Sex)
			allowedBeards = Barber.GetAllowedCuts(ply, 3, preview.Entity:GetBodygroupCount(3), self.Options.Sex)
		end
		sexBtn:SetWide(100)
		sexBtn:SetContentAlignment(5)
		sexBtn:ScaleToRes(2560, 1440)
		sexBtn:SetPos((controlsPanel:GetWide() / 2) - (sexBtn:GetWide() / 2) - (sexBtn:GetWide() * j), 0)
		sexBtn:CenterVertical()
		sexBtn:SetFont("ArmorUI")

		j = j + 1
	end

	local closeBtn = controlsPanel:Add("UI_DButton")
	closeBtn:SetText("Return")
	closeBtn:SetContentAlignment(5)
	closeBtn:SetWide(100)
	closeBtn:ScaleToRes(2560, 1440)
	closeBtn:SetPos(5, 0)
	closeBtn:CenterVertical()
	closeBtn.DoClick = function(s)
		fadeOut(function()
			vgui.Create("nutCharCreate")
			self:Remove()
		end)
	end
	closeBtn:SetFont("ArmorUI")
	self.CloseBtn = closeBtn

	local tip = optionsFrame:Add("UI_DLabel")
	tip:Dock(BOTTOM)
	tip:SetText("Tip: Right click your character to zoom on their face!")
	tip:SetContentAlignment(5)
	tip:SetFont("ArmorUISmall")
	tip:SizeToContents()

	local continueBtn = controlsPanel:Add("UI_DButton")
	continueBtn:SetText("Continue")
	continueBtn:SetContentAlignment(5)
	continueBtn:SetWide(125)
	continueBtn:ScaleToRes(2560, 1440)
	continueBtn:SetPos(controlsPanel:GetWide() - continueBtn:GetWide() - 5, 0)
	continueBtn:CenterVertical()
	continueBtn.DoClick = function()
		local Options = self.Options
		local NSData = self.NSData
		NSData.data = {
			["armorGroup"] = Armor.Config.DefaultBody,
			["sex"] = Options.Sex,
			["gender"] = Options.Sex == "ghoul" and "male" or Options.Sex,
			["race"] = Options.Race,
			["faceBodygroups"] = Options.FaceBodygroups,
			["hairColor"] = Options.Sex != "ghoul" and Options.HairColor or Color(255, 255, 255, 255),
			["build"] = Options.Build,
			["skin"] = Options.Sex == "ghoul" and skinChoice or 0,
			["special"] = self.Options.SPECIAL,
			["height"] = Armor.FormatHeight(heightSlider:GetValue())
		}
		NSData.model = Options.Sex == "female" and 2 or 1

		if self.Surgeon then
			local char = self.char

			if !self.Cost then
				net.Start("ArmorSurgeonFree")
					jlib.WriteCompressedTable(NSData)
				net.SendToServer()

				fadeOut(function()
					vgui.Create("nutCharLoad")
					self:Remove()
				end)
				return
			end

			if char and char:getData("isCharacterCreationV2") then
				Derma_Query("Are you sure you want to pay " .. jlib.CommaNumber(Armor.Config.SurgeryCost) .. " caps for these changes?", "", "Yes", function()
					net.Start("ArmorSurgeon")
						jlib.WriteCompressedTable(NSData)
					net.SendToServer()

					fadeOut(function()
						vgui.Create("nutCharLoad")
						self:Remove()
					end)
				end, "No")
			else
				net.Start("ArmorSurgeon")
					jlib.WriteCompressedTable(NSData)
				net.SendToServer()

				fadeOut(function()
					vgui.Create("nutCharLoad")
					self:Remove()
				end)
			end
		else
			local background = self:Add("DPanel")
			background:SetSize(self:GetSize())
			background.OnMousePressed = function(s)
				s:Remove()
			end

			local namePnl = background:Add("UI_DPanel_Bordered")
			namePnl:SetSize(512, 166)
			namePnl:Center()

			local name1Pnl = namePnl:Add("DPanel")
			name1Pnl:Dock(TOP)
			name1Pnl:SetPaintBackground(false)
			name1Pnl:SetTall(namePnl:GetTall() / 3)

			local name1Lbl = name1Pnl:Add("UI_DLabel")
			name1Lbl:SetText("First Name:")
			name1Lbl:SizeToContents()
			name1Lbl:SetPos((namePnl:GetWide() / 2) - name1Lbl:GetWide(), (name1Pnl:GetTall() / 2) - (name1Lbl:GetTall() / 2))

			local name1Entry = name1Pnl:Add("UI_DTextEntry")
			name1Entry:SetTall(25)
			name1Entry:SetWide(150)
			name1Entry:SetPos(0, (name1Pnl:GetTall() / 2) - (name1Entry:GetTall() / 2))
			name1Entry:MoveRightOf(name1Lbl, 10)

			local name2Pnl = namePnl:Add("DPanel")
			name2Pnl:Dock(TOP)
			name2Pnl:SetPaintBackground(false)
			name2Pnl:SetTall(namePnl:GetTall() / 3)

			local name2Lbl = name2Pnl:Add("UI_DLabel")
			name2Lbl:SetText("Last Name:")
			name2Lbl:SizeToContents()
			name2Lbl:SetPos((namePnl:GetWide() / 2) - name2Lbl:GetWide(), (name2Pnl:GetTall() / 2) - (name2Lbl:GetTall() / 2))

			local name2Entry = name2Pnl:Add("UI_DTextEntry")
			name2Entry:SetTall(25)
			name2Entry:SetWide(150)
			name2Entry:SetPos(0, (name2Pnl:GetTall() / 2) - (name2Entry:GetTall() / 2))
			name2Entry:MoveRightOf(name2Lbl, 10)

			local rF, rL = Armor.RandomName()
			name1Entry:SetText(rF)
			name2Entry:SetText(rL)

			local confirmBtn = namePnl:Add("UI_DButton")
			confirmBtn:SetText("Confirm")
			confirmBtn:Dock(TOP)
			confirmBtn:SetContentAlignment(5)
			confirmBtn:SetTall(namePnl:GetTall() / 3 - 10)
			confirmBtn:DockMargin(10, 0, 10, 0)
			confirmBtn.DoClick = function()
				local first, last = name1Entry:GetText(), name2Entry:GetText()

				if first:find("%s") or last:find("%s") then
					Derma_Message("Your character's name cannot contain any spaces.", nil, "OK")
					return
				elseif first:find("%d") or last:find("%d") then
					Derma_Message("Your character's name cannot contain any numbers.", nil, "OK")
					return
				elseif first:find("%p") or last:find("%p") then
					Derma_Message("Your character's name cannot contain any punctuation.", nil, "OK")
					return
				elseif first:len() < 1 or last:len() < 1 then
					Derma_Message("Your character's first or last name cannot be blank.", nil, "OK")
					return
				elseif (first:len() + last:len()) < 5 then
					Derma_Message("Your character's name cannot be shorter than five letters.", nil, "OK")
					return
				elseif (first:len() + last:len()) > 24 then
					Derma_Message("Your character's name cannot be longer than twenty four letters.", nil, "OK")
					return
				end

				NSData.name = jlib.UpperFirstChar(first:lower()) .. " " .. jlib.UpperFirstChar(last:lower())
				namePnl:Remove()

				local descPnl = background:Add("UI_DPanel_Bordered")
				descPnl:SetSize(512, 166)
				descPnl:Center()

				local descEntry = descPnl:Add("UI_DTextEntry")
				descEntry:SetPlaceholderText("Description")
				descEntry:SetWide(488)
				descEntry:Center()

				local descConfirm = descPnl:Add("UI_DButton")
				descConfirm:SetText("Confirm")
				descConfirm:Dock(BOTTOM)
				descConfirm:SetContentAlignment(5)
				descConfirm:DockMargin(6, 0, 6, 6)
				descConfirm.DoClick = function(s)
					local desc = descEntry:GetValue() != "" and descEntry:GetValue() or NSData.desc

					if #desc < 16 then
						Derma_Message("Your character's description must be at least sixteen characters.", nil, "OK")
						return
					elseif #desc > Armor.Config.DescLength then
						Derma_Message("Your character's description must be at most " .. Armor.Config.DescLength .. " characters.", nil, "OK")
						return
					end

					NSData.desc = desc

					background:Remove()

					local creating = self:Add("UI_DLabel")
					creating:SetSize(ScrW(), ScrH())
					creating:SetContentAlignment(5)
					creating:SetText("Creating Character...")
					creating:SetFont("UI_Bold")

					netstream.Hook("charAuthed", function(fault, ...)
						timer.Remove("nutCharTimeout")

						if type(fault) == "string" then
							creating:Remove()
							Derma_Message("ERROR: " .. fault, nil, "OK")
							return
						end

						if type(fault) == "table" then
							nut.characters = fault
						end

						creating:SetText("Character Created!")

						fadeOut(function()
							vgui.Create("nutCharMenu"):open()
							self:Remove()
						end)
					end)

					timer.Create("nutCharTimeout", 20, 1, function()
						if IsValid(nut.gui.charBuilder) then
							creating:Remove()
							Derma_Message("The character creation timed out, please try again.", nil, "OK")
						end
					end)

					net.Start("ArmorCreateChar")
						jlib.WriteCompressedTable(NSData)
					net.SendToServer()

					surface.PlaySound("ui/found.wav")
				end
			end
		end
	end

	continueBtn:SetFont("ArmorUI")

	local skills = {
		"Strength",
		"Perception",
		"Endurance",
		"Charisma",
		"Intelligence",
		"Agility",
		"Luck"
	}

	local skillDescs = Armor.Config.SkillDescs

	local remaining = Armor.Config.SkillPoints

	local specialPnl = self:Add("UI_DFrame")
	specialPnl:SetTitle("SPECIAL")
	specialPnl:SetSize(self:GetWide() * 0.2, self:GetTall() * 0.7)
	specialPnl:SetPos(35, 0)
	specialPnl:CenterVertical()
	self.SpecialPnl = specialPnl

	local skillPoints = specialPnl:Add("UI_DLabel")
	skillPoints:Dock(BOTTOM)
	skillPoints:SetFont("ArmorUI")
	skillPoints:SetContentAlignment(5)
	skillPoints:SetText("Skill points remaining: " .. remaining)
	skillPoints:SizeToContents()

	local animPnl = specialPnl:Add("jAnimatedPanel")
	animPnl:SetColor(nut.gui.palette.color_primary)
	animPnl:SetKeepCentered(true)

	local descPnl = specialPnl:Add("DPanel")
	descPnl.Paint = function(s)
		draw.DrawText(s.Text or "", "ArmorUISmall", s:GetWide() / 2, 0, nut.gui.palette.text_primary, TEXT_ALIGN_CENTER)
	end
	descPnl:SetWide(specialPnl:GetWide())
	descPnl:SetTall(300)
	descPnl:SetPos(0, #skills * 32 + 15 + 300)

	local lastSkillBtn

	for i, skill in ipairs(skills) do
		local skillBtn = specialPnl:Add("UI_DButton")
	 	skillBtn:SetText(skill)
		skillBtn:SetFont("ArmorUI")
		skillBtn:SetSize(specialPnl:GetWide() - 24, 32)
		skillBtn:SetPos(12, (i * 32) + 10)
		skillBtn.Think = function(s)
			local frames = Armor.SPECIALFrames[skill:lower()]

			if s:IsHovered() then
				if animPnl:GetFrames() != frames then
					animPnl:SetFrames(frames)
					animPnl:SizeToContents()
					animPnl:Center()
					animPnl:MoveBelow(lastSkillBtn, 5)

					if self.Sound then
						self.Sound:Stop()
					end

					if skill:lower() and Armor.SPECIALSounds[skill:lower()] then
						self.Sound = CreateSound(game.GetWorld(), Armor.SPECIALSounds[skill:lower()])
						self.Sound:SetSoundLevel(0)
						self.Sound:Play()
					end

					descPnl.Text = jlib.WrapText(descPnl:GetWide() - 48, skillDescs[skill], "ArmorUI")
				end
			elseif animPnl:GetFrames() == frames then
				animPnl:SetFrames({})
				self.Sound:Stop()
				descPnl.Text = ""
			end
		end

		local skillLbl = specialPnl:Add("UI_DLabel")
		skillLbl:SetFont("ArmorUI")
		skillLbl:SetText(0)
		skillLbl:SetPos(specialPnl:GetWide() - skillLbl:GetWide(), (i * 32) + 15)

		local oldClick = skillBtn.OnMousePressed
		skillBtn.OnMousePressed = function(s, btn)
			if btn == MOUSE_LEFT then
				if remaining <= 0 then return end

				skillLbl:SetText(tonumber(skillLbl:GetText()) + 1)
				remaining = remaining - 1
				skillPoints:SetText("Skill points remaining: " .. remaining)

				self.Options.SPECIAL[skill:sub(0, 1)] = (self.Options.SPECIAL[skill:sub(0, 1)] or 0) + 1

				oldClick(s, btn)
			elseif btn == MOUSE_RIGHT then
				if remaining >= Armor.Config.SkillPoints or tonumber(skillLbl:GetText()) <= 0 then return end

				skillLbl:SetText(tonumber(skillLbl:GetText()) - 1)
				remaining = remaining + 1
				skillPoints:SetText("Skill points remaining: " .. remaining)

				self.Options.SPECIAL[skill:sub(0, 1)] = (self.Options.SPECIAL[skill:sub(0, 1)] or 0) - 1

				oldClick(s, btn)
			end
		end

		lastSkillBtn = skillBtn
	end
end

function PANEL:OnRemove()
	for i, e in ipairs(self.CSEnts) do
		if IsValid(e.Ent) then
			e.Ent:Remove()
		end
	end

	nut.gui.charBuilder = nil
	if self.Sound then self.Sound:Stop() end
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(Color(35, 35, 35, 255))
	surface.DrawRect(0, 0, w, h)
end

function PANEL:SetEditing(tbl)
	for k, v in pairs(self.Editing) do
		self.Editing[k] = nil
	end

	for k, v in pairs(tbl) do
		self.Editing[v] = true
	end
end

function PANEL:SetSurgeon(bool)
	self.Surgeon = true

	if IsValid(self.SpecialPnl) then
		self.SpecialPnl:Remove()
	end
end

vgui.Register("CharacterCustomization", PANEL, "EditablePanel")

--Scoreboard head cleanup
Armor.ScoreboardHeads = Armor.ScoreboardHeads or {}

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "ArmorCleanup", function(dat)
	local steamID = dat.networkid

	if IsValid(Armor.ScoreboardHeads[steamID]) then
		print("Cleaning up scoreboard head for player " .. (dat.name or "unknown"))
		Armor.ScoreboardHeads[steamID]:Remove()
	end
end)

-- Frustum culling
function Armor.IsVisible(ent)
	local mins, maxs = ent:GetRenderBounds()
	local pos = ent:GetPos()
	return Frustum:BoxInFrustum(jlib.MinMaxToVertices(mins + pos, maxs + pos)) != OUTSIDE
end

-- Controls CSENT rendering
hook.Add("Think", "ArmorPlyOnlyFrustumCulling", function()
	if LocalPlayer().cullDelay and LocalPlayer().cullDelay > CurTime() then return end -- Throttles calls for minor performance gains

	LocalPlayer().cullDelay = CurTime() + 0.3

	local plys = player.GetAll()
	for i = 1, #plys do
		local ply = plys[i]
		if ply == LocalPlayer() then
			ply.InFrustum = true
			ply.InLOS = true
			continue
		end

		ply.InLOS = LocalPlayer():IsLineOfSightClear(ply)

		if ply.InLOS then
			ply.InFrustum = Armor.IsVisible(ply)
		end
	end
end)
