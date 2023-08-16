IDCardsConfig.Factions = { --The factions that will receive a salary bonus for their respective ID items
    ["ncr"] = 5, --How large the bonus is for each player that is holding a ncr ID item
	["reegis"] = 1, -- Custom Faction
    ["bos"] = 0,
    ["legion"] = 0,
    ["enclave"] = 0,
	["boomers_real"] = 0
}

IDCardsConfig.Religions = {
    ["The Mormon Church"] = {
        ["mat"] = {
            ["path"] = "religions/mormon_church.png",
            ["size"] = {w = 64, h = 64}
        },
        ["item"] = {
            ["name"] = "Mormon Church Bible",
            ["model"] = "models/props_lab/binderredlabel.mdl"
        }
    },
    ["Followers of the Apocalypse"] = {
        ["mat"] = {
            ["path"] = "religions/followers.png",
            ["size"] = {w = 64, h = 64}
        },
        ["item"] = {
            ["name"] = "Followers of the Apocalypse Principle",
            ["model"] = "models/clutter/bookdcjournal.mdl"
        }
    },
    ["Cult of Mars"] = {
        ["mat"] = {
            ["path"] = "religions/cult_of_mars.png",
            ["size"] = {w = 64, h = 64}
        },
        ["item"] = {
            ["name"] = "Cult of Mars Cultist Token",
            ["model"] = "models/maxib123/legionmoney1.mdl"
        }
    },
    ["Children of the Cathedral"] = {
        ["mat"] = {
            ["path"] = "religions/children_of_the_cathedral.png",
            ["size"] = {w = 64, h = 64}
        },
        ["item"] = {
            ["name"] = "Children of the Cathedral Badge",
            ["model"] = "models/clutter/harmonica.mdl"
        }
    },
    ["Children of the Cathedral"] = {
        ["mat"] = {
            ["path"] = "religions/children_of_the_cathedral.png",
            ["size"] = {w = 64, h = 64}
        },
        ["item"] = {
            ["name"] = "Children of the Cathedral Badge",
            ["model"] = "models/clutter/harmonica.mdl"
        }
    },
    ["Children of Atom"] = {
        ["mat"] = {
            ["path"] = "religions/children_of_atom.png",
            ["size"] = {w = 64, h = 64}
        },
        ["item"] = {
            ["name"] = "Children of Atom Charm",
            ["model"] = "models/maxib123/tags.mdl"
        }
    },
    ["Kiyya"] = {
        ["mat"] = {
            ["path"] = "religions/kiyya.png",
            ["size"] = {w = 64, h = 64}
        },
        ["item"] = {
            ["name"] = "Blessing of Kiyya",
            ["model"] = "models/maxib123/tags.mdl"
        }
    },
	["Cyber Initiative Charm"] = {
		["mat"] = {
			["path"] = "factionicons/cyber_initative.png",
			["size"] = {w = 64, h = 64}
		},
		["item"] = {
			["name"] = "Cyber Charm",
			["model"] = "models/maxib123/tags.mdl"
		}
	}
}
