AddCSLuaFile()

if CLIENT then
    function pk_pills.join_prompt(name, addr)
        Derma_Query("Are you sure you want to join '" .. name .. "'?\nWARNING: You will exit your current game!", "", "Yes", function()
            LocalPlayer():ConCommand("connect " .. addr)
        end, "No")
    end
end
