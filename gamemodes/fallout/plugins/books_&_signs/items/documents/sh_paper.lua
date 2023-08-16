ITEM.name = "Sign"
ITEM.model = "models/props_lab/clipboard.mdl"
ITEM.desc = ""
ITEM.width = 1
ITEM.height = 1
ITEM.noBusiness = false
ITEM.price = 100

function ITEM:GetTitle()
    return self.docTitle or "Sign"
end