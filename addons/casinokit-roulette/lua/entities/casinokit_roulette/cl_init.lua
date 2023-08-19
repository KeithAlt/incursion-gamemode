local L = CasinoKit.L

include("shared.lua")

ENT.RenderGroup = RENDERGROUP_BOTH

local ROUL_INNER_RAD = ENT.ROUL_INNER_RAD
local ROUL_INNER_HEIGHT = ENT.ROUL_INNER_HEIGHT

local ROUL_MID_HEIGHT = ENT.ROUL_MID_HEIGHT

local ROUL_OUTER_RAD = ENT.ROUL_OUTER_RAD
local ROUL_OUTER_HEIGHT = ENT.ROUL_OUTER_HEIGHT

local ROUL_BORDER_HEIGHT = ENT.ROUL_BORDER_HEIGHT
local ROUL_TOTAL_RAD = ENT.ROUL_TOTAL_RAD

local ROUL_BALL_RAD = ENT.ROUL_BALL_RAD

local ROUL_BALL_MASS = ENT.ROUL_BALL_MASS
local ROUL_BALL_ROLLFRICTION_COEFFICIENT = ENT.ROUL_BALL_ROLLFRICTION_COEFFICIENT
local ROUL_BALL_ROLLSLIDEFRICTION_COEFFICIENT = ENT.ROUL_BALL_ROLLSLIDEFRICTION_COEFFICIENT

local METRIC_TO_SOURCE_SCALE = 29.52756 -- assuming 1 unit = 0.75 inch (source: VDW)

local ROUL_TOTAL_RAD_SOURCE = ROUL_TOTAL_RAD * METRIC_TO_SOURCE_SCALE
local ROUL_OUTER_RAD_SOURCE = ROUL_OUTER_RAD * METRIC_TO_SOURCE_SCALE
local ROUL_OUTER_HEIGHT_SOURCE = ROUL_OUTER_HEIGHT * METRIC_TO_SOURCE_SCALE
local ROUL_INNER_RAD_SOURCE = ROUL_INNER_RAD * METRIC_TO_SOURCE_SCALE
local ROUL_INNER_HEIGHT_SOURCE = ROUL_INNER_HEIGHT * METRIC_TO_SOURCE_SCALE
local ROUL_MID_HEIGHT_SOURCE = ROUL_MID_HEIGHT * METRIC_TO_SOURCE_SCALE
local ROUL_BORDER_HEIGHT_SOURCE = ROUL_BORDER_HEIGHT * METRIC_TO_SOURCE_SCALE

local ROUL_INOUT_RATIO = ROUL_INNER_RAD / ROUL_OUTER_RAD

local CIRCLE_POINTS = 40
local RADS_PER_POINT = math.pi * 2 / CIRCLE_POINTS

local obj = Mesh()
local verts = {}

