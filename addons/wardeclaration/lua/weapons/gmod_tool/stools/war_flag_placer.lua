TOOL.Category = "War Declaration"
TOOL.Name = "War Flag Placer"
TOOL.Information = {
	"left",
	"right"
}

TOOL.ClientConVar["Faction"] = ""

if CLIENT then
	language.Add("tool.war_flag_placer.name", "War Flag Placer")
	language.Add("tool.war_flag_placer.desc", "Place or remove war flag locations")
    language.Add("tool.war_flag_placer.left", "Sets a faction's war flag")
    language.Add("tool.war_flag_placer.right", "Removes a faction's war flag")
	language.Add("tool.war_flag_placer.0", "")
end

function TOOL:LeftClick(trace)
    if !IsFirstTimePredicted() or !self:GetOwner():IsSuperAdmin() then return false end

    if SERVER then
        local faction = tonumber(self:GetClientInfo("Faction"))
        if !faction then return false end

        WARDECLARATION.Points[faction] = trace.HitPos
        WARDECLARATION.SavePoints()

        net.Start("WARDECLARATION_AddWarFlag")
            net.WriteInt(faction, 8)
        net.Send(self:GetOwner())

        self:GetOwner():notify("Set " .. nut.faction.indices[faction].name .. "'s flag position.")
    end

    return true
end

function TOOL:RightClick(trace)
	if !IsFirstTimePredicted() or !self:GetOwner():IsSuperAdmin() then return false end

    if SERVER then
        local dist
        local flag
        
        for id, pos in pairs(WARDECLARATION.Points) do
            local curDist = pos:Distance(trace.HitPos)
            
            if !dist or curDist < dist then
                dist = curDist
                flag = id
            end
        end
        
        WARDECLARATION.RemoveFlag(tonumber(flag), self:GetOwner())
    end

    return true
end

function TOOL:Deploy()
    if !IsFirstTimePredicted() then return end 
    if CLIENT then
        net.Start("WARDECLARATION_RequestFlagSpots")
        net.SendToServer()
    end
end

function TOOL:Holster(wep)

    if CLIENT then
        for k, v in pairs(WARDECLARATION.FlagModels or {}) do
            if !IsValid(v) then continue end
            v:Remove()
            WARDECLARATION.FlagModels[k] = nil
        end
    end

    return true
end

function TOOL:DrawHUD()
	if !self:GetOwner():IsSuperAdmin() then return end

    local choiceData = self:GetClientInfo("Faction")
    if choiceData != nil then
        local fac = nut.faction.indices[tonumber(choiceData)]
        if !fac then return end
        draw.SimpleText("Currently Selected: " .. fac.name, "UI_Bold", ScrW() * .5, ScrH() * .55, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    for fac, flag in pairs(WARDECLARATION.Points or {}) do
        if !isnumber(fac) then continue end
        local data = nut.faction.indices[fac]
        local pos = flag:ToScreen()

        if WARDECLARATION.FlagModels == nil then
            WARDECLARATION.FlagModels = {}
        end

        if WARDECLARATION.FlagModels[fac] == nil then
            local flagEx = ClientsideModel("models/sterling/flag.mdl")
            flagEx:SetPos(flag)
            flagEx:SetColor(data.color)
            WARDECLARATION.FlagModels[fac] = flagEx
        end

        draw.SimpleTextOutlined(data.name .. " - Flag", "UI_Bold", pos.x, pos.y, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0))
    end
end

function TOOL.BuildCPanel(panel)
	panel:SetName("War Flag Placer")
    panel:Help("Left click to set flag position for selected faction, right click to remove closest to crosshair.")

    local combo = panel:ComboBox("Faction", "war_flag_placer_Faction")
	for id, fac in pairs(nut.faction.indices) do
        if WARDECLARATION.Points != nil and WARDECLARATION.Points[id] != nil then continue end
		combo:AddChoice(fac.name, fac.index)
	end
end