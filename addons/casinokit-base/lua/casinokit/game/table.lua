local Table = CasinoKit.class("Table")

-- TODO fix includeMixin
function Table:on(name, fn)
	self.__eventhooks = self.__eventhooks or {}
	self.__eventhooks[name] = self.__eventhooks[name] or {}
	table.insert(self.__eventhooks[name], fn)
end
function Table:emit(name, ...)
	local hooks = self.__eventhooks and self.__eventhooks[name]
	if hooks then
		for _,hook in pairs(hooks) do
			hook(...)
		end
	end
end

Table:prop("slots") { type = "number" }
Table:prop("game") { type = CasinoKit.classes.Game }

function Table:initialize(slots)
	Table.super.initialize(self)

	self.players = {}
	self:setSlots(slots)
end

function Table:getPlayerCount()
	return table.Count(self.players)
end

function Table:getValidPlayerStream()
	return CasinoKit.fn.stream(self.players):filter(function(x) return x:isValid() end)
end
function Table:getValidPlayerCount()
	return self:getValidPlayerStream():size()
end
function Table:getValidPlayers()
	return self:getValidPlayerStream():collect()
end

function Table:getPlayerAtSlot(slot)
	return self.players[slot]
end
function Table:isFreeSlot(slot)
	return self:getPlayerAtSlot(slot) == nil
end

function Table:getFreeSlot()
	for i=1, self:getSlots() do
		if self:isFreeSlot(i) then
			return i
		end
	end
end

function Table:getPlayerSlot(p)
	for i=1, self:getSlots() do
		if self.players[i] == p then
			return i
		end
	end
end

function Table:addPlayer(ply, slot)
	slot = slot or self:getFreeSlot()

	if not slot or not (slot >= 1 and slot <= self:getSlots()) then
		return false, "#invalidslot"
	end

	if not self:isFreeSlot(slot) then
		return false, "#invalidslot"
	end

	if self:getPlayerSlot(ply) then
		return false, "#alreadyintable"
	end

	self.players[slot] = ply
	ply:setSeatIndex(slot)
	return true
end

function Table:removePlayerAtSlot(slot)
	local p = self.players[slot]
	if not not p then
		self.players[slot] = nil
		self:emit("playerRemoved", p, slot)
	end
end

--[[ This is a bad function because a player can have multiple seats in a table.
function Table:removePlayer(ply)
	local slot = self:getPlayerSlot(ply)
	if not slot then return end
	self:removePlayerAtSlot(slot)
end]]

function Table:clearInvalidPlayers()
	for i=1, self:getSlots() do
		local ply = self.players[i]
		if ply and not ply:isValid() then
			self:removePlayerAtSlot(i)
		end
	end
end

function Table:createGame(gameClass, tableEnt)
	local game = gameClass(self, tableEnt)
	return game
end
