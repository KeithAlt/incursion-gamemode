--Hunter/Customer interaction
function BountyHunting.SetBountyMenu(hunter)
    local frame = vgui.Create("DFrame")
    frame:SetSize(400, 600)
    frame:MakePopup()
    frame:SetTitle("Bounty Hunter Negotiation")
    frame:Center()
    frame:SetSkin("Dark")

    local targetChoiceLbl = frame:Add("DLabel")
    targetChoiceLbl:SetText("Choose your target")
    targetChoiceLbl:SetFont("DarkSkinMedium")
    targetChoiceLbl:SetTextColor(DarkSkin.TextColor)
    targetChoiceLbl:SizeToContents()
    targetChoiceLbl:SetPos(0, 30)
    targetChoiceLbl:CenterHorizontal()

    local players = {}

    for i, ply in ipairs(player.GetAll()) do
        if ply != LocalPlayer() and ply != hunter and !IsValid(ply:GetHunter()) then
            table.insert(players, ply)
        end
    end

    local targetDisplay = frame:Add("DModelPanel")
    targetDisplay:SetSize(160, 160)
    targetDisplay:MoveBelow(targetChoiceLbl, 10)
    targetDisplay:CenterHorizontal()
    targetDisplay.SetTarget = function(s, target)
        targetDisplay:SetModel(target:GetModel())
        local headPos = targetDisplay.Entity:GetBonePosition(targetDisplay.Entity:LookupBone("ValveBiped.Bip01_Head1") or targetDisplay.Bone or 0)
        targetDisplay:SetLookAt(headPos)
        targetDisplay:SetCamPos(headPos + Vector(18, 0, 0))
        targetDisplay:SetFOV(60)
        targetDisplay.Entity:SetEyeTarget(targetDisplay:GetCamPos())

        targetDisplay.LayoutEntity = function() end
    end

    local targetPicker = frame:Add("DComboBox")
    targetPicker:SetWide(150)
    targetPicker:MoveBelow(targetDisplay, 5)
    targetPicker:CenterHorizontal()
    targetPicker.OnSelect = function(s, i, val, dat)
        targetDisplay:SetTarget(dat)
    end

    for i, ply in ipairs(players) do
        targetPicker:AddChoice(ply:Nick(), ply, i == 1)
    end

    local priceLbl = frame:Add("DLabel")
    priceLbl:SetText("Negotiate a price")
    priceLbl:SetFont("DarkSkinMedium")
    priceLbl:SizeToContents()
    priceLbl:MoveBelow(targetPicker, 10)
    priceLbl:CenterHorizontal()

    local priceEntry = frame:Add("DTextEntry")
    priceEntry:SetPlaceholderText("Offer")
    priceEntry:SetNumeric(true)
    priceEntry:SetWide(150)
    priceEntry:MoveBelow(priceLbl, 10)
    priceEntry:CenterHorizontal()

    local detailsLbl = frame:Add("DLabel")
    detailsLbl:SetText("Target Details")
    detailsLbl:SetFont("DarkSkinMedium")
    detailsLbl:SizeToContents()
    detailsLbl:MoveBelow(priceEntry, 10)
    detailsLbl:CenterHorizontal()

    local locationEntry = frame:Add("DTextEntry")
    locationEntry:SetWide(150)
    locationEntry:MoveBelow(detailsLbl, 10)
    locationEntry:CenterHorizontal()
    locationEntry:SetPlaceholderText("Last known location")

    local reasonEntry = frame:Add("DTextEntry")
    reasonEntry:SetMultiline(true)
    reasonEntry:SetSize(300, 150)
    reasonEntry:MoveBelow(locationEntry, 5)
    reasonEntry:CenterHorizontal()
    reasonEntry:SetPlaceholderText("Reason")

    local submitButton = frame:Add("DButton")
    submitButton:Dock(BOTTOM)
    submitButton:SetText("Submit")

    submitButton:SetDisabled(true)
    submitButton.OnMousePressed = function(s, code)
        if code == MOUSE_LEFT then
            if priceEntry:GetValue() == "" then
                nut.util.notify("No offer entered!")
            elseif tonumber(priceEntry:GetValue()) < BountyHunting.Config.MinimumOffer then
                nut.util.notify("Offer must be at least " .. BountyHunting.Config.MinimumOffer .. "!")
            elseif tonumber(priceEntry:GetValue()) > LocalPlayer():getChar():getMoney() then
                nut.util.notify("You don't have enough caps to offer that much!")
            elseif reasonEntry:GetValue() == "" then
                nut.util.notify("No reason entered!")
            elseif locationEntry:GetValue() == "" then
                nut.util.notify("No location entered!")
            elseif !IsValid(targetPicker:GetOptionData(targetPicker:GetSelectedID())) then
                nut.util.notify("Invalid player selected!")
            elseif !IsValid(hunter) then
                nut.util.notify("This bounty hunter is no longer valid!")
            else
                net.Start("BountyHuntingRequest")
                    net.WriteEntity(targetPicker:GetOptionData(targetPicker:GetSelectedID()))
                    net.WriteEntity(hunter)
                    net.WriteUInt(tonumber(priceEntry:GetValue()), 32)
                    jlib.WriteCompressedString(reasonEntry:GetValue())
                    jlib.WriteCompressedString(locationEntry:GetValue())
                net.SendToServer()

                frame:Close()
            end
        end
    end
    submitButton.Think = function(s)
        s:SetDisabled(priceEntry:GetValue() == "" or reasonEntry:GetValue() == "" or locationEntry:GetValue() == "" or tonumber(priceEntry:GetValue()) < BountyHunting.Config.MinimumOffer or !IsValid(targetPicker:GetOptionData(targetPicker:GetSelectedID())))
    end
