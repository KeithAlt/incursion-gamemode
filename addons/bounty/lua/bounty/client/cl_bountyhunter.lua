JOB_REQUEST_LIST = JOB_REQUEST_LIST or {}

BT_DEVMODE_HECK = true

net.Receive('nutJobAdd', function(len)
	local charID, info = tonumber(net.ReadString()), net.ReadTable()
	JOB_REQUEST_LIST[charID] = info
end)

net.Receive('nutJobRemove', function(len)
	local charID = tonumber(net.ReadString()) --i wanted to ReadInt but it didn't work so now we have to tonumber()
	JOB_REQUEST_LIST[charID] = nil
end)

net.Receive('nutJobUpdate', function(len)
	local charID, bountyInfo = tonumber(net.ReadString()), net.ReadTable()
	JOB_REQUEST_LIST[charID] = info
end)

net.Receive('nutJobSync', function(len)
	local info = util.JSONToTable(net.ReadString())
	JOB_REQUEST_LIST = info
end)

surface.CreateFont("WantedPosterTextName", {
	font = "rosewood",
	size = 17,
	weight = 500,
	antialias = true,
})

surface.CreateFont("WantedPosterTextBounty", {
	font = "rosewood",
	size = 20,
	weight = 500,
	antialias = true,
})

surface.CreateFont("PlaceBountyCheckMark", {
	font = "rosewood",
	size = 23,
	weight = 500,
	antialias = true,
})

surface.CreateFont( "tbfy_header", {
	font = "Arial",
	size = 20,
	weight = 1000,
	antialias = true,
})

surface.CreateFont("tbfy_entname", {
	font = "Verdana",
	size = 12,
	weight = 1000,
	antialias = true,
})

surface.CreateFont("tbfy_buttontext", {
	font = "Verdana",
	size = 11,
	weight = 1000,
	antialias = true,
})

local MainPanelColor = Color(255,255,255,200)
local HeaderColor = Color(50,50,50,255)
local TabListColors = Color(215,215,220,255)
local ButtonColor = Color(50,50,50,255)
local ButtonColorHovering = Color(75,75,75,200)
local ButtonColorPressed = Color(150,150,150,200)
local ButtonOutline = Color(0,0,0,200)
local Padding = 5
local HeaderH = 25

local PANEL = {}

function PANEL:Init()
	self.ButtonText = ""
	self.ButtonTextColor = Color(255,255,255,255)
	self.BColor = ButtonColor
	self:SetText("")
	self.Font = "tbfy_buttontext"
	self.DClickC = ButtonColorPressed
	self.DHoverC = ButtonColorHovering
	self.DButtonC = ButtonColor
end

function PANEL:UpdateColours()

	if self:IsDown() or self.m_bSelected then self.BColor = self.DClickC return end
	if self.Hovered and !self:GetDisabled() then self.BColor = self.DHoverC return end

	self.BColor = self.DButtonC
	return
end

function PANEL:SetBText(Text)
	self.ButtonText = Text
end

function PANEL:SetBTextColor(Color)
	self.ButtonTextColor = Color
end

function PANEL:SetBFont(Font)
	self.Font = Font
end

function PANEL:SetBColors(Press,Hover,Normal)
	self.DClickC = Press
	self.DHoverC = Hover
	self.DButtonC = Normal
end

