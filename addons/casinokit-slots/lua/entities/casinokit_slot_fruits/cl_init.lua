local L = CasinoKit.L

include("shared.lua")
DEFINE_BASECLASS"casinokit_machine"

game.AddParticles("particles/achievement.pcf")

function ENT:Think()
	BaseClass.Think(self)

	if (not self._lastJackpot or self._lastJackpot ~= self:GetJackpot()) then
		self:SetAdDirty()
		self._lastJackpot = self:GetJackpot()
	end
end

local height_segments = 5

local function easefunc(f)
	--[[
	f = f * 2

	if f < 1 then
		return 0.5 * f * f
	else
		f = f - 1
		return -0.5 * (f * (f-2) - 1)
	end]]
	f = f - 1
	return f*f*f + 1
	--return -1 * f * (f-2)
end

local tau = math.pi * 2
local function approachRad(from, to)
	local diff = (to - from)
	if diff > 0 then
		local overflowDiff = from + (tau - to)
		if overflowDiff > diff then
			return from + diff / 10
		else
			return (from - overflowDiff / 10) % tau
		end
	else
		local overflowDiff = (tau - from) + to
		--print(diff, overflowDiff)
		if overflowDiff < diff then
			return from + diff / 10
		else
			return (from + overflowDiff / 10) % tau
		end
	end
end


function ENT:DrawWheel(i, ox, oy, xoff)
	local spinData = self.SpinData

	local startRad = self:GetWheelStartRad(i)

	local targetRad = startRad
	if spinData then
		local spinRad, finished = self:GetRadAt(i, spinData.strength, CurTime() - spinData.start)
		if finished then
			targetRad = startRad
		else
			targetRad = (startRad + spinRad) % (math.pi*2)
		end
	end

	for k,v in ipairs(self.WheelItems) do
		local curRad = targetRad

		local pointer = curRad - self:GetRadForItemIndex(k)
		local _cos, _sin = math.cos(pointer), math.sin(pointer)

		if _cos > 0 then
			local localY = _sin * 150
			local cx, cy = ox + 0, oy + localY

			local mat = v.mat
			if not mat then
				v.mat = Material(v.mat_path, "smooth")
				mat = v.mat
			end
			render.SetMaterial(mat)

			mesh.Begin(MATERIAL_QUADS, height_segments)

			local height = 80

			for i=0, height_segments-1 do
				local up  = i / height_segments
				local down  = (i+1) / height_segments

				local localUpY = -height/2 + height*up
				local upy = cy + localUpY
				local localDownY = -height/2 + height*down
				local downy = cy + localDownY

				local up_frac = (1 - math.abs((localY + localUpY) / 150))
				local down_frac = (1 - math.abs((localY + localDownY) / 150))

				local up_hwidth = easefunc(up_frac) * 40
				local down_hwidth = easefunc(down_frac) * 40

				local up_alpha = 255
				local down_alpha = 255

				local up_x = cx + xoff*(1 - up_frac^(1/2))
				local down_x = cx + xoff*(1 - down_frac^(1/2))

				mesh.Position(Vector(down_x - down_hwidth, downy, 0)); mesh.TexCoord(0, 0, down); mesh.Color(255, 255, 255, down_alpha); mesh.AdvanceVertex()
				mesh.Position(Vector(up_x - up_hwidth, upy, 0)); mesh.TexCoord(0, 0, up); mesh.Color(255, 255, 255, up_alpha); mesh.AdvanceVertex()
				mesh.Position(Vector(up_x + up_hwidth, upy, 0)); mesh.TexCoord(0, 1, up); mesh.Color(255, 255, 255, up_alpha); mesh.AdvanceVertex()
				mesh.Position(Vector(down_x + down_hwidth, downy, 0)); mesh.TexCoord(0, 1, down); mesh.Color(255, 255, 255, down_alpha); mesh.AdvanceVertex()
			end

			mesh.End()
		end
	end
end

