local function allow(ply)
	return ply:IsSuperAdmin()
end

local _cached
local function getRawConfig()
	if not _cached then
		_cached = util.JSONToTable(file.Read("ckit_config.txt", "DATA") or "{}")
	end
	return _cached
end
local function setRawConfig(t)
	_cached = t
	file.Write("ckit_config.txt", util.TableToJSON(t))
end

util.AddNetworkString("casinokit_admin")
concommand.Add("casinokit_admin", function(p)
	if allow(p) then
		net.Start("casinokit_admin")
		net.WriteTable(getRawConfig())
		net.Send(p)
	end
end)

net.Receive("casinokit_admin", function(len, cl)
	if allow(cl) then
		setRawConfig(net.ReadTable())
	end
end)

function CasinoKit.getConfigString(key)
	return getRawConfig()[key]
end
function CasinoKit.getConfigNumber(key)
	return tonumber(getRawConfig()[key])
end
function CasinoKit.getConfigSet(key)
	local str = CasinoKit.getConfigString(key)
	if not str then return end

	local s = {}
	for _,i in pairs(str:Split(",")) do
		s[i] = true
	end
	return s
end
function CasinoKit.configSetContains(key, value)
	local set = CasinoKit.getConfigSet(key)
	return set and set[value]
end