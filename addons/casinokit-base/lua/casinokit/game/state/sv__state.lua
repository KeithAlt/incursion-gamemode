local State = CasinoKit.class("State")

-- TODO fix includeMixin
function State:on(name, fn)
	self.__eventhooks = self.__eventhooks or {}
	self.__eventhooks[name] = self.__eventhooks[name] or {}
	table.insert(self.__eventhooks[name], fn)
end

function State:emit(name, ...)
	local hooks = self.__eventhooks and self.__eventhooks[name]
	if hooks then
		for _,hook in pairs(hooks) do
			hook(...)
		end
	end
end


function State:initialize(global)
	State.super.initialize(self)
	self.global = global
end

function State:isValid()
	return self._isValid
end

function State:changeState(newState, ...)
	self.log.v("State changing from cls ", self.class.name, " to ", newState)
	self:emit("stateChangeRequest", newState, {...})
end

function State:restartState(...)
	self.log.v("State requesting a restart")
	self:emit("stateRestartRequest", {...})
end

function State:broadcastMessage(id, buf)
	self:emit("broadcastMessage", id, buf)
end

function State:enter() end
function State:leave() end

function State:doEnter(...)
	self._isValid = true
	self:enter(...)
end
function State:doLeave()
	self:leave()
	self._isValid = false

	for _,timer in pairs(self._timers or {}) do
		timer:stop()
	end

	-- also clear the table to free old timer wrappers for gc
	self._timers = {}
end

function State:onUserInput(ply, buf)
	self.log.v("Received user input from ", ply)
end

function State:createSimpleTimer(time, fn)
	if not self:isValid() then return end

	self._timers = self._timers or {}
	local timer = CasinoKit.simpleTimer(time, fn)
	table.insert(self._timers, timer)
	return timer
end

local GameOverState = CasinoKit.class("GameOverState", "State")
function GameOverState:enter()
	self:createSimpleTimer(1, function() self:changeState("idle") end)
end
