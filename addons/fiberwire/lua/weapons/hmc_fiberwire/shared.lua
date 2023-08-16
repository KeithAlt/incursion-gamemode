SWEP.AdminSpawnable = true
SWEP.ViewModelFOV = 75
SWEP.ViewModel = "models/hmc/weapons/v_fibrewire.mdl"
SWEP.WorldModel = "models/hmc/weapons/w_fibrewire.mdl"
SWEP.AutoSwitchTo = true
SWEP.Slot = 0
SWEP.HoldType = "normal"
SWEP.PrintName = "Fiber Wire"
SWEP.Spawnable = true
SWEP.UseHands = true
SWEP.AutoSwitchfrom = true
SWEP.FiresUnderwater = true
SWEP.Weight = 5
SWEP.DrawCrosshair = false
SWEP.Category = "HMC"
SWEP.SlotPos = 0
SWEP.DrawAmmo = true
SWEP.Base = "hmc_base"
if ( CLIENT ) then
SWEP.WepSelectIcon		= surface.GetTextureID( "vgui/hmc_fiberwire_h" , Color( 255, 80, 0, 255 ) )

	killicon.Add( "hmc_fiberwire", "vgui/hmc_fiberwire_k", Color( 255, 80, 0, 255 ) )
end
SWEP.Primary.Sound = ("hmc/weapons/w_ak47_shot_01.wav")
SWEP.Primary.Damage = 0
SWEP.Primary.TakeAmmo = 0
SWEP.Primary.ClipSize = -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Spread = 0
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Recoil = 0.1
SWEP.Primary.Delay = 0.5
SWEP.Primary.Force = 9
SWEP.VecticalRecoil = 0
SWEP.HorisontalRecoil = 0
SWEP.IsRandomHorizontalRecoil = true
SWEP.ReloadDelay = 2.5
SWEP.MuzzleName				= "HMC_MuzzRifle"
SWEP.Penetration = true
SWEP.NearWallAng = Vector(35, -15, 0)
SWEP.NearWallPos = Vector(0, 0, -5)
SWEP.WeaponType = 1
SWEP.GunType	= 0
SWEP.MeleeDelay = 0.3
SWEP.NextMeleeAttack = 1.5
SWEP.IsAlwaysRaised = true
SWEP.UsePassiveIdle = false

function SWEP:Initialize()
        self:SetWeaponHoldType( self.HoldType )
end

function SWEP:SetupDataTables()

	self:NetworkVar( "Float", 0, "NextMul" )
	self:NetworkVar( "Float", 1, "NextReload" )
	self:NetworkVar( "Bool", 2, "Holster" )

	self:NetworkVar( "Entity", 0, "Ragdoll" )
	self:NetworkVar( "Float", 2, "RagDrag" )

	self:NetworkVar( "Bool", 3, "ChargeBool" )

	self:SetNextMul( 0 )
	self:SetNextReload( 0 )
	self:SetHolster( false )
	self:SetRagdoll( nil )
	self:SetRagDrag( 0 )

	self:SetChargeBool( false )

end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self.Weapon:SetNextPrimaryFire(CurTime() +0.5)
	self.Weapon:SetNextSecondaryFire(CurTime() +0.5)
	self:SetNextReload( CurTime() + 0.5 )
	self.idledelay = CurTime() +self:SequenceDuration()
	self:SetNextMul(CurTime() + self:SequenceDuration())
	self:SetHolster(false)
	self:SetChargeBool( false )
	self.Charged = false
	self.Aa = true
	self.RagDrag = 0
	self.VzmahDelay = 0

	return true
end

//SWEP:PrimaryFire()\\
local rndb = 1

function SWEP:MuzzleHMC() // Am really sorry.
	if IsFirstTimePredicted() then
		local fx = EffectData()
		fx:SetEntity(self.Weapon)
		fx:SetOrigin(self.Owner:GetShootPos())
		fx:SetNormal(self.Owner:GetAimVector())
		fx:SetAttachment(1)
		util.Effect(self.MuzzleName, fx)
	end
end

function SWEP:NearWall()
	return false
end

SWEP.Charged = false
SWEP.Aa = true

SWEP.RagDrag = 0

SWEP.VzmahDelay = 0

local punchshit = 0
local punchshit2 = 0