local bgx0, bgx1 = 100, 410
local bgy0, bgy1 = 60, 380

local bgpoly = {
	{x = bgx0, y = bgy0},
	{x = bgx1, y = bgy0},
}
for i=0,10 do
	local rad = i/10 * math.pi
	table.insert(bgpoly, {x = bgx1 + math.sin(rad) * 40, y = bgy0 + (bgy1-bgy0)*(i/10)})
end
table.Add(bgpoly, {
	{x = bgx1, y = bgy1},
	{x = bgx0, y = bgy1},
})
for i=0,10 do
	local rad = i/10 * math.pi
	table.insert(bgpoly, {x = bgx0 - math.sin(rad) * 40, y = bgy1 - (bgy1-bgy0)*(i/10)})
end

ENT.ScreenIdleColor = Color(255, 184, 48)

function ENT:DrawGameScreen(w, h)
	surface.SetDrawColor(self.ScreenIdleColor)
	surface.DrawRect(0, 0, w, h)

	draw.SimpleText(L("slots_bet", {amount = self:GetBet()}), "CKVideoPokerInfo", 5, 5, Color(0, 0, 0), TEXT_ALIGN_LEFT)
	draw.SimpleText(L("slots_chips", {amount = LocalPlayer():CKit_GetChips()}), "CKVideoPokerInfo", w - 5, 5, Color(0, 0, 0), TEXT_ALIGN_RIGHT)

	draw.NoTexture()
	surface.SetDrawColor(190, 190, 190)
	surface.DrawPoly(bgpoly)

	surface.SetDrawColor(0, 0, 0)
	for i=0,4 do
		local upy = bgy0 + i*(bgy1-bgy0)/5
		local downy = bgy0 + (i+1)*(bgy1-bgy0)/5

		do
			local upx = bgx0 + 100 - math.sin(i/5 * math.pi) * 15
			local downx = bgx0 + 100 - math.sin((i+1)/5 * math.pi) * 15
			surface.DrawLine(upx, upy, downx, downy)
		end
		do
			local upx = bgx0 + 210 + math.sin(i/5 * math.pi) * 15
			local downx = bgx0 + 210 + math.sin((i+1)/5 * math.pi) * 15
			surface.DrawLine(upx, upy, downx, downy)
		end
	end

	self:DrawWheel(1, w/2 - 135, h/2, 30)
	self:DrawWheel(2, w/2, h/2, 0)
	self:DrawWheel(3, w/2 + 135, h/2, -30)

	surface.SetDrawColor(0, 0, 0)
	surface.DrawLine(30, h/2, w-30, h/2)

	surface.SetDrawColor(255, 184, 48)
	surface.DrawRect(0, 50, w, 40)
	surface.DrawRect(0, 340, w, 40)
end

function ENT:GetItemMaterial(name)
	for _,i in pairs(self.WheelItems) do
		if i.name == name then
			return Material(i.mat_path, "smooth")
		end
	end
end

function ENT:DrawPaytableEntry(x, y, e)
	local display = e.display

	local ix = 0
	for _,de in pairs(display) do
		if type(de) == "string" then
			local tx = draw.SimpleText(de, "CKVideoPokerPaytable", x+ix, y, Color(0, 0, 0), TEXT_ALIGN_LEFT)
			ix = ix + tx + 4
		elseif type(de) == "table" then
			local type = de[1]
			if type == "item" then
				surface.SetMaterial(self:GetItemMaterial(de[2]))
				surface.DrawTexturedRect(x + ix, y - 5, 22, 22)
				ix = ix + 26
			end
		end
	end
end

