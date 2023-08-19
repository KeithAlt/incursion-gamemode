ENT.Type = "anim"
ENT.PrintName = "Gas Mask"
ENT.Category = "SH Items"
ENT.Purpose = "Allows you to breathe while standing in a toxic gas cloud (Mustard gas, etc.)"

ENT.Spawnable = true

local meta = FindMetaTable("Player")

function meta:SH_HasGasMask()
	return self:GetNWBool("SH_GasMask") or (self.HasEquipmentItem and self:HasEquipmentItem(EQUIP_GASMASK))
end