AddCSLuaFile()

ENT.Type      = "anim"
ENT.Base      = "base_gmodentity"

ENT.PrintName = "Workbench"
ENT.Author    = "Claymore Gaming"
ENT.Category  = "Claymore Gaming"

ENT.Spawnable = true

ENT.CannotRemove = true --stops entity from being removed by properties

if SERVER then
	function ENT:SpawnFunction(ply, tr, ClassName)
		if !tr.Hit then return end

		local SpawnPos = tr.HitPos + (tr.HitNormal * 17)
		local SpawnAng = ply:EyeAngles()
		SpawnAng.p = 0
		SpawnAng.y = SpawnAng.y + 180

		local ent = ents.Create(ClassName)
		ent:SetPos(SpawnPos)
		ent:SetAngles(SpawnAng)
		ent:Spawn()
		ent:Activate()

		return ent
	end

	function ENT:Initialize()
		if self.model and !util.IsValidModel(self.model) then
			self.model = "models/props_c17/furnitureStove001a.mdl"
			Workbenches.log("An invalid model path was detected( " .. self.model .. " ) for workbench[" .. self.benchID .. "] ")
		end

		self:SetModel(self.model or "models/props_wasteland/controlroom_desk001a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:PhysWake()

		if self.core then
			self.core.entInit(self)
		end

		Workbenches.BenchEnts[self] = true

		if self.benchID then
			self:ToggleSpawn(false) -- Set spawn state to 'false' to prevent duplicates
			Workbenches.Benches[self.benchID].pos = self:GetPos()
			Workbenches.Benches[self.benchID].angles = self:GetAngles()
		end
	end

	function ENT:Use(ply)
		if !self:GetConfigured() then
			Workbenches.OpenConfigMenu(ply, self)
			return
		end

		if isstring(self:getNetVar("faction", nil)) and istable(self:getNetVar("classes", nil)) and !ply:IsSuperAdmin() then
			local faction = self:getNetVar("faction")
			local classes = self:getNetVar("classes")

			local char = ply:getChar()
			local plyFaction = nut.faction.indices[char:getFaction()].uniqueID
			local plyClass   = nut.class.list[char:getClass()].uniqueID

			if faction != plyFaction or !classes[plyClass] then
				ply:notify("You're not a part of the correct faction to use this!")

				return
			end
		end

		if self:GetCapturable() then
			local owner = self:GetOwnership()

			if IsValid(owner) then
				local hasAccess = self:HasAccess(ply)

				if hasAccess then
					if self.Claimer then
						ply:notify("You can't access a " .. self:GetBenchName():lower() .. " while it's being claimed!")
					else
						self.core.use(self, ply)
					end
				else
					if self.Claimer then
						ply:notify("This is already being claimed!")
					else
						self:AskClaim(ply)
					end
				end
			else
				self:SetOwnership(ply)
			end
		else
			self.core.use(self, ply)
		end
	end

	function ENT:AskClaim(ply)
		net.Start("WBAskClaim")
			net.WriteEntity(self)
		net.Send(ply)
	end

	function ENT:StartClaim(ply)
		if ply.IsClaiming then
			ply:notify("You are already claiming!")
			return
		end

		local curOwner = self:GetOwnership()

		local timerID = "WBClaim" .. self:EntIndex()

		if self.Claimer or timer.Exists(timerID) then
			if !self.Claimer or self.Claimer != ply then
				ply:notify("This " .. self:GetBenchName():lower() .. " is already being claimed by someone else!")
			end
			return
		end

		if IsValid(curOwner) then
			curOwner:notify("Your " .. self:GetBenchName():lower() .. " is being claimed!")
		end

		net.Start("StartWBClaim")
			net.WriteEntity(self:GetOwnership())
		net.Send(ply)

		net.Start("WBClaimStarted")
			net.WriteEntity(ply)
		net.Send(self:GetOwnership())

		timer.Create(timerID, Workbenches.Config.ClaimTime, 1, function()
			if !IsValid(ply) or !IsValid(self) then return end
			self:FinishClaim(ply)
		end)

		local hookID = "WBClaimDistance" .. self:EntIndex()
		hook.Add("Think", hookID, function()
			if !IsValid(ply) or !IsValid(self) then
				hook.Remove("Think", hookID)
				return
			end

			local distance = ply:GetPos():DistToSqr(self:GetPos())
			if distance > Workbenches.Config.ClaimRadius * Workbenches.Config.ClaimRadius then
				self:HaltClaim()
			end

			for k,v in pairs(ents.FindInSphere(self:GetPos(), Workbenches.Config.ClaimRadius)) do
				if v == self:GetOwnership() and v:Alive() then
					self:ChangeContested(true, ply)
					return
				end
			end

			if self.Contested then
				self:ChangeContested(false, ply)
			end
		end)

		ply.IsClaiming = true
		self.Claimer = ply
	end

	function ENT:ChangeContested(contested, ply)
		self.Contested = contested

		net.Start("WBContest")
			net.WriteBool(contested)
		net.Send(ply)

		if !timer.Exists("WBClaim" .. self:EntIndex()) then return end
		if contested then
			timer.Pause("WBClaim" .. self:EntIndex())
		else
			timer.UnPause("WBClaim" .. self:EntIndex())
		end
	end

	function ENT:HaltClaim()
		if timer.Exists("WBClaim" .. self:EntIndex()) then
			timer.Remove("WBClaim" .. self:EntIndex())
		end
		hook.Remove("Think", "WBClaimDistance" .. self:EntIndex())

		if IsValid(self:GetOwnership()) then
			net.Start("WBClaimHalted")
				net.WriteEntity(self.Claimer)
			net.Send(self:GetOwnership())
		end

		if IsValid(self.Claimer) then
			net.Start("HaltWBClaim")
				net.WriteEntity(self:GetOwnership())
			net.Send(self.Claimer)

			self.Claimer.IsClaiming = false
		end

		self.Claimer = nil
	end

	function ENT:FinishClaim(ply)
		self:HaltClaim()

		if IsValid(ply) and ply:Alive() then
			self:SetOwnership(ply)
		end
	end

	function ENT:OpenInventory(ply) --Not all cores use this function
		net.Start("WBOpenInv")
			net.WriteEntity(self)
		net.Send(ply)
	end

	function ENT:ProduceItem()
		self.core.produce(self)
	end

	function ENT:Set3D2DColor(col)
		self:SetNWBool("ColorReady", true)
		self:SetNWString("3D2DColor", util.TableToJSON(col))
	end

	function ENT:SetLockpickLevel(level)
		self.LockpickLevel = level

		net.Start("WBSetLockpickLevel")
			net.WriteEntity(self)
			net.WriteInt(level, 32)
		net.Broadcast()
	end

	function ENT:ToggleSpawn(boolean)
		if !self.benchID then return end

		local id = self.benchID
		local bool = boolean

			timer.Simple(0, function() -- Forces save on next tick which bypasses cleanup stack issue
				if !Workbenches.Benches[id] then return end -- If workbench was removed entirely from database

				Workbenches.Benches[id].spawn = bool
				Workbenches.log("CHANGED workbench[" .. id .. "] to a spawn state of " .. tostring(boolean):upper() or "NULL")
				Workbenches.SaveBenches()
			end)
	end

	function ENT:OnRemove()
		self:ToggleSpawn(true) -- Set spawn state to 'false' to prevent duplicates
		self:HaltClaim()
		timer.Remove("WBProduction" .. self:EntIndex())
		Workbenches.BenchEnts[self] = nil
	end

	function ENT:GetFaction()
		return self:getNetVar("faction") or false
	end
end

if CLIENT then
	function ENT:Initialize()
		if self:GetModel() == "models/zerochain/props_mining/zrms_melter.mdl" then
			self.WasActive = false

			hook.Add("PreDrawTranslucentRenderables", self, function()
				if LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 400 ^ 2 then return end

				render.ClearStencil()
				render.SetStencilEnable(true)
				render.SetStencilWriteMask(255)
				render.SetStencilTestMask(255)
				render.SetStencilReferenceValue(57)
				render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
				render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
				render.SetStencilFailOperation(STENCIL_ZERO)
				render.SetStencilZFailOperation(STENCILOPERATION_KEEP)

				local angle = self:GetAngles()
				cam.Start3D2D(self:GetPos(), angle, 1)
					surface.SetDrawColor(0, 200, 255, 255)
					draw.NoTexture()
					draw.RoundedBox(0, -23, -23, 46, 46, Color(255, 255, 255, 255))
				cam.End3D2D()

				render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
				render.DepthRange(0, 0.8)

				if self:GetActive() then
					if !IsValid(self.BurnCoal) then
						self.BurnCoal = self:ClientsideModel("models/zerochain/props_mining/zrms_melter_burningcoal.mdl")
					end


					self.BurnCoal:DrawModel()
				end

				if !IsValid(self.BurnChamber) then
					self.BurnChamber = self:ClientsideModel("models/zerochain/props_mining/zrms_melter_burnchamber.mdl")
				end

				self.BurnChamber:DrawModel()

				render.SetStencilEnable(false)
				render.DepthRange(0, 1)

				if self:GetActive() then
					if !IsValid(self.Coal) then
						self.Coal = self:ClientsideModel("models/zerochain/props_mining/zrms_melter_coal.mdl")
						self.Coal:SetPos(self.Coal:GetPos() + (self:GetUp() * -23) + (self.Coal:GetUp() * 15))
					end

					self.Coal:DrawModel()

					local light = DynamicLight(self:EntIndex())

					light.pos = self:GetPos() + self:GetUp() * 15
					light.r = 255
					light.g = 75
					light.b = 0
					light.brightness = 1
					light.Decay = 1000
					light.Size = 512
					light.DieTime = CurTime() + 1
				end

				if self:GetActive() and !self.WasActive then
					ParticleEffectAttach("zrms_melter_coalpit", PATTACH_POINT_FOLLOW, self, self:LookupAttachment("coalpit"))
					ParticleEffectAttach("zrms_melter_head", PATTACH_POINT_FOLLOW, self, self:LookupAttachment("body"))
					ParticleEffectAttach("zrms_melter_chimney", PATTACH_POINT_FOLLOW, self, self:LookupAttachment("chimney01"))
					ParticleEffectAttach("zrms_melter_chimney", PATTACH_POINT_FOLLOW, self, self:LookupAttachment("chimney02"))
					self:ResetSequence("unload_start")

					if !self.Sound then
						self.Sound = CreateSound(self, "zrmine_sfx_melter_loop")
					end

					self.Sound:Play()

					self.WasActive = true
				end

				if !self:GetActive() and self.WasActive then
					self:StopParticles()
					self:ResetSequence("open")

					self.Sound:FadeOut(1)

					self.WasActive = false
				end
			end)
		end
	end

	function ENT:ClientsideModel(model)
		ent = ClientsideModel(model)

		ent:SetPos(self:GetPos())
		ent:SetAngles(self:GetAngles())
		ent:SetParent(self)
		ent:SetNoDraw(true)

		return ent
	end

	function ENT:Draw()
		self:DrawModel()

		if self:GetDisplay3D2D() then
			local name = self:GetBenchName()

			local ply = LocalPlayer()
			if ply:GetPos():DistToSqr(self:GetPos()) > 500 * 500 then return end

			self.alpha = self.alpha or 0

			if ply:GetEyeTrace().Entity == self then
				self.alpha = math.Clamp(self.alpha + 2, 0, 255)
			else
				self.alpha = math.Clamp(self.alpha - 2, 0, 255)
			end

			if self.alpha <= 0 then return end

			local owner = self:GetOwnership()

			local eyeAng = EyeAngles()
			eyeAng.p = 0
			eyeAng.y = eyeAng.y - 90
			eyeAng.r = 90

			local faction = ""
			local char = LocalPlayer():getChar()
			if char then
				faction = nut.faction.indices[char:getFaction()].uniqueID
			end

			cam.Start3D2D(self:GetPos() + Vector(0, 0, self:OBBMaxs().z + 10), eyeAng, 0.05)
				self:ShadowText(name, 0, -45, self.alpha)

				if self:GetCapturable() then
					if owner == ply then
						self:ShadowText("Use to open menu", 0, 0, self.alpha)
					elseif IsValid(owner) and self:GetFactionAccess() and self:GetFaction() == faction then
						self:ShadowText("Owned By: " .. owner:Nick(), 0, 0, self.alpha)
						self:ShadowText("Use to open menu", 0, 45, self.alpha)
					elseif IsValid(owner) then
						self:ShadowText("Owned By: " .. owner:Nick(), 0, 0, self.alpha)
						self:ShadowText("Use to begin claiming", 0, 45, self.alpha)
					else
						self:ShadowText("No Owner", 0, 0, self.alpha)
						self:ShadowText("Use to claim", 0, 45, self.alpha)
					end
				end
			cam.End3D2D()
		end
	end

	function ENT:ShadowText(text, x, y, alpha)
		if !self:GetNWBool("ColorReady") then return end

		self.color = self.color or self:Get3D2DColor()

		self.color.a = alpha

		jlib.ShadowText(text, "WB3D2D", x, y, self.color, Color(0, 0, 0, alpha), 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function ENT:Get3D2DColor()
	return util.JSONToTable(self:GetNWString("3D2DColor", util.TableToJSON(Color(255, 255, 255, 255))))
end

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Configured")
	self:NetworkVar("Bool", 1, "Display3D2D")
	self:NetworkVar("Bool", 2, "Capturable")
	self:NetworkVar("Bool", 3, "FactionAccess")
	self:NetworkVar("Bool", 4, "Lockpickable")
	self:NetworkVar("Bool", 5, "Active")

	self:NetworkVar("Int", 0, "Fuel")
	self:NetworkVar("Int", 1, "MaxUses")
	self:NetworkVar("Int", 2, "ProductionTime")
	self:NetworkVar("Int", 3, "MaxCrafts")
	self:NetworkVar("Int", 4, "InvX")
	self:NetworkVar("Int", 5, "InvY")

	self:NetworkVar("Entity", 0, "Ownership")

	self:NetworkVar("String", 0, "BenchName")
	self:NetworkVar("String", 1, "Faction")
	self:NetworkVar("String", 2, "Input")
	self:NetworkVar("String", 3, "Output")

	if SERVER then
		self:SetConfigured(false)
		self:SetDisplay3D2D(false)
		self:SetCapturable(false)
		self:SetFactionAccess(false)
		self:SetLockpickable(false)

		self:SetFuel(0)
		self:SetMaxUses(3)
		self:SetProductionTime(30)
		self:SetMaxCrafts(4)
		self:SetInvX(7)
		self:SetInvY(7)

		self:SetOwnership(NULL)

		self:SetBenchName("Workbench")
		self:SetFaction("wastelander")
		self:SetInput("")
		self:SetOutput("")
	end
end

function ENT:OnLockpicked(lockpicker)
	if !self:GetLockpickable() or CLIENT then return end

	self.core.lockpicked(self, lockpicker)
end

function ENT:StartBenchSound(ply)
	if SERVER then
		net.Start("WBSoundStart")
			net.WriteEntity(self)
			net.WriteString(self.Sound)
		net.Send(ply or player.GetAll())

		self.SoundPlaying = true
	end

	if CLIENT then
		self.Sound = self.Sound or CreateSound(self, self.SoundPath)

		if !self.Sound:IsPlaying() then
			self.Sound:Play()
		end
	end
end

function ENT:StopBenchSound(fadeTime, ply)
	if SERVER then
		net.Start("WBSoundStop")
			net.WriteEntity(self)
			net.WriteInt(fadeTime, 32)
		net.Send(ply or player.GetAll())

		self.SoundPlaying = false
	end

	if CLIENT and self.Sound and self.Sound:IsPlaying() then
		self.Sound:FadeOut(fadeTime)
	end
end

if CLIENT then
	function ENT:OnRemove()
		self:StopBenchSound(0)
	end
end

function ENT:HasAccess(ply)
	if !self:GetCapturable() then
		return true
	else
		local char = ply:getChar()
		local owner = self:GetOwnership()

		if owner == ply then
			return true
		end

		if !IsValid(owner) then
			return false
		end

		local ownerChar = owner:getChar()

		if !char or !ownerChar then
			return false
		end

		if ply:IsSuperAdmin() then return true end

		if self:GetFactionAccess() and char:getFaction() == ownerChar:getFaction() then
			return true
		end
	end

	return false
end
