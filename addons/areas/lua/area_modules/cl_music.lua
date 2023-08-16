Areas.Music = Areas.Music or {}
Areas.Music.SongPos = Areas.Music.SongPos or {}
Areas.Music.Print = jlib.GetPrintFunction("[AreasMusic]", Color(128, 0, 128, 255))
Areas.Music.ConVarName = "areavolume"
Areas.Music.FadeTime = 2

-- Client setting
local convar = CreateClientConVar(Areas.Music.ConVarName, "1", true, false, "", 0, 1)
hook.Add("jSettingsInit", "AreasMusic", function()
	jSettings.AddSlider("Audio", "Area Music Volume", 0, 1, 2, Areas.Music.ConVarName)
end)

-- CVars to be automatically set to 0 when the music begins
Areas.Music.OtherAudioCVars = {
	GetConVar("nombat_volume")
}
Areas.Music.OtherCVarRestore = Areas.Music.OtherCVarRestore or {}

-- Change the currently playing music's volume on demand
cvars.AddChangeCallback(Areas.Music.ConVarName, function(cvar, old, new)
	local area = LocalPlayer():GetArea()
	new, old = tonumber(new), tonumber(old)

	if IsValid(area) then
		if IsValid(area.Sound) then
			area.Sound:StopFade()
			area.Sound:SetVolume(new)
		elseif old <= 0 and new > 0 and #area:GetMusic() > 0 then
			Areas.Music.Play(LocalPlayer(), area)
		end
	end
end)

-- Remembering where the song left off
function Areas.Music.Remember(chnl)
	local fileName = chnl:GetFileName()
	local curTime = chnl:GetTime()

	Areas.Music.Print("Remembering song time ", fileName, "@", curTime)

	Areas.Music.SongPos[fileName] = curTime
end

function Areas.Music.Restore(chnl)
	local fileName = chnl:GetFileName()
	local restoreTime = Areas.Music.SongPos[fileName] or 0

	Areas.Music.Print("Restoring song time ", fileName, "@", restoreTime)

	chnl:SetTime(restoreTime)
end

-- Fade music in
function Areas.Music.Play(ply, area)
	local vol = convar:GetFloat()
	local choices = area:GetMusic()

	if vol > 0 and #choices > 0 and ply == LocalPlayer() then
		local music = "sound/" .. choices[math.random(#choices)]

		if ply == LocalPlayer() then
			Areas.Music.Print("Now playing ", music)

			sound.PlayFile(music, "noblock", function(chnl, errCode, errString)
				if IsValid(chnl) then
					Areas.Music.Restore(chnl)
					chnl:FadeIn(vol, Areas.Music.FadeTime)
					chnl:EnableLooping(true)
					area.Sound = chnl
				else
					Areas.Music.Print("Error playing music: ", errCode, " ", errString)
				end
			end)

			for i, cvar in ipairs(Areas.Music.OtherAudioCVars) do
				local name = cvar:GetName()
				if Areas.Music.OtherCVarRestore[name] == nil then
					Areas.Music.OtherCVarRestore[name] = cvar:GetFloat()
				end

				cvar:SetFloat(0)
			end
		end
	end
end
hook.Add("PlayerEnteredArea", "Music", Areas.Music.Play)

-- Fade music out
function Areas.Music.Stop(ply, area)
	if IsValid(area.Sound) then
		Areas.Music.Print("Stopping ", area.Sound:GetFileName())

		area.Sound:FadeOut(Areas.Music.FadeTime, function(chnl)
			if IsValid(chnl) then
				Areas.Music.Remember(chnl)
				chnl:Stop()
			end

			for i, cvar in ipairs(Areas.Music.OtherAudioCVars) do
				local name = cvar:GetName()
				local oldValue = Areas.Music.OtherCVarRestore[name]
				if oldValue and oldValue != 0 then
					cvar:SetFloat(oldValue)
				end

				Areas.Music.OtherCVarRestore[name] = nil
			end
		end)
	end
end
hook.Add("PlayerLeftArea", "Music", Areas.Music.Stop)

-- Area music config
function Areas.Music.OpenConfig(area)
	local frame = vgui.Create("DFrame")
	frame:SetTitle("Music Zone Configuration")
	frame:SetSize(600, 275)
	frame:Center()
	frame:MakePopup()

	local sounds = frame:Add("DListView")
	sounds:Dock(TOP)
	sounds:SetSize(400, 200)
	sounds:DockMargin(0, 0, 0, 5)
	sounds:SetMultiSelect(false)
	sounds:AddColumn("Soundpath")
	sounds.OnRowRightClick = function(s, id, line)
		local menu = DermaMenu(false, frame)
		menu:SetPos(frame:LocalCursorPos())
		menu:AddOption("Remove", function()
			net.Start("AreasRemoveSong")
				net.WriteInt(area.ID, 32)
				net.WriteString(line:GetColumnText(1))
			net.SendToServer()

			s:RemoveLine(id)
		end):SetIcon("icon16/delete.png")
	end

	for i, song in ipairs(area:GetMusic()) do
		sounds:AddLine(song)
	end

	local addSongBtn = frame:Add("DButton")
	addSongBtn:Dock(TOP)
	addSongBtn:SetText("Add Song")
	addSongBtn:DockMargin(0, 0, 0, 5)
	addSongBtn.DoClick = function(s)
		Derma_StringRequest("Soundpath", "Input a soundpath", "", function(newSong)
			sounds:AddLine(newSong)

			net.Start("AreasAddSong")
				net.WriteInt(area.ID, 32)
				net.WriteString(newSong)
			net.SendToServer()
		end)
	end
end
