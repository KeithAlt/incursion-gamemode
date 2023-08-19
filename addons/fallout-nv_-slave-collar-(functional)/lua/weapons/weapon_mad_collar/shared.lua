// Variables that are used on both client and server
SWEP.Category			= "Mad Slave Collar"
SWEP.HoldType			= "slam"
SWEP.Base 				= "weapon_mad_base"

if (CLIENT) then
	SWEP.PrintName			= "SLAVE COLLARS"			-- 'Nice' Weapon name (Shown on HUD)
	SWEP.Author				= "Xaxidoro"
	SWEP.Slot				= 5							-- Slot in the weapon selection menu
	SWEP.SlotPos			= 1							-- Position in the slot
	SWEP.IconLetter			= "H"
	killicon.Add( "weapon_mad_collar", "HUD/killicons/default", Color( 255, 80, 0, 255 ) )
	function SWEP:DrawHUD()
	end
end

if SERVER then
	util.AddNetworkString("TagSlave")
	util.AddNetworkString("TagSlaveAll")
	util.AddNetworkString("SetDetonationDistance")
end
SWEP.ViewModelFOV			= 52
SWEP.ViewModelFlip			= false
SWEP.ViewModel				= "models/marvless/weapons/c_slavecollar.mdl"
SWEP.WorldModel				= "models/marvless/weapons/w_slavecollar.mdl"
SWEP.Spawnable				= true
SWEP.UseHands				= true
SWEP.AdminSpawnable			= false
SWEP.Primary.Delay			= 0
SWEP.Primary.Sound			= Sound("")
SWEP.Primary.Recoil			= 0
SWEP.Primary.Damage			= 0
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= -1					// Size of a clip
SWEP.Primary.DefaultClip	= -1					// Default number of bullets in a clip
SWEP.Primary.Automatic		= false					// Automatic/Semi Auto
SWEP.Primary.Ammo			= "none"
SWEP.Secondary.Delay		= 0
SWEP.Secondary.ClipSize		= -1					// Size of a clip
SWEP.Secondary.DefaultClip	= -1					// Default number of bullets in a clip
SWEP.Secondary.Automatic	= false					// Automatic/Semi Auto
SWEP.Secondary.Ammo			= "none"
SWEP.ShellEffect			= "none"
SWEP.ShellDelay				= 0
SWEP.Pistol					= true
SWEP.Rifle					= false
SWEP.Shotgun				= false
SWEP.Sniper					= false
SWEP.ComboActivated			= false
SWEP.QuickHittingTime		= 0
SWEP.IronSightsPos 			= Vector (0.001, -6.7271, 5.4635)
SWEP.IronSightsAng 			= Vector (-55.5761, -2.6453, 0)
SWEP.RunArmOffset 			= Vector (-0.3561, 0, 5.9544)
SWEP.RunArmAngle 			= Vector (-28.873, -1.6004, 0)
SWEP.Enslave				= false

function SWEP:UpdateNextIdle()
	local vm = self.Owner:GetViewModel()
	self:SetNextIdle( CurTime() + vm:SequenceDuration() )
end
/*---------------------------------------------------------
   Name: SWEP:Initialize()
   Desc: Called when the weapon is first loaded.
---------------------------------------------------------*/
function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self.Weapon:SetNetworkedBool("Reloading", false)
	if (SERVER) then
		self:SetWeaponHoldType(self.HoldType)
		self:SetNPCMinBurst(30)
		self:SetNPCMaxBurst(30)
		self:SetNPCFireRate(self.Primary.Delay)
	end
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(false)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self:SetHolsted(true)
	if CLIENT then
		self.Window = nil
	end
end

/*---------------------------------------------------------
   Name: SWEP:Holster()
   Desc: Weapon wants to holster.
	   Return true to allow the weapon to holster.
---------------------------------------------------------*/
function SWEP:Holster()
	--self:OnRemove()
	return true
end
function SWEP:OnDrop()
	self:OnRemove()
end
function SWEP:OnRemove()
	return true
end

