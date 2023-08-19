INSTITUTE = INSTITUTE or {}
util.AddNetworkString("INSTITUTE_BASEHANDLER")
util.AddNetworkString("INSTITUTE_CREATEBINDS")
util.AddNetworkString("INSTITUTE_RETRIEVESYNTH")

util.AddNetworkString("INSTITUTE_GOTOPRESS")
util.AddNetworkString("INSTITUTE_BRINGPRESS")
util.AddNetworkString("INSTITUTE_BRINGALL")

function INSTITUTE.AbductPlayer(courser, target)
    if not target:getNetVar("InstAbducted") then
        jlib.RequestBool("Abduct?", function(bool)
            if !bool then return end

            target.lastInstSpot = target:GetPos()
            INSTITUTE.CreateAbductEffect(target, function()
                target:setNetVar("restricted", true)
                target:SetPos(InstituteGetRelayPPos())
                target:setNetVar("InstAbducted", true)
            end, true)
            courser:falloutNotify("[!] You have sent your victim to the base.")
        end, courser, "Yes", "No")
    else
        jlib.RequestBool("Do you want to return them?", function(bool)
            if !bool then return end

            INSTITUTE.CreateTeleportEffectNoDistort(target, function()
                target:setNetVar("restricted", nil)
                target:SetPos(target.lastInstSpot or InstituteGetExitPPos())
                target:setNetVar("InstAbducted", nil)
                target.lastInstSpot = nil
            end)
            
            courser:falloutNotify("[!] You have returned your victim.")
        end, courser, "Yes", "No")
    end
end


function INSTITUTE.TeleportHome(ply)
    jlib.RequestBool("Return home?", function(bool)
        if !bool then return end

        local ent = ply:GetViewModel() or ply
        local effect = EffectData()
        effect:SetOrigin(ent:GetPos())
        util.Effect("vm_distort", effect)
        ply:EmitSound("Sonic_Mania/RedCube_L.wav")

        local tENTs = ents.FindInSphere(ply:GetPos(), 1500)
        for k, v in ipairs(tENTs) do
            if v:IsPlayer() and v != ply then
                v:SetVelocity( Vector( 0, 0, 260 ) )
                v:SetGravity( 0.3 )
                timer.Simple( 3, function() v:SetGravity( 1 ) end )
            end
        end

        timer.Simple(3, function()
            INSTITUTE.CreateTeleportEffectNoDistort(ply, function()
                ply:SetPos(InstituteGetRelayPPos())
                if ply:getNetVar("restricted") then
                    ply:setNetVar("restricted", nil)
                end
        
                if ply:HasWeapon("weapon_handcuffed") then
                    ply:StripWeapon("weapon_handcuffed")
                end            
            end)
        end)
    end, ply, "Yes", "No")
end

function INSTITUTE.TeleportLocation(courser, pos)
    courser:SetPos(pos)
    INSTITUTE.CreateTeleportEffectNoDistort(courser)
end

function INSTITUTE.Teleport(ply)
    if ply.nextINSTITUTETP and ply.nextINSTITUTETP > CurTime() then 
        ply:falloutNotify("[INSTITUTE] Your dash is not ready. ( " .. os.difftime(ply.nextINSTITUTETP, CurTime()) .. "s )" )
        return
    end

    local origin = ply:GetShootPos() + ply:GetForward() * 1000 
    local tr = util.TraceLine({
        start = origin + ply:GetUp() * 500,
        endpos = origin - ply:GetUp() * 5000,
    })

    INSTITUTE.CreateTeleportEffectNoDistort(ply, function()
        ply:SetPos(tr.HitPos + Vector(0, 0, 1))
        Psykers.TeleportEffectEnd(ply)
        if ply:getNetVar("restricted") then
            ply:setNetVar("restricted", nil)
        end

        if ply:HasWeapon("weapon_handcuffed") then
            ply:StripWeapon("weapon_handcuffed")
        end
    end)

    ply.nextINSTITUTETP = CurTime() + 6
end

