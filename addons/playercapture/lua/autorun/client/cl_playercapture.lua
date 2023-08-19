local isFreeing = false
local totalTime = -1

net.Receive("playercapture_startFree", function() --Net message received from server when the ent is used
    totalTime = net.ReadInt(16)
    timer.Create("playercapture_freeTimer", totalTime, 1, function()
        isFreeing = false
    end)
    isFreeing = true
end)

net.Receive("playercapture_haltFree", function()
    isFreeing = false
    timer.Remove("playercapture_freeTimer")
end)

hook.Add("HUDPaint", "playercapture_freeTimer", function() --Draw the progression bar
    if !isFreeing or totalTime == -1 then return end

    local centerX = ScrW()/2
    local centerY = ScrH()/2
    local w = 300
    local h = 45

    surface.SetDrawColor(0, 0, 0, 100)
    surface.DrawRect(centerX - (w/2), centerY + h, w, h)

    surface.SetDrawColor(66, 134, 244, 255)
    surface.DrawRect((centerX - (w/2)) + 4, (centerY + h) + 4, (w - 8) * (1 - (timer.TimeLeft("playercapture_freeTimer")/totalTime)), h - 8)

    surface.SetFont("Trebuchet24")
    local textW, textH = surface.GetTextSize("Freeing...")
    surface.SetTextPos(centerX - (textW/2), centerY + (textH/2) + h)
    surface.SetTextColor(255,255,255,255)
    surface.DrawText("Freeing...")
end)