local L = CasinoKit.L

local BjCl = CasinoKit.class("BlackjackCl", "CardGameCl")

BjCl.enableOverviewUI = true

function BjCl:getGameFriendlyName()
	return "Blackjack"
end

function BjCl:getGameFriendlySubtext()
	return L("blackjack_minimumbet",{amount=self:getMinBet()})
end

function BjCl:getMinBet()
	local te = self:getTableEntity()
	return IsValid(te) and te:GetMinBet() or 5
end

function BjCl:getMaxBet()
	local te = self:getTableEntity()
	return IsValid(te) and te:GetMaxBet() or 5
end

function BjCl:getTimeoutDelay()
	local te = self:getTableEntity()
	return  IsValid(te) and te:GetTimeoutDelay() or -1
end

function BjCl:getStopAt()
	local te = self:getTableEntity()
	return IsValid(te) and te:GetStopAt() or 0
end

function BjCl:handleGameMessage(id, buf)
	if id == "newcd" then -- we need to overwrite because of splitting
		local seatIndex = buf:get()
		local cardId = buf:get()
		local card = buf:getCard()

		local player = self:getPlayerInSeat(seatIndex)

		local cardObj = self:createCardObject(card)
		if player:getSplit() and not player:getFirstHand() then -- give it to second hand if needed
			local splitCards = player:getSplitCards()
			table.insert(splitCards, cardObj)
			player:setSplitCards(splitCards)
		else
			player:addCard(cardObj)			
		end

		self.cardIds = self.cardIds or {}
		self.cardIds[cardId] = cardObj	
	elseif id == "ccard" then
		self.communityCards = self.communityCards or {}

		local k = #self.communityCards
		local cardObj = self:createCardObject(buf:getCard(), Vector(5, -3.5 + (k-1)*5, 0))
		table.insert(self.communityCards, cardObj)
	elseif id == "nturn" then
		self.turn = buf:get()

		local turnTime = buf:get()
		self.turnStartTime = CurTime()
		self.turnEndTime = self.turnStartTime + turnTime

		if self:getTableEntity():GetMySeatIndex() == self.turn then
			surface.PlaySound("HL1/fvox/bell.wav")
		end
		
		-- if they have split and it's their turn, then this is their second turn
		local ply = self:getPlayerInSeat(self.turn)
		if ply:getSplit() then
			ply:setFirstHand(false)
		end
	elseif id == "etime" then
		local turnTime = buf:getInt()
		self.turnStartTime = CurTime()
		self.turnEndTime = self.turnStartTime + turnTime	
	elseif id == "tmout" then
		local turnTime = buf:getInt()
		self.turnStartTime = CurTime()
		self.turnEndTime = self.turnStartTime + turnTime
	elseif id == "chips" then
		local seat = buf:getInt()
		local ply = self:getPlayerInSeat(seat)
		local chips = buf:getInt()
		ply:setChips(chips)
		local chipSound = table.Random{"chipsHandle1.ogg", "chipsHandle3.ogg", "chipsHandle4.ogg", "chipsHandle5.ogg", "chipsHandle6.ogg"}
		self:playTableSound("file:sound/casinokit/" .. chipSound)
	elseif id == "split" then
		local ply = self:getPlayerInSeat(buf:get())
		ply:setSplit(true)
		ply:setFirstHand(true)
		local cards = ply:getCards()
		ply:setCards({cards[1],cards[3]})
		ply:setSplitCards({cards[2],cards[4]})
	elseif id == "bjrev" then
		local card = buf:getCard()
		if self.communityCards and self.communityCards[2] then
			self.communityCards[2].card = card
		end
	elseif id == "rsult" then
		self.showdownResults = self.showdownResults or {}
		buf:getArray(function()
			table.insert(self.showdownResults,{msg=buf:getString(),n=buf:getInt()})
		end)
	else	
		BjCl.super.handleGameMessage(self, id, buf)
	end
end

function BjCl:getCardHorizOffset(idx)
	return (idx - 1) * 0.02
end
function BjCl:getCardVertOffset(idx)
	return 23 - (idx * 1.2)
end

function BjCl:onStateChanged(newState)
	BjCl.super.onStateChanged(self, newState)

	if newState == "gameover" then
		self.communityCards = nil
		self.showdownResults = nil
	end
end


