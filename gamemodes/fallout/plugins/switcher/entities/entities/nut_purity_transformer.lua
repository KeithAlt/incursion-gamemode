if SERVER then
	util.AddNetworkString( "PurgeNotification" )
end

ENT.Type = "anim"
ENT.Base = "nut_switcher"
ENT.PrintName = "Purity Chamber"
ENT.Author = "Chancer"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "Switcher Entities"

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.name = "Pre-War Purity Chamber"
ENT.model = "models/visualitygaming/fallout/prop/autodoc_mk3.mdl" --model of the entity
ENT.nsfaction = "wastelander" --faction that it switches you to
ENT.nsclass = "Wastelander" --class that it switches you to (only works if in correct faction)
-- ENT.nsmodel = "models/player/keitho/subermutant/subermutantchiefpm.mdl" --model that it switches you to

ENT.itemCost = "enclavekeycard"
ENT.itemDesc = "Enclave Keycard used to activate chamber"

ENT.TransformTime = 15 --how long it takes to transform
ENT.NotifDescription = "Do you wish to enter the Purity Chamber? [FearRP must]" --confirmation message

sound.Add( {
	name = "StartSwitch",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = {95, 110},
	sound = "ambient/machines/city_ventpump_loop1.wav"
} )

function ENT:Initialize()
	if (SERVER) then
		self:SetModel(self.model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetColor(Color(150,150,150))
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
	local char = activator:getChar()
	activator.EditingChar = char:getID()
	self:EmitSound("ambient/levels/citadel/pod_open1.wav")
	self:SetBodygroup(1,0)
	util.ScreenShake(self:GetPos(), 500, 100, 2, 300)

	timer.Simple(0.1, function()
		self:EmitSound("StartSwitch")
	end)

	if SERVER then
		local fx = ents.Create("mr_effect25") -- Scuffed method but for some reason ParticleEffect funcs not cooperating
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

		Armor.ReCreate(activator)
		self.activator = activator
	end

	activator:falloutNotify("[ ! ] All expenses are covered by The Enclave", "ui/notify.mp3")
end

function ENT:Think()
	local activator = self.activator
	if(IsValid(activator)) then
		local char = activator:getChar()
		if(char) then
			activator:SetPos(self:GetPos() + Vector(0,0,30))
			self.activator = nil
		end
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
end

if CLIENT then --  Unique information notification
	function ENT:preUseNotif()
		chat.AddText(Color(255,0,0), "[ NOTICE ] ", Color(255,100,100), "Purity Chamber Information:")
		chat.AddText("· The strange chamber requires an Enclave Access Pad to use")
		chat.AddText("· The strange chamber will convert any non-humans to their human form")
	end
end
