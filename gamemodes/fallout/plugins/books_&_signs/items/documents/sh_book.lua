ITEM.name = "Book"
ITEM.model = "models/props_lab/binderblue.mdl"
ITEM.desc = ""
ITEM.width = 1
ITEM.height = 1
ITEM.noBusiness = false
ITEM.price = 100

function ITEM:GetTitle()
    return self.docTitle or "Book"
end