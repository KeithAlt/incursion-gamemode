include("shared.lua")

local L = CasinoKit.L

local tblTexture = CreateMaterial("CasinoKit_table_green_" .. CurTime(), "VertexLitGeneric", {})
local tblBorderTexture = CreateMaterial("CasinoKit_table_border_" .. CurTime(), "VertexLitGeneric", {})
CasinoKit.getRemoteMaterial("http://i.imgur.com/O4Xw0tF.jpg", function(mat)
	tblTexture:SetTexture("$basetexture", mat:GetTexture("$basetexture"))
end, true)
CasinoKit.getRemoteMaterial("http://i.imgur.com/Kuy8cK8.jpg", function(mat)
	tblBorderTexture:SetTexture("$basetexture", mat:GetTexture("$basetexture"))
end, true)

local cvar_cinematics = CreateConVar("casinokit_cinematicmode", "0")
local cvar_tableIgnoreZ = CreateConVar("casinokit_ignorez", "1", FCVAR_ARCHIVE)

ENT.TableLocalOrigin = Vector(0, 0, 32.8)
ENT.TDUILocalOffsetMagnitude = 25

ENT.RenderGroup = RENDERGROUP_BOTH
function ENT:Draw()
	local ignoreZ = cvar_tableIgnoreZ:GetBool() and self:IsLocalPlayerSitting()

	if ignoreZ then cam.IgnoreZ(true) end

	self:DrawTableModel()
	if self.Game then self:DrawGame(self.Game) end

	if ignoreZ then cam.IgnoreZ(false) end
end

function ENT:DrawTableModel()
	self:DrawModel()

	-- Create the green texture round thing
	if not IsValid(self.OverlayModel) then
		self.OverlayModel = ClientsideModel("models/props_phx/construct/plastic/plastic_angle_360.mdl")
	end

	self.OverlayModel:SetNoDraw(true)
	self.OverlayModel:SetRenderOrigin(self:LocalToWorld(Vector(0, 0, 30.5)))
	self.OverlayModel:SetModelScale(0.7, 0)
	self.OverlayModel:SetRenderAngles(self:GetAngles())
	self.OverlayModel:SetupBones()

	render.MaterialOverrideByIndex(0, tblBorderTexture)
	render.MaterialOverrideByIndex(1, tblTexture)
	self.OverlayModel:DrawModel()
	render.MaterialOverrideByIndex(0)
	render.MaterialOverrideByIndex(1)
end

function ENT:DrawGame(game)
	game:drawTable(self, self.TableLocalOrigin)
end

function ENT:DrawGameUI(game, tdui)
	game:drawUI(self, tdui)
	tdui:Cursor()
end

function ENT:DrawTranslucent()
	local veh = LocalPlayer():GetVehicle()
	if IsValid(veh) and veh:CKit_IsSeat() and veh:CKit_GetTableEnt() == self then
		if not self.tdui then
			self.tdui = CasinoKit.tdui.Create()
			self.tdui:SetSkin("CasinoKit")
			self.tdui:SetIgnoreZ(true)
			self.tdui:SetUIScale(2.5)
		end

		local game = self.Game

		-- dont draw here if overview and game supports overview drawing
		if veh:GetThirdPersonMode() then return end

		if game then
			self:DrawGameUI(game, self.tdui)
		end

		local lpos, lang = self:SeatToLocal(veh:CKit_GetSeatIndex(), self.TDUILocalOffsetMagnitude)

		local uiPosOff, uiAngOff
		if self.Game and self.Game.getUIOffset then
			uiPosOff, uiAngOff = self.Game:getUIOffset(self)
		end

		self.tdui:BlockUseBind()

		local wpos = self:LocalToWorld(Vector(lpos.x, lpos.y, self.TableLocalOrigin.z + 21))
		local wang = (wpos - LocalPlayer():EyePos()):Angle() + (uiAngOff or Angle())

		if uiPosOff then
			local add = uiPosOff.x * lang:Right() + uiPosOff.y * lang:Forward() + uiPosOff.z * lang:Up()
			wpos.x = wpos.x + add.x
			wpos.y = wpos.y + add.y
			wpos.z = wpos.z + add.z
		end

		self.tdui:Render(wpos, wang, 0.02)
	elseif not cvar_cinematics:GetBool() then

		local overheadAlpha = 1 - (LocalPlayer():EyePos():Distance(self:GetPos()) / 512) ^ 2

		if overheadAlpha > 0 then
			local name = self.Game and self.Game:getGameFriendlyName()
			local subtext = self.Game and self.Game:getGameFriendlySubtext()

			local ang = LocalPlayer():EyeAngles()
			ang:RotateAroundAxis(ang:Right(), 90)
			ang:RotateAroundAxis(ang:Up(), -90)

			local textColor = Color(255, 255, 255, 255 * overheadAlpha)
			local textOutlineColor = Color(0, 0, 0, 255 * overheadAlpha)

			cam.Start3D2D(self:GetPos() + self:GetUp() * 100, ang, 0.2)
			draw.SimpleTextOutlined(name or "", "CasinoKitTableName", 0, 0, textColor, TEXT_ALIGN_CENTER, nil, 2, textOutlineColor)
			draw.SimpleTextOutlined(subtext or "", "CasinoKitTableSubtext", 0, 70, textColor, TEXT_ALIGN_CENTER, nil, 1, textOutlineColor)
			cam.End3D2D()
		end
	end
