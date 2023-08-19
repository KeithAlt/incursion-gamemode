
if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
	CreateConVar("hmc_infiniteammo", 0)
end

if ( CLIENT ) then

	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 75
	SWEP.ViewModelFlip		= false

	local cvar_fixchrome = CreateClientConVar("hmc_cl_fixchrome", 1, true, false, "Fix chrome envmap lighting")
end

SWEP.BounceWeaponIcon  = false
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.Category		= "HMC"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.Recoil			= 1.5
SWEP.Primary.Damage			= 40
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.Delay			= 0.14

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.UseHands = true
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.VecticalRecoil = 1
SWEP.IsRandomVecticalRecoil = false
SWEP.HorisontalRecoil = 0

SWEP.HolsterSound = "hmc/weapons/gun_holster_01.wav"

SWEP.ReloadDelay = 2
SWEP.DualSoundDelay = 0.1
SWEP.WepLength = 64
SWEP.WepWeight = 2.55

SWEP.WeaponType = 1 -- 1 - пистолет, 2 - винтовка, 3 - нож, 4 - другое
SWEP.GunType = 1
SWEP.DrySound				= "hmc/weapons/w_empty_01.wav"

function SWEP:SetupDataTables()

	self:NetworkVar( "Float", 0, "NextMul" )
	self:NetworkVar( "Float", 1, "NextReload" )
	self:NetworkVar( "Bool", 2, "Holster" )

	self:SetNextMul( 0 )
	self:SetNextReload( 0 )
	self:SetHolster( false )
end

function SWEP:Initialize()

	if ( SERVER ) then
		self:SetNPCMinBurst( 30 )
		self:SetNPCMaxBurst( 30 )
		self:SetNPCFireRate( 0.01 )
	end

	self:SetWeaponHoldType( self.HoldType )
	util.PrecacheSound( self.Primary.Sound )
	util.PrecacheSound( self.DrySound )
	util.PrecacheSound( self.HolsterSound )
end

function SWEP:Deploy()
	if self:Clip1() <= 0 and self.EmptyAnims == true or self.Dual == true and self:Clip1() <= 1 and self:Ammo1() <= 0 and self.EmptyAnims == true then
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW_EMPTY)
	else
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	end
	self.Weapon:SetNextPrimaryFire(CurTime() +0.5)
	self.Weapon:SetNextSecondaryFire(CurTime() +0.5)
	self:SetNextReload( CurTime() + 0.5 )
	self.idledelay = CurTime() +self:SequenceDuration()
	self:SetNextMul(CurTime() + self:SequenceDuration())
	self:SetHolster(false)
	return true
end

SWEP.MeleeVMMeleeAnim = ACT_VM_SECONDARYATTACK
SWEP.MeleeVMEmptyMeleeAnim = ACT_VM_PRIMARYATTACK_DEPLOYED_EMPTY
SWEP.EmptyAnims = false
SWEP.EmptyAnims2 = false
SWEP.UsePassiveIdle = true

SWEP.MeleeDelay = 0.3
SWEP.NextMeleeAttack = 1.5
SWEP.MeleeDamage = 40

SWEP.Dual = false

	local ebalosouns = {
		"hmc/weapons/punch_body_02.wav",
		"hmc/weapons/punch_body_03.wav"
		}
	local punchsounds = {
		"hmc/weapons/punch_body_01.wav",
		"hmc/weapons/punch_body_02.wav",
		"hmc/weapons/punch_body_03.wav",
		}

function SWEP:ImpactEffect(tr)
    if !IsFirstTimePredicted() then return end
    local e = EffectData()
    e:SetOrigin(tr.HitPos)
    e:SetStart(tr.StartPos)
    e:SetSurfaceProp(tr.SurfaceProps)
    e:SetDamageType(DMG_GENERIC)
    e:SetHitBox(tr.HitBox)
    if CLIENT then
        e:SetEntity(tr.Entity)
    else
        e:SetEntIndex(tr.Entity:EntIndex())
    end
    util.Effect("Impact", e)
end

function SWEP:Drop()

self.Owner:DoAnimationEvent( ACT_GMOD_GESTURE_ITEM_DROP )

