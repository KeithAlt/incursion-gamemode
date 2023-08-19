AddCSLuaFile("cook_config.lua")
foCook = foCook or {}
foCook.Config = foCook.Config or {}
include("cook_config.lua")

foCook.Ingredients = {
    ["ant_meat"] = {
        ["name"] = "Ant Meat",
        ["desc"] = "",
        ["model"] = "models/fallout 3/ant_meat.mdl",
        ["amt"] = 15
    },
    ["beans"] = {
        ["name"] = "Uncooked Beans",
        ["desc"] = "",
        ["model"] = "models/fallout 3/beans.mdl",
        ["amt"] = 15
    },
    ["human_flesh"] = {
        ["name"] = "Human Flesh",
        ["desc"] = "",
        ["model"] = "models/fallout 3/human_meat.mdl",
        ["amt"] = 15,
        ["rads"] = 5
    },
    ["brahman_meat"] = {
        ["name"] = "Raw Brahman Meat",
        ["desc"] = "",
        ["model"] = "models/fallout 3/meat.mdl",
        ["amt"] = 15
    },
    ["mole_meat"] = {
        ["name"] = "Raw Mole Meat",
        ["desc"] = "",
        ["model"] = "models/fallout 3/mole_meat.mdl",
        ["amt"] = 15
    },
    ["radroach_meat"] = {
        ["name"] = "Radroach Meat",
        ["desc"] = "",
        ["model"] = "models/fallout 3/radroach_meat.mdl",
        ["amt"] = 15
    }
}

foCook.Foods = {
    ["c_ant_meat"] = {
        ["name"] = "Cooked Ant Meat",
        ["desc"] = "Provides +1 STR, +1 END, +1 AGL for 5 minutes.",
        ["model"] = "models/fallout 3/ant_meat.mdl",
        ["amt"] = 20,
        ["time"] = 30,
        ["recipe"] = {
            ["ant_meat"] = 1
        },
        ["onUse"] = function(item, ply, quality)
            if SERVER then
                local multi = foCook.Config.Multipliers[quality]
                ply:BuffStat("S", 1, 300 * multi, true)
                ply:BuffStat("E", 1, 300 * multi, true)
                ply:BuffStat("A", 1, 300 * multi, true)
				ply:EmitSound("ui/aid" .. math.random(3) .. ".wav")
            end
        end
    },
    ["c_beans"] = {
        ["name"] = "Cooked Beans",
        ["desc"] = "Provides +1 STR, +1 END, +1 AGL for 5 minutes.",
        ["model"] = "models/fallout 3/beans.mdl",
        ["amt"] = 20,
        ["time"] = 30,
        ["recipe"] = {
            ["beans"] = 1
        },
        ["onUse"] = function(item, ply, quality)
            if SERVER then
                local multi = foCook.Config.Multipliers[quality]
                ply:BuffStat("S", 1, 300 * multi, true)
                ply:BuffStat("E", 1, 300 * multi, true)
                ply:BuffStat("A", 1, 300 * multi, true)
				ply:EmitSound("ui/aid" .. math.random(3) .. ".wav")
            end
        end
    },
    ["c_human_flesh"] = {
        ["name"] = "Cooked Human Flesh",
        ["desc"] = "Provides +1 STR, +1 END, +1 AGL for 5 minutes.",
        ["model"] = "models/fallout 3/human_meat.mdl",
        ["amt"] = 20,
        ["time"] = 30,
        ["recipe"] = {
            ["human_flesh"] = 1
        },
        ["onUse"] = function(item, ply, quality)
            if SERVER then
                local multi = foCook.Config.Multipliers[quality]
                ply:BuffStat("S", 1, 300 * multi, true)
                ply:BuffStat("E", 1, 300 * multi, true)
                ply:BuffStat("A", 1, 300 * multi, true)
				ply:addKarma(5, 2)
				ply:falloutNotify("You have lost karma for consuming Human Flesh", "ui/notify.mp3")
				ply:EmitSound("ui/aid" .. math.random(3) .. ".wav")
            end
        end
    },
    ["steak"] = {
        ["name"] = "Steak", --
        ["desc"] = "Provides +1 STR, +1 END, +1 AGL for 5 minutes.",
        ["model"] = "models/fallout 3/steak.mdl",
        ["amt"] = 20,
        ["time"] = 30,
        ["recipe"] = {
            ["brahman_meat"] = 1
        },
        ["onUse"] = function(item, ply, quality)
            if SERVER then
                local multi = foCook.Config.Multipliers[quality]
                ply:BuffStat("S", 1, 300 * multi, true)
                ply:BuffStat("E", 1, 300 * multi, true)
                ply:BuffStat("A", 1, 300 * multi, true)
				ply:EmitSound("ui/aid" .. math.random(3) .. ".wav")
            end
        end
    },
    ["c_mole_meat"] = {
        ["name"] = "Cooked Mole Meat",
        ["desc"] = "Provides +1 STR, +1 END, +1 AGL for 5 minutes.",
        ["model"] = "models/fallout 3/steak.mdl",
        ["amt"] = 20,
        ["time"] = 30,
        ["recipe"] = {
            ["mole_meat"] = 1
        },
        ["onUse"] = function(item, ply, quality)
            if SERVER then
                local multi = foCook.Config.Multipliers[quality]
                ply:BuffStat("S", 1, 300 * multi, true)
                ply:BuffStat("E", 1, 300 * multi, true)
                ply:BuffStat("A", 1, 300 * multi, true)
				ply:EmitSound("ui/aid" .. math.random(3) .. ".wav")
            end
        end
    },
    ["c_radroach_meat"] = {
        ["name"] = "Cooked Radroach Meat",
        ["desc"] = "Provides +1 STR, +1 END, +1 AGL for 5 minutes.",
        ["model"] = "models/fallout 3/radroach_meat.mdl",
        ["amt"] = 20,
        ["time"] = 30,
        ["recipe"] = {
            ["radroach_meat"] = 1
        },
        ["onUse"] = function(item, ply, quality)
            if SERVER then
                local multi = foCook.Config.Multipliers[quality]
                ply:BuffStat("S", 1, 300 * multi, true)
                ply:BuffStat("E", 1, 300 * multi, true)
                ply:BuffStat("A", 1, 300 * multi, true)
				ply:EmitSound("ui/aid" .. math.random(3) .. ".wav")
            end
        end
    },
}

hook.Add("InitializedPlugins", "CookInit", function()
    for k, v in pairs(foCook.Foods) do
        v.uniqueID = k

        local ITEM = nut.item.register(k, "base_jonjo_food", false, nil, true)
        ITEM.name    = v.name
        ITEM.model   = v.model
        ITEM.amt = v.amt
        ITEM.rads = v.rads
        ITEM.getDesc = function(item)
            return v.desc .. "\nConcocted by a " .. foCook.Config.SkillLevels[item:getData("quality", 0)]
        end
        ITEM:hook("Use", function(item)
            v.onUse(item, item.player, item:getData("quality", 0))

            if SERVER then
                net.Start("CookUse")
                    net.WriteString(k)
                net.Send(item.player)
            end
        end)
    end

    for k, v in pairs(foCook.Ingredients) do
        local ITEM = nut.item.register(k, "base_jonjo_food", false, nil, true)
        ITEM.name    = v.name
        ITEM.model   = v.model
        ITEM.amt = v.amt
        ITEM.rads = v.rads
        ITEM.desc    = v.desc
    end
end)
