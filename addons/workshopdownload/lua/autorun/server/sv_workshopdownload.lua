AddCSLuaFile("workshopdl_config.lua")

WorkshopDL = WorkshopDL or {}

include("workshopdl_config.lua")

for i, id in ipairs(WorkshopDL.RequiredContent) do
	resource.AddWorkshop(id)
end
