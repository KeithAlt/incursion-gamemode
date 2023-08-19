-- NOTE: This is a hardcoded list of entities that players can abuse to crash the server
MsgC(Color(255,0,0), "[ANTI-EXPLOIT HANDLER] ", Color(255,255,255), "Anti-crash script prevention initalized!")

local entList = {
	["npc_satchel"] = true,
	["fo_mine"] = true,
	["fo_cryo_mine"] = true,
	["farm_water"] = true
}

hook.Add("OnEntityCreated", "AntiExploitHandler", function(ent)
	local entity = ent -- Needed for cached-timer use

	if entList[entity:GetClass()] then
		timer.Simple(0, function()
			if IsValid(entity) then
				entity:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
				MsgC(Color(255,0,0), "[ANTI-EXPLOIT HANDLER] ", Color(255,255,255), "An exploitable entity (" .. entity:GetClass() .. ") has been spawned; handling...\n")
			end
		end)
	end
end)
