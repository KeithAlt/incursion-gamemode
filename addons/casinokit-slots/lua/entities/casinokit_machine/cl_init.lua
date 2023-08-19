include("shared.lua")

ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:Think()
	if (not self._lastBet or self._lastBet ~= self:GetBet()) then
		self:SetAdDirty()
		self._lastBet = self:GetBet()
	end
end

ENT.AD_VERT_SEPARATOR = 0.55
ENT.AD_UPPER_HEIGHT = ENT.AD_VERT_SEPARATOR
ENT.AD_LOWER_Y = ENT.AD_UPPER_HEIGHT
ENT.AD_LOWER_HEIGHT = 1 - ENT.AD_UPPER_HEIGHT

ENT.AD_WIDTH = 0.62

ENT.SCREEN_HEIGHT = 0.85

ENT.ScreenIdleColor = Color(255, 255, 255)
function ENT:GetScreenIdleColorVector()
	local c = self.ScreenIdleColor
	return Vector(c.r/255, c.g/255, c.b/255)
end

function ENT:SetAdDirty()
	self.AdDirty = true
end

local TEXFLAG_ANISOTROPIC = 0x0010
local TEXFLAG_NODEPTH =  0x800000
local PROJRT_TEXFLAGS = bit.bor(TEXFLAG_ANISOTROPIC, TEXFLAG_NODEPTH)


function ENT:ShouldUpdateRTs()
	if not self.FirstUpdate then
		self.FirstUpdate = true
		return true
	end
	return self:IsWithinDrawDistance()
end
function ENT:IsWithinDrawDistance()
	local eyePos, thisPos = LocalPlayer():EyePos(), self:GetPos()
	if eyePos:DistToSqr(thisPos) > (128^2) then
		return false
	end

	-- check that eyepos can actually see the game
	local nor = (thisPos - eyePos)
	nor:Normalize()
	if nor:Dot(self:GetRight()) < 0 then
		return false
	end

	return true
end

function ENT:IsWithinPassiveDrawDistance()
	local eyePos, thisPos = LocalPlayer():EyePos(), self:GetPos()
	if eyePos:DistToSqr(thisPos) > (350^2) then
		return false
	end

	return true
end

function ENT:Draw()
	if not self.Assets:load() then
		return
	end

	if not self:IsWithinPassiveDrawDistance() then
		self:DrawModel()
		return
	end

	if self:ShouldUpdateRTs() then
		draw.NoTexture()

		--if (self.AdDirty == true or self.AdDirty == nil) or (not self.NextAdIdleUpdate or self.NextAdIdleUpdate < CurTime()) then
			self.AdDirty = false

			local rt_ad = GetRenderTargetEx(("CKitMachineAd_%d"):format(self:EntIndex()), 512, 512,
				RT_SIZE_NO_CHANGE,
				MATERIAL_RT_DEPTH_NONE,
				PROJRT_TEXFLAGS,
				CREATERENDERTARGETFLAGS_HDR,
				IMAGE_FORMAT_BGR888)
			render.PushRenderTarget(rt_ad)

			local sic = self.ScreenIdleColor
			render.Clear(sic.r, sic.g, sic.b, 255, false, false)
			cam.Start2D()
			self:DrawGameAdvert(512 * self.AD_WIDTH, 512)
			cam.End2D()
			render.PopRenderTarget()

			self.NextAdIdleUpdate = CurTime() + 15
		--end

		local rt_screen = GetRenderTargetEx(("CKitMachineScreen_%d"):format(self:EntIndex()), 512, 512,
			RT_SIZE_NO_CHANGE,
			MATERIAL_RT_DEPTH_NONE,
			PROJRT_TEXFLAGS,
			CREATERENDERTARGETFLAGS_HDR,
			IMAGE_FORMAT_BGR888)
		render.PushRenderTarget(rt_screen)

		local sic = self.ScreenIdleColor
		render.Clear(sic.r, sic.g, sic.b, 255, false, false)
		cam.Start2D()
		self:DrawGameScreen(512, 512 * self.SCREEN_HEIGHT)
		cam.End2D()
		render.PopRenderTarget()
	end

	local mat_ad = self.RTMatAd
	if not mat_ad then
		local name = "CKitMachineAd_" .. self:EntIndex()
		self.RTMatAd = CreateMaterial(name, "UnLitGeneric", {})
		self.RTMatAd:SetTexture("$basetexture", name)
		mat_ad = self.RTMatAd
	end

	local mat_screen = self.RTMatScreen
	if not mat_screen then
		local name = "CKitMachineScreen_" .. self:EntIndex()
		self.RTMatScreen = CreateMaterial(name, "UnLitGeneric", {})
		self.RTMatScreen:SetTexture("$basetexture", name)
		mat_screen = self.RTMatScreen
	end

	render.MaterialOverrideByIndex(2, mat_screen)
	render.MaterialOverrideByIndex(3, mat_ad)
	self:DrawModel()
	render.MaterialOverride()

	if self:IsWithinDrawDistance() then
		self:DrawButtons()
	end
