--------------------------
-- BOOTSTRAP CODE START --
--------------------------

if !pcall(require,"pk_pills") then
	if SERVER then
		hook.Add("PlayerInitialSpawn","pk_pill_extfail_cl",function(ply)
			if game.SinglePlayer() || ply:IsListenServerHost() then
				ply:SendLua('notification.AddLegacy("One or more pill extensions failed to load. Did you forget to install Parakeet\'s Pill Pack?",NOTIFY_ERROR,30)')
			end
		end)
		hook.Add("Initialize","pk_pill_extfail_sv",function(ply)
			print("[ALERT] One or more pill extensions failed to load. Did you forget to install Parakeet's Pill Pack?")
		end)
	end
	return
end

------------------------
-- BOOTSTRAP CODE END --
------------------------

AddCSLuaFile()
include("pills/creature/pill_cazador.lua")
include("pills/creature/pill_feral.lua")
include("pills/creature/pill_deathclaw.lua")
include("pills/creature/pill_deathclaw_mef.lua")
include("pills/creature/pill_deathclaw_enclave.lua")
include("pills/sentry/pill_sentry.lua")
include("pills/sentry/pill_sentry_ncr.lua")
include("pills/sentry/pill_sentry_bos.lua")
include("pills/sentry/pill_sentry_enclave.lua")
include("pills/sentry/pill_sentry_legion.lua")
include("pills/sentry/pill_sentry_vt.lua")
include("pills/gutsy/pill_gutsy.lua")
include("pills/gutsy/pill_gutsy_ncr.lua")
include("pills/gutsy/pill_gutsy_bos.lua")
include("pills/gutsy/pill_gutsy_legion.lua")
include("pills/gutsy/pill_gutsy_enclave.lua")
include("pills/protectron/pill_protectron.lua")
include("pills/protectron/pill_protectron_ncr.lua")
include("pills/protectron/pill_protectron_legion.lua")
include("pills/protectron/pill_protectron_bos.lua")
include("pills/protectron/pill_protectron_enclave.lua")
include("pills/eyebot/pill_eyebot.lua")
include("pills/eyebot/pill_eyebot_faction.lua")
include("pills/creature/pill_fallout_dog.lua")
include("pills/pill_securitron.lua")
include("pills/pill_trog.lua")
include("pills/pill_roboscorp.lua")
