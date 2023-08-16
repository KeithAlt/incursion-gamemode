DEFINE_BASECLASS"casinokit_machine"

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")


function ENT:Initialize()
	BaseClass.Initialize(self)

	self:InitializeHands()
end

function ENT:GetStage()
	return self.Stage or "pre"
end
function ENT:SetStage(s)
	self.Stage = s
	self:SetNWString("gstage", s)
end

function ENT:Think()
	if self:GetStage() == "player" and (self:GetTurnTimeout() ~= 0 and self:GetTurnTimeout() <= CurTime()) then
		if IsValid(self.Player) then
			self:OnAct(self.Player, "stand")
			self.Player:ChatPrint("Timed out")
		else
			self:DealerWin()
		end
	end

	self:NextThink(CurTime() + 1)
	return true
end

function ENT:CanBet()
	return self:GetStage() == "pre"
end

function ENT:EndGame()
	self:SetStage("pre")
	self:SetTurnTimeout(0)
end
function ENT:ResetGame()
	self.PlayerHand:clear()
	self.DealerHand:clear()
	self:SetNotification(nil§)
end

function ENT:PlayerWin(isBlackjack)
	self:PayWinnerMul(self.Player, isBlackjack == 2.5 or 2, "beat dealer")
	self:EmitSound("casinokit/slots/payout1.wav")
	self:SetNotification("you win")
	self:EndGame()
end
function ENT:PlayerPush()
	self:PayWinnerMul(self.Player, 1, "beat dealer")
	self:SetNotification("tie - bet paid back")
	self:EndGame()
end
function ENT:DealerWin()
	self:EmitSound("casinokit/slots/bet1.wav")
	self:SetNotification("dealer wins")
	self:EndGame()
end

function ENT:StartDealerPlay()
	self.DealerHand:revealCard(1, self.Deck:pop())

	while self.DealerHand:getValue() < self.DealerStandAt do
		self.DealerHand:addCard(self.Deck:pop())
	end

	local dealerValue = self.DealerHand:getValue()
	local playerValue = self.PlayerHand:getValue()
	if dealerValue > 21 or dealerValue < playerValue then
		self:PlayerWin(playerValue == 2)
	elseif dealerValue == playerValue then
		self:PlayerPush()
	else
		self:DealerWin()
	end
end

function ENT:OnAct(cl, act)
	local stage = self:GetStage()
	local ent = self
	local entply = self.Player

	if act == "deal" then
		if stage ~= "" and stage ~= "pre" then return end

		if not ent:TakeBet(cl) then return end

		self:ResetGame()

		ent.Deck = CasinoKit.classes.Deck()
		ent.Deck:shuffle()

		ent.DealerHand:addCard(ent.Deck:pop())
		ent.DealerHand:addHiddenCard()

		ent.PlayerHand:addCard(ent.Deck:pop())

		self.Player = cl
		self:SetStage("player")
		self:SetTurnTimeout(CurTime() + 25)
	elseif act == "hit" then
		if stage ~= "player" then return end
		if entply ~= cl then return end

		ent.PlayerHand:addCard(ent.Deck:pop())

		local playerValue = ent.PlayerHand:getValue()
		if playerValue == 21 then
			-- TODO if #cards == 5, give 21
			self:StartDealerPlay()
		elseif playerValue > 21 then
			self:DealerWin()
		else
			self:SetTurnTimeout(CurTime() + 25)
		end
	elseif act == "stand" then
		if stage ~= "player" then return end
		if entply ~= cl then return end

		self:StartDealerPlay()
	else
		BaseClass.OnAct(self, cl, act)
	end
end