end

function BountyHunting.ReceiveBountyMenu(tar, customer, reason, location, price)
    local frame = vgui.Create("DFrame")
    frame:SetSize(400, 600)
    frame:MakePopup()
    frame:SetTitle("Bounty Offer")
    frame:Center()
    frame:SetSkin("Dark")

    local targetLbl = frame:Add("DLabel")
    targetLbl:SetFont("DarkSkinMedium")
    targetLbl:SetText("Target: " .. tar:Nick())
    targetLbl:SetPos(0, 30)
    targetLbl:SizeToContents()
    targetLbl:CenterHorizontal()

    local targetDisplay = frame:Add("DModelPanel")
    targetDisplay:SetSize(160, 160)
    targetDisplay:MoveBelow(targetLbl, 10)
    targetDisplay:CenterHorizontal()
    targetDisplay.SetTarget = function(s, target)
        targetDisplay:SetModel(target:GetModel())
        local headPos = targetDisplay.Entity:GetBonePosition(targetDisplay.Entity:LookupBone("ValveBiped.Bip01_Head1") or targetDisplay.Bone or 0)
        targetDisplay:SetLookAt(headPos)
        targetDisplay:SetCamPos(headPos + Vector(18, 0, 0))
        targetDisplay:SetFOV(60)
        targetDisplay.Entity:SetEyeTarget(targetDisplay:GetCamPos())

        targetDisplay.LayoutEntity = function() end
    end
    targetDisplay:SetTarget(tar)

    local customerLbl = frame:Add("DLabel")
    customerLbl:SetText("Customer: " .. customer:Nick())
    customerLbl:SetFont("DarkSkinMedium")
    customerLbl:MoveBelow(targetDisplay, 5)
    customerLbl:SizeToContents()
    customerLbl:CenterHorizontal()

    local priceLbl = frame:Add("DLabel")
    priceLbl:SetFont("DarkSkinMedium")
    priceLbl:SetText("Price Offered: " .. price .. " caps")
    priceLbl:MoveBelow(customerLbl, 5)
    priceLbl:SizeToContents()
    priceLbl:CenterHorizontal()

    local locationLbl = frame:Add("DLabel")
    locationLbl:SetFont("DarkSkinMedium")
    locationLbl:SetText("Last known location: " .. location)
    locationLbl:MoveBelow(priceLbl, 5)
    locationLbl:SizeToContents()
    locationLbl:CenterHorizontal()

    local reasonLbl = frame:Add("DLabel")
    reasonLbl:SetFont("DarkSkinMedium")
    reasonLbl:SetText("Reason:")
    reasonLbl:MoveBelow(locationLbl, 5)
    reasonLbl:SizeToContents()
    reasonLbl:CenterHorizontal()

    local reasonText = frame:Add("DLabel")
    reasonText:SetFont("DarkSkinRegular")
    reasonText:SetWrap(true)
    reasonText:SetContentAlignment(8)
    reasonText:SetText(reason)
    reasonText:MoveBelow(reasonLbl, 5)
    local _, yPos = reasonText:GetPos()
    reasonText:SetSize(300, frame:GetTall() - yPos - 30 - 1)
    reasonText:CenterHorizontal()

    local btnWidth = (frame:GetWide() - 2) / 2

    local acceptBtn = frame:Add("DButton")
    acceptBtn:SetText("Accept")
    acceptBtn:SetPos(1, frame:GetTall() - acceptBtn:GetTall() - 1)
    acceptBtn:SetWide(btnWidth)
    acceptBtn.DoClick = function(s)
        if IsValid(customer) then
            net.Start("BountyHuntingAccept")
                net.WriteEntity(customer)
            net.SendToServer()
        end

        frame:Close()
    end

    local declineBtn = frame:Add("DButton")
    declineBtn:SetText("Decline")
    declineBtn:SetPos(btnWidth, frame:GetTall() - acceptBtn:GetTall() - 1)
    declineBtn:SetWide(btnWidth)
    declineBtn.DoClick = function(s)
        if IsValid(customer) then
            net.Start("BountyHuntingDecline")
                net.WriteEntity(customer)
            net.SendToServer()
        end

        frame:Close()
    end
