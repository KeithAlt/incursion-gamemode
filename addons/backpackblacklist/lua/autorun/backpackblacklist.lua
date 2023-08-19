local backpacks = {
    ["stor_briefcase"] = true,
    ["stor_briefcasemedium"] = true,
    ["stor_briefcaselarge"] = true,
    ["stor_ringcase"] = true
}

hook.Add("CanItemBeTransfered", "BackpackBlacklist", function(item, oldInv, newInv)
    if (((item.isArmor or item.isSwep or item.uniqueID == "pipboy" or item.noBackpack) or (item.isChem and !nut.config.get("allowChemsInBackpacks"))) and (newInv.vars and backpacks[newInv.vars.isBag])) or ((oldInv.vars and oldInv.vars.isBag) and (newInv.vars and newInv.vars.isBag)) then
        return false
    end
end)
