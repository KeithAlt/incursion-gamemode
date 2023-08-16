LEADERPOWERS = LEADERPOWERS or {}
util.AddNetworkString("LEADER_CREATEBINDS")
util.AddNetworkString("LEADER_OPENUI")

local InspireCooldown = 350
// Loop through, buff
function LEADERPOWERS.Inspire(ply, data)
    if !ply:getChar() or !ply:getChar():getData("leader") then return end

    if ply.buffCooldown and ply.buffCooldown > CurTime() then
        ply:falloutNotify("[LEADER] Your leader buff is on cooldown [ " .. math.floor(ply.buffCooldown - CurTime()) .. "s ]")
        return
    end
    ply.buffCooldown = CurTime() + InspireCooldown

    local members = team.GetPlayers(ply:Team())
    for _, member in ipairs(members) do
        if member:GetMoveType() == MOVETYPE_NOCLIP then continue end
        //if member:getLocalVar("leaderBuffed") then continue end // prevent stacking

        for special, amount in pairs(data.specials) do
            member:BuffStat(special, amount, LEADERPOWERS.Duration)
        end

        member:setLocalVar("leaderBuffed", true)

        if data.drBuff then 
            print("added dr boost")
            member:AddDR(data.drBuff, LEADERPOWERS.Duration)
        end

        if data.speedBuff then 
            print("added speed boost")
            member:AddSpeed(data.speedBuff, LEADERPOWERS.Duration)
        end

        if data.dmgBuff then 
            print("added dmg boost")
            member:AddDMG(data.dmgBuff, LEADERPOWERS.Duration)
        end

        if data.effect then
            timer.Simple(0.4, function()
                ParticleEffectAttach(data.effect, PATTACH_POINT_FOLLOW, member, 0)
            end)
        end

        if data.snd then
            member:EmitSound(data.snd)

            if data.loop != nil then
                timer.Create(member:EntIndex() .. "-LeaderBuff", data.loop, 0, function()
                    if !IsValid(member) then
                        timer.Remove(member:EntIndex() .. "-LeaderBuff")
                        return
                    end

                    member:StopSound(data.snd)
                    timer.Simple(.1, function()
                        member:EmitSound(data.snd)
                    end)
                end)
            end
        end

        timer.Simple(LEADERPOWERS.Duration, function()
            if IsValid(member) then
                member:setLocalVar("leaderBuffed", nil)
                member:StopSound(data.snd)
                member:StopParticles()
                timer.Remove(member:EntIndex() .. "-LeaderBuff")
            end
        end)

        net.Start("LEADER_OPENUI")
        net.Send(member)
    end
end

hook.Add("PlayerDeath", "LEADER_RemoveSound", function(ply)
    if ply:getLocalVar("leaderBuffed") then
        timer.Remove(ply:EntIndex() .. "-LeaderBuff")

        local fac = nut.faction.indices[ply:Team()]
        if !fac then print("no fac") return end
        local id = fac.uniqueID
    
        local data = LEADERPOWERS.List[id]
        if !data then print("no fac data") return end

        print("ran this")
    
        ply:StopSound(data.snd)
    end
end)

hook.Add("ScalePlayerDamage", "WARHORN_DECAP", function(ply, hit, info)
    local attacker = info:GetAttacker()
    local fac = nut.faction.indices[attacker:Team()]

    if attacker:getLocalVar("leaderBuffed") and IsValid(ply) and IsValid(attacker) and fac and fac.uniqueID == "legion" then
        print("weedtest")
        timer.Simple(.1, function()
            if !ply:Alive() then
                Dismemberment.QuickDismember(ply, HITGROUP_HEAD, attacker)
            end
        end)
    end
end)

hook.Add("PlayerLoadedChar", "LEADER_LOADEDLEADER", function(ply, char, oldChar)
    if char:getData("leader") then
        net.Start("LEADER_CREATEBINDS")
        net.Send(ply)
    end
end)

concommand.Add("leaderpower_use", function(ply)
    if !ply:getChar() or !ply:getChar():getData("leader") then return end

    local fac = nut.faction.indices[ply:Team()]
    if !fac then return end
    local id = fac.uniqueID

    local data = LEADERPOWERS.List[id]
    if !data then return end

    LEADERPOWERS.Inspire(ply, data)
end)
