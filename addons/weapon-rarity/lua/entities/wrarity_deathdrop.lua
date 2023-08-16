AddCSLuaFile()

ENT.Type      = "anim"
ENT.Base      = "base_gmodentity"

ENT.PrintName = "Death Drop"
ENT.Author    = "jonjo"
ENT.Category  = "Claymore Gaming"

ENT.Spawnable = true

if SERVER then
	function ENT:Initialize()
		self:SetModel("models/props_lab/box01a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:DropToFloor()

		local physObj = self:GetPhysicsObject()
		if IsValid(physObj) then
			physObj:Wake()
			physObj:EnableMotion(false)
		end

		self:EmitSound("lootdropped.mp3", 70)

		timer.Simple(wRarity.Config.DropTimeout, function()
			if IsValid(self) then
				self:Remove()
			end
		end)
	end

	function ENT:Use(ply)
		if self:GetIsWep() then
			local created, err = wRarity.CreateItem(ply:getChar():getInv(), self:GetItem(), wRarity.Config.Rarities[self:GetRarity()])
			if created == false then
				ply:notifyLocalized(err)
				return
			end
			self:Remove()

			ply:notify("You picked up a " .. wRarity.Config.Rarities[self:GetRarity()].name .. " " .. nut.item.list[self:GetItem()].name .. "!")
		else
			local x, y = ply:getChar():getInv():add(self:GetItem())
			if !x then
				if y == "noSpace" then
					ply:notify("You don't have enough space to loot this!")
				else
					ply:notify("Error: " .. y)
				end

				return
			end

			self:Remove()

			ply:notify("You picked up " .. nut.item.list[self:GetItem()].name .. "!")
		end
	end
end

if CLIENT then
	function ENT:Initialize()
		local hookID = "wRarityHalosDrop" .. self:EntIndex()

		hook.Add("PreDrawHalos", hookID, function()
			if !IsValid(self) then
				hook.Remove("PreDrawHalos", hookID)
				return
			end

			halo.Add({self}, wRarity.Config.Rarities[self:GetRarity()].color)
		end)
	end

	function ENT:Draw()
		if self:GetNoDraw() then return end

		self:DrawModel()

		if LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 750*750 then
			return
		end

		local rarityColor
		if self:GetIsWep() then
			rarityColor = table.Copy(wRarity.Config.Rarities[self:GetRarity()].color)
		else
			rarityColor = table.Copy(nut.loot.colors[self:GetRarity()])
		end

		rarityColor.a = 180

		self.radius = math.min((self.radius or 0) + (FrameTime() * 140), 450)
		self.height = math.min((self.height or 0) + (FrameTime() * 224), 750)

		surface.SetDrawColor(rarityColor)
		cam.Start3D2D(self:GetPos() - Vector(0, 0, 3.3), Angle(0, 0, 0), 0.05)
			jlib.DrawCircle(0, 0, self.radius, 25)
		cam.End3D2D()

		local angles = EyeAngles()
		angles = Angle(0, angles.y + 270, 90)

		cam.Start3D2D(self:GetPos() + Vector(0, 0, 55), angles, 0.05)
			local w, h = 50, self.height
			surface.DrawRect(-w / 2, 0, w, h)

			local str
			if self:GetIsWep() then
				str = wRarity.Config.Rarities[self:GetRarity()].name .. " " .. nut.item.list[self:GetItem()].name
			else
				str = nut.loot.names[self:GetRarity()] .. " " .. nut.item.list[self:GetItem()].name
			end

			surface.SetFont("wRarityLarge")
			w, h = surface.GetTextSize(str)

			surface.SetDrawColor(0, 0, 0, 180)
			surface.DrawRect(75, 0, w, h)

			surface.SetTextColor(255, 255, 255, 255)
			surface.SetTextPos(75, 0)
			surface.DrawText(str)
		cam.End3D2D()
	end
end

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "Item")
	self:NetworkVar("Int", 0, "Rarity")
	self:NetworkVar("Bool", 0, "IsWep")

	if SERVER then
		self:SetItem("weapon_poolcue")
		self:SetRarity(1)
		self:SetIsWep(true)
	end
end
