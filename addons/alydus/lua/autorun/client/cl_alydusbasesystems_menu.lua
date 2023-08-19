--[[ 
	© Alydus.net
	Do not reupload lua to workshop without permission of the author
	Alydus Base Systems
	Alydus: (officialalydus@gmail.com | STEAM_0:1:57622640)
--]]
local function alydusBaseSystemsPanel(panel)
	commandPrefix = "sv_alydusbasesystems_"	
	panel:AddControl("Label", {Text = "Alydus Base Systems"})	
	panel:AddControl("Label", {Text = "Serverside Configuration"})	
	panel:AddControl("Label", {Text = "Addon by Alydus"})
	panel:AddControl("Label", {Text = "- BASE CONTROLLERS CONFIGURATION"})
	panel:AddControl("CheckBox", {Label = "Enable repairing sound", Command = commandPrefix .. "enable_basecontroller_repairsound"})
	panel:AddControl("CheckBox", {Label = "Enable destruction explosion", Command = commandPrefix .. "enable_basecontroller_destructionexplosion"})
	panel:AddControl("CheckBox", {Label = "Enable destruction ignition", Command = commandPrefix .. "enable_basecontroller_destructionignition"})
	panel:AddControl("Slider", {Label = "Destruction Ignition Length/Time", Command = commandPrefix .. "enable_basecontroller_destructionignitionlength", Min = "0", Max = "360"})
	panel:AddControl("Slider", {Label = "Destruction Ignition Radius", Command = commandPrefix .. "enable_basecontroller_destructionignitionradius", Type = "Float", Min = "0", Max = "500"})
	panel:AddControl("CheckBox", {Label = "Enable extra explosion sound", Command = commandPrefix .. "enable_basecontroller_destructionexplosionextra"})
	panel:AddControl("CheckBox", {Label = "Enable destruction screen shake", Command = commandPrefix .. "enable_basecontroller_destructionscreenshake"})
	panel:AddControl("Label", {Text = "- MODULES CONFIGURATION"})
	panel:AddControl("CheckBox", {Label = "Enable destruction explosion", Command = commandPrefix .. "enable_module_destructionexplosion"})
	panel:AddControl("CheckBox", {Label = "Enable destruction ignition", Command = commandPrefix .. "enable_module_destructionignition"})
	panel:AddControl("Slider", {Label = "Destruction Ignition Length/Time", Command = commandPrefix .. "enable_module_destructionignitionlength", Min = "0", Max = "360"})
	panel:AddControl("Slider", {Label = "Destruction Ignition Radius", Command = commandPrefix .. "enable_module_destructionignitionradius", Type = "Float", Min = "0", Max = "1000"})
	panel:AddControl("CheckBox", {Label = "Enable extra explosion sound", Command = commandPrefix .. "enable_module_destructionexplosionextra"})
	panel:AddControl("CheckBox", {Label = "Enable destruction screen shake", Command = commandPrefix .. "enable_module_destructionscreenshake"})
	panel:AddControl("Label", {Text = "- MODULES GENERAL CONFIGURATION"})
	panel:AddControl("Slider", {Label = "Maximum Claim Radius from Base Controller", Command = commandPrefix .. "enable_module_maximumclaimradius", Min = "0", Max = "10000"})
	panel:AddControl("Slider", {Label = "Default Health", Command = commandPrefix .. "config_module_defaulthealth", Min = "1", Max = "10000"})
	panel:AddControl("CheckBox", {Label = "Set CPPI/FPP/SPP Prop Owner when claimed", Command = commandPrefix .. "enable_module_claimcppiset"})
	panel:AddControl("Label", {Text = "- PROXIMITY TRIGGER"})
	panel:AddControl("Slider", {Label = "Entity detection radius", Command = commandPrefix .. "config_proximitytrigger_range", Min = "0", Max = "5000"})
	panel:AddControl("Label", {Text = "- SAM TURRETS"})
	panel:AddControl("CheckBox", {Label = "Prioitise nearby targets", Command = commandPrefix .. "config_samturret_prioritisenearbytargets"})
	panel:AddControl("Slider", {Label = "Target detection radius", Command = commandPrefix .. "config_samturret_range", Min = "0", Type = "Float", Max = "10000"})
	panel:AddControl("Slider", {Label = "Missile Damage", Command = commandPrefix .. "config_samturret_damage", Type = "Float", Min = "0", Max = "100000"})
	panel:AddControl("Label", {Text = "- GUN TURRETS"})
	panel:AddControl("CheckBox", {Label = "Prioitise nearby targets", Command = commandPrefix .. "config_gunturret_prioritisenearbytargets"})
	panel:AddControl("Slider", {Label = "Target detection radius", Command = commandPrefix .. "config_gunturret_range", Min = "0", Type = "Float", Max = "10000"})
	panel:AddControl("Slider", {Label = "Bullet Damage", Command = commandPrefix .. "config_gunturret_bulletdamage", Type = "Float", Min = "0", Max = "100000"})
	panel:AddControl("Slider", {Label = "Bullet Physics Force", Command = commandPrefix .. "config_gunturret_bulletforce", Type = "Float", Min = "0", Max = "100000"})
	panel:AddControl("CheckBox", {Label = "Target owner's team", Command = commandPrefix .. "config_gunturret_turretstargetownerteam"})
	panel:AddControl("Label", {Text = "- LASER TURRETS"})
	panel:AddControl("CheckBox", {Label = "Prioitise nearby targets", Command = commandPrefix .. "config_laserturret_prioritisenearbytargets"})
	panel:AddControl("Slider", {Label = "Target detection radius", Command = commandPrefix .. "config_laserturret_range", Min = "0", Type = "Float", Max = "10000"})
	panel:AddControl("Slider", {Label = "Bullet Damage", Command = commandPrefix .. "config_laserturret_bulletdamage", Type = "Float", Min = "0", Max = "100000"})
	panel:AddControl("Slider", {Label = "Bullet Physics Force", Command = commandPrefix .. "config_laserturret_bulletforce", Type = "Float", Min = "0", Max = "100000"})
	panel:AddControl("Label", {Text = "- ALARMS"})
	panel:AddControl("Slider", {Label = "Sound Level", Command = commandPrefix .. "config_alarm_soundlevel", Min = "20", Max = "180"})
	panel:AddControl("Label", {Text = "- CAMERAS"})
	panel:AddControl("CheckBox", {Label = "Identify entities HUD", Command = commandPrefix .. "config_camera_identifyentities"})
	panel:AddControl("Label", {Text = "- CONSUMABLES"})
	panel:AddControl("Slider", {Label = "Gun Turret Ammo - Bullet Count", Command = commandPrefix .. "config_gunturretammo_amount", Min = "1", Max = "10000"})
	panel:AddControl("Slider", {Label = "Laser Turret Ammo - Bullet Count", Command = commandPrefix .. "config_laserturretammo_amount", Min = "1", Max = "10000"})
	panel:AddControl("Slider", {Label = "SAM Turret Ammo - Missile Count", Command = commandPrefix .. "config_samturretammo_amount", Min = "1", Max = "10000"})
end
hook.Add("PopulateToolMenu", "alydusBaseSystems.PopulateToolMenu.CreateOptionsInSpawnMenu", function()
	spawnmenu.AddToolMenuOption("Options", "Alydus Base Systems", "Configuration", "Serverside Configuration", "", "", alydusBaseSystemsPanel)
end)