function BjCl:drawTable(ent, localOrigin)
--	BjCl.super.drawTable(self, ent, localOrigin) -- fuck this, gotta add splitting

	-- draw chips and cards
	for _,tpl in pairs(ent:GetCachedSeatindexPlyTuples()) do
		local seatIndex = tpl[1]
		local ply = tpl[2]

		if ply:IsValid() then
			local lpos, lang = ent:SeatToLocal(seatIndex, 29.5)
			lpos = ent:LocalToWorld(localOrigin + lpos)
			lang = ent:LocalToWorldAngles(lang)
			CasinoKit.drawChipStack(ply:CKit_GetChips(), lpos, lang, true)
		end
	end

	for k,p in pairs(self:getPlayers()) do
		if p:getSplit() then
			k = k - 0.15
			for cidx,c in pairs(p:getSplitCards()) do
				self:updateCardEndPos(ent, c, cidx, p, k+0.3)
				self:drawCard(ent, localOrigin, c)
			end			
		end
		for cidx,c in pairs(p:getCards()) do
			if not c.anim.endPos or p:getSplit() then -- make sure we update in case they split
				self:updateCardEndPos(ent, c, cidx, p, k)
			end	
			self:drawCard(ent, localOrigin, c)
		end
		
	end	
	

	for k,v in pairs(self.communityCards or {}) do
		self:drawCard(ent, localOrigin, v)
	end

	if self.communityCards and #self.communityCards > 0 then
		local pos = ent:LocalToWorld(localOrigin + Vector(13, 0, 0))
		local ang = ent:GetAngles()
		ang:RotateAroundAxis(ang:Up(),270)
		CasinoKit.drawChipStack(self.pot or 0, pos, ent:GetAngles(), true)
	
		local hand = self.communityCards or {}
		local value,soft = self:getHandValue(hand)
		if value == 21 then
			value = value .. " (blackjack)"
		elseif value > 21 then
			value = value .. " (busted)"
		elseif soft then
			value = value .. " (soft)"
		end
		
		cam.Start3D2D( pos,ang, 0.05 )
			draw.SimpleTextOutlined("Card value", "Trebuchet24", 0, 0, Color(255,255,255,255), 0, 5, 1, Color(0,0,0,255) )
			draw.SimpleTextOutlined(value, "Trebuchet24", 0, 25, Color(255,255,255,255), 0, 5, 1, Color(0,0,0,255) )
		cam.End3D2D()	
	end	

	for i,p in pairs(self:getPlayers()) do
		local lpos,lang = ent:SeatToLocal(i-0.30,21)
		lpos = ent:LocalToWorld(localOrigin + lpos)
		lang = ent:LocalToWorldAngles(lang)
		
		CasinoKit.drawChipStack(p:getChips() or 0, lpos, ent:GetAngles(), true)
	end
	
	local me = self:getPlayers()[ent:GetMySeatIndex()]
	-- ent:GetMySeatIndex() ~= -1 and me and in if statement
	if table.HasValue({"playing","reveal","showdown"},self.state) then
		for i,p in pairs(self:getPlayers()) do
			local lpos,lang = ent:SeatToLocal(i,26)
			lpos = ent:LocalToWorld(localOrigin + lpos)
			lang = ent:LocalToWorldAngles(lang)
			lang:RotateAroundAxis(lang:Up(),270) -- looks better than 270
			
			local hand = p:getCards()
			
			local value,soft = self:getHandValue(hand)
			local text = value
			if value > 21 then
				text = text .. " (busted)"
			elseif value == 21 then
				text = text .. " (blackjack)"
			elseif soft then
				text = text .. " (soft)"
			end

			if p:getSplit() then
				hand = p:getSplitCards()
				local value,soft = self:getHandValue(hand)
				text = text .. " | "..value
				if value > 21 then
					text = text .. " (busted)"
				elseif value == 21 then
					text = text .. " (blackjack)"
				elseif soft then
					text = text .. " (soft)"
				end				
			end
			
			cam.Start3D2D( lpos,lang, 0.05 )
				draw.SimpleTextOutlined("Card value", "Trebuchet24", 80, 0, Color(255,255,255,255), 0, 5, 1, Color(0,0,0,255) )
				draw.SimpleTextOutlined(text, "Trebuchet24", 80, 25, Color(255,255,255,255), 0, 5, 1, Color(0,0,0,255) )
			cam.End3D2D()
		end
	end	
	
end

function BjCl:sendAction(ent, act)
	local out = CasinoKit.classes.OutBuffer()
	out:putString(act)
	self:sendInput(out)
end

function BjCl:sendBet(ent,bet)
	local out = CasinoKit.classes.OutBuffer()
	out:putString("bet")
	out:putInt(bet)
	self:sendInput(out)	
end

function BjCl:stateMessage()
	return tostring(self.state)
end

function BjCl:getActivityPosition(ent, localOrigin)
	local apos = self.super.getActivityPosition(self, ent, localOrigin)
	if apos then
		return apos
	end

	local gmodPly = self:getTurnGmodPly(ent)
	if IsValid(gmodPly) then
		return gmodPly:EyePos()
	end
