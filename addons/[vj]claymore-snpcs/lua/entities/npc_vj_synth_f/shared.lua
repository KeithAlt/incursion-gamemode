ENT.Base 			= "npc_vj_human_base" -- Full list of bases is in the base, or go back to this link and read the list: https://saludos.sites.google.com/site/vrejgaming/makingvjbaseaddon

ENT.Type 			= "ai"

ENT.PrintName 		= "Institute Synth (Friendly)"

ENT.Author 			= "SOMEBODY SAY HO!"

ENT.Contact 		= "http://steamcommunity.com/profiles/76561198180831682/"

ENT.Purpose 		= "Spawn it and fight with it!"

ENT.Instructions 	= "Click on the spawnicon to spawn it."

ENT.Category		= "Resistance: Fall of Man"



if (CLIENT) then

	local Name = "SRPA Soldier"

	local LangName = "npc_vj_resistance_srpa_soldier"

	language.Add(LangName, Name)

	killicon.Add(LangName,"HUD/killicons/default",Color(255,80,0,255))

	language.Add("#"..LangName, Name)

	killicon.Add("#"..LangName,"HUD/killicons/default",Color(255,80,0,255))

end


function ENT:OnRemove()
	if SERVER and self:Health() > 0 then -- PARTICLE EFFECT EVENTS (By Keith)
		local particleAttach = ents.Create("prop_physics")
		particleAttach:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		particleAttach:SetMoveType(MOVETYPE_NONE)
		particleAttach:SetRenderMode(RENDERMODE_NONE)
		particleAttach:DrawShadow(false)
		particleAttach:SetPos(self:GetPos() + Vector(0,0,25))
		particleAttach:Spawn()
		particleAttach:SetNotSolid(true)

		particleAttachPhysics = particleAttach:GetPhysicsObject()
		particleAttachPhysics:EnableMotion(false)

	ParticleEffect("_sai_wormhole", particleAttach:GetPos(), Angle(-90), particleAttach)
	ParticleEffect("mr_energybeam_1", particleAttach:GetPos() + Vector(0,0,300), Angle(-270,-0, -0), particleAttach)
		ParticleEffect("mr_cop_anomaly_electra_a", particleAttach:GetPos(), particleAttach:GetAngles(), particleAttach)
		particleAttach:EmitSound("npc/scanner/cbot_energyexplosion1.wav")
		util.ScreenShake(particleAttach:GetPos(), 100, 100, 2, 100)

		timer.Simple(0.2, function()
			if IsValid(particleAttach) then
				particleAttach:Remove()
			end
		end)
	end
end
