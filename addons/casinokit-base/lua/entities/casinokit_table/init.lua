AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr, ClassName)
	if not tr.Hit then return end

	local ent = ents.Create(ClassName)
	ent:SetPos(tr.HitPos)
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:OnEntityCopyTableFinish(data)
	-- these kill the duplicator with cyclic references if kept in
	data.Game = nil
	data.Table = nil
end

hook.Add("CanProperty", "CasinoKit_BlockTablePeripheralPersist", function(ply, property, ent)
	if property == "persist" and IsValid(ent:GetParent()) and ent:GetParent().CasinoKitTable then
		ply:ChatPrint("[CasinoKit] Persist the table instead of the dealer or the seats!")
		return false
	end
end)

hook.Add("canPocket", "CasinoKit_PreventPock", function(ply, ent)
	if ent:GetParent().CasinoKitTable then
		return false
	end
end)

-- models/props/cs_office/table_meeting.mdl
ENT.Model = "models/props/de_tides/restaurant_table.mdl"
ENT.SpawnDealer = true

function ENT:OnDealerIdChanged(varname, oldvalue, newvalue)
	local function ParseDealerId(id)
		local dealer = CasinoKit.getDealer(newvalue)
		if dealer then return dealer end

		-- provided a model path; we'll create a temp dealer object for that
		if util.IsValidModel(id) then
			return { Model = id }
		end
	end

	local dealer = ParseDealerId(newvalue)
	if dealer and IsValid(self.Dealer) then
		self.Dealer:SetDealerObj(dealer)
	end
end

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)

	self:SetUseType(SIMPLE_USE)

	self.Table = CasinoKit.classes.Table(self.SeatCount)
	self.Table:on("playerRemoved", function(ply, seatIndex)
		local gmodPly = ply:getGmodPlayer()
		if not IsValid(gmodPly) then return end

		local seatEnt = self.SeatEnts[seatIndex]
		if IsValid(seatEnt) and gmodPly == seatEnt:GetSitter() then
			seatEnt:RemovePlayer()
		end
	end)

	self.SeatEnts = {}
	for i=1, self.SeatCount do
		local lpos, lang = self:SeatToLocal(i)

		local ent = ents.Create("casinokit_seat")

		local seatData = self.SeatData
		ent.Model = seatData.model or ent.Model
		ent.SeatLPos = seatData.lpos or ent.SeatLPos
		ent.SeatLAng = seatData.lang or ent.SeatLAng

		ent:SetPos(self:LocalToWorld(lpos))
		--lang:RotateAroundAxis(lang:Up(), -90)
		ent:SetAngles(self:LocalToWorldAngles(lang))
		ent:Spawn()
		ent:Activate()

		ent:SetMoveType(MOVETYPE_NONE)
		ent:SetParent(self)

		-- darkrp
		ent.DoorData = { NonOwnable = true }
		if ent.setKeysNonOwnable then ent:setKeysNonOwnable(true) end

		ent.CasinoKitSeat = true
		ent.CasinoKitTable = self

		ent:SetSeatIndex(i)
		self.SeatEnts[i] = ent

		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end

		local tableSelf = self
		function ent:CanEnter(ply)
			return tableSelf:CanEnterSeat(ply, self)
		end
		function ent:OnEnter(ply)
			local p = CasinoKit.classes.Player(ply)
			tableSelf.Table:addPlayer(p, self:GetSeatIndex())

			tableSelf:OnGameEvent("PlayerJoinedTable", {ply = ply, seat = ent})
		end
		function ent:OnLeave(ply)
			tableSelf.Table:removePlayerAtSlot(self:GetSeatIndex())
			tableSelf:OnGameEvent("PlayerLeftTable", {ply = ply, seat = self})
		end
	end

	if self.SpawnDealer then
		self.Dealer = ents.Create("casinokit_dealernpc")

		local pos, ang = self:SeatToLocal(0, self.DealerDistance)

		self.Dealer:SetPos(self:LocalToWorld(pos))
		self.Dealer:SetAngles(self:LocalToWorldAngles(ang))
		self.Dealer:Spawn()

		self.Dealer:SetMoveType(MOVETYPE_NONE)
		self.Dealer:SetParent(self)

		self:OnDealerIdChanged(nil, nil, self:GetDealerId())
	end

	local gameClass = CasinoKit.classes[self.GameClass]
	assert(gameClass, "game '" .. tostring(self.GameClass) .. "' does not exist!")

	self.Game = self.Table:createGame(gameClass, self)
	self:SetClGameClass(self.Game:getClClass())

	self.Game:addGEventListener(function(id, args)
		self:ProcessGameEvent(id, args)
	end)
end