end

surface.CreateFont("CasinoKitTableName", {
	font = "Roboto",
	size = 80,
	weight = 800
})
surface.CreateFont("CasinoKitTableSubtext", {
	font = "Roboto",
	size = 40
})

function ENT:IsLocalPlayerSitting()
	local veh = LocalPlayer():GetVehicle()
	return IsValid(veh) and veh:CKit_IsSeat() and veh:CKit_GetTableEnt() == self
end

function ENT:GetMySeatIndex()
	local veh = LocalPlayer():GetVehicle()
	if IsValid(veh) and veh:CKit_IsSeat() and veh:CKit_GetTableEnt() == self then
		return veh:CKit_GetSeatIndex() or -1
	end
	return -1
end

-- DEPRECATED
ENT.GetSeatIndex = ENT.GetMySeatIndex

function ENT:Think()
	if not self.Game or self.Game.class.name ~= (self:GetClGameClass()) then
		local cls = CasinoKit.classes[self:GetClGameClass()]
		if cls then
			self.Game = cls()
			self.Game:setTableEntity(self)

			for _,data in pairs(self._messageQueue or {}) do
				self.Game:handleGameMessage(data.id, data.buf)
			end
			self._messageQueue = nil
		end
	end
end

function ENT:HandleGameMessage(id, buf)
	if self.Game then
		self.Game:handleGameMessage(id, buf)
	else
		self._messageQueue = self._messageQueue or {}
		table.insert(self._messageQueue, {id=id, buf=buf})
	end
end

function ENT:OnRemove()
	if IsValid(self.OverlayModel) then self.OverlayModel:Remove() end
end

local cvar_overviewZoom = CreateConVar("casinokit_overviewzoom", "0")
local cvar_overviewY = CreateConVar("casinokit_overviewy", "0")

hook.Add("SetupMove", "CasinoKit_OverviewInput", function(ply, mv, cmd)
	local veh = ply:GetVehicle()
	local wheel = cmd:GetMouseWheel()
	if wheel ~= 0 and IsValid(veh) and veh:CKit_IsSeat() and veh:GetThirdPersonMode() then
		cvar_overviewZoom:SetFloat(math.Clamp(cvar_overviewZoom:GetFloat() + wheel * -0.1, 0, 1))
	end
end)

function ENT:CalculateLocalHorizPosForAngle(rad, zoom)
	local a, b = self.TableEllipseA, self.TableEllipseB
	local px, py = a*math.cos(rad), b*math.sin(rad) -- position of ellipse vertex

	local horizOffset = math.Remap(zoom, 0, 1, 45, 10)
	return Vector(px * horizOffset, py * horizOffset, 0)
end

local function calcVehViewPAF(veh)
	local par = veh:CKit_GetTableEnt()

	local lpos
	do
		local vehHoriz = veh:GetPos()
		vehHoriz.z = 0
		local parHoriz = par:GetPos()
		parHoriz.z = 0

		local mySeatRad = math.rad((vehHoriz - parHoriz):Angle().y)
		
		lpos = par.TableLocalOrigin
			+ par:CalculateLocalHorizPosForAngle(mySeatRad, 1)
			+ Vector(0, 0, 20 + 60 * cvar_overviewZoom:GetFloat())
	end

	local pos = par:LocalToWorld(lpos)

	local tr = util.TraceLine {
		start = LocalPlayer():EyePos(),
		endpos = pos,
		mask =  MASK_SOLID_BRUSHONLY
	}

	pos = tr.HitPos + tr.HitNormal * 10

	local ang = (par:LocalToWorld(par.TableLocalOrigin) - pos):Angle()
	ang.p = 80

	return pos, ang, 90
