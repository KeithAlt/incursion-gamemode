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

vgui.Register("jRewardsPanel", PANEL, "DPanel")

local function DiscordRewardsConfigMenu()
    local currentRewards = net.ReadTable()

    local frame = vgui.Create("DFrame")
    frame:MakePopup()
    frame:SetSize(600, 400)
    frame:SetTitle("Discord Rewards Config")
    frame:Center()

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)

    local rewards = {}

    local addRewardButton = vgui.Create("DImageButton", scroll)
    addRewardButton:SetSize(16, 16)
    addRewardButton:SetImage("icon16/add.png")
    addRewardButton:SetPos(550, 5)
    addRewardButton.DoClick = function(s)
        local rewardPanel = vgui.Create("jRewardsPanel", scroll)
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

            table.insert(rewardsConfig, v.rewardInfo)
        end

        net.Start("DiscordRewardsSendConfig")
            net.WriteTable(rewardsConfig)
        net.SendToServer()
    end

    for _,reward in pairs(currentRewards) do
        local rewardPanel = vgui.Create("jRewardsPanel", scroll)
        rewardPanel:SetPos((frame:GetWide()/2) - (rewardPanel:GetWide()/2), 30)
        print(scroll:GetWide(), rewardPanel:GetWide())

        if #rewards != 0 then
            rewardPanel:MoveBelow(rewards[#rewards], 10)
        end

        rewardPanel:SetReward(reward)
        rewardPanel.combo:SetValue(reward.type:upper())
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
net.Receive("DiscordRewardsOpenConfigMenu", DiscordRewardsConfigMenu)