end

function BjCl:getSeatPly(ent, seat)
	for _,sp in pairs(ent:GetCachedSeatindexPlyTuples()) do
		if sp[1] == seat then
			return sp[2]
		end
	end
end

function BjCl:getTurnGmodPly(ent)
	local turn = self.turn
	return self:getSeatPly(ent, turn)
end


function BjCl:addBetAmount(amount)
	local value = cookie.GetNumber("ckbj-bet")
	if (value + amount) <= self:getMaxBet() and (value + amount) >= self:getMinBet() then
		cookie.Set("ckbj-bet",value+amount)
	end	
end

function BjCl:setBetAmount(amount)
	if amount <= self:getMaxBet() and amount >= self:getMinBet() then
		cookie.Set("ckbj-bet",amount)
	end	
end

function BjCl:stateMessage()
	local state = self.state
	if not state then return "-" end

	if state == "idle" then
		return L"waiting"
	end

	local bstate = string.format("blackjack_%s", state)
	return L(bstate)	
end

function BjCl:getUIOffset(ent)
	local turnGmodPly = self:getTurnGmodPly(ent)
	
	if self.state == "playing" and turnGmodPly == LocalPlayer() and self:getPlayerInSeat(self.turn):getSplit() then
		if self:getPlayerInSeat(self.turn):getFirstHand() then
			return Vector(1, -3, -5), Angle(10, 10, 0)
		else
			return Vector(1, 3, -5), Angle(10, -10, 0)
		end
	end
	return Vector(1,0,-5),Angle(10,0,0)
end

function BjCl:drawUI(ent, p)
	BjCl.super.drawUI(self, ent, p)

	p:Rect(-85, -25, 170, 25, nil, Color(255, 255, 255))
	p:Text(self:stateMessage(), "!Roboto@18", 0, -22)

	local turnGmodPly = self:getTurnGmodPly(ent)
	
	local me = self:getPlayers()[ent:GetMySeatIndex()]
	
	if self.state == "initBet" then
		if self.turnStartTime and self.turnEndTime then
			local elapsed = CurTime() - self.turnStartTime
			local elapsedFrac = elapsed / (self.turnEndTime - self.turnStartTime)

			p:Rect(-85, 32, 170, 5, nil, Color(255, 255, 255))
			p:Rect(-85, 32, 170 * (1 - elapsedFrac), 5, Color(255, 255, 255), nil)
		end

		p:Text(L("blackjack_bet")..": " .. cookie.GetNumber("ckbj-bet",self:getMinBet()), "!Roboto@15", 0, 5)
	
		if me and me:hasBet() then
			--don't ask why i did it like this
		else
			if p:Button(L"blackjack_betverb", "!Roboto@17", -50, 45, 100, 30) then
				self:sendBet(ent,cookie.GetNumber("ckbj-bet"))
			end
			if p:Button("<", "!Roboto@17", -85, 45, 30, 30) then
				local amount = -1
				if input.IsKeyDown(KEY_LSHIFT) then
					amount = -10
				elseif input.IsKeyDown(KEY_LALT) then
					amount = -100
				end
				self:addBetAmount(amount)
			end		
			if p:Button(">", "!Roboto@17", 55, 45, 30, 30) then
				local amount = 1
				if input.IsKeyDown(KEY_LSHIFT) then
					amount = 10
				elseif input.IsKeyDown(KEY_LALT) then
					amount = 100
				end
				self:addBetAmount(amount)
			end
			if p:Button(L"blackjack_minimum", "!Roboto@17", -85, 80, 80, 30) then
				self:setBetAmount(self:getMinBet())
			end	
			if p:Button(L"blackjack_maximum", "!Roboto@17", 5, 80, 80, 30) then
				self:setBetAmount(math.min(self:getMaxBet(),LocalPlayer():CKit_GetChips()))
			end				
		end
		
	end

	local turnGmodPly = self:getTurnGmodPly(ent)
	if self.state == "playing" and turnGmodPly then
		-- clarity for splitting turns
		local nick = turnGmodPly:Nick()
		if self:getPlayerInSeat(self.turn):getSplit() then
			if self:getPlayerInSeat(self.turn):getFirstHand() then
				nick = nick .. " (1/2)"
			else
				nick = nick .. " (2/2)"
			end	
		end
	
		p:Text(L("turn")..": " .. nick, "!Roboto@15", 0, 5)
		
		if turnGmodPly == LocalPlayer() then
			if self.turnStartTime and self.turnEndTime then
				local elapsed = CurTime() - self.turnStartTime
				local elapsedFrac = elapsed / (self.turnEndTime - self.turnStartTime)
	
				p:Rect(-85, 32, 170, 5, nil, Color(255, 255, 255))
				p:Rect(-85, 32, 170 * (1 - elapsedFrac), 5, Color(255, 255, 255), nil)
			end
	
			local me = self:getPlayers()[ent:GetMySeatIndex()] 
			local cards = me:getCards()
			if me:getSplit() and not me:getFirstHand() then
				cards = me:getSplitCards()
			end
			local numCards = #cards
			local dealerCard = self.communityCards[1]["card"]:getRank()
	
			if numCards < 5 and self:getHandValue(cards) < 21 and p:Button(L"blackjack_hit", "!Roboto@17", -95, 45, 90, 30) then
				self:sendAction(ent, "hit")
			end
			if p:Button(L"blackjack_stand", "!Roboto@17", -95, 80, 90, 30) then
				self:sendAction(ent, "stand")
			end	
			if not me:getSplit() and numCards == 2 and cards[1]["card"]:getRank() == cards[2]["card"]:getRank() and p:Button(L"blackjack_split", "!Roboto@17", -95, 115, 90, 30) then
				self:sendAction(ent, "split")
			end				
			if numCards == 2 and self:getHandValue(cards) ~= 21 and p:Button(L"blackjack_ddown", "!Roboto@17", 5, 45, 90, 30) then
				self:sendAction(ent, "doubledown")
			end	
			if dealerCard:isAce() and numCards == 2 and p:Button(L"blackjack_insurance","!Roboto@17", 5, 80, 90, 30) then
				self:sendAction(ent,"insurance")
			end			
			if self:getHandValue(cards) == 21 and numCards == 2 and dealerCard:isAce() and p:Button(L"blackjack_evenmoney", "!Roboto@17", 5, 115, 90, 30) then
				self:sendAction(ent,"evenmoney")
			end
			
		end
	end	

	if self.state == "showdown" and self.showdownResults then
		for i, tbl in pairs(self.showdownResults) do
			if tbl.n == -1 then
				p:Text(L(tbl.msg), "!Roboto@18", 0, -10 + i*15, nil, TEXT_ALIGN_CENTER)
			else
				p:Text(L(tbl.msg,{amount=tbl.n}), "!Roboto@18", 0, -10 + i*15, nil, TEXT_ALIGN_CENTER)
			end	
		end
	end

