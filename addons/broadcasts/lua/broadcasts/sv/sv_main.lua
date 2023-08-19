local _P = FindMetaTable("Player")

local nets = {
	"broadcasts_openMenu",
	"broadcasts_playSong",
	"broadcasts_toggleSong",
	"broadcasts_joinSong",
	"broadcasts_quitSong",
	"broadcasts_getSongLengths",
	"broadcasts_forceJoin",
	"broadcasts_forceQuit",
	"broadcasts_joinByID",
	"broadcasts_quitByID"
}

resource.AddFile("materials/broadcasts/circle.png")
resource.AddFile("materials/broadcasts/pause.png")

local fileLocation = "broadcasts/songdata.txt"

for k,v in ipairs(nets) do
	util.AddNetworkString(v)
end
-- Initializes default broadcast data that is stored on the player
function _P:BroadcastsPrepareData()
	self.broadcastData = {
		speakingTo = 0,
		listeningTo = 0,
	}
end

function BROADCASTS.LoadSongLengths()
	if not file.Exists(fileLocation, "DATA") then return end

	local songLengths = util.JSONToTable(file.Read(fileLocation))
	for k,v in pairs(BROADCASTS.Config.SongList) do
		if not v.length and songLengths[v.file] then
			v.length = songLengths[v.file]
		end
	end
end

hook.Add("InitPostEntity", "Broadcasts_LoadSongData", function()
	BROADCASTS.LoadSongLengths()
end)

hook.Add("PlayerSpawn", "PreparePlayerBroadcastData", _P.BroadcastsPrepareData)

local nextCheck = CurTime()
hook.Add("Think", "HandleBroadcastSpeakers", function()
	local broadcasts = BROADCASTS.GetBroadcastEnts()
	if nextCheck < CurTime() then
		--Loops over CACHED broadcast entities
		for id, ent in pairs(broadcasts) do
			--Ensure the entity still exists, if it somehow didn't get removed already.
			if not IsValid(ent) then broadcasts[id] = nil continue end
			local plys = player.GetAll()
			for i = 1, #plys do
				local ply = plys[i]
				--Add/Remove if they are within dist.
				local isLive = not ent.songData or ent.songData and ent.songData.paused
				if isLive and ply:GetPos():DistToSqr(ent:GetPos()) < BROADCASTS.Config.BroadcastDistance then
					BROADCASTS.AddBroadcaster(ply, ent.broadcastID)
				else
					BROADCASTS.RemoveBroadcaster(ply, ent.broadcastID)
				end
			end
		end
		--Update next check time, which will determine when this check is performed again.
		nextCheck = CurTime() + BROADCASTS.Config.CacheRefreshTime
	end
end)

hook.Add("PlayerCanHearPlayersVoice", "HandleBroadcastingTransmission", function(listener, speaker)
	--print( bit.band(listener.broadcastData.listeningTo, speaker.broadcastData.speakingTo))
	--print(math.IntToBin(speaker.broadcastData.speakingTo), math.IntToBin(listener.broadcastData.listeningTo), bit.band(listener.broadcastData.listeningTo, speaker.broadcastData.speakingTo))
	if bit.band(listener.broadcastData.listeningTo, speaker.broadcastData.speakingTo) > 0 then
	--if listener != speaker and bit.band(listener.broadcastData.listeningTo, speaker.broadcastData.speakingTo) > 0 then
		hook.Run("OnBroadcastHear", speaker, listener) -- Add support for hooking onto when a player speaks into a broadcast.
		return true
	end
end)

hook.Add("OnBroadcastHear", "BroadcastHearExample", function(speaker, listener)
	// listener:ChatPrint("You're listening to " .. speaker:Name())
end)

hook.Add("OnBroadcastEndHear", "BroadcastEndHearExample", function(listener, broadcastID)
	--listener:ChatPrint("You stopped listening to broadcast " .. broadcastID )
end)

function BROADCASTS.GetListeningPlayers(broadcastID)
	local listeningPlayers = {}
	local shifted = bit.lshift(1, broadcastID - 1)

	for i, ply in ipairs(player.GetAll()) do
		if bit.band(ply.broadcastData.listeningTo, shifted) > 0 then
			table.insert(listeningPlayers, ply)
		end
	end

	return listeningPlayers