if CLIENT then return end
	if self:Clip1() <= 0 and self.EmptyAnims == true or self.Dual == true and self:Clip1() <= 1 and self:Ammo1() <= 0 and self.EmptyAnims == true then
		self:SendWeaponAnim(ACT_VM_UNDEPLOY_EMPTY)
	else
		self:SendWeaponAnim(ACT_VM_THROW)
	end

	self.Weapon:SetNextPrimaryFire( CurTime() + self:SequenceDuration() )
	self.Weapon:SetNextSecondaryFire( CurTime() + self:SequenceDuration() )
	self:SetNextMul(CurTime()+self:SequenceDuration())
	self.idledelay = CurTime() + self:SequenceDuration()
	self:SetNextReload( CurTime() + self:SequenceDuration() )

	timer.Simple(0.22, function()
		if self.Weapon == nil then return end
		local drop = ents.Create("hmc_weapon_drop")
		drop:SetPos( self.Owner:GetShootPos() + self.Owner:GetAimVector() * 25 )

			drop.WeaponClass = self.Weapon:GetClass()
			drop.WeaponModel = self.WorldModel
			drop.WeaponType = self.WeaponType
			drop.WeaponClip = self.Weapon:Clip1()
		drop:Spawn()
		drop:Activate()
		--drop:SetModel(self.WorldModel)
	end)

	timer.Simple(self:SequenceDuration(), function()
		if self.Weapon == nil then return end
		self.Owner:StripWeapon(self.Weapon:GetClass())
	end)

end

function SWEP:SecondaryAttack()

	if self.Owner:KeyDown(IN_USE) then self:Drop() return end

	if self:Clip1() <= 0 and self.EmptyAnims == true or self.Dual == true and self:Clip1() <= 1 and self:Ammo1() <= 0 and self.EmptyAnims == true then
		self:SendWeaponAnim(self.MeleeVMEmptyMeleeAnim)
	else
		self:SendWeaponAnim(self.MeleeVMMeleeAnim)
	end
		self.Owner:DoAnimationEvent( ACT_GMOD_GESTURE_MELEE_SHOVE_2HAND )

	self:SetNextMul(CurTime()+self:SequenceDuration())
	self:SetNextReload( CurTime() + self.NextMeleeAttack )

	self:SetHoldType(self.HoldType)
		timer.Simple(0.25, function()
			if self.Weapon == nil then return end
			self:EmitSound("HMC/Weapons/Punch_Swing_0"..math.random(1,3)..".wav")
		end)
	timer.Simple(self.MeleeDelay, function()
		if self.Weapon == nil then return end
		local tr = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 55 ),
			filter = self.Owner,
			mins = Vector( -1, -1, -1 ),
			maxs = Vector( 1, 1, 1 ),
			mask = MASK_SHOT_HULL
		} )
		if tr.Hit then
			--util.Decal( "ManhackCut",( tr.HitPos - tr.HitNormal ),( tr.HitPos + tr.HitNormal ) )
			local trace2 = self.Owner:GetEyeTrace()
			if trace2.Entity:IsNPC() or trace2.Entity:IsPlayer() then
				if trace2.HitGroup == HITGROUP_HEAD then
					trace2.Entity:EmitSound(tostring(table.Random(ebalosouns)))
					self:ImpactEffect(tr)
				else
					trace2.Entity:EmitSound(tostring(table.Random(punchsounds)))
					self:ImpactEffect(tr)
				end
			else
				if tr.Entity:IsNPC() or tr.Entity:IsPlayer() then
					trace2.Entity:EmitSound(tostring(table.Random(punchsounds)))
					self:ImpactEffect(tr)
				end
			end

			if SERVER then
				local dmginfo = DamageInfo()
				local attacker = self.Owner
				if !IsValid(attacker) then attacker = self end
				dmginfo:SetAttacker(attacker)
				dmginfo:SetInflictor(self)
				dmginfo:SetDamageType(DMG_CLUB)
				dmginfo:SetDamage(self.MeleeDamage)
				dmginfo:SetDamageForce(self.Owner:GetUp() *4000 +self.Owner:GetForward() *15000)
				tr.Entity:TakeDamageInfo(dmginfo)
			end
		end
	end)

	self.Weapon:SetNextPrimaryFire( CurTime() + 1 )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.NextMeleeAttack )
	self.idledelay = CurTime() + self:SequenceDuration()

end

