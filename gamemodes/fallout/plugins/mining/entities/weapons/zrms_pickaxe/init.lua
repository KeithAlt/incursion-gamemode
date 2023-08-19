local PLUGIN = PLUGIN

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
SWEP.Weight = 5

util.AddNetworkString("zrmine_insert_FX")
util.AddNetworkString("zrmine_FX")

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
end

local vmAnims = {ACT_VM_HITCENTER, ACT_VM_HITKILL}

local function createInsertEffect(prop, rtype)
	local effectInfo = {}
	effectInfo.parent = prop
	effectInfo.rtype = rtype
	net.Start("zrmine_insert_FX")
	net.WriteTable(effectInfo)
	net.SendPVS(prop:GetPos())
end

local function createEffectTable(effect, sound, parent, angle, position, attach)
	net.Start("zrmine_FX")
	local effectInfo = {}
	effectInfo.effect = effect
	effectInfo.sound = sound
	effectInfo.pos = position
	effectInfo.ang = angle
	effectInfo.parent = parent
	effectInfo.attach = attach
	net.WriteTable(effectInfo)
	net.SendPVS(parent:GetPos())
end

function SWEP:PrimaryAttack()
	if not IsValid(self.Owner) then return end

	local tr = self.Owner:GetEyeTrace()
	local trEnt = tr.Entity

	if (self:GetCoolDown() - CurTime()) < 0 then

		if ( IsValid(trEnt) and trEnt:GetClass() == "fo_mine_rock" and PLUGIN:InDistance(self.Owner:GetPos(), trEnt:GetPos(), 100) ) then

			-- Generate new cooldown
			local harvestIntervalMul = self:GetHarvestInterval()
			self:SetNextCoolDown(harvestIntervalMul)
			self:SetCoolDown(CurTime() + self:GetNextCoolDown())

			local previousHp = tonumber(tostring(trEnt:getNetVar("mineHp", PLUGIN.DefaultHp)))
			local hp = previousHp - (0.01 + ((self.Owner:getSpecial("S") or 0) / 10) * 0.02) * PLUGIN.HarvestMul
			local previousCeil = math.ceil(previousHp)
			local ceil = math.ceil(hp)

			if (previousHp == 0) then
				self:SetNextCoolDown(1)
				self:SetCoolDown(CurTime() + self:GetNextCoolDown())
				self:SendWeaponAnim(ACT_VM_MISSCENTER)
				self.Owner:SetAnimation(PLAYER_ATTACK1)
				self.Owner:ViewPunch(Angle(-1, 0, 0))
				return
			elseif ( ceil < previousCeil ) then
				local rType = trEnt:getNetVar("mineType", PLUGIN.DefaultType)

				local item = PLUGIN.Rocks[rType][2]
				if (type(item) == "table") then
					item = item[math.random(1, #item)]
				end

				local result, msg = self.Owner:getChar():getInv():add(PLUGIN.Ores[item])
				if ( not result ) then
					self.Owner:ChatPrint("Inventory is Full.")
					return
				end

				createInsertEffect(trEnt, rType)
				createEffectTable("zrms_ore_mine", "zrmine_resourcedespawn", trEnt, trEnt:GetAngles(), trEnt:GetPos())

				if ( hp < 0.01 ) then
					trEnt:setNetVar("mineHp", 0)
					trEnt:RemoveAllDecals()
					trEnt:SetCustomCollisionCheck(true)

					trEnt.NextRefresh = CurTime() + trEnt.RefreshRate -- Refresh the rock hp
				else
					trEnt:setNetVar("mineHp", hp)
				end
			else
				trEnt:setNetVar("mineHp", hp)
			end

			self:SendWeaponAnim(vmAnims[math.random(#vmAnims)])
			self.Owner:SetAnimation(PLAYER_ATTACK1)
			self.Owner:ViewPunch(Angle(-1, 0, 0))

			createEffectTable("pickaxe_hit01", "zrmine_pickaxeHit", trEnt, tr.HitNormal:Angle(), tr.HitPos)
		else
			self:SetNextCoolDown(1)
			self:SetCoolDown(CurTime() + self:GetNextCoolDown())
			self:SendWeaponAnim(ACT_VM_MISSCENTER)
			self.Owner:SetAnimation(PLAYER_ATTACK1)
			self.Owner:ViewPunch(Angle(-1, 0, 0))
		end
	end
end


function SWEP:SecondaryAttack()
end

--Tells the script what to do when the player "Initializes" the SWEP.
function SWEP:Equip()
	self:SendWeaponAnim(ACT_VM_DRAW) -- View model animation
	self.Owner:SetAnimation(PLAYER_IDLE) -- 3rd Person Animation
end

function SWEP:Reload()
end

function SWEP:ShouldDropOnDie()
	return false
end