function PANEL:Paint(W,H)
	draw.RoundedBox(4, 0, 0, W, H, self.BColor)
	draw.SimpleText(self.ButtonText, self.Font, W/2, H/2, self.ButtonTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end
vgui.Register("tbfy_button", PANEL, "DButton")

net.Receive("RemoveBountyMenu", function(length, client)
	if BountyMenu then
		BountyMenu:Remove()
		BountyMenu = nil
	end
end)

net.Receive("open_place_bounty_menu", function(length, client)
	vgui.Create("place_bounty_menu");
end)

local sscale = ScreenScale
local Frame = Material("bountyframe.png")

local PANEL = {}

local Width, Height = sscale(144), sscale(216)
function PANEL:Init()
	self:SetTitle("")
	self:ShowCloseButton(false)
    self:SetDraggable(false)
    self:MakePopup()

	self.Name = ""

	self.IconIMG = vgui.Create("DPanel", self)
	self.IconIMG.Paint = function(panel, W,H)
		if(self.Icon.Display) then
			surface.SetMaterial(self.Icon.Display)
			surface.SetDrawColor(50, 50, 50, 255)
			surface.DrawTexturedRect(0, 0, W, H)
		end
	end

	local icons = {
		["icons/caps.png"] = "Caps",
		["icons/27.png"] = "Gun",
		["icons/56.png"] = "Fist",
		["icons/70.png"] = "Clover",
		["icons/74.png"] = "Tool",
		["icons/76.png"] = "Syringe",
		["icons/78.png"] = "Star",
		["icons/82.png"] = "Skull",
		["icons/90.png"] = "Bag",
		["icons/98.png"] = "Apple",
		["icons/102.png"] = "Warning",
		["icons/142.png"] = "Shield",
		["icons/164.png"] = "Chemical",
		["icons/172.png"] = "Dog",
		["icons/229.png"] = "Key",
		["icons/285.png"] = "Ammo",
		["icons/291.png"] = "Trap",
		["icons/379.png"] = "Tree",
		["icons/397.png"] = "Smile",
		["icons/409.png"] = "Medical",
	}

	self.Icon = vgui.Create("DComboBox", self)
	self.Icon:SetValue("")
	self.Icon.DisplayText = "Select Icon"
	for k,v in pairs(icons) do
		self.Icon:AddChoice(v, {icon = k})
	end
	self.Icon.OnSelect = function(panel, index, value)
		local id, data = self.Icon:GetSelected()
		local icon = data.icon

		self.Icon.Display = Material(icon, "noclamp")

		self.Icon.savedVal = icon
		self.Icon:SetValue("")
	end

	self.BountyField = vgui.Create("DTextEntry", self)
	self.BountyField:SetPlaceholderText(L("bountyEnterAmount"))
	self.BountyField:SetFont("WantedPosterTextBounty")
	self.BountyField:SetTextColor(Color(0,0,0,255))
	self.BountyField:SetDrawBackground(true)
	self.BountyField:SetDrawBorder(true)
	self.BountyField:SetUpdateOnType(true)

	self.ReasonField = vgui.Create("DTextEntry", self)
	self.ReasonField:SetPlaceholderText(L("Description"))
	self.ReasonField:SetFont("WantedPosterTextBounty")
	self.ReasonField:SetTextColor(Color(0,0,0,255))
	self.ReasonField:SetDrawBackground(true)
	self.ReasonField:SetDrawBorder(true)
	self.ReasonField:SetUpdateOnType(true)

	self.MeetField = vgui.Create("DTextEntry", self)
	self.MeetField:SetPlaceholderText(L("Contact"))
	self.MeetField:SetFont("WantedPosterTextBounty")
	self.MeetField:SetTextColor(Color(0,0,0,255))
	self.MeetField:SetDrawBackground(true)
	self.MeetField:SetDrawBorder(true)
	self.MeetField:SetUpdateOnType(true)

	self.TimeField = vgui.Create("DCheckBox", self)
	self.TimeField:SetToolTip(L("Remove on Disconnect?"))
	self.TimeField:SetValue(true)
	self.TimeField:SetDrawBackground(true)
	self.TimeField:SetDrawBorder(true)

	self.PlaceButton = vgui.Create("tbfy_button", self)
	self.PlaceButton:SetBFont("PlaceBountyCheckMark")
	self.PlaceButton:SetBText("✓")
	self.PlaceButton:SetBColors(Color(0,0,0,0), Color(0,0,0,0), Color(0,0,0,0))
	self.PlaceButton:SetBTextColor(Color(22,155,22, 255))
	self.PlaceButton.DoClick = function()
		local amount = self.BountyField:GetValue()
		local reason = self.ReasonField:GetValue()
		local contact = self.MeetField:GetValue()
		local removeOnDC = self.TimeField:GetChecked()
		local icon = self.Icon.savedVal

		local oldPoster = JOB_REQUEST_LIST[tonumber(LocalPlayer():getChar():getID())]
		if(oldPoster) then
			nut.util.notify("You already have a job posted.")
			return
		end

		if (amount and reason and contact) then
			net.Start("create_job")
				net.WriteString(amount)
				net.WriteString(reason)
				net.WriteString(contact)
				net.WriteBool(removeOnDC)
				net.WriteString(icon or "")
			net.SendToServer()

			self:Remove()
		end
	end

	self.CloseButton = vgui.Create("tbfy_button", self)
	self.CloseButton:SetBText("X")
	self.CloseButton:SetBColors(Color(0,0,0,0), Color(0,0,0,0), Color(0,0,0,0))
	self.CloseButton:SetBTextColor(Color(222,22,22, 255))
	self.CloseButton.DoClick = function() self:Remove() end
end

function PANEL:PerformLayout()
	local ScW, ScH = ScrW(), ScrH()
	self:SetPos(ScW/2-Width/2, ScH/2-Height/2)
    self:SetSize(Width, Height)

	local x, y, w, h
	x, y = sscale(10), sscale(53)
	w, h = sscale(120), sscale(118)
	self.IconIMG:SetPos(x, y)
	self.IconIMG:SetSize(w, h)

	h = sscale(10)
	y = y

	self.Icon:SetSize(w, h)
	self.Icon:SetPos(Width/2 - w/2, y)

	w = sscale(60)
	y = Height - sscale(40)
	self.BountyField:SetPos(Width/2-w/2, y)
	self.BountyField:SetSize(w,h)

	w = sscale(100)
	y = y + sscale(10)
	self.ReasonField:SetPos(Width/2-w/2, y)
	self.ReasonField:SetSize(w,h)

	w = sscale(100)
	y = y + sscale(10)
	self.MeetField:SetPos(Width/2-w/2, y)
	self.MeetField:SetSize(w,h)

	w = sscale(100)
	y = y + sscale(10)
	self.TimeField:SetPos(Width/2-w/2, y)

	y = y - sscale(10)
	self.PlaceButton:SetPos(Width-sscale(15), y)
	self.PlaceButton:SetSize(20,20)

	self.CloseButton:SetPos(Width-sscale(12), 30)
	self.CloseButton:SetSize(20,20)
end

function PANEL:Paint(W,H)
	surface.SetMaterial(Frame)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(0, 0, W, H)
end
vgui.Register("place_bounty_menu", PANEL, "DFrame")

local targetMat = Material("bountytarget.png")
surface.CreateFont("bounty3D2D", {font = "Arial", size = 52})
hook.Add("PostDrawOpaqueRenderables", "BountyTarget", function()
	local ply = LocalPlayer()
	local target = ply:GetNWEntity("BountyTarget")

	if IsValid(target) and target:IsPlayer() then
		local w = 160
	    local h = 160

		local eyeAng = EyeAngles()
        eyeAng.p = 0
        eyeAng.y = eyeAng.y - 90
        eyeAng.r = 90

        local bone = target:LookupBone("ValveBiped.Bip01_Head1")
        local pos = bone and (target:GetBonePosition(bone) + Vector(0, 0, 15)) or (target:GetPos() + Vector(0, 0, (target:OBBMaxs().z * target:GetModelScale()) + 35))

        cam.Start3D2D(pos, eyeAng, 0.05)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(targetMat)
            surface.DrawTexturedRect(-w/2, (-h/2) - 10, w, h)
            jlib.ShadowText("ENEMY", "bounty3D2D", 0, 45, Color(255, 191, 0, 255), Color(0, 0, 0, 255), 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        cam.End3D2D()
	end
end)
