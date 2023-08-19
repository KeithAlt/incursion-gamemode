player_manager.AddValidModel( "Synth Generation 1", "models/arachnit/Fallout4/synths/SynthGeneration1.mdl" );
player_manager.AddValidModel( "Synth Generation 1 Player Model", "models/arachnit/Fallout4/synths/SynthGeneration1_pm.mdl" );

local Category = "Fallout 4 Synths"

local NPC = { 	Name = "Synth Generation 1", 
				Class = "npc_citizen",
				Model = "models/arachnit/Fallout4/synths/SynthGeneration1.mdl",
				Health = "40",
				KeyValues = { citizentype = 4 },
				Category = Category	}

list.Set( "NPC", "npc_synth_generation_1_f", NPC )