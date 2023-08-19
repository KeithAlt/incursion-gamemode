LEADERPOWERS = LEADERPOWERS or {}
LEADERPOWERS.Duration = 120
LEADERPOWERS.List = {
    ["enclave"] = {
        specials = {["I"] = 3, ["A"] = 3},
        effect = nil,
        speedBuff = 5,
        snd = "enclavetheme.mp3",
    },
    ["ncr"] = {
        specials = {["P"] = 3, ["E"] = 3},
        effect = nil,
        dmgBuff = 5,
        snd = "ncrtheme.mp3", //"falloutradio/battle_hymn_of_republic.mp3",
    },
    ["legion"] = {
        specials = {["S"] = 10, ["P"] = 3, ["E"] = 3},
        effect = nil,
        snd = "legiontheme.mp3",
        loop = 12,
        dmgBuff = 5,
    },
    ["bos"] = {
        specials = {["I"] = 3, ["A"] = 3},
        effect = nil,
        speedBuff = 5,
        snd = "vj_fo3_libertyprime/agenda_usa.mp3",
    },
}

hook.Add("InitPostEntity", "LEADER_CreateCommands", function()
    nut.command.add("setleader", {
        syntax = "",
        superAdminOnly = true,
        onRun = function(ply)
            local target = ply:GetEyeTrace().Entity
            if !IsValid(target) or !target:IsPlayer() then target = ply end
            local leaderData = target:getChar():getData("leader", false)
            
            target:getChar():setData("leader", !leaderData)
            ply:notify("Set leader status of " .. target:getChar():getName() .. " to : " .. (!leaderData and "Active" or "Removed"))
        end
    })
end)