FACTION.name = "Mole Miner"
FACTION.desc = "A bleak remnant of Appalachia's storied past, the mole miners are humans that make their homes in the many caves and mines of the region, trapped within their deteriorating mining suits."
FACTION.color = Color(255, 74, 74)
FACTION.isDefault = false
FACTION.NotAttackable = true -- Faction is not attackable via war declaration system

FACTION.Radio = {
	["Color"] = Color(50, 255, 50, 255), --The color that the message will appear in
	["Sounds"] = { --One of these sounds will be randomly chosen and played when a message is sent
		"radio/moleman-1.wav",
		"radio/moleman-2.wav",
		"radio/moleman-3.wav",
		"radio/moleman-4.wav",
	},
	["Volume"] = {60, 70}, --The volume of the sound will be a random number between these two numbers
	["Pitch"] = {80, 120}, --The pitch of the sound will be a random number between these two numbers
	["Censor"] = true --Whether or not to censor the message for non-faction members
}
FACTION.mdls = {
	["moleman"] = {
		"models/player/keitho/MoleMiner01.mdl",
	}
}

FACTION.models = {}

for i, v in pairs(FACTION.mdls["moleman"]) do
	FACTION.models[#FACTION.models + 1] = v
end;

function FACTION:onSpawn(client)
	if SERVER then
	client:SetMaxHealth(1700)
    client:SetHealth(1700)
	client:falloutNotify("You are playing as an optional KOS Creature", "ui/notify.mp3")
	client:SetNoTarget(true)
	end
	if CLIENT then
		chat.AddText(Color(255, 0, 0), "WARNING:", Color(255,255,255), " You are playing as a Moleman!", Color(255,80,80), "The Following Apply:")
		chat.AddText(Color(255,0,0), "· ", Color(255,255,255), "You cannot use or equip items that are not Molemen Based")
		chat.AddText(Color(255,0,0), "· ", Color(255,255,255), "You must RP / Play as a Molemen; no FailRP")
		chat.AddText(Color(255,0,0), "· ", Color(255,255,255), "Abusing any Equipment even as a joke is not tolerated")
	end
end

FACTION.karma = {
	kill = {1, 3},
	passive = {25, 5},
}

FACTION_MOLEMEN = FACTION.index