/*---------------------------------------------------------
   Name: SWEP:Reload()
   Desc: Reloading
---------------------------------------------------------*/
function SWEP:Reload()
end

function SWEP:ReloadMenu()
	if not CLIENT then return end
	if self.Window then return end
	for k, v in pairs(self.Owner.Slaves) do
		if IsValid( v ) then
			if v:GetNWEntity( "slavecollar" ) == nil or v:GetNWEntity( "slavecollar" ) == NULL then
				table.RemoveByValue( self.Owner.Slaves, v )
				return
			end
		end
	end
	self.Window = vgui.Create("DFrame")
	self.Window:Center()
	self.Window:SetSize(608, 410)
	self.Window:SetTitle(" ")
	self.Window:ShowCloseButton(false)
	local alph = 0
	self.Window:MakePopup()
	//self.Window:SetDraggable(false)
	self.Window.Paint = function()
		if self.Window and IsValid(self.Window) then
			if alph < 200 then alph = alph + 3 end
			local w = self.Window:GetWide()
			local t = self.Window:GetTall()
			draw.RoundedBox(0, 0, 0, w, t, Color(0, 0, 0, alph))
		end
	end
	local btn = vgui.Create("DButton", self.Window)
	btn:SetPos(580, 10)
	btn:SetSize(20, 20)
	btn:SetText("X")
	btn:SetFont("default")
	btn:SetColor(Color(255, 255, 255))
	btn.DoClick = function()
		if self.Window and IsValid(self.Window) then
			self.Window:Close()
			self.Window = nil
		else
			print("ERROR: Window invalid")
		end
	end
	btn.Paint = function()
		local w = btn:GetWide()
		local t = btn:GetTall()
		draw.RoundedBox(0, 0, 0, w, t, Color(255, 0, 0, alph * 0.7))
	end
	local NameEntry = vgui.Create( "DTextEntry", self.Window )
	NameEntry:SetPos( 5, 5 )
	NameEntry:SetSize( 100, 30 )
	NameEntry:SetText( ( self.Owner.SlaveDetonateDist ) or "Detonation Distance" )
	NameEntry:SetFont( "Fact_Small_Strong" )
	NameEntry:SetDrawBorder(false)
	NameEntry:SetDrawBackground(false)
	NameEntry.OnGetFocus = function(self)
		if self:GetValue() == "Detonation Distance" then
		self:SetText( "" )	end
	end
	NameEntry.OnLoseFocus = function(self)
		if self:GetValue() == "" then
		self:SetText( "Detonation Distance" )	end
	end
	local btn = vgui.Create("DButton", self.Window)
	btn:SetPos(80, 5)
	btn:SetSize(80, 30)
	btn:SetText("Apply")
	btn:SetFont("default")
	btn:SetColor(Color(255, 255, 255))
	btn.DoClick = function()
		if not tonumber( NameEntry:GetText() ) then
			print( "Invalid Number" )
			return
		end
		self.Owner.SlaveDetonateDist = tonumber( NameEntry:GetText() )
		net.Start("SetDetonationDistance")
			net.WriteFloat( tonumber( NameEntry:GetText() ) )
			net.WriteBool( true )
		net.SendToServer()
		if self.Window and IsValid(self.Window) then
			self.Window:Close()
			self.Window = nil
		else
			print("ERROR: Window invalid")
		end
	end
	btn.Paint = function()
		local w = btn:GetWide()
		local t = btn:GetTall()
		draw.RoundedBox(0, 0, 0, w, t, Color(255, 0, 0, alph * 0.7))
	end
	--------------------------------------------------------------------------
	local mg = vgui.Create("DListView", self.Window)
	mg:SetPos(12.5, 35)
	mg:SetSize(275, 330)
	mg:AddColumn("Slaves (KILL)")
	mg.Paint = function()
		local w = mg:GetWide()
		local t = mg:GetTall()
		draw.RoundedBox(0, 0, 0, w, t, Color(255, 255, 255, alph * 0.5))
	end
	local all = vgui.Create("DButton", self.Window)
	all:SetPos(60, 370)
	all:SetSize(200, 30)
	all:SetText("KILL ALL")
	all:SetFont("default")
	all:SetColor(Color(255, 255, 255))
	all.DoClick = function()
		net.Start("TagSlaveAll")
			net.WriteEntity(self)
			net.WriteBool( true )
		net.SendToServer()
		table.Empty( self.Owner.Slaves )
		self.Window:Close()
		self.Window = nil
	end
	all.Paint = function()
		local w = all:GetWide()
		local t = all:GetTall()
		draw.RoundedBox(0, 0, 0, w, t, Color(255, 0, 0, alph * 0.7))
	end
	for k, v in pairs(self.Owner.Slaves) do
		if IsValid( v ) then
			mg:AddLine(v:GetName(), "")
		end
	end
	mg.OnClickLine = function(parent, line, isselected)
		if not self.Weapon or not self then return end
		net.Start("TagSlave")
			net.WriteEntity(self)
			net.WriteString(line:GetValue(1))
			net.WriteBool( true )
		net.SendToServer()
		self.Window:Close()
		self.Window = nil
		timer.Simple(1, function()
			for k, v in pairs(self.Owner.Slaves) do
				if IsValid( v ) then
					if v:GetNWEntity( "slavecollar" ) == nil or v:GetNWEntity( "slavecollar" ) == NULL then
						table.RemoveByValue( self.Owner.Slaves, v )
						return
					end
				end
			end
		end)
	end
	--------------------------------------------------------------------------
	local mg = vgui.Create("DListView", self.Window)
	mg:SetPos(320, 35)
	mg:SetSize(275, 330)
	mg:AddColumn("Slaves (FREE)")
	mg.Paint = function()
		local w = mg:GetWide()
		local t = mg:GetTall()
		draw.RoundedBox(0, 0, 0, w, t, Color(255, 255, 255, alph * 0.5))
	end
	local all = vgui.Create("DButton", self.Window)
	all:SetPos(350, 370)
	all:SetSize(200, 30)
	all:SetText("FREE ALL")
	all:SetFont("default")
	all:SetColor(Color(255, 255, 255))
	all.DoClick = function()
		net.Start("TagSlaveAll")
			net.WriteEntity(self)
			net.WriteBool( false )
		net.SendToServer()
		table.Empty( self.Owner.Slaves )
		self.Window:Close()
		self.Window = nil
	end
	all.Paint = function()
		local w = all:GetWide()
		local t = all:GetTall()
		draw.RoundedBox(0, 0, 0, w, t, Color(255, 0, 0, alph * 0.7))
	end
	for k, v in pairs(self.Owner.Slaves) do
		if IsValid( v ) then
			mg:AddLine(v:GetName(), "")
		end
	end
	mg.OnClickLine = function(parent, line, isselected)
		if not self.Weapon or not self then return end
		net.Start("TagSlave")
			net.WriteEntity(self)
			net.WriteString(line:GetValue(1))
			net.WriteBool( false )
		net.SendToServer()
		self.Window:Close()
		self.Window = nil
		timer.Simple(1, function()
			for k, v in pairs(self.Owner.Slaves) do
				if IsValid( v ) then
					if v:GetNWEntity( "slavecollar" ) == nil or v:GetNWEntity( "slavecollar" ) == NULL then
						table.RemoveByValue( self.Owner.Slaves, v )
						return
					end
				end
			end
		end)
	end
	--------------------------------------------------------------------------
