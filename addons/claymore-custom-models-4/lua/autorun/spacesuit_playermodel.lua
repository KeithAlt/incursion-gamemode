if SERVER then
	AddCSLuaFile()
	resource.AddFile("models/player/spacesuit.mdl")
	resource.AddFile("materials/models/spacesuit/spacesuit.vmt")
	resource.AddFile("materials/models/spacesuit/glove_d.vmt")
	resource.AddFile("materials/models/spacesuit/helmet_d.vmt")
	resource.AddFile("materials/models/spacesuit/outfitm_d.vmt")
end

local function AddPlayerModel( name, model )

	list.Set( "PlayerOptionsModel", name, model )
	player_manager.AddValidModel( name, model )
	
end

AddPlayerModel( "spacesuit", "models/player/spacesuit.mdl" )