local Category = "SGM Cars (Fallout)"

local V = {
				// Required information
				Name =	"HMMWV",
				Class = "prop_vehicle_jeep",
				Category = Category,

				// Optional information
				Author = "SentryGunMan, Turn 10",
				Information = "vroom vroom",
				Model =	"models/sentry/humvee_fo3.mdl",

				KeyValues = {				
								vehiclescript =	"scripts/vehicles/sentry/humvee_fo3.txt"
					    }
}

list.Set( "Vehicles", "humvee_fo3_sgm", V )