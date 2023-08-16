if SERVER then
	util.AddNetworkString( "synthChamberNotif" )
	util.AddNetworkString( "synthExitChamberNotif" )
end

if CLIENT then -- Using due to extreme custom nature of message
	net.Receive("synthChamberNotif", function()
		chat.AddText(Color(255,131,0), "[ INFORMATION ] ", Color(0,101,255), "Synth Replicant Chamber:")
		chat.AddText("· This chamber will transform you into a Synth Replicant")
		chat.AddText("____________________________________________")
		chat.AddText(Color(0,101,255), "Synth Replicants have the following:")
		chat.AddText("· Body replaced with metal replicant endoskeleton")
		chat.AddText("· Immune to RP diseases & human-specific ailments")
		chat.AddText("· Opportunity to become immortal (if useful to Institute)")
		chat.AddText("· Opportunity to become GEN III SYNTH (if useful to Institute)")
		chat.AddText("____________________________________________")
		chat.AddText("· Interact with the machine again if you wish to proceed.")
		chat.AddText("____________________________________________")
	end)
	net.Receive("synthExitChamberNotif", function()
		chat.AddText(Color(255,131,0), "[ INFORMATION ] ", Color(0,101,255), "Synth Replicant Guide:")
		chat.AddText("· You have become a Synth Replicant")
		chat.AddText("____________________________________________")
		chat.AddText(Color(0,101,255), "The following apply:")
		chat.AddText("· All previously stated possible perks apply")
		chat.AddText("· Your memory of this and you being a Synth will be told to you")
		chat.AddText("· If you hear your compliance code, you must obey the person")
		chat.AddText("· Hide your true identity unless you have a deathwish")
		chat.AddText("· If any action would reveal you are a synth, you must tell them. (Skin penetration, etc)")
		chat.AddText("· You can be PK'd for being a Synth, your new character will be human")
		chat.AddText("____________________________________________")
		chat.AddText(Color(0,101,255), "COMPLIANCE CODE: ", Color(255,130,130), "ALPHASYS-58")
		chat.AddText("· Do not EVER repeat this information (even OOCly)")
	end)
end

ENT.Type = "anim"
ENT.Base = "nut_switcher"
ENT.PrintName = "Synth Body Switcher"
ENT.Author = "Chancer"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "Switcher Entities"

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.name = "Synth Replicant Chamber"
ENT.model = "models/visualitygaming/fallout/prop/autodoc_mk3.mdl" --model of the entity
--ENT.nsfaction = "supermutant" --faction that it switches you to
--ENT.nsclass = "Super Mutant - Traveler" --class that it switches you to (only works if in correct faction)
--ENT.nsmodel = "models/arachnit/fallout4/synths/synthgeneration1.mdl" --model that it switches you to (Doesn't work with new armor system)
ENT.TransformTime = 12 --how long it takes to transform
ENT.NotifDescription = "Do you wish to become a Synth Replicant?" --confirmation message

	sound.Add( {
	name = "StartSwitch",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = {95, 110},
	sound = "ambient/machines/city_ventpump_loop1.wav"
	} )

function ENT:Initialize()
	if(SERVER) then
		self:SetModel(self.model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetBodygroup(1,1)

		local pos = self:GetPos()

		local physicsObject = self:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:EnableMotion(false)
			physicsObject:Sleep()
		end
	end
end

function ENT:Use(activator)
	--prompt whether or not they want to switch to whatever here

	if !activator.replicantNotifcooldown then
		net.Start("synthChamberNotif")
		net.Send(activator)
		activator.replicantNotifcooldown = true
		self:EmitSound("ambient/levels/citadel/pod_open1.wav")

		timer.Simple(self.nextUse or 5, function()
			if IsValid(activator) then
				activator.replicantNotifcooldown = nil
			end
		end)
	return end

	if((self.nextUse or 0) < CurTime()) then
		self.nextUse = CurTime() + 1

		netstream.Start(activator, "nut_switcherStart", self)
	end
end

function ENT:onUseStart(activator)
	self:EmitSound("ambient/levels/citadel/pod_open1.wav")
	self:SetBodygroup(1,0)
	util.ScreenShake(self:GetPos(), 500, 100, 2, 300)

	timer.Simple(0.1, function()
		self:EmitSound("StartSwitch")
	end)

	if SERVER then
		activator:falloutNotify("You fade into unconciousness . . .", "ui/notify.mp3")

		local fx = ents.Create("mr_effect19") -- Scuffed method but for some reason ParticleEffect funcs not cooperating
		fx:SetPos(self:GetPos() + Vector(0,0,40))
		fx:SetAngles(self:GetAngles())
		fx:SetNotSolid(true)
		fx:Spawn()

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
	self:StopSound("StartSwitch")
	self:SetBodygroup(1,1)
	util.ScreenShake(self:GetPos(), 500, 100, 2, 300)

	net.Start("synthExitChamberNotif")
	net.Send(activator)

	timer.Simple(0.2, function()
		if IsValid(activator) then
			activator:Spawn()
			activator:SetPos(self:GetPos() + Vector(0,0,30))
			self:EmitSound("ambient/levels/citadel/pod_open1.wav")
			activator:getChar():setData("isSynth", true)
		end
	end)
	activator:falloutNotify("You've been transformed into a Synth replicant!", "ui/ui_experienceup.mp3")
end
