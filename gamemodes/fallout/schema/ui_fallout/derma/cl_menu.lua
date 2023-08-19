local PANEL = {}

function PANEL:Init()
	if hook.Run("PlayerCanMenu") == false then
		self:Remove()
		return
	end

	if (IsValid(nut.gui.menu)) then
		nut.gui.menu:Remove()
	end

	nut.gui.menu = self

	pages = {}
	act = 0

	anchor = true

	local character = LocalPlayer():getChar()

	self:Dock(FILL)
	self:MakePopup()
	self:Center()
	self:ParentToHUD()

	--[[exit = self:Add("DButton")
		exit:Dock(BOTTOM)
		exit.DoClick = function() self:Close() end]]--

	butts = self:Add("UI_DPanel_Vertical") -- Heh Heh, Butts.
	butts:SetSize(sW(896), 42)
	butts:SetPos((ScrW() * 0.5) - butts:GetWide() / 2, 16)
	butts:DockPadding(0, 6, 6, 6)

	menu = self:Add("UI_DPanel")
	menu:SetSize(sW(896), sH(704))
	menu:SetPos((ScrW() * 0.5) - menu:GetWide() / 2, ((ScrH() * 0.5) - menu:GetTall() / 2) + 16)
	menu:SetPaintBackground(false)

	info = menu:Add("DPanel")
	info:Dock(BOTTOM)
	info:SetHeight(32)
	info:SetPaintBackground(false)

	local tabs = menu:Add("DPanel")
	tabs:Dock(TOP)
	tabs:SetHeight(32)
	tabs.Paint = function(p, w, h)
		if (act > 0) then
			local bX, bY = buttons:GetPos()
			local aW = pages[act].button:GetWide()
			local b = 0

			for i = 1, act do
				if (i != act) then b = b + pages[i].button:GetWide() end
			end

			local s = bX + aW + b + 6

			surface.SetDrawColor(Color(0, 0, 0))

			DisableClipping(true)
			surface.DrawRect(1, 31, bX + 6 + b, 2)
			surface.DrawRect(s - 1, 31, menu:GetWide() - s + 2, 2)
			DisableClipping(false)

			surface.SetDrawColor(nut.gui.palette.color_primary)

			surface.DrawRect(0, 30, bX + 6 + b, 2)
			surface.DrawRect(s, 30, menu:GetWide() - s, 2)
		end
	end

	buttons = tabs:Add("DPanel")
	buttons:SetHeight(32)
	buttons:SetWidth(12)
	buttons:DockPadding(6, 0, 6, 0)
	buttons:SetPaintBackground(false)

	page = self:Add("DPanel")
	page:SetSize(menu:GetWide(), menu:GetTall() - 64)
	local x, y = menu:GetPos()
	page:SetPos(x, y + 32)
	page:DockPadding(6, 6, 6, 6)
	page.Paint = function(p, w, h)
		surface.SetDrawColor(Color(0, 0, 0, 100))
		surface.DrawRect(6, 6, w - 12, h - 12)

		surface.SetDrawColor(Color(0, 0, 0))

		DisableClipping(true)
		surface.DrawRect(1, 1, 2, 6)
		surface.DrawRect(w - 1, 1, 2, 6)
		DisableClipping(false)

		surface.SetDrawColor(nut.gui.palette.color_primary)

		surface.DrawRect(0, 0, 2, 6)
		surface.DrawRect(w - 2, 0, 2, 6)
	end

	local hp = self:addInfo()
	hp:SetWidth(128)

	local text = hp:Add("UI_DLabel")
	text:Dock(FILL)
	text:SetContentAlignment(5)
	text:SetText("❤ " .. LocalPlayer():Health() .. "/" .. LocalPlayer():GetMaxHealth())

	local caps = self:addInfo()
	caps:SetWidth(128)

	local text = caps:Add("UI_DLabel")
	text:Dock(FILL)
	text:SetContentAlignment(5)
	text:SetText("Ⓒ " .. jlib.CommaNumber(character:getMoney()))

	local level = self:addInfo()
	level:SetWidth(128)

	local text = level:Add("UI_DLabel")
	text:Dock(FILL)
	text:SetContentAlignment(5)
	text:SetText("Level "..LocalPlayer():getChar():getData("level", 0))

	local skillPoints = self:addInfo()
	skillPoints:SetWidth(128)

	local text = skillPoints:Add("UI_DLabel")
	text:Dock(FILL)
	text:SetContentAlignment(5)
	text:SetText("Skill Points "..LocalPlayer():getChar():getData("skillPoints", 0))

	local respec = self:addInfo()
	respec:Dock(FILL)
	respec:DockMargin(0, 0, 0, 0)

	local reset = respec:Add("UI_DButton")
	reset:Dock(FILL)
	reset:SetContentAlignment(5)
	reset:SetText("RESPEC")
	reset.DoClick = function()
		if (LocalPlayer():getChar():getData("level", 0) >= 50) then
			local reset = LocalPlayer():getChar():getData("reset", 0)
			if (reset == 0) then
				Derma_Query("Are you sure you want to respec your character?\n(Since this is your first it will be free)", "Are you sure?",
				"YES", function()
					netstream.Start("NutRespec")
					self:Remove()
				end, "NO")
			else
				local respecCost = nut.config.get("Respec Price")
				local shouldMultiply = nut.config.get("Respec Cost Multiplier")
				if !shouldMultiply then
					reset = 1
				end

				Derma_Query("Are you sure you want to respec your character?\n(This will cost you "..(respecCost * reset).." Caps)", "Are you sure?",
				"YES", function()
					netstream.Start("NutRespec")
					self:Remove()
				end, "NO")
			end
		else
			Derma_Message("You must be at least level 50 to respec.")
		end
	end

		--[[self:addTab("statistics", function()
			local t = page:Add("DPanel")
				t:SetSize(512, 512)
		end)]]--

		self:addTab("inv", function()
			if (hook.Run("CanPlayerViewInventory") != false) then
				nut.gui.inv1 = self:Add("nutInventory")

				nut.gui.inv1.childPanels = {}

				local inventory = LocalPlayer():getChar():getInv()

				if (inventory) then
					nut.gui.inv1:setInventory(inventory)
				end

				nut.gui.inv1:SetDraggable(false)
				nut.gui.inv1:NoClipping(false)

				local trashBtn = nut.gui.inv1:Add("DImageButton")
				trashBtn:SetSize(16, 16)
				trashBtn:SetImage("icon16/bin_closed.png")
				trashBtn:SetPos(nut.gui.inv1:GetWide() - trashBtn:GetWide(), 0)
				trashBtn.DoClick = function(s)
					local trashID = LocalPlayer():getChar():getData("trashInvID")

					if isnumber(trashID) and trashID > 0 then
						if !IsValid(s.TrashPnl) then
							x, y = nut.gui.inv1:GetPos()

							local trashPnl = nut.gui.inv1:Add("InvTrash")
							trashPnl:setInventory(nut.item.inventories[trashID])
							trashPnl:SetDraggable(false)
							trashPnl:SetPos(x + nut.gui.inv1:GetWide() + 5, y)

							s.TrashPnl = trashPnl

							nut.gui["inv" .. trashID] = trashPnl
						end
					else
						Derma_Message("Failed to load trash inventory ID #" .. (trashID or "none"))
					end
				end
			end
		end)

		self:addTab("skills", function()
			skerk = page:Add("nutSkerk")

			skerk:SetPaintBackground(false)

			local w, h = page:GetSize()
			local x, y = page:GetPos()

			skerk:SetPos((x - (skerk:GetWide() / 2)) + (w / 2), (y - (skerk:GetTall() / 2)) + (h / 2))
		end)

		self:addTab("special", function()
			special = page:Add("nutSpecial")

			special:SetPaintBackground(false)

			local w, h = page:GetSize()
			local x, y = page:GetPos()

			special:SetPos((x - (special:GetWide() / 2)) + (w / 2), (y - (special:GetTall() / 2)) + (h / 2))
		end)

		self:addTab("bank", function()
			local bankPanel = vgui.Create("UI_DPanel_Bordered", page)
			bankPanel:SetSize(600, 300)
			bankPanel:Center()

			local bal = LocalPlayer():getChar():getData("bankbal", 0)

			local balLabel = vgui.Create("UI_DLabel", bankPanel)
			balLabel:SetText("Balance: " .. jlib.CommaNumber(bal))
			balLabel:SetFont("UI_Medium")
			balLabel:SizeToContents()
			balLabel:SetPos(0, 15)
			balLabel:CenterHorizontal()

			local amtEntry = vgui.Create("UI_DTextEntry", bankPanel)
			amtEntry:SetSize(100, 30)
			amtEntry:Center()
			amtEntry.AllowInput = function(s, char)
				return type(tonumber(char)) != "number"
			end

			local withdrawButton = vgui.Create("UI_DButton", bankPanel)
			withdrawButton:SetText("Withdraw")
			withdrawButton:SetContentAlignment(5)
			withdrawButton:SetSize(100, 30)
			withdrawButton:CenterHorizontal()
			withdrawButton:MoveBelow(amtEntry, 5)

			local feeShow = vgui.Create("UI_DLabel", bankPanel)
			feeShow:SetText("Withdrawl Fee: " .. capsbankConfig.withdrawlFee * 100 .. "%")
			feeShow:SizeToContents()
			feeShow:CenterHorizontal()
			feeShow:MoveBelow(withdrawButton, 5)

			amtEntry.OnChange = function(s)
				local amt = tonumber(s:GetText())

				if !amt then
					feeShow:SetText("Withdrawl Fee: " .. capsbankConfig.withdrawlFee * 100 .. "%")
					feeShow:SizeToContents()
					feeShow:CenterHorizontal()
					return
				end

				feeShow:SetText("You will receive: " .. jlib.CommaNumber(math.floor(amt - (amt * capsbankConfig.withdrawlFee))))
				feeShow:SizeToContents()
				feeShow:CenterHorizontal()
			end

			withdrawButton.DoClick = function(s)
				local amt = tonumber(amtEntry:GetText())

				if !amt then
					nut.util.notify("Please enter an amount.")
					return
				elseif amt < 1 then
					nut.util.notify("Please enter a value of at least 1.")
					return
				elseif bal <= 0 then
					nut.util.notify("You have no caps in the bank to withdraw.")
					return
				elseif bal < amt then
					nut.util.notify("You do not have enough bank balance to withdraw that amount.")
					return
				elseif amt > 524287 then
					nut.util.notify("Please enter at most 524287.")
					return
				end

				bal = bal - amt
				balLabel:SetText("Balance: " .. bal)
				balLabel:SizeToContents()
				balLabel:CenterHorizontal()

				net.Start("capsbankRequestWithdrawl")
					net.WriteInt(amt, 20)
				net.SendToServer()

				local capsTextP = caps:GetChild(0)
				capsTextP:SetText("CAPS " .. math.floor(LocalPlayer():getChar():getMoney() + (amt - (amt * capsbankConfig.withdrawlFee))))
			end
		end)

		self:addTab("shop", function()
			page:Add("BuyMenuCategories")
		end)

		self:addTab("settings", function()
			jSettings.Fill(page)
		end)

		self:addSecondary("rewards", function()
			self:Remove()
			vgui.Create("nutDailyRewards")
		end)

		self:addTab("radio", function()
			local channels = {
				[1] = {"▶  Diamond City Radio", "http://fallout.fm:8000/falloutfm6.ogg"},
				[2] = {"▶  Galaxy News Radio", "http://fallout.fm:8000/falloutfm2.ogg"},
				[3] = {"▶  Radio New Vegas", "http://fallout.fm:8000/falloutfm3.ogg"},
				[6] = {"▶  New California Radio", "http://fallout.fm:8000/falloutfm8.ogg"},
				[4] = {"▶  Diamond Classical", "http://fallout.fm:8000/falloutfm7.ogg"},
				[6] = {"▶  Mount Point Radio", "http://fallout.fm:8000/falloutfm1.ogg"},
				[7] = {"▶  West Virginia Radio", "http://fallout.fm:8000/falloutfm10.ogg"},
				[8] = {"▶  Van Buren Signal", "http://fallout.fm:8000/falloutfm4.ogg"},
				[9] = {"▶  Megaton Classical", "http://fallout.fm:8000/falloutfm9.ogg"},
			}

			local stations = page:Add("DPanel")
			stations:Dock(LEFT)
			stations:SetWide(400)
			stations:SetPaintBackground(false)
			stations:DockMargin(6, 6, 0, 6)

			local broadcastBtn = stations:Add("UI_DButton")
			broadcastBtn:SetText("  ▶ Wasteland Radio - Channel " .. BROADCASTS.GetFrequency(1))
			broadcastBtn:SizeToContentsX()
			broadcastBtn:Dock(TOP)
			broadcastBtn:DockMargin(0, 0, 0, 6)
			broadcastBtn.DoClick = function()
				net.Start("broadcasts_joinByID")
					net.WriteUInt(1, 32)
				net.SendToServer()

				if IsValid(nut.radio) then
					nut.radio:Stop()
				end
			end

			for i, v in pairs(channels) do
				local button = stations:Add("UI_DButton")
				button:Dock(TOP)
				button:DockMargin(0, 0, 0, 6)
				button:SetText("  "..v[1])
				button.DoClick = function()
					if IsValid(nut.radio) then
						nut.radio:Stop()
					end

					sound.PlayURL(v[2], "", function(station, errID, err)
						if IsValid(station) then
							nut.radio = station
						else
							print("Error loading audio stream: ", errID, err)
						end
					end)

					if LocalPlayer():GetNWInt("broadcastListeningTo", 0) > 0 then
						net.Start("broadcasts_quitByID")
							net.WriteUInt(1, 32)
						net.SendToServer()
					end
				end
			end

			local off = stations:Add("UI_DButton")
			off:Dock(BOTTOM)
			off:SetText(" ⌧  RADIO OFF")
			off.DoClick = function()
				if IsValid(nut.radio) then
					nut.radio:Stop()
				end

				if LocalPlayer():GetNWInt("broadcastListeningTo", 0) > 0 then
					net.Start("broadcasts_quitByID")
						net.WriteUInt(1, 32)
					net.SendToServer()
				end
			end
		end)

	/**	self:addTab("map", function() -- Disabled by Keith, no capital wasteland map png
		gui.OpenURL( "https://i.imgur.com/ErfMByo.png" )
	end)**/

		self:addSecondary("guild", function()
			LocalPlayer():ConCommand("say /guild")
		end)

		self:addSecondary("group", function()
			LocalPlayer():ConCommand("say /groups")
		end)

		self:addSecondary("discord", function()
			gui.OpenURL("https://discord.gg/WBSuAfw")
		end)

		self:addSecondary("content", function()
			gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=948435070")
		end)

		self:addSecondary("rules", function()
			gui.OpenURL("https://claymoregaming.com/forums/index.php?/topic/64-fallout-incursion-rules/")
		end)

		self:addSecondary("changes", function()
			gui.OpenURL("https://claymoregaming.com/changes/")
		end)

		self:addSecondary("store", function()
			gui.OpenURL("https://steamcommunity.com/openid/login?openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.mode=checkid_setup&openid.return_to=https%3A%2F%2Fstore.claymoregaming.com%2Fstore%2Findex.php&openid.realm=https%3A%2F%2Fstore.claymoregaming.com&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select")
		end)


		self:addTab("menu", function()
			menu:SetDisabled(true)
			fadeOut(function()
				--kick currently selected char if it exists
				netstream.Start("nutCharKickSelf")

				self:Remove()
				vgui.Create("nutCharMenu"):open()
			end)
		end)

		if (LocalPlayer():IsSuperAdmin() and hook.Run("CanPlayerUseConfig") != false) then
			self:addTab("config", function()
				self:config()
			end)
		end

		surface.PlaySound("fallout/ui/menu/ui_menu_open.wav")

		timer.Simple(0.5, function() anchor = false end)

		--menu:SetSize(sW(896), sH(704))
		--menu:SetPos((ScrW() * 0.5) - menu:GetWide() / 2, ((ScrH() * 0.5) - menu:GetTall() / 2) + 16)

		local x, y = menu:GetPos()

		local level = LocalPlayer():getChar():getData("level", 0)
		local xpReq = nut.leveling.requiredXP(level + 1)
		local xpCur = LocalPlayer():getChar():getData("XP", 0)

		local expBar = self:Add("DPanel")
			expBar:SetSize(sW(896), 24)
			expBar:SetPos(x, y + sH(704) + 6)
			expBar:SetPaintBackground(false)
			expBar.Paint = function(p, w, h)
				surface.SetDrawColor(0, 0, 0, 150)
				surface.DrawRect(0, 0, w + 6, h)
				surface.SetDrawColor(0, 0, 0, 200)
				surface.DrawOutlinedRect(0, 0, w, h)

				surface.SetDrawColor(nut.gui.palette.color_primary)
				surface.DrawRect(3, 3, ((w - 6) / xpReq) * xpCur, h - 6)
			end
			local xpText = expBar:Add("UI_DLabel")
				xpText:Dock(FILL)
				xpText:SetContentAlignment(5)
				xpText:SetTextColor(nut.gui.palette.text_primary)
				xpText:SetText(jlib.CommaNumber(math.Round(xpCur, 2)) .. " / " .. jlib.CommaNumber(xpReq))	end