local mat_logo
function ENT:DrawGameTopAdvert(x, y, w, h)
	surface.SetDrawColor(self.ScreenIdleColor)
	surface.DrawRect(x, y, w, h)

	surface.SetDrawColor(255, 255, 255)
	mat_logo = mat_logo or Material("models/casinokit/slots/logo_fruits.png")
	surface.SetMaterial(mat_logo)
	surface.DrawTexturedRect(x + 10, y + 10, 120, 40)

	local tbl_x = x + 5
	local tbl_y = y + 70

	--surface.SetDrawColor(255, 255, 255)
	--surface.DrawOutlinedRect(10, tbl_y, 303, 148)


	render.PushFilterMag( TEXFILTER.ANISOTROPIC )
	render.PushFilterMin( TEXFILTER.ANISOTROPIC )

	for k,v in pairs(self.Paytable) do
		surface.SetDrawColor(255, 255, 255)

		self:DrawPaytableEntry(tbl_x + 5, tbl_y + 5 + 25*(k-1), v)
		--draw.SimpleText(v.name, "CKVideoPokerPaytable", tbl_x + 5, tbl_y + 5 + 16*(k-1), Color(0, 0, 0), TEXT_ALIGN_LEFT)
	end

	render.PopFilterMag()
	render.PopFilterMin()

	--draw.SimpleText("Bet", "CKVideoPokerPaytable", tbl_x + 90, tbl_y - 15, Color(0, 0, 0), TEXT_ALIGN_RIGHT)

	for i=0,4 do
		if (self:GetBetLevel() == (i+1)) then
			surface.SetDrawColor(255, 127, 0, 50)
		else
			surface.SetDrawColor(255, 255, 255, 50)
		end

		surface.DrawRect(tbl_x + 95 + i*42, tbl_y, 38, 175, bgclr)

		local bet = self:GetBetLevelAmount(i+1)
		draw.SimpleText(bet, "CKVideoPokerPaytable", tbl_x + 95 + 18 + i*42, tbl_y - 15, Color(0, 0, 0), TEXT_ALIGN_CENTER)

		for k,v in pairs(self.Paytable) do
			if v.jackpot and i == 4 then
				draw.SimpleText(math.floor(self:GetJackpot()), "CKVideoPokerPaytable", tbl_x + 95 + 18 + i*42, tbl_y + 5 + 25*(k-1), Color(0, 0, 255), TEXT_ALIGN_CENTER)
			else
				draw.SimpleText(bet * v.value, "CKVideoPokerPaytable", tbl_x + 95 + 18 + i*42, tbl_y + 5 + 25*(k-1), Color(0, 0, 0), TEXT_ALIGN_CENTER)
			end
		end
	end
end

local mat_ad
function ENT:DrawGameBottomAdvert(x, y, w, h)
	mat_ad = mat_ad or Material("models/casinokit/slots/ad_fruits.png")
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(mat_ad)
	surface.DrawTexturedRect(x, y - 30, w, h + 30)
end

ENT.Buttons = {
	{ slot = 1,   text = "Spin",    clr = Color(255, 127, 0),   fn = function(ent) ent:DoSimpleAction("spin") end,   glow = function(e) return not e.IsSpinning end },
	{ slot = 2.5, text = "Max",     clr = Color(255, 255, 255), fn = function(ent) ent:DoSimpleAction("betmax") end, glow = function(e) return not e.IsSpinning end },
	{ slot = 3.5, text = "Bet +1",  clr = Color(255, 255, 255), fn = function(ent) ent:DoSimpleAction("bet+1") end,  glow = function(e) return not e.IsSpinning end },
}

function ENT:Spin(str)
	self.SpinData = { start = CurTime(), strength = str }

	self.SpinSound = CreateSound(self, "casinokit/slots/spin_wheels.mp3")
	self.SpinSound:Play()

	self.IsSpinning = true
end

function ENT:SpinEnd(wasJackpot)
	if self.SpinSound then
		self.SpinSound:Stop()
	end

	self.IsSpinning = false
end

net.Receive("ckit_fruitspin", function()
	local e = net.ReadEntity()
	if IsValid(e) then
		local str = net.ReadDouble()
		e:Spin(str)
	end
end)
net.Receive("ckit_fruitspinend", function()
	local e = net.ReadEntity()
	if IsValid(e) then
		e:SpinEnd(net.ReadBool())
	end
end)