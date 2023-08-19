local meta = FindMetaTable("Entity")

function meta:CKit_IsPersistable()
	return self.CasinoKitTable or self.CasinoKitPersistable
end


local Get = meta.GetNW2Bool or meta.GetNWBool
local Set = meta.SetNW2Bool or meta.SetNWBool
function meta:CKit_IsPersisted()
	return Get(self, "CasinoKit_Persistent")
end
function meta:CKit_SetPersistedNWFlag(b)
	Set(self, "CasinoKit_Persistent", b)
end