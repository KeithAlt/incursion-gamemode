surface.CreateFont("WB3D2D", {font = "Roboto", size = 52, weight = 400})
surface.CreateFont("WBHUD", {font = "Arial", size = 32, weight = 400})

--Capture mechanics
Workbenches.Enemies = {}
local alertMat = Material("enemyalert.png")
function Workbenches.DrawEnemy()
	local w = 160
	local h = 160

	for ply, v in pairs(Workbenches.Enemies) do

		if !IsValid(ply) then
			Workbenches.Enemies[ply] = nil
			continue
		end

		local eyeAng = EyeAngles()
		eyeAng.p = 0
		eyeAng.y = eyeAng.y - 90
		eyeAng.r = 90

		local bone = ply:LookupBone("ValveBiped.Bip01_Head1")
		local pos = bone and (ply:GetBonePosition(bone) + Vector(0, 0, 15)) or (ply:GetPos() + Vector(0, 0, (ply:OBBMaxs().z * ply:GetModelScale()) + 35))

		cam.Start3D2D(pos, eyeAng, 0.05)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(alertMat)
			surface.DrawTexturedRect(-w/2, (-h/2) - 10, w, h)
			jlib.ShadowText("ENEMY", "WB3D2D", 0, 45, Color(250, 44, 44, 255), Color(0, 0, 0, 255), 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		cam.End3D2D()
	end
end
hook.Add("PostDrawOpaqueRenderables", "WBDrawEnemy", Workbenches.DrawEnemy)

function Workbenches.AskClaim()
	local ent = net.ReadEntity()

	local frame = vgui.Create("UI_DFrame")
	frame:SetSize(300, 220)
	frame:SetTitle("WARNING")
	frame:Center()
	frame:MakePopup()
	jlib.AddBackgroundBlur(frame)

	local cancel = vgui.Create("UI_DButton", frame)
	cancel:Dock(BOTTOM)
	cancel:SetText("CANCEL")
	cancel.DoClick = function()
		frame:Close()
	end

	local confirm = vgui.Create("UI_DButton", frame)
	confirm:Dock(BOTTOM)
	confirm:SetText("CONTINUE")
	confirm.DoClick = function()
		frame:Close()
		net.Start("WBConfirmClaim")
			net.WriteEntity(ent)
		net.SendToServer()
	end

	local warning = vgui.Create("UI_DLabel", frame)
	warning:SetText("You are attempting to claim another person's " .. ent:GetBenchName():lower() .. " for your own. If you choose to continue the owner may kill you for attempting this.")
	warning:SetWrap(true)
	warning:SetSize(frame:GetSize())
	warning:SetPos(0, -20)
end
net.Receive("WBAskClaim", Workbenches.AskClaim)

function Workbenches.DrawProgressBar()
	local dots = {
		"",
		".",
		"..",
		"..."
	}

	if CurTime() >= (Workbenches.NextDot or CurTime()) then
		Workbenches.NextDot = CurTime() + 1
		Workbenches.dot = (Workbenches.dot or 1) + 1
		if Workbenches.dot > 4 then Workbenches.dot = 1 end
	end

	local w = 800
	local h = 30
	local x = ScrW()/2 - w/2
	local y = 150

	local progress = math.Clamp(1 - (math.abs(timer.TimeLeft("WBProgress")) / Workbenches.Config.ClaimTime), 0, 1)

	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawOutlinedRect(x, y, w, h)
	surface.SetDrawColor(80, 80, 80, 240)
	surface.DrawRect(x + 1, y + 1, w - 2, h - 2)
	surface.SetDrawColor(contested and Color(250, 44, 44, 255) or Color(66, 134, 244, 255))
	surface.DrawRect(x + 1, y + 1, (progress * w) - 2, h - 2)

	jlib.ShadowText(contested and "CONTESTED" or ("Claiming" .. dots[Workbenches.dot]), "WBHUD", x + (w/2), y, Color(255, 255, 255, 255), Color(0, 0, 0, 255), 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end

net.Receive("StartWBClaim", function()
	local owner = net.ReadEntity()
	Workbenches.Enemies[owner] = true

	contested = false
	timer.Create("WBProgress", Workbenches.Config.ClaimTime, 1, function()
		hook.Remove("HUDPaint", "WBProgress")
	end)
	hook.Add("HUDPaint", "WBProgress", Workbenches.DrawProgressBar)
end)

net.Receive("HaltWBClaim", function()
	local owner = net.ReadEntity()
	hook.Remove("HUDPaint", "WBProgress")
	Workbenches.Enemies[owner] = nil
end)

net.Receive("WBClaimStarted", function()
	local attacker = net.ReadEntity()
	Workbenches.Enemies[attacker] = true
end)

net.Receive("WBClaimHalted", function()
	local attacker = net.ReadEntity()
	Workbenches.Enemies[attacker] = nil
end)

net.Receive("WBContest", function()
	contested = net.ReadBool()

	if contested then
		timer.Pause("WBProgress")
	else
		timer.UnPause("WBProgress")
	end
end)

--Presets
function Workbenches.AddPresetButton(panel, options, think)
	local savePresetButton = panel:Add("DButton")
	savePresetButton:SetText("Save Preset")
	savePresetButton:Dock(BOTTOM)
	savePresetButton:SetDisabled(true)
	savePresetButton.Think = think

	savePresetButton.DoClick = function(s)
		s.ExtraOptions(options)

		Derma_StringRequest("Save Preset", "Choose a unique preset ID", "", function(text)
			if text == "" then return end

			Workbenches.SavePreset(text, options)
		end)
	end

	return savePresetButton
end

function Workbenches.PresetApplicationMenu(bench, presets)
	local frame = vgui.Create("DFrame")
	frame:SetTitle("Choose a Preset")
	frame:SetSize(800, 600)
	frame:MakePopup()
	frame:Center()
	frame:SetBackgroundBlur(true)
	frame.m_fCreateTime = 0

	local categoryList = frame:Add("DCategoryList")
	categoryList:Dock(FILL)

	for id, options in pairs(presets) do
		local panelList = frame:Add("DPanelList")

		local cat = categoryList:Add(id)
		cat:SetContents(panelList)
		cat:SetExpanded(false)

		local button = panelList:Add("DButton")
		button:SetWide(frame:GetWide() - 15)
		button:SetText("Apply")
		button.DoClick = function(s)
			net.Start("WBConfig")
				jlib.WriteCompressedTable(options)
				net.WriteEntity(bench)
			net.SendToServer()

			frame:Close()
		end

		local delButton = panelList:Add("DButton")
		delButton:SetWide(frame:GetWide() - 15)
		delButton:SetText("Delete")
		delButton.DoClick = function(s)
			net.Start("WBDeletePreset")
				net.WriteString(id)
			net.SendToServer()

			cat:Remove()
		end
		delButton:MoveBelow(button, 2)

		for k, v in pairs(options) do
			if istable(v) and v.r and v.g and v.b and v.a then --So it has the correct __tostring value
				setmetatable(v, FindMetaTable("Color"))
			end

			cat:Add(tostring(k) .. ": " .. tostring(v))
		end
	end
end
net.Receive("WBSendPresets", function()
	local presets = jlib.ReadCompressedTable()
	local ent = net.ReadEntity()

	Workbenches.PresetApplicationMenu(ent, presets)
end)

--Inventory menu
--[[
net.Receive("WBOpenInv", function()
	local inventory = nut.item.inventories[net.ReadInt(32)]

	local panel = vgui.Create("nutInventory")
	panel:ShowCloseButton(true)
	panel:SetTitle("Inventory")
	panel:setInventory(inventory)

	local playerinv = vgui.Create("nutInventory")
	playerinv:ShowCloseButton(false)
	playerinv:setInventory(LocalPlayer():getChar():getInv())
	playerinv:viewOnly()
	playerinv:SetDraggable(false)
	playerinv.Think = function(s)
		s:MoveRightOf(panel)
		s:MoveBelow(panel, -s:GetTall())
	end

	panel.OnClose = function()
		playerinv:Close()
	end
end)
]]

net.Receive("WBOpenInv", function()
	local ent = net.ReadEntity()
	local items = ent:getNetVar("inventory", {})

	local gridSize = 64
	local gridSpacing = 2
	local gridItemSize = gridSize + gridSpacing

	local w = (gridItemSize * math.Round(ent:GetInvX())) + 20
	local h = (gridItemSize * math.Round(ent:GetInvY())) + 35 + 45

	local frame = vgui.Create("DFrame")
	frame:SetSize(w, h)
	frame:MakePopup()
	frame:Center()
	frame:SetTitle("Inventory")

	local grid = frame:Add("DGrid")
	grid:SetPos(10, 30)
	grid:SetCols(ent:GetInvX())
	grid:SetColWide(gridItemSize)
	grid:SetRowHeight(gridItemSize)

	for i = 1, (math.Round(ent:GetInvX()) * math.Round(ent:GetInvY())) do
		local pnl = vgui.Create("DPanel")
		pnl:SetSize(gridSize, gridSize)

		grid:AddItem(pnl)
	end

	local function fillGrid()
		local gridItems = grid:GetItems()
		local i = 1
		for uniqueID, amt in pairs(items) do
			for j = 1, amt do
				local itemBtn = gridItems[i]:Add("nutSpawnIcon")
				itemBtn:SetModel(nut.item.list[uniqueID].model)
				itemBtn:SetSize(gridSize, gridSize)
				itemBtn.DoClick = function(s)
					net.Start("WBTakeItem")
						net.WriteEntity(ent)
						net.WriteString(uniqueID)
					net.SendToServer()
				end

				i = i + 1
			end
		end
	end
	fillGrid()

	local curTotal = jlib.TableSum(ent:getNetVar("inventory", {}))
	frame.Think = function(s)
		items = ent:getNetVar("inventory", {})
		local total = jlib.TableSum(items)
		if total != curTotal then
			for _, pnl in pairs(grid:GetItems()) do
				for _, child in pairs(pnl:GetChildren()) do
					child:Remove()
				end
			end
			fillGrid()

			curTotal = total
		end
	end

	local takeAllBtn = frame:Add("DButton")
	takeAllBtn:SetText("Take All")
	takeAllBtn:SetSize(frame:GetWide() - 21, 40)
	takeAllBtn:SetPos(10, gridItemSize * (math.Round(ent:GetInvY()) + 0.5))
	takeAllBtn.DoClick = function(s)
		net.Start("WBTakeAllItems")
			net.WriteEntity(ent)
		net.SendToServer()
	end
end)

--Recipes
function Workbenches.RecipeMaker(default, category)
	local frame = vgui.Create("DFrame")
	frame:SetTitle("Recipe Maker")
	frame:SetSize(800, 600)
	frame:MakePopup()
	frame:Center()
	frame:SetBackgroundBlur(true)

	local inputList = frame:Add("DListView")
	inputList:AddColumn("Input Item(s)")
	inputList:SetMultiSelect(false)
	inputList:SetSize(300, 300)
	inputList:SetPos((frame:GetWide() / 2) - (inputList:GetWide() / 2) - 155, (frame:GetTall() / 2) - (inputList:GetTall() / 2))
	inputList.SelectedInput = {}

	local outputList = frame:Add("DListView")
	outputList:AddColumn("Output Item")
	outputList:SetMultiSelect(false)
	outputList:SetSize(300, 300)
	outputList:SetPos((frame:GetWide() / 2) - (outputList:GetWide() / 2) + 155, (frame:GetTall() / 2) - (outputList:GetTall() / 2))

	for uniqueID, item in pairs(nut.item.list) do
		local outputLine = outputList:AddLine(item.name)
		outputLine.uniqueID = uniqueID

		if default and uniqueID == default then
			outputLine:SetSelected(true)
		end

		inputList:AddLine(item.name).uniqueID = uniqueID
	end

	inputList.OnClickLine = function(s, line)
		Derma_StringRequest("Amount", "Amount of " .. nut.item.list[line.uniqueID].name, "1", function(text)
			local number = tonumber(text)
			if !number then return end

			if inputList.SelectedInput[line.uniqueID] then
				inputList.SelectedInput[line.uniqueID] = nil

				if line.tick then
					line.tick:Remove()
					line.tick = nil
				end
			else
				inputList.SelectedInput[line.uniqueID] = number

				local tick = line:Add("DImage")
				tick:SetSize(16, 16)
				tick:SetImage("icon16/tick.png")
				tick:SetPos(line:GetWide() - 32, 0)
				line.tick = tick
			end
		end)
	end

	local categoryEntry = frame:Add("DTextEntry")
	categoryEntry:SetWide(610)
	categoryEntry:Center()
	categoryEntry:MoveBelow(outputList, 5)
	categoryEntry:SetPlaceholderText("Category")
	categoryEntry:SetValue(category or "")

	local timeEntry = frame:Add("DTextEntry")
	timeEntry:SetNumeric(true)
	timeEntry:SetWide(610)
	timeEntry:Center()
	timeEntry:MoveBelow(categoryEntry, 5)
	timeEntry:SetPlaceholderText("Production Time")

	local finishButton = frame:Add("DButton")
	finishButton:SetDisabled(true)
	finishButton:SetText("Finish")
	finishButton:Dock(BOTTOM)

	finishButton.Think = function(s)
		if outputList:GetSelectedLine() and timeEntry:GetValue() != "" and categoryEntry:GetValue() != "" and table.Count(inputList.SelectedInput) > 0 then
			s:SetDisabled(false)
		else
			s:SetDisabled(true)
		end
	end

	finishButton.DoClick = function(s)
		frame:Close()

		net.Start("WBAddRecipe")
			net.WriteString(outputList:GetLine(outputList:GetSelectedLine()).uniqueID)
			jlib.WriteCompressedTable(inputList.SelectedInput)
			net.WriteInt(tonumber(timeEntry:GetValue()), 32)
			net.WriteString(categoryEntry:GetValue())
		net.SendToServer()
	end
end
net.Receive("WBOpenRecipeMaker", Workbenches.RecipeMaker)

function Workbenches.CategoryPicker()
	local frame = vgui.Create("DFrame")
	frame:SetTitle("Recipe Manager")
	frame:SetSize(800, 600)
	frame:MakePopup()
	frame:Center()
	frame:SetBackgroundBlur(true)

	local scrollPnl = frame:Add("DScrollPanel")
	scrollPnl:Dock(FILL)

	local i = 1
	for category, recipes in pairs(Workbenches.Recipes) do
		local btn = scrollPnl:Add("DButton")
		btn:SetPos((frame:GetWide() / 2) - (btn:GetWide() / 2), 25 * i)
		btn:SetText(category)
		btn.DoClick = function(s)
			frame:Close()
			Workbenches.RecipeManager(category)
		end

		i = i + 1
	end
end

function Workbenches.RecipeManager(category)
	local frame = vgui.Create("DFrame")
	frame:SetTitle("Recipe Manager: " .. category)
	frame:SetSize(800, 600)
	frame:MakePopup()
	frame:Center()
	frame:SetBackgroundBlur(true)

	local scroll = frame:Add("DScrollPanel")
	scroll:Dock(FILL)

	local panels = {}

	local i = 1
	for output, data in pairs(Workbenches.Recipes[category]) do
		local label = scroll:Add("DLabel")
		label:SetText(nut.item.list[output].name)
		label:SizeToContents()
		label:SetPos((frame:GetWide() / 2) - (label:GetWide() / 2), 50 * i)
		label.index = table.insert(panels, label)

		local editButton = scroll:Add("DButton")
		editButton:SetText("Edit")
		editButton:SetWide(100)
		editButton:SetPos((frame:GetWide() / 2) - (editButton:GetWide() / 2) + 55, (50 * i) + 20)
		editButton.DoClick = function(s)
			frame:Close()
			Workbenches.RecipeMaker(output, category)
		end
		editButton.index = table.insert(panels, editButton)

		local delButton = scroll:Add("DButton")
		delButton:SetText("Delete")
		delButton:SetWide(100)
		delButton:SetPos((frame:GetWide() / 2) - (delButton:GetWide() / 2) - 55, (50 * i) + 20)
		delButton.DoClick = function(s)
			net.Start("WBDeleteRecipe")
				net.WriteString(output)
				net.WriteString(category)
			net.SendToServer()

			label:Remove()
			editButton:Remove()
			s:Remove()

			for j = delButton.index, #panels do
				local panel = panels[j]

				if IsValid(panel) then
					panel:MoveBy(0, -50, 1)
				end
			end
		end
		delButton.index = table.insert(panels, delButton)

		i = i + 1
	end
end
net.Receive("WBOpenRecipeManager", Workbenches.CategoryPicker)

net.Receive("WBUpdateRecipes", function()
	Workbenches.Recipes = jlib.ReadCompressedTable()
end)

--Lockpicking
net.Receive("WBSetLockpickLevel", function()
	local ent = net.ReadEntity()
	local level = net.ReadInt(32)

	ent.LockpickLevel = level
end)

--Bench sounds
net.Receive("WBSoundStart", function()
	local bench = net.ReadEntity()
	local sound = net.ReadString()

	if IsValid(bench) then
		bench.SoundPath = sound
		bench:StartBenchSound(sound)
	end
end)

net.Receive("WBSoundStop", function()
	local bench = net.ReadEntity()
	local fadeTime = net.ReadInt(32)

	if IsValid(bench) then
		bench:StopBenchSound(fadeTime)
	end
end)

--Zrmine stuff
sound.Add({
	name = "zrmine_sfx_melter_loop",
	channel = CHAN_STATIC,
	volume = 0.6,
	level = 65,
	pitch = {85, 90},
	sound = "zrms/melter_loop.wav"
})
