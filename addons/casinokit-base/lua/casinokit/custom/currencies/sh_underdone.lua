-- Underdone RPG currency provided by 'Commander'
local CURRENCY = {}
local fflags = SERVER and bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY) or FCVAR_REPLICATED
 
local cvar_underdone_to = CreateConVar("casinokit_chiprate_underdone_money2chips", "1", fflags, "how many tokens per Underdone RPG money player gets. This gets rounded down")
local cvar_underdone_fee = CreateConVar("casinokit_chiprate_underdone_exchangefee", "0.01", fflags, "the percentage taken from player when they exchange from chips to money")
 
CURRENCY.NiceName = "Underdone RPG"
CURRENCY.UnitName = "money"
CURRENCY.UnitPluralName = "money"
 
function CURRENCY:isEnabled()
    return string.lower(GAMEMODE.Name) == "underdone - rpg"
end
 
function CURRENCY:getExchangeRateFromCurrencyToChips(ply)
    return cvar_underdone_to:GetFloat()
end
 
function CURRENCY:getExchangeRateFromChipsToCurrency(ply)
    return (1 / cvar_underdone_to:GetFloat()) * (1 - cvar_underdone_fee:GetFloat())
end
 
function CURRENCY:addPlayerCurrency(ply, amount)
    ply:AddItem("money", amount)
end
function CURRENCY:canPlayerAfford(ply, amount)
    return ply:HasItem("money", amount)
end
 
CasinoKit.registerCurrency("underdone", CURRENCY)
