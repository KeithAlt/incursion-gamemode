local Category = "SGM Cars (Fallout)"

local V = {
				// Required information
				Name =	"APC",
				Class = "prop_vehicle_jeep",
				Category = Category,

				// Optional information
				Author = "SentryGunMan",
				Information = "vroom vroom",
				Model =	"models/sentry/apc_fo4.mdl",
 
                                           

				KeyValues = {				
								vehiclescript =	"scripts/vehicles/sentry/apc_fo4.txt"
					    }
}

list.Set( "Vehicles", "apc_fo4_sgm", V )