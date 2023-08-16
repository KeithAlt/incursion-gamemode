BountyHunting.Config.FootstepFrequency = 10 --Every X footsteps will be shown to the hunter. Example: If the value is 10 every 10th footstep will be shown to the hunter.
BountyHunting.Config.FootstepLife = 60 --How long a footstep will remain visible for after it's initial appearance.
BountyHunting.Config.FootstepDrawDistance = 750 --Draw distance for footsteps
BountyHunting.Config.DmgTime = 15 --How recently the hunter needs to have taken damage from a player when they die for it to count as them dying to a player
BountyHunting.Config.MinimumOffer = 500 --The minimum number of caps someone can offer for a bounty
BountyHunting.Config.TargetCooldown = 1800 --The length of the cooldown between the same target being selected
BountyHunting.Config.HeadCollectionTime = 3 --The time it takes to collect someone's head
BountyHunting.Config.BodyAge = 20 --How long a player's dead body will remain for
BountyHunting.Config.IdentificationTime = 2 --The time it takes to identify whether or not someone is your target
BountyHunting.Config.NoHead = { --Factions that cannot have their head taken
	["monster"] = true,
	["feral"] = true,
	["robot"] = true,
	["securitron"] = true,
	["creature"] = true,
}
