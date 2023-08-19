ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.AdminOnly = true

ENT.PrintName = "Mining Rock"
ENT.Author = "SuperMicronde"
ENT.Category = "NutScript"

PLUGIN.Ores = {
    [1] = "ore_iron",
    [2] = "ore_bronze",
    [3] = "ore_silver",
    [4] = "ore_gold",
    [5] = "coal"
}

PLUGIN.Rocks = {
    [0] = {"Random", {1, 2, 3, 4, 5}},
    [1] = {"Iron", 1},
    [2] = {"Bronze", 2},
    [3] = {"Silver", 3},
    [4] = {"Gold", 4},
    [5] = {"Coal", 5}
}

function PLUGIN:ShouldCollide( ent1, ent2 )
	if ( (IsValid( ent1 ) and ent1:GetClass() == "fo_mine_rock") or (IsValid( ent2 ) and ent2:GetClass() == "fo_mine_rock") ) then return false end
end