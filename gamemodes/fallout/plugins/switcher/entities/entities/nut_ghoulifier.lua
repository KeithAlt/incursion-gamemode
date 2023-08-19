if SERVER then
	util.AddNetworkString( "ghoulTransformerNotif" )
end

if CLIENT then --  Unique information notification
	net.Receive("ghoulTransformerNotif", function()
		chat.AddText(Color(255,0,0), "[ NOTICE ] ", Color(0,255,0), "Ghoulifier Chamber Information:\n· This chamber transforms humans into ghouls\n· Requires either a F.E.V. Sample or Enclave Access Pad to use")
	end)
end

ENT.Type = "anim"
ENT.Base = "nut_switcher"
ENT.PrintName = "Ghoulifier Switcher"
ENT.Author = "Claymore Gaming"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "Switcher Entities"

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.name = "Ghoulification Chamber"
ENT.model = "models/cyberpod/cyberpod.mdl" --model of the entity
--ENT.nsfaction = "" --faction that it switches you to
--ENT.nsclass = "" --class that it switches you to (only works if in correct faction)
--ENT.nsmodel = "models/player/keitho/subermutant/subermutantchiefpm.mdl" --model that it switches you to
ENT.TransformTime = 7 --how long it takes to transform
ENT.NotifDescription = "Do you enter the chamber? [FearRP must]" --confirmation message
ENT.itemCost = "enclavekeycard" -- by uniqueID, the required fuel for the switcher
ENT.itemDesc = "Activator inserted into chamber" -- the notification you will recieve if the item is put in
ENT.humanOnly = true-- If the Switcher should only be usable by humans

sound.Add( {
	name = "StartSwitch",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = {95, 110},
	sound = "ambient/machines/combine_shield_touch_loop1.wav"
} )

function ENT:Initialize()
	if (SERVER) then
		self:SetModel(self.model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetBodygroup(1,1)

		local physicsObject = self:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:EnableMotion(false)
			physicsObject:Sleep()
		end
	end
end

function ENT:onUseStart(activator)
	self:EmitSound("ambient/levels/citadel/pod_open1.wav")
	util.ScreenShake(self:GetPos(), 500, 100, 2, 300)
	self.fevChamberActivated = nil

	for k, v in pairs(ents.FindInSphere(self:GetPos(), 1000)) do
		if v:IsPlayer() then
			timer.Simple(0, function() -- Prevents a client issue if called twice on same tick
				v:ScreenFade(SCREENFADE.IN, Color(0,255,0,100), 1, 0)
			end)
		end
	end

	timer.Simple(0.1, function()
		self:EmitSound("StartSwitch")
	end)

	if SERVER then
		local fx = ents.Create("mr_effect15") -- Scuffed method but for some reason ParticleEffect funcs not cooperating
		fx:SetPos(self:GetPos() + Vector(0,0,40))
		fx:SetAngles(self:GetAngles())
		fx:Spawn()
		fx:SetNotSolid(true)
		fx:Activate()

		local fxPhysics = fx:GetPhysicsObject()
		if (IsValid(fxPhysics)) then
			fxPhysics:EnableMotion(false)
		end

		timer.Simple(self.TransformTime + 0.5, function()
			if IsValid(fx) && SERVER then
				fx:Remove()
			end
		end)
	end
end

function ENT:onUseEnd(activator)
	if IsValid(activator) then
		self:StopSound("StartSwitch")
		util.ScreenShake(self:GetPos(), 500, 100, 2, 300)

		timer.Simple(0.2, function()
			activator:ChatPrint("[ NOTICE ]  You have been ghoulified!\n- There are ways to cure yourself of this\n- All who aided in this act or witnessed it happen are penalty to your vengence")
			activator:falloutNotify("You've been transformed into a Ghoul!", "fallout/death/death_2.wav")
			activator:Spawn()
			activator:SetPos(self:GetPos() + (self:GetForward() * 50))
			self:EmitSound("ambient/levels/citadel/pod_open1.wav")
			activator:EmitSound("ambient/energy/zap" .. math.random(1,9) .. ".wav", 50, 100, 0.60)
			ParticleEffectAttach( "mr_fx_beamelectric_arcc1", PATTACH_POINT_FOLLOW, activator, 4 )

			for k, v in pairs(ents.FindInSphere(self:GetPos(), 1000)) do
				if v:IsPlayer() then
					v:ScreenFade(SCREENFADE.IN, Color(255,255,255,100), 1, 0)
				end
			end

			timer.Simple(2, function()
				activator:EmitSound("ambient/energy/zap" .. math.random(1,9) .. ".wav", 50, 100, 0.60)
				activator:StopParticles()
			end)
		end)

		activator:SetSex("ghoul")
		activator:SetRace("ghoul")
		activator:SetHeadSkin(3)
		Armor.SetSex(activator, "ghoul")
		Armor.SetSkin(activator, 3)
		Armor.SetHairColor(activator, Color(255, 255, 255))
	end
end
