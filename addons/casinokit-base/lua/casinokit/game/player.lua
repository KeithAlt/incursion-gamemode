local Player = CasinoKit.class("Player")

Player:prop("gmodPlayer")
Player:prop("seatIndex") { type = "number" }
Player:prop("game") { type = CasinoKit.classes.Game }

function Player:initialize(gmodRef)
	Player.super.initialize(self)

	self:setGmodPlayer(gmodRef)
end

function Player:mapGmodPlayer(fn)
	local p = self:getGmodPlayer()
	return IsValid(p) and fn(p) or nil
end

function Player:getChipCount()
	return self:mapGmodPlayer(function(ply)
		return ply:CKit_GetChips()
	end) or 0
end
function Player:canAffordChips(n)
	return self:mapGmodPlayer(function(ply)
		return ply:CKit_CanAffordChips(n)
	end) or false
end
function Player:addChips(n, reason)
	self:mapGmodPlayer(function(ply)
		return ply:CKit_AddChips(n, reason)
	end)
end

function Player:chatPrint(msg)
	self:mapGmodPlayer(function(ply)
		ply:ChatPrint(tostring(msg))
	end)
end
function Player:chatPrintL(msg, params)
	self:mapGmodPlayer(function(ply)
		ply:CKit_PrintL(msg, params)
	end)
end
function Player:chatPrintML(msg, params)
	self:mapGmodPlayer(function(ply)
		ply:CKit_PrintML(msg, params)
	end)
end

function Player:isValid()
	return IsValid(self:getGmodPlayer())
end

function Player:sendMessage(id, buf)
	self:mapGmodPlayer(function(ply)
		self:getGame():sendMessageTo({ply}, id, buf)
	end)
end

function Player:toShortString()
	local gpString = self:mapGmodPlayer(function(p) return p:Nick() end) or "-invalid-"
	return string.format("%s (#%d)", gpString, self:getSeatIndex() or -1)
end

function Player:__tostring()
	return string.format("%s(gmod: %s seat: %d)", self.class.name, tostring(self:getGmodPlayer()), self:getSeatIndex() or -1)
end
