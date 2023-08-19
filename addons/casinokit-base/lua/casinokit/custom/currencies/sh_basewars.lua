local CURRENCY = {}

-- dont archive on client
local fflags = SERVER and bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY) or FCVAR_REPLICATED

local cvar_basewars_to = CreateConVar("casinokit_chiprate_basewars_money2chips", "0.1", fflags, "how many tokens per basewars money player gets. This gets rounded down")
local cvar_basewars_fee = CreateConVar("casinokit_chiprate_basewars_exchangefee", "0.01", fflags, "the percentage taken from player when they exchange from chips to money")

CURRENCY.NiceName = "BaseWars"
CURRENCY.UnitName = "#money"
CURRENCY.UnitPluralName = "#money"

function CURRENCY:isEnabled()
	return BaseWars ~= nil
end

function CURRENCY:getExchangeRateFromCurrencyToChips(ply)
	return cvar_basewars_to:GetFloat(), 0
end

function CURRENCY:getExchangeRateFromChipsToCurrency(ply)
	local feeFrac = cvar_basewars_fee:GetFloat()
	local baseRate = (1 / cvar_basewars_to:GetFloat())

	return baseRate * (1 - feeFrac), baseRate * feeFrac
end

function CURRENCY:addPlayerCurrency(ply, amount, desc)
	ply:GiveMoney(amount)
	ply:PrintMessage(HUD_PRINTCONSOLE, "[CasinoKit] Modified money " .. amount .. ". Reason: " .. tostring(desc))
end
function CURRENCY:canPlayerAfford(ply, amount)
	return ply:GetMoney() >= amount
end

CasinoKit.registerCurrency("basewars", CURRENCY)