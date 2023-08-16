local PANEL = {}
	function PANEL:Init()
		if (nut.gui.instanceEditor) then
		  nut.gui.instanceEditor:Remove()
		end;

		nut.gui.instanceEditor = self

		entity = false
		instance = false

		self:SetSize(512, 512)
		self:Center()
		self:MakePopup()
		self:SetSkin("flat")
		self:SetTitle("Merchant Instance Editor")
		template = self:Add("DTextEntry")
			template:Dock(TOP)
			template:SetTall(24)
			template:SetPlaceholderText("Template...")
			template:SetFont("UI_Regular")

		name = self:Add("DTextEntry")
			name:Dock(TOP)
			name:DockMargin(0, 6, 0, 0)
			name:SetTall(24)
			name:SetPlaceholderText("Name...")
			name:SetFont("UI_Regular")

		model = self:Add("DTextEntry")
			model:Dock(TOP)
			model:DockMargin(0, 6, 0, 0)
			model:SetTall(24)
			model:SetPlaceholderText("Model...")
			model:SetFont("UI_Regular")

		faction = self:Add("DTextEntry")
			faction:Dock(TOP)
			faction:DockMargin(0, 6, 0, 0)
			faction:SetTall(24)
			faction:SetPlaceholderText("Faction...")
			faction:SetFont("UI_Regular")

		buyScale = self:Add("DNumSlider")
			buyScale:Dock(TOP)
			buyScale:DockMargin(0, 6, 0, 0)
			buyScale:SetText("Buy Scale:")
			buyScale:SetMin(0)
			buyScale:SetMax(100)
			buyScale:SetValue(50)

		del = self:Add("DButton")
			del:Dock(BOTTOM)
			del:DockMargin(0, 6, 0, 0)
			del:SetText("Delete Instance")
			del.DoClick = function()
				netstream.Start("nutMerchantsInstanceDelete", instance, entity)
				self:Remove()
			end;

		save = self:Add("DButton")
			save:Dock(BOTTOM)
			save:SetText("Save & Exit")
			save.DoClick = function()
				if (!template:GetText() or !name:GetText() or !model:GetText()) then
					return
				else
					local data = {template = template:GetText(), name = name:GetText(), model = model:GetText(), buyScale = buyScale:GetValue() / 100, faction = faction:GetValue()}
					netstream.Start("nutMerchantsInstanceSave", instance, data, entity)
					self:Remove()
				end;
			end;
	end;

	function PANEL:open(int, data, ent)
		entity = ent

		if (!int) then
			Derma_StringRequest("Provide a unique ID", "Please provide a unique ID, this cannot be changed.\nIf this ID is the same as one already in use it will be overwritten!", "", function(text)
				instance = string.gsub(text:lower(), "%s+", "_")
			end)
		else
			instance = int
		end;

		if (data) then
			template:SetText(data.template or nil)
			name:SetText(data.name or nil)
			model:SetText(data.model or nil)

			local scale = data.buyScale or 0.5
			buyScale:SetValue(scale * 100)
		end;
	end;

vgui.Register("nutMerchantInstanceEditor", PANEL, "DFrame")
