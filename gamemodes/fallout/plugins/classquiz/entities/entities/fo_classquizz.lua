local PLUGIN = PLUGIN

AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Class Quizz"
ENT.Author = "SuperMicronde"
ENT.Spawnable = true
ENT.Category = "NutScript"
ENT.AdminOnly = true
ENT.Category = "Claymore Gaming"

if (SERVER) then
	function ENT:Initialize()
		if ( !self.foQuizz ) then
			self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		end

		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )
		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end
	end

	function ENT:Use(activator)
		local char = activator:getChar()
		if not char then return end

		if ( not self.foQuizz ) then return end

		if char:getFaction() != PLUGIN.Quizzes[self.foQuizz][6] then
			if not nut.faction.indices[PLUGIN.Quizzes[self.foQuizz][6]] then return end
			activator:notify("You aren't in "..nut.faction.indices[PLUGIN.Quizzes[self.foQuizz][6]].name.." faction.")
			return
		end

		if char:getClass() == PLUGIN.Quizzes[self.foQuizz][5] && nut.class.list[char:getClass()] then
			activator:notify("Your class is already "..nut.class.list[char:getClass()].name)
			return
		end

		if not PLUGIN:CanTakeQuizz(char, self.foQuizz) then
			local data = char:getData("quizzes", {})

			activator:notify("You failed the quizz, you may take it again on "..os.date("%c", data[self.foQuizz])..".")
			return
		end

		netstream.Start(activator, "fo_classquizz", self, PLUGIN.Quizzes[self.foQuizz][3])
	end
else

	ENT.DrawEntityInfo = true

	local COLOR_LOCKED = Color(242, 38, 19)
	local COLOR_UNLOCKED = Color(135, 211, 124)
	local toScreen = FindMetaTable("Vector").ToScreen
	local colorAlpha = ColorAlpha
	local drawText = nut.util.drawText
	local configGet = nut.config.get

	function ENT:onDrawEntityInfo(alpha)
		local locked = self.getNetVar(self, "locked", false)
		local position = toScreen(self.LocalToWorld(self, self.OBBCenter(self)))
		local x, y = position.x, position.y

		local tx, ty = drawText(self:getNetVar("title", "Quizz"), x, y, colorAlpha(configGet("color"), alpha), 1, 1, nil, alpha * 0.65)
	end

end