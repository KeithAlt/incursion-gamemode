/*An efficient means of detecting if a player is speaking into a broadcaster entity
A toggle function will be needed to specify if a player can hear the broadcaster or not*/
BROADCASTS.Broadcasts = BROADCASTS.Broadcasts or {}
BROADCASTS.BroadcastListeners = BROADCASTS.BroadcastListeners or {}

 -- Call inside of ENT:Initialize to add an additional broadcast entity.
function BROADCASTS.RegisterBroadcast(ent, id)
	if !id then
 		id = #BROADCASTS.Broadcasts + 1
	end

	BROADCASTS.Broadcasts[id] = ent
	ent.broadcastID = id -- Reference/index by this id.

	if CLIENT then
		BROADCASTS.Data[id] = {}
	end
end

--Call inside of ENT:Initialize to add an additional broadcast listener ent.
function BROADCASTS.RegisterBroadcastListener(ent, id)
    local id = id or table.Count(BROADCASTS.BroadcastListeners) + 1
    BROADCASTS.BroadcastListeners[id] = ent
    ent.broadcastListenID = id -- Reference/index by this id.
end

--Returns a cached table of all the broadcasting entities. ( Not players )
function BROADCASTS.GetBroadcastEnts()
	return BROADCASTS.Broadcasts
end

function BROADCASTS.GetBroadcastEnt(broadcastID)
	return BROADCASTS.GetBroadcastEnts()[broadcastID]
end

--Call this method to add a PLAYER as a broadcaster tied to the specified broadcastID.
function BROADCASTS.AddBroadcaster(ply, broadcastID)
	local oldSpeakingTo = ply.broadcastData.speakingTo
	ply.broadcastData.speakingTo = bit.lshift(1, broadcastID - 1)-- Shift to the left by 1 bit to get a bit mask.
	if SERVER and oldSpeakingTo != ply.broadcastData.speakingTo then
		ply:SetNWInt("broadcastSpeakingTo", ply.broadcastData.speakingTo)
	end
	--print(ply:Name() .. " speaking to " .. math.IntToBin(ply.broadcastData.speakingTo))
end

--Call this method to remove a PLAYER as a broadcaster tied to the specified broadcastID.
function BROADCASTS.RemoveBroadcaster(ply, broadcastID)
	--print(ply:Name() .. " speaking BEFORE to " .. math.IntToBin(ply.broadcastData.speakingTo))
	local shifted = bit.lshift(1, broadcastID - 1)
	if bit.band(ply.broadcastData.speakingTo, shifted) > 0 then
		ply.broadcastData.speakingTo = bit.bxor(ply.broadcastData.speakingTo, shifted)
		if SERVER then
			ply:SetNWInt("broadcastSpeakingTo", ply.broadcastData.speakingTo)
		end
	end
   -- print(ply:Name() .. " speaking AFTER to " .. math.IntToBin(ply.broadcastData.speakingTo))
end

 -- Call inside of ENT:OnRemove to ensure broadcast entity is properly uncached.
function BROADCASTS.OnBroadcastRemoved(ent)
	if !ent or !ent.broadcastID then return end

	BROADCASTS.Broadcasts[ent.broadcastID] = nil

	if SERVER then
		for k, ply in pairs(player.GetAll()) do
			ply:BroadcastHear(ent.broadcastID, false)
			BROADCASTS.RemoveBroadcaster(ply, ent.broadcastID)
		end
	end

	if CLIENT then
		local data = BROADCASTS.Data[ent.broadcastID]
		if data and data.songData and IsValid(data.songData.station) then
			data.songData.station:Stop()
		end

		BROADCASTS.Data[ent.broadcastID] = nil
	end
end

function BROADCASTS.GetTheme()
	return BROADCASTS.Config.Theme
end


local _P = FindMetaTable("Player")
--METHODS NOW SHARED
function _P:IsListeningToBroadcast(broadcastID)
	local shifted = bit.lshift(1, broadcastID - 1)
	local listeningTo = self:GetNWInt("broadcastListeningTo") or self.broadcastData.listeningTo
	return self.broadcastData and bit.band(listeningTo, shifted) > 0
end

function _P:IsSpeakingToBroadcast(broadcastID)
	local shifted = bit.lshift(1, broadcastID - 1)
	local speakingTo = self:GetNWInt("broadcastSpeakingTo", self.broadcastData.speakingTo)
	return bit.band(speakingTo, shifted) > 0
end

-- Returns a random number seeded by the broadcast ID
function BROADCASTS.GetFrequency(id)
	return math.Round(util.SharedRandom("BroadcastFrequency", 80, 108, id), 1)
end

properties.Add("BROADCASTUpdate", {
    ["MenuLabel"] = "Save broadcasters",
    ["MenuIcon"] = "icon16/arrow_refresh.png",
    ["Order"] = 10001,
    ["Filter"] = function(self, ent)
        return ent:GetClass() == "broadcaster" and LocalPlayer():IsSuperAdmin()
    end,
    ["Action"] = function(self, ent, tr)
        self:MsgStart()
          net.WriteEntity(ent)
        self:MsgEnd()
    end,
    ["Receive"] = function(self, len, ply)
        if !ply:IsSuperAdmin() then return end
				jlib.RequestBool("Save/Update all broadcasters?", function(bool)
					if !bool then return end
					BROADCASTS.Save()
					jlib.Announce(ply, Color(255,0,0), "[NOTICE] ", Color(255,255,255), "Saved/Updated all broadcast entity positions")
				end, ply, "Yes", "No")
    end
})
