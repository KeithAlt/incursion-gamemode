AddCSLuaFile()

ENT.Type 			= "anim"
ENT.PrintName = "Vim Machine"
ENT.Category 	= "NutScript"
ENT.Spawnable = true
ENT.AdminOnly = true

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/vex/seventysix/vending/nukacolamachine.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(false)

		self:SetSkin(2)

		local physics = self:GetPhysicsObject()
		physics:EnableMotion(false)
		physics:Sleep()

		self.sound = CreateSound(self, Sound("ambient/machines/machine6.wav"))
		self.sound:SetSoundLevel(60)
		self.sound:PlayEx(1, 100)

		self.cost = 5
		self.item = "drink_vim"

		self.fridge = {}

		self:Refill(6)
	end

	function ENT:OnRemove()
		if (self.sound) then
			self.sound:Stop()
		end
	end

	function ENT:Refill(count)
		local stock = self:getNetVar("stock", {})
		local restocked = 0

		for i = 1, 6 do
			if (!stock[i]) then
				if (restocked >= count) then
					return
				end
				restocked = restocked + 1
				stock[i] = self.item
			end
		end

		self:setNetVar("stock", stock)
		self:UpdateFridge()
	end

	function ENT:UpdateFridge()
		local bottles = {
			[6] = {13.5, -8.42, 36.8},
			[5] = {13.5, -13.34, 36.8},
			[4] = {13.5, -18.3, 36.8},
			[3] = {13.5, -8.42, 22.85},
			[2] = {13.5, -13.34, 22.85},
			[1] = {13.5, -18.3, 22.85},
		}

		for i, v in pairs(self.fridge) do
			if (IsValid(v)) then
				v:Remove()
			end
		end

		local stock = self:getNetVar("stock", {})

		for i, v in SortedPairs(bottles) do
			if (stock[i]) then
				self.fridge[i] = ents.Create("prop_dynamic")
					self.fridge[i]:SetModel(nut.item.list[stock[i]].model or "models/mosi/fallout4/props/drink/vim.mdl")
					self.fridge[i]:SetSkin(nut.item.list[stock[i]].skin or 0)
					self.fridge[i]:SetModelScale(0.95)
					self.fridge[i]:SetPos(self:GetPos() + self:GetForward() * v[1] + self:GetRight() * v[2] + self:GetUp() * v[3])
					self.fridge[i]:SetAngles(self:GetAngles())
					self.fridge[i]:SetParent(self)
					self.fridge[i]:DrawShadow(false)
					self.fridge[i]:Spawn()
					self.fridge[i]:Activate()
				self:DeleteOnRemove(self.fridge[i])
			end
		end
	end

	function ENT:Use(activator)
		self.nextUse = self.nextUse or CurTime()
		if (self.nextUse > CurTime()) then
			return
		end

		local character = activator:getChar()

		local stock = self:getNetVar("stock", {})

		if (table.Count(stock) <= 0) then
			self.nextUse = CurTime() + 1
			activator:ChatPrint("The machine seems to be out of stock.")
			return
		elseif (character:hasMoney(self.cost)) then
			local cola, id = table.Random(stock)

			local item, error = character:getInv():add(cola, 1)

			if (item) then
				self.nextUse = CurTime() + (self.cost / 2) + 3

				character:takeMoney(self.cost)
				self:setNetVar("stock", stock)

				stock[id] = nil

				self:setNetVar("money", self:getNetVar("money", 0) + self.cost)

				for i = 1, self.cost do
					timer.Simple(i / 2, function() self:EmitSound("ambient/levels/labs/coinslot1.wav") end)
				end

				timer.Simple((self.cost / 2) + 1, function()
					activator:ChatPrint("You pay "..self.cost.." Caps and receive an ice cold bottle of "..nut.item.list[cola].name..".")

					self:EmitSound("fallout/nukamachine/open.wav")

					timer.Simple(1, function()
						self:EmitSound("fallout/item/bottle_up.wav")

						self:UpdateFridge()

						timer.Simple(0.5, function() self:EmitSound("fallout/nukamachine/close.wav") end)

						--timer.Simple(1, function() self:EmitSound("fallout/prize_dispense.wav") end)
					end)
				end)
			else
				self.nextUse = CurTime() + 1
				activator:ChatPrint("The following error occured: '"..error.."'")
			end
		else
			self.nextUse = CurTime() + 1
			activator:ChatPrint("You need at least "..self.cost.." Caps to buy a bottle of Ice Cold Vim.")
		end
	end
end
