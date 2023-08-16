local function findTableEnt(e)
	for d=0, 3 do
		if not IsValid(e) then return end
		if e.CasinoKitTable then return e end

		e = e:GetParent()
	end
end

local Player = FindMetaTable("Player")
function Player:CKit_ExchangeMoneyToChips(currency, money, counterpartyEntity)
	assert(money >= 0)
	assert(math.floor(money) == money)

	local exchangeRate = currency:getExchangeRateFromCurrencyToChips(self)
	local chips = math.floor(exchangeRate * money)
	assert(chips >= 0)

	-- Zero chips = nil operation
	if chips == 0 then
		return
	end

	local maxAllowedChips = CasinoKit.getConfigNumber("chip.maxcount")
	if maxAllowedChips and maxAllowedChips > 0 then
		-- no decimals to screw things up
		maxAllowedChips = math.floor(maxAllowedChips)

		local plyChips = self:CKit_GetChips()
		if plyChips + chips > maxAllowedChips then
			self:CKit_PrintL("chipexchange_limitreached", { maxChips = maxAllowedChips })
			return
		end
	end

	if not currency:canPlayerAfford(self, money) then
		self:CKit_PrintL("cantafford")
		return
	end
	currency:addPlayerCurrency(self, -money, "currency->chip exchange")
	self:CKit_AddChips(chips, "chip exchange", counterpartyEntity)

	self:CKit_PrintL("currencytochips", { money = money, chips = chips })

	return chips
end
function Player:CKit_ExchangeChipsToMoney(currency, chips, counterpartyEntity)
	assert(chips >= 0)
	assert(math.floor(chips) == chips)

	if self:CKit_GetChips() < chips then
		self:CKit_PrintL("cantafford")
		return
	end
	self:CKit_AddChips(-chips, "chip exchange", counterpartyEntity)

	local baseRate, feeRate = currency:getExchangeRateFromChipsToCurrency(self)
	local baseMoney, feeMoney = math.floor(baseRate * chips), math.floor((feeRate or 0) * chips)

	currency:addPlayerCurrency(self, baseMoney, "chip->currency exchange")

	self:CKit_PrintL("chipstocurrency", { money = baseMoney, chips = chips })

	return baseMoney, feeMoney
end

-- Attempts to remove n amount of chips from player.
-- If this fails, checks if there is a primary currency and then attempts to
-- convert that currency to chips (with proper exchange fee) and immediately discards those chips.
-- This method may not actually touch chips at all, but simply subtracts the currency amount.
--
-- Returns true on success and false if neither currency was enough (or there was no primary currency)
function Player:CKit_TakeChipsWithPrimaryFallback(n, reason, counterparty)
	assert(n > 0, "cannot _add_ chips to chip balance via this method at the moment")

	if self:CKit_CanAffordChips(n) then
		self:CKit_AddChips(-n, reason, counterparty)
		return true
	else

		local pcid = CasinoKit.getConfigString("currency.primary")
		if not pcid then return false end

		local currency = CasinoKit.getCurrency(pcid)
		if not currency then return false end

		local neededMoney = math.ceil(n / currency:getExchangeRateFromCurrencyToChips(self))
		if not currency:canPlayerAfford(self, neededMoney) then return false end

		currency:addPlayerCurrency(self, -neededMoney, "on-fly currency->chip exchange")
		self:CKit_PrintL("currencytochips", { money = neededMoney, chips = n })

		return true
	end
end