end

/*---------------------------------------------------------
   Name: SWEP:Deploy()
   Desc: Whip it out.
---------------------------------------------------------*/
function SWEP:Deploy()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.DeployDelay)
	self.Weapon:SetNextSecondaryFire(CurTime() + self.DeployDelay)
	self.ActionDelay = (CurTime() + self.DeployDelay)
	if CLIENT then
		self.Window = nil
	end
	return true
end

/*---------------------------------------------------------
   Name: SWEP:Think()
   Desc: Called every frame.
---------------------------------------------------------*/
function SWEP:Think()
	if not self.Owner.SlaveDetonateDist then
		self.Owner.SlaveDetonateDist = 400
	end
	if not self.Owner.Slaves then
		self.Owner.Slaves = {}
	end
	if self.Owner:GetVelocity():Length() > 350 or self.Weapon:GetDTBool(0) then
		self:SetWeaponHoldType( 'normal' )
		self:SetHoldType( 'normal' )
	else
		self:SetWeaponHoldType(self.HoldType)
		self:SetHoldType(self.HoldType)
	end
	if self.Enslave then
		local ent = self:GetNWEntity( "EnslaveTarg" )
		if ent then
			local trace = util.QuickTrace( self.Owner:EyePos(), self.Owner:GetAimVector() * 80, self.Owner )
			if trace.Entity ~= ent then
				self:SetNWEntity( "EnslaveTarg", nil )
				self.Enslave = false
			end
		end
		if self:GetNWFloat( "EnslaveTime" ) < CurTime() then
			self.Owner:SetAnimation( PLAYER_ATTACK1 )
			local vm = self.Owner:GetViewModel()
			self.Weapon:SendWeaponAnim(ACT_SLAM_THROW_THROW)
			timer.Simple( vm:SequenceDuration(), function()
				if not self then return end
				self.Weapon:SendWeaponAnim(ACT_SLAM_THROW_THROW2)
				timer.Simple( vm:SequenceDuration(), function()
					if not self then return end
					self.Weapon:SendWeaponAnim(ACT_SLAM_THROW_IDLE)
				end)
			end)
			self.Enslave = false
			SetSlave(self.Owner, ent)
		end
	end
	self:SecondThink()
	self:NextThink(CurTime())
