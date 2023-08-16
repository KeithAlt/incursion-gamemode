LIMB_HEAD = 0
LIMB_TORSO = 1
LIMB_LEFTARM = 2
LIMB_RIGHTARM = 3
LIMB_LEFTLEG = 4
LIMB_RIGHTLEG = 5
LIMB_CUSTOMASS = 6
-- .. and goes on


RVATS = RVATS or {}
RVATS.apCalc = 0
RVATS.APMaximum = 100 -- max AP
RVATS.options = {
	outline = true, -- use outline effect
	scanline = true, -- use scanline effect
	superhd = false, -- use 9 passes than 4 passes
	thick = 2, -- the thickness of the line
	distance = 2500, -- it will not detect anyone/anything farther than this distance
	maincolor = Color(0, 250, 0),
	redcolor = Color(231, 76, 60),
	displayAP = true,
	vatDelay = .5
}
RVATS.targetTypes = {
	player = "human",
}
RVATS.selectionInfo = {
	--targetBone
	--targetEntity
	--count
}
RVATS.selectionQueue = {
}
RVATS.modelLimbs = {
}
RVATS.targetLimbs = {
	human = {
		[LIMB_HEAD] = {
			bone = "ValveBiped.Bip01_Head1",
			name = "Head",
			ap = 50,
			baseChance = .8,
		},
		[LIMB_TORSO] = {
			bone = "ValveBiped.Bip01_Spine2",
			name = "Torso",
			ap = 25,
			baseChance = .8,
		},
		[LIMB_LEFTARM] = {
			bone = "ValveBiped.Bip01_L_Forearm",
			name = "Left Arm",
			ap = 20,
			baseChance = .7,
		},
		[LIMB_RIGHTARM] = {
			bone = "ValveBiped.Bip01_R_Forearm",
			name = "Right Arm",
			ap = 20,
			baseChance = .7,
		},
		[LIMB_LEFTLEG] = {
			bone = "ValveBiped.Bip01_L_Calf",
			name = "Left Calf",
			ap = 20,
			baseChance = .7,
		},
		[LIMB_RIGHTLEG] = {
			bone = "ValveBiped.Bip01_R_Calf",
			name = "Right Calf",
			ap = 20,
			baseChance = .7,
		},
	}
}

local ENTITY = FindMetaTable("Entity")

function ENTITY:IsVisibleClear(client)
	if (!IsValid(client)) then
		return false
	end

	if (!client:IsPlayer()) then
		return false
	end

	local tr = util.TraceHull( {
		start = client:EyePos(),
		endpos = self:GetPos() + self:OBBCenter(),
		filter = client,
		mins = Vector( -5, -5, -5 ),
		maxs = Vector( 5, 5, 5 ),
		mask = MASK_SHOT_HULL
	} )

	return (tr.Entity == self)
end

function ENTITY:GetLimbData()
	local class = self:GetClass()
	local model = self:GetModel()
	local classLimb = RVATS.targetLimbs[RVATS.targetTypes[class]]

	if (classLimb) then
		local modelLimb = RVATS.modelLimbs[model]

		if (modelLimb) then
			return modelLimb
		end

		return classLimb
	end

	return nil
end

function ENTITY:CanBeTargeted(client, distCheck)
	if (self:IsPlayer() or self:IsBot()) then
		if (!self:Alive()) then return false end
		if (self.getChar and self:getChar() == nil) then return false end -- nutscript compatability.
		if (self:GetNoDraw() == true) then return false end
		if (IsValid(client)) then
			if (!self:IsVisibleClear(client)) then
				return false
			end

			if (distCheck) then
				local distLimit = RVATS.options.distance
				local dist = self:GetPos():Distance(client:GetPos())

				if (dist > distLimit) then
					return false
				end
			end
		end
	end

	return true
end

function ENTITY:IsBurstWeapon()
	return (self and self.Primary and self.Primary.Automatic == true) and 5 or 1
end

RVATS.blacklistWeapons = {
	["weapon_physcannon"] = true,
	["weapon_physgun"] = true,
}

function ENTITY:IsValidVATWeapon()
	local class = self:GetClass():lower()
	-- is melee or whatsoever mate

	return !(RVATS.blacklistWeapons[class])
