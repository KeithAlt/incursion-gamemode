netstream.Hook("ns_changeclass_menu_confirm", function(client, selectedClass)
    -- Security checks
    if !IsValid(client) then return end
    if !client:getChar() then return end
    if !isnumber(selectedClass) then return end
    local classTable = nut.class.list[selectedClass]
    if !classTable then return end

    -- Check that the client faction allows him to change his class
    local clientFaction = client:getChar():getFaction()
    if (!clientFaction) then return end
    local clientFactionTable = nut.faction.indices[clientFaction]
    if (!clientFactionTable) then return end
    if (!clientFactionTable.CanClassChange) then return end

    -- Try to join class
    if (client:getChar():joinClass(selectedClass)) then
        client:notifyLocalized("becomeClass", L(classTable.name, client))

        return
    else
        client:notifyLocalized("becomeClassFail", L(classTable.name, client))

        return
    end
end)