end
net.Receive("BountyHuntingRequest", function()
    local target = net.ReadEntity()
    local customer = net.ReadEntity()
    local price = net.ReadUInt(32)
    local reason = jlib.ReadCompressedString()
    local location = jlib.ReadCompressedString()

    BountyHunting.ReceiveBountyMenu(target, customer, reason, location, price)
end)

-- Moved to garrysmod\gamemodes\fallout\plugins\slavecollar\cl_plugin.lua
-- hook.Add("KeyPress", "BountyHuntingMenu", function(ply, key)
--     if key == IN_USE and IsFirstTimePredicted() then
--         local hunter = ply:GetEyeTrace().Entity

--         if IsValid(hunter) and hunter:IsPlayer() and hunter:IsBountyHunter() and !ply:IsBountyHunter() then
--             if IsValid(hunter:GetTarget()) then
--                 nut.util.notify("This hunter already has a target!")
--             else
--                 BountyHunting.SetBountyMenu(hunter)
--             end
--         end
--     end
-- end)

--Footstep visualization
BountyHunting.Footsteps = BountyHunting.Footsteps or {}
BountyHunting.FootstepMaterial = BountyHunting.FootstepMaterial or Material("bountyhunting/footprint")
BountyHunting.FootstepDrawDistance = BountyHunting.Config.FootstepDrawDistance * BountyHunting.Config.FootstepDrawDistance
BountyHunting.FootstepLookDist = 10 * 10
BountyHunting.RandomChars = {"!", "£", "$", "%", "^", "&", "*", "@", "?"}

function BountyHunting.VisualizeFootsteps()
    local isDrawingDetails = false

    for i, step in ipairs(BountyHunting.Footsteps) do
        local timeSinceAppearance = CurTime() - step.startTime

        if timeSinceAppearance >= BountyHunting.Config.FootstepLife then
            table.remove(BountyHunting.Footsteps, i)
        else
            if step.pos:DistToSqr(LocalPlayer():GetPos()) <= BountyHunting.FootstepDrawDistance then
                local col = HSVToColor(120 * (1 - (timeSinceAppearance / BountyHunting.Config.FootstepLife)), 1, 1)

                render.SetMaterial(BountyHunting.FootstepMaterial)
                render.DrawQuadEasy(step.pos + step.normal * 0.01, step.normal, 10, 20, col, step.ang.y)

                if LocalPlayer():GetEyeTraceNoCursor().HitPos:DistToSqr(step.pos) <= BountyHunting.FootstepLookDist and !isDrawingDetails then
                    if !step.LookedAt then
                        step.LookedAt = CurTime()
                    end

                    local ang = EyeAngles()
                    ang.p = 0
                    ang.y = ang.y - 90
                    ang.r = 90

                    local animSpeed = 1.3
                    local factor = math.Clamp((CurTime() - step.LookedAt) * animSpeed, 0, 1)

                    cam.Start3D2D(step.pos, ang, 0.1)
                        local fullStr = step.target:Nick() .. "'s footstep"
                        local amtOfChars = #fullStr * factor
                        local displayStr = string.sub(fullStr, 1, amtOfChars) .. (amtOfChars == #fullStr and "" or BountyHunting.RandomChars[math.random(1, #BountyHunting.RandomChars)])

                        draw.SimpleTextOutlined(displayStr, "DarkSkinHuge", 0, -190, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0, 255))
                    cam.End3D2D()

                    isDrawingDetails = true
                else
                    step.LookedAt = nil
                end
            end
        end
    end
