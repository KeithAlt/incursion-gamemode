local db = CasinoKit.metso.get("casinokit")

db:query([[
	CREATE TABLE IF NOT EXISTS ckit_chips (
		sid64 BIGINT,
		type VARCHAR(16),
		amount INT,

		PRIMARY KEY (sid64, type)
	);
]]):next(nil, function(e)
	ErrorNoHalt("[CasinoKit] Failed to create economy table: " .. tostring(e))
end)

function CasinoKit.setChipsS32(steamid32, amount, callback)
	assert(type(amount) == "number")

	local s64 = util.SteamIDTo64(steamid32)
	db:query("REPLACE INTO ckit_chips (sid64, type, amount) VALUES (CAST(? AS BIGINT), ?, ?)", {s64, "", amount}):done(callback)
end
function CasinoKit.getChipsS32(steamid32, callback)
	local s64 = util.SteamIDTo64(steamid32)
	db:query("SELECT amount FROM ckit_chips WHERE sid64 = CAST(? AS BIGINT) AND type = ?", {s64, ""}):done(function(rows)
		local amount = rows[1] and rows[1].amount
		if amount then callback(tonumber(amount)) end
	end)
end
function CasinoKit.addChipsS32(steamid32, amount, callback)
	assert(type(amount) == "number")

	local s64 = util.SteamIDTo64(steamid32)
	db:query([[
		REPLACE INTO ckit_chips (sid64, type, amount)
		VALUES (CAST(? AS BIGINT), ?, COALESCE((SELECT amount FROM ckit_chips WHERE sid64 = CAST(? AS BIGINT) AND type = ?), 0) + ?)
	]], {s64, "", s64, "", amount}):done(callback)
end
function CasinoKit.resetAllChipsUnSafe()
	db:query("DELETE FROM ckit_chips")
end

hook.Add("PlayerInitialSpawn", "CKit_OldChipFormatConverter", function(ply)
	local oldChips = tonumber(ply:GetPData("CK_Chips", 0))
	if not oldChips or oldChips <= 0 then return end

	ply:ChatPrint("You have " .. oldChips .. " old casinokit chips. Starting conversion to new format.")
	print("[CasinoKit] Converting chips to new format for " .. ply:Nick() .. "(" .. oldChips .. " chips)")

	local sid = ply:SteamID()
	CasinoKit.addChipsS32(sid, oldChips, function()
		util.RemovePData(sid, "CK_Chips")
		ply:ChatPrint("Conversion complete.")
		ply:CKit_UpdateChipCount()
	end)
end)