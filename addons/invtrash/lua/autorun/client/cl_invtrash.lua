local PANEL = {}

function PANEL:Init()
	self:MakePopup()
	self:Center()
	self:ShowCloseButton(true)
	self:SetDraggable(true)
	self:SetTitle("Trash")
	self:SetDeleteOnClose(false)

	self.panels = {}

	if cookie.GetNumber("InvTrashTip", 0) != 1 then
		Derma_Message(jlib.WrapText(620, InvTrash.Config.InitialTip, "UI_Bold"), nil)
		cookie.Set("InvTrashTip", 1)
	end
end

-- Erase all items in the inv
function PANEL:EmptyTrash()
	net.Start("InvTrashEmpty")
		net.WriteUInt(self.invID, 32)
	net.SendToServer()
end

function PANEL:OnClose()
	self:Show()
	Derma_Query(InvTrash.Config.Confirmation, "", "Yes", function()
		self:EmptyTrash()
		self.Trashing = true
		self:Remove()
	end, "No")
end

-- Called when the window is removed for any reason, including hitting f1 and pressing the x button
function PANEL:OnRemove()
	if !self.Trashing then -- Makes sure we don't return trashed items
		net.Start("InvTrashDump") -- Returns the items to the player's inventory if they close the menu
			net.WriteUInt(self.invID, 32)
		net.SendToServer()
	end
end

vgui.Register("InvTrash", PANEL, "nutInventory")

-- Block all item interactions for items that are in the trash
hook.Add("OnCreateItemInteractionMenu", "InvTrash", function(panel, menu, item)
	local ply = LocalPlayer()
	local char = ply:getChar()
	local trashID = char and char:getData("trashInvID", -1) or -1

	if item.invID == trashID then
		InvTrash.Notify("You cannot interact with items in the trash")
		return true
	end
end)
