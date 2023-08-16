include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    if LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 650 * 650 then
        return
    end

    local activeCooks = self:getNetVar("activeCooks", {})
    local lowestEndTime
    local item
    for k, cook in pairs(activeCooks) do
        if !lowestEndTime or cook.endTime < lowestEndTime then
            lowestEndTime = cook.endTime
            item = cook
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

        draw.SimpleText(foFood.Foods[item.item].name, "Cook3D2D", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

function ENT:StartFireEffect()
    if ( not self.fireActive ) then
        local pos = self:GetPos() + self:GetForward() * -40 + self:GetRight() * -5 + self:GetUp() * -15
        local ang = self:GetAngles()

        ParticleEffect("env_fire_tiny", pos, ang, self)

        self.fireActive = true
    end
end

function ENT:StopFireEffect()
    if ( self.fireActive ) then
        self:StopParticles()

        self.fireActive = false
    end
end

function ENT:OnRemove()
    self:StopParticles()
end

netstream.Hook("forpCookStartFire", function(ent)
    if ( not ent ) then return end

    ent:StartFireEffect()
end)

netstream.Hook("forpCookStopFire", function(ent)
    if ( not ent ) then return end

    ent:StopFireEffect()
end)