end

function BROADCASTS.GetSongRemainingTime(broadcastEnt)
	local identifier = broadcastEnt:EntIndex() .. "clearSongData"
	if not timer.Exists(identifier) or not broadcastEnt.songData then return 0 end

	return timer.TimeLeft(identifier)
end

function BROADCASTS.PlaySong(broadcastEnt, songKey)
	if not IsValid(broadcastEnt) or not broadcastEnt.broadcastID then return end

	local songListData = BROADCASTS.Config.SongList[songKey]
	if not songListData then return end

	if not songListData.length then
		BROADCASTS.MsgC("THE REQUESTED SONG: " .. songListData.title .. " " .. songListData.file .. " HAS NO SONG LENGTH! HAVE A SUPER ADMIN CONNECT WITH THE DOWNLOADED SONGS FOR IT TO WORK CORRECTLY.", true)
		return
	end
	broadcastEnt.songData = {
		songKey = songKey,
		paused = false,
	}
	timer.Create(broadcastEnt:EntIndex() .. "clearSongData", songListData.length, 1, function()
		if not IsValid(broadcastEnt) then return end
		broadcastEnt.songData = nil
	end)
	net.Start("broadcasts_playSong")
	net.WriteUInt(songKey, 8)
	net.WriteUInt(broadcastEnt.broadcastID, 32)
	net.Send(BROADCASTS.GetListeningPlayers(broadcastEnt.broadcastID))
end

function BROADCASTS.JoinSong(broadcastEnt, ply)
	if IsValid(broadcastEnt) then
		local timeLeft = BROADCASTS.GetSongRemainingTime(broadcastEnt)
		if timeLeft <= 0 then return end

		local songData = broadcastEnt.songData
		local songListData = BROADCASTS.Config.SongList[songData.songKey]
		if not songListData then return end

		net.Start("broadcasts_joinSong")
		net.WriteUInt(songData.songKey, 8)
		net.WriteUInt(broadcastEnt.broadcastID, 32)
		net.WriteUInt(songListData.length - timeLeft, 12)
		net.WriteBool(songData.paused)
		net.Send(ply)
	end
end

function BROADCASTS.QuitSong(broadcastEnt, ply)
	if IsValid(broadcastEnt) then
		net.Start("broadcasts_quitSong")
		net.WriteUInt(broadcastEnt.broadcastID, 32)
		net.Send(ply)
	end
end

function _P:BroadcastHear(broadcastID, canHear)
    local val = self.broadcastData.listeningTo
    --print("PREV LISTEN:", math.IntToBin(val))
    local shifted = bit.lshift(1, broadcastID - 1)
    local broadcastEnt = BROADCASTS.GetBroadcastEnt(broadcastID)
    local isListening = bit.band(self.broadcastData.listeningTo, shifted) > 0
    if canHear and not isListening then
				self:falloutNotify("☊ You've tuned into a public broadcast", "buttons/button9.wav")
        --Shifting over one since we're not starting at index 0.
        BROADCASTS.JoinSong(broadcastEnt, self)
        self.broadcastData.listeningTo = bit.bor(val, shifted)
        self:SetNWInt("broadcastListeningTo", self.broadcastData.listeningTo)
    elseif not canHear and isListening then
				self:falloutNotify("☊ You've tuned out of a public broadcast", "buttons/combine_button7.wav")
        self.broadcastData.listeningTo = bit.bxor(val, shifted)
        BROADCASTS.QuitSong(broadcastEnt, self)
        hook.Run("OnBroadcastEndHear", self, broadcastID)
        self:SetNWInt("broadcastListeningTo", self.broadcastData.listeningTo)
    end
    --print("AFTER LISTEN:", math.IntToBin(self.broadcastData.listeningTo))
end

net.Receive("broadcasts_playSong", function(len, ply)
	local songKey = net.ReadUInt(8)
	local broadcastEnt = net.ReadEntity()
	BROADCASTS.PlaySong(broadcastEnt, songKey)
end)

