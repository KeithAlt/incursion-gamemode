local CURRENCY = {}

-- dont archive on client
local fflags = SERVER and bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY) or FCVAR_REPLICATED

local cvar_nutscript_to = CreateConVar("casinokit_chiprate_nutscript_money2chips", "0.1", fflags, "how many tokens per nutscriptmoney player gets. This gets rounded down")
local cvar_nutscript_fee = CreateConVar("casinokit_chiprate_nutscript_exchangefee", "0.01", fflags, "the percentage taken from player when they exchange from chips to money")

CURRENCY.NiceName = "NutScript"
CURRENCY.UnitName = "#money"
CURRENCY.UnitPluralName = "#money"

function CURRENCY:isEnabled()
	return nut ~= nil
end

function CURRENCY:getExchangeRateFromCurrencyToChips(ply)
	return cvar_nutscript_to:GetFloat(), 0
end

function CURRENCY:getExchangeRateFromChipsToCurrency(ply)
	local feeFrac = cvar_nutscript_fee:GetFloat()
	local baseRate = (1 / cvar_nutscript_to:GetFloat())

	return baseRate * (1 - feeFrac), baseRate * feeFrac
end

function CURRENCY:addPlayerCurrency(ply, amount, desc)
	local char = ply:getChar()
	if char then
		if amount > 0 then
			char:giveMoney(amount)
		else
			char:takeMoney(-amount)
		end
		ply:PrintMessage(HUD_PRINTCONSOLE, "[CasinoKit] Modified money " .. amount .. ". Reason: " .. tostring(desc))
	else
		error("attempting to modify casinokit money when player " .. ply:Nick() .. " has no char")
	end
end
function CURRENCY:canPlayerAfford(ply, amount)
	local char = ply:getChar()
	return char and char:hasMoney(amount)
end

CasinoKit.registerCurrency("nutscript", CURRENCY)