function SWEP:Reload()

	if ( self.Weapon:Ammo1() <= 0 ) or self.Weapon:Clip1() >= self.Primary.ClipSize then return end
	if self:GetNextReload() > CurTime() then return end
	if self.Weapon:GetNextPrimaryFire() > CurTime() then return end
		self:SetNextReload( CurTime() + self.ReloadDelay + 0.1 )
		self.Weapon:SetNextPrimaryFire( CurTime() + self.ReloadDelay )
		self.Weapon:SetNextSecondaryFire( CurTime() + self.ReloadDelay )
		self:SetNextMul(CurTime()+self.ReloadDelay)
	self:SetHoldType(self.HoldType)
		timer.Simple(0.1, function()
			if self.Weapon == nil then return end
			self.Owner:SetAnimation(PLAYER_RELOAD)
		end)
	--self.Weapon:DefaultReload( ACT_VM_RELOAD )
	local ammomath = 0
	if self.Weapon:Ammo1() >= self.Primary.ClipSize - self.Weapon:Clip1() then
		ammomath = self.Primary.ClipSize - self.Weapon:Clip1()
		self.Owner:SetAmmo( self.Weapon:Ammo1() - ammomath, self.Primary.Ammo )
	elseif self.Weapon:Ammo1() < self.Primary.ClipSize - self.Weapon:Clip1() then
		ammomath = self.Weapon:Ammo1()
		self.Owner:SetAmmo( 0, self.Primary.Ammo )
	end

	timer.Simple( self.ReloadDelay, function()
		if self.Weapon == nil then return end
		if ( self.Weapon:Clip1() >= self.Primary.ClipSize ) then return end
		self.Weapon:SetClip1( self.Weapon:Clip1()+ammomath )
	end)
			if self:Clip1() <= 0 and self.WeaponType == 1 and self.EmptyAnims2 == true then
			self:SendWeaponAnim(ACT_VM_RELOAD_EMPTY)
			else
			self:SendWeaponAnim(ACT_VM_RELOAD)
			end
	self.idledelay = CurTime() + self:SequenceDuration()

	--self.Weapon:EmitSound(self.ReloadSound)
end

function SWEP:SecondThink()

end

function SWEP:Think()

	self:SecondThink()

	for _,ply in pairs(player.GetAll()) do
	ply:SetDSP( 0 )
	end

	if CLIENT then return end
	if self.idledelay and CurTime() > self.idledelay then
			if self:Clip1() <= 0 and self.EmptyAnims == true or self.Dual == true and self:Clip1() <= 1 and self:Ammo1() <= 0 and self.EmptyAnims == true then
				self:SendWeaponAnim(ACT_VM_IDLE_EMPTY)
			else
				self:SendWeaponAnim(ACT_VM_IDLE)
			end
		self.idledelay = CurTime() + self:SequenceDuration()
		if self.cantholster and CurTime() > self.cantholster then
			self.cantholster = nil
		end
	end

	if !self:GetHolster() and self.UsePassiveIdle == true then
		if self:GetNextMul() < CurTime() then
			self:SetHoldType("passive")
		elseif self:GetNextMul() >= CurTime() then
			self:SetHoldType(self.HoldType)
		end
	elseif self.UsePassiveIdle == false then
		self:SetHoldType(self.HoldType)
	end


		--self:SetNextReload( CurTime() + self.ReloadDelay )
		--self.Weapon:SetNextPrimaryFire( CurTime() + self.ReloadDelay )
		--self.Weapon:SetNextSecondaryFire( CurTime() + self.ReloadDelay )

	if self.HolsterDelay and self.HolsterDelay - CurTime() <= 0 and SERVER then
		self.Owner:SelectWeapon(self.ChangeTo)
	end

end

function SWEP:OnRemove()

end
function SWEP:TakeAmmo(num)
	num = num or 1
	if !cvars.Bool("hmc_infiniteammo") then
		if !self.Owner:IsNPC() then self:TakePrimaryAmmo(num) end
	end
