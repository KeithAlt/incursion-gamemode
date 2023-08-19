local ply,wep

--[[
Hook: PlayerTick
Function: Weapon Logic
Used For: Main weapon "think" logic
]]--

hook.Add("PlayerTick", "PlayerTickTFA", function(plyv)
	wep = plyv:GetActiveWeapon()
	if wep:IsValid() and wep.PlayerThink then
		wep:PlayerThink(plyv)
	end
end)

--[[
Hook: PreRender
Function: Weapon Logic
Used For: Per-frame weapon "think" logic
]]
--
hook.Add("PreRender", "prerender_tfabase", function()
	if not IsValid(ply) then ply = LocalPlayer() return end
	wep = ply:GetActiveWeapon() or wep

	if IsValid(wep) and wep.IsTFAWeapon and wep.PlayerThinkCL then
		wep:PlayerThinkCL(ply)
	end
end)

--[[
Hook: AllowPlayerPickup
Function: Prop holding
Used For: Records last held object
]]
--
hook.Add("AllowPlayerPickup", "TFAPickupDisable", function(plyv, ent)
	plyv:SetNW2Entity("LastHeldEntity", ent)
end)

--[[
Hook: PlayerBindPress
Function: Intercept Keybinds
Used For:  Alternate attack, inspection, shotgun interrupts, and more
]]--

local cv_cm = GetConVar("sv_tfa_cmenu")
local cv_cci
if CLIENT then
	cv_cci = GetConVar("cl_tfa_inspection_ckey")
end

function TFAPlayerBindPress(plyv, b, p)
	if p and IsValid(plyv) then
		wep = plyv:GetActiveWeapon() or wep

		if IsValid(wep) then
			--[[
			if wep.AltAttack and b == "+zoom" then
				wep:AltAttack()

				if CLIENT then
					net.Start("tfaAltAttack")
					net.SendToServer()
				end

				return true
			end
			]]--

			--[[

			if wep.ShotgunInterrupt and b == "+attack" and (wep:GetReloading() and wep.Shotgun and not wep:GetShotgunPumping() and not wep:GetShotgunNeedsPump()) then
				wep:ShotgunInterrupt()

				return true
			end
			]]--
			if wep.ToggleInspect and b == "+menu_context" and cv_cm:GetBool() then
				if not cv_cci:GetBool() then
					wep:ToggleInspect()
				elseif wep.CheckAmmo then
					net.Start("tfaRequestFidget")
					net.SendToServer()
				end
				return true
			end
		end
	end
end

hook.Add("PlayerBindPress", "TFAInspectionMenu", TFAPlayerBindPress)

--[[
Hook: KeyPress
Function: Allows player to bash
Used For:  Predicted bashing
]]--

local cv_lr = GetConVar("sv_tfa_reloads_legacy")

local function KP_Bash(plyv, key)
	if (key == IN_ZOOM) then
		wep = plyv:GetActiveWeapon()

		if IsValid(wep) and wep.AltAttack then
			wep:AltAttack()
		end
	end
	if (key == IN_RELOAD ) then
		plyv.HasTFAAmmoChek = false
		plyv.LastReloadPressed = CurTime()
	end
end

local reload_threshold = 0.3

hook.Add("KeyPress","TFABase_KP",KP_Bash)

local function KR_Reload(plyv, key)
	if key == IN_RELOAD and cv_lr and ( not cv_lr:GetBool() ) and CurTime() <= ( plyv.LastReloadPressed or CurTime() ) + reload_threshold then
		plyv.LastReloadPressed = nil
		plyv.HasTFAAmmoChek = false
		wep = plyv:GetActiveWeapon()

		if IsValid(wep) and wep.IsTFAWeapon then
			plyv:GetActiveWeapon():Reload( true )
		end
	end
end

hook.Add("KeyRelease","TFABase_KR",KR_Reload)

local function KD_AmmoCheck(plyv)
	if plyv.HasTFAAmmoChek then return end
	if plyv:KeyDown(IN_RELOAD) and CurTime() > ( plyv.LastReloadPressed or CurTime() ) + reload_threshold then
		wep = plyv:GetActiveWeapon()

		if IsValid(wep) and wep.IsTFAWeapon then
			plyv.HasTFAAmmoChek = true
			plyv:GetActiveWeapon():CheckAmmo()
		end
	end
end

hook.Add("PlayerTick","TFABase_KD",KD_AmmoCheck)

function TFA.ProcessBashZoom( plyv, wepv )
	if not IsValid(wepv) then
		plyv:SetCanZoom(true)
		return
	end
	if wepv.AltAttack then
		plyv:SetCanZoom(false)
	else
		plyv:SetCanZoom(true)
	end
end

local function PSW_PBZ(plyv,owv,nwv)
	timer.Simple(0,function()
		if IsValid(plyv) then
			TFA.ProcessBashZoom( plyv, plyv:GetActiveWeapon() )
		end
	end)
end

hook.Add("PlayerSwitchWeapon","TFABashFixZoom",PSW_PBZ)

--[[
Hook: PlayerSpawn
Function: Extinguishes players, zoom cleanup
Used For:  Fixes incendiary bullets post-respawn
]]--

hook.Add("PlayerSpawn", "TFAExtinguishQOL", function(plyv)
	if IsValid(plyv) and plyv:IsOnFire() then
		plyv:Extinguish()
		TFA.ProcessBashZoom( plyv, plyv:GetActiveWeapon() )
	end
end)

--[[
Hook: SetupMove
Function: Modify movement speed
Used For:  Weapon slowdown, ironsights slowdown
]]--

local cv_cmove = GetConVar("sv_tfa_compat_movement")
local sumwep
local speedmult

if not Clockwork then
	hook.Add("SetupMove", "tfa_setupmove", function(plyv, movedata, commanddata)
		if not cv_cmove then
			cv_cmove = GetConVar("sv_tfa_compat_movement")
		else
			if cv_cmove:GetBool() then return end
		end

		sumwep = plyv:GetActiveWeapon() or wep
		if IsValid(sumwep) and sumwep.IsTFAWeapon then
			sumwep.IronSightsProgress = sumwep.IronSightsProgress or 0
			speedmult = Lerp(sumwep.IronSightsProgress, sumwep.MoveSpeed or 1, sumwep.IronSightsMoveSpeed or 1)
			movedata:SetMaxClientSpeed(movedata:GetMaxClientSpeed() * speedmult)
			commanddata:SetForwardMove(commanddata:GetForwardMove() * speedmult)
			commanddata:SetSideMove(commanddata:GetSideMove() * speedmult)
		end
	end)
end

--[[
Hook: PlayerFootstep
Function: Weapoon Movement
Used For:  Weapon viewbob, gunbob per-step
]]
--
hook.Add("PlayerFootstep", "tfa_playerfootstep", function(plyv)
	local isc = TFA.PlayerCarryingTFAWeapon(plyv)

	if isc and wep.Footstep and CLIENT then
		wep:Footstep()
	end

	return
end)

--[[
Hook: HUDShouldDraw
Function: Weapon HUD
Used For:  Hides default HUD
]]--

local cv_he = GetConVar("cl_tfa_hud_enabled", 1)

if CLIENT then
	local TFAHudHide = {
		CHudAmmo = true,
		CHudSecondaryAmmo = true
	}

	hook.Add("HUDShouldDraw", "tfa_hidehud", function(name)
		if TFAHudHide[name] and cv_he:GetBool() then
			local ictfa = TFA.PlayerCarryingTFAWeapon()
			if ictfa then return false end
		end
	end)
end