end
hook.Add("CalcVehicleView", "CasinoKit_AboveView", function(veh, ply, view)
	if veh:CKit_IsSeat() and veh:GetThirdPersonMode() then
		local pos, ang, fov = calcVehViewPAF(veh)
		return {
			origin = pos,
			angles = ang,
			fov = fov
		}
	end
end)

hook.Add("PostDrawTranslucentRenderables", "CasinoKit_OverviewUI", function(drawingSkybox, drawingDepth)
	if drawingDepth then return end

	local veh = LocalPlayer():GetVehicle()
	if IsValid(veh) and veh:CKit_IsSeat() and veh:GetThirdPersonMode() then
		local table = veh:CKit_GetTableEnt()

		local tdui = table.tdui
		local game = table.Game

		if not tdui or not game or not game.enableOverviewUI then return end

		-- forces recalculation of screen mouse
		tdui._lastGEyeAngles = nil

		table:DrawGameUI(game, tdui)

		local pos, ang, fov = calcVehViewPAF(veh)
		pos = pos + ang:Forward() * 15 + ang:Right() * 14

		tdui:Render(pos, ang, 0.02)
	end
end)
hook.Add("ShouldDrawLocalPlayer", "CasinoKit_AboveView", function(ply)
	local veh = ply:GetVehicle()
	if IsValid(veh) and veh:CKit_IsSeat() and veh:GetThirdPersonMode() then
		return true
	end
end)

local sitTime = nil
local wasThirdp = false
hook.Add("HUDPaint", "CasinoKit_3rdPersonInfo", function()
	local veh = LocalPlayer():GetVehicle()

	if not IsValid(veh) or not veh:CKit_IsSeat() then
		sitTime = nil
		return
	end

	local isThirdPerson = veh:GetThirdPersonMode()

	-- reset sitTime if thirdp mode changed
	if wasThirdp ~= isThirdPerson then
		sitTime = nil
	end
	wasThirdp = isThirdPerson

	-- set sitTime if not set
	if not sitTime then
		sitTime = CurTime()
	end

	-- Calculate alpha according to time since sittime start
	local alpha = 1 - ((CurTime() - sitTime) / 5)^5
	if alpha < 0 then
		return
	end

	local switchBind = input.LookupBinding("+duck") or "[not bound]"

	local text = L(
		isThirdPerson and "ui_overviewleavehelp" or "ui_overviewenterhelp",
		{key = switchBind}
	)
	draw.SimpleTextOutlined(text, "DermaLarge", ScrW()/2, ScrH() - 150, Color(255, 255, 255, alpha*255), TEXT_ALIGN_CENTER, nil, 1, Color(0, 0, 0, alpha*255))

	if isThirdPerson then
		local game = veh:CKit_GetTableEnt().Game
		if game and game.enableOverviewUI then
			local mouseBind = input.LookupBinding("+menu_context") or "[not bound]"

			local text = L(
				"ui_overviewmousehelp",
				{key = mouseBind}
			)
			draw.SimpleTextOutlined(text, "DermaLarge", ScrW()/2, ScrH() - 110, Color(255, 255, 255, alpha*255), TEXT_ALIGN_CENTER, nil, 1, Color(0, 0, 0, alpha*255))
		end
	end
end)

concommand.Add("casinokit_starttabledebug", function()
	hook.Add("PostDrawTranslucentRenderables", "CasinoKitTableDebug", function()
		local t = (CurTime() * 5) % 40
		render.SetColorMaterial()
		for _,e in pairs(ents.GetAll()) do
			if e.CasinoKitTable then

				for i=1, e.SeatCount do
					local lpos0, lang = e:SeatToLocal(i, 0)
					local lpos1, lang = e:SeatToLocal(i, 40)
					render.DrawLine(e:LocalToWorld(lpos0), e:LocalToWorld(lpos1), Color(255, 255, 255), false)
					render.DrawLine(e:LocalToWorld(lpos1), e:LocalToWorld(lpos1) + lang:Forward() * -50, Color(255, 0, 0), false)

					local normal = lang:Forward()
					local b = normal.x / normal.y
					local d = lpos1.x - b*lpos1.y

					local isectX = d / (-b)
					render.DrawLine(e:LocalToWorld(Vector(0, isectX, 0)), e:LocalToWorld(lpos1), Color(255, 127, 0), false)

					local lpos, lang = e:SeatToLocal(i, t)
					render.DrawSphere(e:LocalToWorld(lpos) + Vector(0, 0, 50), 8, 4, 4, Color(255, 255, 255))
				end
			end
		end
	end)
end)