function INSTITUTE.GetAllSynths()

    local synthList = {}

    for k, v in ipairs(player.GetAll()) do
        if v:IsSynth() then
            synthList[#synthList + 1] = v:getChar():getID()
        end
    end

    return synthList
end

concommand.Add("institute_abduct", function(ply)
    if !INSTITUTE.WhitelistedIDs[ply:SteamID()] then return end
    if nut.faction.indices[ply:Team()] and nut.faction.indices[ply:Team()].name != "Institute" then return end

    local tr = ply:GetEyeTrace()

    if IsValid(tr.Entity) and tr.Entity:IsPlayer() then
        INSTITUTE.AbductPlayer(ply, tr.Entity)
    end
end)

concommand.Add("institute_home", function(ply)
    if !INSTITUTE.WhitelistedIDs[ply:SteamID()] then return end
    if nut.faction.indices[ply:Team()] and nut.faction.indices[ply:Team()].name != "Institute" then return end

    INSTITUTE.TeleportHome(ply)
end)

concommand.Add("institute_dash", function(ply)
    if !INSTITUTE.WhitelistedIDs[ply:SteamID()] then return end
    if nut.faction.indices[ply:Team()] and nut.faction.indices[ply:Team()].name != "Institute" then return end

    INSTITUTE.Teleport(ply)
end)

net.Receive("INSTITUTE_BASEHANDLER", function(len, ply)
    ply:Freeze(true)
    INSTITUTE.CreateTeleportEffectNoDistort(ply, function()
        ply:Freeze(false)
        ply:Spawn()
    end)
end)

net.Receive("INSTITUTE_RETRIEVESYNTH", function(len, ply)
    if !INSTITUTE.WhitelistedIDs[ply:SteamID()] then return end

    net.Start("INSTITUTE_RETRIEVESYNTH")
        net.WriteTable(INSTITUTE.GetAllSynths())
    net.Send(ply)
end)

net.Receive("INSTITUTE_BRINGPRESS", function(len, ply)
    if !INSTITUTE.WhitelistedIDs[ply:SteamID()] then return end    
    local target = net.ReadEntity()

    INSTITUTE.CreateTeleportEffectNoDistort(target, function()
        target:SetPos(ply:GetPos() + ply:GetForward() * -100)
        INSTITUTE.CreateTeleportEffectNoDistort(target)
    end)
end)

net.Receive("INSTITUTE_GOTOPRESS", function(len, ply)
    if !INSTITUTE.WhitelistedIDs[ply:SteamID()] then return end 
    local target = net.ReadEntity()

    INSTITUTE.CreateTeleportEffectNoDistort(ply, function()
        ply:SetPos(target:GetPos() + target:GetForward() * -100)
        INSTITUTE.CreateTeleportEffectNoDistort(ply)
    end)
end)

net.Receive("INSTITUTE_BRINGALL", function(len, ply)
    if !INSTITUTE.WhitelistedIDs[ply:SteamID()] then return end    

    for k, v in ipairs(player.GetAll()) do
        if v == ply then continue end
        if v:IsSynth() then
            INSTITUTE.CreateTeleportEffectNoDistort(v, function()
                v:SetPos(ply:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 150)
                INSTITUTE.CreateTeleportEffectNoDistort(v)
            end)
        end
    end

end)

hook.Add("PlayerDeath", "INSTITUTE_AbductReset", function(ply)
    if ply:getNetVar("InstAbducted") then
        ply:setNetVar("InstAbducted", false)
    end
end)


/*
    add tiers to this later on,

    gen 1:
        2 end

    gen 2:
        4 end
        no hunger & rads

    gen 3:
        +25/50 hp
        no rads + no hunger
        + 5-6 end
*/

hook.Add("PlayerSpawn", "INSTITUTE_SynthBenefits", function(ply)
    if ply:IsSynth() and !ply:IsCourser() then
        timer.Simple(3, function()
            ply:SetMaxHealth( ply:GetMaxHealth() + 25 )
            ply:SetHealth( ply:GetMaxHealth() )
            
            -- copied from fallout_hunger
            ply.thirstbuff = 0
            ply.hungerbuff = 0
            ply:SprintEnable()
            ply:SetNWBool("noHunger", true)
            ply.isImmune = true
            
            ply:BuffStat("E", 5, -1)
            ply:falloutNotify("[SYNTH] Your frame enables enhanced behavior...")
        end)
    end
end)

hook.Add("PlayerLoadedChar", "INSTITUTE_LOADEDCOURSER", function(ply, char, oldChar)
    local class = nut.class.list[char:getClass()]
    if class and class.name == "Institute - Lead" then
        net.Start("INSTITUTE_CREATEBINDS")
        net.Send(ply)
    end
end)