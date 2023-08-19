local function c(a)
    return "<color="..a.r..","..a.g..","..a.b..">"
end
local function col(s, col)
    return string.format("<color=%s,%s,%s>%s</color>", col.r, col.g, col.b, s)
end
local rgb = Color

local function updateBountyLanguage()
    local englishStrings = {
        bountyCollected = "You've collected %s for killing %s.",
        bountyPlaced = "You've successfully placed bounty %s on %s.",
        bountyPlacedOnYou = "A Bounty has been placed on your head.",
        bountyClaimed = "%s has claimed a bounty on %s's head!",
        bountyPlacedDone = "You successfully placed bounty on %s's head!",
        bountyTaken = "You've started bounty hunting on %'s head.",
        bountyCantYourself = "You can't start bounty placed by yourself!",
        bountyOngoing = "You have already started a bounty, finish it, then come back!",
        bountyDelay = "You can start a bounty on this player again in: %s seconds",
        bountyPoster = "A Bounty Poster",
        bountyTakeHelp = "",
        bountyAlreadyPlaced = "There is already a bounty on that person's head.",
        bountyNotAllowed = "You're not allowed to hunt bounties.",
        bountyNotAllowedToPlace = "You're not allowed to place bounties.",
        bountyEnterAmount = "Enter Reward",
        bountyEnterReason = "Enter Reason",
    }
    local koreanStrings = {
        bountyCollected = "%s 의 현상금을 %s님을 죽여 받았습니다.",
        bountyPlaced = "%s를 %s님을 사냥하여 보상금으로 받았습니다.",
        bountyPlacedOnYou = "당신에 대해서 현상금이 올라왔습니다.",
        bountyClaimed = "%s님이 %s의 현상금을 %s님을 죽여 받았습니다!",
        bountyPlacedDone = "%s님의 머리에 성공적으로 현상금을 걸었습니다.",
        bountyTaken = "%s님에 대한 현상금 사냥을 받았습니다.",
        bountyCantYourself = "당신이 걸어놓은 현상금은 받을 수 없습니다!",
        bountyOngoing = "이미 진행중인 현상금 사냥이 있습니다. 끝내고 다시 찾아오세요!",
        bountyDelay = "당신의 현상금 사냥을 등록중입니다. %s 초후 시도해주세요",
        bountyPoster = "현상수배지",
        bountyTakeHelp = "",
        bountyAlreadyPlaced = "이미 현상수배가 된 인원입니다.",
        bountyNotAllowed = "당신은 현상금 사냥을 사용할 수 없습니다.",
        bountyNotAllowedToPlace = "당신은 현상금을 걸 수 없습니다.",
        jobChangedWhileBounty = "당신은 현상금이 걸린채로 캐릭터를 변경했습니다.",
        jobChangedWhileBounty2 = "당신의 행동은 서버에 기록되었으며, 반복된다면 처벌될 수 있습니다.",
        bountyEnterAmount = "현상금 쓰는 곳",
        bountyEnterReason = "이유 쓰는 곳",
    }

    table.Merge(nut.lang.stored.english, englishStrings)
    table.Merge(nut.lang.stored.korean, koreanStrings)
end

local unique = "updateBountyLanguage"
hook.Add("Think", unique, function()
    if (nut) then
        updateBountyLanguage()
        hook.Remove("Think", unique)
    end
end)