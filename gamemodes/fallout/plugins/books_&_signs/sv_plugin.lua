local PLUGIN = PLUGIN

hook.Add("InitializedPlugins", "forp_books_&_signs_data", function()
    local path = "nutscript/"..SCHEMA.folder.."/books_&_signs.txt"
    local status, decoded = pcall(pon.decode, file.Read(path, "DATA"))

    local tbl

	if (status and decoded) then
		local value = decoded[1]

		if (value != nil) then
			tbl = value
		else
			tbl = {}
		end
	else
		tbl = {}
    end
    
    PLUGIN.documents = tbl
end)

hook.Add("ShutDown", "forp_books_&_signs_data2", function()
    local path = "nutscript/"..SCHEMA.folder.."/books_&_signs.txt"
	file.CreateDir("nutscript/"..SCHEMA.folder.."/")
    
    file.Write( path, pon.encode({PLUGIN.documents}) )
end)

netstream.Hook("foDocRnm", function(client, index, title)
    local item = nut.item.instances[index]

    if (item and item.base == "base_documents" and item:getOwner() == client)  then
        PLUGIN.documents[index] = PLUGIN.documents[index] or {}
        PLUGIN.documents[index].title = title
        netstream.Start(client, "foDocTitle", index, title)
    end
end)

netstream.Hook("foDocWrite", function(client, index, content)
    local char = client:getChar()
    if (!char) then return end
    local inventory = char:getInv()

    local item = nut.item.instances[index]

    if (item && item.base == "base_documents") then

        if (item.entity) then
            if (item.entity:GetPos():Distance(client:GetPos()) > 96) then
                return
            end
        elseif (!inventory:getItemByID(index)) then
            return
        end

        PLUGIN.documents[index] = PLUGIN.documents[index] or {}

        if ( PLUGIN.documents[index].authorId ) then
            if ( PLUGIN.documents[index].authorId != char:getID() ) then return end
        else
            PLUGIN.documents[index].authorId = char:getID()
            PLUGIN.documents[index].author = char:getName()
        end

        PLUGIN.documents[index].text = content

        if (inventory:getItemByID(index)) then
            netstream.Start(client, "foDocAuthor", index)
        end
    end
end)