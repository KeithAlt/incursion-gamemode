--[[--------------------------------------------------------------------------------------------------
HookProtect by jonjo/yobson

Detours hook.Add to instead place the functions in our own table and then have only one function
actually subscribed to the hook which will then call all of the other subsequent functions
but check for return values when we don't want them and catch errors.

Intended to ensure that all functions subscribed to an event get a chance to run.
----------------------------------------------------------------------------------------------------]]

HookProtect = HookProtect or {}
HookProtect.Functions = HookProtect.Functions or {}
HookProtect.OriginalHookAdd = HookProtect.OriginalHookAdd or hook.Add
HookProtect.OriginalHookRemove = HookProtect.OriginalHookRemove or hook.Remove
HookProtect.Print = jlib.GetPrintFunction("[HookProtect]", Color(0, 255, 255))

HookProtect.ProtectedHooks = HookProtect.ProtectedHooks or {}

HookProtect.HooksToProtect = {
	["InitPostEntity"] = {shouldReturn = false}
}

HookProtect.ID = "HookProtect"

function HookProtect.CacheExisting(event)
	local hookTbl = hook.GetTable()

	HookProtect.Functions[event] = HookProtect.Functions[event] or {}

	-- Get any functions that have already been added to the hook, in-case our addon was loaded
	-- after some others that may have been using one of our protected hooks.
	local existingHookFuncs = hookTbl[event] or {}
	for id, func in pairs(existingHookFuncs) do
		if id != HookProtect.ID then
			HookProtect.Print("Caching " .. id .. " from " .. event)

			HookProtect.Functions[event][id] = func -- Cache them in our own table
			hook.Remove(event, id) -- Remove them from the hook
		end
	end
end

function HookProtect.CacheFuture(event)
	HookProtect.ProtectedHooks[event] = true
end

function HookProtect.Detour(event, func)
	HookProtect.OriginalHookAdd(event, HookProtect.ID, func)
end

function HookProtect.RunHook(event, ...)
	for id, func in pairs(HookProtect.Functions[event] or {}) do
		local result = func(...)

		if result != nil then
			return result
		end
	end
end

function HookProtect.ProtectEvent(event, dat)
	HookProtect.Print("Initializing protection for " .. event)

	HookProtect.CacheExisting(event)
	HookProtect.CacheFuture(event)

	-- Add our own function to our protected events
	-- this will call the other functions subscribing to this event
	-- in a safe manner
	HookProtect.Detour(event, function(...)
		HookProtect.Print(event .. " called")

		for id, func in pairs(HookProtect.Functions[event] or {}) do
			local returns = {pcall(func, ...)}

			if returns[1] == false then
				HookProtect.Print("Caught error in " .. event .. " from " .. id .. ":\n", Color(255, 0, 0), returns[2])
				continue
			end

			if #returns > 1 then
				if dat.shouldReturn then
					table.remove(returns, 1)
					return unpack(returns)
				else
					local info = debug.getinfo(func, "S")
					HookProtect.Print("Stopped " .. event .. " from being stopped early because of " .. id .. " returning a value ", Color(255, 0, 0), info.short_src .. "@" .. info.linedefined .. "-" .. info.lastlinedefined)
				end
			end
		end
	end)
end

function HookProtect.Initialize()
	for event, dat in pairs(HookProtect.HooksToProtect) do
		HookProtect.ProtectEvent(event, dat)
	end
end
HookProtect.Initialize()

function hook.Add(event, id, func)
	if HookProtect.ProtectedHooks[event] and id != HookProtect.ID then
		HookProtect.Functions[event][id] = func
		HookProtect.Print("Stopped " .. id .. " from being added to " .. event)
	elseif (func and isfunction(func)) then
		HookProtect.OriginalHookAdd(event, id, func)
	end
end

function hook.Remove(event, id)
	if id == "HookProtect" then
		HookProtect.Print("Stopped hook protect from being removed from " .. event)
		return
	end

	if HookProtect.ProtectedHooks[event] and HookProtect.Functions[event] then
		HookProtect.Functions[event][id] = nil
		HookProtect.Print("Removed " .. id .. " from " .. event)
	elseif id then
		HookProtect.OriginalHookRemove(event, id)
	end
end

hook.Run("HookProtect")
