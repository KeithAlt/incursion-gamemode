local PANEL = {}
	function PANEL:Init()
		if (nut.gui.merchantEditor) then
		  nut.gui.merchantEditor:Remove()
		end;

		nut.gui.merchantEditor = self

		self:SetSize(sW(1024), sH(640))
		self:Center()
		self:MakePopup()
		self:SetSkin("flat")
		self:SetPaintBackground(false)

		unsaved = false

		active = 0
		template = {}
		templates = {}

		itemList = nut.item.list

		PLeft = self:Add("DPanel")
			PLeft:Dock(LEFT)
			PLeft:SetWidth(self:GetWide() * 0.25)
			PLeft:DockMargin(0, 0, 6, 0)

		templateList = PLeft:Add("DScrollPanel")
			templateList:Dock(FILL)
			templateList:DockMargin(6, 6, 6, 6)

		Close = PLeft:Add("DButton")
			Close:Dock(BOTTOM)
			Close:DockMargin(6, 0, 6, 6)
			Close:SetText("Close")
			Close.DoClick = function()
				if (unsaved) then
					Derma_Query("You have unsaved changes, what would you like to do?", "Unsaved changes", "Save & Exit", function()
						self:saveTemplate()
						self:Remove()
					end, "Exit Without Saving", function()
						self:Remove()
					end, "Cancel", function() end)
				else
					self:Remove()
				end;
			end;

		new = PLeft:Add("DButton")
			new:Dock(BOTTOM)
			new:DockMargin(6, 0, 6, 6)
			new:SetText("New Template")
			new.DoClick = function()
				Derma_StringRequest("", "Please provide an ID name for this template\nThis cannot be changed.", "", function(text)
					if (!templates[text:lower()]) then
						templates[text:lower()] = {items = {}}
						netstream.Start("nutMerchantsTemplateSave", string.gsub(text:lower(), "%s+", "_"), {items = {}})
						self:populateTemplates()
					else
						-- Pop-up if template exists.
					end;
				end, function() end)
			end;

		PRight = self:Add("DPanel")
			PRight:Dock(FILL)

		local temp = PRight:Add("DLabel")
			temp:Dock(FILL)
			temp:SetContentAlignment(5)
			temp:SetFont("UI_Big")
			temp:SetText("Please Select Template")
	end;

	function PANEL:open(data)
		templates = data
		self:populateTemplates()
	end;

	function PANEL:populateTemplates()
		templateList:Clear()
		for i, v in pairs(templates) do
			local t = templateList:Add("DButton")
				t:Dock(TOP)
				t:DockMargin(0, 0, 0, 6)
				t:SetText(i)
				t.DoClick = function()
					if (active != i) then
						if (unsaved) then
							Derma_Query("You have unsaved changes, what would you like to do?", "Unsaved changes", "Save Changes", function()
								self:saveTemplate()
								self:select(i)
							end, "Continue Without Saving", function()
								self:select(i)
							end, "Cancel", function() end)
						else
							self:select(i)
						end;
					end;
				end;
		end;
	end;

	function PANEL:select(tmp)
		active = tmp
		template = templates[tmp]

		PRight:Clear()

		local options = PRight:Add("DPanel")
			options:Dock(TOP)
			options:DockMargin(6, 6, 6, 0)
			options:SetTall(92)
			options.Paint = function(p, w, h)
				surface.SetDrawColor(nut.gui.palette.background_light)
				surface.DrawRect(0, 0, w, h)
			end;

		local editing = options:Add("DLabel")
			editing:Dock(TOP)
			editing:DockMargin(6, 0, 0, 0)
			editing:SetFont("UI_Regular")
			editing:SetText("Currently Editing: "..active)

		local saveTemplate = options:Add("DButton")
			saveTemplate:Dock(BOTTOM)
			saveTemplate:DockMargin(6, 0, 6, 6)
			saveTemplate:SetText("Save Template")
			saveTemplate.DoClick = function()
				self:saveTemplate()
			end;

		local addItem = options:Add("DButton")
			addItem:Dock(BOTTOM)
			addItem:DockMargin(6, 0, 6, 6)
			addItem:SetText("Add New Item")
			addItem.DoClick = function()
				self:newItem()
			end;

		items = PRight:Add("DScrollPanel")
			items:Dock(FILL)
			items:DockMargin(6, 6, 6, 6)

		self:populateItems()
	end;

	function PANEL:saveTemplate()
		netstream.Start("nutMerchantsTemplateSave", active, template)
		unsaved = false
	end;

	function PANEL:populateItems()
		items:Clear()
		for i, v in pairs(template.items) do
			items.i = items:Add("DPanel")
				items.i:Dock(TOP)
				items.i:DockMargin(0, 0, 0, 6)
				items.i:SetHeight(64)
				items.i:SetMouseInputEnabled(true)
				items.i.Paint = function(p, w, h)
					if (p:IsHovered()) then
						surface.SetDrawColor(nut.gui.palette.header)
					else
						surface.SetDrawColor(nut.gui.palette.background_light)
					end;

					surface.DrawRect(0, 0, w, h)
				end;
				items.i.OnMouseReleased = function(p, mousecode)
					if (mousecode == MOUSE_LEFT) then
						self:newItem(i) -- newItem() is also used for editing.
					elseif (mousecode == MOUSE_RIGHT) then
						Derma_Query("Are you sure you want to remove this item?", "Are you sure?", "Yes", function()
							template.items[i] = nil
							unsaved = true
							self:populateItems()
						end, "No", function() end)
					end;
				end;

				local icon = items.i:Add("nutSpawnIcon")
					icon:SetSize(52, 52)
					icon:Dock(LEFT)
					icon:DockMargin(6, 6, 6, 6)
					icon:SetModel(itemList[i].model)

				local label = items.i:Add("DLabel")
					label:Dock(LEFT)
					label:SetFont("UI_Regular")
					label:SetText(itemList[i].name)
					label:SizeToContentsX()

				local price = items.i:Add("DLabel")
					price:Dock(RIGHT)
					price:DockMargin(0, 0, 12, 0)
					price:SetFont("UI_Regular")
					price:SetText("$"..v.price)
					price:SizeToContentsX()
		end;
	end;

	function PANEL:newItem(itm)
		local sItm = 0

		PLeft:SetDisabled(true)
		PRight:SetDisabled(true)

		local editor = self:Add("DFrame")
			editor:SetSize(768, 512)
			editor:SetDraggable(false)
			editor:MakePopup()
			editor:SetPos((ScrW() / 2) - (self:GetWide() / 2), (ScrH() / 2) - (self:GetTall() / 2)) -- This is because editor:Center() isn't working.
			editor:DockPadding(0, 24, 0, 0)
			editor.lblTitle:SetFont("UI_Regular")
			editor.lblTitle:SetTextColor(nut.gui.palette.text_white)
			editor:SetTitle("Merchant Editor : New Item")
			editor.OnRemove = function()
				PLeft:SetDisabled(false)
				PRight:SetDisabled(false)
			end;

		local add = editor:Add("DButton")
			add:Dock(BOTTOM)
			add:DockMargin(6, 0, 6, 6)
			add:SetText("Add Item")

		local PSearch = editor:Add("DPanel")
			PSearch:Dock(LEFT)
			PSearch:DockMargin(6, 6, 6, 6)
			PSearch:SetWidth(256)
			PSearch.Paint = function(p, w, h)
				surface.SetDrawColor(nut.gui.palette.background_darker)
				surface.DrawRect(0, 0, w, h)
			end;

		local PSList = PSearch:Add("DScrollPanel")
			PSList:Dock(FILL)
			PSList:DockMargin(6, 0, 6, 6)

		local searchBar = PSearch:Add("DTextEntry")
			searchBar:Dock(TOP)
			searchBar:DockMargin(6, 6, 6, 6)
			searchBar:SetTall(24)
			searchBar:SetPlaceholderText("Search...")
			searchBar:SetFont("UI_Regular")

		local PInfo = editor:Add("DPanel")
			PInfo:Dock(FILL)
			PInfo:DockMargin(0, 6, 6, 6)
			PInfo.Paint = function(p, w, h)
				surface.SetDrawColor(nut.gui.palette.background_darker)
				surface.DrawRect(0, 0, w, h)
			end;

		local IName = PInfo:Add("DLabel")
			IName:Dock(TOP)
			IName:DockMargin(6, 0, 0, 0)
			IName:SetFont("UI_Regular")
			IName:SetText("Selected Item: None")

		local IPrice = PInfo:Add("DTextEntry")
			IPrice:Dock(TOP)
			IPrice:DockMargin(6, 6, 6, 6)
			IPrice:SetTall(24)
			IPrice:SetPlaceholderText("Price...")
			IPrice:SetFont("UI_Regular")
			IPrice:SetNumeric(true)

		local IMode = PInfo:Add("DComboBox")
			IMode:Dock(TOP)
			IMode:DockMargin(6, 0, 6, 6)
			IMode:SetTall(24)
			IMode:SetFont("UI_Regular")
			IMode:AddChoice("Sell")
			IMode:AddChoice("Buy")
			IMode:AddChoice("Buy & Sell")
			IMode:ChooseOptionID(1)

		add.DoClick = function()
			template.items[sItm] = {stock = false, price = tonumber(IPrice:GetText()), mode = IMode:GetSelectedID()} -- Modes: 1 = sell, 2 = buy, 3 = buy & sell.
			editor:Remove()
			self:populateItems()
			unsaved = true
		end;

		searchBar.OnEnter = function()
			PSList:Clear()
			for i, v in pairs(itemList) do
				if (searchBar:GetText():len() == 0 or string.find(searchBar:GetText():lower(), v.name:lower())) then
					PSList.i = PSList:Add("DButton")
					PSList.i:Dock(TOP)
					PSList.i:SetText(v.name)
					PSList.i.DoClick = function()
						sItm = i
						IName:SetText("Selected Item: "..v.name)

						if (template.items[i]) then
							IPrice:SetText(template.items[i].price)
							add:SetText("Save Changes")
						else
							IPrice:SetText(100)
						end;
					end;
				end;
			end;
		end;

		searchBar.OnEnter()

		if (itm) then
			sItm = itm
			IName:SetText("Editing Item: "..itemList[itm].name)
			IPrice:SetText(template.items[itm].price)
			IMode:ChooseOptionID(template.items[itm].mode or 1)
			add:SetText("Save Changes")
		end;
	end;

vgui.Register("nutMerchantTemplateEditor", PANEL, "DPanel")
