local PLUGIN = PLUGIN
surface.CreateFont("Refinery3D2D", {font = "Roboto", size = 64, weight = 500})
include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    if ( not PLUGIN:InDistance(LocalPlayer():GetPos(), self:GetPos(), 650) ) then
        return
    end

    local activeMelts = self:getNetVar("activeMelts", {})
    local lowestEndTime
    local productToDisplay
    for k, product in pairs(activeMelts) do
        if ( not lowestEndTime or product.endTime < lowestEndTime ) then
            lowestEndTime = product.endTime
            productToDisplay = product
        end
    end

    if ( not productToDisplay ) then
        return
    end

    local ang = self:GetAngles()
    local pos = self:GetPos() - (ang:Forward() * 7) + (ang:Up() * 18) + (ang:Right() * 12)

    ang:RotateAroundAxis(ang:Right(), -90)
    ang:RotateAroundAxis(ang:Up(), 90)

    cam.Start3D2D(pos, ang, 0.05)
        surface.SetDrawColor(0, 0, 0, 200)
        jlib.DrawCircle(0, 0, 300, 25)

        surface.SetDrawColor(50, 100, 255, 255)
        jlib.DrawCircle(0, 0, 300, 25, math.min((CurTime() - item.startTime) / (item.endTime - item.startTime), 1))

        draw.SimpleText(nut.item.list[productToDisplay.item].name, "Refinery3D2D", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end