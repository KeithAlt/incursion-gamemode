ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Combatant - Blade"
ENT.Category		= "Melee Arts 2"

ENT.Spawnable		= true
ENT.AdminOnly = false
ENT.DoNotDuplicate = false

if SERVER then

	AddCSLuaFile("shared.lua")

	function ENT:Initialize()

		local model = ("models/props_c17/FurnitureDrawer003a.mdl")
		
		self.Entity:SetModel(model)
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_NONE)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetMaterial("models/props_wasteland/quarryobjects01")
		self.Entity:SetModelScale(1)
		self.Entity:SetColor(Color(255,255,255))
		self.Entity:SetNoDraw(false)
		self.Entity:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)

	  self:Explode()
	end
	function ENT:Explode()
		local ent = ents.Create("npc_combine_s")
		ent:SetPos(self.Entity:GetPos() + Vector( 0, 0, 10 ) )
		ent:Spawn()
		ent:Fire("GagEnable")
		ent:SetNPCState(NPC_STATE_ALERT)
		ent:SetHealth(math.random(90,100))
		ent:SetNWInt("matier",math.Round(math.random(1,GetConVarNumber("ma2_combatantmaxtier"))))
		ent:SetNWBool("MACombatant",true)
		--print(ent:GetNWInt("matier"))
		ent:Give("npc_mablade")
		local w = math.random(1)
		w = math.random(1,9)
		if w == 1 then
			ent:SetModel("models/Humans/Group03/male_01.mdl")
		elseif w == 2 then
			ent:SetModel("models/Humans/Group03/male_02.mdl")
		elseif w == 3 then
			ent:SetModel("models/Humans/Group03/male_03.mdl")
		elseif w == 4 then
			ent:SetModel("models/Humans/Group03/male_04.mdl")
		elseif w == 5 then
			ent:SetModel("models/Humans/Group03/male_05.mdl")
		elseif w == 6 then
			ent:SetModel("models/Humans/Group03/male_06.mdl")
		elseif w == 7 then
			ent:SetModel("models/Humans/Group03/male_07.mdl")
		elseif w == 8 then
			ent:SetModel("models/Humans/Group03/male_08.mdl")
		elseif w == 9 then
			ent:SetModel("models/Humans/Group03/male_09.mdl")
		end
		--PrintTable( ent:GetSequenceList() )
		--PrintTable( ent:GetSequenceList() )
		--ent:SetNWBool("MABoss",true)
		--ent:SetMaterial("models/props_wasteland/tugboat01")
		self.Entity:Remove()
	end
end