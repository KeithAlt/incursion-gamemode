local Player = FindMetaTable("Player")

local LANGPRINT_L = 0
local LANGPRINT_ML = 1

if SERVER then
	util.AddNetworkString("ckit_langprint")
	function Player:CKit_PrintL(str, params)
		net.Start("ckit_langprint")
		net.WriteUInt(LANGPRINT_L, 2)
		net.WriteString(str)
		net.WriteTable(params or {})
		net.Send(self)
	end
	function Player:CKit_PrintML(str, params)
		net.Start("ckit_langprint")
		net.WriteUInt(LANGPRINT_ML, 2)
		net.WriteString(str)
		net.WriteTable(params or {})
		net.Send(self)
	end
else
	function Player:CKit_PrintL(str, params)
		self:ChatPrint(CasinoKit.L(str, params))
	end
	function Player:CKit_PrintML(str, params)
		self:ChatPrint(CasinoKit.ML(str, params))
	end
	net.Receive("ckit_langprint", function()
		local type = net.ReadUInt(2)
		if type == LANGPRINT_L then
			LocalPlayer():CKit_PrintL(net.ReadString(), net.ReadTable())
		elseif type == LANGPRINT_ML then
			LocalPlayer():CKit_PrintML(net.ReadString(), net.ReadTable())
		end

	end)
end
