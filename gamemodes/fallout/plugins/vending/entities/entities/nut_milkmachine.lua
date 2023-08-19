AddCSLuaFile()

ENT.Type 			= "anim"
ENT.PrintName = "Milk Machine"
ENT.Category 	= "NutScript"
ENT.Spawnable = true
ENT.AdminOnly = true

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/vex/seventysix/vending/milkmachine.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(false)

		local physics = self:GetPhysicsObject()
		physics:EnableMotion(false)
		physics:Sleep()

		self.sound = CreateSound(self, Sound("ambient/machines/machine6.wav"))
		self.sound:SetSoundLevel(60)
		self.sound:PlayEx(1, 100)

		self.cost = 5
		self.item = "drink_milk"

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
		return
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
				self.nextUse = CurTime() + (self.cost / 2) + 4

				character:takeMoney(self.cost)
				self:setNetVar("stock", stock)

				stock[id] = nil

				self:setNetVar("money", self:getNetVar("money", 0) + self.cost)

				for i = 1, self.cost do
					timer.Simple(i / 2, function() self:EmitSound("ambient/levels/labs/coinslot1.wav") end)
				end

				timer.Simple((self.cost / 2) + 1, function()
					activator:ChatPrint("You pay "..self.cost.." Caps and receive an ice cold bottle of "..nut.item.list[cola].name..".")

					self:EmitSound("fallout/dispense_generic.wav")

					timer.Simple(1, function()
						self:EmitSound("fallout/milkmachine/open.wav")

						self:UpdateFridge()

						timer.Simple(1, function() self:EmitSound("fallout/milkmachine/close.wav") end)

						timer.Simple(1.5, function() self:EmitSound("fallout/milkmachine/moo_"..math.random(1, 5)..".wav") end)
					end)
				end)
			else
				self.nextUse = CurTime() + 1
				activator:ChatPrint("The following error occured: '"..error.."'")
			end
		else
			self.nextUse = CurTime() + 1
			activator:ChatPrint("You need at least "..self.cost.." Caps to buy a bottle of cold fresh milk.")
		end
	end
end