net.Receive("broadcasts_toggleSong", function(len,ply)
	local broadcastEnt = net.ReadEntity()
	if not IsValid(broadcastEnt) or not broadcastEnt.broadcastID or not broadcastEnt.songData then return end

	local songListData = BROADCASTS.Config.SongList[broadcastEnt.songData.songKey]
	if not songListData then return end

	local shouldPause = not broadcastEnt.songData.paused
	broadcastEnt.songData.paused = shouldPause

	local identifier = broadcastEnt:EntIndex() .. "clearSongData"
	if shouldPause then
		timer.Pause(identifier)
	else
		timer.Start(identifier)
	end

	net.Start("broadcasts_toggleSong")
	net.WriteUInt(broadcastEnt.broadcastID, 32)
	net.WriteBool(broadcastEnt.songData.paused)
	net.Send(BROADCASTS.GetListeningPlayers(broadcastEnt.broadcastID))
end)


net.Receive("broadcasts_getSongLengths", function(len, ply)
	if not ply:IsSuperAdmin() then return end
	local songsReady = true
	for k,v in pairs(BROADCASTS.Config.SongList) do
		if not v.length then
			songsReady = false
			break
		end
	end
	if songsReady then return end
	local data = net.ReadTable()
	if not file.Exists("broadcasts", "DATA") then
		file.CreateDir("broadcasts")
	end
	file.Write(fileLocation, util.TableToJSON(data, true))
	BROADCASTS.LoadSongLengths()
end)

net.Receive("broadcasts_forceJoin", function(len, ply)
	local broadcastEnt = net.ReadEntity()
	if not IsValid(broadcastEnt) or not broadcastEnt.broadcastID then return end

	if ply:IsListeningToBroadcast(broadcastEnt.broadcastID) then
		ply.broadcastData.notForced = true
		return
	end
	// ply:ChatPrint(broadcastEnt.broadcastID)
	ply:BroadcastHear(broadcastEnt.broadcastID, true)
	ply.broadcastData.notForced = false
end)

net.Receive("broadcasts_joinByID", function(len, ply)
	local id = net.ReadUInt(32)

	ply:BroadcastHear(id, true)
end)

net.Receive("broadcasts_forceQuit", function(len, ply)
	local broadcastEnt = net.ReadEntity()
	if ply.broadcastData.notForced then return end

	if not IsValid(broadcastEnt) or not broadcastEnt.broadcastID then return end
	ply:BroadcastHear(broadcastEnt.broadcastID, false)
	ply.broadcastData.notForced = true
end)

net.Receive("broadcasts_quitByID", function(len, ply)
	local id = net.ReadUInt(32)

	ply:BroadcastHear(id, false)
end)

function BROADCASTS.Create(data)
	local broadcast = ents.Create("broadcaster")
	broadcast:SetPos(data.pos)
	broadcast:SetAngles(data.angles)
	broadcast:Spawn()

	broadcast:GetPhysicsObject():EnableMotion(false)

	BROADCASTS.RegisterBroadcast(broadcast, data.id)
	print("[BROADCAST] Created/loaded broadcaster entity . . .")
end

function BROADCASTS.Load()
	BROADCASTS.BroadcastSaves = util.JSONToTable(file.Read("broadcasts/broadcasts.json") or "[]")

	for k, v in pairs(BROADCASTS.BroadcastSaves) do
		BROADCASTS.Create(v)
	end
end

function BROADCASTS.Save()
	BROADCASTS.BroadcastSaves = {}

	for k, v in pairs(ents.FindByClass("broadcaster")) do
		table.insert(BROADCASTS.BroadcastSaves,
			{ ["id"] = v.broadcastID or 1,
				["pos"] = v:GetPos() + Vector(0,0,35),
				["angles"] = v:GetAngles()
			}
		)
	end

	file.Write("broadcasts/broadcasts.json", util.TableToJSON(BROADCASTS.BroadcastSaves))
end

hook.Add("InitPostEntity", "BroadcastersLoad", function()
	timer.Simple(1, function()
		BROADCASTS.Load()
	end)
end)

hook.Add("PostCleanupMap", "BroadcastersLoad", function()
	timer.Simple(1, function()
		BROADCASTS.Load()
	end)
end)
