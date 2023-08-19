local PLUGIN = PLUGIN

include("shared.lua")
SWEP.PrintName = "Pickaxe"
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end


function SWEP:DrawHUD()
	-- CoolDown
	local cd = self:GetCoolDown() - CurTime()

	if (cd > 0) then
	else
		self:SetCoolDown(-1)
	end
end

local vmAnims = {ACT_VM_HITCENTER, ACT_VM_HITKILL}

function SWEP:PrimaryAttack()
	local tr = self.Owner:GetEyeTrace()
	local trEnt = tr.Entity

	if ((self:GetCoolDown() - CurTime()) < 0) then
		if (self.Owner:getChar() and IsValid(trEnt) and trEnt:GetClass() == "fo_mine_rock") then
			if PLUGIN:InDistance(self.Owner:GetPos(), trEnt:GetPos(), 100) then
				local previousHp = tonumber(tostring(trEnt:getNetVar("mineHp", PLUGIN.DefaultHp)))
				local hp = previousHp - (0.01 + (self.Owner:getChar():getAttrib("strength", 0) / 10) * 0.025)
				local previousCeil = math.ceil(previousHp)
				local ceil = math.ceil(hp)

				if (previousHp == 0) then
					return
				elseif ( ceil < previousCeil ) then
					local x = self.Owner:getChar():getInv():findEmptySlot(1, 1)
					if not x then
						return false
					end
				end

				self:SendWeaponAnim(vmAnims[math.random(#vmAnims)])
				self.Owner:SetAnimation(PLAYER_ATTACK1)
			end
		else
			self:SendWeaponAnim(ACT_VM_MISSCENTER)
			self.Owner:SetAnimation(PLAYER_ATTACK1)
		end
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
end

function SWEP:Holster()
	self:SendWeaponAnim(ACT_VM_HOLSTER)
end

--Tells the script what to do when the player "Initializes" the SWEP.
function SWEP:Equip()
	self:SendWeaponAnim(ACT_VM_DRAW) -- View model animation
	self.Owner:SetAnimation(PLAYER_IDLE) -- 3rd Person Animation
end

local function Emit_InsertEffect(prop, rtype)
	if (1 == 0) then return end
	local pos = prop:GetPos()
	local vel = Vector(0, 0, 200)

	pos = prop:GetPos() + prop:GetRight() * math.random(-50, 50) + prop:GetForward() * math.random(-50, 50)
	vel = Vector(0, 0, math.random(300, 350))

	local icon = prop.InsertEffect:Add("zerochain/zrms/particles/zrms_ore", pos)
	icon:SetVelocity(vel)
	icon:SetDieTime(2)
	icon:SetStartAlpha(255)
	icon:SetEndAlpha(0)
	icon:SetStartSize(7)
	icon:SetEndSize(10)
	local iconColor = Color(255, 255, 255)

	if (rtype == 1) then
		iconColor = Color(104, 85, 87)
	elseif (rtype == 2) then
		iconColor = Color(158, 72, 39)
	elseif (rtype == 3) then
		iconColor = Color(125, 125, 125)
	elseif (rtype == 4) then
		iconColor = Color(189, 143, 49)
	elseif (rtype == 5) then
		iconColor = Color(0, 0, 0)
	else
		iconColor = Color(255, 255, 255)
	end

	icon:SetColor(iconColor.r, iconColor.g, iconColor.b)
	icon:SetGravity(Vector(0, 0, 0))
	icon:SetAirResistance(256)
end

net.Receive("zrmine_insert_FX", function(len, ply)
	local effectInfo = net.ReadTable()

	-- Triggers our insert effect
	if IsValid(effectInfo.parent) and PLUGIN:InDistance(LocalPlayer():GetPos(), effectInfo.parent:GetPos(), 500) then
		Emit_InsertEffect(effectInfo.parent, effectInfo.rtype)
	end
end)

local function particleEffect(effect, pos, ang, ent)
	if 1 == 1 then
		ParticleEffect(effect, pos, ang, ent)
	end
end

local function particleEffectAttach(effect, enum, ent, attachid)
	if GetConVar("zrms_cl_particleffects"):GetInt() == 1 then
		ParticleEffectAttach(effect, enum, ent, attachid)
	end
end

local sounds = {}
sounds["zrmine_pickaxeHit"] = {
	paths = {"physics/concrete/concrete_impact_hard1.wav", "physics/concrete/concrete_impact_hard2.wav", "physics/concrete/concrete_impact_hard3.wav", "physics/concrete/concrete_impact_soft1.wav", "physics/concrete/concrete_impact_soft2.wav", "physics/concrete/concrete_impact_soft3.wav"},
	lvl = SNDLVL_65dB,
	pitchMin = 80,
	pitchMax = 90,
	pref_volume = 1
}
sounds["zrmine_resourcedespawn"] = {
	paths = {"physics/concrete/concrete_break2.wav", "physics/concrete/concrete_break3.wav"},
	lvl = SNDLVL_60dB,
	pitchMin = 95,
	pitchMax = 100,
	pref_volume = 1
}

local function catchSound(id)
	local soundData = {}
	local soundTable = sounds[id]
	soundData.sound = soundTable.paths[math.random(#soundTable.paths)]
	soundData.lvl = soundTable.lvl
	soundData.pitch = math.Rand(soundTable.pitchMin, soundTable.pitchMax)
	local vol = 1

	if CLIENT then
		vol = 1
	end

	soundData.volume = vol * soundTable.pref_volume

	return soundData
end

local function emitSoundENT(id, ent)
	local soundData = catchSound(id)

	EmitSound(soundData.sound, ent:GetPos(), ent:EntIndex(), CHAN_STATIC, soundData.volume, soundData.lvl, 0, soundData.pitch)
end

net.Receive("zrmine_FX", function(len, ply)
	local effectInfo = net.ReadTable()

	if effectInfo and IsValid(effectInfo.parent) then

		if (effectInfo.sound) then
			emitSoundENT(effectInfo.sound,effectInfo.parent)
		end

		if (effectInfo.effect and PLUGIN:InDistance(LocalPlayer():GetPos(), effectInfo.parent:GetPos(), 500)) then

			if (effectInfo.attach) then
				particleEffectAttach(effectInfo.effect, PATTACH_POINT_FOLLOW, effectInfo.parent, effectInfo.attach)
			else
				particleEffect(effectInfo.effect, effectInfo.pos, effectInfo.ang, effectInfo.parent)
			end
		end
	end
end)