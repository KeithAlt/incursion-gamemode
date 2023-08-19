INSTITUTE = INSTITUTE or {}
INSTITUTE.WhitelistedIDs = 
{
    ["STEAM_0:0:68317481"] = true, // Keith
    ["STEAM_0:0:38833235"] = true, // Lenny
    ["STEAM_0:1:54271280"] = true, // Elliot
}

local meta = FindMetaTable("Player")

hook.Add("InitPostEntity", "INSTITUTE_SETUP", function()
    function meta:IsCourser()
        local char = self:getChar()
        if !char then return end 

        local class = char:getClass()
        if !class then return end

        local classData = nut.class.list[class]
        if !classData then return end

        local classCheck = classData.name == "Institute - Lead"
        
        return classCheck and INSTITUTE.WhitelistedIDs[self:SteamID()]
    end

    function meta:IsSynth()
        local char = self:getChar() 
        if !char then return false end

        local class = nut.class.list[char:getClass()]

        if char:getData("isSynth") then return true end

        if class and class.name == "Institute - Lead" then
            return true
        end

        return false
    end

    nut.command.add("revertsynth", {
        superAdminOnly = true,
        onRun = function(ply)
            local target = ply:GetEyeTrace().Entity
            if !IsValid(target) then return "No target found." end
    
            if target:getChar() and target:getChar():getData("isSynth") then
                target:getChar():setData("isSynth", nil)
                return "Reverted Synth status on " .. target:getChar():getName()
            else
                return "Your target is not a synth."
            end
        end
    })
end)


function INSTITUTE.CreateTeleportEffect(ply, callback, bFreeze)
    if bFreeze and SERVER then
        ply:Freeze(true)
    end

    local effect = EffectData()
    effect:SetOrigin(ply:GetShootPos())
    util.Effect("vm_distort", effect)
    ply:EmitSound("ambient/levels/labs/teleport_preblast_suckin1.wav", 100, 60)

    ParticleEffect("mr_energybeam_1", ply:GetShootPos() + Vector(0,0,300), Angle(-270,-0, -0), ply)
    ParticleEffect("_sai_wormhole", ply:GetShootPos(), Angle(-90), ply)
    ParticleEffect("mr_cop_anomaly_electra_a", ply:GetShootPos(), ply:GetAngles(), ply)
    ParticleEffectAttach("super_shlrd",PATTACH_POINT_FOLLOW, ply, 1)
    ply:EmitSound("npc/scanner/cbot_energyexplosion1.wav", 100, 100, 30)
    util.ScreenShake(ply:GetShootPos(), 25, 100, 2, 100)
    
    timer.Simple(1, function()
        ply:StopParticles()
        ply:EmitSound("Sonic_Mania/Attack6_R.wav")
        
        if bFreeze and SERVER then
            ply:Freeze(false)
        end
        
        if callback != nil then
            callback()
        end
    end)
end

function INSTITUTE.CreateAbductEffect(ply, callback, bFreeze)
    INSTITUTE.CreateTeleportEffect(ply, callback, bFreeze)
end

function INSTITUTE.CreateTeleportEffectNoDistort(ply, callback, bFreeze)
    if bFreeze then
        ply:Freeze(true)
    end

    ParticleEffect("mr_energybeam_1", ply:GetShootPos() + Vector(0,0,300), Angle(-270,-0, -0), ply)
    ParticleEffect("_sai_wormhole", ply:GetShootPos(), Angle(-90), ply)
    ParticleEffect("mr_cop_anomaly_electra_a", ply:GetShootPos(), ply:GetAngles(), ply)
    ParticleEffectAttach("super_shlrd",PATTACH_POINT_FOLLOW, ply, 0)
    ply:EmitSound("npc/scanner/cbot_energyexplosion1.wav", 100, 100, 30)
    util.ScreenShake(ply:GetShootPos(), 5, 100, 2, 100)
    
    timer.Simple(0.5, function()
        ply:StopParticles()
        
        if bFreeze then
            ply:Freeze(false)
        end
        
        if callback != nil then
            callback()
        end
    end)
end