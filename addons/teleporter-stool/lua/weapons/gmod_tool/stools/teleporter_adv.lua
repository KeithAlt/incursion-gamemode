-- Teleporter STool
-- By Anya O'Quinn / Slade Xanthas

AddCSLuaFile()

if SERVER then
	CreateConVar("sbox_maxteleporters_adv", 10)
end

if CLIENT then
    language.Add("tool.teleporter_adv.name", 	"Teleporter")
    language.Add("tool.teleporter_adv.desc", 	"Spawn a Teleporter")
    language.Add("tool.teleporter_adv.0", 		"Primary: Create/Update Teleporter you're looking at.  Spawn two teleporters to make a set.")
	language.Add("Cleanup_teleporters_adv", 	"Teleporters")
	language.Add("Cleaned_teleporters_adv", 	"Cleaned up all Teleporters")
	language.Add("Undone_teleporter_adv", 		"Undone Teleporter")
	language.Add("SBoxLimit_teleporters_adv", 	"You've hit Teleporter limit!")
end

TOOL.Name							= "#tool.teleporter_adv.name"
TOOL.Category						= "Construction"
TOOL.ConfigName						= ""
TOOL.ClientConVar["model"] 			= "models/Items/combine_rifle_ammo01.mdl"
TOOL.ClientConVar["sound"] 			= "ambient/levels/citadel/weapon_disintegrate2.wav"
TOOL.ClientConVar["effect"] 		= "sparks"
TOOL.ClientConVar["radius"] 		= "100"
TOOL.ClientConVar["ontouch"] 		= "0"
TOOL.ClientConVar["onuse"] 			= "0"
TOOL.ClientConVar["showbeam"] 		= "1"
TOOL.ClientConVar["showradius"] 	= "1"
TOOL.ClientConVar["key"] 			= "1"

cleanup.Register("teleporters_adv")

list.Set("TeleporterModels", "models/Items/combine_rifle_ammo01.mdl", {})
list.Set("TeleporterModels", "models/props_c17/clock01.mdl", {})
list.Set("TeleporterModels", "models/props_junk/sawblade001a.mdl", {})
list.Set("TeleporterModels", "models/props_combine/combine_mine01.mdl", {})
list.Set("TeleporterModels", "models/props_wasteland/prison_toilet01.mdl", {})
list.Set("TeleporterModels", "models/props_lab/teleplatform.mdl", {})

list.Set("TeleporterSounds", "None", 				{teleporter_adv_sound = ""})
list.Set("TeleporterSounds", "Teleport 1", 			{teleporter_adv_sound = "ambient/machines/teleport1.wav"})
list.Set("TeleporterSounds", "Teleport 2", 			{teleporter_adv_sound = "ambient/machines/teleport3.wav"})
list.Set("TeleporterSounds", "Teleport 3", 			{teleporter_adv_sound = "ambient/machines/teleport4.wav"})
list.Set("TeleporterSounds", "Zap 1", 				{teleporter_adv_sound = "ambient/machines/zap1.wav"})
list.Set("TeleporterSounds", "Zap 2", 				{teleporter_adv_sound = "ambient/machines/zap2.wav"})
list.Set("TeleporterSounds", "Zap 3", 				{teleporter_adv_sound = "ambient/machines/zap3.wav"})
list.Set("TeleporterSounds", "Disintegrate 1", 		{teleporter_adv_sound = "ambient/levels/citadel/weapon_disintegrate1.wav"})
list.Set("TeleporterSounds", "Disintegrate 2", 		{teleporter_adv_sound = "ambient/levels/citadel/weapon_disintegrate2.wav"})
list.Set("TeleporterSounds", "Disintegrate 3", 		{teleporter_adv_sound = "ambient/levels/citadel/weapon_disintegrate3.wav"})
list.Set("TeleporterSounds", "Disintegrate 4", 		{teleporter_adv_sound = "ambient/levels/citadel/weapon_disintegrate4.wav"})

list.Set("TeleporterEffects", "Prop Spawn", 		{teleporter_adv_effect = "propspawn"})
list.Set("TeleporterEffects", "Explosion", 			{teleporter_adv_effect = "explosion"})
list.Set("TeleporterEffects", "Sparks", 			{teleporter_adv_effect = "sparks"})
list.Set("TeleporterEffects", "None", 				{teleporter_adv_effect = ""})

