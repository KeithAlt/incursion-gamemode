function nut.handlers.modifyWalk(player, modifier)
	player:SetWalkSpeed(player:GetWalkSpeed() + modifier)
end

function nut.handlers.modifyRun(player, modifier)
	player:SetRunSpeed(player:GetRunSpeed() + modifier)
end

function nut.handlers.modifyJump(player, modifier)
	player:SetJumpPower(player:GetJumpPower() + modifier)
end
