local Category = "SGM Cars (Fallout)"

local V = {
				// Required information
				Name =	"Fallout Chrysalis Highwayman",
				Class = "prop_vehicle_jeep",
				Category = Category,

				// Optional information
				Author = "SentryGunMan",
				Information = "vroom vroom",
				Model =	"models/sentry/highwayman.mdl",
 
				KeyValues = {				
								vehiclescript =	"scripts/vehicles/sentry/highwayman.txt"
					    }
}

list.Set( "Vehicles", "highwayman_sgm", V )