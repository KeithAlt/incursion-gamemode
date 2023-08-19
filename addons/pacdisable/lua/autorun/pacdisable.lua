hook.Add("InitPostEntity", "PACEnable", function()
    nut.command.add("pacenable", {
        onRun = function(ply)
            ply:ConCommand("pac_enable 1")
        end
    })
end)

if CLIENT then
    hook.Add("InitPostEntity", "PACDisable", function()
        if !tobool(LocalPlayer():GetPData("pacdisable", false)) then
            timer.Simple(5, function()
                RunConsoleCommand("pac_enable", "0")
                LocalPlayer():SetPData("pacdisable", true)
                chat.AddText("PAC has been disabled to boost performance. If you would like to re-enable it type /pacenable in chat.")
            end)
        end
    end)
end