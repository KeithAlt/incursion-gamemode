AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= true

//Make sure all clients get the materials
resource.AddFile("materials/smokenade/smokenade.vmt")
resource.AddFile("materials/smokenade/smokenade.vtf")
resource.AddFile("materials/smokenade/smokenade_normal.vtf")
resource.AddFile("materials/weapons/swep_smokenade.vtf")
resource.AddFile("materials/weapons/swep_smokenade.vmt")