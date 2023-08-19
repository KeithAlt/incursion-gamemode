
BROADCASTS.Data = BROADCASTS.Data or {}

surface.CreateFont("broadcast_36", {font = "Roboto", size = 36, weight = 400, antialias = true})
surface.CreateFont("broadcast_24", {font = "Roboto", size = 24, weight = 400, antialias = true})
surface.CreateFont("broadcast_20", {font = "Roboto", size = 20, weight = 400, antialias = true})
surface.CreateFont("broadcast_16", {font = "Roboto", size = 16, weight = 400, antialias = true})

local soundDirectory = "falloutradio" --falloutradio

local function SendSongLengths(tbl)
	net.Start("broadcasts_getSongLengths")
	net.WriteTable(tbl)
	net.SendToServer()
end

hook.Add("InitPostEntity", "PopulateBroadcastsSongLengths", function()
	if not LocalPlayer():IsSuperAdmin() then return end

	local songLengths = {}
	local filesDone = 0
	for k, songData in pairs(BROADCASTS.Config.SongList) do
		local filePath = "sound/" .. soundDirectory .. "/" .. songData.file

		sound.PlayFile(filePath , "noblock noplay", function(station, errCode, errStr)
			if IsValid(station) then
				songLengths[songData.file] = station:GetLength()

			else
				BROADCASTS.MsgC("UNABLE TO GET SONG LENGTH FOR SONG: " .. songData.title .. " " .. songData.artist .. " FILE: " .. filePath, true)
			end

			filesDone = filesDone + 1

			if filesDone == #BROADCASTS.Config.SongList then
				SendSongLengths(songLengths)
			end
		end)
	end
end)

-- This can continue to use the entity since the menu is opened by using the entity
-- so it certainly will be in PVS.
net.Receive("broadcasts_openMenu", function()
	local broadcast = net.ReadEntity()
	BROADCASTS.OpenMenu(broadcast)
end)

net.Receive("broadcasts_toggleSong", function()
	local id = net.ReadUInt(32)
	local paused = net.ReadBool()
	if !BROADCASTS.Data[id] then return end

	local songData = BROADCASTS.Data[id].songData
	songData.paused = paused
	if songData and songData.station:IsValid() then
		local identifier = id .. "clearSongData"
		if not paused then
			songData.station:Play()
			surface.PlaySound("ambient/levels/prison/radio_random5.wav")
			timer.Start(identifier)
		else
			songData.station:Pause()
			surface.PlaySound("ambient/levels/prison/radio_random7.wav")
			timer.Pause(identifier)
		end
	end
end)

net.Receive("broadcasts_quitSong", function()
	local id = net.ReadUInt(32)
	local data = BROADCASTS.Data[id]
	if data and data.songData and IsValid(data.songData.station) then
		data.songData.station:Stop()
	end
end)

net.Receive("broadcasts_playSong", function()
	local songKey = net.ReadUInt(8)
	local id = net.ReadUInt(32)
	local songListData = BROADCASTS.Config.SongList[songKey]
	if not songListData then return end

	BROADCASTS.Data[id] = BROADCASTS.Data[id] or {}
	local data = BROADCASTS.Data[id]
	local songData = data.songData
	if songData and songData.station:IsValid() then
		songData.station:Stop()
	end
	sound.PlayFile( "sound/" .. soundDirectory .. "/" .. songListData.file, "noblock", function(station, errCode, errStr)
		if IsValid(station)then
			station:Play()
			surface.PlaySound("ambient/levels/prison/radio_random5.wav")
			data.songData = {
				songKey = songKey,
				station = station,
				paused = false,
			}
			timer.Create(id .. "clearSongData", station:GetLength(), 1, function()
				if not data then return end
				data.songData = nil
			end)
		end
	end)
end)

