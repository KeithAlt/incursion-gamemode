local PANEL = {}

function PANEL:Init()
    self:SetSize(1092, 74)
    self.isMemberPanel = true
end

function PANEL:Paint(w, h)
    draw.RoundedBox(10, 0, 7, w, h - 7, hcWhitelist.theme.dropShadow)
    draw.RoundedBox(10, 5, 0, w - 10, 64, hcWhitelist.theme.primary)
end

function PANEL:SetPlayer(ply, data)
    --Remove any existing panels
    if ispanel(self.avatar) then
        self.avatar:Remove()
        self.avatar = nil
    end
    if ispanel(self.avatarFrame) then
        self.avatarFrame:Remove()
        self.avatarFrame = nil
    end
    if ispanel(self.avatarplaceholder) then
        self.avatarplaceholder:Remove()
        self.avatarplaceholder = nil
    end
    if ispanel(self.name) then
        self.name:Remove()
        self.name = nil
    end
    if ispanel(self.class) then
        self.class:Remove()
        self.class = nil
    end
    if ispanel(self.steamid) then
        self.steamid:Remove()
        self.steamid = nil
    end
    if ispanel(self.lastseen) then
        self.lastseen:Remove()
        self.lastseen = nil
    end
    if ispanel(self.actions) and ispanel(self.actions.optionsFrame) then
        self.actions.optionsFrame:Remove()
        self.actions.optionsFrame = nil
    end
    if ispanel(self.actions) then
        self.actions:Remove()
        self.actions = nil
    end

    self.data = data

    if IsValid(ply) then
        self.avatar = self:Add("AvatarImage")
        self.avatar:SetSize(64, 64)
        self.avatar:SetPlayer(ply, 64)
        self.avatar:SetPos(13, 0)

        local material = Material("hcwhitelist/avatarframe.png")

        self.avatarFrame = self:Add("DImage")
        self.avatarFrame:SetSize(64, 64)
        self.avatarFrame:SetPos(13, 0)
        self.avatarFrame:SetImageColor(hcWhitelist.theme.primary)
        self.avatarFrame:SetMaterial(material)
    else
        local steamID = data.steamid

        --Download their steam avatar using steam API
        if !file.Exists("hcwhitelistavatarcache", "DATA") then
            file.CreateDir("hcwhitelistavatarcache")
        end

        --Delete the image from the cache if it is old
        if file.Exists("hcwhitelistavatarcache/" .. steamID .. ".png", "DATA") and os.time() - file.Time("hcwhitelistavatarcache/" .. steamID .. ".png", "DATA") > hcWhitelist.config.avatarCacheMaxAge then
            file.Delete("hcwhitelistavatarcache/" .. steamID .. ".png")
        end

        if file.Exists("hcwhitelistavatarcache/" .. steamID .. ".png", "DATA") then --Check if we have already cached their avatar
            local material = Material("data/hcwhitelistavatarcache/" .. steamID .. ".png")

            self.avatar = self:Add("DImage")
            self.avatar:SetSize(64, 64)
            self.avatar:SetMaterial(material)
            self.avatar:SetPos(13, 0)

            material = Material("hcwhitelist/avatarframe.png")

            self.avatarFrame = self:Add("DImage")
            self.avatarFrame:SetSize(64, 64)
            self.avatarFrame:SetPos(13, 0)
            self.avatarFrame:SetImageColor(hcWhitelist.theme.primary)
            self.avatarFrame:SetMaterial(material)
        else
            --Place a loading animation as a placeholder while we download the image
            local frames = {
                Material("hcwhitelist/frame1.png"),
                Material("hcwhitelist/frame2.png"),
                Material("hcwhitelist/frame3.png")
            }
            self.avatarplaceholder = self:Add("DImage")
            self.avatarplaceholder:SetSize(64, 64)
            self.avatarplaceholder:SetPos(13, 0)
            self.avatarplaceholder:CenterVertical()
            self.avatarplaceholder.Think = function(s)
                if (s.NextThink or 0) <= CurTime() then
                    s.NextThink = CurTime() + (1/3)
                    if !s.frame or s.frame == 3 then
                        s.frame = 1
                    else
                        s.frame = s.frame + 1
                    end
                    s:SetMaterial(frames[s.frame])
                end
            end

            --Use the steamAPI to get the URL to the avatar
            http.Fetch("https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=" .. hcWhitelist.config.steamAPIKey .. "&steamids=" .. steamID, function(body)
                local result = util.JSONToTable(body)
                local url = result.response.players[1].avatarfull or false

				if !url then return end

                http.Fetch(url, function(img) --Download the avatar
                    file.Write("hcwhitelistavatarcache/" .. steamID .. ".png", img)

                    hcWhitelist.consoleLog("Cached avatar for steam user with SteamID " .. steamID)

                    if !IsValid(self) then
                        return
                    end

                    local material = Material("data/hcwhitelistavatarcache/" .. steamID .. ".png")

                    self.avatar = self:Add("DImage")
                    self.avatar:SetSize(64, 64)
                    self.avatar:SetMaterial(material)
                    self.avatar:SetPos(13, 0)

                    material = Material("hcwhitelist/avatarframe.png")

                    self.avatarFrame = self:Add("DImage")
                    self.avatarFrame:SetSize(64, 64)
                    self.avatarFrame:SetPos(13, 0)
                    self.avatarFrame:SetImageColor(hcWhitelist.theme.primary)
                    self.avatarFrame:SetMaterial(material)

                    if IsValid(self.avatarplaceholder) then
                        self.avatarplaceholder:Remove()
                    end
                end,
                function(err)
                    hcWhitelist.consoleLog("Failed to fetch steam avatar for SteamID64: " .. steamID, true)
                end)
            end,
            function(err)
                hcWhitelist.consoleLog("Failed to fetch steam avatar url for SteamID64: " .. steamID, true)
            end)
        end
    end

    self.name = self:Add("DLabel")
    self.name:SetFont(hcWhitelist.config.font)
    self.name:SetText(data.name)
    self.name:SetSize(300, self:GetTall())
    self.name:SetPos(86, 0)
    self.name:CenterVertical()
    self.name:SetTextColor(hcWhitelist.theme.textColor)

    self.class = self:Add("DLabel")
    self.class:SetFont(hcWhitelist.config.font)
    self.class:SetText(nut.class.list[hcWhitelist.uniqueIDToID(data.class)].name)
    self.class:SetSize(160, self:GetTall())
    self.class:MoveRightOf(self.name, 6)
    self.class:CenterVertical()
    self.class:SetTextColor(hcWhitelist.theme.textColor)

    self.steamid = self:Add("DLabel")
    self.steamid:SetFont(hcWhitelist.config.font)
    self.steamid:SetText(data.steamid)
    self.steamid:SetSize(140, self:GetTall())
    self.steamid:MoveRightOf(self.class, 6)
    self.steamid:CenterVertical()
    self.steamid:SetTextColor(hcWhitelist.theme.textColor)

    self.lastseen = self:Add("DLabel")
    self.lastseen:SetFont(hcWhitelist.config.font)
    self.lastseen:SetText(os.date("%d/%m/%Y", data.lastseen))
    self.lastseen:SetSize(95, self:GetTall())
    self.lastseen:MoveRightOf(self.steamid, 18)
    self.lastseen:CenterVertical()
    self.lastseen:SetTextColor(hcWhitelist.theme.textColor)

    self.actions = self:Add("DImageButton")
    self.actions:SetImage("hcwhitelist/ellipses.png")
    self.actions:SetColor(Color(0, 0, 0, 30))
    self.actions:SizeToContents()
    self.actions:MoveRightOf(self.lastseen, 140)
    self.actions:CenterVertical()
    self.actions.Think = function(s)
        if s:IsHovered() then
            s:SetColor(hcWhitelist.theme.dropShadow)
        else
            s:SetColor(hcWhitelist.theme.border)
        end
    end
    self.actions.DoClick = function(s)
        --Check this in DoClick instead of just disabling the button so we can tell them they can't do that
		if hcWhitelist.isNCO(LocalPlayer()) and !hcWhitelist.isHC(LocalPlayer()) then
			local classID = hcWhitelist.uniqueIDToID(data.class)

        	if (nut.class.list[classID].NCO or nut.class.list[classID].Officer) and !LocalPlayer():IsSuperAdmin() then
            	nut.util.notify("You can't perform actions on this member!")
            	return
        	end
		end

        self.optionsFrame = self:GetParent():GetParent():GetParent():Add("DFrame")
        self.optionsFrame:SetTitle(data.name .. " actions")
        self.optionsFrame:SetSize(500, 300)
        self.optionsFrame:Center()
        self.optionsFrame.Paint = function(_, w, h)
    		surface.SetDrawColor(hcWhitelist.theme.background)
    		surface.DrawRect(0, 0, w, h)

    		surface.SetDrawColor(Color(100, 100, 100, 25))
    		surface.DrawOutlinedRect(0 + 1, 0 + 1, w - 2, h - 2)

            surface.SetDrawColor(hcWhitelist.theme.border)
    		surface.DrawRect(0, 0, w, 24)

            surface.SetDrawColor(hcWhitelist.theme.border)
    		surface.DrawOutlinedRect(0, 0, w, h)
        end

        --Set name panels
        self.optionsFrame.nameLabel = self.optionsFrame:Add("DLabel")
        self.optionsFrame.nameLabel:SetFont(hcWhitelist.config.font)
        self.optionsFrame.nameLabel:SetText("Set Name:")
        self.optionsFrame.nameLabel:SizeToContents()
        self.optionsFrame.nameLabel:SetPos(0, 50)
        self.optionsFrame.nameLabel:CenterHorizontal()
        self.optionsFrame.nameLabel:SetTextColor(hcWhitelist.theme.textColor)

        self.optionsFrame.nameEntry = self.optionsFrame:Add("DTextEntry")
        self.optionsFrame.nameEntry:SetText(data.name)
        self.optionsFrame.nameEntry:SetWide(230)
        self.optionsFrame.nameEntry:MoveBelow(self.optionsFrame.nameLabel, 10)
        self.optionsFrame.nameEntry:CenterHorizontal()

        self.optionsFrame.nameConfirm = self.optionsFrame:Add("DButton")
        self.optionsFrame.nameConfirm:SetText("Set Name")
        self.optionsFrame.nameConfirm:MoveBelow(self.optionsFrame.nameEntry, 6)
        self.optionsFrame.nameConfirm:CenterHorizontal()
        self.optionsFrame.nameConfirm.DoClick = function(this)
            local name = self.optionsFrame.nameEntry:GetText()
            net.Start("hcAction")
                net.WriteString("setName" .. (data.online and "" or "Offline"))
                net.WriteTable({tonumber(data.charid), name})
            net.SendToServer()

            hcWhitelist.log(LocalPlayer():Nick() .. " has attempted to set " .. data.name .. "'s name to " .. name, LocalPlayer():SteamID64(), data.steamid, true)

            self.name:AlphaTo(0, 0.5, 0, function()
                self.name:SetText(name)
                data.name = name
                self.name:AlphaTo(255, 0.5, 0.3)
            end)
        end

        --Set class panels
        self.optionsFrame.classLabel = self.optionsFrame:Add("DLabel")
        self.optionsFrame.classLabel:SetFont(hcWhitelist.config.font)
        self.optionsFrame.classLabel:SetText("Set Class:")
        self.optionsFrame.classLabel:SizeToContents()
        self.optionsFrame.classLabel:SetPos(0, 150)
        self.optionsFrame.classLabel:CenterHorizontal()
        self.optionsFrame.classLabel:SetTextColor(hcWhitelist.theme.textColor)

        self.optionsFrame.classSelection = self.optionsFrame:Add("DComboBox")
        self.optionsFrame.classSelection:SetValue("Classes")
        self.optionsFrame.classSelection:SetWide(130)
        self.optionsFrame.classSelection:MoveBelow(self.optionsFrame.classLabel, 10)
        self.optionsFrame.classSelection:CenterHorizontal()

        local classes = hcWhitelist.getClasses(nut.class.list[hcWhitelist.uniqueIDToID(data.class)].faction)

		--NCOs can't make anyone else HC/NCO
		if hcWhitelist.isNCO(LocalPlayer()) and !hcWhitelist.isHC(LocalPlayer()) then
			for i, class in pairs(classes) do
				if class.Officer or class.NCO then
					classes[i] = nil
				end
			end
		end

        for i = 1, #classes do
            local class = classes[i]
            self.optionsFrame.classSelection:AddChoice(class.name, class.index)
        end

        self.optionsFrame.classConfirm = self.optionsFrame:Add("DButton")
        self.optionsFrame.classConfirm:SetText("Set Class")
        self.optionsFrame.classConfirm:MoveBelow(self.optionsFrame.classSelection, 6)
        self.optionsFrame.classConfirm:CenterHorizontal()
        self.optionsFrame.classConfirm.DoClick = function(this)
            local _, classID = self.optionsFrame.classSelection:GetSelected()
            if !classID then
                nut.util.notify("No class selected!")
                return
            end

            net.Start("hcAction")
                net.WriteString("setClass" .. (data.online and "" or "Offline"))
                net.WriteTable({tonumber(data.charid), classID})
            net.SendToServer()

            local className = nut.class.list[classID].name
            hcWhitelist.log(LocalPlayer():Nick() .. " has attempted to set " .. data.name .. "'s class to " .. className, LocalPlayer():SteamID64(), data.steamid, true)

            self.class:AlphaTo(0, 0.5, 0, function()
                self.class:SetText(className)
                self.class:AlphaTo(255, 0.5, 0.3)
            end)
        end

        --Discharge panels
        self.optionsFrame.dischargeButton = self.optionsFrame:Add("DButton")
        self.optionsFrame.dischargeButton:SetText("Discharge")
        self.optionsFrame.dischargeButton:SetPos(0, 265)
        self.optionsFrame.dischargeButton:CenterHorizontal()
        self.optionsFrame.dischargeButton.DoClick = function(this)
            local skipDefault
            if !data.online then
                skipDefault = false
            end

            net.Start("hcAction")
                net.WriteString("setFaction" .. (data.online and "" or "Offline"))
                net.WriteTable({tonumber(data.charid), "wastelander", skipDefault})
            net.SendToServer()

            hcWhitelist.log(LocalPlayer():Nick() .. " has attempted to set " .. data.name .. "'s faction to wastelander", LocalPlayer():SteamID64(), data.steamid, true)

            self.optionsFrame:Close()
            s:SetDisabled(true)

            --Animate and remove this member panel then move all the panels below this one up
            self:MoveBy(-60, 0, 0.6, 0, -1, function()
                self:MoveBy(self:GetWide(), 0, 0.5, 0, -1, function()
                    self:Remove()

                    if self.id then
                        local memberPanels = self:GetParent():GetChildren()
                        for i = self.id, #memberPanels do
                            local panel = memberPanels[i]
                            panel:MoveBy(0, -79, 0.5)
                            panel.id = panel.id - 1
                        end
                    end
                end)
            end)
        end
    end
