surface.CreateFont("wRarityLarge", {font = "Roboto", size = 60, weight = 400})
surface.CreateFont("wRaritySmall", {font = "Roboto", size = 20, weight = 400})

--Item entity halos
wRarity.itemEnts = wRarity.itemEnts or {}

--[[timer.Create("wRarityHalosUpdate", 1, 0, function()
	itemEnts = ents.FindByClass("nut_item")
end)]]

hook.Add("OnEntityCreated", "wRarityHalosUpdate", function(ent)
	timer.Simple(0, function()
		if IsValid(ent) and ent:GetClass() == "nut_item" and isfunction(ent.getData) and ent:getData("rarity", nil) then
			table.insert(wRarity.itemEnts, ent)
		end
	end)
end)

hook.Add("PreDrawHalos", "wRarityHalos", function()
	for i = 1, #wRarity.itemEnts do
		local ent = wRarity.itemEnts[i]

		if !IsValid(ent) or !ent:getData("rarity", nil) then
			table.remove(wRarity.itemEnts, i)
			continue
		elseif ent:GetNoDraw() then
			continue
		end

		local rarity = ent:getData("rarity", 1)

		halo.Add({ent}, wRarity.Config.Rarities[rarity].color)
	end
end)

--Boss spawns
net.Receive("wRaritySendBossSpawns", function()
	wRarity.BossSpawns = net.ReadTable()
end)

--Trade ups
surface.CreateFont("wRarityTradeup", {font = "Roboto", size = 16, weight = 400})

local PANEL = {}
function PANEL:Init()
	self.Background = self:Add("DShape")
	self.Background:SetType("Rect")
	self.Background:SetColor(Color(75, 75, 75, 127))

	self.Accent = self:Add("DShape")
	self.Accent:SetType("Rect")
	self.Accent:SetColor(Color(255, 255, 255, 255))

	self.Wep = "weapon_poolcue"
	self.Rarity = 1

	self.MdlPnl = self:Add("nutSpawnIcon")

	self.Label = self:Add("DLabel")
	self.Label:SetFont("wRarityTradeup")

	self.Btn = self:Add("DImageButton")
	self.Btn.DoClick = function()
		if isfunction(self.DoClick) then
			surface.PlaySound("UI/buttonclickrelease.wav")
			self:DoClick()
		end
	end
	self.Btn.OnCursorEntered = function() surface.PlaySound("UI/buttonrollover.wav") end
end

function PANEL:SetWeapon(wep)
	self.Wep = wep
	local wepTbl = nut.item.list[wep]

	self.MdlPnl:SetModel(wepTbl.model)

	self.Label:SetText(wepTbl.name)
	self.Label:SizeToContents()
	self.Label:CenterHorizontal()
end

function PANEL:SetRarity(rarity)
	self.Rarity = rarity

	local rarityTbl = wRarity.Config.Rarities[self.Rarity]

	self.Label:SetText(rarityTbl.name .. " " .. self.Label:GetText())
	self.Label:SizeToContents()
	self.Label:CenterHorizontal()
	local col = table.Copy(rarityTbl.color) col.a = 200
	self.Accent:SetColor(col)
end

function PANEL:OnSizeChanged(w, h)
	self.Btn:SetSize(w, h)

	local backgroundHeight = h - self.Label:GetTall()

	self.Background:SetSize(w, backgroundHeight)
	self.Accent:SetSize(w * 0.1, backgroundHeight)
	self.MdlPnl:SetSize(w, backgroundHeight)
	self.Label:MoveBelow(self.MdlPnl)
	self.Label:CenterHorizontal()
end

function PANEL:Paint(w, h) end

function PANEL:PaintOver(w, h)
	surface.SetDrawColor(Color(0, 0, 0, 255))
	surface.DrawOutlinedRect(0, 0, w, h)
end

function PANEL:Think()
	if self.Btn.Depressed then
		self.Background:SetColor(Color(65, 65, 65, 127))
	elseif self.Btn:IsHovered() then
		self.Background:SetColor(Color(95, 95, 95, 127))
	else
		self.Background:SetColor(Color(75, 75, 75, 127))
	end
end
vgui.Register("wRarityWep", PANEL, "DPanel")

