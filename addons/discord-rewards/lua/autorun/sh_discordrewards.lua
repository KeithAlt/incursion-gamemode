DiscordRewards = DiscordRewards or {}
DiscordRewards.Config = DiscordRewards.Config or {}

local function commandInit()
    nut.command.add("discordreward", {
        syntax = "<reward code>",
        onRun = function(ply, args)
            local code = args[1]

            local db = DiscordRewards.db

            local q = db:query("SELECT * FROM `codes` WHERE `usedBy` = '" .. ply:SteamID64() .. "';") --Check if they have already claimed a code
            q.onSuccess = function(self, data)
                if #data == 0 then
                    q = db:query("SELECT * FROM `codes` WHERE `code` = '" .. db:escape(code) .. "';") --Check if the code they provided is valid
                    q.onSuccess = function(s, result)
                        if #result == 1 then
                            if result[1].used != 1 then --They have passed all checks, redeem the code
                                ply:notify("Success! You have redeemed the code " .. code)
                                DiscordRewards.redeemCode(ply, code)
                            else
                                ply:notify("The code you have given has already been used!")
                            end
                        else
                            ply:notify("Unrecognized code.")
                        end
                    end
                    q:start()
                else
                    ply:notify("You have already redeemed a code!")
                end
            end
            q:start()
        end
    })

    nut.command.add("getreferralcode", {
        syntax = "",
        onRun = function(ply, args)
            local code = ply:AccountID()
            ply:ChatPrint("Your referral code is: " .. code)

            local db = DiscordRewards.db

            local q = db:query("INSERT IGNORE INTO `users` (steamID64, code) VALUES('" .. ply:SteamID64() .. "', '" .. code .. "');")
            q:start()
        end
    })

    nut.command.add("submitreferralcode", {
        syntax = "<referral code>",
        onRun = function(ply, args)
            local code = tonumber(args[1])

            if !code then
                ply:notify("Ensure you are only using numeric characters.")
            end

            local db = DiscordRewards.db

            if code != ply:AccountID() then --Check they aren't trying to use their own code
                code = db:escape(tostring(code))

                local q = db:query("SELECT * FROM `users` WHERE `steamID64` = '" .. ply:SteamID64() .. "';") --Check if the user has already used a code
                q.onSuccess = function(self, data)
                    if data[1] and data[1].codeUsed then --They have, alert them and stop
                        ply:notify("You have already used a referral code!")
                    else
                        q = db:query("SELECT * FROM `users` WHERE `code` = '" .. code .. "';") --Check if the code is valid
                        q.onSuccess = function(s, result)
                            if result[1] then --It is, update the code this player has used
                                q = db:query("INSERT INTO `users` (`steamID64`, `codeUsed`, `code`) VALUES('" .. ply:SteamID64() .. "', '" .. code .. "', '" .. ply:AccountID() .. "') ON DUPLICATE KEY UPDATE codeUsed = " .. code .. ";")
                                q:start()

                                ply:notify("Success!")
                            else --It isn't, alert them and stop
                                ply:notify("Unrecognized code.")
                            end
                        end
                        q:start()
                    end
                end
                q:start()
            else
                ply:notify("You can't use your own referral code!")
            end
        end
    })

    nut.command.add("referrals", {
        syntax = "",
        onRun = function(ply, args)
            local db = DiscordRewards.db

            local q = db:query("INSERT IGNORE INTO `users` (steamID64, code) VALUES('" .. ply:SteamID64() .. "', '" .. ply:AccountID() .. "');")
            q.onSuccess = function()
                q = db:query("SELECT * FROM `users` WHERE `codeUsed` = '" .. ply:AccountID() .. "';")
                q.onSuccess = function(self, codeUsers)
                    for _,v in pairs(codeUsers) do
                        v.rewardClaimed = nil
                        v.codeUsed = nil
                    end

                    q = db:query("SELECT * FROM `users` WHERE steamID64 = '" .. ply:SteamID64() .. "';")
                    q.onSuccess = function(s, data)
                        local nextTier = {}
                        local nextTierRequirement = -1
                        for referralsRequired, rewards in pairs(DiscordRewards.ReferralRewards) do
                            referralsRequired = tonumber(referralsRequired)
                            if referralsRequired > (data[1].rewardClaimed or 0) and (nextTierRequirement == -1 or nextTierRequirement > referralsRequired) then
                                nextTierRequirement = referralsRequired
                                nextTier = rewards
                            end
                        end

                        net.Start("ReferralOpenMenu")
                            net.WriteTable(codeUsers)
                            net.WriteTable(nextTier)
                            net.WriteInt(nextTierRequirement, 32)
                        net.Send(ply)
                    end
                    q:start()
                end
                q:start()
            end
            q:start()
        end
    })
end
hook.Add("InitPostEntity", "DiscordCommandInit", commandInit)