local L = CasinoKit.L

DEFINE_BASECLASS"casinokit_machine"

include("shared.lua")

ENT.RenderGroup = RENDERGROUP_OPAQUE

local card_ar = 1.453

local tdui = CasinoKit.tdui

surface.CreateFont("CKVideoPokerPaytable", {
	font = "Roboto",
	size = 14
})

ENT.ScreenIdleColor = Color(0, 74, 198)

local mat_logo
function ENT:DrawGameTopAdvert(x, y, w, h)
	mat_logo = mat_logo or Material("models/casinokit/slots/logo_videopoker.png")

	surface.SetDrawColor(self.ScreenIdleColor)
	surface.DrawRect(x, y, w, h)

	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(mat_logo)
	surface.DrawTexturedRect(x + 10, y + 10, 124, 40)

	local tbl_x = x + 5
	local tbl_y = y + 70

	--surface.SetDrawColor(255, 255, 255)
	--surface.DrawOutlinedRect(10, tbl_y, 303, 148)

	for k,v in pairs(self.VerbosePaytable) do
		draw.SimpleText(v.name, "CKVideoPokerPaytable", tbl_x + 5, tbl_y + 5 + 16*(k-1), Color(255, 255, 255), TEXT_ALIGN_LEFT)
	end

	--draw.SimpleText("Bet", "CKVideoPokerPaytable", tbl_x + 90, tbl_y - 15, Color(255, 255, 255), TEXT_ALIGN_RIGHT)

	for i=0,4 do
		if (self:GetBetLevel() == (i+1)) then
			surface.SetDrawColor(255, 127, 0, 50)
		else
			surface.SetDrawColor(255, 255, 255, 50)
		end

		surface.DrawRect(tbl_x + 95 + i*42, tbl_y, 38, 152, bgclr)

		local bet = self:GetBetLevelAmount(i+1)
		draw.SimpleText(bet, "CKVideoPokerPaytable", tbl_x + 95 + 18 + i*42, tbl_y - 15, Color(255, 255, 255), TEXT_ALIGN_CENTER)

		for k,v in pairs(self.VerbosePaytable) do
			draw.SimpleText(bet * v.val, "CKVideoPokerPaytable", tbl_x + 95 + 18 + i*42, tbl_y + 5 + 16*(k-1), Color(255, 255, 255), TEXT_ALIGN_CENTER)
		end
	end
end

local mat_ad
function ENT:DrawGameBottomAdvert(x, y, w, h)
	mat_ad = mat_ad or Material("models/casinokit/slots/ad_videopoker.png")
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(mat_ad)
	surface.DrawTexturedRect(x, y - 30, w, h + 30)
end

surface.CreateFont("CKVideoPokerInfo", {
	font = "Roboto",
	size = 32,
	weight = 600
})
surface.CreateFont("CKVideoPokerInfoSmall", {
	font = "Roboto",
	size = 24,
	weight = 600
})

