DEFINE_BASECLASS"casinokit_machine"

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:PostInit()
	self:SetBet(1)
end

function ENT:GetStage()
	return self.Stage or "pre"
end
function ENT:SetStage(s)
	self.Stage = s
	self:SetNWString("gstage", s)
end

function ENT:Think()
	if not IsValid(self:GetPlayer()) and self:GetStage() ~= "pre" then
		self:ResetGame()
		self:SetStage("pre")
	elseif IsValid(self:GetPlayer()) and self:GetStage() == "hold" and (self:GetTurnTimeout() ~= 0 and self:GetTurnTimeout() <= CurTime()) then
		self:OnAct(self:GetPlayer(), "deal")
		self:GetPlayer():ChatPrint("Your poker game has automatically advanced due to inactivity.")
	end

	self:NextThink(CurTime() + 1)
	return true
end

function ENT:ResetGame()
	self:SetHand("")
	self:SetNotification(nil)
	self:SetHeldCards(0)
	self:SetTurnTimeout(0)
end

function ENT:CanBet()
	return self:GetStage() == "pre"
end

function ENT:OnAct(cl, act)
	local ent = self
	local entply = self:GetPlayer()

	if act == "deal" then
		local hand = ent:GetHand()
		if ent:GetStage() == "pre" then -- stage one
			if not ent:TakeBet(cl) then return end

			ent.Deck = CasinoKit.classes.Deck()
			ent.Deck:shuffle()

			local hand = {}
			for i=1,5 do hand[i] = ent.Deck:pop():toTwoByteString() end

			local handstr = table.concat(hand, "")
			ent:SetHand(handstr)
			ent:SetPlayer(cl)

			ent:SetStage("hold")
			ent:EmitSound("casinokit/slots/bet1.wav")
			ent:SetTurnTimeout(CurTime() + 25)
		elseif ent:GetStage() == "hold" then -- stage two
			if entply ~= cl then return end

			local heldCards = ent:GetHeldCards()
			local oldHand = hand
			local newHand = ""

			for i=0,4 do
				local card = string.sub(hand, 1+i*2, 2+i*2)

				local isHeld = bit.band(heldCards, bit.lshift(1, i)) ~= 0
				if not isHeld then
					card = ent.Deck:pop():toTwoByteString()
				end

				newHand = newHand .. card
			end

			ent:SetHand(newHand)
			ent:SetHeldCards(0)

			local phEval = CasinoKit.classes.PokerHandEvaluator()
			local m = phEval:evaluate(CasinoKit.classes.CardSet(self:GetHandAsObjs()))

			local payx = 0
			if m then
				payx = self.Paytable[m.mainValue] or 0
				if payx == 0 and m.name == "Pair" and (m.mainRanks[1]:isFace() or m.mainRanks[1]:isAce()) then
					payx = 1
				end
			end
			if payx > 0 then
				if payx < 5 then
					ent:EmitSound("casinokit/slots/payout1.wav")
				else
					ent:EmitSound("casinokit/slots/payoutslow.wav")
				end

				local amount = self:PayWinnerMul(cl, payx, m.name)

				ent:SetNotification(m.name .. " +" .. amount, "win")
			else
				ent:EmitSound("casinokit/slots/bet1.wav")
				ent:SetNotification("no win")
			end

			ent:SetStage("post")
			timer.Simple(3, function()
				if ent:GetStage() ~= "post" then return end
				ent:ResetGame()
				ent:SetStage("pre")
			end)
		elseif ent:GetStage() == "post" then
			ent:ResetGame()
			ent:SetStage("pre")
		end
	elseif act == "hold" then
		if entply ~= cl then return end
		if ent:GetStage() ~= "hold" then return end

		local idx = net.ReadUInt(8)
		local bits = ent:GetHeldCards()
		bits = bit.bxor(bits, bit.lshift(1, idx))
		ent:SetHeldCards(bits)
		ent:EmitSound("casinokit/slots/card.wav")
	else
		BaseClass.OnAct(self, cl, act)
	end
end