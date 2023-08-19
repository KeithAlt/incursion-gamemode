DEFINE_BASECLASS"casinokit_machine"

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	BaseClass.Initialize(self)

	for i=1,3 do
		self:SetWheelStartRad(i, self:GetRadForItemIndex(1 + math.random(#self.WheelItems)))
	end

	self.JackpotCluster = 1

	self:SetJackpot(self.JackpotStart)

	local cluster = self.JackpotCluster
	if cluster then
		for _,e in pairs(ents.FindByClass("casinokit_slot_fruits")) do
			if e.JackpotCluster == cluster then
				self:SetJackpot(e:GetJackpot())
				break
			end
		end
	end
end

function ENT:UpdateJackpotValue(value)
	local cluster = self.JackpotCluster
	if cluster then
		for _,e in pairs(ents.FindByClass("casinokit_slot_fruits")) do
			if e.JackpotCluster == cluster then
				e:SetJackpot(value)
			end
		end
	else
		self:SetJackpot(value)
	end
end
function ENT:ClearJackpot()
	self:UpdateJackpotValue(self.JackpotStart)
end
function ENT:IncreaseJackpot(delta)
	self:UpdateJackpotValue(self:GetJackpot() + delta)
end

util.AddNetworkString("ckit_fruitspin")
util.AddNetworkString("ckit_fruitspinend")
function ENT:Spin()
	if self.Spinning then return end

	self.Spinning = true

	local str = 13 + CasinoKit.rand.random() * 10

	net.Start("ckit_fruitspin")
	net.WriteEntity(self)
	net.WriteDouble(str)
	net.SendPVS(self:GetPos())

	local items = {}

	for i,d in pairs(self.WheelData) do
		local time = self:GetSpinStopTime(i, str)
		local startRad = self:GetWheelStartRad(i)
		local finalRad = (startRad + self:GetFinalRad(i, str)) % (math.pi * 2)

		timer.Simple(time, function()
			local itemIndex = self:GetItemIndexForRad(finalRad)
			items[i] = self.WheelItems[itemIndex]
			self:SetWheelStartRad(i, self:GetRadForItemIndex(itemIndex))

			if i == #self.WheelData then
				self:SpinEnd(items)
			end
		end)
	end
end

function ENT:CanBet()
	return not self.Spinning
end

function ENT:SpinEnd(items)
	local won
	for _,p in pairs(self.Paytable) do
		if p.test(items) then
			if won then
				ErrorNoHalt("Two wins, report this to developer! Items: " .. table.ToString(items))
				return
			end
			won = p
		end
	end

	local bet = self:GetBet()
	local isMaxBet = bet == 5 * self:GetBetLevel()

	net.Start("ckit_fruitspinend")
	net.WriteEntity(self)
	net.WriteBool(won and won.jackpot)
	net.SendPVS(self:GetPos())

	if won then
		local wonDisplayString = ""

		for _,de in pairs(won.display) do
			if type(de) == "string" then
				wonDisplayString = wonDisplayString .. de
			elseif type(de) == "table" then
				local type = de[1]
				if type == "item" then
					wonDisplayString = wonDisplayString .. " " .. de[2]
				end
			end
		end

		if won.jackpot and isMaxBet then
			self:Jackpot()
			if IsValid(self.SpinPlayer) then
				local amount = self:PayWinner(self.SpinPlayer, math.floor(self:GetJackpot()), won.name)
				self:ClearJackpot()
				self.SpinPlayer:ChatPrint("You won the jackpot of " .. amount .. " chips with " .. wonDisplayString .. "!")
			end
		else
			self:EmitSound("casinokit/slots/win.wav")
			if IsValid(self.SpinPlayer) then
				local amount = self:PayWinnerMul(self.SpinPlayer, won.value, won.name)
				self.SpinPlayer:ChatPrint("You won " .. amount .. " with " .. wonDisplayString .. "!")
			end
		end

	else
		self:IncreaseJackpot(math.ceil(self.AddToJackpotPercentage * self:GetBet()))
	end

	self.Spinning = false
	if IsValid(self.SpinPlayer) then
		-- lock the machine for 10 seconds; no other player can interact
		self.SpinLock = { self.SpinPlayer, CurTime() + 10 }
	end
end

function ENT:Jackpot()
	self:EmitSound("casinokit/slots/win_big.mp3")

	self:EmitSound("weapons/underwater_explode4.wav")
	for i=0,2 do
		timer.Simple(i, function()
			ParticleEffect("mini_fireworks", self:GetPos() + Vector(0, 0, 30), Angle(0, 0, 0))
		end)
	end
end

function ENT:OnAct(ply, act)
	if self.SpinLock and IsValid(self.SpinLock[1]) and ply ~= self.SpinLock[1] and self.SpinLock[2] > CurTime() then
		ply:ChatPrint("This machine was recently used by someone else. Try again in a few seconds.")
		return
	end

	if act == "spin" then
		if not self.Spinning and self:TakeBet(ply) then
			self.SpinPlayer = ply
			self:Spin()
		end
	else
		BaseClass.OnAct(self, ply, act)
	end
end

local prob_test = false
if prob_test then

	print("PROBABILITY TEST RESULT:")

	local bet = 1
	local E = 0
	for _,p in pairs(ENT.Paytable) do
		if not p.jackpot then
			E = E + bet*p.value*p.probability
		end
	end
	print("bet: ", bet, " expectation value: ", E, " house edge: ", (bet - E))

	print("FREQ BRUTEFORCE TEST RESULT:")
	local singleBet = 1
	local bets = 1000000
	local jackpot = ENT.JackpotStart
	local jackpotWinnings = 0
	local wona = 0
	local wincounts = {}

	local rads = {0, 0, 0}
	for i=1,bets do
		local str = 13 + CasinoKit.rand.random() * 10

		local items = {}
		for w=1,3 do
			local frad = rads[w] + ENT:GetFinalRad(w, str)
			local itemidx = ENT:GetItemIndexForRad(frad)
			items[w] = ENT.WheelItems[itemidx]
			rads[w] = ENT:GetRadForItemIndex(itemidx)
		end

		local won
		for _,p in pairs(ENT.Paytable) do
			if p.test(items) then
				if won then
					ErrorNoHalt("Two wins, report this to developer! Items: " .. table.ToString(items) .. ".W0:" .. table.ToString(won) .. ".W1:" .. table.ToString(p))
					return
				end
				won = p
				wincounts[p] = (wincounts[p] or 0) + 1
			end
		end

		if won then
			if won.jackpot then
				wona = wona + jackpot
				jackpotWinnings = jackpotWinnings + jackpot
				jackpot = ENT.JackpotStart
			else
				wona = wona + won.value * singleBet
			end
		else
			jackpot = jackpot + ENT.AddToJackpotPercentage * singleBet
		end
	end

	print("won ", wona, " (x" .. (wona/(bets*singleBet)) .. ")")
	print("total jackpot winnings ", jackpotWinnings, " avg jackpot amount ", (jackpotWinnings / wincounts[ENT.Paytable[1]]))
	for k,v in pairs(wincounts) do
		print(table.ToString(k.display), v)
	end
end

