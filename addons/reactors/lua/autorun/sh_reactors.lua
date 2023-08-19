fusionConfig = {}
include("fusion_config.lua")

hook.Add("InitPostEntity", "ReactorRegister", function()
    nut.item.registerInv("reactor", fusionConfig.InvW, fusionConfig.InvH)

    local ITEM = nut.item.register("component_nuclear_material", nil, false, nil, true)
    ITEM.name    = "Nuclear Material"
    ITEM.model   = fusionConfig.MaterialModel
    ITEM.getDesc = function(self)
        return "A large lead lined container filled with radioactive material. Often used in the production of fusion cores.\n\n" .. self:getData("uses", fusionConfig.maxUses) .. " uses left"
    end

    ITEM = nut.item.register("fusion_core", nil, false, nil, true)
    ITEM.name  = "Fusion Core"
    ITEM.model = fusionConfig.CoreModel
    ITEM.desc  = "A densely packed source of energy, often used to fuel power armour."
end)