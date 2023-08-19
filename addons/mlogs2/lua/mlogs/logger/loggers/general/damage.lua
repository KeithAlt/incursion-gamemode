--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "general"
// Damage Logs
mLogs.addLogger("Damage","dmg",category)
mLogs.addHook("EntityTakeDamage", category, function(ply,dmg)
    if(not (IsValid(ply) and type(ply) == "Player" and dmg:GetDamage() != 0)) then return end
    local attacker = dmg:GetAttacker()
    local _inflictor = dmg:GetInflictor()
    if(not (IsValid(attacker) or attacker:IsWorld())) then return end
    if(ply:GetNWBool("SpecDM_Enabled") || attacker:GetNWBool("SpecDM_Enabled")) then return end
    
    local log = {player1=mLogs.logger.getPlayerData(ply),damage=tostring(math.Round(dmg:GetDamage()))}
    
    // World
    if(attacker:IsWorld())then
        log.attacker = mLogs.logger.getWorld()
    // Player
    elseif(type(attacker) == "Player")then
        //local wep = attacker:GetActiveWeapon()
        //local wepData = mLogs.logger.getWeaponData(wep)
        local wep = IsValid(_inflictor) and mLogs.logger.isEntType(type(_inflictor)) and _inflictor
            or attacker:GetActiveWeapon()
        local wepData = type(wep) == "Weapon" and mLogs.logger.getWeaponData(wep) or type(wep) == "Vehicle"
            and mLogs.logger.getVehicleData(wep) or mLogs.logger.getEntityData(wep)
        
        if(wepData) then
            log.inflictor = wepData
        end
        
        // Self harm
        if(ply == attacker)then
            log.attacker = "self"
        // Weapon
        else
            log.attacker = mLogs.logger.getPlayerData(attacker)
        end
    // Vehicle
    elseif(type(attacker) == "Vehicle")then
        local driver = attacker:GetDriver()
        log.inflictor = mLogs.logger.getVehicleData(attacker)
        if(IsValid(driver))then
            log.attacker = mLogs.logger.getPlayerData(driver)
        end
    // Entities
    elseif(mLogs.logger.isEntType(type(attacker)))then
        local entOwner = mLogs.getEntOwner(attacker)
        if(IsValid(entOwner))then
            log.owner = mLogs.logger.getPlayerData(entOwner)
        end
        log.inflictor = mLogs.logger.getEntityData(attacker)
    // Unknown ???
    else
        log.inflictor = mLogs.logger.getUnknown()
    end
    mLogs.log("dmg", category, log)
end)