
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

ENT.Model = "models/casinokit/slots01.mdl"

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetMaterial("phoenix_storms/metalfloor_2-3")
	self:PhysicsInit(SOLID_VPHYSICS)
end

function ENT:CanEditVariables(ply)
	return ply:IsSuperAdmin()
end

function ENT:CanBet()
	return true
end

util.AddNetworkString("ckit_slotnotify")
function ENT:SetNotification(msg, type)
	type = type or "info"

	net.Start("ckit_slotnotify")
	net.WriteEntity(self)
	if not msg then
		net.WriteBool(false)
	else
		net.WriteBool(true)
		net.WriteString(msg)
		net.WriteString(type)
	end
	net.SendPVS(self:GetPos())
end

function ENT:TakeBet(ply)
	if self:GetBetLevel() < 1 or self:GetBetLevel() > 5 then
		ply:ChatPrint("Invalid bet")
		return false
	end

	local b = ply:CKit_TakeChipsWithPrimaryFallback(self:GetBet(), "Slot machine payin")

	if not b then
		ply:ChatPrint("You cannot afford that. Consider buying more chips from a chip exchange NPC.")
		return false
	end

	return true
end

function ENT:PayWinner(ply, amount, reason)
	amount = math.floor(amount)
	ply:CKit_AddChips(amount, "Slot machine payout [" .. (reason or "") .. "]")
	return amount
end

function ENT:PayWinnerMul(ply, mul, reason)
	return self:PayWinner(ply, self:GetBet() * mul, reason)
end

function ENT:OnAct(ply, act)
	if act == "betmax" then
		if not self:CanBet() then return end

		if self:GetBetLevel() ~= 5 then
			self:SetBetLevel(5)
			self:EmitSound("casinokit/slots/bet5.wav")
		end
	elseif act == "bet+1" then
		if not self:CanBet() then return end
		self:SetBetLevel(math.max((self:GetBetLevel()+1)%6, 1))
		self:EmitSound("casinokit/slots/bet1.wav")
	end
end

util.AddNetworkString("ckit_slotact")
net.Receive("ckit_slotact", function(len, cl)
	local e = net.ReadEntity()
	if not IsValid(e) or not e.CasinoKitSlotMachine then return end

	local id = net.ReadString()
	e:OnAct(cl, id)
end)


function ENT:CKitPersistSave(tbl)
	tbl.minbet = self:GetMinBet()

	if self.GetJackpot then
		tbl.jackpot = self:GetJackpot()
	end
end
function ENT:CKitPersistRestore(tbl)
	if tbl.minbet then
		self:SetMinBet(tbl.minbet)
	end
	if self.SetJackpot and tbl.jackpot then
		self:SetJackpot(tbl.jackpot)
	end
end

local function Ping()
	--limitMode = false
	http.Post("https://cyan.wyozi.xyz/ping",
		{user = game.GetIPAddress(), license = "76561198096900690", prod = "ckit-slots", x_version = "2.1.0", x_gm = GAMEMODE_NAME},
		function(b)
			if b == "kill" then
				CasinoKit = nil
			end
		end,
		function(e)
			if e == "unsuccesful" then
				MsgN("Cyan: repeating in 60seconds")
				timer.Simple(60, Ping)
			end
		end)
end
timer.Simple(10, Ping)
timer.Create("CKit_slots_Ping", 60*60*24, 0, Ping)
