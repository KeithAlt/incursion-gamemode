PLUGIN.name = "FearRP"
PLUGIN.author = "github.com/John1344"
PLUGIN.desc = "FearRP infliction system"

-----------------------
--[[ Plugin Config ]]--
-----------------------
PLUGIN.NON_THREATENING_WEAPONS = {
	nut_hands = true,
	nut_keys = true,
    weapon_physcannon = true,
    nut_areahelper = true,
    nut_poshelper = true,
    gmod_camera = true,
    weapon_medkit = true,
    gmod_tool = true,
    weapon_physgun = true
}


---------------------
--[[ Threatening ]]--
---------------------
function PLUGIN:IsPlayerAlreadyThreatened(victim, threatener)
    if CLIENT then
        return self.threatenedPlayers[victim]
    elseif SERVER then
        return (self.threatenedPlayers[victim] && self.threatenedPlayers[victim][threatener] != nil)
    end
end

function PLUGIN:CanThreatenPlayer(threatener, victim)
	local activeWeapon = threatener:GetActiveWeapon()

	return (victim:IsPlayer() && !self:IsPlayerAlreadyThreatened(victim, threatener) && IsValid(activeWeapon) && !self.NON_THREATENING_WEAPONS[activeWeapon:GetClass()] && threatener:isWepRaised() && threatener:GetPos():Distance(victim:GetPos()) < nut.config.get("fearRPDistance"))
end


-----------------------
--[[ Ingame config ]]--
-----------------------
nut.config.add("fearRPDistance", 500, "A distance value of how far a player needs to be to invoke FearRP on another", nil,
{
    data = {min = 1, max = 2000},
    category = "fearRp"
})

nut.config.add("fearRPExitDistanceToSquare", 1200, "A distance value of how far a scared player needs to be to exit FearRP", nil,
{
    data = {min = 1, max = 20000},
    category = "fearRp"
})

nut.config.add("fearRPdefaultFearResist", 1, "The default threshold at which a player is under FearRP", nil,
{
    data = {min = 1, max = 20000},
    category = "fearRp"
})

nut.config.add("fearRPdefaultFearPower", 0.5, "The default power of the fear induced by a player", nil,
{
    data = {min = 0, max = 10},
    category = "fearRp"
})

nut.util.include("sv_plugin.lua")
nut.util.include("cl_plugin.lua")