function SWEP:Think()

	self:SecondThink()

	for _,ply in pairs(player.GetAll()) do
	ply:SetDSP( 0 )
	end

	if CLIENT then return end

	if self:GetRagDrag() > CurTime() and IsValid(self:GetRagdoll()) and self:GetRagdoll() != nil then

		local shotang = self.Owner:EyeAngles()
		shotang.pitch = Lerp(FrameTime()*10, shotang.pitch, 0)
		self.Owner:SetEyeAngles( shotang )

		self:SetHoldType( "camera" )

		local ang = self.Owner:EyeAngles()

		ang:RotateAroundAxis(ang:Up(), 90)

		local b = self:GetRagdoll():TranslateBoneToPhysBone(self:GetRagdoll().head_bone)

		self:GetRagdoll():GetPhysicsObjectNum(b):SetPos(self.Owner:GetShootPos() + (self.Owner:GetAimVector()*(15+punchshit2)))

		punchshit2 = Lerp(FrameTime()*10, punchshit2, 0)

		self:GetRagdoll():GetPhysicsObjectNum(b):SetAngles(ang)

		self:GetRagdoll():GetPhysicsObjectNum(b):SetVelocity(Vector(0,0,0))

		if self:GetRagDrag()-1 > CurTime() then

			local h2 = self:GetRagdoll():TranslateBoneToPhysBone(self:GetRagdoll().lhand_bone)
			self:GetRagdoll():GetPhysicsObjectNum(h2):SetPos(self.Owner:GetShootPos() + self.Owner:GetAimVector()*30 + Vector(0,0,-5) + self.Owner:EyeAngles():Right()*-5)

		end

		if self:GetRagDrag()-0.7 > CurTime() then

			local h1 = self:GetRagdoll():TranslateBoneToPhysBone(self:GetRagdoll().rhand_bone)
			self:GetRagdoll():GetPhysicsObjectNum(h1):SetPos(self.Owner:GetShootPos() + self.Owner:GetAimVector()*25 + Vector(0,0,-5) + self.Owner:EyeAngles():Right()*5)

			if punchshit < CurTime() then
				local rand = math.random(-3, 3)
				self.Owner:ViewPunch( Angle( 0, 0, rand*0.7 ) )
				--self:GetRagdoll():GetPhysicsObjectNum(b):AddVelocity(self.Owner:GetAimVector()*15)
				punchshit2 = math.random(-4, -2)
				punchshit = CurTime() + 0.3
			end

		end
		--[[local num = self:GetRagdoll():GetPhysicsObjectCount()-1
		--local v = ent:GetVelocity()

		for i=0, num do

			local bone = self:GetRagdoll():GetPhysicsObjectNum(i)

			if IsValid(bone) then
				bone:SetVelocity(Vector(0,0,0))
			end

		end]]--

	end

	if !self.Aa and self.VzmahDelay < CurTime() and !self.Owner:KeyDown(IN_ATTACK) then
		self:Vzmah()
		self.Aa = true
	end

	if self.idledelay and CurTime() > self.idledelay then

		--self.Aa = true

		if self.Owner:KeyDown(IN_ATTACK) then
			if !self.Aa and self:GetNextPrimaryFire() < CurTime() then
				self:SendWeaponAnim(ACT_VM_IDLE_1)
				self:SetHoldType("duel")
				self:SetChargeBool( true )
				self.idledelay = CurTime() + self:SequenceDuration()
			end
		else

			if self.Charged then
				self:SetHoldType("duel")
				self:SendWeaponAnim(ACT_VM_IDLE_SILENCED)
				self:SetChargeBool( true )
			else
				self:SendWeaponAnim(ACT_VM_IDLE)
				self:SetHoldType("normal")
				self:SetChargeBool( false )
			end

			self.idledelay = CurTime() + self:SequenceDuration()

		end

		if self.cantholster and CurTime() > self.cantholster then
			self.cantholster = nil
		end

	end

	--[[if !self:GetHolster() and self.UsePassiveIdle == true then
		if self:GetNextMul() < CurTime() then
			self:SetHoldType("passive")
		elseif self:GetNextMul() >= CurTime() then
			self:SetHoldType(self.HoldType)
		end
	elseif self.UsePassiveIdle == false then
		self:SetHoldType(self.HoldType)
	end]]--


		--self:SetNextReload( CurTime() + self.ReloadDelay )
		--self.Weapon:SetNextPrimaryFire( CurTime() + self.ReloadDelay )
		--self.Weapon:SetNextSecondaryFire( CurTime() + self.ReloadDelay )

	if self.HolsterDelay and self.HolsterDelay - CurTime() <= 0 and SERVER then
		self.Owner:SelectWeapon(self.ChangeTo)
	end

