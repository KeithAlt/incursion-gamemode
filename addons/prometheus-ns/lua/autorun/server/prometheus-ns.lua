PrometheusNS = {}
PrometheusNS.Packages = {
    ["bronze"] = {
		["money"] = 5000,
		["factions"] = {
			"feral"
		},
        ["flags"] = "pet"
	},
	["silver"] = {
		["money"] = 12500,
		["factions"] = {
			"feral",
			"supermutant"
		},
        ["flags"] = "pet"
	},
	["gold"] = {
		["money"] = 17500,
		["factions"] = {
			"feral",
			"supermutant",
			"monster",
			"robot",
			"creature"
		},
        ["flags"] = "pet"
	},
	["diamond"] = {
		["money"] = 25000,
		["factions"] = {
			"feral",
			"supermutant",
			"monster",
			"robot",
			"creature",
			"sentry",
			"firegeckos",
			"enclave",
			"bos",
			"legion",
			"ncr"
		},
        ["flags"] = "pet"
	},
	["legendary"] = {
		["money"] = 50000,
		["factions"] = {
			"feral",
			"supermutant",
			"monster",
			"robot",
			"creature",
			"sentry",
			"firegeckos",
			"enclave",
			"bos",
			"legion",
			"ncr"
		},
        ["flags"] = "pet"
	}
}

function PrometheusNS.GetWhitelistIDs(name)
    local package = PrometheusNS.Packages[name]
    local whiteListIDs = {}

    if package.factions then
        for _, factionID in ipairs(package.factions) do
            local faction = nut.faction.teams[factionID]

            if !faction then
                ServerLog("Attempt to get ID for faction " .. factionID .. " failed as it could not be found. " .. "\n")
                continue
            end

            whiteListIDs[#whiteListIDs + 1] = faction.index
        end
    end

    return whiteListIDs
end

local function ClaimPackage(name, char, ply)
    local package = PrometheusNS.Packages[name]
    local whiteListIDs = PrometheusNS.GetWhitelistIDs(name)

    for _, id in ipairs(whiteListIDs) do
        ply:setWhitelisted(id, true)
    end

    if package.money then
        char:giveMoney(package.money)
    end

    if package.flags then
        char:giveFlags(package.flags)
    end

    ServerLog(ply:Nick() .. " claimed Prometheus package " .. name .. "\n")
    ply:notify("Successfully claimed rewards.")
end

function PrometheusNS.ClaimPackage(name, ply) --Used to claim one of the pre-defined packages
    ServerLog(ply:Nick() .. " claiming Prometheus package " .. name .. "\n")

    if ply:getChar() then
        ClaimPackage(name, ply:getChar(), ply)
    else
        timer.Simple(5, function()
            Prometheus.Notify(ply, 1, false, {text = "NOTICE: The next character you load will be given your donation rewards! Please choose the correct one."})
        end)

		local sid = ply:SteamID64()
        local hookID = "PrometheusNS" .. sid .. name
        hook.Add("PlayerLoadedChar", hookID, function(loader, char, lastChar)
            if loader:SteamID64() == sid then
                hook.Remove("PlayerLoadedChar", hookID)
                ClaimPackage(name, char, ply)
            end
        end)
    end
end

local function UpgradePackage(from, to, char, ply)
    local whiteListIDs = PrometheusNS.GetWhitelistIDs(to)

    for _, id in ipairs(whiteListIDs) do
        ply:setWhitelisted(id, true)
    end

    local fromMoney = PrometheusNS.Packages[from].money
    local toMoney = PrometheusNS.Packages[to].money
    if fromMoney and toMoney then --Give them the difference
        char:giveMoney(toMoney - fromMoney)
    elseif toMoney then --Just give them the full amount
        char:giveMoney(toMoney)
    end

    ServerLog(ply:Nick() .. " upgraded Prometheus package from " .. from .. " to " .. to  .. "\n")
    ply:notify("Successfully claimed rewards.")
end

function PrometheusNS.UpgradePackage(from, to, ply) --Used when a user upgrades from one package to another
    ServerLog(ply:Nick() .. " upgrading Prometheus package from " .. from .. " to " .. to  .. "\n")

    if ply:getChar() then
        UpgradePackage(from, to, ply:getChar(), ply)
    else
        timer.Simple(5, function()
            Prometheus.Notify(ply, 1, false, {text = "NOTICE: The next character you load will be given your donation rewards! Please choose the correct one."})
        end)

		local sid = ply:SteamID64()
        local hookID = "PrometheusNS" .. sid .. to
        hook.Add("PlayerLoadedChar", hookID, function(loader, char, lastChar)
            if loader:SteamID64() == sid then
                hook.Remove("PlayerLoadedChar", hookID)
                UpgradePackage(from, to, char, ply)
            end
        end)
    end
end

local function ClaimMoney(amt, char, ply)
    char:giveMoney(amt)

    ServerLog(ply:Nick() .. " claimed " .. amt .. " money from Prometheus package"  .. "\n")
    ply:notify("Successfully claimed rewards.")
end

function PrometheusNS.ClaimMoney(amt, ply) --Used to claim any amount of money
    ServerLog(ply:Nick() .. " claiming " .. amt .. " money from Prometheus package"  .. "\n")

    if ply:getChar() then
        ClaimMoney(amt, ply:getChar(), ply)
    else
        timer.Simple(5, function()
            Prometheus.Notify(ply, 1, false, {text = "NOTICE: The next character you load will be given your donation rewards! Please choose the correct one."})
        end)

		local sid = ply:SteamID64()
        local hookID = "PrometheusNS" .. sid .. tostring(amt)
        hook.Add("PlayerLoadedChar", hookID, function(loader, char, lastChar)
            if loader:SteamID64() == sid then
                hook.Remove("PlayerLoadedChar", hookID)
                ClaimMoney(amt, char, ply)
            end
        end)
    end
end

hook.Add("PlayerLoadedChar", "PrometheusNSFlags", function(ply, char, lastChar) --Flags should be given to all characters of a donor
    local package = PrometheusNS.Packages[ply:GetUserGroup()]
    if package and package.flags and !char:hasFlags(package.flags) then
        char:giveFlags(package.flags)
    end
end)