for i=1, CIRCLE_POINTS do
	-- Top plane
	local rad0, rad1 = RADS_PER_POINT * i, RADS_PER_POINT * (i + 1)
	local rad0x, rad0y = math.cos(rad0), math.sin(rad0)
	local rad1x, rad1y = math.cos(rad1), math.sin(rad1)

	local u0, v0 = rad0x * 0.5 + 0.5, rad0y * 0.5 + 0.5
	local u1, v1 = rad1x * 0.5 + 0.5, rad1y * 0.5 + 0.5

	local iu0, iv0 = rad0x * ROUL_INOUT_RATIO * 0.5 + 0.5, rad0y * ROUL_INOUT_RATIO * 0.5 + 0.5
	local iu1, iv1 = rad1x * ROUL_INOUT_RATIO * 0.5 + 0.5, rad1y * ROUL_INOUT_RATIO * 0.5 + 0.5

	table.insert(verts, { pos = Vector(rad0x*ROUL_OUTER_RAD_SOURCE, rad0y*ROUL_OUTER_RAD_SOURCE, ROUL_OUTER_HEIGHT_SOURCE), normal = Vector(0, 0, 1), u = 1-u0, v = v0 })
	table.insert(verts, { pos = Vector(rad1x*ROUL_INNER_RAD_SOURCE, rad1y*ROUL_INNER_RAD_SOURCE, ROUL_MID_HEIGHT_SOURCE), normal = Vector(0, 0, 1), u = 1-iu1, v = iv1 })
	table.insert(verts, { pos = Vector(rad1x*ROUL_OUTER_RAD_SOURCE, rad1y*ROUL_OUTER_RAD_SOURCE, ROUL_OUTER_HEIGHT_SOURCE), normal = Vector(0, 0, 1), u = 1-u1, v = v1 })

	table.insert(verts, { pos = Vector(rad0x*ROUL_OUTER_RAD_SOURCE, rad0y*ROUL_OUTER_RAD_SOURCE, ROUL_OUTER_HEIGHT_SOURCE), normal = Vector(0, 0, 1), u = 1-u0, v = v0 })
	table.insert(verts, { pos = Vector(rad0x*ROUL_INNER_RAD_SOURCE, rad0y*ROUL_INNER_RAD_SOURCE, ROUL_MID_HEIGHT_SOURCE), normal = Vector(0, 0, 1), u = 1-iu0, v = iv0 })
	table.insert(verts, { pos = Vector(rad1x*ROUL_INNER_RAD_SOURCE, rad1y*ROUL_INNER_RAD_SOURCE, ROUL_MID_HEIGHT_SOURCE), normal = Vector(0, 0, 1), u = 1-iu1, v = iv1 })

	table.insert(verts, { pos = Vector(rad0x*ROUL_INNER_RAD_SOURCE, rad0y*ROUL_INNER_RAD_SOURCE, ROUL_MID_HEIGHT_SOURCE), normal = Vector(0, 0, 1), u = 1-iu0, v = iv0 })
	table.insert(verts, { pos = Vector(0, 0, ROUL_INNER_HEIGHT_SOURCE), normal = Vector(0, 0, 1), u = 0.5, v = 0.5 })
	table.insert(verts, { pos = Vector(rad1x*ROUL_INNER_RAD_SOURCE, rad1y*ROUL_INNER_RAD_SOURCE, ROUL_MID_HEIGHT_SOURCE), normal = Vector(0, 0, 1), u = 1-iu1, v = iv1 })
end
obj:BuildFromTriangles(verts)

local out_obj = Mesh()
local out_verts = {}

local function map_out_u(u)
	return math.Remap(u, 0, 1, 0.6, 0.9)
end
local function map_out_v(v)
	return math.Remap(v, 0, 1, 0.8, 0.9)
end

local LOWER_BORDER_RAD_SOURCE = ROUL_TOTAL_RAD_SOURCE - 0.1
local LOWER_BORDER_HEIGHT_SOURCE = ROUL_BORDER_HEIGHT_SOURCE - 1

