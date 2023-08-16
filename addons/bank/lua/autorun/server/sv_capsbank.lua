util.AddNetworkString("capsbankRequestWithdrawl")

local disconnectedTransactions = {}

hook.Add("PlayerDisconnected", "AntiTransfer", function(ply)
    if ply.recentExchanges then
        disconnectedTransactions[ply:SteamID64()] = ply.recentExchanges
    end
end)

hook.Add("PlayerInitialSpawn", "AntiTransfer", function(ply)
    if disconnectedTransactions[ply:SteamID64()] then
        ply.recentExchanges = disconnectedTransactions[ply:SteamID64()]
        disconnectedTransactions[ply:SteamID64()] = nil
    end
end)

function AddToBank(ply, amt)
    if !IsValid(ply) then return end
    local char = ply:getChar()
    if !char then return end

    local balance = char:getData("bankbal", 0)
    char:setData("bankbal", balance + amt)

    ply:notify(amt .. " caps has been added to your bank.")
end

local function TakeFromBank(ply, amt)
    if !IsValid(ply) then return end
    local char = ply:getChar()
    if !char then return end

    if amt < 1 then
        ply:notify("Please enter a value of at least 1.")
        return
    end

    local balance = char:getData("bankbal", 0)
    if balance <= 0 then
        ply:notify("You have no caps in the bank to withdraw.")
        return
    elseif balance < amt then
        ply:notify("You do not have enough bank balance to withdraw that amount.")
        return
    end

    local taxamt = amt * capsbankConfig.withdrawlFee
    char:setData("bankbal", balance - amt)
    char:giveMoney(math.floor(amt - taxamt), true)

    ply:notify("You have withdrawn " .. amt .. " caps (" .. math.floor(amt - taxamt) .. " after " .. capsbankConfig.withdrawlFee * 100 .. "% fee)")
end
net.Receive("capsbankRequestWithdrawl", function(len, ply)
    local amt = net.ReadInt(20)
    TakeFromBank(ply, amt)
end)

local function AddExchange(giver, taker)
    giver.recentExchanges = giver.recentExchanges or {}
    taker.recentExchanges = taker.recentExchanges or {}

    table.insert(giver.recentExchanges, {
        ["charID"] = taker:getChar():getID(),
        ["ply"] = taker:SteamID64(),
        ["time"] = CurTime()
    })
    table.insert(taker.recentExchanges, {
        ["charID"] = giver:getChar():getID(),
        ["ply"] = giver:SteamID64(),
        ["time"] = CurTime()
    })
end

function BankAlertStaff(target, chance)
    local msg = "Anti-Transfer: User " .. target:Nick() .. " with SteamID " .. target:SteamID() .. " is attempting to transfer money between characters. " .. (chance and "There's a chance this is a false positive." or "It is almost certain they are trying to exploit.")
    print(msg)
    for _,ply in pairs(player.GetAll()) do
        if ply:IsValid() and ply:IsAdmin() then
            ply:ChatPrint(msg)
        end
    end
end

hook.Add("OnPickupMoney", "CharacterTransferPrevention", function(ply, money)
    if !IsValid(money.client) or !money.charID or !IsValid(ply) then return end

    local char = ply:getChar()
    if !char then return false end

    if money.client == ply and money.charID != char:getID() then
        ply:notify("You cannot pickup money that you dropped on another character!")
        BankAlertStaff(ply, false)
        return false
    end

    local giver, taker = money.client, ply
    local exchanges = giver.recentExchanges
    if exchanges then
        for _, exchange in pairs(exchanges) do
            if exchange.ply == taker:SteamID64() and exchange.charID != taker:getChar():getID() and CurTime() - exchange.time < capsbankConfig.transferCooldown then
                ply:notify("You cannot pickup money that was dropped by someone you just gave money to while on another character!")
                BankAlertStaff(giver, true)
                BankAlertStaff(taker, true)
                return false
            end
        end
    end

    AddExchange(money.client, ply)
end)

hook.Add("PlayerCashExchange", "CharacterTransferPrevention", function(giver, taker)
    local char = taker:getChar()
    if !char then return false end

    local exchanges = giver.recentExchanges
    if exchanges then
        for _, exchange in pairs(exchanges) do
            if exchange.ply == taker:SteamID64() and exchange.charID != taker:getChar():getID() and CurTime() - exchange.time < capsbankConfig.transferCooldown then
                giver:notify("You cannot give money to someone you recently took money from while they were on another character!")
                BankAlertStaff(giver, true)
                BankAlertStaff(taker, true)
                return false
            end
        end
    end

    AddExchange(giver, taker)
end)

hook.Add("CharacterLoaded", "CapsbankTrimExcess", function(id)
    local char = nut.char.loaded[id]
    local ply = char:getPlayer()

    if !char:getData("capsbankTrimmed", false) then
        if char:getMoney() > capsbankConfig.maxCash then
            AddToBank(ply, char:getMoney() - capsbankConfig.maxCash)
            char:setMoney(capsbankConfig.maxCash)
        end
        char:setData("capsbankTrimmed", true)
    end
end)

timer.Create("RecentExchangeCleanup", 1800, 0, function()
    for _,ply in pairs(player.GetAll()) do
        if !ply.recentExchanges then continue end
        for k,exchange in pairs(ply.recentExchanges) do
            if CurTime() - exchange.time > capsbankConfig.transferCooldown then
                ply.recentExchanges[k] = nil
            end
        end
    end
end)