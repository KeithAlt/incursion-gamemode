local PANEL = {}
	function PANEL:Init()
		self:SetSize(768, 768)
		self:Center()
		self:MakePopup()
		self:SetSkin("fallout")
		self:SetPaintBackground(false)

		if (nut.gui.armormod) then
			nut.gui.armormod:Remove()
		end

		inv = {}

		nut.gui.armormod = self

		local cB = self:Add("DPanel")
			cB:Dock(BOTTOM)
			cB:SetHeight(42)
			cB:DockPadding(6, 6, 6, 6)
		local closeButton = cB:Add("falloutButton")
			closeButton:Dock(FILL)
			closeButton:SetFont("falloutRegular")
			closeButton:SetText("Close")
			closeButton.DoClick = function()
				self:Remove()
			end

		modList = self:Add("DPanel")
			modList:Dock(LEFT)
			modList:SetWidth(352)
			modList:DockMargin(0, 0, 0, 16)
			modList:DockPadding(6, 6, 6, 6)

		preview = self:Add("DPanel")
			preview:Dock(RIGHT)
			preview:SetWidth(352)
			preview:DockMargin(0, 0, 0, 16)

			model = preview:Add("DModelPanel")
				model:Dock(FILL)
				model:SetModel(LocalPlayer():GetModel())

				local mn, mx = model.Entity:GetRenderBounds()
				local size = 0
				size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
				size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
				size = math.max(size, math.abs(mn.z) + math.abs(mx.z))

				model:SetFOV(20)
				model:SetCamPos(Vector(size, size, size))
				model:SetLookAt((mn + mx) * 0.5)
	end

	function PANEL:Open(inventory, armor)
		inv = inventory
		local armr = nut.armor.armors[armor]

		for i, v in pairs(nut.armor.mods) do
			if (!IsValid(v.isPA) or v.isPA == armor.powerArmor) then
				local t = modList:Add("UI_DButton")
					t:Dock(TOP)
					t:DockMargin(0, 0, 0, 6)
					t:SetContentAlignment(5)
					t:SetText(v.name)
					t.DoClick = function()
						netstream.Start("nutInstallArmorMod", i)
						inv[i] = nil
					end

					if (!inv["armormod_"..i:lower()]) then
						t:SetText(t:GetText().." (Missing Item)")
						t:SetDisabled(true)
					end
			end
		end
	end

	function PANEL:msg(installed, msg)
		Derma_Message(msg, msg, "OK")
		
		if(installed) then
			surface.PlaySound("sound/shelter/jingle/emergency_succes.ogg")
		end
	end

vgui.Register("nutArmorMod", PANEL, "DPanel")
