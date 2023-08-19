local Category = "SGM Cars"

local function HandlePHXAirboatAnimation( vehicle, ply )
	return ply:SelectWeightedSequence( ACT_DRIVE_AIRBOAT )
end

local V = {
				// Required information
				Name =	"Deathbike",
				Class = "prop_vehicle_jeep",
				Category = Category,

				// Optional information
				Author = "SentryGunMan, Turn 10",
				Information = "vroom vroom",
				Model =	"models/sentry/deathbike.mdl",

				KeyValues = {
								vehiclescript =	"scripts/vehicles/sentry/deathbike.txt"
					    },
	Members = {
		HandleAnimation = HandlePHXAirboatAnimation,
	}
}

list.Set( "Vehicles", "deathbike_sgm", V )