local stageExplanation = {
	pre = "Please place your bet and press deal",
	hold = "Choose cards to keep"
}
function ENT:DrawGameScreen(w, h)
	surface.SetDrawColor(self.ScreenIdleColor)
	surface.DrawRect(0, 0, w, h)

	local deck = CasinoKit.getCardDeck("default")
	deck:fetch()

	local heldCards = self:GetHeldCards()
	local hand = self:GetHand()
	local cardObjs = self:GetHandAsObjs()
	for k=1,5 do
		local i = k-1

		local cardObj = cardObjs[k]

		local mat = deck.backMaterials[1] or Material("error")
		if cardObj then
			local suit, rank = cardObj:getSuit(), cardObj:getRank()
			if suit and rank then
				local suitTable = deck.frontMaterials[suit]
				if suitTable then
					mat = suitTable[rank] or mat
				end
			end
		end

		if mat then
			surface.SetMaterial(mat)
			surface.SetDrawColor(255, 255, 255)
			surface.DrawTexturedRect(10+i*100, 200, 90, 90*card_ar)
		end

		local isHeld = bit.band(heldCards, bit.lshift(1, i)) ~= 0
		if isHeld then
			surface.SetDrawColor(255, 127, 0)
			surface.DrawRect(10+i*100, 338, 90, 6)
		end
	end

	local stage = self:GetNWString("gstage")
	if stage and stage ~= "" then
		draw.SimpleText(L("slots_vpstage_" .. stage), "CKVideoPokerInfoSmall", w/2, 140, nil, TEXT_ALIGN_CENTER)
	end

	draw.SimpleText(L("slots_bet", {amount = self:GetBet()}), "CKVideoPokerInfo", 5, 5, nil, TEXT_ALIGN_LEFT)
	draw.SimpleText(L("slots_chips", {amount = LocalPlayer():CKit_GetChips()}), "CKVideoPokerInfo", w - 5, 5, nil, TEXT_ALIGN_RIGHT)

	local turnto = self.GetTurnTimeout and self:GetTurnTimeout() or 0
	if turnto ~= 0 then
		draw.SimpleText(L("slots_turntime", {remaining = math.ceil(turnto - CurTime())}), "CKVideoPokerInfo", 145, 5, nil, TEXT_ALIGN_LEFT)
	end

	self:DrawNotification()
end

local preglow = function(ent) local s = ent:GetNWString("gstage") return s == "" or s == "pre" end

local Buttons = {
	{ slot = 1,   text = "Deal",    clr = Color(255, 127, 0),   fn = function(ent) ent:DoSimpleAction("deal") end },
	{ slot = 2, text = "Max",     clr = Color(255, 255, 255), fn = function(ent) ent:DoSimpleAction("betmax") end,   glow = preglow },
	{ slot = 2.9, text = "Bet +1",  clr = Color(255, 255, 255), fn = function(ent) ent:DoSimpleAction("bet+1") end,  glow = preglow },
}

for i=0,4 do
	table.insert(Buttons, {
		slot = 4 + (3.6 - i*0.9),
		text = "Hold " .. (i+1),
		clr = Color(255, 255, 255),
		fn = function(ent)
			net.Start("ckit_slotact")
			net.WriteEntity(ent)
			net.WriteString("hold")
			net.WriteUInt(i, 8)
			net.SendToServer()
		end,
		glow = function(ent)
			return ent:GetNWString("gstage") == "hold"
		end
	})
end

function ENT:GetButtons() return Buttons end

local act_btns = {
	{text = "slots_betone", act = "bet+1", x = 300, y = 17},
	{text = "slots_betmax", act = "betmax", x = 355, y = 17},
	{text = "slots_deal", act = "deal", x = 410, y = 17}
}
function ENT:DrawTranslucent()
	--[[
	if not self:IsWithinDrawDistance() then return end

	local depthLevel = 0
	local vertLevel = 0

	-- Hold buttons
	local pnl = self.TDUIHoldBtns or tdui.Create()
	pnl:SetSkin("ckitslotskin")
		for i=0,4 do
			local text = L"slots_hold"
			local x, y = 6+i*55, 17

			pnl:Rect(x, y, 50, 50, Color(180, 180, 180))
			if pnl:Button(text, "DermaDefaultBold", x, y, 50, 50) then
				net.Start("ckit_slotact")
				net.WriteEntity(self)
				net.WriteString("hold")
				net.WriteUInt(i, 8)
				net.SendToServer()
			end
		end

		for _,t in pairs(act_btns) do
			pnl:Rect(t.x, t.y, 50, 50, Color(180, 180, 180))
			if pnl:Button(L(t.text), "DermaDefaultBold", t.x, t.y, 50, 50) then
				net.Start("ckit_slotact")
				net.WriteEntity(self)
				net.WriteString(t.act)
				net.SendToServer()
			end
		end

		pnl:Cursor()
	pnl:Render(self:LocalToWorld(Vector(11, 5, 10.35)), self:LocalToWorldAngles(Angle(60, -90, 0)), 0.05)
	self.TDUIHoldBtns = pnl]]
end