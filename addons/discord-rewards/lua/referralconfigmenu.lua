local rewardTypes = {
    ["money"] = {
        ["amt"] = "Amount"
    },
    ["item"] = {
        ["item"] = "Item classname",
        ["amt"] = "Amount"
    },
    ["exp"] = {
        ["amt"] = "Amount"
    }
}

local PANEL = {}

function PANEL:Init()
    self:SetSize(300, 100)

    self.rewardType = "none"
    self.rewardTypeDerma = {}
    self.rewardInfo = {}

    local combo = self:Add("DComboBox")
    combo:SetValue("Reward Type")
    combo:AddChoice("Money")
    combo:AddChoice("Item")
    combo:AddChoice("EXP")
    combo.OnSelect = function(s, i, v)
        self.rewardType = v:lower()
        self:RewardTypeChanged()
    end
    combo:SetSize(100, 20)
    self.combo = combo

    local amtEntry = self:Add("DTextEntry")
    amtEntry:SetPlaceholderText("Amount of Referrals")
    amtEntry:SetWide(110)
    amtEntry:SetPos(self:GetWide() - amtEntry:GetWide())
    amtEntry:SetNumeric(true)
    amtEntry.OnChange = function(s)
        self.referralAmt = s:GetText()
    end
    self.amtEntry = amtEntry
end

function PANEL:RewardTypeChanged()
    for k,v in pairs(self.rewardTypeDerma) do
        v:Remove()
        self.rewardTypeDerma[k] = nil
    end
    self.rewardInfo = {type = self.rewardType}

    local i = 1
    for k,v in pairs(rewardTypes[self.rewardType]) do
        if k == "item" then
            local itemInput = self:Add("DTextEntry")
            itemInput:SetPlaceholderText(v)
            itemInput:SetWide(100)
            itemInput:SetPos((self:GetWide()/2) - (itemInput:GetWide()/2), 25 * i)
            itemInput.OnChange = function(s)
                self.rewardInfo.item = s:GetText()
            end
            table.insert(self.rewardTypeDerma, itemInput)
        elseif k == "amt" then
            local amtInput = self:Add("DTextEntry")
            amtInput:SetPlaceholderText(v)
            amtInput:SetWide(100)
            amtInput:SetPos((self:GetWide()/2) - (amtInput:GetWide()/2), 25 * i)
            amtInput:SetNumeric(true)
            amtInput.OnChange = function(s)
                self.rewardInfo.amt = tonumber(s:GetText())
            end
            table.insert(self.rewardTypeDerma, amtInput)
        end

        i = i + 1
    end
end

function PANEL:SetReward(reward)
    self.rewardType = reward.type
    self:RewardTypeChanged()
    self.rewardInfo = reward
end

function PANEL:Paint(w, h)
    draw.RoundedBox(6, 0, 0, w, h, Color(255, 255, 255, 255))
end

vgui.Register("jRRewardsPanel", PANEL, "DPanel")