local function MakeTeleporter(ply, pos, Ang, model, sound, effect, radius, ontouch, onuse, showbeam, showradius, key)

	if not SERVER or not IsValid(ply) or !ply:IsAdmin() then return end
	if not ply:CheckLimit("teleporters_adv") then return false end

	local teleporter = ents.Create("gmod_advteleporter")
	if not IsValid(teleporter) then return false end

	teleporter:SetAngles(Ang)
	teleporter:SetPos(pos)
	teleporter:SetModel(Model(model))
	teleporter:Spawn()
	teleporter.Owner = ply
	teleporter:Setup(model, sound, effect, radius, ontouch, onuse, showbeam, showradius, key)

	numpad.OnDown(ply, key, "Teleporter_On", teleporter)
	numpad.OnUp(ply, key, "Teleporter_Off", teleporter)

	local ttable = {
		model = model,
		sound = sound,
		effect = effect,
		radius = radius,
		ontouch = ontouch,
		onuse = onuse,
		showbeam = showbeam,
		showradius = showradius,
		key = key,
	}

	table.Merge(teleporter:GetTable(), ttable)
	ply:AddCount("teleporters_adv", teleporter)
	DoPropSpawnedEffect(teleporter)

	return teleporter

end

duplicator.RegisterEntityClass("gmod_advteleporter", MakeTeleporter, "pos", "ang", "model", "sound", "effect", "radius", "ontouch", "onuse", "showbeam", "showradius", "key")

function TOOL:LeftClick(trace)
	 if !self:GetOwner():IsAdmin() then return end
	if not trace.Hit then return false end

	local ent = trace.Entity

	if IsValid(ent) and ent:IsPlayer() then return false end
	if SERVER and not util.IsValidPhysicsObject(ent,trace.PhysicsBone) then return false end
	if CLIENT then return true end

	local ply = self:GetOwner()
	local model = self:GetClientInfo("model")
	local sound = self:GetClientInfo("sound")
	local effect = self:GetClientInfo("effect")
	local radius = math.Clamp(self:GetClientNumber("radius"),50,500)
	local ontouch = (self:GetClientNumber("ontouch") == 1)
	local onuse = (self:GetClientNumber("onuse") == 1)
	local showbeam = (self:GetClientNumber("showbeam") == 1)
	local showradius = (self:GetClientNumber("showradius") == 1)
	local key = self:GetClientNumber("key")

	if IsValid(ent) and ent:GetClass() == "gmod_advteleporter" then

		ent:Setup(model, sound, effect, radius, ontouch, onuse, showbeam, showradius, key)

		local ttable = {
			model = model,
			sound = sound,
			effect = effect,
			radius = radius,
			ontouch = ontouch,
			onuse = onuse,
			showbeam = showbeam,
			showradius = showradius,
			key = key,
		}

		table.Merge(ent:GetTable(), ttable)
		return true

	end

	if not self:GetSWEP():CheckLimit("teleporters_adv") then return false end

	local pos = trace.HitPos
	local ang = trace.HitNormal:Angle()
	ang.pitch = ang.pitch + 90

	local teleporter = MakeTeleporter(ply, pos, ang, model, sound, effect, radius, ontouch, onuse, showbeam, showradius, key)

	if not IsValid(teleporter) then return end

	local min = teleporter:OBBMins()
	teleporter:SetPos(trace.HitPos - trace.HitNormal * min.z)

	if not teleporter:IsInWorld() then
		teleporter:Remove()
		return false
	end

	if trace.HitWorld then teleporter:GetPhysicsObject():EnableMotion(false) end

	if IsValid(ent) then
		local const = constraint.Weld(teleporter, ent, trace.PhysicsBone, 0, 0)
		local nocollide = constraint.NoCollide(teleporter, ent, 0, trace.PhysicsBone)
		ent:DeleteOnRemove(teleporter)
	end

	undo.Create("teleporter_adv")
		undo.AddEntity(teleporter)
		undo.AddEntity(const)
		undo.AddEntity(nocollide)
		undo.SetPlayer(ply)
	undo.Finish()

	ply:AddCleanup("teleporters_adv", teleporter)
	ply:AddCleanup("teleporters_adv", const)
	ply:AddCleanup("teleporters_adv", nocollide)

	return true

