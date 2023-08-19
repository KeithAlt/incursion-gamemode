AddCSLuaFile()
---------------------------------------------------------------------------------------------------------------------------//
CreateConVar("gb_deleteconstraints", "1", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
CreateConVar("gb_unfreeze", "0", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
CreateConVar("gb_easyuse", "1", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
CreateConVar("gb_fragility", "1", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
CreateConVar("gb4_shockwave_unfreeze", "0", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
CreateConVar("gb4_sound_shake", "1", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
CreateConVar("gb4_cache_health", "1", { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )

---------------------------------------------------------------------------------------------------------------------------\\

SetGlobalString ( "gb_ver", 2.2 )

function gb4_initialize()
Msg("\n|----------------------|")
Msg("\n|Gbombs 4 | Version "..GetGlobalString("gb_ver"))
Msg("\n|Created by the Gbombs Team.")
Msg("\n|Do not reupload without permission.")
Msg("\n|Write '!gb' in chat for help")
Msg("\n|Have fun <3")
Msg("\n|----------------------|\n")
end

hook.Add( "InitPostEntity", "gb4_initialize", gb4_initialize )

concommand.Add("gb4_whatisit", function(ply)
	if ply:GetEyeTrace().Entity.GBOWNER==nil then return end
	ply:ChatPrint("Entity: "..tostring(ply:GetEyeTrace().Entity).."\nOwner: "..ply:GetEyeTrace().Entity.GBOWNER:Nick())
end)
