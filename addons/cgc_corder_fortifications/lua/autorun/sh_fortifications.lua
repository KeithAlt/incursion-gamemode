FORTIFICATIONS = FORTIFICATIONS or {}

FORTIFICATIONS.Deployables = {

    ["Artillery Cannon"] = {
        mdl = "",
        desc = "A heavy artillery cannon capable of stopping power armored units with ease.",
        itemCost = 5    ,
        class = "fortification_cannon",
        limit = 1,
    },


    ["Slowing Net"] = {
        mdl = "",
        desc = "A strong net on the ground to slow down approaching enemies.",
        class = "fortification_net",
        itemCost = 2,
        limit = 2,
    },

    ["Barbed Wire"] = {
        mdl = "",
        desc = "Block off paths, prevent entry and force enemies through chokeholds.",
        class = "fortification_barbedwire",
        itemCost = 1,
        limit = 5,
    },

}

hook.Add("InitPostEntity", "FORTIFICATIONS_ItemCreation", function()
    local ITEM = nut.item.register("fortification_material", nil, false, nil, true)
	ITEM.name  = "Fortification Materials"
	ITEM.model = "models/clutter/conductor.mdl"
	ITEM.desc  = "A big crate with many components and materials which can be used to create fortifications like Artillery cannons, barbed wire and nets."
end)