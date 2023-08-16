netstream.Hook("nutUnlockReward", function(client)
	local rewardDay = client:getNutData("rewardDay", 1)
	local lastReward = client:getNutData("lastReward", 0)

	if (lastReward == os.date("%d")) then
		return false
	end

	if (rewardDay > #nut.rewards) then
		rewardDay = 1
	end

	local reward = nut.rewards[rewardDay]
	local character = client:getChar()

	if (reward.type == 1) then
		local inv = character:getInv()

		local item, error = inv:add(reward.item)

		if (!item) then
			client:ChatPrint("Failed to give daily reward item! (Probably not enough inventory space)")
			return false
		else
			client:ChatPrint("You have gained a "..nut.item.list[reward.item].name.."!")
		end;
	elseif (reward.type == 2) then
		character:giveMoney(reward.amount)
		client:ChatPrint("You have gained "..reward.amount.." Caps!")
	end;

	client:setNutData("rewardDay", rewardDay + 1)
	client:setNutData("lastReward", os.date("%d"))
end)