net.Receive("broadcasts_joinSong", function()
	local songKey = net.ReadUInt(8)
	local id = net.ReadUInt(32)
	local timeStamp = net.ReadUInt(12)
	local paused = net.ReadBool()
	local songListData = BROADCASTS.Config.SongList[songKey]
	if not songListData then return end

	BROADCASTS.Data[id] = BROADCASTS.Data[id] or {}
	local data = BROADCASTS.Data[id]
	local songData = data.songData
	if songData and songData.station:IsValid() then
		songData.station:Stop()
	end
	sound.PlayFile( "sound/" .. soundDirectory .. "/" .. songListData.file, "noblock", function( station, errCode, errStr )
		if ( IsValid( station ) ) then
			station:Play()
			surface.PlaySound("ambient/levels/prison/radio_random5.wav")
			station:SetTime(timeStamp)
			data.songData = {
				songKey = songKey,
				station = station,
				paused = paused,
			}
		end
	end )
end)


function BROADCASTS.OpenMenu(broadcast)
	if IsValid(BROADCASTS.Menu) then
		BROADCASTS.Menu:Remove()
	end
	BROADCASTS.Menu = vgui.Create("BroadcastManager")
	BROADCASTS.Menu.broadcastEnt = broadcast
	net.Start("broadcasts_forceJoin")
	net.WriteEntity(broadcast)
	net.SendToServer()
end

local PANEL = {}
local pause = Material("broadcasts/pause.png", "noclamp smooth")
local play = Material("broadcasts/play.png", "noclamp smooth")

local function formatSongPlayTime(time)
	local minutes = math.floor(time%3600/60)
	local seconds = math.floor(time%60)
	return minutes .. ":" .. (seconds < 10 and 0 or "") .. seconds
end

