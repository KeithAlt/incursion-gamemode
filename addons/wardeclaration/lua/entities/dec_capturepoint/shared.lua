AddCSLuaFile( )
ENT.Type            = "anim"
ENT.Base            = "base_anim"
ENT.PrintName		= "Flag"
ENT.Author			= "Lenny"
ENT.Spawnable       = false
ENT.Category        = "Claymore Gaming : Declaration"

local radius = 300
local radiusSqrd = radius * radius
local renderDistance = 2500
local renderDistSqrd = renderDistance * renderDistance

function ENT:SetupDataTables()
    self:NetworkVar("Int", 1, "Faction")
    self:NetworkVar("Int", 2, "EnemyFaction")
    self:NetworkVar("Int", 3, "CaptureTime")

    self:NetworkVar("Bool", 1, "Capturing")
    self:NetworkVar("Bool", 2, "Contested")

    if SERVER then
        self:SetCaptureTime(30)
        self:SetContested(false)

        self:NetworkVarNotify( "Contested", self.ContestChange )
        self:NetworkVarNotify( "Capturing", self.CaptureChange )
        self:NetworkVarNotify( "Faction", self.UpdateFaction )
    end
end

function ENT:UpdateFaction(name, old, new)
    self:SetColor(nut.faction.indices[new].color or Color(255, 255, 255))
end