end
function SWEP:PrimaryAttack()
	if not IsValid(self.Owner) or self.Owner:Health() < 0 or !self:CanPrimaryAttack() or self:NearWall() or self:GetNextReload() > CurTime() then return end
	self:ShootBullet()
			if self:Clip1() <= 1 and self.WeaponType == 1 and self.EmptyAnims == true or self.Dual == true and self:Clip1() <= 2 and self.WeaponType == 1 and self.EmptyAnims == true or self.Dual == true and self:Clip1() <= 3 and self:Ammo1() <= 0 and self.WeaponType == 1 and self.EmptyAnims == true then
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_EMPTY)
			else
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
			end
			self.Owner:SetAnimation(PLAYER_ATTACK1)
			self:SetNextMul(CurTime()+2)
	--self.Owner:FireBullets( bullet )
	self:MuzzleHMC()
		if SERVER then self.Owner:EmitSound(Sound(self.Primary.Sound)) end
		if SERVER then if self.Dual == true then timer.Simple (self.DualSoundDelay, function() self.Owner:EmitSound(Sound(self.Primary.Sound)) end) end end
	--self.Owner:ViewPunch( Angle( -1,0,0 ) )
	self:TakeAmmo(self.Primary.TakeAmmo)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
			self.idledelay = CurTime() + self:SequenceDuration()

		local ply = self.Owner
	    if !ply:IsNPC() and ( (game.SinglePlayer() and SERVER) or ( !game.SinglePlayer() and CLIENT and IsFirstTimePredicted() ) ) then
                local shotang = self.Owner:EyeAngles()
					if !self.IsRandomVecticalRecoil then
						shotang.pitch = shotang.pitch - self.VecticalRecoil
					else
						shotang.pitch = shotang.pitch - math.random(-self.VecticalRecoil,self.VecticalRecoil)
					end
					shotang.yaw = shotang.yaw - math.random(-self.HorisontalRecoil,self.HorisontalRecoil)
                ply:SetEyeAngles( shotang )
        end

end

SWEP.Penetration = false
SWEP.PenetrationSpread = 0

function SWEP:ShootBullet(dmg, numbul, cone, ric)
	numbul 	= numbul 	or 1
	cone 	= cone 		or 0.01
		local bulletcallback = function(attacker, tr, dmginfo)
				if tr.HitWorld and !tr.HitSky then
					sound.Play("HMC/Weapons/Impact_Undefined"..math.random(1,5)..".wav", tr.HitPos, 75, 100)

						local fx 		= EffectData()
						fx:SetOrigin(tr.HitPos)
						fx:SetNormal(tr.HitNormal)
						util.Effect( "HMC_hit",fx)
				end
				if tr.Entity:IsValid() and ( tr.Entity:IsNPC() or tr.Entity:IsPlayer() ) and self.Penetration == true then

					local bullet = {}
					bullet.Num = self.Primary.NumberofShots
					bullet.Src = tr.HitPos + (tr.HitNormal*-1)*15
					bullet.Dir = self.Owner:GetAimVector()
					bullet.Spread = Vector( self.PenetrationSpread, self.PenetrationSpread, 0)
					bullet.Tracer = 1
					bullet.Force = self.Primary.Force
					bullet.Damage = self.Primary.Damage
					bullet.AmmoType = self.Primary.Ammo
					tr.Entity:FireBullets(bullet)
				end

				return true
			end


local bullet = {}
	if self.Dual == false then
		bullet.Num = self.Primary.NumberofShots
		bullet.Src = self.Owner:GetShootPos()
		bullet.Dir = self.Owner:GetAimVector()
		bullet.Spread = Vector( self.Primary.Spread * 0.1 , self.Primary.Spread * 0.1, 0)
		bullet.Tracer = 1
		bullet.Force = self.Primary.Force
		bullet.Damage = self.Primary.Damage
		bullet.AmmoType = self.Primary.Ammo
		bullet.Callback = bulletcallback
		self.Owner:FireBullets(bullet)
	elseif self.Dual == true then
		for i = 1, self.Primary.NumberofShots do
			bullet.Num = 1
			bullet.Src = self.Owner:GetShootPos()
			bullet.Dir = self.Owner:GetAimVector()+VectorRand()*self.Primary.Spread*0.1
			bullet.Spread = Vector(0,0,0)//Vector( self.Primary.Spread * 0.1 , self.Primary.Spread * 0.1, 0)
			bullet.Tracer = 1
			bullet.Force = self.Primary.Force
			bullet.Damage = self.Primary.Damage
			bullet.AmmoType = self.Primary.Ammo
			bullet.Callback = bulletcallback
			self.Owner:FireBullets(bullet)
		end
	end

	--self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	--self.Owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:CanPrimaryAttack()
	if  self:Clip1() <= 0 or self.Dual == true and self:Clip1() <= 1 then
			if self.Weapon:Ammo1() > 0 then
				self:Reload()
			else
				self:DryFire()
				self:SetNextPrimaryFire( CurTime() + 0.3 )
				self:SetNextSecondaryFire( CurTime() + 0.3 )
			end
		return false

	end

	return true