end

function PANEL:OnMouseReleased(keycode)
    if keycode == MOUSE_RIGHT and self.data then
        local menu = self:Add("DMenu")
        menu:SetPos(input.GetCursorPos())

        menu:AddOption("Copy Name", function()
            SetClipboardText(self.data.name)
        end):SetIcon("icon16/page_copy.png")

        menu:AddOption("Copy SteamID", function()
            SetClipboardText(self.data.steamid)
        end):SetIcon("icon16/page_copy.png")

        menu:Open()
    end
end
vgui.Register("hcMember", PANEL, "DPanel")

PANEL = {}

local function recursiveAlphaTo(panel)
    panel:AlphaTo(0, 1, 0, function()
        if !IsValid(panel) then
            return
        end
        panel:AlphaTo(255, 1, 0, function()
            if !IsValid(panel) then
                return
            end
            recursiveAlphaTo(panel)
        end)
    end)
end

function PANEL:Init()
    self:SetSize(64, 64)
    self:SetPos(ScrW(), 256)
    self:MoveTo(ScrW() - 64, 256, 1)
    timer.Simple(hcWhitelist.config.popupTimeout, function()
        if IsValid(self) then
            self:MoveTo(ScrW(), 256, 1, 0, -1, function()
                self:Remove()
                hcWhitelist.notifPopup = nil
            end)
        end
    end)

    local exclamation = self:Add("DLabel")
    exclamation:SetSize(self:GetSize())
    exclamation:SetText("!")
    exclamation:SetContentAlignment(5)
    exclamation:SetFont("hcWhitelistLarge")
    exclamation:SetTextColor(Color(255, 255, 255, 255))
    timer.Simple(1, function()
        recursiveAlphaTo(exclamation)
    end)
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(hcWhitelist.theme.popupColor)
    surface.DrawRect(0, 0, w, h)
end

function PANEL:OnMouseReleased(keycode)
    if keycode == MOUSE_LEFT then
        self:MoveTo(ScrW(), 256, 1, 0, -1, function()
            self:Remove()
            hcWhitelist.notifPopup = nil
        end)

        hcWhitelist.showMOTD()
    elseif keycode == MOUSE_RIGHT then
        self:MoveTo(ScrW(), 256, 1, 0, -1, function()
            self:Remove()
            hcWhitelist.notifPopup = nil
        end)
    end
end
vgui.Register("hcNotification", PANEL, "DImageButton")