for i=1, CIRCLE_POINTS do
	-- Top plane
	local rad0, rad1 = RADS_PER_POINT * i, RADS_PER_POINT * (i + 1)
	local rad0x, rad0y = math.cos(rad0), math.sin(rad0)
	local rad1x, rad1y = math.cos(rad1), math.sin(rad1)

	local u0, v0 = rad0x * 0.5 + 0.5, rad0y * 0.5 + 0.5
	local u1, v1 = rad1x * 0.5 + 0.5, rad1y * 0.5 + 0.5

	local iu0, iv0 = rad0x * ROUL_INOUT_RATIO * 0.5 + 0.5, rad0y * ROUL_INOUT_RATIO * 0.5 + 0.5
	local iu1, iv1 = rad1x * ROUL_INOUT_RATIO * 0.5 + 0.5, rad1y * ROUL_INOUT_RATIO * 0.5 + 0.5

	table.insert(out_verts, { pos = Vector(rad0x*LOWER_BORDER_RAD_SOURCE, rad0y*LOWER_BORDER_RAD_SOURCE, LOWER_BORDER_HEIGHT_SOURCE), normal = Vector(0, 0, 1), u = map_out_u(u0), v = map_out_v(v0) })
	table.insert(out_verts, { pos = Vector(rad1x*ROUL_OUTER_RAD_SOURCE, rad1y*ROUL_OUTER_RAD_SOURCE, ROUL_OUTER_HEIGHT_SOURCE), normal = Vector(0, 0, 1), u = map_out_u(iu1), v = map_out_v(iv1) })
	table.insert(out_verts, { pos = Vector(rad1x*LOWER_BORDER_RAD_SOURCE, rad1y*LOWER_BORDER_RAD_SOURCE, LOWER_BORDER_HEIGHT_SOURCE), normal = Vector(0, 0, 1), u = map_out_u(u1), v = map_out_v(v1) })

	table.insert(out_verts, { pos = Vector(rad0x*LOWER_BORDER_RAD_SOURCE, rad0y*LOWER_BORDER_RAD_SOURCE, LOWER_BORDER_HEIGHT_SOURCE), normal = Vector(0, 0, 1), u = map_out_u(u0), v = map_out_v(v0) })
	table.insert(out_verts, { pos = Vector(rad0x*ROUL_OUTER_RAD_SOURCE, rad0y*ROUL_OUTER_RAD_SOURCE, ROUL_OUTER_HEIGHT_SOURCE), normal = Vector(0, 0, 1), u = map_out_u(iu0), v = map_out_v(iv1) })
	table.insert(out_verts, { pos = Vector(rad1x*ROUL_OUTER_RAD_SOURCE, rad1y*ROUL_OUTER_RAD_SOURCE, ROUL_OUTER_HEIGHT_SOURCE), normal = Vector(0, 0, 1), u = map_out_u(iu1), v = map_out_v(iv1) })
end
out_obj:BuildFromTriangles(out_verts)

local out2_obj = Mesh()
local out2_verts = {}

for i=1, CIRCLE_POINTS do
	-- Top plane
	local rad0, rad1 = RADS_PER_POINT * i, RADS_PER_POINT * (i + 1)
	local rad0x, rad0y = math.cos(rad0), math.sin(rad0)
	local rad1x, rad1y = math.cos(rad1), math.sin(rad1)

	local u0, v0 = rad0x * 0.5 + 0.5, rad0y * 0.5 + 0.5
	local u1, v1 = rad1x * 0.5 + 0.5, rad1y * 0.5 + 0.5

	local iu0, iv0 = rad0x * ROUL_INOUT_RATIO * 0.5 + 0.5, rad0y * ROUL_INOUT_RATIO * 0.5 + 0.5
	local iu1, iv1 = rad1x * ROUL_INOUT_RATIO * 0.5 + 0.5, rad1y * ROUL_INOUT_RATIO * 0.5 + 0.5

	table.insert(out2_verts, { pos = Vector(rad0x*ROUL_TOTAL_RAD_SOURCE, rad0y*ROUL_TOTAL_RAD_SOURCE, ROUL_BORDER_HEIGHT_SOURCE), normal = Vector(0, 0, 1), u = map_out_u(u0), v = map_out_v(v0) })
	table.insert(out2_verts, { pos = Vector(rad1x*LOWER_BORDER_RAD_SOURCE, rad1y*LOWER_BORDER_RAD_SOURCE, LOWER_BORDER_HEIGHT_SOURCE), normal = Vector(0, 0, 1), u = map_out_u(iu1), v = map_out_v(iv1) })
	table.insert(out2_verts, { pos = Vector(rad1x*ROUL_TOTAL_RAD_SOURCE, rad1y*ROUL_TOTAL_RAD_SOURCE, ROUL_BORDER_HEIGHT_SOURCE), normal = Vector(0, 0, 1), u = map_out_u(u1), v = map_out_v(v1) })

	table.insert(out2_verts, { pos = Vector(rad0x*ROUL_TOTAL_RAD_SOURCE, rad0y*ROUL_TOTAL_RAD_SOURCE, ROUL_BORDER_HEIGHT_SOURCE), normal = Vector(0, 0, 1), u = map_out_u(u0), v = map_out_v(v0) })
	table.insert(out2_verts, { pos = Vector(rad0x*LOWER_BORDER_RAD_SOURCE, rad0y*LOWER_BORDER_RAD_SOURCE, LOWER_BORDER_HEIGHT_SOURCE), normal = Vector(0, 0, 1), u = map_out_u(iu0), v = map_out_v(iv1) })
	table.insert(out2_verts, { pos = Vector(rad1x*LOWER_BORDER_RAD_SOURCE, rad1y*LOWER_BORDER_RAD_SOURCE, LOWER_BORDER_HEIGHT_SOURCE), normal = Vector(0, 0, 1), u = map_out_u(iu1), v = map_out_v(iv1) })