end
hook.Add("PostDrawTranslucentRenderables", "BountyHuntingVisualizeFootsteps", BountyHunting.VisualizeFootsteps)

function BountyHunting.AddFootstep(target, pos, ang, isRight)
    if isRight then
        pos = pos + ang:Right() * 5
    else
        pos = pos + ang:Right() * -5
    end

    table.insert(BountyHunting.Footsteps, {
        pos = pos,
        ang = ang,
        normal = Vector(0, 0, 1),
        target = target,
        startTime = CurTime()
    })
end

net.Receive("BountyHuntingFootstep", function()
    local target = net.ReadEntity()
    local pos = net.ReadVector()
    local ang = net.ReadAngle()
    local isRight = net.ReadBool()

    target.Step = (target.Step or 0) + (1 / BountyHunting.Config.FootstepFrequency)

    if target.Step >= 1 then
        BountyHunting.AddFootstep(target, pos, ang, isRight)
        target.Step = 0
    end
end)

net.Receive("BountyHuntingClearSteps", function()
    BountyHunting.Footsteps = {}
end)

--Contract review
function BountyHunting.ContractReview()
	local tar = LocalPlayer():GetTarget()

	local frame = vgui.Create("DFrame")
    frame:SetSize(400, 300)
    frame:MakePopup()
    frame:SetTitle("Contract Review")
    frame:Center()
    frame:SetSkin("Dark")

    local targetLbl = frame:Add("DLabel")
    targetLbl:SetFont("DarkSkinMedium")
    targetLbl:SetText("Target: " .. tar:Nick())
    targetLbl:SetPos(0, 30)
    targetLbl:SizeToContents()
    targetLbl:CenterHorizontal()

    local targetDisplay = frame:Add("DModelPanel")
    targetDisplay:SetSize(160, 160)
    targetDisplay:MoveBelow(targetLbl, 10)
    targetDisplay:CenterHorizontal()
    targetDisplay.SetTarget = function(s, target)
        targetDisplay:SetModel(target:GetModel())
        local headPos = targetDisplay.Entity:GetBonePosition(targetDisplay.Entity:LookupBone("ValveBiped.Bip01_Head1") or targetDisplay.Bone or 0)
        targetDisplay:SetLookAt(headPos)
        targetDisplay:SetCamPos(headPos + Vector(18, 0, 0))
        targetDisplay:SetFOV(60)
        targetDisplay.Entity:SetEyeTarget(targetDisplay:GetCamPos())

        targetDisplay.LayoutEntity = function() end
    end
    targetDisplay:SetTarget(tar)
end

hook.Add("PlayerButtonDown", "ContractReview", function(ply, btn)
	if btn == KEY_F6 and IsFirstTimePredicted() and ply == LocalPlayer() and ply:IsBountyHunter() then
		if IsValid(ply:GetTarget()) then
			BountyHunting.ContractReview()
		else
			chat.AddText("You have no active contract at this time.")
		end
	end
end)

--Head collection
function BountyHunting.DrawHeadCollectionProgress()
	local time = CurTime()
    local collectTime = BountyHunting.Config.HeadCollectionTime
    
    local wep = LocalPlayer():GetActiveWeapon()
    if wep.Base and wep.Base == "dangumeleebase" then
        collectTime = BountyHunting.Config.HeadCollectionTime / 5
    end

	if BountyHunting.CollectingHead and BountyHunting.CollectingHead + collectTime > time then
		local progress = (time - BountyHunting.CollectingHead) / collectTime
		local w, h = 720, 40

		jlib.DrawProgressBar((ScrW() / 2) - (w / 2), h * 4, w, h, progress, "Collecting", true, Color(230, 0, 0, 255))
	end