end

function RVATS:findPossibleTargets(client)
	if (IsValid(client)) then
		local distLimit = RVATS.options.distance
		local pos = client:GetPos()
		local possibleTargets = {}

		for k, v in ipairs(player.GetAll()) do
			if (v == client) then continue end
			if (!v:CanBeTargeted()) then continue end

			local dist = pos:Distance(v:GetPos())

			if (dist > distLimit) then
				continue
			end

			if (!v:IsVisibleClear(client)) then
				continue
			end

			table.insert(possibleTargets, v)
		end

		return possibleTargets
	else
		return {}
	end
end

function RVATS:getNearestTarget(client)
	if (IsValid(client)) then
		local pos = client:GetPos()
		local targets = self:findPossibleTargets(client)
		local min = math.huge
		local finalTarget

		for k, v in ipairs(targets) do
			local dist = pos:Distance(v:GetPos())

			if (dist < min) then
				finalTarget = v
				min = dist
			end
		end

		return finalTarget
	else
		return {}
	end
end

if (SERVER) then
	netstream.Hook("rvatsVATRequest", function(client, target, info, queue)
		RVATS:confirmVATS(client, target, info, queue)
	end)

	function RVATS:confirmVATS(client, target, info, queue)
		if (true) then
			local APCost = 0
			local limbData = target:GetLimbData()

			for k, v in ipairs(queue) do
				if (limbData[v]) then
					APCost = APCost + limbData[v].ap
				end
			end

			if (APCost > RVATS.APMaximum) then
				client:ChatPrint("VATS Request is corrupted.")
				return false
			end

			if (APCost > target:getLocalVar("stm")) then
				client:ChatPrint("Not enough AP Points")
				return false
			end

			local weapon = client:GetActiveWeapon()

			if (IsValid(weapon)) then
				if (!weapon:IsValidVATWeapon()) then
					client:ChatPrint("This weapon is not suitable for VATS Attack.")

					return false
				end
			end
			
			local item = client:getChar():getInv():hasItem("pipboy")
			if !item and !client:hasSkerk("vats") then
				client:falloutNotify("You need a Pip-Boy or the VATS skill in order to preform VATS.")
				return false
			end

			if item and !item:getData("equip") and !client:hasSkerk("vats") then
				client:falloutNotify("You do not have a pipboy equipped.")
				return false
			end

			if (APCost > 0) then
				print(client:GetName() .. " wants to go VATSHOT with " .. APCost .. " AP, and it's granted.")

				netstream.Start(client, "rvatsVATGranted", target, queue) -- VAT SHOT is granted, aimlock gogogo!
				RVATS:executeVATS(client, target, queue)
			end
		end
	end

	function RVATS:executeVATS(client, target, shotInfo)
		if (client:Alive()) then
			local weapon = client:GetActiveWeapon()

			if (IsValid(weapon)) then

				if weapon.Primary.Automatic == true then
					VATSrate = 0.5
				elseif weapon.Primary.Automatic == false then
					VATSrate = 1.7
				end

				local weaponShotDelay = VATSrate or 1.7
				local targetLimbs = target:GetLimbData()
				local numShot = weapon:IsBurstWeapon()
				local shotCount = table.Count(shotInfo)
				local timerName = client:SteamID() .. "_VATREQUEST"
				local startpos = client:GetPos()

				-- remove exisiting VAT request
				timer.Remove(timerName)

				local boi = false
				local realBoi = false
				local function haltTimer(allFired)
					timer.Remove(timerName)
					hook.Run("OnVATSFinished", client, weapon, target, shotInfo, allFired)
				end

				local function kimchiBoi()
					local reps = timer.RepsLeft(timerName) or (shotCount - 1)
					local indexReps = shotCount - reps

					-- if client is deceased or left the game or changing the character.
					if (!IsValid(client) or !client:Alive() or client:InVehicle() or (client.getChar and !client:getChar())) then
						haltTimer()
						boi = true
						client:falloutNotify("VATS Aborted: Invalid user", "ui/notify.mp3")
						return
					end

					if (!target:CanBeTargeted(client, true)) then
						haltTimer()
						boi = true
						client:falloutNotify("VATS Aborted: Cannot hit target", "ui/notify.mp3")
						return
					end

					-- if weapon is not valid or weapon is changed or weapon is removed from the game.
					if (!IsValid(client:GetActiveWeapon()) or !IsValid(weapon) or client:GetActiveWeapon() != weapon) then
						haltTimer()
						boi = true
						client:falloutNotify("VATS Aborted: Weapon holstered", "ui/notify.mp3")
						return
					end

					if (weapon:Clip1() == 0) then
						haltTimer()
						boi = true
						client:falloutNotify("VATS Aborted: Insufficient ammo", "ui/notify.mp3")
						return
					end

					if client:GetPos():Distance(startpos) > 200 then
						haltTimer()
						boi = true
						client:falloutNotify("VATS Aborted: Excessive movement", "ui/notify.mp3")
						return
					end

					local curStamina = client:getLocalVar("stm")
					local curBoneData = targetLimbs[shotInfo[indexReps]]

					if (!curBoneData) then
						haltTimer()
						boi = true
						client:falloutNotify("VATS Aborted: Invalid request", "ui/notify.mp3")
						return
					end

					if ((curStamina - curBoneData.ap) < 0) then
						haltTimer()
						boi = true
						client:falloutNotify("VATS Aborted: Not enough AP", "ui/notify.mp3")
						return
					end

					-- check if it's melee or not!
					if (true) then

					else
						-- idk teleport or somethin
					end

					client:setLocalVar("stm", curStamina - curBoneData.ap)

					-- use the weapon
					local isSuccess = curBoneData.baseChance >= math.Rand(0, 1) -- lmao

					for i = 0, math.max(0, weapon:IsBurstWeapon() - 1) do
						timer.Simple(weaponShotDelay * i, function()
							if (realBoi == true) then return end -- it's halt!
							if (boi == true) then realBoi = true return end -- get some halt flag
							if (IsValid(target) == false or IsValid(client) == false or IsValid(weapon) == false) then realBoi = true return end
							if (IsValid(client:GetActiveWeapon()) and weapon != client:GetActiveWeapon()) then realBoi = true return end
							-- to increase accuracy
							local bonePos = target:GetBonePosition(target:LookupBone(curBoneData.bone))
							local dir = bonePos - client:GetShootPos()

							client:SetEyeAngles(dir:Angle())

							local prevCone = weapon.Primary.Cone
							local prevRecoil = weapon.Primary.Recoil
							local prevIronCone = weapon.Primary.IronAccuracy
							local prevSpread = weapon.Primary.Spread

							if (isSuccess) then
								weapon.Primary.Cone = 0
								weapon.Primary.Recoil = 0
								weapon.Primary.IronAccuracy = 0
								weapon.Primary.Spread = 0
							else
								weapon.Primary.Cone = .05
								weapon.Primary.Recoil = .1
								weapon.Primary.IronAccuracy = .1
								weapon.Primary.Spread = .1
							end

							weapon:PrimaryAttack()

							weapon.Primary.Cone = prevCone
							weapon.Primary.Recoil = prevRecoil
							weapon.Primary.IronAccuracy = prevIronCone
							weapon.Primary.Spread = prevSpread
						end)
					end

					-- deduct the AP Point.
					local costAP

					--hook the end of the timer
					if (reps == 0) then
						haltTimer(true)
					end
				end

				kimchiBoi()

				if ((shotCount - 1) > 0) then
					local timerLength = weapon:IsBurstWeapon() <= 1 and weaponShotDelay or weaponShotDelay * weapon:IsBurstWeapon() + 0.1
					timer.Create(timerName, timerLength, shotCount - 1, kimchiBoi)
				end
			end
		end
	end

	hook.Add("OnVATSFinished", "rvatsRevokeCamera", function(client)
		timer.Simple(1, function() if (!IsValid(client)) then return end netstream.Start(client, "rvatsVATRevoked") end)
	end)
	hook.Add("PlayerDeath", "rvatsRevokeCamera", function(client)
		timer.Simple(1, function() if (!IsValid(client)) then return end netstream.Start(client, "rvatsVATRevoked") end)
	end)
