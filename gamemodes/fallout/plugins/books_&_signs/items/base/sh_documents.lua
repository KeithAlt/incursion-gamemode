local PLUGIN = PLUGIN

ITEM.name = "Document"
ITEM.desc = ""
ITEM.category = "Documents"
ITEM.model = ""
ITEM.width = 1
ITEM.height = 1

ITEM.functions["Read/Edit"] = {
    text = "Read/Edit",
    icon = "icon16/eye.png",
    onRun = function(item)
        local index = item:getID()

        local doc = PLUGIN.documents[index]

        if ( doc ) then
            netstream.Start(item.player, "foDocRead", index, (!doc.authorId or doc.authorId == item.player:getChar():getID()), doc.text)
        else
            netstream.Start(item.player, "foDocRead", index, true)
        end

        return false
    end,
    onCanRun = function(item)
        return true
    end
}

ITEM.functions.Rename = {
    text = "Rename",
    icon = "icon16/tag_blue_edit.png",
    onRun = function(item)
        netstream.Start(item.player, "foDocRnm", item:getID())

        return false
    end,
    onCanRun = function(item)
        if (CLIENT) then
            return IsValid(nut.gui.menu)
        end
        
        return true
    end
}

function ITEM:onSendData()
    local receiver = self.player
    local receiverChar = receiver:getChar() and receiver:getChar():getID()

    local index = self:getID()
    local title = PLUGIN.documents[index] and PLUGIN.documents[index].title
    local author = receiver:IsAdmin() and PLUGIN.documents[index] and PLUGIN.documents[index].author

    netstream.Start(receiver, "foDocData", index, title, author)
end

function ITEM:onRemoved()
    PLUGIN.documents[self:getID()] = nil
end

function ITEM:GetTitle()
    return "Document"
end

function ITEM:GetAuthor()
    return self.docAuthor
end

function ITEM:GetFormatTitle()
    return "<color=255, 153, 51>"..self:GetTitle().."</color>"
end

function ITEM:GetFormatAuthor()
    local author = self:GetAuthor()

    if ( author and LocalPlayer():IsAdmin() ) then
        return "Author: "..author
    else
        return ""
    end
end