end
hook.Add("HUDPaint", "BountyHeadCollection", BountyHunting.DrawHeadCollectionProgress)

net.Receive("BountyHeadCollect", function()
	BountyHunting.CollectingHead = CurTime()
end)

net.Receive("BountyHeadHalt", function()
	BountyHunting.CollectingHead = nil
end)

--Target confirmation
BountyHunting.IdentificationProgress = 0
BountyHunting.IdentificationDistance = 50
BountyHunting.IdentificationDistanceSqr = BountyHunting.IdentificationDistance ^ 2
BountyHunting.IDCooldown = false

function BountyHunting.IdentifyTarget()
	if LocalPlayer():KeyDown(IN_USE) and LocalPlayer():IsBountyHunter() and IsValid(LocalPlayer():GetTarget()) then
		if BountyHunting.IDCooldown then return end

		local tr = LocalPlayer():GetEyeTraceNoCursor()

		if IsValid(tr.Entity) and tr.Entity:IsPlayer() and tr.Entity:GetPos():DistToSqr(LocalPlayer():GetPos()) < BountyHunting.IdentificationDistanceSqr then
			BountyHunting.IdentificationProgress = BountyHunting.IdentificationProgress + RealFrameTime()

			if BountyHunting.IdentificationProgress >= BountyHunting.Config.IdentificationTime then
				chat.AddText(tr.Entity == LocalPlayer():GetTarget() and "You have found your target." or "This is not your target.")
				BountyHunting.IdentificationProgress = 0
				BountyHunting.IDCooldown = true
			end

			local w, h = 720, 40

			jlib.DrawProgressBar((ScrW() / 2) - (w / 2), h * 4, w, h, BountyHunting.IdentificationProgress / BountyHunting.Config.IdentificationTime, "Identifying", true, Color(0, 100, 250, 255))
		end
	else
		BountyHunting.IdentificationProgress = 0
		BountyHunting.IDCooldown = false
	end
end
hook.Add("HUDPaint", "BountyTargetIdentification", BountyHunting.IdentifyTarget)

--Rocket Boots
BountyHunting.BoostingPlayers = {}

surface.CreateFont("RocketBootsCharge", {font = "Arial", size = 26, weight = 400})
function BountyHunting.RocketBootsHUD()
	if LocalPlayer():HasRocketBoots() and LocalPlayer().MaxRocketCharge then
		local w, h = 450, 30

		jlib.DrawProgressBar((ScrW() / 2) - (w / 2), ScrH() - (h * 2), w, h, LocalPlayer():GetRocketCharge() / LocalPlayer().MaxRocketCharge, "Boots Fuel", false, Color(255, 199, 44, 255), "RocketBootsCharge")
	end
end
hook.Add("HUDPaint", "BountyRocketBoots", BountyHunting.RocketBootsHUD)

net.Receive("BountyStartBoost", function()
	local ply = net.ReadEntity()
	BountyHunting.BoostingPlayers[ply] = true
end)

net.Receive("BountyStopBoost", function()
	local ply = net.ReadEntity()
	BountyHunting.BoostingPlayers[ply] = nil
end)

local EFFECT = {}

function EFFECT:Init(dat)
	local ply = dat:GetEntity()
	if not IsValid(ply) then return end

	self:SetPos(ply:GetPos())
	self.DieTime = CurTime() + 1

	self.Emitter = ParticleEmitter(ply:GetPos())
	self.Player  = ply
end

