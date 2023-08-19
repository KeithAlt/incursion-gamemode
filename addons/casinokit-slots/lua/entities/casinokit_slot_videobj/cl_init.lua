local L = CasinoKit.L

DEFINE_BASECLASS"casinokit_machine"
include("shared.lua")

ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:Initialize()
	BaseClass.Initialize(self)

	self:InitializeHands()
end

function ENT:GetStage()
	return self:GetNWString("gstage")
end

local card_ar = 1.453

local tdui = CasinoKit.tdui

surface.CreateFont("CKVideoPokerPaytable", {
	font = "Roboto",
	size = 14
})

ENT.ScreenIdleColor = Color(21, 91, 53)

local mat_logo
function ENT:DrawGameTopAdvert(x, y, w, h)
	mat_logo = mat_logo or Material("models/casinokit/slots/logo_blackjack.png")
	surface.SetDrawColor(self.ScreenIdleColor)
	surface.DrawRect(x, y, w, h)

	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(mat_logo)
	surface.DrawTexturedRect(x + 35, y + 10, 256, 78)

	draw.SimpleText(L("slots_standat", {value = self.DealerStandAt}), "CKVideoPokerInfoSmall", x + w/2, y + 115, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
function ENT:DrawGameBottomAdvert(x, y, w, h)
	surface.SetDrawColor(self.ScreenIdleColor)
	surface.DrawRect(x, y, w, h)
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

	-- dealer
	draw.SimpleText(L"dealer" .. " (" .. tostring(self.DealerHand:getValue()) .. ")", "CKVideoPokerInfoSmall", 30, 205)

	for i,cardObj in self.DealerHand:cards() do
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
			surface.DrawTexturedRect(30+(i-1)*100, 70, 90, 90*card_ar)
		end
	end

	-- player
	draw.SimpleText(L"player" .. " (" .. tostring(self.PlayerHand:getValue()) .. ")", "CKVideoPokerInfoSmall", 30, 395)

	for i,cardObj in self.PlayerHand:cards() do
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
			surface.DrawTexturedRect(30+(i-1)*100, 260, 90, 90*card_ar)
		end
	end

	--[[local stage = self:GetNWString("gstage")
	if stage and stage ~= "" then
		draw.SimpleText(stage, "CKVideoPokerInfoSmall", w/2, 35, nil, TEXT_ALIGN_CENTER)
	end]]

	draw.SimpleText(L("slots_bet", {amount = self:GetBet()}), "CKVideoPokerInfo", 5, 5, nil, TEXT_ALIGN_LEFT)
	draw.SimpleText(L("slots_chips", {amount = LocalPlayer():CKit_GetChips()}), "CKVideoPokerInfo", w - 5, 5, nil, TEXT_ALIGN_RIGHT)

	local turnto = self.GetTurnTimeout and self:GetTurnTimeout() or 0
	if turnto ~= 0 then
		draw.SimpleText(L("slots_turntime", {remaining = math.ceil(turnto - CurTime())}), "CKVideoPokerInfo", 145, 5, nil, TEXT_ALIGN_LEFT)
	end

	self:DrawNotification()
end

ENT.Buttons = {
	{ slot = 1,   text = "Deal",    clr = Color(255, 127, 0),   fn = function(ent) ent:DoSimpleAction("deal") end,   glow = function(e) return e:GetStage() ~= "player" end },
	{ slot = 2.5, text = "Max",     clr = Color(255, 255, 255), fn = function(ent) ent:DoSimpleAction("betmax") end, glow = function(e) return e:GetStage() == "pre" or e:GetStage() == "" end },
	{ slot = 3.5, text = "Bet +1",  clr = Color(255, 255, 255), fn = function(ent) ent:DoSimpleAction("bet+1") end,  glow = function(e) return e:GetStage() == "pre" or e:GetStage() == "" end },

	{ slot = 5, text = "Stand",  clr = Color(255, 200, 200), fn = function(ent) ent:DoSimpleAction("stand") end,  glow = function(e) return e:GetStage() == "player" end },
	{ slot = 6, text = "Hit",  clr = Color(200, 255, 200), fn = function(ent) ent:DoSimpleAction("hit") end,  glow = function(e) return e:GetStage() == "player" end },
}

local act_btns = {
	{text = "bet", act = "bet+1"},
	{text = "betmax", act = "betmax"},
	{text = "deal", act = "deal"},

	{text = "hit", act = "hit"},
	{text = "stand", act = "stand"},
	{text = "doubledown", act = "double"},
	{text = "split", act = "split"},
}
function ENT:DrawTranslucent()
	if not self:IsWithinDrawDistance() then return end

	local depthLevel = 0
	local vertLevel = 0

	-- Hold buttons
	local pnl = self.TDUIHoldBtns or tdui.Create()
	pnl:SetSkin("ckitslotskin")

		local x, y = 130, 17
		for _,t in pairs(act_btns) do
			pnl:Rect(x, y, 50, 50, Color(180, 180, 180))
			if pnl:Button(L(t.text), "DermaDefaultBold", x, y, 50, 50) then
				net.Start("ckit_slotact")
				net.WriteEntity(self)
				net.WriteString(t.act)
				net.SendToServer()
			end

			x = x + 55
		end

		pnl:Cursor()
	pnl:Render(self:LocalToWorld(Vector(11, 5, 10.35)), self:LocalToWorldAngles(Angle(60, -90, 0)), 0.05)
	self.TDUIHoldBtns = pnl
end