function wRarity.TradeUpMenu()
	local ply = LocalPlayer()
	local char = ply:getChar()

	if !char then return end

	local frame = vgui.Create("DFrame")
	frame:SetSize(1065, 720)
	frame:Center()
	frame:SetTitle("Trade Up")
	frame:MakePopup()
	frame:SetBackgroundBlur(true)

	local invPnl = frame:Add("DPanel")
	invPnl:Dock(LEFT)
	invPnl:SetWide((frame:GetWide() - 12) / 2)

	local itemGrid = invPnl:Add("DGrid")
	itemGrid:SetPos(4, 4)
	itemGrid:SetCols(4)
	itemGrid:SetColWide(130)
	itemGrid:SetRowHeight(130)

	local tradeupPnl = frame:Add("DPanel")
	tradeupPnl:Dock(RIGHT)
	tradeupPnl:SetWide((frame:GetWide() - 12) / 2)

	local tradeupGrid = tradeupPnl:Add("DGrid")
	tradeupGrid:SetPos(4, 4)
	tradeupGrid:SetCols(4)
	tradeupGrid:SetColWide(130)
	tradeupGrid:SetRowHeight(130)

	for _, item in pairs(char:getInv():getItems()) do
		if item.base == "base_firearm" then
			local wepPnl = frame:Add("wRarityWep")
			wepPnl:SetWeapon(item.uniqueID)
			wepPnl:SetRarity(item:getData("rarity", 1))
			wepPnl:SetSize(128, 128)

			function wepPnl:ItemToTrade()
				if (!tradeupGrid.Rarity or self.Rarity == tradeupGrid.Rarity) and #tradeupGrid:GetItems() < wRarity.Config.TradeupAmt and item:getData("rarity", 1) < wRarity.Config.MaxTradeupRarity then
					itemGrid:RemoveItem(self, true)
					tradeupGrid:AddItem(self)

					tradeupGrid.Rarity = tradeupGrid.Rarity or self.Rarity
					self.DoClick = self.TradeToItem
				end
			end

			function wepPnl:TradeToItem()
				tradeupGrid:RemoveItem(self, true)
				itemGrid:AddItem(self)

				if #tradeupGrid:GetItems() == 0 then
					tradeupGrid.Rarity = nil
				end

				self.DoClick = self.ItemToTrade
			end
			wepPnl.DoClick = wepPnl.ItemToTrade

			itemGrid:AddItem(wepPnl)
		end
	end

	local confirmBtn = frame:Add("DButton")
	confirmBtn:SetFont("wRaritySmall")
	confirmBtn:SetSize(80, 35)
	confirmBtn:SetText("Confirm")
	confirmBtn:SetTextColor(Color(255, 255, 255, 255))
	confirmBtn.Paint = function(s, w, h)
		if s.Depressed then
			draw.RoundedBox(6, 0, 0, w, h, Color(58, 165, 73))
		elseif s:IsHovered() then
			draw.RoundedBox(6, 0, 0, w, h, Color(88, 195, 103))
		else
			draw.RoundedBox(6, 0, 0, w, h, Color(68, 175, 83))
		end
	end
	confirmBtn:SetPos(frame:GetWide() - confirmBtn:GetWide() - 4, frame:GetTall() - confirmBtn:GetTall() - 4)
	confirmBtn.DoClick = function(s)
		local pnls = tradeupGrid:GetItems()

		if #pnls < wRarity.Config.TradeupAmt then
			nut.util.notify("Not enough items! You need " .. wRarity.Config.TradeupAmt .. ".")
			return
		end

		local items = {}
		for _, pnl in pairs(pnls) do
			table.insert(items, pnl.Wep)
		end

		net.Start("wRarityTradeup")
			net.WriteTable(items)
			net.WriteInt(tradeupGrid.Rarity, 32)
		net.SendToServer()

		frame:Close()
	end
end
net.Receive("wRarityTradeupMenu", function()
	if !file.Exists("tradeupinstructions.txt", "DATA") then
		local frame = vgui.Create("UI_DFrame")
		frame:SetSize(600, 400)
		frame:SetTitle("Weapon Trade Up Bench First Time Instructions")
		frame:Center()
		frame:MakePopup()

		local text = frame:Add("DPanel")
		text:Dock(FILL)
		local instructions = "In order to use this workbench simply select the weapons you want to trade up from the left panel. You can move them back over to the left by clicking them again at any time.\n\n Once you are happy with your selection click the confirm button in the bottom right to complete the trade up.\n\n All items in the trade up must be of the same rarity, however, may consist of an assortment of weapons.\n\n The weapon that you get as a result will be chosen randomly from the list of items that you put in."
		text.Text = jlib.WrapText(frame:GetWide() - 50, instructions, "wRaritySmall")
		text.Paint = function(s)
			draw.DrawText(s.Text, "wRaritySmall", (s:GetWide() / 2) + 2, 2, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
			draw.DrawText(s.Text, "wRaritySmall", s:GetWide() / 2, 0, nut.gui.palette.text_primary, TEXT_ALIGN_CENTER)
		end

		local continueBtn = frame:Add("UI_DButton")
		continueBtn:SetText("Continue")
		continueBtn:Dock(BOTTOM)
		continueBtn.DoClick = function()
			file.Write("tradeupinstructions.txt", "")
			frame:Close()
			wRarity.TradeUpMenu()
		end
	else
		wRarity.TradeUpMenu()
	end
end)