end

SetSlave = function( ply, ent )
	table.insert( ply.Slaves, ent )
	--self.Enslave = false
	if SERVER then
		local collar = ents.Create("ent_mad_collar")
		if ent:LookupBone( "ValveBiped.Bip01_Neck1" ) then
			collar:SetPos( ent:GetBonePosition( ent:LookupBone( "ValveBiped.Bip01_Neck1" ) ) )
			collar:SetParent( ent, ent:LookupBone( "ValveBiped.Bip01_Neck1" ) )
		else
			collar:SetPos( ent:GetPos() + Vector( 0, 0, 50 ) )
			collar:SetParent( ent )
		end
		collar.Attach = ent
		collar:SetOwner( ply )
		collar:Spawn()
		collar:Activate()
		ent.slavecollar = collar
		ent:SetNWEntity( "slavecollar", collar )
	end
end

/*---------------------------------------------------------
   Name: SWEP:SecondThink()
   Desc: Called every frame.
---------------------------------------------------------*/
function SWEP:SecondThink()
	if self.Owner:KeyPressed( IN_RELOAD ) then
		self:ReloadMenu()
	end
	if SERVER then
		net.Receive("SetDetonationDistance", function()
			local dist = net.ReadFloat()
			self.Owner.SlaveDetonateDist = dist
		end)
		net.Receive("TagSlave", function()
			local wep = net.ReadEntity()
			local name = net.ReadString()
			local kill = net.ReadBool()
			self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_DETONATE)
			timer.Simple( self.Owner:GetViewModel():SequenceDuration(), function()
				if not self then return end
				self.Weapon:SendWeaponAnim(ACT_SLAM_THROW_IDLE)
			end)
			self.Owner:SetAnimation( PLAYER_ATTACK1 )
			if not self.Owner.Slaves then return end
			for k, v in pairs(self.Owner.Slaves) do
				if IsValid( v ) and v:GetName() == name then
					if IsValid( v.slavecollar ) then
						if kill then
							v.slavecollar:Explode() --v:TakeDamage( 99999999, self.Owner, v.slavecollar )
						else
							v.slavecollar:Remove()
						end
					end
					table.RemoveByValue( self.Owner.Slaves, v )
					return
				end
			end
		end)
		net.Receive("TagSlaveAll", function()
			local wep = net.ReadEntity()
			local kill = net.ReadBool()
			if not self.Owner.Slaves then return end
			self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_DETONATE)
			timer.Simple( self.Owner:GetViewModel():SequenceDuration(), function()
				if not self then return end
				self.Weapon:SendWeaponAnim(ACT_SLAM_THROW_IDLE)
			end)
			self.Owner:SetAnimation( PLAYER_ATTACK1 )
			for k, v in pairs(self.Owner.Slaves) do
				if IsValid( v ) then
					if IsValid( v.slavecollar ) then
						if kill then
							v.slavecollar:Explode() --v:TakeDamage( 99999999, self.Owner, v.slavecollar )
						else
							v.slavecollar:Remove()
						end
					end
					table.RemoveByValue( self.Owner.Slaves, v )
				end
			end
		end)
	end
