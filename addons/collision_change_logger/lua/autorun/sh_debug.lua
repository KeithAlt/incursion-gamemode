local ENTITY = FindMetaTable("Entity")
ENTITY.OldSetCollisionGroup = ENTITY.SetCollisionGroup

function ENTITY:SetCollisionGroup(group)
	print("SetCollisionGroup has been called.")
	print("Args:", self, group)
	debug.Trace()

	self:OldSetCollisionGroup(group)
end
