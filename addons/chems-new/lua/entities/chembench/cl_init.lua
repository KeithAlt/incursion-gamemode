include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    if LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 650 * 650 then
        return
    end

    local activeCrafts = self:getNetVar("activeCrafts", {})
    local lowestEndTime
    local item
    for k, craft in pairs(activeCrafts) do
        if !lowestEndTime or craft.endTime < lowestEndTime then
            lowestEndTime = craft.endTime
            item = craft
        end
    end

    if !item then
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

        draw.SimpleText(jChems.Chems[item.item].name, "Chems3D2D", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end