else
	surface.CreateFont("vatHelpFont", {
		font = "Bebas Neue",
		size = ScreenScale(10),
		weight = 500,
		extended = true,
		antialias = true
	})

	surface.CreateFont("vatChanceFont", {
		font = "Bebas Neue",
		size = ScreenScale(13),
		weight = 500,
		extended = true,
		antialias = true
	})

	surface.CreateFont("vatLimbFont", {
		font = "Bebas Neue",
		size = ScreenScale(8),
		weight = 500,
		extended = true,
		antialias = true
	})

	RVATS.renderTargets = {}
	RVATS.vatShotData = {
		active = false,
		target = nil,
		data = {}
	}

	local minZoom = 0.058
	local humanoidZoom = 0.4
	local lerpMe = minZoom
	local curViewData

	-- or enter vats
	function RVATS:setTarget(target, continous)
		if (IsValid(target)) then
			RVATS.renderTargets = {target}
			RVATS.aimTarget = target
			RVATS.selectionInfo = {}
			RVATS.selectionQueue = {}

			if (!continous) then
				lerpMe = minZoom
			end
			gui.EnableScreenClicker(true)
		end
	end

	function RVATS:removeTarget()
		RVATS.renderTargets = {}
		RVATS.selectionInfo = {}
		RVATS.selectionQueue = {}
		RVATS.aimTarget = nil
		gui.EnableScreenClicker(false)
		surface.PlaySound("vat_exit.mp3")
	end

	function RVATS:sendInformation()
		local target = RVATS.aimTarget
		local hitQueue = RVATS.selectionQueue
		local hitInfo = RVATS.selectionInfo

		netstream.Start("rvatsVATRequest", target, hitInfo, hitQueue)

		if (table.Count(hitQueue) > 0) then
			surface.PlaySound("vat_engage.mp3")
		end
		RVATS:removeTarget()
	end

	function RVATS:enterVATS(client)
		local pipboy = LocalPlayer():getChar():getInv():hasItem("pipboy")

		if LocalPlayer():Alive() and (client:isWepRaised() == true) and LocalPlayer():getChar() and ( (pipboy and pipboy:getData("equip") != nil) or LocalPlayer():hasSkerk("vats") ) then
			self:setTarget(RVATS:getNearestTarget(client))
			if (RVATS.aimTarget) then
				surface.PlaySound("vat_enter.mp3")
			end
		end
	end


	hook.Add("OnVATSFinished", "removeAimLock", function()
		RVATS.vatShotData = {
			active = false,
			target = nil,
			data = {}
		}
	end)

	local client = LocalPlayer()
	local target = RVATS:getNearestTarget(client)
	local shotInfo = {
		LIMB_HEAD,
		LIMB_HEAD,
		LIMB_HEAD,
	}

	RVATS.VatCam = {
	}

	netstream.Hook("rvatsVATGranted", function(target, shotInfo)
		RVATS.VatCam = {
			enabled = true,
			target = target,
		}
	end)

	netstream.Hook("rvatsVATRevoked", function(target, shotInfo)
		RVATS.VatCam = {
			enabled = false
		}
	end)

	local targets = RVATS:findPossibleTargets(LocalPlayer())

	function RVATS:nextTarget(client)
		local currentTarget = RVATS.aimTarget

		if (IsValid(currentTarget)) then
			local targets = self:findPossibleTargets(client)

			if (table.Count(targets) == 0) then
				self:removeTarget()
			end

			local noTarget = true
			for k, v in pairs(targets) do
				if (v == currentTarget) then
					noTarget = false

					local nextTarget = targets[k + 1]
					if (IsValid(nextTarget)) then
						self:setTarget(nextTarget, true)
					else
						nextTarget = targets[1]

						if (IsValid(nextTarget) and nextTarget != currentTarget) then
							self:setTarget(nextTarget, true)
						end
					end
				end
			end

			if (noTarget) then
				self:setTarget(table.Random(targets), true)
			end
		end
	end

	function RVATS:prevTarget(client)
		local currentTarget = RVATS.aimTarget

		if (IsValid(currentTarget)) then
			local targets = self:findPossibleTargets(client)

			if (table.Count(targets) == 0) then
				self:removeTarget()
			end

			local noTarget = true
			for k, v in pairs(targets) do
				if (v == currentTarget) then
					noTarget = false
					local nextTarget = targets[k - 1]

					if (IsValid(nextTarget)) then
						self:setTarget(nextTarget, true)
					else
						nextTarget = targets[#targets]

						if (IsValid(nextTarget) and nextTarget != currentTarget) then
							self:setTarget(nextTarget, true)
						end
					end
				end
			end

			if (noTarget) then
				self:setTarget(table.Random(targets), true)
			end
		end
	end

	local lerpAngle = Angle()
	hook.Add("CalcView", "VATSFovCalc", function(client, position, angles, fov)
		local view = {}
		view.origin = position
		view.angles = angles

		curViewData = view
		if (RVATS.VatCam.enabled == true) then
			local aimTarget = client
			local perspective = RVATS.VatCam.target or Entity(4)
			view.drawviewer = true

			if (IsValid(aimTarget)) then
				if (RealTime()%6 < 3) then
					local targetPosition = (perspective:GetPos() + perspective:OBBCenter())
					local clientPosition = (aimTarget:GetPos() + aimTarget:OBBCenter() + Angle(RealTime()*22 % 360, RealTime()*50 % 360, RealTime()*8 % 360):Right() * 22)
					local targetDir =  targetPosition  - clientPosition
					local distance = clientPosition:Distance(targetPosition) / RVATS.options.distance
					local newCalc = math.min(1,distance)
					targetDir:Normalize()
					local targetAngle = targetDir:Angle()

					lerpMe = Lerp(FrameTime() * 0.9, lerpMe, humanoidZoom/10)
					lerpAngle = LerpAngle(FrameTime() * 15, lerpAngle, targetAngle)

					view.origin = clientPosition - targetDir * 100
					view.angles = lerpAngle
					view.fov = math.min(1/(distance*lerpMe), 100)
					curViewData = view
				else
					local clientPosition =  (perspective:GetPos() + perspective:OBBCenter() + Angle(RealTime()*22 % 360, RealTime()*50 % 360, RealTime()*8 % 360):Right() * 40)
					local targetPosition = (aimTarget:GetPos() + aimTarget:OBBCenter())
					local targetDir =  targetPosition  - clientPosition
					local distance = clientPosition:Distance(targetPosition) / RVATS.options.distance
					local newCalc = math.min(1,distance)
					targetDir:Normalize()
					local targetAngle = targetDir:Angle()

					lerpMe = Lerp(FrameTime() * 0.9, lerpMe, humanoidZoom/5)
					lerpAngle = LerpAngle(FrameTime() * 15, lerpAngle, targetAngle)

					view.origin = clientPosition - targetDir * 100
					view.angles = lerpAngle
					view.fov = math.min(1/(distance*lerpMe), 100)
					curViewData = view
				end

				return view
			else
				lerpAngle = angles
			end
		else
			local aimTarget = RVATS.aimTarget
			view.drawviewer = false

			if (IsValid(aimTarget)) then
				local clientPosition = client:GetShootPos()
				local targetPosition = (aimTarget:GetPos() + aimTarget:OBBCenter())
				local targetDir =  targetPosition  - clientPosition
				local distance = clientPosition:Distance(targetPosition) / RVATS.options.distance
				local newCalc = math.min(1,distance)
				targetDir:Normalize()
				local targetAngle = targetDir:Angle()
				lerpMe = Lerp(FrameTime() * 0.9, lerpMe, humanoidZoom)
				lerpAngle = LerpAngle(FrameTime() * 15, lerpAngle, targetAngle)

				view.angles = lerpAngle
				view.fov = math.min(1/(distance*lerpMe), 130)
				curViewData = view
				return view
			else
				lerpAngle = angles
			end
		end
	end)

	local TEXTURE_FLAGS_CLAMP_S = 0x0004
	local TEXTURE_FLAGS_CLAMP_T = 0x0008
	local w, h = ScrW(), ScrH()
	local tex_effect = GetRenderTarget( "VAToutline", w, h)
	local mat_outline = CreateMaterial("VAToutline","UnlitGeneric",{
		["$basetexture"] = tex_effect:GetName(),
		["$translucent"] = 1
	})
	local mat_scanline = Material( "scanline2.png", "noclamp smooth" )

	local bracketThicc = 2
	local bracketShadow = 1
	local bracketLength = 10
	local bracketAttackLength = 7
	local minWidth = 90

	local clickTarget = nil
	local function hookClick(x, y, w, h, index)
		local mx, my = gui.MousePos()

		if (mx > x and mx < x + w) then
			if (my > y and my < y + h) then
				clickTarget = index
			end
		end
	end

	local function drawModels()
		for k, v in ipairs(RVATS.renderTargets) do
			if (IsValid(v)) then
				v:DrawModel()

				local wep = v:GetActiveWeapon()
				if (IsValid(wep)) then
					wep:DrawModel()
				end
			end
		end
	end

	local function drawBracket(x, y, w, h, select)
		local len = select and bracketAttackLength or bracketLength
		local col = select and RVATS.options.redcolor or RVATS.options.maincolor
		surface.SetDrawColor(col)
		surface.DrawRect(x - w/2, y - h/2, bracketThicc, h)
		surface.DrawRect(x + w/2, y - h/2, bracketThicc, h)

		surface.DrawRect(x - w/2, y + h/2, len, bracketThicc)
		surface.DrawRect(x - w/2, y - h/2 - bracketThicc, len, bracketThicc)

		surface.DrawRect(x + w/2 - len, y + h/2 - bracketThicc, len, bracketThicc)
		surface.DrawRect(x + w/2 - len, y - h/2, len, bracketThicc)

		surface.SetDrawColor(color_black)
		surface.DrawRect(x - w/2 + 2, y - h/2, bracketShadow, h)
		surface.DrawRect(x + w/2 + 2, y - h/2, bracketShadow, h)

		surface.DrawRect(x - w/2, y + h/2 + bracketThicc, len, bracketShadow)
		surface.DrawRect(x - w/2 + bracketThicc, y - h/2, len - bracketThicc, bracketShadow)

		surface.DrawRect(x + w/2 - len, y + h/2, len + bracketThicc, bracketShadow)
		surface.DrawRect(x + w/2 - len, y - h/2 + bracketThicc, len, bracketShadow)
	end

	local txu, txd = ScreenScale(6), ScreenScale(4)
	local trueClick = false
	function RVATS.render2d()
		if (type(curViewData) != "table") then return false end

		do
			if (RVATS.options.outline) then
					-- render the player outline render target texture
					render.SetWriteDepthToDestAlpha( false )

					render.SetStencilEnable(true)
						render.SetBlend(0)
						render.ClearStencil()
						render.PushRenderTarget( tex_effect )
							render.Clear(0,0,0,0)
							render.ClearDepth()
							cam.Start2D()
								cam.Start3D(curViewData.origin, curViewData.angles, nil, 0, 0, w, h)
									render.SetStencilWriteMask(157) -- yeah random number to avoid confliction
									render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
									render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
									render.SetStencilFailOperation(STENCILOPERATION_REPLACE)

									render.SetBlend(0)
									drawModels()

									render.SetStencilTestMask(157)
									render.SetStencilReferenceValue(1)
									render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_LESSEQUAL)
									render.SetStencilPassOperation(STENCILOPERATION_KEEP)
									render.SetStencilFailOperation(STENCILOPERATION_KEEP)
									cam.Start2D()
										surface.SetDrawColor(RVATS.options.maincolor )
										surface.DrawRect( 0,0, w, h)
									cam.End2D()
								cam.End3D()
							cam.End2D()
						render.PopRenderTarget()
					render.SetStencilEnable(false)
					render.SuppressEngineLighting( false )
					render.SetWriteDepthToDestAlpha( true )
			end

			-- render the screenspace target highlight
			render.SetStencilEnable(true)
			render.SetBlend(0)

			cam.Start3D(curViewData.origin, curViewData.angles, nil, 0, 0, w, h)
					render.SetStencilWriteMask(157) -- yeah random number to avoid confliction
					render.SetStencilCompareFunction(1)
					render.SetStencilPassOperation(3)
					render.SetStencilFailOperation(3)
					render.SetStencilZFailOperation(3)

					drawModels()
			cam.End3D()

			render.SetStencilTestMask(157)
			render.SetStencilReferenceValue(1)

			if (RVATS.options.outline) then
				render.SetStencilCompareFunction(5)
				render.SetStencilPassOperation(STENCILOPERATION_KEEP)
				render.SetStencilFailOperation(STENCILOPERATION_KEEP)

				surface.SetDrawColor(RVATS.options.maincolor)
				surface.SetMaterial( mat_outline )
				surface.DrawTexturedRect( RVATS.options.thick, 0, w, h, 0, 0)
				surface.DrawTexturedRect( -RVATS.options.thick, 0, w, h, 0, 0)
				surface.DrawTexturedRect( 0, RVATS.options.thick, w, h, 0, 0)
				surface.DrawTexturedRect( 0, -RVATS.options.thick, w, h, 0, 0)

				if (RVATS.options.superhd) then
					surface.DrawTexturedRect( -RVATS.options.thick, -RVATS.options.thick, w, h, 0, 0)
					surface.DrawTexturedRect( -RVATS.options.thick, RVATS.options.thick, w, h, 0, 0)
					surface.DrawTexturedRect( RVATS.options.thick, RVATS.options.thick, w, h, 0, 0)
					surface.DrawTexturedRect( RVATS.options.thick, -RVATS.options.thick, w, h, 0, 0)
				end
			end

			if (RVATS.options.scanline) then
				render.SetStencilCompareFunction(3)
				render.SetStencilPassOperation(3)
				render.SetStencilFailOperation(3)
				render.SetStencilZFailOperation(3)

				surface.SetDrawColor(ColorAlpha(RVATS.options.maincolor, 100))
				surface.SetMaterial( mat_scanline )
				surface.DrawTexturedRect( 0,0, w, h)
			end
			render.SetStencilEnable(false)
		end

		-- lol think in the hudpaint
		if (IsValid(RVATS.aimTarget)) then
			do
				local v = RVATS.aimTarget

				if (IsValid(v)) then
					local class = v:GetClass()
					local limbClass = RVATS.targetTypes[class]
					local limbData = v:GetLimbData()
					local abort = false
					clickTarget = nil

					if (limbData) then
						-- ikr? but I need to increase the compatibility.
						RVATS.apCalc = 0
						for boneEnum, limbData in pairs(limbData) do
							if (abort) then break end -- if the bone is not valid just bail

							local boneIndex = v:LookupBone(limbData.bone)

							if (boneIndex and boneIndex > 0) then
								local bonePos = v:GetBonePosition(boneIndex)
								local scrPos = bonePos:ToScreen()

								local x, y, w, h = scrPos.x, scrPos.y, minWidth, 70

								surface.SetDrawColor(ColorAlpha(RVATS.options.maincolor, 50))
								surface.DrawRect(x - w/2, y - h/2, w, h)

								hookClick(x - w/2, y - h/2, w, h, boneEnum)

								drawBracket(x, y, w, h)

								local selectionInfo = RVATS.selectionInfo[boneEnum]
								if (selectionInfo) then
									for i = 1, selectionInfo.count do
										RVATS.apCalc = RVATS.apCalc + limbData.ap
										drawBracket(x, y, w*(1 + 0.10*i), h*1.2, true)
									end
								end

								draw.TextShadow({
									text = limbData.name,
									font = "vatLimbFont",
									pos = {x, y - txu},
									color = RVATS.options.maincolor,
									xalign = 1,
									yalign = 1
								}, 1, 255)

								draw.TextShadow({
									text = 100 * limbData.baseChance,
									font = "vatChanceFont",
									pos = {x, y + txd},
									color = RVATS.options.maincolor,
									xalign = 1,
									yalign = 1
								}, 1, 255)
							else
								abort = true
							end
						end
					end

					if (RVATS.options.displayAP) then
						local x, y = w/2, h/5*4 - 2
						local bw, bh = w/8, 15
						local len = bracketLength
						local col = RVATS.options.maincolor

						surface.SetDrawColor(RVATS.options.maincolor)
						surface.DrawRect(x - bw/2, y - bh/2, bracketThicc, bh)
						surface.DrawRect(x + bw/2 - bracketThicc, y - bh/2, bracketThicc, bh)
						surface.DrawRect(x - bw/2, y + bh/2, bw, bracketThicc)

						surface.SetDrawColor(color_black)
						surface.DrawRect(x - bw/2, y + bh/2 + bracketThicc, bw, bracketShadow)
						surface.DrawRect(x - bw/2 + bracketThicc, y - bh/2, bracketShadow, bh - bracketShadow)
						surface.DrawRect(x + bw/2, y - bh/2, bracketShadow, bh + bracketThicc + bracketShadow)

						local stm = LocalPlayer():getLocalVar("stm")

						local maxWidth = bw - bracketThicc * 2
						surface.SetDrawColor(RVATS.options.maincolor)
						surface.DrawRect(x + bracketThicc - bw/2, y - bh/2, maxWidth*(stm/RVATS.APMaximum), bh)
						surface.SetDrawColor(RVATS.options.redcolor)
						surface.DrawRect(x + bracketThicc - bw/2, y - bh/2, maxWidth*(RVATS.apCalc/RVATS.APMaximum), bh)

						draw.TextShadow({
							text = "AP",
							font = "vatChanceFont",
							pos = {x - bw/2 - ScreenScale(7), y + bracketThicc},
							color = RVATS.options.maincolor,
							xalign = 1,
							yalign = 1
						}, 1, 255)

						draw.TextShadow({
							text = "[LMB] to Select [RMB] to Confirm [W] [A] to Cycle Targets",
							font = "vatHelpFont",
							pos = {x, y + bracketThicc + ScreenScale(10),},
							color = RVATS.options.maincolor,
							xalign = 1,
							yalign = 1
						}, 1, 255)

						draw.TextShadow({
							text = "[SPRINT] + [RMB] to cancel and exit",
							font = "vatHelpFont",
							pos = {x, y + bracketThicc + ScreenScale(10)*2,},
							color = RVATS.options.maincolor,
							xalign = 1,
							yalign = 1
						}, 1, 255)
					end

				end
			end

			if (RVATS.aimTarget:CanBeTargeted(LocalPlayer()) == false) then
				RVATS:nextTarget(LocalPlayer())
			end
		end
	end
	hook.Add("HUDPaint", "VATSDrawHook", RVATS.render2d)

	--lmao
	hook.Add( "Think", "VATSThinkHook", function( ms, vec )
		local currentTarget = RVATS.aimTarget

		if (IsValid(currentTarget)) then
			local mouse = input.IsMouseDown(MOUSE_LEFT) and 1 or (input.IsMouseDown(MOUSE_RIGHT) and 2 or 0)

			if (mouse > 0) then
				if (!trueClick) then
					if (mouse == 1) then
						if (clickTarget != nil) then
							if (!trueClick) then
								local limbData = currentTarget:GetLimbData()
								local canAddVAT = (RVATS.apCalc + limbData[clickTarget].ap <= LocalPlayer():getLocalVar("stm"))

								if (canAddVAT) then
									RVATS.selectionInfo[clickTarget] = RVATS.selectionInfo[clickTarget] or {
										count = 0,
									}

									RVATS.selectionInfo[clickTarget].count = RVATS.selectionInfo[clickTarget].count + 1

									table.insert(RVATS.selectionQueue, clickTarget)

									surface.PlaySound("vat_sel.mp3")
								end
							end
						end
					elseif (mouse == 2) then
						if (LocalPlayer():KeyDown(IN_SPEED)) then
							RVATS:removeTarget()
						else
							RVATS:sendInformation()
						end
					end

					trueClick = true
				end
			else
				trueClick = false
			end
		end
	end)


	hook.Add( "KeyPress", "VATSKeyHook", function( ply, key )
		local currentTarget = RVATS.aimTarget

		if (key == IN_WALK) then
			if (IsFirstTimePredicted()) then
				RVATS:enterVATS(ply, target, shotInfo)
			end
		end

		if (IsValid(currentTarget)) then
			if not IsFirstTimePredicted() then return end
			if not IsValid( ply ) or ply != LocalPlayer() then return end

			if ( key == IN_MOVELEFT ) then
				RVATS:prevTarget(LocalPlayer())

				surface.PlaySound("vat_next.mp3")
			elseif ( key == IN_MOVERIGHT ) then
				RVATS:nextTarget(LocalPlayer())

				surface.PlaySound("vat_next.mp3")
			end
		end
	end )

end