function ENT:CanEnterSeat(ply, seat)
	-- make sure we're not trying to sit on someone else's seat
	local plyInSeat = self.Game:getPlayerInSeat(seat:GetSeatIndex())
	if plyInSeat and plyInSeat:getGmodPlayer() ~= ply then
		ply:CKit_PrintL("seatreserved")
		return false
	elseif not plyInSeat then

		-- if seat is empty, make sure that we're not already sitting somewhere
		local op = self.Game:getPlayerByEnt(ply)
		if op and op:getSeatIndex() ~= seat:GetSeatIndex() then
			ply:CKit_PrintL("notyourseat")
			return false
		end

	end

	local b, reason = self.Game:canGmodPlayerSitIn(ply, seat:GetSeatIndex())
	if not b then
		ply:CKit_PrintML(tostring(reason or "#unknownreason"))
		return false
	end

	return true
end

function ENT:ProcessGameEvent(id, args)
	if IsValid(self.Dealer) then
		self.Dealer:ProcessGameEvent(id, args)
	end
end

util.AddNetworkString("casinokit_gameinput")
net.Receive("casinokit_gameinput", function(len, cl)
	local table = net.ReadEntity()
	if not IsValid(table) or not table.CasinoKitTable then cl:ChatPrint("Invalid table ent.") return end

	local game = table.Game
	if not game then
		cl:ChatPrint("No game ongoing in table.")
		return
	end

	local seatIndex = net.ReadUInt(8)

	local gamePlayer

	-- First try to find gameplayer from seat directly
	if seatIndex ~= 0 then
		gamePlayer = game:getPlayerInSeat(seatIndex)
		if gamePlayer and gamePlayer:getGmodPlayer() ~= cl then cl:ChatPrint("That gameplayer is not you!") return end
	end

	-- if gamePlayer not found via seat directly, try from all gamePlayers
	if not gamePlayer then
		gamePlayer = game:getPlayerByEnt(cl)
	end

	local dataLen = net.ReadUInt(16)
	local data = net.ReadData(dataLen)
	if not data then cl:ChatPrint("No data") return end
	local buffer = CasinoKit.classes.Buffer(data)

	-- if still no gamePlayer, fallback to onOutsidePlayerInput
	if not gamePlayer then
		if game.onOutsidePlayerInput then
			game:onOutsidePlayerInput(cl, buffer)
		else
			cl:ChatPrint("No GamePlayer found")
		end
	else
		game:onPlayerInput(gamePlayer, buffer)
	end
end)

function ENT:OnRemove()
	if self.Game then self.Game:cleanup() end
end

function ENT:OnGameEvent(name, data)
	if IsValid(self.Dealer) then
		if name == "PlayerJoinedTable" then
			self.Dealer:SayVoicePhrase("greet")
		elseif name == "PlayerLeftTable" then
			self.Dealer:SayVoicePhrase("leave")
		end
	end
end

function ENT:OnGameConfigReceived(key, value)

end

util.AddNetworkString("casinokit_tablecfg")
net.Receive("casinokit_tablecfg", function(len, cl)
	local tbl = net.ReadEntity()
	local key = net.ReadString()
	local value = net.ReadType()

	if not IsValid(tbl) or not tbl.CasinoKitTable then return end
	if not tbl:CanConfigureTable(cl) then return cl:ChatPrint("permission denied") end

	tbl:OnGameConfigReceived(key, value)

	if tbl:CKit_IsPersisted() then
		CasinoKit.updatePersistedEntity(tbl)
	end
end)

function ENT:PersistTableSettings(tbl)
	self.Game:persistTableSettings(tbl)
end
function ENT:RestoreTableSettings(tbl)
	self.Game:restoreTableSettings(tbl)
end

function ENT:CKitPersistSave(tbl)
	local psettings = {}
	self:PersistTableSettings(psettings)
	tbl.tableSettings = psettings

	tbl.dealerid = self:GetDealerId()
end
function ENT:CKitPersistRestore(tbl)
	if tbl.tableSettings then
		self:RestoreTableSettings(tbl.tableSettings)
	end

	if tbl.dealerid then
		self:SetDealerId(tbl.dealerid)
	end
end

hook.Add("PlayerDisconnected", "CasinoKit_KickDCdFromGame", function(ply)
	for _,t in pairs(ents.FindByClass("casinokit_*")) do
		if t.CasinoKitTable and t.Game then
			for _,tp in pairs(t.Game:getPlayersByEnt(ply)) do
				t.Game:kickPlayer(tp)
			end
		end
	end
end)

concommand.Add("casinokit_createdebugply", function(ply, cmd, args)
	if not ply:IsSuperAdmin() then return end

	local tr = ply:GetEyeTrace()
	local e = tr.Entity

	print(e)

	local table, seatIndex
	if e.CasinoKitTable then
		table = e
		seatIndex = 1
	else
		table = e:GetParent()
		seatIndex = e:CKit_GetSeatIndex()
	end
	assert(table.CasinoKitTable)

	local p = CasinoKit.classes.Player(ply)
	table.Table:addPlayer(p, seatIndex)

	ply:ChatPrint("debug ply created @" .. seatIndex)
end)
