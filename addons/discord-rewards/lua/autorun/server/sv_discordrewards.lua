require("mysqloo")

AddCSLuaFile("discordconfigmenu.lua")
AddCSLuaFile("referralconfigmenu.lua")

util.AddNetworkString("DiscordRewardsSendConfig")
util.AddNetworkString("DiscordRewardsOpenConfigMenu")

util.AddNetworkString("ReferralRewardsOpenConfigMenu")
util.AddNetworkString("ReferralRewardsSendConfig")
util.AddNetworkString("ReferralOpenMenu")
util.AddNetworkString("ReferralClaimRewards")

DiscordRewards.ConnectionRewards = DiscordRewards.ConnectionRewards or {}
DiscordRewards.ReferralRewards = DiscordRewards.ReferralRewards or {}

function DiscordRewards.loadRewards()
    if !file.Exists("drrewards", "DATA") then
        file.CreateDir("drrewards")
    end

    if file.Exists("drrewards/connectionrewards.txt", "DATA") then
        DiscordRewards.ConnectionRewards = util.JSONToTable(file.Read("drrewards/connectionrewards.txt"))
    end
    if file.Exists("drrewards/referralrewards.txt", "DATA") then
        DiscordRewards.ReferralRewards = util.JSONToTable(file.Read("drrewards/referralrewards.txt"))
    end
end
DiscordRewards.loadRewards()

function DiscordRewards.dbConnect()
    DiscordRewards.db = mysqloo.connect('remote_database_ip_address', 'claymore_ref', 'bvYTFA7e6NE4ZMRJV5qf', 'claymore_referrals')
    DiscordRewards.db.onConnected = function(db)
        db:query("CREATE TABLE IF NOT EXISTS `codes` (`code` VARCHAR(9) PRIMARY KEY, `used` INTEGER, `usedBy` VARCHAR(17), `generatedBy` VARCHAR(64));"):start()
        db:query("CREATE TABLE IF NOT EXISTS `users` (`steamID64` VARCHAR(17) PRIMARY KEY, `codeUsed` VARCHAR(9), `code` VARCHAR(9), `rewardClaimed` INTEGER);"):start()
    end
    DiscordRewards.db:connect()
end
if !DiscordRewards.db or !DiscordRewards.db:ping() then
    DiscordRewards.dbConnect()
end

function DiscordRewards.claimReward(reward, ply)
    if reward.type == "money" then
        ply:getChar():giveMoney(reward.amt)
        ply:ChatPrint("You have been rewarded with " .. reward.amt .. " caps!")
    elseif reward.type == "item" then
        for i = 1, reward.amt do
            ply:getChar():getInv():add(reward.item)
        end
        ply:ChatPrint("You have been rewarded with " .. reward.amt .. " " .. nut.item.list[reward.item].name)
    elseif reward.type == "exp" then
        nut.leveling.giveXP(ply, reward.amt, true, true)
        ply:ChatPrint("You have been rewarded with " .. reward.amt .. " XP!")
    end
end

function DiscordRewards.redeemCode(ply, code)
    local db = DiscordRewards.db

    local q = db:query("UPDATE `codes` SET used = 1, usedBy = '" .. ply:SteamID64() .. "' WHERE code = '" .. code .. "';") --Update the code to be flagged as used
    q.onSuccess = function(s, result) --Only give the user their rewards after we know the query was a success to prevent the same code being used several times
        --Handle giving the user the reward(s)
        for _,reward in pairs(DiscordRewards.ConnectionRewards) do
            DiscordRewards.claimReward(reward, ply)
        end
    end
    q:start()
end

--Config menu
hook.Add("PlayerSay", "DiscordRewardsOpenConfigMenu", function(ply, text)
    if ply:IsSuperAdmin() and text:lower() == "!discordrewardsconfig" then
        net.Start("DiscordRewardsOpenConfigMenu")
            net.WriteTable(DiscordRewards.ConnectionRewards)
        net.Send(ply)
        return ""
    elseif ply:IsSuperAdmin() and text:lower() == "!referralrewardsconfig" then
        net.Start("ReferralRewardsOpenConfigMenu")
            net.WriteTable(DiscordRewards.ReferralRewards)
        net.Send(ply)
        return ""
    end
end)

net.Receive("DiscordRewardsSendConfig", function(len, ply)
    if !ply:IsSuperAdmin() then return end

    DiscordRewards.ConnectionRewards = net.ReadTable()

    file.Write("drrewards/connectionrewards.txt", util.TableToJSON(DiscordRewards.ConnectionRewards))
end)

net.Receive("ReferralRewardsSendConfig", function(len, ply)
    if !ply:IsSuperAdmin() then return end

    DiscordRewards.ReferralRewards = net.ReadTable()

    file.Write("drrewards/referralrewards.txt", util.TableToJSON(DiscordRewards.ReferralRewards))
end)

--Claim referral rewards
net.Receive("ReferralClaimRewards", function(len, ply)
    local db = DiscordRewards.db

    local q = db:query("SELECT * FROM `users` WHERE `codeUsed` = '" .. ply:AccountID() .. "';")
    q.onSuccess = function(self, data)
        local referralAmt = #data
        q = db:query("SELECT * FROM `users` WHERE `steamID64` = '" .. ply:SteamID64() .. "';")
        q.onSuccess = function(s, d)
            local result = d[1]
            result.rewardClaimed = result.rewardClaimed or 0
            local highestTierRewarded = result.rewardClaimed

            local rewardTiersClaimed = 0
            for referralAmtNeeded, rewards in pairs(DiscordRewards.ReferralRewards) do
                referralAmtNeeded = tonumber(referralAmtNeeded)
                if referralAmtNeeded <= referralAmt and referralAmtNeeded > result.rewardClaimed then
                    if referralAmtNeeded > highestTierRewarded then
                        highestTierRewarded = referralAmtNeeded
                    end

                    for _, reward in pairs(rewards) do
                        DiscordRewards.claimReward(reward, ply)
                    end

                    rewardTiersClaimed = rewardTiersClaimed + 1
                end
            end

            if rewardTiersClaimed == 0 then
                ply:notify("You have no rewards to claim!")
            else
                ply:notify("You have claimed " .. rewardTiersClaimed .. " referral reward tier(s)!")
            end

            if highestTierRewarded > result.rewardClaimed then
                db:query("UPDATE `users` SET `rewardClaimed` = '" .. highestTierRewarded .. "' WHERE steamID64 = '" .. ply:SteamID64() .. "';"):start()
            end
        end
        q:start()
    end
    q:start()
end)
