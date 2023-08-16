WARDECLARATION = WARDECLARATION or {}
WARDECLARATION.Points = WARDECLARATION.Points or {}

/*
    Creates a timer that checks if the player can see the enemy's base
    with a minimum distance to prevent chain-respawning

    This only supports hostilities as of current.
*/
function WARDECLARATION.CreateBaseChecker()

    local ply = LocalPlayer()
    local isinAttack = WARDECLARATION.IsInAttack(ply:Team())
    local isCuffed = LocalPlayer():IsHandcuffed()
    if ply:getNetVar("restricted") or isCuffed or ply:getNetVar("enslaved") then return end
    if !isinAttack then return end

    local enemy
    if WARDECLARATION.Attacks.calling == ply:Team() then
        enemy = WARDECLARATION.Attacks.enemy
    else
        enemy = WARDECLARATION.Attacks.calling
    end

    if timer.Exists("BASE_CHECKER") then timer.Remove("BASE_CHECKER") end

    local enemyBase
    for k, v in pairs(Areas.Instances) do
        if v.FactionUID == nut.faction.indices[enemy].uniqueID then
            enemyBase = v
            break
        end
    end
    local ownBase
    for k, v in pairs(Areas.Instances) do
        if v.FactionUID == nut.faction.indices[ply:Team()].uniqueID then
            ownBase = v
            break
        end
    end

    if !enemyBase or !ownBase then return end

    // calculate this beforehand, no need to do every second.
    local ownCenter = ownBase:GetCenter()
    local enemyCenter = enemyBase:GetCenter()
    local baseDistance = enemyCenter:DistToSqr(ownCenter)
    
    local baseDistanceMinimum = 8000*8000
    local distSquared = 6500*6500
    local executeDist = 6000*6000

    if baseDistance < baseDistanceMinimum then print("base distance too short, returning") return end
    
    local nextWarning = CurTime()
    local warningReceived = 0

    local shootSounds = {
        "m2/50cal_fire.wav",
        "m14/fire.mp3",
        "holorifle/shoot.mp3",
        "44magnum/fire.ogg",
        "weapons/lasercannon_fire.mp3",
    }

    timer.Create("BASE_CHECKER", 3, 0, function()
        local dist = LocalPlayer():GetPos():DistToSqr(enemyCenter)
        if !LocalPlayer():Alive() then return end
        if !WARDECLARATION.IsInAttack(ply:Team()) then return end

        if dist < distSquared and dist > executeDist and nextWarning < CurTime() then

            if warningReceived > 1 then
                vgui.Create("nutFalloutNotice"):open("You walked too close . . .")

                local effect = EffectData()
                effect:SetOrigin(ply:GetShootPos())
                effect:SetStart(ply:GetShootPos() + ply:GetForward() * 500)
                effect:SetEntity(ply)
                util.Effect("AR2Tracer", effect)
    
                surface.PlaySound(shootSounds[math.random(#shootSounds)])
    
                net.Start("WARDECLARATION_HOSTILITIESRESET")
                net.SendToServer()

                warningReceived = 0
            else
                vgui.Create("nutFalloutNotice"):open("You are too close to their base, move back now.", "fallout/ui/ui_char_load.wav")
                nextWarning = CurTime() + 10
                warningReceived = warningReceived + 1
            end

            return
        elseif dist < executeDist then
            vgui.Create("nutFalloutNotice"):open("You walked too close . . .")

            local effect = EffectData()
            effect:SetOrigin(ply:GetShootPos())
            effect:SetStart(ply:GetShootPos() + ply:GetForward() * 500)
            effect:SetEntity(ply)
            util.Effect("AR2Tracer", effect)

            surface.PlaySound(shootSounds[math.random(#shootSounds)])

            net.Start("WARDECLARATION_HOSTILITIESRESET")
            net.SendToServer()
        end

    end)
end
net.Receive("WARDECLARATION_UPDATEUI", function()
    local tbl = jlib.ReadCompressedTable()

    WARDECLARATION.Attacks = tbl

    if WARDECLARATION.Attacks.type == "Hostilities" then
        WARDECLARATION.CreateBaseChecker()
    end

    if table.Count(WARDECLARATION.Attacks) >= 1 then
        if IsValid(WARDECLARATIONUI) then return end-- We do not want a duplicate UI element
        
        WARDECLARATIONUI = vgui.Create("WARUI")
        local time = WARDECLARATION.Attacks.time
        local startTime = WARDECLARATION.Attacks.starttime
        local currentTime = os.time()
        WARDECLARATIONUI:SetTime( time - (os.difftime(startTime, currentTime) * -1) )
    else
        if IsValid(WARDECLARATIONUI) then
            WARDECLARATIONUI.Fadingout = true

            WARDECLARATIONUI:AlphaTo(0, 1, 0, function()
                WARDECLARATIONUI:Remove()
            end)
        end

        // Remove hostilities distance checker
        if timer.Exists("BASE_CHECKER") then timer.Remove("BASE_CHECKER") end
    end
end)

net.Receive("WARDECLARATION_LEAVESKIRMISH", function()
    local fac = net.ReadInt(8)
    local factions = net.ReadTable()

    WARDECLARATIONUI:RemoveAssister(fac)

    WARDECLARATION.Attacks.participants[fac] = nil
end)

net.Receive("WARDECLARATION_ADDTEAM", function()
    local new = net.ReadInt(8)

    if WARDECLARATION.Attacks.participants == nil then
        WARDECLARATION.Attacks.participants = {}
    end

    WARDECLARATION.Attacks.participants[new] = {}
    WARDECLARATIONUI:AddMainFaction(new)
end)

net.Receive("WARDECLARATION_ATTACKEND", function()
    if IsValid(WARDECLARATIONUI) then
        WARDECLARATIONUI:Remove()
    end
end)

net.Receive("WARDECLARATION_ADDASSISTER", function()
    if not IsValid(WARDECLARATIONUI) then return end
    local side = net.ReadInt(8)
    local faction = net.ReadInt(8)

    WARDECLARATION.Attacks.participants[side][faction] = true
    WARDECLARATIONUI:AddAssister(side, faction)
end)

net.Receive("WARDECLARATION_REMOVEASSISTER", function()
    if not IsValid(WARDECLARATIONUI) then return end
    local faction = net.ReadInt(8)

    WARDECLARATIONUI:RemoveAssister(faction)

    for k, v in pairs(WARDECLARATION.Attacks.participants) do
        if v[faction] then
            v[faction] = nil
            break
        end
    end
end)

net.Receive("WARDECLARATION_ATTACKCONFIRMATION", function()
    local typ = net.ReadString()
    local target = net.ReadInt(8)
    local facname = nut.faction.indices[target].name

    local frame = vgui.Create("UI_DFrame")
    frame:ShowCloseButton(false)
    frame:SetSize(ScrW() * .3, ScrH() * .3)
    frame:SetTitle("Attack Confirmation - " .. typ)
    frame:Center()
    frame:MakePopup()

    local explanation = vgui.Create("DLabel", frame)
    explanation:SetText("Are you sure this is your target?")
    explanation:SetExpensiveShadow(3)
    explanation:SetContentAlignment(5)
    explanation:SetFont("UI_Bold")
    explanation:Dock(TOP)
    explanation:DockMargin(0, frame:GetTall() * .3, 0, 15)
    explanation:SetAutoStretchVertical(true)

    local factionName = vgui.Create("DLabel", frame)
    factionName:SetText(facname)
    factionName:SetExpensiveShadow(3)
    factionName:SetContentAlignment(8)
    factionName:SetFont("BuyMenu")
    factionName:SetTextColor(Color(255, 100, 100, 255))
    factionName:Dock(TOP)
    factionName:SetAutoStretchVertical(true)

    local confirm = vgui.Create("UI_DButton", frame)
    confirm:SetWide(frame:GetWide() * .2)
    confirm:SetTall(40)
    confirm:SetText("Confirm")
    confirm:SetPos(frame:GetWide() * .5 - confirm:GetWide(), frame:GetTall() * .8)
    confirm:SetContentAlignment(5)
    confirm.DoClick = function()
        net.Start("WARDECLARATION_ATTACKCONFIRMATION")
            net.WriteInt(target, 8)
            net.WriteString(typ)
        net.SendToServer()

        frame:Close()
    end

    local cancel = vgui.Create("UI_DButton", frame)
    cancel:SetWide(frame:GetWide() * .2)
    cancel:SetTall(40)
    cancel:SetText("Cancel")
    cancel:MoveRightOf(confirm, 5)
    cancel:SetContentAlignment(5)
    cancel:SetY(frame:GetTall() * .8)
    cancel.DoClick = function()
        frame:Remove()
    end
end)

-- Battle ambient battle sound effects
net.Receive("WARDECLARATION_BATTLEAMBIENCE", function()
	local battleNotice = {
		[0] = "Blistering sounds of gunfire echo across the wasteland . . .",
		[1] = "Sounds of a large battle ring across the wasteland . . .",
		[2] = "Death & destruction can be heard in the air . . .",
		[3] = "Gunshots & lasers can be heard whizzing in the distance . . .",
	}

	for i = 3, 1, -1 do
		timer.Simple(i * 1.2, function()
			sound.Play("ambient/levels/streetwar/city_battle" .. math.random(1,10) .. ".wav", LocalPlayer():GetPos() + Vector(500,500,500), 75, 100, 1)
		end)
	end

	timer.Simple(1.5, function()
		chat.AddText(Color(255, 150, 0), battleNotice[math.random(0,3)])
	end)
end)

net.Receive("WARDECLARATION_RequestFlagSpots", function()
    local points = jlib.ReadCompressedTable()

    WARDECLARATION.Points = points
end)

net.Receive("WARDECLARATION_AddWarFlag", function()
    local flag = net.ReadInt(8)

    if WARDECLARATION.FlagModels == nil then
        WARDECLARATION.FlagModels = {}
    end

    if IsValid(WARDECLARATION.FlagModels[flag]) then
        WARDECLARATION.FlagModels[flag]:Remove()
    end

    local pos = LocalPlayer():GetEyeTrace().HitPos
    local flagEx = ClientsideModel("models/sterling/flag.mdl")
    flagEx:SetPos(LocalPlayer():GetEyeTrace().HitPos)
    flagEx:SetColor(nut.faction.indices[flag].color)
    WARDECLARATION.FlagModels[flag] = flagEx

    WARDECLARATION.Points[flag] = pos
end)

net.Receive("WARDECLARATION_RemoveWarFlag", function()
    local flag = net.ReadInt(8)

    WARDECLARATION.FlagModels[flag]:Remove()
    WARDECLARATION.FlagModels[flag] = nil

    WARDECLARATION.Points[flag] = nil

    nut.util.notify("Removed " .. nut.faction.indices[flag].name .. "'s flag.")
end)