end

function SWEP:DryFire()
	self.Weapon:EmitSound(self.DrySound)
	self.Weapon:SendWeaponAnim(ACT_VM_DRYFIRE)
	self.idledelay = CurTime() + self:SequenceDuration()
end

function SWEP:NearWall()
if self.Owner:IsNPC() or !self.Owner:IsValid() then return end
	return self.Owner:GetShootPos():Distance(self.Owner:GetEyeTrace().HitPos) <= 45 and !self.Owner:GetEyeTrace().Entity:IsPlayer() and !self.Owner:GetEyeTrace().Entity:IsNPC()
end

SWEP.NearWallAng = Vector(0, 0, 0)
SWEP.NearWallPos = Vector(0, 0, 0)

local Mul = 0
local NextMul = 0
local NearWallMul = 0

function SWEP:GetViewModelPosition( pos, ang )

local FT = FrameTime()
local pitch = self.Owner:EyeAngles().pitch

		if self.Weapon:GetNextPrimaryFire() < CurTime() and !self:NearWall() and self.UsePassiveIdle == true then
			if NextMul < CurTime() then
				Mul = Lerp(FT*1, Mul, 1)
			end
		else
				Mul = Lerp(FT*12, Mul, 0)
				NextMul = CurTime() + 1.5
		end

	if self:NearWall() and self:GetNextReload() < CurTime() then
		NearWallMul = Lerp(FT*6, NearWallMul, 1)
	else
		NearWallMul = Lerp(FT*6, NearWallMul, 0)
	end

		ang:RotateAroundAxis( ang:Right(), (self.NearWallAng.x * NearWallMul) )
		ang:RotateAroundAxis( ang:Up(), (self.NearWallAng.y * NearWallMul) )
		ang:RotateAroundAxis( ang:Forward(), (self.NearWallAng.z * NearWallMul))

	pos = pos+(ang:Right()*0)+(ang:Forward()*0)+(ang:Up()*(-5+(pitch*0.09))*Mul)
	pos = pos+(ang:Right()*self.NearWallPos.x*NearWallMul)+(ang:Forward()*self.NearWallPos.y*NearWallMul)+(ang:Up()*self.NearWallPos.z*NearWallMul)

	return pos, ang

end

function SWEP:DrawHUD()
	self:Crosshair()
end

function SWEP:Crosshair()
	local x, y = ScrW() / 2, ScrH() / 2
	local tr = self.Owner:GetEyeTraceNoCursor()

	if (self.Owner == LocalPlayer() && self.Owner:ShouldDrawLocalPlayer()) then
		local coords = tr.HitPos:ToScreen()
		x, y = coords.x, coords.y
	end

	local dist = math.Round(-self.Owner:GetPos():Distance(self.Owner:GetEyeTraceNoCursor().HitPos) /12) +64
	dist = math.Clamp(dist, 32, 128)

	local getgun = self.GunType

	local colr, colg, colb = 255, 255, 255
	if (tr.Entity:IsNPC() or tr.Entity:IsPlayer()) and tr.Entity:Health() > 0 then
			colr, colg, colb = 255, 0, 0
	end

	surface.SetTexture(surface.GetTextureID("vgui/HMC/Crosshair"..getgun))
	if getgun != 0 then surface.SetDrawColor(colr, colg, colb, 255) else surface.SetDrawColor(colr, colg, colb, 0) end
	surface.DrawTexturedRect(x - 16, y - 16, 32, 32)