function ENT:Initialize()
    self:SetModel("models/sterling/flag.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_NONE)

    WARDECLARATION.Flags = WARDECLARATION.Flags or {}
    WARDECLARATION.Flags[#WARDECLARATION.Flags + 1] = self

    local index = self:EntIndex()
    local ent = self

    timer.Create(index .. "CapTimer", 1, 0, function()
        if not IsValid(ent) or ent:GetCaptureTime() <= 0 then
            timer.Remove(index .. "CapTimer")
            return
        end

        local instances = 0
        local contesters = 0
        for k, v in ipairs(ents.FindInSphere(ent:GetPos(), radius)) do
            if !v:IsPlayer() then continue end
            if !v:Alive() then continue end
            if !WARDECLARATION.IsInAttack(v:Team()) then print("not in attack") continue end
            if hcWhitelist.isCreature(v) then print("is creature") continue end
            if IsValid(pk_pills.getMappedEnt(v)) then print("pill exists") continue end
            if v:GetNWBool("StealthCamo") then print("is stealthed") continue end
            if v:InVehicle() then print("in vehicle") continue end

            if v:Team() == ent:GetFaction() or WARDECLARATION.Attacks.participants[ent:GetFaction()][v:Team()] then
                contesters = contesters + 1
            else
                instances = instances + 1
            end
        end

        if contesters == 0 and ent:GetContested() then
            ent:SetContested(false)
        elseif (instances >= 2 and contesters > 0) and !ent:GetContested() then
            ent:SetContested(true)
        end

        if instances < 2 then
            if ent:GetCaptureTime() != 30 then
                ent:SetCapturing(false)
                ent:SetCaptureTime(30)
            end

            if ent:GetCapturing() then
                ent:SetCapturing(false)
            end
        else
            if ent:GetContested() then return end
            local time = ent:GetCaptureTime() - 1
            local checkpoint = time % 10

            if checkpoint == 0 then
                if time > 0 then
                    jlib.Announce(player.GetAll(), Color(255,0,0), "[WAR] ", Color(255,255,255), "The " .. nut.faction.indices[ent:GetFaction()].name .. " point is being captured with " .. time .. " seconds remaining!")
                else
                    jlib.Announce(player.GetAll(), Color(255,0,0), "[WAR] ", Color(255,255,255), "The " .. nut.faction.indices[ent:GetFaction()].name .. " point has been captured!")

                    // add stop declaration here & other misc effects 
                    WARDECLARATION.EndAttack()
                    ent:Remove()
                end
            end

            ent:SetCaptureTime( ent:GetCaptureTime() - 1 )
            ent:SetCapturing(true)
        end
    end)
end

function ENT:OnRemove()
    table.RemoveByValue(WARDECLARATION.Flags, self)
end

function ENT:ContestChange( name, old, new )
    if old == new then return end

    if old then
        jlib.Announce(player.GetAll(), Color(255, 0, 0), "[WAR] ", Color(255, 255, 255), "The " .. nut.faction.indices[self:GetFaction()].name .. " point is no longer being contested!")
    else
        jlib.Announce(player.GetAll(), Color(255, 0, 0), "[WAR] ", Color(255, 255, 255), "The " .. nut.faction.indices[self:GetFaction()].name .. " point is being contested!")
    end
end

function ENT:CaptureChange(name, old, new)
    if old == new then return end

    local time = self:GetCaptureTime()


    if new then
        jlib.Announce(player.GetAll(), Color(255,0,0), "[WAR] ", Color(255,255,255), "The " .. nut.faction.indices[self:GetFaction()].name .. " is being captured! (30 seconds)")
    else
        jlib.Announce(player.GetAll(), Color(255,0,0), "[WAR] ", Color(255,255,255), "The " .. nut.faction.indices[self:GetFaction()].name .. " point has less than 2 capturers and has been reset.")
    end
end

if CLIENT then
    local cappoints = {}
    local nextWarning = 0

    function ENT:Initialize()  
        self.index = #cappoints + 1

        cappoints[self.index] = self

        self.color = nut.faction.indices[self:GetFaction()].color
    end

    function ENT:OnRemove()
        cappoints[self.index] = nil
    end


    hook.Add("HUDPaint", "HUDPaint_CapPoint", function()
		for i, ent in ipairs(cappoints) do
			if IsValid(ent) and ent:GetPos():DistToSqr(LocalPlayer():GetPos()) < radiusSqrd and WARDECLARATION.IsInAttack(LocalPlayer():Team()) then
				local captureTime = ent:GetCaptureTime()
                local capturing = ent:GetCapturing()
                local contested = ent:GetContested()

                if contested then
                    draw.SimpleText("Point is being contested!", "UI_Medium", ScrW() * .5 + 1, ScrH() * .08 + 1, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText("Point is being contested!", "UI_Medium", ScrW() * .5, ScrH() * .08, Color(180, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    break
                else
                    if (captureTime > 0 and capturing) then
                        draw.SimpleText("Capturing Point", "UI_Medium", ScrW() * .5 + 1, ScrH() * .05 + 1, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        draw.SimpleText("Capturing Point", "UI_Medium", ScrW() * .5, ScrH() * .05, nut.gui.palette.color_primary, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        
                        draw.SimpleText(captureTime .. "s", "UI_Medium", ScrW() * .5 + 1, ScrH() * .08 + 1, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        draw.SimpleText(captureTime .. "s", "UI_Medium", ScrW() * .5, ScrH() * .08, nut.gui.palette.color_primary, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                end

				break
			end
		end
	end)

    local color = Color(172, 172, 172)
    hook.Add("PostDrawOpaqueRenderables", "PostDrawOpaqueRenderables_CapturePoint", function()
        render.SetStencilWriteMask(0xFF)
        render.SetStencilTestMask(0xFF)
        render.SetStencilReferenceValue(0)
        render.SetStencilPassOperation(STENCIL_KEEP)
        render.SetStencilZFailOperation(STENCIL_KEEP)
        render.ClearStencil()

        render.SetStencilEnable(true)

        for k, v in ipairs(cappoints) do
            if !IsValid(v) or v:GetPos():DistToSqr(LocalPlayer():GetPos()) > renderDistSqrd then continue end
            local color = Color(172, 172, 172)
            local stage = v:GetCaptureTime()

            if stage == 30 then
                color = Color(172, 172, 172)
            elseif stage >= 20 and stage <= 29 then
                color = Color(0, 180, 0, 100)
            elseif stage >= 10 and stage <= 19 then
                color = Color(255, 115, 0)
            elseif stage >= 0 and stage <= 9 then
                color = Color(180, 0, 0)
            end
            
            if v:GetContested() then
                color = Color(172, 172, 172)
            end


            render.SetStencilReferenceValue(1)
            render.SetStencilCompareFunction(STENCIL_NEVER)
            render.SetStencilFailOperation(STENCIL_REPLACE)

            render.SetColorMaterial()
            render.DrawBox(v:GetPos(), Angle(0,0,0), Vector(-radius, -radius, 0), Vector(radius, radius, 10), color, true)

            render.SetStencilCompareFunction(STENCIL_EQUAL)
            render.SetStencilFailOperation(STENCIL_KEEP)

            render.SetColorMaterial()
            cam.Start3D()
                render.DrawSphere(v:GetPos(), radius, 25, 25, ColorAlpha(color, 100))
                render.DrawSphere(v:GetPos(), -radius, 25, 25, ColorAlpha(color, 100))
            cam.End3D()
        end

        render.SetStencilEnable(false)
    end)
end