function PANEL:Init()
	local scrw,scrh = ScrW(),ScrH()
	local theme = BROADCASTS.GetTheme()
	local yPad = scrh * .015
	local xPad = scrw * .02
	self.broadcasting = true
	self:SetSize(0,0)
	self.isAnimating = true
	self:SizeTo(scrw * .32, scrh * .6, 1, 0, .1, function(anim, pnl)
		self.isAnimating = false
	end)
	self:MakePopup()
	self:SetTitle("")
	self:DockPadding(0, 0, 0, 0)
	self.topBar = self:Add("DPanel")
	self.topBar:Dock(TOP)
	self.topBar.Paint = function(me,w,h)
		surface.SetDrawColor(theme.panel)
		surface.DrawRect(0,0,w,h)
		if not IsValid(self.broadcastEnt) then return end

		local textColor = theme.text
		local text = "Live"
		surface.SetDrawColor(theme.red)
		textColor = theme.text
		local data = BROADCASTS.Data[self.broadcastEnt.broadcastID]
		local songData = data and data.songData or nil

		if songData and not songData.paused and songData.station then
			surface.SetDrawColor(theme.blue)
			text  = "Broadcasting Song"
		end
		local radius = h * .15
		if not me.circleData then
			local x,y = radius + w * .025, h * .5
			local seg = 25
			me.circleData = {}
			table.insert( me.circleData, { x = x, y = y, u = 0.5, v = 0.5 } )
			for i = 0, seg do
				local a = math.rad( ( i / seg ) * -360 )
				table.insert( me.circleData, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
			end

			local a = math.rad( 0 ) -- This is needed for non absolute segment counts
			table.insert( me.circleData, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
		end
		draw.NoTexture()
		surface.DrawPoly( me.circleData )
		draw.SimpleText(text, "broadcast_20", w * .025 + radius * 4, h * .5, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	end

	self.musicState = self:Add("DPanel")
	self.musicState:Dock(TOP)
	self.musicState:DockMargin(xPad, yPad, xPad, 0)
	self.musicState.Paint = function(me,w,h)

		surface.SetDrawColor(theme.panel)
		surface.DrawRect(0,0,w,h)

		local data = BROADCASTS.Data[self.broadcastEnt.broadcastID]
		local songData = data and data.songData or nil

		if not songData or songData and not songData.station or songData.station and not songData.station:IsValid() then
			draw.SimpleText("You're currently not listening to this channel.", "broadcast_20", w * .5, h * .4, theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("Opt into this channel or play a song.", "broadcast_20", w * .5, h * .6, theme.gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			return
		end

		local station = songData.station
		local songListData = BROADCASTS.Config.SongList[songData.songKey]

		draw.SimpleText(songListData.title, "broadcast_24", w * .5, h * .2, theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(songListData.artist, "broadcast_24", w * .5, h * .4, theme.gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		local barPad = w * .09
		local barH = h * .04
		local barY = h - barH - yPad
		local barW = w - barPad * 2
		local curTime, endTime = station:GetTime(), station:GetLength()
		draw.RoundedBox(6, barPad, barY, barW, barH, theme.panel)
		draw.RoundedBox(6, barPad, barY, barW * (curTime / endTime), barH, theme.gray)
		local textPad = w * .01
		draw.SimpleText(formatSongPlayTime(curTime), "broadcast_20", barPad - textPad, barY + barH * .5, theme.gray, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		draw.SimpleText(formatSongPlayTime(endTime), "broadcast_20", barPad + barW + textPad, barY + barH * .5, theme.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	self.playButton = self.musicState:Add("DButton")
	self.playButton:SetText("")
	self.playButton.Paint = function(me,w,h)
		local data = BROADCASTS.Data[self.broadcastEnt.broadcastID]
		local songData = data and data.songData or nil
		if not songData then return end

		local station = songData.station
		if not station:IsValid() then return end
		local activeMat = songData.paused and play or pause
		surface.SetMaterial(activeMat)
		surface.SetDrawColor(theme.gray)
		surface.DrawTexturedRect(0,0,w,h)
		if me:IsHovered() then
			surface.SetDrawColor(color_white)
			surface.DrawTexturedRect(0,0,w,h)
		end
		--draw.SimpleText("Pause", "broadcast_20", w * .5, h * .5, theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	self.playButton.DoClick = function()
		local data = BROADCASTS.Data[self.broadcastEnt.broadcastID]
		local songData = data and data.songData or nil

		if !data or !songData or !IsValid(self.broadcastEnt) or (self.SelectionDelay and (CurTime() < self.SelectionDelay)) then return end

		self.SelectionDelay = CurTime() + 2

		net.Start("broadcasts_toggleSong")
		net.WriteEntity(self.broadcastEnt)
		net.SendToServer()
	end
	self.musicState.OnSizeChanged = function(me,w,h)
		self.playButton:SetSize(h * .19, h * .19)
		self.playButton:SetPos( w * .5 - self.playButton:GetWide() * .5, h - self.playButton:GetTall() - yPad * 2)
	end

	self.closeButton = self.topBar:Add("DButton")
	self.closeButton:Dock(RIGHT)
	self.closeButton:SetText("")
	self.closeButton.Paint = function(me,w,h)
		draw.SimpleText("X", "broadcast_20", w * .5, h * .5, theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	self.closeButton.DoClick = function()
		if self.SelectionDelay and (CurTime() < self.SelectionDelay) then return end

		self.SelectionDelay = CurTime() + 2

		net.Start("broadcasts_forceQuit")
		net.WriteEntity(self.broadcastEnt)
		net.SendToServer()
		self:Remove()
	end

	self.songPanels = {}
	self.songPanel = self:Add("DPanel")
	self.songPanel:Dock(FILL)
	self.songPanel:DockMargin(xPad, yPad, xPad, yPad)
	self.songPanel.Paint = function(me,w,h)
		surface.SetDrawColor(theme.panel)
		surface.DrawRect(0,0,w,h)
	end


	self.listDividers = self.songPanel:Add("DPanel")
	self.listDividers:Dock(TOP)
	self.listDividers.Paint = function(me,w,h)
		local pad = w * .05
		surface.SetDrawColor(theme.darkgray)
		surface.DrawRect(pad, h - 1, w - pad * 2, 1)
		draw.SimpleText("TITLE", "broadcast_20", w * .025 + pad, h * .5, theme.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("ARTIST", "broadcast_20", w * .025 + pad + w * .5, h * .5, theme.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	table.insert(self.songPanels, self.listDividers)

	self.scroll = self.songPanel:Add("DScrollPanel")
	self.scroll:Dock(FILL)
	self.scroll:DockMargin(0, 0, 0, 0)

	self:PopulateSongs()
	self:ShowCloseButton(false)
end

function PANEL:PopulateSongs()
	if not IsValid(self.scroll) then return end
	local theme = BROADCASTS.GetTheme()
	local yPad = ScrH() * .015

	for k,v in pairs(BROADCASTS.Config.SongList) do
		local song = self.scroll:Add("DButton")
		song:SetText("")
		song:Dock(TOP)
		song:DockMargin(0, 0, 0, 0)
		song.Paint = function(me,w,h)
			local pad = w * .05
			surface.SetDrawColor(theme.darkgray)
			surface.DrawRect(pad, h - 1, w - pad * 2, 1)
			if me:IsHovered() then
				surface.SetDrawColor(theme.highlight)
				surface.DrawRect(pad,0,w - pad * 2,h)
			end
			draw.SimpleText(v.title, "broadcast_20", w * .025 + pad, h * .5, theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(v.artist, "broadcast_20", w * .025 + pad + w * .5, h * .5, theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
		song.DoClick = function()
			self:SelectSong(k)
		end
		table.insert(self.songPanels, song)
	end

	self.scroll.OnSizeChanged = function(me,w,h)
		for k, v in pairs(self.songPanels) do
			v:SetTall(math.ceil(h * .1))
		end
	end
end

function PANEL:SelectSong(songKey)
	if not IsValid(self.broadcastEnt) then
		self:Remove()
	end

	if self.SelectionDelay and (CurTime() < self.SelectionDelay) then return end
	self.SelectionDelay = CurTime() + 2

	net.Start("broadcasts_playSong")
	net.WriteUInt(songKey, 8)
	net.WriteEntity(self.broadcastEnt)
	net.SendToServer()
end

function PANEL:OnSizeChanged(w,h)
	if self.isAnimating then
		self:Center()
	end
	if IsValid(self.topBar) then
		local pad = h * .01
		self.topBar:SetTall(h * .05)
		self.topBar.circleData = nil
		if IsValid(self.closeButton) then
			self.closeButton:SetWide(w * .05)
		end
	end
	if IsValid(self.musicState) then
		self.musicState:SetTall(h * .2)
	end
	if IsValid(self.scroll) then
		--self.scroll:SetTall(h * .7)
	end
end

function PANEL:Paint(w,h)
	local theme = BROADCASTS.GetTheme()
	self:BlurMenu( 16, 16, 255, true )
	surface.SetDrawColor(theme.panel)
	surface.DrawRect(0,0,w,h)
end

local blur = Material( "pp/blurscreen" )
function PANEL:BlurMenu( layers, density, alpha)
	-- Its a scientifically proven fact that blur improves a script
	-- 🧢
	local x, y = self:LocalToScreen( 0, 0 )
	surface.SetDrawColor( 255, 255, 255, alpha )
	surface.SetMaterial( blur )

	for i = 1, 5 do
		blur:SetFloat( "$blur", ( i / 4 ) * 4 )
		blur:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
	end
end

derma.DefineControl("BroadcastManager", "Broadcast Manager DFrame", PANEL, "DFrame")

hook.Add("VoiceNotifyColor", "Broadcasts", function(ply)
	if bit.band(ply:GetNWInt("broadcastSpeakingTo", 0), LocalPlayer():GetNWInt("broadcastListeningTo", 0)) > 0 then
		return Color(3, 161, 252, 70), Color(3, 215, 252)
	end
end)
