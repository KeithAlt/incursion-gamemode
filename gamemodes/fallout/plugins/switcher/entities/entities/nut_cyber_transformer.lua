if SERVER then
	util.AddNetworkString( "cyberTransformerNotif" )
end

if CLIENT then --  Unique information notification
	net.Receive("cyberTransformerNotif", function()
		chat.AddText(Color(255,0,0), "[ NOTICE ] ", Color(0,255,0), "Cyber Chamber Information:")
		chat.AddText("· The Cyber Chamber will transform you into a Robotic Humanoid")
	end)
end

ENT.Type = "anim"
ENT.Base = "nut_switcher"
ENT.PrintName = "Cyber Chamber"
ENT.Author = "Chancer"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "Switcher Entities"

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.name = "Cyber Chamber"
ENT.model = "models/visualitygaming/fallout/prop/autodoc_mk3.mdl" --model of the entity
ENT.nsfaction = "cyber_initative" --faction that it switches you to
ENT.nsclass = "Cyber Initative - Soldier" --class that it switches you to (only works if in correct faction)
ENT.nsmodel = "models/player/misc/death_star/droid_104th.mdl" --model that it switches you to
ENT.TransformTime = 7 --how long it takes to transform
ENT.NotifDescription = "Do you wish to become a Cybernetic Human?" --confirmation message
ENT.humanOnly = true-- If the Switcher should only be usable by humans

ENT.itemCost = "cybercore"
ENT.itemDesc = "Cyber Core inserted into chamber"

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

function ENT:onUseStart(activator)
	self:EmitSound("ambient/levels/citadel/pod_open1.wav")
	self:SetBodygroup(1,0)
	util.ScreenShake(self:GetPos(), 500, 100, 2, 300)
	self.fevChamberActivated = nil

	timer.Simple(0.1, function()
		self:EmitSound("StartSwitch")
	end)

	if SERVER then
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

	timer.Simple(0.2, function()
		if IsValid(activator) then
			activator:SetPos(self:GetPos() + Vector(0,0,30))
			self:EmitSound("ambient/levels/citadel/pod_open1.wav")
		end
	end)

	activator:ChatPrint("[ NOTICE ]  You have been transformed into a Cybernetic!")
	activator:ChatPrint("- Do not wear clothing items that are not intended for your class")
	activator:ChatPrint("- If you do not want to remain a Cybernetic there are cures in the wasteland")
	activator:falloutNotify("You've been transformed into a Cybernetic", "ui/ui_experienceup.mp3")
end
