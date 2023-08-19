-- Purpose: Tie a player with a ziptie
nut.playerInteract.addFunc("useZipTie", {
	nameLocalized = "Use Ziptie",
	callback = function(target)
		net.Start("nutZiptieActions")
		net.WriteString("tie")
		net.SendToServer()
	end,
	canSee = function(target)
		return LocalPlayer():getChar():getInv():hasItem("tie") and not target:getNetVar("restricted") and not LocalPlayer():getNetVar("restricted")
	end
})

-- Purpose: Check the money balance of a player
nut.playerInteract.addFunc("checkMoney", {
	nameLocalized = "Check wallet",
	callback = function()
		net.Start("nutZipCheckMoney")
		net.WriteEntity(LocalPlayer())
		net.SendToServer()
	end,
	canSee = function(target)
		return target:getNetVar("restricted") and not LocalPlayer():getNetVar("restricted")
	end
})

-- Purpose: Untie a player if they are currently tied.
nut.playerInteract.addFunc("untieZipTie", {
	nameLocalized = "Untie Character",
	callback = function(target)
		net.Start("nutZiptieActions")
		net.WriteString("untie")
		net.WriteEntity(target)
		net.SendToServer()
	end,
	canSee = function(target)
		return target:getNetVar("restricted") and not LocalPlayer():getNetVar("restricted")
	end
})

-- Purpose: Search a player with a ziptie
nut.playerInteract.addFunc("searchChar", {
	nameLocalized = "Search Character",
	callback = function(target)
		net.Start("nutZiptieActions")
		net.WriteString("search")
		net.SendToServer()
	end,
	canSee = function(target)
		return target:getNetVar("restricted") and not LocalPlayer():getNetVar("restricted")
	end
})

-- Purpose: Disarm a player who has a slavecollar
nut.playerInteract.addFunc("disarmCollar", {
	nameLocalized = "Attempt to Disarm Collar",
	callback = function(target)
		net.Start("nutAttemptDisarmCollar")
		net.WriteEntity(target)
		net.SendToServer()
	end,
	canSee = function(target)
		return target:getNetVar("enslaved") and not LocalPlayer():getNetVar("restricted")
	end
})

nut.playerInteract.addFunc("openHuntingMenu", {
	nameLocalized = "Bounty Hunting",
	callback = function(hunter)
        if IsValid(hunter:GetTarget()) then
            nut.util.notify("This hunter already has a target!")
            return
        else
            BountyHunting.SetBountyMenu(hunter)
        end
	end,
	canSee = function(hunter)
		return IsValid(hunter) and hunter:IsPlayer() and hunter:IsBountyHunter() and not LocalPlayer():IsBountyHunter()
	end
})