end

function SWEP:IsFromBehind(npc)

	local pos1 = self.Owner:GetShootPos()
	local pos2 = npc:GetShootPos()

	if pos1:Distance(pos2) > 50 then return end

	local forward = self.Owner:GetAimVector()
	local dir = npc:GetForward()
	local dot = dir:Dot( forward ) >= math.cos(math.rad(180/2))--/ entVector:Length()

	return dot

end

function SWEP:IsTargetHuman(npc)
	local head = npc:LookupBone("ValveBiped.Bip01_Head1")
	--local rhand = npc:LookupBone("ValveBiped.Bip01_R_Hand")
	--local lhand = npc:LookupBone("ValveBiped.Bip01_L_Hand")

	if head != nil then return true end

	return false

end

function SWEP:TurnRagdoll(ent)
	ent:EmitSound("weapons/crowbar/crowbar_impact1.wav", 40)
	ent:falloutNotify("[!] You feel as if you're being choked!", "buttons/blip1.wav")

	if ent:IsPlayer() then
		local MStrength = self.Owner:getSpecial("S")
		local EStrength = ent:getSpecial("S")

		ent:Freeze(true)
		self.Owner:Freeze(true)
		ent:SetNotSolid(true)

	timer.Simple(2.1, function()
		ent:SetNoDraw(true)
	end)

	timer.Simple(2.1, function()
		ent:SetPos(ent:GetPos())
		ent:Freeze(false)
		self.Owner:Freeze(false)
		ent:SetNoDraw(false)
		ent:SetNotSolid(false)
		if MStrength > EStrength then
			if (ent:getNetVar("powerArmor") or ent:GetNW2Bool("WearingPA")) && (self.Owner:hasSkerk("knockout") != 2) then
				self.Owner:falloutNotify("[!] The Victims Power Armor stops you!", "ui/notify.mp3")
				self.Owner:ChatPrint("[ ! ]  Heavy Hitter Level 2 is required to choke out Power Armor victims")
				return 
			end
			self.Owner:falloutNotify("[!] You overpowered your victim")
			ent:falloutNotify("[!] You were choked into unconciousness", "ui/notify.mp3")
			
			ent:Knockout(self.Owner)
			
			//ent:ChatPrint("[ META-REMINDER: You have been knocked out. Informing friends or allies of this is considered meta-game and is bannable ]")
			//local ragdoll = jlib.CreateRagdoll(ent)
			//ent.TranqRagdoll = ragdoll
			//ent.WakeTime = 3
			//ent.TranqTime = 2
			//timer.Simple(0.1, function()
			//	net.Start("TranqRagdoll")
			//		net.WriteEntity(ent)
			//		net.WriteEntity(ragdoll)
			//	net.Broadcast()
			//end)
			//timer.Simple(ent.WakeTime + 0.5, function()
			//	if !IsValid(ragdoll) then return end
			//	ragdoll:Remove()
			//end)
			//return ragdoll
		elseif MStrength <= EStrength then
			self.Owner:falloutNotify("[!] The victim overpowered you")
			self.Owner:ChatPrint(">> Uhoh! You the victim has more Strength!")
			ent:ChatPrint(">> You overpowered the attacker with your Strength!")
			ent:falloutNotify("[!] Someone tried to knock you out")
		end

		end)
	end
	--Death notif

	//rag:SetCollisionGroup(COLLISION_GROUP_WEAPON or COLLISION_GROUP_DEBRIS_TRIGGER)

	--self:SetRagdoll(rag)

	//local num = rag:GetPhysicsObjectCount()-1
	//--local v = ent:GetVelocity()
	//for i=0, num do
	//	local bone = rag:GetPhysicsObjectNum(i)
	//	if IsValid(bone) then
	//		local bp, ba = ent:GetBonePosition(rag:TranslatePhysBoneToBone(i))
	//		if bp and ba then
	//			bone:SetPos(bp)
	//			bone:SetAngles(ba)
	//		end
	//		bone:SetVelocity(Vector(0,0,0))
	//	end
	//end

end

