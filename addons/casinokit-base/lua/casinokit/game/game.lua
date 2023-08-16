local Game = CasinoKit.class("Game")

Game:prop("table")
Game:prop("tableEntity") { type = "Entity" }
Game:prop("state")

local cvar_debuglevel = CreateConVar("casinokit_debuglevel", "0", FCVAR_ARCHIVE)

function Game:initialize(table, tableEnt)
	Game.super.initialize(self)
	self:setTable(table)
	self:setTableEntity(tableEnt)

	self.log = {
		i = function(...)
			MsgN("[CasinoKit-Info] ", ...)
		end,
		v = function(...)
			if cvar_debuglevel:GetInt() >= 1 then
				MsgN("[CasinoKit-Verbose] ", ...)
			end
		end,
		w = function(...)
			MsgN("[CasinoKit-Warning] ", ...)
		end
	}

	self.globalState = {}
	self:changeToState(self.initialState)
end

function Game:getPlayers()
	return self.globalState.players or {}
end

function Game:getClClass()
	return self.class.name .. "Cl"
end

Game.states = {}
Game.initialState = "unsetInitialState"

function Game:changeToState(stateId, ...)
	if self._cleanedUp then
		error("attempted to change state after cleanup!!")
	end
	local oldState = self:getState()
	if oldState then
		oldState:doLeave()
	end

	self.log.v("Changing state to ", stateId)

	local state = self.states[stateId](self.globalState)
	state.game = self
	state.table = self:getTable()
	state.log = self.log

	state:on("stateChangeRequest", function(newState, args)
		self:changeToState(newState, unpack(args))
	end)
	state:on("stateRestartRequest", function(args)
		self:changeToState(stateId, unpack(args))
	end)
	state:on("broadcastMessage", function(id, buf)
		self:broadcastMessage(id, buf)
	end)

	state:doEnter(...)
	self:setState(state)

	local out = CasinoKit.classes.OutBuffer()
	out:putString(stateId)
	self:broadcastMessage("state", out)
end

function Game:cleanup()
	self:getState():doLeave()
	self._cleanedUp = true
end

function Game:getPlayerByEnt(ent)
	for _,p in pairs(self:getPlayers()) do
		if p:getGmodPlayer() == ent then return p end
	end
end
function Game:getPlayersByEnt(ent)
	local t = {}
	for _,p in pairs(self:getPlayers()) do
		if p:getGmodPlayer() == ent then
			table.insert(t, p)
		end
	end
	return t
end

function Game:getPlayerInSeat(seatIdx)
	for _,p in pairs(self:getPlayers()) do
		if p:getSeatIndex() == seatIdx then return p end
	end
end

function Game:kickPlayer(ply)
	local out = CasinoKit.classes.OutBuffer()
	out:put(ply:getSeatIndex())
	self:broadcastMessage("pkick", out)

	table.RemoveByValue(self:getPlayers(), ply)
end

local function internalCreateMessage(tableEnt, id, buf)
	assert(#id == 5, "message identifier must be five bytes, is " .. (#id))

	net.Start("casinokit_gamemsg")
	net.WriteEntity(tableEnt)
	net.WriteData(id, 5)

	local data = buf:build()
	net.WriteUInt(#data, 16)
	net.WriteData(data, #data)
end

util.AddNetworkString("casinokit_gamemsg")
function Game:broadcastMessage(id, buf)
	local tableEnt = self:getTableEntity()

	internalCreateMessage(tableEnt, id, buf)
	net.SendPVS(tableEnt:GetPos())
end
function Game:sendMessageTo(targets, id, buf)
	internalCreateMessage(self:getTableEntity(), id, buf)
	net.Send(targets)
end

function Game:emitGEvent(id, args)
	for _,e in pairs(self._glisteners or {}) do
		e(id, args)
	end
end
function Game:addGEventListener(listener)
	self._glisteners = self._glisteners or {}
	table.insert(self._glisteners, listener)
end

-- Broadcasts a gameplay related string message (eg. 'Player x bet $10')
-- Clientside game should display this clearly.
function Game:broadcastGameplayMessage(msg)
	local out = CasinoKit.classes.OutBuffer()
	out:putString(tostring(msg))
	self:broadcastMessage("gpmsg", out)
end
function Game:broadcastGameplayMessageL(msg, params)
	local out = CasinoKit.classes.OutBuffer()
	out:putString(tostring(msg))
	out:put(table.Count(params))
	for k,v in pairs(params) do
		out:putString(k)
		out:putString(tostring(v))
	end
	self:broadcastMessage("glmsg", out)
end

function Game:onPlayerInput(ply, buffer)
	self:getState():onUserInput(ply, buffer)
end

-- Return whether given gmod player can sit in seat index
-- This is called after normal seat-occupation checks so it should mostly
-- be used for eg. verifying that the player can afford ante.
function Game:canGmodPlayerSitIn(gmodPly, seatIndex)
	return true
end

-- Table settings (eg. ante or timeout delay) that should persist should be written into out table
-- Default restore impl. calls OnGameConfigReceived in table entity for each key-value pair in persist table
function Game:persistTableSettings(out)
end

function Game:restoreTableSettings(tbl)
	local tableEnt = self:getTableEntity()
	for k,v in pairs(tbl) do
		tableEnt:OnGameConfigReceived(k, v)
	end
end

function Game.static.getGamePlayer(player)
	return player
end