function PANEL:addSecondary(label, callback)
	local button = butts:Add("UI_DButton")
		button:Dock(LEFT)
		button:DockMargin(6, 0, 0, 0)
		button:SetText(" "..label:upper().." ")
		button:SetContentAlignment(5)
		button:SizeToContentsX()
		button.DoClick = function()
			callback()
		end
end

function PANEL:addTab(label, callback)
	local index = #pages + 1
	local t = {}

	t.button = buttons:Add("DButton")
	t.button:SetHeight(32)
	t.button:SetText(" "..label:upper().." ")
	t.button:SetContentAlignment(5)
	t.button:SetTextColor(nut.gui.palette.text_primary)
	t.button:SetExpensiveShadow(1, Color(0, 0, 0))
	t.button:SetFont("UI_Bold")
	t.button:SizeToContents()
	t.button:Dock(LEFT)
	t.button.DoClick = function()
		if (index > act) then
			surface.PlaySound("fallout/ui/menu/ui_menu_forward.wav")
		else
			surface.PlaySound("fallout/ui/menu/ui_menu_backward.wav")
		end

		surface.PlaySound("fallout/ui/menu/static/ui_menu_static_burst_"..math.random(1, 10)..".wav")

		act = index

		page:Clear()
		if (nut.gui.inv1) then nut.gui.inv1:Remove() end

		if (callback) then callback() end
	end
	t.button.Paint = function(p, w, h)
		if (act == index) then
			surface.SetDrawColor(Color(0, 0, 0))

			DisableClipping(true)
			surface.DrawRect(1, (h / 2) + 1, 2, h / 2)
			surface.DrawRect(0, (h / 2) + 1, 5, 2)

			surface.DrawRect(w - 2, (h / 2) + 1, 3, (h / 2) - 3)
			surface.DrawRect(w - 4, (h / 2) + 1, 5, 2)
			DisableClipping(false)

			surface.SetDrawColor(nut.gui.palette.color_primary)

			surface.DrawRect(0, h / 2, 2, h / 2)
			surface.DrawRect(0, h / 2, 4, 2)

			surface.DrawRect(w - 2, h / 2, 2, h / 2)
			surface.DrawRect(w - 4, h / 2, 4, 2)
		end
	end

	buttons:SetWidth(buttons:GetWide() + t.button:GetWide())
	buttons:SetPos((menu:GetWide() * 0.5) - (buttons:GetWide() * 0.5), 0)

	pages[index] = t

	if (act == 0) then act = index end

	if (index == 1) then timer.Simple(0.1, function() callback() end) end