util.AddNetworkString("casinokit_chipexchange")
net.Receive("casinokit_chipexchange", function(len, cl)
	local ent = net.ReadEntity()

	local currencyId = net.ReadString()
	local money2chips = net.ReadBool()

	local amountNum = net.ReadUInt(32)
	if amountNum < 0 then cl:ChatPrint("amount<0?") return end -- shouldnt be possible but idk

	local currency = CasinoKit.getCurrency(currencyId)
	if not currency then return end

	if CasinoKit.configSetContains("currency.disabled", currencyId) then
		cl:ChatPrint("This currency has been disabled from chip exchanges.")
		return
	end

	if money2chips then
		cl:CKit_ExchangeMoneyToChips(currency, amountNum, ent)
		DiscordEmbed(cl:Nick() .. " ( " .. cl:SteamID() .. " ) has exchanged:\n " .. amountNum .. " Caps → " .. math.Round(amountNum / 10 , 0) .. " Chips", "🃏 Chip Exchange Log 🃏" , Color(255,255,0), "Admin")
		DiscordEmbed(cl:Nick() .. " ( " .. cl:SteamID() .. " ) has exchanged:\n " .. amountNum .. " Caps → " .. math.Round(amountNum / 10 , 0) .. " Chips", "🃏 Chip Exchange Log 🃏" , Color(255,255,0), "BTeam")

		if cl.recentlyExchanged and cl.recentlyExchanged != cl:getChar() then -- Character transfer tracking
			jlib.AlertStaff(cl:Nick() .. " ( " .. cl:SteamID() .. " ) is potentially attempting to transfer caps between characters!\n- This player has recently exchanged chips, swapped characters, and purchased more chips\n- This specific alert could be a false positive, as the player is yet to obtain caps from said chips")
			DiscordEmbed(cl:Nick() .. " ( " .. cl:SteamID() .. " ) has recently exchanged chips on one character and now just exchanged:" .. amountNum .. " Caps → " .. math.Round(amountNum / 10 , 0) .. " Chips on a new character\n- This alert could be a false positive of intentful abuse", "⚠️ Chip Transfer Alert ⚠️" , Color(255,0,0), "Admin")
			DiscordEmbed(cl:Nick() .. " ( " .. cl:SteamID() .. " ) has recently exchanged chips on one character and now just exchanged:" .. amountNum .. " Caps → " .. math.Round(amountNum / 10 , 0) .. " Chips on a new character\n- This alert could be a false positive of intentful abuse", "⚠️ Chip Transfer Alert ⚠️" , Color(255,0,0), "BTeam")
		end

		cl.recentlyExchanged = cl:getChar()
	else
		local _, feeMoney = cl:CKit_ExchangeChipsToMoney(currency, amountNum, ent)
		DiscordEmbed(cl:Nick() .. " ( " .. cl:SteamID() .. " ) has redeemed:\n " .. math.Round(amountNum / 10 , 0) .. " Chips → " .. amountNum .. " Caps", "🃏 Chip Exchange Log 🃏" , Color(255,255,0), "Admin")
		DiscordEmbed(cl:Nick() .. " ( " .. cl:SteamID() .. " ) has redeemed:\n " .. math.Round(amountNum / 10 , 0) .. " Chips → " .. amountNum .. " Caps", "🃏 Chip Exchange Log 🃏" , Color(255,255,0), "BTeam")

		if cl.recentlyExchanged and cl.recentlyExchanged != cl:getChar() then -- Character transfer tracking
			jlib.AlertStaff(cl:Nick() .. " ( " .. cl:SteamID() .. " ) is potentially attempting to transfer caps between characters!\n- This player has recently exchanged chips, swapped characters, and exchanged for caps\n- This specific alert is likely not a false positive")
			DiscordEmbed(cl:Nick() .. " ( " .. cl:SteamID() .. " ) has recently exchanged chips on one character and now just redeemed:" .. math.Round(amountNum / 10 , 0) .. " Chips → " .. amountNum .. " Caps on a new character\n- This alert is likely not a false positive", "⚠️ Chip Transfer Alert ⚠️" , Color(255,0,0), "Admin")
			DiscordEmbed(cl:Nick() .. " ( " .. cl:SteamID() .. " ) has recently exchanged chips on one character and now just redeemed:" .. math.Round(amountNum / 10 , 0) .. " Chips → " .. amountNum .. " Caps on a new character\n- This alert is likely not a false positive", "⚠️ Chip Transfer Alert ⚠️" , Color(255,0,0), "BTeam")
			cl.recentlyExchanged = cl:getChar()
		end

		-- give table owner his fee moneys
		if feeMoney and feeMoney > 0 then
			local table = findTableEnt(ent)
			if IsValid(table) then
				local tableOwner = table.TableOwner
				if IsValid(tableOwner) then
					currency:addPlayerCurrency(tableOwner, feeMoney, "player exchange fee")
				end
			end
		end
	end
end)
