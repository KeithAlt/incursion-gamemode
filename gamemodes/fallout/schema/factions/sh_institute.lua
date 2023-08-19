FACTION.name = "Institute"
FACTION.desc = "A hyper advanced assication oriented toward android based research and development."
FACTION.color = Color(255, 63, 0)
FACTION.isDefault = false
FACTION.weapons = {"weapon_fo4instituterif_nope", "weapon_emerald", "weapon_instituterelay"}

FACTION.Radio = {
	["Color"] = Color(0, 208, 225, 255), --The color that the message will appear in
	["Sounds"] = { --One of these sounds will be randomly chosen and played when a message is sent
		"ambient/levels/prison/radio_random1.wav",
		"ambient/levels/prison/radio_random2.wav",
		"ambient/levels/prison/radio_random3.wav",
		"ambient/levels/prison/radio_random4.wav",
		"ambient/levels/prison/radio_random5.wav",
		"ambient/levels/prison/radio_random6.wav",
		"ambient/levels/prison/radio_random7.wav",
		"ambient/levels/prison/radio_random8.wav",
		"ambient/levels/prison/radio_random9.wav",
		"ambient/levels/prison/radio_random10.wav",
		"ambient/levels/prison/radio_random11.wav",
		"ambient/levels/prison/radio_random12.wav",
		"ambient/levels/prison/radio_random13.wav",
		"ambient/levels/prison/radio_random14.wav",
		"ambient/levels/prison/radio_random15.wav",
	},
	["Volume"] = {90, 100}, --The volume of the sound will be a random number between these two numbers
	["Pitch"] = {80, 120}, --The pitch of the sound will be a random number between these two numbers
	["Censor"] = true --Whether or not to censor the message for non-faction members
}

FACTION.mdls = {
	["male"] = {
		"models/arachnit/fallout4/synths/synthgeneration1.mdl",
	},
}

FACTION.models = {}

for i, v in pairs(FACTION.mdls["male"]) do
	FACTION.models[#FACTION.models + 1] = v
end;

FACTION.karma = {
	kill = {1, 3},
	passive = {20, 10},
}

FACTION_INSTITUTE = FACTION.index

function FACTION:onSpawn(client)
	client:SetMaxHealth(500)
    client:SetHealth(500)
end
