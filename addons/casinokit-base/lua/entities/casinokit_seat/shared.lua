ENT.Type = "anim"

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "SeatIndex")
end

function ENT:GetSitter()
	for _,c in pairs(self:GetChildren()) do
		if IsValid(c) then
			return c:GetChildren()[1]
		end
	end
end

local Entity = FindMetaTable("Entity")
function Entity:CKit_IsSeat()
	return IsValid(self:GetParent()) and self:GetParent():GetClass() == "casinokit_seat"
end
function Entity:CKit_GetSeatIndex()
	if self:GetClass() == "casinokit_seat" then
		return self:GetSeatIndex()
	end
	return self:CKit_IsSeat() and self:GetParent():GetSeatIndex()
end
function Entity:CKit_GetTableEnt()
	if not self:CKit_IsSeat() then return end

	return self:GetParent():GetParent()
end