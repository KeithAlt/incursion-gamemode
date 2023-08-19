IDCardsConfig = {}
include("idcards_config.lua")

local items = {
    ["NCR ID Card"] = {
        ["model"] = "models/maxib123/bluepasscard.mdl",
        ["faction"] = "ncr"
    },
    ["BoS Civilian Tag"] = {
        ["model"] = "models/maxib123/tags.mdl",
        ["faction"] = "bos"
    },
    ["Legion Loyalist Coin"] = {
        ["model"] = "models/maxib123/legionmoney25.mdl",
        ["faction"] = "legion"
    },
    ["American Citizenship ID Card"] = {
        ["model"] = "models/maxib123/bluepasscard.mdl",
        ["faction"] = "enclave"
    },
	["Regiis Devotee Charm"] = {
		["model"] = "models/mosi/fallout4/props/plant/melonflower.mdl",
		["faction"] = "reegis"
	},
	["PLA Civilian Papers"] = {
		["model"] = "models/clutter/bookchinesearmy.mdl",
		["faction"] = "boomers_real"
	},
	["Allegiance ID Badge"] = {
		["model"] = "models/maxib123/tags.mdl",
		["faction"] = "tkc"
	}
}

local function ItemInit()
    for k,v in pairs(items) do
        local ITEM = nut.item.register(string.Replace(k:lower(), " ", "_"), nil, false, nil, true)
        ITEM.name    = k
        ITEM.model   = v.model
        ITEM.desc    = "Unique ID item for the " .. (k:Split(" ")[1] != "American" and k:Split(" ")[1] or "Enclave") .. " faction"
        ITEM.isID    = true
        ITEM.faction = v.faction
    end

    for k,v in pairs(IDCardsConfig.Religions) do
        local item = v.item

        local ITEM = nut.item.register(string.Replace(item.name:lower(), " ", "_"), nil, false, nil, true)
        ITEM.name        = item.name
        ITEM.model       = item.model
        ITEM.desc        = "Unique item for the " .. k .. " religion"
        ITEM.isReligious = true
        ITEM.religion    = k
    end
end
hook.Add("InitPostEntity", "IDCardInit", ItemInit)

if SERVER then
    hook.Add("PlayerLoadedChar", "IDCardsNetworkVars", function(ply, char, oldChar)
        for _,v in pairs(items) do
            local f = v.faction
            local id = "has" .. f .. "id"
            char:setData(id, char:getData(id) or false, nil, player.GetAll())
        end

        for _,p in pairs(player.GetAll()) do
            for _,v in pairs(items) do
                local f = v.faction
                local id = "has" .. f .. "id"

                local c = p:getChar()
                if c then
                    c:setData(id, c:getData(id) or false, nil, ply)
                end
            end
        end
    end)

    hook.Add("PlayerLoadedChar", "IDCardsNetworkVarsReligion", function(ply, char, oldChar)
        char:setData("hasreligion", char:getData("hasreligion", false) or false, nil, player.GetAll())
        char:setData("religion", char:getData("religion", "") or "", nil, player.GetAll())

        for _,p in pairs(player.GetAll()) do
            local c = p:getChar()

            if c then
                c:setData("hasreligion", c:getData("hasreligion", false) or false, nil, ply)
                c:setData("religion", c:getData("religion", "") or "", nil, ply)
            end
        end
    end)
end