function SWEP:Vzmah()

	local tr = self.Owner:GetEyeTrace()
	local ent = tr.Entity

	if ( ent:IsNPC() or ent:IsPlayer() ) and self:IsFromBehind(ent) and self:IsTargetHuman(ent) then
		self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
		self.Charged = false
		self.Aa = true
		self:TurnRagdoll(ent)
		self:SetRagDrag( CurTime() + self:SequenceDuration()+2 )
		self:EmitSound("hmc/weapons/repeat_186.wav")
	else
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_1)
		self:EmitSound("hmc/weapons/Punch_Swing_0"..math.Round(math.random(1, 3))..".wav", 100, 100)
	end

	self.Owner:ViewPunch( Angle( 2, 0, 0 ) )
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Weapon:SetNextPrimaryFire( CurTime() + self:SequenceDuration()-0.3 )
	self.idledelay = CurTime() + self:SequenceDuration()
	self:SetNextMul(CurTime()+self:SequenceDuration())

end

function SWEP:PrimaryAttack()
	if not IsValid(self.Owner) or self.Owner:Health() < 0 or self:GetNextReload() > CurTime() or self:GetNextPrimaryFire() > CurTime() then return end

		if !self.Charged then
			self:SendWeaponAnim(ACT_VM_SWINGHARD)
				self.Owner:ViewPunch( Angle( -0.3, 0, 1 ) )
				timer.Simple(0.6, function()
					if self.Weapon == nil then return end
					if !self.Owner:KeyDown(IN_ATTACK) then return end
						self.Owner:ViewPunch( Angle( -0.3, 0, -1 ) )
					timer.Simple(1, function()
						if self.Weapon == nil then return end
						if !self.Owner:KeyDown(IN_ATTACK) then return end
							self.Owner:ViewPunch( Angle( 1, 0, 0 ) )
					end)
				end)
			self.VzmahDelay = CurTime() + 0.5
			self.Weapon:SetNextPrimaryFire( CurTime() + self:SequenceDuration() )
			self.Charged = true
			self.Aa = false
		else
			if self.Aa then
			--	self:Vzmah()
			end
			self:SendWeaponAnim(ACT_VM_SWINGMISS)
				self.Owner:ViewPunch( Angle( -1, 0, 0 ) )
				timer.Simple(0.7, function()
					if self.Weapon == nil then return end
					if !self.Owner:KeyDown(IN_ATTACK) then return end
						self.Owner:ViewPunch( Angle( 1, 0, 0 ) )
				end)
			self.VzmahDelay = CurTime() + 0.5
			self.Weapon:SetNextPrimaryFire( CurTime() + self:SequenceDuration() )
			self.Aa = false
		end

		self.Owner:SetAnimation(PLAYER_ATTACK1)
		self.idledelay = CurTime() + self:SequenceDuration()
		self:SetNextMul(CurTime()+self:SequenceDuration())

end

function SWEP:SecondaryAttack()

	if self:GetRagDrag() < CurTime() and self.Owner:KeyDown(IN_USE) then self:Drop() return end

end

function SWEP:AdjustMouseSensitivity()

	if self:GetRagDrag() > CurTime() and IsValid(self:GetRagdoll()) and self:GetRagdoll() != nil then
		return 2
	end
	return 1

end

function SWEP:PreDrawViewModel(vm, wep, ply)

	local rag = self:GetRagdoll()

	if self:GetRagDrag() > CurTime() and IsValid(rag) and rag != nil then
	--render.SetScissorRect( 0, 0, 512, 512, true )
		render.SetStencilWriteMask( 0xFF )
		render.SetStencilTestMask( 0xFF )
		render.SetStencilReferenceValue( 0 )
		render.SetStencilCompareFunction( STENCIL_ALWAYS )
		render.SetStencilPassOperation( STENCIL_KEEP )
		render.SetStencilFailOperation( STENCIL_KEEP )
		render.SetStencilZFailOperation( STENCIL_KEEP )
		render.ClearStencil()

		-- Enable stencils
		render.SetStencilEnable( true )
		-- Set the reference value to 1. This is what the compare function tests against
		render.SetStencilReferenceValue( 1 )

		render.SetStencilCompareFunction( STENCIL_GREATER )
		local w, h = ScrW() / 7, ScrH() / 1.5
		local x_start, y_start = ScrW()/2 - w/2, h
		local x_end, y_end = x_start + w, y_start + h
		render.ClearStencilBufferRectangle( x_start, y_start, x_end, y_end, 1 )
	end

end

function SWEP:DrawWorldModel()

	if self:GetChargeBool() then
		self:SetModel("models/hmc/weapons/w_fibrewire2.mdl")
	else
		self:SetModel("models/hmc/weapons/w_fibrewire.mdl")
	end

	self:DrawModel()

end

function SWEP:ViewModelDrawn(vm)

	render.SetStencilEnable( false )

end