local function ReferralRewardsConfigMenu()
    local rewardsTable = net.ReadTable()

    local frame = vgui.Create("DFrame")
    frame:MakePopup()
    frame:SetSize(600, 400)
    frame:SetTitle("Referral Rewards Config")
    frame:Center()

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)

    local rewards = {}

    local addRewardButton = vgui.Create("DImageButton", scroll)
    addRewardButton:SetSize(16, 16)
    addRewardButton:SetImage("icon16/add.png")
    addRewardButton:SetPos(550, 5)
    addRewardButton.DoClick = function(s)
        local rewardPanel = vgui.Create("jRRewardsPanel", scroll)
        rewardPanel:SetPos((frame:GetWide()/2) - (rewardPanel:GetWide()/2), 30)

        if #rewards != 0 then
            rewardPanel:MoveBelow(rewards[#rewards], 10)
        end

        addRewardButton:SetPos((rewardPanel:GetPos() + rewardPanel:GetWide()) - addRewardButton:GetWide())
        addRewardButton:MoveBelow(rewardPanel, 2)

        local removeRewardButton = vgui.Create("DImageButton", scroll)
        removeRewardButton:SetSize(16, 16)
        removeRewardButton:SetImage("icon16/cancel.png")
        removeRewardButton:SetPos(rewardPanel:GetPos())
        removeRewardButton:MoveRightOf(rewardPanel, 2)
        removeRewardButton.DoClick = function(self)
            table.RemoveByValue(rewards, rewardPanel)
            rewardPanel:Remove()
            self:Remove()
            local bottomRewardPanel = rewards[#rewards]
            if bottomRewardPanel then
                s:SetPos(bottomRewardPanel:GetPos())
                s:MoveBelow(bottomRewardPanel, 2)
                s:MoveRightOf(bottomRewardPanel, -16)
            end
        end

        table.insert(rewards, rewardPanel)
    end

    local saveButton = vgui.Create("DButton", frame)
    saveButton:SetText("SAVE")
    saveButton:SetTextColor(Color(255, 255, 255, 255))
    saveButton:SetPos(frame:GetWide() - saveButton:GetWide() - 21, frame:GetTall() - saveButton:GetTall() - 1)
    saveButton.DoClick = function(s)
        local rewardsConfig = {}

        for k,v in pairs(rewards) do
            if !v.rewardType or v.rewardType == "none" then continue end

            rewardsConfig[v.referralAmt] = rewardsConfig[v.referralAmt] or {}
            table.insert(rewardsConfig[v.referralAmt], v.rewardInfo)
        end

        net.Start("ReferralRewardsSendConfig")
            net.WriteTable(rewardsConfig)
        net.SendToServer()
    end

    for amtRequired, currentRewards in pairs(rewardsTable) do
        for _,reward in pairs(currentRewards) do
            local rewardPanel = vgui.Create("jRRewardsPanel", scroll)
            rewardPanel:SetPos((frame:GetWide()/2) - (rewardPanel:GetWide()/2), 30)
            print(scroll:GetWide(), rewardPanel:GetWide())

            if #rewards != 0 then
                rewardPanel:MoveBelow(rewards[#rewards], 10)
            end

            rewardPanel:SetReward(reward)
            rewardPanel.combo:SetValue(reward.type:upper())
            rewardPanel.amtEntry:SetValue(amtRequired)
            rewardPanel.referralAmt = amtRequired
            local i = 1
            for _,v in pairs(rewardPanel.rewardTypeDerma) do
                if i == 1 then
                    v:SetValue(reward.amt)
                else
                    v:SetValue(reward.item)
                end
                i = i + 1
            end

            addRewardButton:SetPos((rewardPanel:GetPos() + rewardPanel:GetWide()) - addRewardButton:GetWide())
            addRewardButton:MoveBelow(rewardPanel, 2)

            local removeRewardButton = vgui.Create("DImageButton", scroll)
            removeRewardButton:SetSize(16, 16)
            removeRewardButton:SetImage("icon16/cancel.png")
            removeRewardButton:SetPos(rewardPanel:GetPos())
            removeRewardButton:MoveRightOf(rewardPanel, 2)
            removeRewardButton.DoClick = function(self)
                table.RemoveByValue(rewards, rewardPanel)
                rewardPanel:Remove()
                self:Remove()
                local bottomRewardPanel = rewards[#rewards]
                if bottomRewardPanel then
                    addRewardButton:SetPos(bottomRewardPanel:GetPos())
                    addRewardButton:MoveBelow(bottomRewardPanel, 2)
                    addRewardButton:MoveRightOf(bottomRewardPanel, -16)
                end
            end

            table.insert(rewards, rewardPanel)
        end
    end
end
net.Receive("ReferralRewardsOpenConfigMenu", ReferralRewardsConfigMenu)

surface.CreateFont("referralMenu", {font = "Arial", size = 24})
surface.CreateFont("referralMenuSmall", {font = "Arial", size = 22})

local function ReferralsMenu()
    local codeUsers = net.ReadTable()
    local nextTierRewards = net.ReadTable()
    local nextTierRequirement = net.ReadInt(32)

    local frame = vgui.Create("DFrame")
    frame:MakePopup()
    frame:SetSize(630, 400)
    frame:SetTitle("Your Referrals")
    frame:Center()

    local listView = vgui.Create("DListView", frame)
    listView:AddColumn("SteamID")
    listView:AddColumn("Their Referral Code")
    for _,v in pairs(codeUsers) do
        listView:AddLine(v.steamID64, v.code)
    end
    listView:Dock(LEFT)
    listView:SetWide(220)

    local yourCode = vgui.Create("DLabel", frame)
    yourCode:SetFont("referralMenu")
    yourCode:SetText("Your Referral Code: " .. LocalPlayer():AccountID())
    yourCode:SetTextColor(Color(255, 255, 255, 255))
    yourCode:SetExpensiveShadow(2, Color(0, 0, 0, 190))
    yourCode:SizeToContents()
    yourCode:MoveRightOf(listView, 10)
    yourCode:MoveAbove(listView, -60)

    local referralAmt = vgui.Create("DLabel", frame)
    referralAmt:SetFont("referralMenu")
    referralAmt:SetText("Number of Referrals: " .. #codeUsers)
    referralAmt:SetTextColor(Color(255, 255, 255, 255))
    referralAmt:SetExpensiveShadow(2, Color(0, 0, 0, 190))
    referralAmt:SizeToContents()
    referralAmt:MoveRightOf(listView, 10)
    referralAmt:MoveBelow(yourCode, 5)

    local refsNeeded = vgui.Create("DLabel", frame)
    refsNeeded:SetFont("referralMenu")
    refsNeeded:SetText(nextTierRequirement >= #codeUsers and ("Total Referrals For Next Reward Tier: " .. nextTierRequirement) or "You have earned all referral reward tiers!")
    refsNeeded:SetTextColor(Color(255, 255, 255, 255))
    refsNeeded:SetExpensiveShadow(2, Color(0, 0, 0, 190))
    refsNeeded:SizeToContents()
    refsNeeded:MoveRightOf(listView, 10)
    refsNeeded:MoveBelow(referralAmt, 15)

    if nextTierRequirement >= #codeUsers then
        local nextTierHead = vgui.Create("DLabel", frame)
        nextTierHead:SetFont("referralMenu")
        nextTierHead:SetText("Rewards For Next Reward Tier:")
        nextTierHead:SetTextColor(Color(255, 255, 255, 255))
        nextTierHead:SetExpensiveShadow(2, Color(0, 0, 0, 190))
        nextTierHead:SizeToContents()
        nextTierHead:MoveRightOf(listView, 10)
        nextTierHead:MoveBelow(refsNeeded, 5)

        local prevReward
        for _,reward in pairs(nextTierRewards) do
            local rewardLabel = vgui.Create("DLabel", frame)

            if reward.type == "item" then
                rewardLabel:SetText("• " .. reward.amt .. " " .. nut.item.list[reward.item].name)
            elseif reward.type == "money" then
                rewardLabel:SetText("• " .. reward.amt .. " caps")
            elseif reward.type == "exp" then
                rewardLabel:SetText("• " .. reward.amt .. " XP")
            end

            rewardLabel:SetFont("referralMenuSmall")
            rewardLabel:SetTextColor(Color(255, 255, 255, 255))
            rewardLabel:SetExpensiveShadow(2, Color(0, 0, 0, 190))
            rewardLabel:SizeToContents()
            rewardLabel:MoveRightOf(listView, 10)
            rewardLabel:MoveBelow(prevReward or nextTierHead, 5)

            prevReward = rewardLabel
        end
    end

    local claimRewardsB = vgui.Create("DButton", frame)
    claimRewardsB:Dock(BOTTOM)
    claimRewardsB:SetText("Claim Rewards")
    claimRewardsB:SetTextColor(Color(255, 255, 255, 255))
    claimRewardsB.DoClick = function(s)
        net.Start("ReferralClaimRewards")
        net.SendToServer()
    end
end
net.Receive("ReferralOpenMenu", ReferralsMenu)