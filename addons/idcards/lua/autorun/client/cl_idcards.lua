local function IDCardCheck(char)
    if char:getData("hasncrid") then
        return "ncr"
    elseif char:getData("hasbosid") then
        return "bos"
    elseif char:getData("haslegionid") then
        return "legion"
    elseif char:getData("hasenclaveid") then
        return "enclave"
	elseif char:getData("hasreegisid") then
		return "reegis"
	elseif char:getData("hasboomers_realid") then
		return "boomers_real"
	elseif char:getData("hastkcid") then
		return "tkc"
    end
end

local mats = {
    ["ncr"] = {
        ["mat"] = Material("ncridlogo.png"),
        ["size"] = {w = 113, h = 75}
    },
    ["legion"] = {
        ["mat"] = Material("legionidlogo.png"),
        ["size"] = {w = 64, h = 64}
    },
    ["bos"] = {
        ["mat"] = Material("bosidlogo.png"),
        ["size"] = {w = 96, h = 117}
    },
    ["enclave"] = {
        ["mat"] = Material("enclaveidlogo.png"),
        ["size"] = {w = 96, h = 96}
    },
	["reegis"] = {
		["mat"] = Material("regiislogo.png"),
		["size"] = {w = 75, h = 115}
	},
	["boomers_real"] = {
		["mat"] = Material("plalogo.png"),
		["size"] = {w = 113, h = 75}
	},
	["tkc"] = {
		["mat"] = Material("tkclogo.png"),
		["size"] = {w = 75, h = 115}
	}
}

for k,v in pairs(IDCardsConfig.Religions) do
    mats[k] = {
        ["mat"] = Material(v.mat.path),
        ["size"] = v.mat.size
    }
end

hook.Add("DrawEntityInfo", "IDCard", function(entity, alpha, position)
    if !entity:IsPlayer() or !entity:getChar() then return end

    local faction = IDCardCheck(entity:getChar())
    local religion = entity:getChar():getData("hasreligion", false) and entity:getChar():getData("religion", nil) or nil

    local factionPos
    local religionPos

    if faction and religion then
        local religionData = mats[religion]
        local factionData = mats[faction]
        local totalW = religionData.size.w + factionData.size.w

        factionPos = (entity:GetPos() + (entity:Crouching() and Vector(0, 0, 48) or Vector(0, 0, 80))):ToScreen()
        religionPos = table.Copy(factionPos)
        factionPos.x = factionPos.x - (totalW / 3)
        religionPos.x = religionPos.x + (totalW / 3)
    elseif religion then
        religionPos = (entity:GetPos() + (entity:Crouching() and Vector(0, 0, 48) or Vector(0, 0, 80))):ToScreen()
    elseif faction then
        factionPos = (entity:GetPos() + (entity:Crouching() and Vector(0, 0, 48) or Vector(0, 0, 80))):ToScreen()
    end

    if factionPos then
        surface.SetFont("nutSmallFont")
        local _, th = surface.GetTextSize(hook.Run("GetDisplayedName", entity) or "")
        factionPos.y = factionPos.y - th

        local data = mats[faction]

        local w, h = data.size.w, data.size.h
        surface.SetDrawColor(255, 255, 255, alpha)
        surface.SetMaterial(data.mat)
        surface.DrawTexturedRect(factionPos.x - w/2, factionPos.y - h, w, h)
    end

    if religionPos then
        surface.SetFont("nutSmallFont")
        local _, th = surface.GetTextSize(hook.Run("GetDisplayedName", entity) or "")
        religionPos.y = religionPos.y - th

        local data = mats[religion]

        local w, h = data.size.w, data.size.h
        surface.SetDrawColor(255, 255, 255, alpha)
        surface.SetMaterial(data.mat)
        surface.DrawTexturedRect(religionPos.x - w/2, religionPos.y - h, w, h)
    end
end)