end

function TOOL:RightClick(trace)
	return false
end

function TOOL:Reload(trace)
	return false
end

function TOOL:UpdateGhostEntity(ent, ply)
	if !self:GetOwner():IsAdmin() then return end
	if not IsValid(ent) then return end

	local tr = ply:GetEyeTrace()

	if not tr.Hit or IsValid(tr.Entity) and tr.Entity:GetClass() == "gmod_advteleporter" or tr.Entity:IsPlayer() then
		ent:SetNoDraw(true)
		return
	end

	local ang = tr.HitNormal:Angle()
	ang.pitch = ang.pitch + 90

	local min = ent:OBBMins()
	ent:SetPos(tr.HitPos - tr.HitNormal * min.z)
	ent:SetAngles(ang)

	ent:SetNoDraw(false)

end

function TOOL:Think()
	if !self:GetOwner():IsAdmin() then return end
	if not IsValid(self.GhostEntity) or (IsValid(self.GhostEntity) and self.GhostEntity:GetModel() ~= self:GetClientInfo("model")) then
		self:MakeGhostEntity(self:GetClientInfo("model"), Vector(0,0,0), Angle(0,0,0))
	end

	self:UpdateGhostEntity(self.GhostEntity, self:GetOwner())

end

function TOOL.BuildCPanel(CPanel)

	CPanel:AddControl("Header", {Text = "#Tool.teleporter_adv.name", Description = "#Tool.teleporter_adv.desc"})

	local Options = {
		Default = {
			teleporter_adv_model 		= "models/Items/combine_rifle_ammo01.mdl",
			teleporter_adv_sound 		= 0,
			teleporter_adv_ontouch		= 0,
			teleporter_adv_onuse 		= 0,
			teleporter_adv_key 			= 1
		}
	}

	local CVars = {
		"teleporter_adv_model",
		"teleporter_adv_sound",
		"teleporter_adv_effect",
		"teleporter_adv_ontouch",
		"teleporter_adv_onuse",
		"teleporter_adv_showbeam",
		"teleporter_adv_showradius",
		"teleporter_adv_key"
	}

	CPanel:AddControl("ComboBox",
		{
			Label = "#Presets",
			MenuButton = 1,
			Folder = "teleporter_adv",
			Options = Options,
			CVars = CVars
		}
	)

	CPanel:AddControl("PropSelect",
		{
			Label = "Model:",
			ConVar = "teleporter_adv_model",
			Category = "Teleporters",
			Models = list.Get("TeleporterModels")
		}
	)

	CPanel:AddControl("Numpad",
		{
			Label = "Key:",
			Command = "teleporter_adv_key",
			ButtonSize = 22
		}
	)

 	CPanel:AddControl("Slider",
		{
			Label = "Teleport Radius:",
			Command = "teleporter_adv_radius",
			min = 50,
			max = 500
		}
	)

	CPanel:AddControl("Label", {Text = "Teleport Sound:"})

 	CPanel:AddControl("ComboBox",
		{
			Label = "Teleport Sound:",
			MenuButton = 0,
			Command = "teleporter_adv_sound",
			Options = list.Get("TeleporterSounds")
		}
	)

	CPanel:AddControl("Label", {Text = "Teleport Effect:"})

 	CPanel:AddControl("ComboBox",
		{
			Label = "Teleport Effect:",
			MenuButton = 0,
			Command = "teleporter_adv_effect",
			Options = list.Get("TeleporterEffects")
		}
	)

	CPanel:AddControl("CheckBox",
		{
			Label = "Teleport On Touch",
			Command = "teleporter_adv_ontouch"
		}
	)

	CPanel:AddControl("CheckBox",
		{
			Label = "Teleport On Use",
			Command = "teleporter_adv_onuse"
		}
	)

	CPanel:AddControl("CheckBox",
		{
			Label = "Show Beam",
			Command = "teleporter_adv_showbeam"
		}
	)

	CPanel:AddControl("CheckBox",
		{
			Label = "Show Teleport Radius",
			Command = "teleporter_adv_showradius"
		}
	)

end

-- 37062385