end
out2_obj:BuildFromTriangles(out2_verts)

local WheelBallModel = ClientsideModel("models/XQM/Rails/gumball_1.mdl")
WheelBallModel:SetNoDraw(true)

local wheelMatrix = Matrix()

local mater
local out_mater

local WHEEL_CENTER = Vector(6.3, -27.5, 15)

function ENT:Draw()
	self:DrawModel()

	if not self.Assets:load() then
		return
	end

	if not mater then
		mater = CreateMaterial("TDUI_RouletteMater" .. os.time(), "VertexLitGeneric", {})
		mater:SetTexture("$basetexture", Material("models/casinokit/roulette/innerwheel.png", "vertexlitgeneric mips"):GetTexture("$basetexture"))
	end
	out_mater = out_mater or Material("models/casinokit/roulette/Table")

	wheelMatrix:Identity()
	wheelMatrix:Translate(self:LocalToWorld(WHEEL_CENTER))
	wheelMatrix:Rotate(self:LocalToWorldAngles(Angle(0, 175 + math.deg(self:GetWheelAngle()), 0)))

	cam.PushModelMatrix(wheelMatrix)
	render.SetMaterial(mater)
	obj:Draw()
	cam.PopModelMatrix()

	wheelMatrix:Identity()
	wheelMatrix:Translate(self:LocalToWorld(WHEEL_CENTER))
	wheelMatrix:Rotate(self:LocalToWorldAngles(Angle(0, 0, 0)))

	cam.PushModelMatrix(wheelMatrix)
	render.SetMaterial(out_mater)
	out_obj:Draw()
	out2_obj:Draw()
	cam.PopModelMatrix()

	if self.RollData then
		local ballpos = self:SimulateBall(self.RollData.start, self.RollData.strength)

		WheelBallModel:SetRenderOrigin(self:LocalToWorld(ballpos * METRIC_TO_SOURCE_SCALE + WHEEL_CENTER))
		WheelBallModel:SetModelScale(ROUL_BALL_RAD * 2, 0)
		WheelBallModel:SetupBones()

		WheelBallModel:DrawModel()


		if self.WheelBallSound ~= true and IsValid(self.WheelBallSound) then
			local elapsed = CurTime() - self.RollData.start
			local ballStopTime = self:GetBallStopTime(self.RollData.strength)

			local shouldPlay = elapsed < ballStopTime

			if shouldPlay and self.WheelBallSound:GetState() ~= STATE_PLAYING then
				self.WheelBallSound:Play()
			elseif not shouldPlay and self.WheelBallSound:GetState() ~= STATE_PAUSED then
				self.WheelBallSound:Pause()
			end
			self.WheelBallSound:SetPos(self:LocalToWorld(ballpos))
		end
	end

	if not self.WheelBallSound then
		self.WheelBallSound = true
		sound.PlayFile("sound/casinokit/roulette/roulette_loop1.ogg", "3d", function(chan, e, i)
			if not chan then
				MsgN("[CasinoKit] Failed to load roulette loop; ", e, i)
				return
			end
			chan:SetVolume(0.1)
			self.WheelBallSound = chan
		end)
	end
end

