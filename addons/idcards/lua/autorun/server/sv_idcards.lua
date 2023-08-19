AddCSLuaFile("idcards_config.lua")
resource.AddSingleFile("materials/bosidlogo.png")
resource.AddSingleFile("materials/ncridlogo.png")
resource.AddSingleFile("materials/legionidlogo.png")
resource.AddSingleFile("materials/enclaveidlogo.png")
resource.AddSingleFile("materials/regiislogo.png")
resource.AddSingleFile("materials/tkclogo.png")

for k, religion in pairs(IDCardsConfig.Religions) do
    resource.AddSingleFile("materials/" .. religion.mat.path)
end

hook.Add("GetSalaryAmountExtra", "IDCards", function(pay, ply, faction)
    if !IDCardsConfig.Factions[faction.uniqueID] then return end

    for _,v in pairs(player.GetAll()) do
        if !IsValid(v) or !v:getChar() or v:Team() == faction.index then continue end

        for _,item in pairs(v:getChar():getInv():getItems()) do
            if item.isID and item.faction == faction.uniqueID then
                pay = pay + IDCardsConfig.Factions[faction.uniqueID]
                break
            end
        end
    end

    return pay
end)

hook.Add("CanItemBeTransfered", "IDCards", function(item, sourceInv, targetInv)
    if sourceInv.id == targetInv.id or !item.isID then return end

    local sourceChar = nut.char.loaded[sourceInv.owner]
    local targetChar = nut.char.loaded[targetInv.owner]

    if istable(targetChar) then
        targetChar:setData("has" .. item.faction .. "id", true, nil, player.GetAll())
    end

    if istable(sourceChar) then
        local amtOfID = 0

        if isfunction(sourceInv.getItems) then
            for _,i in pairs(sourceInv:getItems()) do
                if i.uniqueID == item.uniqueID then
                    amtOfID = amtOfID + 1
                end
            end
        end

        if amtOfID <= 1 then
            sourceChar:setData("has" .. item.faction .. "id", false, nil, player.GetAll())
        end
    end
end)

hook.Add("CanItemBeTransfered", "IDCardsReligion", function(item, sourceInv, targetInv)
    if sourceInv.id == targetInv.id or !item.isReligious then return end

    local sourceChar = nut.char.loaded[sourceInv.owner]
    local targetChar = nut.char.loaded[targetInv.owner]

    if istable(targetChar) then
        targetChar:setData("hasreligion", true, nil, player.GetAll())
        targetChar:setData("religion", item.religion, nil, player.GetAll())
    end

    if istable(sourceChar) then
        local amtOfID = 0

        if isfunction(sourceInv.getItems) then
            for _,i in pairs(sourceInv:getItems()) do
                if i.uniqueID == item.uniqueID then
                    amtOfID = amtOfID + 1
                end
            end
        end

        if amtOfID <= 1 then
            sourceChar:setData("hasreligion", false, nil, player.GetAll())
        end
    end
end)