end
local srface = surface
function SWEP:PrintWeaponInfo( x, y, alpha )

	if ( self.DrawWeaponInfoBox == false ) then return end

	if (self.InfoMarkup == nil ) then
		local str
		local title_color = "<color=230,230,230,255>"
		local text_color = "<color=150,150,150,255>"

		str = "<font=HudSelectionText>"
		if ( self.Author != "" ) then str = str .. title_color .. "Author:</color>\t"..text_color..self.Author.."</color>\n" end
		if ( self.Contact != "" ) then str = str .. title_color .. "Contact:</color>\t"..text_color..self.Contact.."</color>\n\n" end
		if ( self.Purpose != "" ) then str = str .. title_color .. "Purpose:</color>\n"..text_color..self.Purpose.."</color>\n\n" end
		if ( self.Instructions != "" ) then str = str .. title_color .. "Instructions:</color>\n"..text_color..self.Instructions.."</color>\n" end
				-- Moar info --
		str = str .. title_color .. "Caliber:</color>\t"..text_color..self.Primary.Ammo.. "</color>\n"
		str = str .. title_color .. "Clip capacity:</color>\t"..text_color..self.Primary.ClipSize.."</color>\n"
		str = str .. title_color .. "Length</color>\t"..text_color..self.WepLength.." cm".."</color>\n"
		str = str .. title_color .. "Weight</color>\t"..text_color..self.WepWeight.." kg".."</color>\n"
		str = str .. "</font>"

		self.InfoMarkup = markup.Parse( str, 250 )
	end

	srface.SetDrawColor( 60, 60, 60, alpha )
	srface.SetTexture( self.SpeechBubbleLid )

	srface.DrawTexturedRect( x, y - 64 - 5, 128, 64 )
	draw.RoundedBox( 8, x - 5, y - 6, 260, self.InfoMarkup:GetHeight() + 18, Color( 60, 60, 60, alpha ) )

	self.InfoMarkup:Draw( x+5, y+5, nil, nil, alpha )

end

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

function SWEP:OnRestore()

	self.NextSecondaryAttack = 0

end
function SWEP:PostDrawViewModel(vm, wep, ply)
		local lightCol = render.GetLightColor(vm:GetPos() + Vector(0,0,2))
		if render.GetToneMappingScaleLinear()[1] != 1 then -- checking for HDR
			lightCol = (lightCol[1] + lightCol[2] + lightCol[3]) / 3
			lightCol = lightCol / 2 + .02
			lightCol = math.min(lightCol, .3)
			lightCol = Vector(lightCol, lightCol, lightCol)
		else
			lightCol = lightCol * 2
		end

		if !self.chromeMats then
			self.chromeMats = {}
			for k, v in pairs(vm:GetMaterials()) do
				if string.find(v, "HMC") then
					local mat = Material(v)
					if !mat:IsError() and mat:GetShader() == "VertexLitGeneric" then
						table.insert(self.chromeMats, {vm:GetModel(), mat})
					end
				end
			end
		else
			for k, v in pairs(self.chromeMats) do
				if v[1] == vm:GetModel() then
					v[2]:SetVector("$envmaptint", lightCol)
				else
					self.chromeMats = nil
				end
			end
		end
	end
function SWEP:Holster(wep)
	local vm = self.Owner:GetViewModel()

	return true
	--[[

	if self:IsValid() and self.Owner:IsValid() and IsValid(vm) then
		//return activity == "ACT_VM_IDLE" or activity == "ACT_VM_IDLE_SILENCED"
		local activity = vm:GetSequenceActivityName(vm:GetSequence())

		if IsValid(wep) and self:GetNextPrimaryFire() < CurTime() and !self.HolsterDelay and SERVER then
			self.idledelay = nil
			self:SetNextReload( CurTime() + self:SequenceDuration() )
			self.idledelay = CurTime() +self:SequenceDuration()
			self:SetNextMul(CurTime() + self:SequenceDuration())
			self:SetNextPrimaryFire(CurTime() + self:SequenceDuration())
			self:SetNextSecondaryFire(CurTime() + self:SequenceDuration())
				self:SetHolster(true)
				self:SetHoldType("slam")
				self:EmitSound(self.HolsterSound, 100, 100)
			if self:Clip1() <= 0 and self.EmptyAnims == true or self.Dual == true and self:Clip1() <= 1 and self:Ammo1() <= 0 and self.EmptyAnims == true then
				self:SendWeaponAnim(ACT_VM_HOLSTER_EMPTY)
			else
				self:SendWeaponAnim(ACT_VM_HOLSTER)
			end
			self.HolsterDelay = CurTime() + self:SequenceDuration()
			self.ChangeTo = wep:GetClass()

			/*self.NewWeapon = wep:GetClass()
			print(self.NewWeapon)
			timer.Simple(self:SequenceDuration() , function()
				if IsValid(self) and IsValid(self.Owner) and self.Owner:Alive() then
					print ("Kakaha")
					if SERVER then
						self.Owner:SelectWeapon(self.NewWeapon)
					end
				end
			end)
			return false*/

		end

		if self.HolsterDelay and self.HolsterDelay - CurTime() <= 0 then
			self.HolsterDelay = nil
			self.ChangeTo = nil
			return true
		end
	end

	return false
	--]]
end