function ENT:SendBet(id, param)
	if not self.localBet or self.localBet <= 0 then
		LocalPlayer():ChatPrint(L"roul_setbet")
		return
	end

	net.Start("ckit_roul_bet")
	net.WriteEntity(self)
	net.WriteString(id)
	net.WriteString(param or "")
	net.WriteUInt(self.localBet, 32)
	net.SendToServer()
end

local clr_red_no = Color(255, 20, 20, 220)
local clr_black_no = Color(20, 20, 20, 220)
local clr_green_no = Color(20, 255, 20, 220)


function ENT:DrawTDUIChip(amount, x, y, oldChips)
	return CasinoKit.drawChipSingleStack(amount, self:TDUIXYToWorldPosition(x, y) + Vector(0, 0, (oldChips or 0) * 0.135), Angle(0, 0, 0), nil, oldChips)
end

-- keep a counter to make sure deferred bets don't get placed
local clearsDone = 0
net.Receive("ckit_roul_bet", function()
	local ent = net.ReadEntity()

	local betId = net.ReadString()
	local betParam = net.ReadString()
	local betIdParam = betId .. "-" .. betParam

	local amount = net.ReadUInt(32)

	if not IsValid(ent) then return end

	ent.ExistingBets = ent.ExistingBets or {}
	ent.ExistingBets[betIdParam] = ent.ExistingBets[betIdParam] or {}

	local beforeTimerCD = clearsDone

	-- defer placement to make chip animation look nice
	timer.Simple(1, function()
		if clearsDone ~= beforeTimerCD then return end

		table.insert(ent.ExistingBets[betIdParam], {amount = amount})
	end)
end)
net.Receive("ckit_roul_clearbet", function()
	local ent = net.ReadEntity()
	if not IsValid(ent) then return end

	ent.ExistingBets = {}
	clearsDone = clearsDone + 1
end)

function ENT:DrawTDUIBets(betId, betParam, x, y)
	local ebets = self.ExistingBets and self.ExistingBets[("%s-%s"):format(betId, betParam)]
	if not ebets then return 0 end

	local da = 0
	for _,ebet in pairs(ebets) do
		da = da + self:DrawTDUIChip(ebet.amount, x, y, da)
	end
	return da
end

local MAX_DIST_SQ = math.pow(126, 2)

local betset_spots = {
	{pos = Vector(21, -9, 14.2), ang = Angle(90, 180, 0)},
	{pos = Vector(21, 20, 14.2), ang = Angle(90, 180, 0)},
	{pos = Vector(12, 40, 14.2), ang = Angle(90, -90, 0)},
	{pos = Vector(-11.5, 32, 14.2), ang = Angle(90, 0, 0)},
}

local expand_bounds_fn = function(self)
	self:_ExpandRenderBounds(-240, -160, 600, 500)
end

surface.CreateFont("CKitRoulInfo", {
	font = "Roboto",
	size = 23,
	weight = 800
})
surface.CreateFont("CKitRoulInfoBig", {
	font = "Roboto",
	size = 30,
	weight = 800
})