end

function ENT:DrawGameAdvert(w, h)
	self:DrawGameTopAdvert(0, 0, w, h * self.AD_UPPER_HEIGHT)
	self:DrawGameBottomAdvert(0, h * self.AD_LOWER_Y, w, h * self.AD_LOWER_HEIGHT)
end

function ENT:DrawGameTopAdvert(x, y, w, h)
	surface.SetDrawColor(255, 0, 0)
	surface.DrawRect(x, y, w, h)
end
function ENT:DrawGameBottomAdvert(x, y, w, h)
	surface.SetDrawColor(0, 255, 0)
	surface.DrawRect(x, y, w, h)
end

function ENT:DrawGameScreen(w, h)
	surface.SetDrawColor(255, 0, 0)
	surface.DrawRect(0, 0, w/2, h/2)

	surface.SetDrawColor(0, 0, 255)
	surface.DrawRect(w/2, h/2, w/2, h/2)
end

function ENT:DrawNotification()
	local n = self._notification

	if not n then
		return
	end

	surface.SetDrawColor(255, 0, 0)
	surface.DrawRect(0, 135, 512, 35)

	draw.SimpleText(n.msg, "CKVideoPokerInfoSmall", 256, 140, nil, TEXT_ALIGN_CENTER)
end

function ENT:HandleNotification(msg, type)
	self._notification = {
		time = CurTime(),
		msg = msg,
		type = type
	}
end

net.Receive("ckit_slotnotify", function(len, cl)
	local e, b, m, t = net.ReadEntity(), net.ReadBool(), net.ReadString(), net.ReadString()
	if IsValid(e) then
		if b then
			e:HandleNotification(m, t)
		else
			e._notification = nil
		end
	end
end)

local buttonModel

surface.CreateFont("CKitSlotBtnFont", {
	font = "Roboto",
	size = 80,
	weight = 800
})

local buttonGlow = CreateMaterial("CKitSlotButtonGlow", "UnLitGeneric", {
    ["$basetexture"] = "sprites/glow03",
    ["$nocull"] = 1,
    ["$additive"] = 1,
    ["$translucent"] = 1,
    ["$vertexalpha"] = 1,
    ["$vertexcolor"] = 1,
})

local rtid = 0

function ENT:GetButtons() return self.Buttons end

