local Category = "SGM Cars (Fallout)"

local function HandlePHXAirboatAnimation( vehicle, ply )
	return ply:SelectWeightedSequence( ACT_DRIVE_AIRBOAT ) 
end


local V = {
				// Required information
				Name =	"Motorcycle",
				Class = "prop_vehicle_jeep",
				Category = Category,

				// Optional information
				Author = "SentryGunMan, Turn 10",
				Information = "vroom vroom",
				Model =	"models/sentry/fo4bike.mdl",

				KeyValues = {				
								vehiclescript =	"scripts/vehicles/sentry/fo4bike.txt"
					    },
	Members = {
		--HandleAnimation = HandlePHXAirboatAnimation,
	}
}

list.Set( "Vehicles", "fo4bike_sgm", V )