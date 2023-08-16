ITEM.name = "Sign" // This item is a duplicate of "sh_paper" due to being added to th server accidentally
ITEM.model = "models/props_lab/clipboard.mdl"
ITEM.desc = ""
ITEM.width = 1
ITEM.height = 1
ITEM.noBusiness = false
ITEM.price = 100

function ITEM:GetTitle()
    return self.docTitle or "Sign"
end
