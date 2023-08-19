local dealers = {}

function CasinoKit.getDealer(name)
	return dealers[name]
end

function CasinoKit.registerDealer(name, tbl)
	dealers[name] = tbl
end
