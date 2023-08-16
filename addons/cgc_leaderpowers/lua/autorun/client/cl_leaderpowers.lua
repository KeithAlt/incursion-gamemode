LEADERPOWERS = LEADERPOWERS or {}

net.Receive("LEADER_CREATEBINDS", function()
    jSettings.AddBinder("Binds", "Leader Boost", {"leaderpower_use"})
    
    vgui.Create("nutFalloutNotice"):open("[LEADER] Created binds.", "fallout/ui/ui_char_new.wav")
end)

surface.CreateFont( "WARHORNFONT", {
	font = "Akbar",
	extended = true,
	size = ScreenScale(40),
	weight = 500,
} )

surface.CreateFont( "WARHORNFONT_BG", {
	font = "Akbar",
	extended = true,
	size = ScreenScale(45),
	weight = 500,
} )

local PANEL = {}
local statNames = {
	["S"] = "Strength",
	["P"] = "Perception",
	["E"] = "Endurance",
	["C"] = "Charisma",
	["I"] = "Intelligence",
	["A"] = "Agility",
	["L"] = "Luck"
}

function PANEL:Init()
    LeaderUI = self

    local x, y = ScrW(), ScrH()
    self:SetSize(x, y)

    local fac = nut.faction.indices[LocalPlayer():Team()]
    if !fac then return end
    local id = fac.uniqueID

    local data = LEADERPOWERS.List[id]
    if !data then return end

    local teamCol = team.GetColor(LocalPlayer():Team())

    chat.AddText(teamCol, "[FACTION LEADER PRESENCE]")
    chat.AddText(teamCol, "> ", Color(255, 255, 255), "- You feel inspired by the presence of your Faction Leader in combat")
    for k, v in pairs(data.specials) do
        chat.AddText(teamCol, "> ", Color(255, 255, 255), "- You gain +" .. v .. " " .. statNames[k])
    end

    if data.speedBuff then
        chat.AddText(teamCol, "> ", Color(255, 255, 255), "- You gain a ", data.speedBuff, "% speed boost.")
    end

    if data.dmgBuff then
        chat.AddText(teamCol, "> ", Color(255, 255, 255), "- You gain a ", data.dmgBuff, "% damage buff.")
    end

    if data.drBuff then
        chat.AddText(teamCol, "> ", Color(255, 255, 255), "- You gain a ", data.drBuff, "% damage resistance buff.")
    end

    chat.AddText(teamCol, "> ", Color(255, 255, 255), "- Don't let your leader down...")

    timer.Create("LeaderUI", LEADERPOWERS.Duration, 1, function()
        self:AlphaTo(0, 2, 0, function()
            if IsValid(self) then
                chat.AddText(teamCol, "[FACTION LEADER PRESENCE]")
                chat.AddText(teamCol, "> ", Color(255, 255, 255), "- The inspiring presence of your Faction Leader wears off")
                chat.AddText(teamCol, "> ", Color(255, 255, 255), "- You lived to fight another day...")
        
                self:Remove()
            end
        end)
    end)
end

function PANEL:OnRemove()
    timer.Remove("LeaderUI")
end

function PANEL:Think()
    if not LocalPlayer():Alive() then
        self:Remove()
    end
end

local vig = Material("materials/nutscript/gui/vignette.png")
function PANEL:Paint(w, h)
    local col = ColorAlpha(team.GetColor( LocalPlayer():Team() ), 25)
    surface.SetDrawColor(col)
    surface.SetMaterial(vig)
    surface.DrawTexturedRect(0, 0, w, h)
    
    if timer.Exists("LeaderUI") then
        local val = math.floor(timer.TimeLeft("LeaderUI"))
        if val == -1 then return end

        draw.SimpleText(val, "WARHORNFONT", w * .5, h * .1, team.GetColor(LocalPlayer():Team()), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(val, "WARHORNFONT_BG", w * .5, h * .1, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

vgui.Register("LeaderUI", PANEL, "DPanel")

net.Receive("LEADER_OPENUI", function()
    if IsValid(LeaderUI) then
        LeaderUI:Remove()
    end
    
    LeaderUI = vgui.Create("LeaderUI")
end)