end

function PANEL:addInfo()
	local t = info:Add("DPanel")
		t:Dock(LEFT)
		t:DockMargin(0, 0, 12, 0)
		t.Paint = function(p, w, h)
			surface.SetDrawColor(Color(0, 0, 0))
			surface.DrawRect(0, 0, w, h)
			DisableClipping(true)
			surface.DrawRect(1, 1, w, h)
			DisableClipping(false)
			surface.SetDrawColor(nut.gui.palette.color_background)
			surface.DrawRect(0, 0, w, h)
		end

	return t
end

function PANEL:config()
	local scroll = page:Add("DScrollPanel")
	scroll:Dock(FILL)

	local properties = scroll:Add("DProperties")
	properties:SetSize(page:GetSize())

	nut.gui.properties = properties

	local buffer = {}

	for k, v in pairs(nut.config.stored) do
		local index = v.data and v.data.category or "misc"

		buffer[index] = buffer[index] or {}
		buffer[index][k] = v
	end

	for category, configs in SortedPairs(buffer) do
		category = L(category)

		for k, v in SortedPairs(configs) do
			local form = v.data and v.data.form
			local value = nut.config.stored[k].default

			if (!form) then
				local formType = type(value)

				if (formType == "number") then
					form = "Int"
					value = tonumber(nut.config.get(k)) or value
				elseif (formType == "boolean") then
					form = "Boolean"
					value = util.tobool(nut.config.get(k))
				else
					form = "Generic"
				end
			end

			if (form == "Generic" and type(value) == "table" and value.r and value.g and value.b) then
				value = Vector(value.r / 255, value.g / 255, value.b / 255)
				form = "VectorColor"
			end

			local delay = 1

			if (form == "Boolean") then
				delay = 0
			end

			local row = properties:CreateRow(category, k)
			row:Setup(form, v.data and v.data.data or {})
			row:SetValue(value)
			row:SetToolTip(v.desc)
			row.DataChanged = function(this, value)
				timer.Create("nutCfgSend"..k, delay, 1, function()
					if (IsValid(row)) then
						if (form == "VectorColor") then
							local vector = Vector(value)

							value = Color(math.floor(vector.x * 255), math.floor(vector.y * 255), math.floor(vector.z * 255))
						elseif (form == "Int" or form == "Float") then
							value = tonumber(value)

							if (form == "Int") then
								value = math.Round(value)
							end
						elseif (form == "Boolean") then
							value = util.tobool(value)
						end

						netstream.Start("cfgSet", k, value)
					end
				end)
			end
		end
	end
end

function PANEL:Paint(w, h)
	nut.util.drawBlur(self, 5)
	surface.SetDrawColor(0, 0, 0, 150)
	surface.DrawRect(0, 0, w, h)
end

function PANEL:Close()
	self:Remove()
	surface.PlaySound("fallout/ui/menu/ui_menu_close.wav")
end

function PANEL:Think()
	if (input.IsKeyDown(KEY_F1) and anchor == false) then
		self:Close()
	end
end

vgui.Register("nutMenu", PANEL, "EditablePanel")
