ITEM.name = 'Food'
ITEM.category = 'Food'
ITEM.desc = 'Food item'
ITEM.model = 'models/props_junk/watermelon01.mdl'

ITEM.functions.Use = {
	onRun = function(item) --Only ran server-side
        local ply = item.player
		local char = ply:getChar()
		if !char then return end

        char:setData("hunger", math.min(char:getData("hunger", 100) + item.amt, 100))

		if item.rads then ply:addRadsUpdate(item.rads) end

		local extra = item.extra
		if !isfunction(extra) then return end
		extra(ply)
	end
}