end


function BjCl:addGameSettings(settings)
	settings:integer("Minimum Bet", "minbet", self:getMinBet(), 5, 1e6)
	settings:integer("Maximum bet", "maxbet", self:getMaxBet(), 5, 1e9) -- pray some idiot doesn't make it lower than minimum
	settings:integer("Timeout delay (seconds)", "timeoutdelay", self:getTimeoutDelay(), 5, 180)
	settings:integer("Stop at hard/soft 17 (0/1)", "stopat", self:getStopAt(), 0, 1)
	BjCl.super.addGameSettings(self, settings)
end

local BjPlayerCl = CasinoKit.class("BjPlayer", "CardGamePlayerCl")
BjPlayerCl:prop("chips")
BjPlayerCl:prop("split")
BjPlayerCl:prop("firstHand")
BjPlayerCl:prop("splitCards")

function BjCl:createClPlayer(gmodPlayer)
	return BjPlayerCl(gmodPlayer)
end

function BjPlayerCl:hasBet()
	if type(self:getChips()) ~= "number" then return false end
	if self:getChips() <= 0 then return false end
	return true
end


function BjCl:getHandValue(hand)
	local value = 0
	local aces = 0
	local isSoft = false
	
	for _,c in pairs(hand) do
		if c["card"] then
			c = c["card"]
			if c:getRank():isAce() then
				aces = aces + 1
				value = value + 1
			elseif c:getRank():isFace() then
				value = value + 10
			else
				assert(type(tonumber(c:getRank():getValue())) == "number")
				value = value + tonumber(c:getRank():getValue())	
			end
		end	
	end

	-- neth still likes penis
	-- the above comment is a reference to the comment put in by Hobbes in my previous script.
	
	if aces >= 1 and value <= 11 then
		value = value + 10
		isSoft = true
	end

	if value <= 21 and #hand >= 5 then
		value = 21
	end

	return value,isSoft
end

BjCl.htmlHelp = [[
<h2>Blackjack rules</h2>
<p>
	Click <a href="javascript:openRules()">here</a> to open Blackjack rules.
</p>
<script>
	function openRules() {
		gmod.OpenUrl('https://en.wikipedia.org/wiki/Blackjack#Rules_of_play_at_casinos')
	}
</script>
]]