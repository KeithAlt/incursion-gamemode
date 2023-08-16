local PLUGIN = PLUGIN


---------------
--[[ Fear  ]]--
---------------
function PLUGIN:ApplyFear(victim)
    victim:SetNW2Bool("nut_fearrp_is_under_fear", true)
end

function PLUGIN:RemoveFear(victim)
    victim:SetNW2Bool("nut_fearrp_is_under_fear", false)
end

function PLUGIN:GetFearResistance(ply)
    local char = ply:getChar()
    if (!char) then return false end

    local class = char:getClass()
    local faction = char:getFaction()

    if (class && nut.class.list[class].fearImmune) then
        return false
    elseif (faction && nut.faction.indices[faction].fearImmune) then
        return false
    else
        return ply.fearResist || nut.config.get("fearRPdefaultFearResist")
    end
end

function PLUGIN:GetFearPower(ply)
    return ply.fearPower || nut.config.get("fearRPdefaultFearPower")
end

function PLUGIN:GetPlayerFear(ply)
    if (!self.threatenedPlayers[ply]) then return false end -- false means the player is not threatened by anyone

    local totalFear
    for threatener, value in pairs(self.threatenedPlayers[ply]) do
        totalFear = (totalFear || 0) + value[1]
    end

    if (!totalFear) then return false end -- false means the player is not threatened by anyone

    return totalFear
end


---------------------
--[[ Threatening ]]--
---------------------
PLUGIN.threatenedPlayers = PLUGIN.threatenedPlayers or {}

function PLUGIN:ThreatenPlayer(inflictor, victim)
    local inflictor = inflictor
    local victim = victim

    -- Manage threatening
	self.threatenedPlayers[victim] = self.threatenedPlayers[victim] or {}
	self.threatenedPlayers[victim][inflictor] = {self:GetFearPower(inflictor), inflictor.fearrp_lifeUniqueIndex}
    victim:falloutNotify("You are being threatened!", "ui/notify.mp3")
    netstream.Start(inflictor, "nut_fearrp_threatener_add", victim)

    -- Manage fear state
    local fearResistance = self:GetFearResistance(victim)
    local totalFear = self:GetPlayerFear(victim)

	if (fearResistance && totalFear && totalFear >= fearResistance) then
        self:ApplyFear(victim)
	end


    -- Update threatening and fear state
    if (!timer.Exists("nut_fearrp_fear_check_"..victim:AccountID())) then
        timer.Create("nut_fearrp_fear_check_"..victim:AccountID(), 5, 0, function()
            -- Manage threatening
            for threatener, value in pairs(PLUGIN.threatenedPlayers[victim]) do
                if (!IsValid(threatener)) then

                    PLUGIN.threatenedPlayers[victim][threatener] = nil

                elseif (threatener.fearrp_lifeUniqueIndex != value[2] || !threatener:Alive() || (threatener:GetPos():Distance(victim:GetPos()) > nut.config.get("fearRPExitDistanceToSquare"))) then

                    netstream.Start(threatener, "nut_fearrp_threatener_remove", victim)
                    PLUGIN.threatenedPlayers[victim][threatener] = nil

                end
            end

            -- Manage fear state
            local fearResistance = PLUGIN:GetFearResistance(victim)
            local totalFear = PLUGIN:GetPlayerFear(victim)

            if (victim:GetNW2Bool("nut_fearrp_is_under_fear")) then
                if (!fearResistance || !totalFear || totalFear < fearResistance) then
                    PLUGIN:RemoveFear(victim)
                    victim:falloutNotify("You're no longer inflicted with fear", "ui/goodkarma.ogg")
                end
            elseif (fearResistance && totalFear && totalFear >= fearResistance) then
                PLUGIN:ApplyFear(victim)
            end

            if (!totalFear) then
                PLUGIN.threatenedPlayers[victim] = nil
                timer.Remove("nut_fearrp_fear_check_"..victim:AccountID())
            end
        end)
    end
end

function PLUGIN:RemoveThreateners(victim)
    if (self.threatenedPlayers[victim]) then
        for threatener, lifeUniqueIndex in pairs(PLUGIN.threatenedPlayers[victim]) do
            if (IsValid(threatener)) then

                netstream.Start(threatener, "nut_fearrp_threatener_remove", victim)
                PLUGIN.threatenedPlayers[victim][threatener] = nil

            end
        end
    end
end


---------------
--[[ Hooks ]]--
---------------
concommand.Add("+fearRP", function( ply, cmd, args )
    local trace = ply:GetEyeTrace()
    local ent = trace.Entity

    if (PLUGIN:CanThreatenPlayer(ply, ent)) then
        PLUGIN:ThreatenPlayer(ply, ent)
        ply:falloutNotify("Inflicting fear on target [" .. (PLUGIN:GetFearPower(ply) / PLUGIN:GetFearResistance(ent)) * 100 .. "%]", "vat_exit.mp3")
    end
end)

PLUGIN.lifeUniqueIndex = PLUGIN.lifeUniqueIndex || 0

function PLUGIN:PlayerSpawn(ply)
    ply.fearrp_lifeUniqueIndex = PLUGIN.lifeUniqueIndex
    PLUGIN.lifeUniqueIndex = PLUGIN.lifeUniqueIndex + 1
    self:RemoveFear(ply)
    self:RemoveThreateners(ply)
end

function PLUGIN:PostPlayerDeath(ply, attacker, dmg)
    self:RemoveFear(ply)
    self:RemoveThreateners(ply)
end

function PLUGIN:PlayerDisconnected(ply)
    self:RemoveFear(ply)
    self:RemoveThreateners(ply)
end