local tdui = CasinoKit.tdui
function ENT:DrawTranslucent()
	if LocalPlayer():EyePos():DistToSqr(self:GetPos()) > MAX_DIST_SQ then return end

	self:DrawModel() -- needed so that chips are shaded properly

	self.p = self.p or tdui.Create()
	local p = self.p

	local table_x, table_y = -240, 100

	for _,bp in pairs(self.BettingPositions) do
		local pressed, _, hovered = p:TestAreaInput(bp.inner_x, bp.inner_y, bp.inner_w, bp.inner_h)

		local chipsDrawn = self:DrawTDUIBets(bp.betId, bp.betParam, bp.chip_x, bp.chip_y)
		if pressed then
			self:SendBet(bp.betId, bp.betParam)
		end
		if hovered then
			self:DrawTDUIChip(self.localBet or 0, bp.chip_x, bp.chip_y, (chipsDrawn == 0 and 0 or (chipsDrawn + 2)) + (CurTime() * 0.1 % 1))
		end
	end

	local num = "-"
	local numcolor = clr_black_no

	if self.RollData then
		num = self:GetBallNumber(self.RollData.start, self.RollData.strength)

		if table.HasValue(self.RedNumbers, num) then
			numcolor = clr_red_no
		elseif num == 0 or num == "00" then
			numcolor = clr_green_no
		else
			numcolor = clr_black_no
		end
	end

	if not self:GetRolling() then
		p:Text(L("roul_nextroll", {seconds = math.floor(self:GetTimeToNextRoll())}), "CKitRoulInfo", -120, 70, nil, TEXT_ALIGN_LEFT)
	end

	p:Text(L"roul_number", "CKitRoulInfo", -240, 70, nil, TEXT_ALIGN_LEFT)
	p:Text(num, "CKitRoulInfoBig", -160, 67, numcolor, TEXT_ALIGN_LEFT)

	p:Text(L("roul_minbet", {amount = self:GetMinBet()}), "CKitRoulInfo", -240, 345, nil, TEXT_ALIGN_LEFT)
	local mtb = self:GetMaxTotalBet()
	if mtb > 0 then
		p:Text(L("roul_maxbet", {amount = mtb}), "CKitRoulInfo", -60, 345, nil, TEXT_ALIGN_LEFT)
	end

	p:Custom(expand_bounds_fn)
	p:Cursor()

    p:Render(self:LocalToWorld(self.TDUIOffset), self:LocalToWorldAngles(self.TDUIAngle), self.TDUIScale)

	self.betp = self.betp or tdui.Create()
	local betp = self.betp

	local delta = (input.IsShiftDown() and (input.IsKeyDown(KEY_LALT) and 100 or 10) or 1)
	if betp:Button("<", "!Roboto@20", 0, 0, 30, 30) then
		self.localBet = math.max((self.localBet or 0) - delta, self:GetMinBet())
	end
	betp:Rect(35, 0, 70, 30)
	if betp:Button("", "!Roboto@20", 35, 0, 70, 30) then
		local fr = vgui.Create("DFrame")
		fr:SetSkin("CasinoKit")
		fr:SetSize(180, 50)
		fr:SetTitle("Set Bet")
		fr:Center()

		local txt = fr:Add("DTextEntry")
		txt.OnEnter = function()
			local num = tonumber(txt:GetText())
			if num then
				self.localBet = math.max(num, self:GetMinBet())
			else
				LocalPlayer():ChatPrint("Only numeric bets allowed!")
			end

			fr:Close()
		end
		txt:Dock(FILL)
		txt:RequestFocus()

		fr:MakePopup()
	end
	betp:Text(self.localBet or 0, "!Roboto@22", 70, 4, tdui.COLOR_WHITE)
	if betp:Button(">", "!Roboto@20", 110, 0, 30, 30) then
		self.localBet = math.max((self.localBet or 0) + delta, self:GetMinBet())
	end

    betp:Cursor()

	local leyepos = self:WorldToLocal(LocalPlayer():EyePos())

	local thespot, thespotdist = nil, math.huge
	for _,spot in pairs(betset_spots) do
		local dist = leyepos:Distance(spot.pos)
		if dist < thespotdist then
			thespot = spot
			thespotdist = dist
		end
	end

	CasinoKit.drawChipStack(LocalPlayer():CKit_GetChips() or 0, self:LocalToWorld(thespot.pos + thespot.ang:Right()*-4 + thespot.ang:Up()*-1), self:LocalToWorldAngles(thespot.ang), true)

	betp:Render(self:LocalToWorld(thespot.pos), self:LocalToWorldAngles(thespot.ang), 0.1)
end

function ENT:Roll(startTime, strength)
	self.RollData = {
		start = startTime,
		strength = strength
	}
	self:EmitSound("casinokit/roulette/roulette_start1.ogg")
end
net.Receive("ckit_roul_roll", function()
	local e = net.ReadEntity()
	local startTime, strength = net.ReadDouble(), net.ReadDouble()
	if IsValid(e) then
		e:Roll(startTime, strength)
	end
end)