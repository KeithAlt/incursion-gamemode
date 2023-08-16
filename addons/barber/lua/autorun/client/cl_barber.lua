-- Fonts
surface.CreateFont("BarberSkillcheck", {
	font = "Gardens CM",
	extended = true,
	size = ScreenScale(8),
	weight = 100,
	antialias = true
})

-- Barbershop preview menu
local COLOR = FindMetaTable("Color")
local PANEL = {}
local HAIR_GROUP = 2
local BEARD_GROUP = 3

function PANEL:Init()
	self:SetTitle("Barbershop")
	self:SetSize(ScrW() / 2, ScrH() / 2)

	local cancelConfirmPnl = self:Add("DPanel")
	cancelConfirmPnl:Dock(BOTTOM)
	cancelConfirmPnl:DockMargin(0, self:GetTall() / 50, 0, 0)
	cancelConfirmPnl:SetPaintBackground(false)

	local cancelBtn = cancelConfirmPnl:Add("UI_DButton")
	cancelBtn:SetText("Cancel")
	cancelBtn:SetContentAlignment(5)
	cancelBtn:Dock(FILL)
	cancelBtn.DoClick = function()
		surface.PlaySound("ui/ui_pip_mode.mp3")
		self:Close()
		net.Start("BarberCancel")
		net.SendToServer()
	end

	local left = self:GetDockPadding()

	local modelPreview = self:Add("jModelPanel")
	modelPreview:SetWide(self:GetWide() / 2 - (left * 1.5))
	modelPreview:Dock(LEFT)
	modelPreview:SetRotateSpeed(.6)

	self.ModelPreview = modelPreview
	self.CancelConfirm = cancelConfirmPnl
	self.CancelBtn = cancelBtn

	self:EnableControls(false)

	jlib.AddBackgroundBlur(self)

	Barber.PreviewPanel = self
end

function PANEL:EnableControls(bool)
	if bool then
		if !IsValid(self.ControlsPanel) then
			-- Resize to full
			self:SetSize(ScrW() / 2, ScrH() / 2)
			self:Center()

			-- Add controls on the right
			local _, _, right = self:GetDockPadding()

			local controlsPanel = self:Add("DScrollPanel")
			controlsPanel:Dock(RIGHT)
			controlsPanel:SetWide(self:GetWide() / 2 - (right * 1.5))
			controlsPanel:SetPaintBackground(false)

			-- Bodygroup buttons
			local function ChangePreviewBodygroup(group, btn)
				local previewEnt = self.ModelPreview:GetEntity()
				local value = previewEnt:GetBodygroup(group)
				local groupCount = previewEnt:GetBodygroupCount(group)
				local increment = btn == MOUSE_RIGHT and -1 or 1

				repeat
					value = value + increment

					if value >= groupCount then
						value = 0
					elseif value < 0 then
						value = groupCount - 1
					end
				until Barber.CanUseHair(group, value, self.Customer) -- Skip all hairs that the customer does not have permission to use

				previewEnt:SetBodygroup(group, value)

				net.Start("BarberUpdatePreview")
					net.WriteUInt(group, 2)
					net.WriteUInt(value, 16)
				net.SendToServer()
			end

			local hairSwitcher = controlsPanel:Add("UI_DButton")
			hairSwitcher:SetText("Change hairstyle")
			hairSwitcher:Dock(TOP)
			hairSwitcher:SetContentAlignment(5)
			hairSwitcher.OnMousePressed = function(s, btn)
				ChangePreviewBodygroup(HAIR_GROUP, btn)
				surface.PlaySound("ui/ok.mp3")
			end

			local beardSwitcher = controlsPanel:Add("UI_DButton")
			beardSwitcher:SetText("Change facial hair")
			beardSwitcher:Dock(TOP)
			beardSwitcher:SetContentAlignment(5)
			beardSwitcher.OnMousePressed = function(s, btn)
				ChangePreviewBodygroup(BEARD_GROUP, btn)
				surface.PlaySound("ui/ok.mp3")
			end

			-- Color picker
			if Barber.CanColorHead(self.Customer) then
				local colorSelector = controlsPanel:Add("DColorMixer")
				colorSelector:Dock(TOP)
				colorSelector:SetAlphaBar(false)
				colorSelector.ValueChanged = function(s, col)
					self.ModelPreview.Entity:SetColor(col)
				end
				if IsValid(self.ModelPreview.Entity) then
					colorSelector:SetColor(self.ModelPreview.Entity:GetColor())
				end
			end

			-- Add confirm button
			local btnW = self.CancelConfirm:GetWide() / 2

			self.CancelBtn:Dock(RIGHT)
			self.CancelBtn:SetWide(btnW)

			local confirmBtn = self.CancelConfirm:Add("UI_DButton")
			confirmBtn:SetText("Confirm")
			confirmBtn:SetContentAlignment(5)
			confirmBtn:Dock(LEFT)
			confirmBtn:SetWide(btnW)
			confirmBtn.DoClick = function()
				local ent = self.ModelPreview.Entity
				surface.PlaySound("ui/notify.mp3")
				net.Start("BarberFinalize")
					net.WriteUInt(ent:GetBodygroup(HAIR_GROUP), 16)
					net.WriteUInt(ent:GetBodygroup(BEARD_GROUP), 16)
					net.WriteColor(setmetatable(ent:GetColor(), COLOR))
					net.WriteUInt(ent:GetBodygroupCount(HAIR_GROUP), 16)
					net.WriteUInt(ent:GetBodygroupCount(BEARD_GROUP), 16)
				net.SendToServer()
				self:Close()
			end

			self.ControlsPanel = controlsPanel
			self.ConfirmBtn = confirmBtn
		end
	else
		if IsValid(self.ControlsPanel) then
			self.ControlsPanel:Remove()
		end

		if IsValid(self.ConfirmBtn) then
			self.ConfirmBtn:Remove()
			self.CancelBtn:Dock(FILL)
		end

		-- Resize it to just the model preview
		local left, _, right = self:GetDockPadding()
		self:SetWide(self.ModelPreview:GetWide() + left + right)
		self:Center()
	end

	self.ControlsEnabled = bool
