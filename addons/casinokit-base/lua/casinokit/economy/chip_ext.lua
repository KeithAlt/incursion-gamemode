local ply = FindMetaTable("Player")

-- An uniquely indexable symbol for a temporary chip count that is valid
-- for the period during which the db transaction is in progress
local SYMBOL_TMPCHIPS = "CKit_SYMBOLTMPCHIPS"

function ply:CKit_GetChips()
	return self[SYMBOL_TMPCHIPS] or self:GetNWInt("CK_Chips", 0)
end
function ply:CKit_CanAffordChips(n)
	return n >= 0 and self:CKit_GetChips() >= n
end

if SERVER then
	hook.Add("PlayerInitialSpawn", "CasinoKit_RestorePChips", function(ply)
		ply:CKit_UpdateChipCount()
	end)

	function ply:CKit_UpdateChipCount()
		local preFetchTC = self[SYMBOL_TMPCHIPS]

		CasinoKit.getChipsS32(self:SteamID(), function(chips)
			local postFetchTC = self[SYMBOL_TMPCHIPS]

			-- If the double-spend variable is mutated during fetch, abort
			if preFetchTC ~= postFetchTC then
				return
			end

			self[SYMBOL_TMPCHIPS] = nil
			self:SetNWInt("CK_Chips", chips)
		end)
	end

	function ply:CKit_SetChips(chips)
		-- Setting chipcount, double-spend prevention is useless
		self[SYMBOL_TMPCHIPS] = nil

		self:SetNWInt("CK_Chips", chips)

		CasinoKit.setChipsS32(self:SteamID(), chips)
	end

	local chipSounds = {"chipsHandle1.ogg", "chipsHandle3.ogg", "chipsHandle4.ogg", "chipsHandle5.ogg", "chipsHandle6.ogg"}

	util.AddNetworkString("ckit_chiptransaction")

	-- Modifies player's chip count by given 'chips' argument
	-- Reason must be provided for log purposes
	-- Counterparty (optional) is an entity representing the other party
	function ply:CKit_AddChips(chips, reason, counterparty)
		if (IsEntity(counterparty) or type(counterparty) == "Vector") and chips ~= 0 then
			net.Start("ckit_chiptransaction")
			-- counterparty -> self
			if chips > 0 then
				net.WriteType(counterparty)
				net.WriteType(self)
			else
				net.WriteType(self)
				net.WriteType(counterparty)
			end
			net.WriteUInt(math.abs(chips), 32)
			net.SendPVS(self:GetPos())
		end
		
		hook.Run("CasinoKitChips", self, chips, reason, counterparty)

		-- Set TMPCHIPS symbol to prevent double-spend during the transaction
		local newChipCount = self:CKit_GetChips() + chips
		self[SYMBOL_TMPCHIPS] = newChipCount
		assert(newChipCount >= 0, "addChips resulting in chipCount < 0!!")

		CasinoKit.addChipsS32(self:SteamID(), chips, function()
			if not IsValid(self) then return end
			self:CKit_UpdateChipCount()
		end)
	end
end
if CLIENT then
	-- Create fake model which will be used to fix flying chip lights
	local cmdl = ClientsideModel("models/hunter/plates/plate1x1.mdl")
	cmdl:SetNoDraw(true)
	local cmdl_mat = Material("models/effects/vol_light001")
	cmdl:DrawShadow(false)

	local chipSounds = {"chipsHandle1.ogg", "chipsHandle3.ogg", "chipsHandle4.ogg", "chipsHandle5.ogg", "chipsHandle6.ogg"}
	local cvar_drawFlyingChips = CreateConVar("ckit_drawflyingchips", "1", FCVAR_ARCHIVE)

	net.Receive("ckit_chiptransaction", function()
		local from, to, chips = net.ReadType(), net.ReadType(), net.ReadUInt(32)
		local scale = math.log(chips, 1.5)

		local hid = string.format("CKit_ChipXferAnim_%f_%s->%s", CurTime(), tostring(from), tostring(to))

		local frompos = (IsEntity(from) and IsValid(from)) and from:WorldSpaceCenter() or from
		local topos = (IsEntity(to) and IsValid(to)) and to:WorldSpaceCenter() or to

		local chipdt = CasinoKit._chipDivisionTable(chips)

		timer.Create(hid .. "_sounds", 0.05, #chipdt, function()
			if not IsValid(from) then return end

			from:EmitSound("casinokit/" .. table.Random(chipSounds), 70, nil, 0.9)
		end)

		if not cvar_drawFlyingChips:GetBool() then
			return
		end

		local progress = 0
		hook.Add("PostDrawTranslucentRenderables", hid, function()
			if progress >= 1 or not isvector(frompos) or not isvector(topos) then
				hook.Remove("PostDrawOpaqueRenderables", hid)
				hook.Remove("Think", hid)
				return
			end

			if EyePos():Distance(frompos) > 256 or EyePos():Distance(topos) > 256 then
				return
			end

			if IsEntity(to) and IsValid(to) then
				topos = to:WorldSpaceCenter()
			end

			-- Draw fake model that fixes lightning on chips
			render.MaterialOverride(cmdl_mat)
			cmdl:DrawModel()
			render.MaterialOverride(nil)

			for i,info in pairs(chipdt) do
				local lprog = progress + (i-1)*0.01
				local leprog = math.EaseInOut(lprog, 0.1, 0.1)
				if lprog < 1 then
					local lpos = LerpVector(leprog, frompos, topos) + Vector(((i*0.6)%1) * 3 + math.sin(i+CurTime()) * 2, ((0.5+i*0.6)%1) * 3 + math.cos(i+CurTime()) * 2, math.sin(leprog * math.pi) * 20)
					CasinoKit._drawChipType(info.chip, lpos, info.count, 1 + math.sin(lprog * math.pi) * 0.2)
				end
			end
		end)
		hook.Add("Think", hid, function()
			progress = progress + FrameTime() * 1.0
		end)
	end)
end