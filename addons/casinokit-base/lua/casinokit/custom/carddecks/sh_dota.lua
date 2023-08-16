local DECK = {}

DECK.backMaterials = {}
DECK.frontMaterials = {}

local fetching = false
function DECK.fetch()
	if fetching then return end
	fetching = true

	CasinoKit.getRemoteMaterial("http://i.imgur.com/ztiBatU.jpg", function(remoteMat)
		local offX, offY = 0.005, 0.003
		local cardW, cardH = 0.1234, 0.1419

		local suitNames = {"Spades", "Clubs", "Diamonds", "Hearts"}

		for row=1, 7 do
			local maxCol = row == 7 and 4 or 8
			for col=1, maxCol do
				local suitIdx = (col-1)%4
				local rankIdx = (row-1)*2 + math.floor((col-1)/4)

				local suit = CasinoKit.classes.Suit[ suitNames[suitIdx+1] ]
				local rank = CasinoKit.classes.Rank.valueList[rankIdx+1]

				local mat = CreateMaterial("CasinoKit_card_" .. tostring(suit) .. "x" .. tostring(rank) .. "_" .. CurTime(), "UnlitGeneric", {["$translucent"] = "1"})
				mat:SetTexture("$basetexture", remoteMat:GetTexture("$basetexture"))

				local matrix = Matrix()
				matrix:SetScale(Vector(cardW, cardH, 1))
				matrix:SetTranslation(Vector(offX + cardW*(col-1), offY + cardH*(row-1), 0))
				mat:SetMatrix("$basetexturetransform", matrix)

				if suit and rank then
					DECK.frontMaterials[suit] = DECK.frontMaterials[suit] or {}
					DECK.frontMaterials[suit][rank] = mat
				else
					table.insert(DECK.backMaterials, mat)
				end

			end
		end
	end)
end

CasinoKit.registerCardDeck("dota", DECK)


--[[
CasinoKit.getRemoteMaterial("http://i.imgur.com/ztiBatU.jpg", function(mat)
	local offX, offY = 0.005, 0.003
	local cardW, cardH = 0.1234, 0.1419

	local suitNames = {"Spades", "Clubs", "Diamonds", "Hearts"}

	for row=1, 7 do
		local maxCol = row == 7 and 4 or 8
		for col=1, maxCol do
			local suitIdx = (col-1)%4
			local rankIdx = (row-1)*2 + math.floor((col-1)/4)

			local suit = CasinoKit.classes.Suit[ suitNames[suitIdx+1] ]

			local rank = CasinoKit.classes.Rank.valueList[rankIdx+1]

			if suit and rank then
				local id = suit.name .. "p" .. rank.name
				cardmats[id] = CreateMaterial("CasinoKit_card_" .. id .. "_" .. CurTime(), "UnlitGeneric", {})
				cardmats[id]:SetTexture("$basetexture", mat:GetTexture("$basetexture"))

				local mat = Matrix()
				mat:SetScale(Vector(cardW, cardH, 1))
				mat:SetTranslation(Vector(offX + cardW*(col-1), offY + cardH*(row-1), 0))
				cardmats[id]:SetMatrix("$basetexturetransform", mat)
			end
		end
	end
end)
]]
