SlaveSpawns = {}

ENT.Type = "anim"
ENT.PrintName = "Slave Spawn"
ENT.Category = "NutScript"
ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:Initialize()
	if (SERVER) then
		self:SetModel("models/props_trainstation/TrackSign01.mdl")
		self:SetUseType(SIMPLE_USE)
		self:SetMoveType(MOVETYPE_NONE)
		self:DrawShadow(true)
		self:SetSolid(SOLID_BBOX)
		self:PhysicsInit(SOLID_BBOX)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

		self:setNetVar("owner", false)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
			physObj:Sleep()
		end

		if self:GetOwner():IsValid() then
			local id = self:GetOwner():getChar():getID()
			self:setNetVar("owner", id)
			SlaveSpawns[id] = self
		end
	end
end

function ENT:OnRemove()
    SlaveSpawns[self:getNetVar("owner", -1)] = nil
end

if (CLIENT) then
	function ENT:Draw()
		self:DrawModel()
	end

	local TEXT_OFFSET = Vector(0, 0, 20)
	local toScreen = FindMetaTable("Vector").ToScreen
	local colorAlpha = ColorAlpha
	local drawText = nut.util.drawText
	local configGet = nut.config.get

	ENT.DrawEntityInfo = true

	function ENT:onDrawEntityInfo(alpha)
		local position = toScreen(self.LocalToWorld(self, self.OBBCenter(self)) + TEXT_OFFSET)
		local x, y = position.x, position.y
		local owner = self.getNetVar(self, "owner")

		drawText("Slave Spawnpoint", x, y, colorAlpha(configGet("color"), alpha), 1, 1, nil, alpha * 0.65)

		if (owner) then
			owner = nut.char.loaded[owner]:getName() or "Inactive"
			drawText("Owner: "..owner, x, y + 16, colorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
		end
	end
end
