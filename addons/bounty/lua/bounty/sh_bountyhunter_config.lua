btQuack = btQuack or {}
function btQuack:IsValid()
	return true
end

POSTER_TIMEOUT = 2160 --had to put it here instead of nut.config since it's an addon

--[[
Blacklist config now allows to set jobs permissions to Bounty hunt, receive bounties and accept bounties
Should now properly remove current bounty if switching job while a bounty is active

Config changes:
.JobBlackList now consists of 3 different values instead of just true/false
	- CanPlaceBounty = If this job can place bounties
	- CanReceiveBounty = If this job can have a bounty placed on their head
	- CanBountyHunt = If this job can accept bounties
]]