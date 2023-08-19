local PANEL = {}

function PANEL:Init()
	if (IsValid(nut.gui.looter)) then
		nut.gui.looter:Remove()
	end

	nut.gui.looter = self

	self:SetSize(256, 512)
	self:SetPos((ScrW() - ScrW() * 0.2) - 256, (ScrH() / 2) - 256)
	self:SetTitle("Looter")

	self:MakePopup()

	local close = self:Add("UI_DButton")
	close:SetText("Close")
	close:SetContentAlignment(5)
	close:Dock(BOTTOM)
	close.DoClick = function()
		self:Remove()
	end
end

function PANEL:UpdateItems(items)
	for i, v in ipairs(items) do
		if nut.item.list[v] then
			local t = self:Add("UI_DButton")
			t:SetText(nut.item.list[v].name)
			t:Dock(TOP)
			t:SetContentAlignment(5)
			t.DoClick = function()
				netstream.Start("looterTake", v, self.Ent)
			end
			t.item = v

			table.insert(self.Btns, t)
		end
	end
end

function PANEL:open(entity)
	if IsValid(entity) then
		self.Ent = entity
		self.Btns = {}

		self:UpdateItems(entity:getNetVar("items", {}))
	end
end

function PANEL:Think()
	if IsValid(self.Ent) then
		self.OldItems = self.OldItems or self.Ent:getNetVar("items", {})

		local items = self.Ent:getNetVar("items", {})
		if #self.OldItems != #items then
			for i, pnl in ipairs(self.Btns) do
				if IsValid(pnl) then
					pnl:Remove()
				end
			end

			self:UpdateItems(items)
			self.OldItems = items
		end
	end
end

vgui.Register("nutLooter", PANEL, "UI_DFrame")
