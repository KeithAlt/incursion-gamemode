AddCSLuaFile("wrarity_config.lua")
wRarity = wRarity or {}
wRarity.Config = wRarity.Config or {}
include("wrarity_config.lua")

for i = 1, #wRarity.Config.Rarities do --Assign index value to each rarity
    wRarity.Config.Rarities[i].index = i
end

wRarity.Print = jlib.GetPrintFunction("[wRarity]", Color(255, 216, 41, 255))
function wRarity.ConsoleLog(str, force) --General logging
    if !wRarity.debug and !force then
        return
    end

    wRarity.Print(str)
end

--Debug commands
local function printRarityFixed(name, item, rarity)
    local curRarity = math.Clamp(item:getData("rarity", 1), 1, #wRarity.Config.Rarities)
    wRarity.ConsoleLog(name .. " had wrong rarity set changing it from " .. wRarity.Config.Rarities[curRarity].name .. "(" .. curRarity .. ")" .. " to " .. rarity.name .. "(" .. rarity.index .. ")", true)
end

hook.Add("InitPostEntity", "wRarityCommands", function()
    if wRarity.debug then
        nut.command.add("givewepofrarity", {
            superAdminOnly = true,
            syntax = "<string uniqueID> <integer rarity>",
            onRun = function(ply, args)
                local wep = args[1]

                if !wep then return end

                local rarity = args[2] and wRarity.Config.Rarities[tonumber(args[2])] or wRarity.GetRarity(ply)

                wRarity.CreateItem(ply:getChar():getInv(), wep, rarity)
            end
        })

        nut.command.add("givecraftingmats", {
            superAdminOnly = true,
            onRun = function(ply, args)
                local materials = nut.crafting.recipes.weapons[args[1]].materials

                for k,v in pairs(materials) do
                    for i = 1, v do
                        ply:getChar():getInv():add(k)
                    end
                end
            end
        })
    end

    nut.command.add("fixweaponrarities", {
        onRun = function(ply, args)
            local char = ply:getChar()
            if !char then return end

            local inv = char:getInv()
            local weapons = {}

            for k, item in pairs(inv:getItems()) do
                if item.isSwep then
                    table.insert(weapons, item)
                end
            end

            for _, item in pairs(weapons) do
                local name = item:getData("name", item.name)

                wRarity.ConsoleLog("Checking " .. item:getName() .. " for incorrect rarity for " .. ply:Nick(), true)

                if name != item.name then
                    local found = false

                    for k, rarity in pairs(wRarity.Config.Rarities) do
                        if name:StartWith(rarity.name) then
                            if item:getData("rarity", 0) != k then
                                printRarityFixed(name, item, rarity)
                                item:setData("rarity", k)
                            end

                            found = true
                            break
                        end
                    end

                    if !found and item:getData("rarity", 0) != #wRarity.Config.Rarities then --The name is not the default item name nor does it start with any of the rarity names, must be a legendary with a custom name.
                        printRarityFixed(name, item, wRarity.Config.Rarities[#wRarity.Config.Rarities])
                        item:setData("rarity", #wRarity.Config.Rarities)
                    end
                end
            end
        end
    })
end)