end

/*---------------------------------------------------------
   Name: SWEP:PrimaryAttack()
   Desc: +attack1 has been pressed.
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	// Holst/Deploy your fucking weapon
	if (not self.Owner:IsNPC() and self.Owner:KeyDown(IN_USE)) then
		bHolsted = !self.Weapon:GetDTBool(0)
		self:SetHolsted(bHolsted)
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.3)
		self.Weapon:SetNextSecondaryFire(CurTime() + 0.3)
		self:SetIronsights(false)
		return
	end
	if (not self:CanPrimaryAttack()) then return end
	if self.Enslave then return end
	local trace = util.QuickTrace( self.Owner:EyePos(), self.Owner:GetAimVector() * 80, self.Owner )
	if not trace.Entity then return end
	if trace.Entity.slavecollar then return end
	if trace.Entity:GetNWEntity( "slavecollar" ) ~= nil and trace.Entity:GetNWEntity( "slavecollar" ) ~= NULL then return end
	if trace.Entity:IsPlayer() then
		self:SetNWEntity( "EnslaveTarg", trace.Entity )
		self:SetNWFloat( "EnslaveTime", CurTime() + 7 )
		self.Enslave = true
	end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
end

/*---------------------------------------------------------
   Name: SWEP:SecondaryAttack()
   Desc: +attack2 has been pressed.
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	if (not self.Owner:IsNPC() and self.Owner:KeyDown(IN_USE)) then
		return
	end
	if (not self:CanSecondaryAttack()) then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay * 2)
end

/*---------------------------------------------------------
   Name: SWEP:CanPrimaryAttack()
   Desc: Helper function for checking for no ammo.
---------------------------------------------------------*/
function SWEP:CanPrimaryAttack()
	if (not self.Owner:IsNPC()) and (self.Weapon:GetDTBool(0)) then
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
		return false
	end
	return true
end

/*---------------------------------------------------------
   Name: SWEP:CanPrimaryAttack()
   Desc: Helper function for checking for no ammo.
---------------------------------------------------------*/
function SWEP:CanSecondaryAttack()
	if (not self.Owner:IsNPC()) and (self.Weapon:GetDTBool(0)) then
		self.Weapon:SetNextSecondaryFire(CurTime() + 0.5)
		return false
	end
	return true
end

if CLIENT then
	function SWEP:DrawHUD()
		if self:GetNWEntity( "EnslaveTarg" ) == NULL then return end
		if self:GetNWEntity( "EnslaveTarg" ) == nil then return end
		local timeLeft = ( self:GetNWFloat( "EnslaveTime" ) - CurTime() ) * 100 / 3
		if timeLeft <= 0 then return end
        x = ScrW()
        y = ScrH()
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawOutlinedRect(x * 0.5 - 100, y * 0.5 + 206, 200, 18)
		surface.SetDrawColor(0, 0, 0, 200)
		surface.DrawRect(x * 0.5 - 99, y * 0.5 + 207, 198, 16)
		surface.SetDrawColor(255, 0, 0, 255)
		surface.DrawRect(x * 0.5 - 99, y * 0.5 + 207, timeLeft * 1.98, 16)
	end
end
