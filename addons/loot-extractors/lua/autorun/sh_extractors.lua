extractorsConfig = {}
include("extractors_config.lua")

hook.Add("InitPostEntity", "RegisterExtractorInv", function()
    nut.item.registerInv("extractor", extractorsConfig.InvW, extractorsConfig.InvH)
end)