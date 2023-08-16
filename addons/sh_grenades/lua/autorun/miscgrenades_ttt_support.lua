-- Allows the grenades to be used in TTT.

if (SERVER) then
	AddCSLuaFile()
end

hook.Add("Initialize", "MISCGRENADES_TTTSUPPORT", function()
	if not (engine.ActiveGamemode() == "terrortown") then
		return end

	AMMO_HEALGRENADE = 220
	AMMO_ELECTRICGRENADE = 221
	AMMO_PERCUSSIONGRENADE = 222
	AMMO_SMOKEGRENADE = 223

	local function AddSupport()
		// Heal Grenade
		local ENT = scripted_ents.GetStored("proj_sh_healgrenade").t

		DEFINE_BASECLASS("ttt_basegrenade_proj")
		ENT.Base = "ttt_basegrenade_proj"

		if (SERVER) then
			AccessorFunc(ENT, "thrower", "Thrower")

			function ENT:Initialize() BaseClass.Initialize(self) self:SetSubMaterial(0, "models/weapons/v_models/eq_healgrenade/healgrenade") self:SetElasticity(2) end
			function ENT:Think() BaseClass.Think(self) return self:DamageThink() end
			function ENT:SetupDataTables() self:NetworkVar("Float", 0, "ExplodeTime") end
			function ENT:SetDetonateTimer(length) self:SetDetonateExact(CurTime() + length) end
			function ENT:SetDetonateExact(t) self:SetExplodeTime(t or CurTime()) end
			ENT.Explode = ENT.DoExplode
		end

		local SWEP = weapons.GetStored("weapon_sh_healgrenade")

		DEFINE_BASECLASS("weapon_tttbasegrenade")
		SWEP.Base = "weapon_tttbasegrenade"
		SWEP.HoldType = "grenade"

		SWEP.Icon = "vgui/ttt/icon_nades"
		SWEP.IconLetter = "P"

		SWEP.WeaponID = AMMO_HEALGRENADE
		SWEP.Kind = WEAPON_NADE
		SWEP.ViewModelFlip = false

		SWEP.AutoSpawnable = true
		SWEP.IsGrenade = true
		SWEP.NoSights = true
		SWEP.HoldReady = "grenade"
		SWEP.HoldNormal = "slam"
		SWEP.detonate_timer = SWEP.CookTime

		AccessorFunc(SWEP, "det_time", "DetTime")

		-- Let the SWEP base or whatever handle it..!
		function SWEP:Initialize() self:SetupVars() BaseClass.Initialize(self) end
		function SWEP:SetupDataTables() BaseClass.SetupDataTables(self) end
		function SWEP:Holster(we) return BaseClass.Holster(self, we) end
		function SWEP:OwnerChanged() BaseClass.OwnerChanged(self) end
		function SWEP:OnRemove() BaseClass.OnRemove(self) end
		function SWEP:Deploy() return BaseClass.Deploy(self) end
		function SWEP:OnDrop() BaseClass.OnDrop(self) end
		function SWEP:Think() BaseClass.Think(self) end
		function SWEP:PrimaryAttack() BaseClass.PrimaryAttack(self) end
		function SWEP:SecondaryAttack() BaseClass.SecondaryAttack(self) end
		function SWEP:GetGrenadeName() return self.ThrownProjectile end
		function SWEP:PreDrop() BaseClass.PreDrop(self) end

		local allow = {}
		if (HEALGRENADE_SETTINGS.TTT.TraitorsGet) then table.insert(allow, ROLE_TRAITOR) end
		if (HEALGRENADE_SETTINGS.TTT.DetectivesGet) then table.insert(allow, ROLE_DETECTIVE) end

		if (#allow > 0) then
			SWEP.EquipMenuData = {
				type = "item_weapon",
				desc = [[A grenade which heals anyone standing in its
gas cloud.]],
			}

			SWEP.AutoSpawnable = false
			SWEP.Kind = WEAPON_EQUIP
			SWEP.Slot = 7
			SWEP.CanBuy = allow
			SWEP.LimitedStock = HEALGRENADE_SETTINGS.TTT.LimitedStock
			SWEP.Icon = "vgui/ttt/icon_healgrenade"
		end

		if (CLIENT) then
			SWEP.DrawCrosshair = false
		end

		// Electric Grenade
		local ENT = scripted_ents.GetStored("proj_sh_electricgrenade").t

		DEFINE_BASECLASS("ttt_basegrenade_proj")
		ENT.Base = "ttt_basegrenade_proj"

		if (SERVER) then
			AccessorFunc(ENT, "thrower", "Thrower")

			function ENT:Initialize() BaseClass.Initialize(self) self:SetSubMaterial(0, "models/weapons/v_models/eq_electricgrenade/electricgrenade") self:SetElasticity(2) end
			function ENT:Think() BaseClass.Think(self) return self:DamageThink() end
			function ENT:SetupDataTables() self:NetworkVar("Float", 0, "ExplodeTime") end
			function ENT:SetDetonateTimer(length) self:SetDetonateExact(CurTime() + length) end
			function ENT:SetDetonateExact(t) self:SetExplodeTime(t or CurTime()) end
			ENT.Explode = ENT.DoExplode
		end

		local SWEP = weapons.GetStored("weapon_sh_electricgrenade")

		DEFINE_BASECLASS("weapon_tttbasegrenade")
		SWEP.Base = "weapon_tttbasegrenade"
		SWEP.HoldType = "grenade"

		SWEP.Icon = "vgui/ttt/icon_nades"
		SWEP.IconLetter = "P"

		SWEP.WeaponID = AMMO_ELECTRICGRENADE
		SWEP.Kind = WEAPON_NADE
		SWEP.ViewModelFlip = false

		SWEP.AutoSpawnable = true
		SWEP.IsGrenade = true
		SWEP.NoSights = true
		SWEP.HoldReady = "grenade"
		SWEP.HoldNormal = "slam"
		SWEP.detonate_timer = SWEP.CookTime

		AccessorFunc(SWEP, "det_time", "DetTime")

		-- Let the SWEP base or whatever handle it..!
		function SWEP:Initialize() self:SetupVars() BaseClass.Initialize(self) end
		function SWEP:SetupDataTables() BaseClass.SetupDataTables(self) end
		function SWEP:Holster(we) return BaseClass.Holster(self, we) end
		function SWEP:OwnerChanged() BaseClass.OwnerChanged(self) end
		function SWEP:OnRemove() BaseClass.OnRemove(self) end
		function SWEP:Deploy() return BaseClass.Deploy(self) end
		function SWEP:OnDrop() BaseClass.OnDrop(self) end
		function SWEP:Think() BaseClass.Think(self) end
		function SWEP:PrimaryAttack() BaseClass.PrimaryAttack(self) end
		function SWEP:SecondaryAttack() BaseClass.SecondaryAttack(self) end
		function SWEP:GetGrenadeName() return self.ThrownProjectile end
		function SWEP:PreDrop() BaseClass.PreDrop(self) end

		local allow = {}
		if (ELECTRICGRENADE_SETTINGS.TTT.TraitorsGet) then table.insert(allow, ROLE_TRAITOR) end
		if (ELECTRICGRENADE_SETTINGS.TTT.DetectivesGet) then table.insert(allow, ROLE_DETECTIVE) end

		if (#allow > 0) then
			SWEP.EquipMenuData = {
				type = "item_weapon",
				desc = [[A grenade which damages and briefly stuns
anyone in its range.]],
			}

			SWEP.AutoSpawnable = false
			SWEP.Kind = WEAPON_EQUIP
			SWEP.Slot = 7
			SWEP.CanBuy = allow
			SWEP.LimitedStock = ELECTRICGRENADE_SETTINGS.TTT.LimitedStock
			SWEP.Icon = "vgui/ttt/icon_electricgrenade"
		end

		if (CLIENT) then
			SWEP.DrawCrosshair = false
		end

		// Percussion Grenade
		local ENT = scripted_ents.GetStored("proj_sh_percussiongrenade").t

		DEFINE_BASECLASS("ttt_basegrenade_proj")
		ENT.Base = "ttt_basegrenade_proj"

		if (SERVER) then
			AccessorFunc(ENT, "thrower", "Thrower")

			function ENT:Initialize() BaseClass.Initialize(self) self:SetSubMaterial(0, "models/weapons/w_models/w_eq_percussiongrenade/w_eq_percussiongrenade") end
			function ENT:PhysicsCollide(data, phys) if (20 < data.Speed and 0.25 < data.DeltaTime) then self:SetExplodeTime(CurTime()) end end
			function ENT:Think() BaseClass.Think(self) end
			function ENT:SetupDataTables() self:NetworkVar("Float", 0, "ExplodeTime") end
			function ENT:SetDetonateTimer(length) self:SetDetonateExact(CurTime() + length) end
			function ENT:SetDetonateExact(t) self:SetExplodeTime(t or CurTime()) end
			ENT.Explode = ENT.DoExplode
		end

		local SWEP = weapons.GetStored("weapon_sh_percussiongrenade")

		DEFINE_BASECLASS("weapon_tttbasegrenade")
		SWEP.Base = "weapon_tttbasegrenade"
		SWEP.HoldType = "grenade"

		SWEP.Icon = "vgui/ttt/icon_nades"
		SWEP.IconLetter = "P"

		SWEP.WeaponID = AMMO_PERCUSSIONGRENADE
		SWEP.Kind = WEAPON_NADE
		SWEP.ViewModelFlip = false

		SWEP.AutoSpawnable = true
		SWEP.IsGrenade = true
		SWEP.NoSights = true
		SWEP.HoldReady = "grenade"
		SWEP.HoldNormal = "slam"
		SWEP.detonate_timer = SWEP.CookTime

		AccessorFunc(SWEP, "det_time", "DetTime")

		-- Let the SWEP base or whatever handle it..!
		function SWEP:Initialize() self:SetupVars() BaseClass.Initialize(self) end
		function SWEP:SetupDataTables() BaseClass.SetupDataTables(self) end
		function SWEP:Holster(we) return BaseClass.Holster(self, we) end
		function SWEP:OwnerChanged() BaseClass.OwnerChanged(self) end
		function SWEP:OnRemove() BaseClass.OnRemove(self) end
		function SWEP:Deploy() return BaseClass.Deploy(self) end
		function SWEP:OnDrop() BaseClass.OnDrop(self) end
		function SWEP:Think() BaseClass.Think(self) end
		function SWEP:PrimaryAttack() BaseClass.PrimaryAttack(self) end
		function SWEP:SecondaryAttack() BaseClass.SecondaryAttack(self) end
		function SWEP:GetGrenadeName() return self.ThrownProjectile end
		function SWEP:PreDrop() BaseClass.PreDrop(self) end

		local allow = {}
		if (PERCUSSIONGRENADE_SETTINGS.TTT.TraitorsGet) then table.insert(allow, ROLE_TRAITOR) end
		if (PERCUSSIONGRENADE_SETTINGS.TTT.DetectivesGet) then table.insert(allow, ROLE_DETECTIVE) end

		if (#allow > 0) then
			SWEP.EquipMenuData = {
				type = "item_weapon",
				desc = [[A grenade which explodes on impact.]],
			}

			SWEP.AutoSpawnable = false
			SWEP.Kind = WEAPON_EQUIP
			SWEP.Slot = 7
			SWEP.CanBuy = allow
			SWEP.LimitedStock = PERCUSSIONGRENADE_SETTINGS.TTT.LimitedStock
			SWEP.Icon = "vgui/ttt/icon_percussiongrenade"
		end

		if (CLIENT) then
			SWEP.DrawCrosshair = false
		end

		// Smoke Grenade
		local ENT = scripted_ents.GetStored("proj_sh_smokegrenade").t

		DEFINE_BASECLASS("ttt_basegrenade_proj")
		ENT.Base = "ttt_basegrenade_proj"

		if (SERVER) then
			AccessorFunc(ENT, "thrower", "Thrower")

			function ENT:Initialize() BaseClass.Initialize(self) self:SetElasticity(2) end
			function ENT:Think() BaseClass.Think(self) end
			function ENT:SetupDataTables() self:NetworkVar("Float", 0, "ExplodeTime") end
			function ENT:SetDetonateTimer(length) self:SetDetonateExact(CurTime() + length) end
			function ENT:SetDetonateExact(t) self:SetExplodeTime(t or CurTime()) end
			ENT.Explode = ENT.DoExplode
		end

		local SWEP = weapons.GetStored("weapon_sh_smokegrenade")

		DEFINE_BASECLASS("weapon_tttbasegrenade")
		SWEP.Base = "weapon_tttbasegrenade"
		SWEP.HoldType = "grenade"

		SWEP.Icon = "vgui/ttt/icon_nades"
		SWEP.IconLetter = "P"

		SWEP.WeaponID = AMMO_SMOKEGRENADE
		SWEP.Kind = WEAPON_NADE
		SWEP.ViewModelFlip = false

		SWEP.AutoSpawnable = true
		SWEP.IsGrenade = true
		SWEP.NoSights = true
		SWEP.HoldReady = "grenade"
		SWEP.HoldNormal = "slam"
		SWEP.detonate_timer = SWEP.CookTime

		AccessorFunc(SWEP, "det_time", "DetTime")

		-- Let the SWEP base or whatever handle it..!
		function SWEP:Initialize() self:SetupVars() BaseClass.Initialize(self) end
		function SWEP:SetupDataTables() BaseClass.SetupDataTables(self) end
		function SWEP:Holster(we) return BaseClass.Holster(self, we) end
		function SWEP:OwnerChanged() BaseClass.OwnerChanged(self) end
		function SWEP:OnRemove() BaseClass.OnRemove(self) end
		function SWEP:Deploy() return BaseClass.Deploy(self) end
		function SWEP:OnDrop() BaseClass.OnDrop(self) end
		function SWEP:Think() BaseClass.Think(self) end
		function SWEP:PrimaryAttack() BaseClass.PrimaryAttack(self) end
		function SWEP:SecondaryAttack() BaseClass.SecondaryAttack(self) end
		function SWEP:GetGrenadeName() return self.ThrownProjectile end
		function SWEP:PreDrop() BaseClass.PreDrop(self) end

		local allow = {}
		if (SMOKEGRENADE_SETTINGS.TTT.TraitorsGet) then table.insert(allow, ROLE_TRAITOR) end
		if (SMOKEGRENADE_SETTINGS.TTT.DetectivesGet) then table.insert(allow, ROLE_DETECTIVE) end

		if (#allow > 0) then
			SWEP.EquipMenuData = {
				type = "item_weapon",
				desc = [[A grenade which emits a smoke cloud,
blocking line of sight.]],
			}

			SWEP.AutoSpawnable = false
			SWEP.Kind = WEAPON_EQUIP
			SWEP.Slot = 7
			SWEP.CanBuy = allow
			SWEP.LimitedStock = SMOKEGRENADE_SETTINGS.TTT.LimitedStock
			SWEP.Icon = "vgui/ttt/icon_smokegrenade"
		end

		if (CLIENT) then
			SWEP.DrawCrosshair = false
		end
	end

	AddSupport()
end)