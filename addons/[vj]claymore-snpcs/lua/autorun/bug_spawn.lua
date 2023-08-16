if (!file.Exists("autorun/vj_base_autorun.lua","LUA")) then return end
include('autorun/vj_controls.lua')

local vCat = "Fallout"

VJ.AddNPC("Enclave Eyebot","npc_bug",vCat)
