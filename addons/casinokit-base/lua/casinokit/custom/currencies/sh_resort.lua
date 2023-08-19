local CURRENCY = {}

-- dont archive on client
local fflags = SERVER and bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY) or FCVAR_REPLICATED

local cvar_resort_to = CreateConVar("casinokit_chiprate_resort_money2chips", "0.1", fflags, "how many tokens per resort money player gets. This gets rounded down")
local cvar_resort_fee = CreateConVar("casinokit_chiprate_resort_exchangefee", "0.01", fflags, "the percentage taken from player when they exchange from chips to money")

CURRENCY.NiceName = "resort"
CURRENCY.UnitName = "#money"
CURRENCY.UnitPluralName = "#money"

function CURRENCY:isEnabled()
	return resort ~= nil
end

function CURRENCY:getExchangeRateFromCurrencyToChips(ply)
	return cvar_resort_to:GetFloat(), 0
end

function CURRENCY:getExchangeRateFromChipsToCurrency(ply)
	local feeFrac = cvar_resort_fee:GetFloat()
	local baseRate = (1 / cvar_resort_to:GetFloat())

	return baseRate * (1 - feeFrac), baseRate * feeFrac
end

function CURRENCY:addPlayerCurrency(ply, amount, desc)
	ply:Resort_AddMoney(amount,desc)
end
function CURRENCY:canPlayerAfford(ply, amount)
	return ply:Resort_CanAfford(amount)
end

CasinoKit.registerCurrency("resort", CURRENCY)