--[[
	StockPool object
	Automatically networks all values and interacts with the database
]]
BuyMenu.StockPools = BuyMenu.StockPools or {}

local StockPool = {}
StockPool.__index = StockPool

local lenTypes = {
	["Int"] = true,
	["UInt"] = true
}

function BuyMenu.AddStockPoolVar(name, vType, onSet, onGet, default)
	if SERVER then
		util.AddNetworkString("BuyMenuSPSet" .. name)
	end

	if CLIENT then
		net.Receive("BuyMenuSPSet" .. name, function()
			local spID = net.ReadUInt(32)
			local val = net["Read" .. vType](lenTypes[vType] and 32 or nil)
			BuyMenu.StockPools[spID] = BuyMenu.StockPools[spID] or setmetatable({}, StockPool)
			local pool = BuyMenu.StockPools[spID]
			pool["Set" .. name](pool, val)
		end)
	end

	StockPool["Set" .. name] = function(self, val, skipCallback)
		self[name] = val

		if SERVER then
			net.Start("BuyMenuSPSet" .. name)
				net.WriteUInt(self:GetID(), 32)
				net["Write" .. vType](val, lenTypes[vType] and 32 or nil)
			net.Broadcast()

			if onSet and skipCallback != true then
				onSet(self, val)
			end
		end
	end

	StockPool["Get" .. name] = function(self, skipCallback)
		if onGet and skipCallback != true then
			onGet(self)
		end

		return self[name] or (istable(default) and table.Copy(default) or default)
	end
end

BuyMenu.AddStockPoolVar("ID", "UInt", function(pool, id)
	BuyMenu.StockPools[id] = pool
end)
BuyMenu.AddStockPoolVar("Stock", "UInt", function(pool, stock)
	BuyMenu.SQL:Query(string.format("UPDATE `stockPools` SET curStock = %u WHERE id = %u;", stock, pool:GetID()))
end)
BuyMenu.AddStockPoolVar("MaxStock", "UInt")
BuyMenu.AddStockPoolVar("RestockAmt", "UInt")
BuyMenu.AddStockPoolVar("StockInterval", "UInt")
BuyMenu.AddStockPoolVar("LastRestock", "UInt", function(pool, lastRestock)
	BuyMenu.SQL:Query(string.format("UPDATE `stockPools` SET lastRestock = %u WHERE id = %u;", lastRestock, pool:GetID()))
end)

function StockPool:GetNextRestock()
	return self:GetLastRestock() + self:GetStockInterval()
end

function StockPool:Remove(skipDB)
	BuyMenu.StockPools[self:GetID()] = nil

	if SERVER then
		if skipDB != true then
			BuyMenu.SQL:Query(string.format("DELETE FROM `stockPools` WHERE id = %u", self:GetID()))
		end

		net.Start("BuyMenuStockRemove")
			net.WriteUInt(self:GetID(), 8)
		net.Broadcast()
	end

	self = nil
end

if SERVER then
	util.AddNetworkString("BuyMenuStockPools")

	function StockPool:Restock()
		self:SetStock(math.min(self:GetStock() + self:GetRestockAmt(), self:GetMaxStock()))
		self:SetLastRestock(os.time())
	end

	function StockPool:TakeStock()
		self:SetStock(math.max(self:GetStock() - 1, 0))
	end

	local function CreateStockPool(dat)
		local pool = {}

		setmetatable(pool, StockPool)

		pool:SetID(dat.id)
		pool:SetStock(dat.curStock, true)
		pool:SetMaxStock(dat.maxStock)
		pool:SetRestockAmt(dat.restockAmt)
		pool:SetStockInterval(dat.stockInterval)
		pool:SetLastRestock(dat.lastRestock, true)

		return pool
	end

	function BuyMenu.CreateStockPool(dat, insert, callback)
		if insert then
			BuyMenu.SQL:Query(string.format("INSERT INTO `stockPools` VALUES(NULL, %u, %u, %u, %f, %f); SELECT LAST_INSERT_ID();", dat.curStock, dat.maxStock, dat.restockAmt, dat.stockInterval, dat.lastRestock), function(_, response)
				dat.id = response[1]["LAST_INSERT_ID()"]

				local pool = CreateStockPool(dat)

				if callback then
					callback(pool)
				end
			end)
		else
			local pool = CreateStockPool(dat)

			if callback then
				callback(pool)
			end
		end
	end

	function BuyMenu.NetworkStockPoolsTo(ply)
		net.Start("BuyMenuStockPools")
			jlib.WriteCompressedTable(BuyMenu.StockPools)
		net.Send(ply)
	end
	hook.Add("PlayerInitialSpawn", "BuyMenuSPNetwork", BuyMenu.NetworkStockPoolsTo)

	timer.Create("BuyMenuStock", BuyMenu.StockTimer, 0, function()
		for _, pool in pairs(BuyMenu.StockPools) do
			if pool:GetNextRestock() <= os.time() then
				pool:Restock()
			end
		end
	end)
end

BuyMenu.StockPoolMeta = StockPool