function EFFECT:Think()
	self.Dead = self.DieTime < CurTime() or self.Player:IsOnGround()

	if self.Dead then
		self.Emitter:Finish()
	else
		local Up = self.Player:EyeAngles():Up()
		local velocity = self.Player:GetVelocity() / 3
		Up.z = 0
		local Foot1 = self.Player:LookupBone("ValveBiped.Bip01_R_Foot")
		local Foot2 = self.Player:LookupBone("ValveBiped.Bip01_L_Foot")

		if !Foot1 or !Foot2 then return end

		local Foot1Pos = self.Player:GetBonePosition(Foot1)
		local Foot2Pos = self.Player:GetBonePosition(Foot2)
		local p

		--Right foot flame
		p = self.Emitter:Add("particles/flamelet" .. math.random(1, 5), Foot1Pos + Up * -3)
		p:SetDieTime(1 + math.random() * 0.5)
		p:SetStartAlpha(200 + math.random(55))
		p:SetEndAlpha(0)
		p:SetStartSize(8 + math.random() * 3)
		p:SetEndSize(0)
		p:SetRoll(math.random() * 3)
		p:SetRollDelta(math.random() * 2 - 1)

		--Right foot smoke
		p = self.Emitter:Add("particles/smokey", Foot1Pos + Up * -3)
		p:SetDieTime(1 + math.random() * 0.5)
		p:SetStartAlpha(180 + math.random(55))
		p:SetEndAlpha(0)
		p:SetStartSize(8 + math.random() * 3)
		p:SetEndSize(2 + math.random() * 10)
		p:SetRoll(math.random() * 3)
		p:SetRollDelta(math.random() * 2 - 1)
		p:SetVelocity(velocity)

		--Left foot flame
		p = self.Emitter:Add("particles/flamelet" .. math.random(1, 5), Foot2Pos + Up * -3)
		p:SetDieTime(1 + math.random() * 0.5)
		p:SetStartAlpha(200 + math.random(55))
		p:SetEndAlpha(0)
		p:SetStartSize(8 + math.random() * 3)
		p:SetEndSize(0)
		p:SetRoll(math.random() * 3)
		p:SetRollDelta(math.random() * 2 - 1)

		--Left foot smoke
		p = self.Emitter:Add("particles/smokey", Foot2Pos + Up * -3)
		p:SetDieTime(1 + math.random() * 0.5)
		p:SetStartAlpha(180 + math.random(55))
		p:SetEndAlpha(0)
		p:SetStartSize(8 + math.random() * 3)
		p:SetEndSize(2 + math.random() * 10)
		p:SetRoll(math.random() * 3)
		p:SetRollDelta(math.random() * 2 - 1)
		p:SetVelocity(velocity)
	end

	return not self.Dead
end

function EFFECT:Render()
end

effects.Register(EFFECT, "wt_rocketboots_effect")

--moved to pkdecap plugin
--[[
net.Receive("PKForceNameChange", function()
	local frame = vgui.Create("DFrame")
	frame:SetTitle("PK Name Change")
	frame:SetSize(600, 600)
	frame:Center()
	frame:ShowCloseButton(false)
	frame:MakePopup()

	local firstName = frame:Add("DTextEntry")
	firstName:SetWide(300)
	firstName:SetPlaceholderText("First Name")
	firstName:Center()

	local lastName = frame:Add("DTextEntry")
	lastName:SetWide(300)
	lastName:SetPlaceholderText("Last Name")
	lastName:CenterHorizontal()
	lastName:MoveBelow(firstName, 5)

	local submitBtn = frame:Add("DButton")
	submitBtn:SetText("Submit")
	submitBtn:Dock(BOTTOM)
	submitBtn.DoClick = function(s)
		--Same name validation steps as from the character creator
		local f, l = firstName:GetText(), lastName:GetText()

		if !f or !l then
			Derma_Message("Your character's first or last name cannot be blank.", nil, "OK")
			return
		end

		if f:find("%s") or l:find("%s") then
			Derma_Message("Your character name cannot contain any spaces.", nil, "OK")
			return
		elseif f:find("%d") or l:find("%d") then
			Derma_Message("Your character name cannot contain any numbers.", nil, "OK")
			return
		elseif f:find("%p") or l:find("%p") then
			Derma_Message("Your character name cannot contain any punctuation.", nil, "OK")
			return
		elseif f:len() < 1 or l:len() < 1 then
			Derma_Message("Your character's first or last name cannot be blank.", nil, "OK")
			return
		elseif (f:len() + l:len()) < 5 then
			Derma_Message("Your character's name cannot be shorter than five letters.", nil, "OK")
			return
		elseif (f:len() + l:len()) > 24 then
			Derma_Message("Your character's name cannot be longer than twenty four letters.", nil, "OK")
			return
		end

		frame:Close()

		net.Start("PKSubmitNameChange")
			net.WriteString(f .. " " .. l)
		net.SendToServer()
	end
end)
--]]