end

function PANEL:SetPreviewHead(ply)
	local head = ply.Head
	if IsValid(head) then
		self.ModelPreview:SetModel(head:GetModel())
		local ent = self.ModelPreview:GetEntity()

		local headPos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Head1"))
		self.ModelPreview:SetLookAt(headPos)
		self.ModelPreview:SetCamPos(headPos + Vector(20, 0, 0))
		ent:SetEyeTarget(self.ModelPreview:GetCamPos())

		local col = head:GetColor()
		ent:SetBodygroup(HAIR_GROUP, head:GetBodygroup(HAIR_GROUP))
		ent:SetBodygroup(BEARD_GROUP, head:GetBodygroup(BEARD_GROUP))
		ent:SetSkin(head:GetSkin())
		ent:SetColor(col)

		self.LastColSent = col
	end
	self.Customer = ply
end

function PANEL:Think()
	local ent = self.ModelPreview.Entity
	if IsValid(ent) then
		local curCol = ent:GetColor()
		local lastSent = self.LastColorUpdate or -1
		if self.ControlsEnabled and !COLOR.__eq(self.LastColSent, curCol) and CurTime() - lastSent >= 1 then
			self.LastColSent = curCol
			self.LastColorUpdate = CurTime()

			net.Start("BarberUpdatePreviewCol")
				net.WriteColor(setmetatable(curCol, COLOR))
			net.SendToServer()
		end
	end
end

vgui.Register("BarberPreview", PANEL, "UI_DFrame")

-- Menu update networking
net.Receive("BarberOpenMenu", function()
	local customer = net.ReadEntity()

	local isWearingHat = false
	if IsValid(customer) then
		for k, _ in pairs(customer.Accessories or {}) do
			if Barber.Config.HatTypes[k] then
				isWearingHat = true
			end
		end
	end

	if isWearingHat or !IsValid(customer) or !IsValid(customer.Head) then
		net.Start("BarberCancel")
		net.SendToServer()

		chat.AddText(Color(255, 38, 23, 255), "Invalid customer, try removing anything that covers the head.")
		return
	end

	local pnl = vgui.Create("BarberPreview")
	pnl:MakePopup()
	pnl:SetKeyboardInputEnabled(false) -- To allow voice chat between the customer & barber during the process
	pnl:SetPreviewHead(customer)
	pnl:EnableControls(customer != LocalPlayer())
end)

net.Receive("BarberUpdatePreview", function()
	local bodygroup = net.ReadUInt(2)
	local value = net.ReadUInt(16)

	if IsValid(Barber.PreviewPanel) and IsValid(Barber.PreviewPanel.ModelPreview) and IsValid(Barber.PreviewPanel.ModelPreview.Entity) then
		Barber.PreviewPanel.ModelPreview.Entity:SetBodygroup(bodygroup, value)
	end
end)

net.Receive("BarberUpdatePreviewCol", function()
	local color = net.ReadColor()

	if IsValid(Barber.PreviewPanel) and IsValid(Barber.PreviewPanel.ModelPreview) and IsValid(Barber.PreviewPanel.ModelPreview.Entity) then
		Barber.PreviewPanel.ModelPreview.Entity:SetColor(color)
	end
end)

net.Receive("BarberCancel", function()
	if IsValid(Barber.PreviewPanel) then
		Barber.PreviewPanel:Close()
	end
end)
