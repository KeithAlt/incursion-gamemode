local pkActive = false
local pkTime = 0
local pkcharID = 0
net.Receive("MUGGING_DISPLAYTIMER", function()
    local time = net.ReadUInt(16)
    if !time then return end

    pkcharID = LocalPlayer():getChar():getID() 
    pkActive = true
    pkTime = CurTime() + time
end)

local color = WARDECLARATION.BaseColor
hook.Add("HUDPaint", "MUGGING_DrawTimer", function()
    if LocalPlayer():getChar() != nil and pkActive and pkcharID == LocalPlayer():getChar():getID() then
        local newTime = math.floor( pkTime - CurTime() )
        if newTime <= 0 or not LocalPlayer():Alive() then
            pkActive = false
        end

        draw.SimpleTextOutlined("PK Active - " .. math.floor( pkTime - CurTime() ) .. "s", "WARFONT_MASSIVE", ScrW() * .06, ScrH() * .3, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
    end
end)