function ENT:DrawButtons()
	local buttons = self:GetButtons()
	if not buttons then return end

	-- Load button model if it hasn't been created
	if not buttonModel then
		buttonModel = ClientsideModel("models/casinokit/slot-button.mdl", RENDERGROUP_OPAQUE)
		buttonModel:SetNoDraw(true)
		buttonModel:SetModelScale(1.5, 0)
	end

	local wasUSE, isUSE = self._wasUSE, self._isUSE
	local isUsing = LocalPlayer():KeyDown(IN_USE) or LocalPlayer():KeyDown(IN_ATTACK)
	do
		if isUsing ~= wasUSE then
			isUSE = isUsing
			wasUSE = isUsing
		else
			isUSE = false
		end

		self._wasUSE = wasUSE
		self._isUSE = isUSE
	end

	for _,btn in pairs(buttons) do
		local slot = btn.slot or 1

		local pos = self:LocalToWorld(Vector(-10 + (slot-1)*3, 7, 9.2))
		local ang = self:LocalToWorldAngles(Angle(0, 0, -30))

		local tr = LocalPlayer():GetEyeTrace()
		local eyepos = tr.StartPos
		local eyenormal

		if vgui.IsHoveringWorld() and vgui.CursorVisible() then
			eyenormal = gui.ScreenToVector(gui.MousePos())
		else
			eyenormal = tr.Normal
		end

		local isect = util.IntersectRayWithOBB(eyepos, eyenormal * 99999, pos, ang, Vector(-1.3, -1.3, 0), Vector(1.3, 1.3, 0.5))
		local hovering = not not isect

		if not btn._tex then
			local rtnm = "CKitSlotBtn." .. self:GetClass():sub(-5) .. "." .. btn.text:Replace(" ", "") .. "_" .. rtid
			rtid = rtid + 1

			local rt = GetRenderTarget(util.CRC(rtnm), 256, 256, false)
			render.PushRenderTarget(rt)
			render.Clear(btn.clr.r, btn.clr.g, btn.clr.b, 255)

			cam.Start2D()
			--draw.SimpleText(tostring(slot), "DermaLarge", 32, 32, Color(0, 0, 0))
			draw.SimpleText(btn.text, "CKitSlotBtnFont", 128, 128, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			cam.End2D()

			render.PopRenderTarget()

			btn._tex = rt

			btn._onMat = CreateMaterial(rtnm .. ".on", "UnlitGeneric", {})
			btn._onMat:SetInt("$model", 1)
			btn._onMat:SetTexture("$basetexture", rt)

			btn._offMat = CreateMaterial(rtnm .. ".off", "VertexLitGeneric", {})
			btn._offMat:SetTexture("$basetexture", rt)
			btn._offMat:SetVector("$color2", Vector(0.3, 0.3, 0.3))
 		end

		buttonModel:SetRenderOrigin(pos)
		buttonModel:SetRenderAngles(ang)

		local isPressing = hovering and isUsing
		btn._pressFrac = math.Approach(btn._pressFrac or 0, isPressing and 1 or 0, FrameTime() * 10)
		buttonModel:SetPoseParameter("switch", btn._pressFrac)

		buttonModel:SetupBones()

		local isOn = not btn.glow or btn.glow(self)

		render.MaterialOverrideByIndex(0, isOn and btn._onMat or btn._offMat)
		buttonModel:DrawModel()
		render.MaterialOverride()

		if isOn then
			render.SetMaterial(buttonGlow)
			render.DrawSprite(pos + ang:Up() * 0.1, 16, 16, ColorAlpha(btn.clr, hovering and 48 or 24))
		end

		if hovering and isUSE then
			btn.fn(self)

			sound.PlayFile("sound/casinokit/slots/button-0" .. (math.random(3)) .. ".ogg", "3d", function(c, ...) if c then c:SetPos(isect) end end)
		end
	end
end

function ENT:DoSimpleAction(id)
	net.Start("ckit_slotact")
	net.WriteEntity(self)
	net.WriteString(id)
	net.SendToServer()
end

local tdui = CasinoKit.tdui

tdui.RegisterSkin("ckitslotskin", {
	button = {
		fgColor = tdui.COLOR_BLACK,
		fgHoverColor = tdui.COLOR_ORANGE,
		fgPressColor = tdui.COLOR_WHITE,

		bgColor = tdui.COLOR_BLACK_TRANSPARENT,
		bgHoverColor = tdui.COLOR_BLACK_TRANSPARENT,
		bgPressColor = tdui.COLOR_BLACK_TRANSPARENT,
	}
})

local matCursor = Material("icon16/cursor.png")
hook.Add("HUDPaint", "CasinoKitMachines.DrawCursor", function()
	local tr = LocalPlayer():GetEyeTrace()
	if IsValid(tr.Entity) and tr.Entity.CasinoKitSlotMachine and tr.Entity:IsWithinDrawDistance() and not vgui.CursorVisible() then
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(matCursor)
		local scr = tr.HitPos:ToScreen()
		if scr.visible then
			surface.DrawTexturedRect(scr.x, scr.y, 20, 20)
		else
			surface.DrawTexturedRect(ScrW()/2, ScrH()/2, 20, 20)
		end
	end
end)