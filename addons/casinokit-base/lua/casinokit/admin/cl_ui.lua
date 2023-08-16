
local function OpenUI(data)
	local fr = vgui.Create("DFrame")
	fr:SetTitle("CasinoKit Config")
	fr:SetSkin("CasinoKit")

	local p = fr:Add("DForm")
	p:Dock(FILL)

	-- Fun hack to automatically set label width to 250
	local oldAddItem = p.AddItem
	function p:AddItem(l, r)
		oldAddItem(self, l, r)
		if IsValid(l) then
			l:SetSize(250, 20)
		end
	end

	local dc = p:TextEntry("Disabled currencies (separate by comma)")
	dc:SetText(data["currency.disabled"] or "")

	local pc = p:TextEntry("Primary currency:")
	pc:SetText(data["currency.primary"] or "")

	local mcc = p:TextEntry("Maximum chip count (excl. won rewards):")
	mcc:SetText(data["chip.maxcount"] or "-1")

	p:Button("Save").DoClick = function()
		net.Start("casinokit_admin")

		data["currency.disabled"] = dc:GetText()
		data["currency.primary"] = pc:GetText()
		data["chip.maxcount"] = mcc:GetText()

		net.WriteTable(data)
		net.SendToServer()

		fr:Close()
	end

	fr:SetSize(800, 600)
	fr:Center()
	fr:MakePopup()
end

net.Receive("casinokit_admin", function()
	OpenUI(net.ReadTable())
end)