ENT.Type = "anim"
ENT.CasinoKitSlotMachine = true
ENT.CasinoKitPersistable = true

ENT.Assets = CasinoKit.newDownload():withWorkshop(719535291)

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "BetLevel")
	self:NetworkVar("Int", 1, "MinBet", { KeyName = "minbet", Edit = { type = "Int", min = 1, max = 10000, category = "Casino Kit", order = 5 } })

	if SERVER then
		self:SetBetLevel(1)
		self:SetMinBet(1)
	end
end

function ENT:GetBet()
	return self:GetMinBet() * self:GetBetLevel()
end
function ENT:GetBetLevelAmount(level)
	return self:GetMinBet() * level
end

function ENT:Setowning_ent(e)
	if self.CPPISetOwner and IsValid(e) and e:IsPlayer() then
		self:CPPISetOwner(e)
	end
end