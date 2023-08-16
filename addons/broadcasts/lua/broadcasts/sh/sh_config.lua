BROADCASTS.Config.CacheRefreshTime = 1 -- How often distance checks are performed to determine if a player is within valid broadcast speaking range.
BROADCASTS.Config.BroadcastDistance = 150 ^ 2 -- The squared distance that a player must be within of a broadcast ent to count as a broadcaster. Square the value here.
BROADCASTS.Config.DefaultListenDistance = 300^2 --Default distance for radio listeners to tune in/out at.
BROADCASTS.Config.TransmissionCooldown = 120 -- Amount of time in seconds the player won't be forced to tune in or out of a broadcast by a transmitter entity

/* Uncomment if working with theme that does not involve nut
BROADCASTS.Config.Theme = {
    panel =  Color(0, 0, 0, 200),
    text = color_white,
    inactiveText = Color(200, 200, 200),
    gray = Color(175, 175, 175),
    darkgray = Color(80, 80, 80),
    red = Color(204, 31, 0),
    blue = Color(0, 31, 204),
    highlight = Color(255, 255, 255, 10)
}
*/

-- Added since nut is not declared till later
hook.Add("Think", "BroadcastConfigInit", function()
	if nut and nut.fallout and nut.fallout.color then
		BROADCASTS.Config.Theme = {
			panel = nut.fallout.color.background or Color(0, 0, 0, 200),
			text = nut.fallout.color.main or color_white,
			inactiveText = Color(200, 200, 200),
			gray = nut.fallout.color.main or Color(175, 175, 175),
			darkgray = nut.fallout.color.main or Color(80, 80, 80),
			red = Color(204, 31, 0),
			blue = Color(0, 31, 204),
			highlight = Color(255, 255, 255, 10)
		}

		hook.Remove("Think", "BroadcastConfigInit")
	end
end)

--Automatically assumes songs are in sound/falloutradio/
BROADCASTS.Config.SongList = BROADCASTS.Config.SongList or {
	--{title = "SongName", artist = "Name", file = "song.mp3"},
	{title = "16 Tons", artist = "Tennessee Ernie Ford", file = "16tons.mp3"},
	{title = "Big Iron", artist = "Marty Robbins", file = "bigiron.mp3"},
	{title = "The Master's Call", artist = "Marty Robbins", file = "masters_call.ogg"},
	{title = "Mr. Shorty", artist = "Marty Robbins", file = "mr_shorty.ogg"},
	{title = "World on Fire", artist = "The Ink Spots", file = "idontwanttosettheworldonfire.mp3"},
	{title = "It's all Over", artist = "The Ink Spots", file = "itsalloverbutthecrying.mp3"},
	{title = "Rain Must Fall", artist = "The Ink Spots", file = "rainmustfall.mp3"},
	{title = "Johnny Guitar", artist = "Peggy Lee", file = "johnnyguitar.mp3"},
	{title = "Do it Right", artist = "Peggy Lee", file = "do_it_right.mp3"},
	{title = "Blue Moon", artist = "Dean Martin", file = "bluemoon.mp3"},
	{title = "Kick In The Head", artist = "Dean Martin", file = "aintthatakickinthehead.mp3"},
	{title = "Mambo Italiano", artist = "Dean Martin", file = "mambo_italiano.ogg"},
	{title = "Can't Take My Eyes Off You", artist = "Frankie Valli", file = "eyes_off_of_you.ogg"},
	{title = "Fly Me to The Moon", artist = "Frank Sinatra", file = "fly_me_to_the_moon.ogg"},
	{title = "Love You Baby", artist = "Frank Sinatra", file = "love_you_baby.ogg"},
	{title = "My Way", artist = "Frank Sinatra", file = "my_way.ogg"},
	{title = "New York, New York", artist = "Frank Sinatra", file = "new_york.ogg"},
	{title = "Luck Be A Lady", artist = "Frank Sinatra", file = "luck_be_a_lady.ogg"},
	{title = "Something Stupid", artist = "Frank Sinatra", file = "something_stupid.ogg"},
	{title = "The Girl from Ipanema", artist = "Frank Sinatra", file = "the_girl_from_ipanema.ogg"},
	{title = "That's Life", artist = "Frank Sinatra", file = "thats_life.ogg"},
	{title = "Return to Sender", artist = "Elvis Presley", file = "return_to_sender.ogg"},
	{title = "Devil in Disguise", artist = "Elvis Presley", file = "devil_in_disguise.ogg"},
	{title = "Heartbreak Hotel", artist = "Elvis Presley", file = "heartbreak_hotel.ogg"},
	{title = "Jailhouse Rock", artist = "Elvis Presley", file = "jailhouse_rock.ogg"},
	{title = "Viva Las Vegas", artist = "Elvis Presley", file = "viva_las_vegas.ogg"},
	{title = "Wonderful World", artist = "Louis Armstrong", file = "wonderful_world.ogg"},
	{title = "A Kiss To Build A Dream On", artist = "Louis Armstrong", file = "akisstobuildadreamon.mp3"},
	{title = "Civilization", artist = "The Andrews Sisters", file = "civilization.mp3"},
	{title = "The Gun Was Loaded", artist = "The Andrews Sisters", file = "gunwasloaded.mp3"},
	{title = "Don't Fence Me In", artist = "Bing Crosby", file = "dontfencemein.mp3"},
	{title = "Gentle People", artist = "Bing Crosby", file = "gentlepeople.mp3"},
	{title = "Mister Sandman", artist = "The Chordettes", file = "sandman.ogg"},
	{title = "Smile", artist = "Jimmy Durante", file = "smile.ogg"},
	{title = "End of the World", artist = "Skeeter Davis", file = "endoftheworld.mp3"},
	{title = "Ain't Misbehavin", artist = "Fats Waller", file = "aintmisbehavin.mp3"},
	{title = "Anything Goes", artist = "Cole Porter", file = "anythinggoes.mp3"},
	{title = "Atom Bomb Baby", artist = "Five Stars", file = "atombombbaby.mp3"},
	{title = "Butcher Pete", artist = "Roy Brown", file = "butcherpete.mp3"},
	{title = "Country Roads", artist = "John Denver", file = "countryroads.mp3"},
	{title = "Crawlout", artist = "Sheldon Allman", file = "crawlout.mp3"},
	{title = "Crazy He Calls Me", artist = "Billie Holiday", file = "crazyhecallsme.mp3"},
	{title = "Fairweather Friend", artist = "Johnny Gill", file = "fairweatherfriend.mp3"},
	{title = "Heartaches by the Number", artist = "Ray Price", file = "heartachesbythenumber.mp3"},
	{title = "Jingle Jangle Jingle", artist = "Kay Kyser", file = "jinglejanglejingle.mp3"},
	{title = "Lonestar", artist = "Tony Marcus", file = "lonestar.mp3"},
	{title = "Ecstacy of Gold", artist = "Ennio Morricone", file = "ecstacy_of_gold.mp3"},
	{title = "Maybe", artist = "The Chantels", file = "maybe.mp3"},
	{title = "Mister Five by Five", artist = "Ella Mae", file = "mr5x5.mp3"},
	{title = "Orange Colored Sky", artist = "Nat King Cole", file = "orangecolouredsky.mp3"},
	{title = "Personality", artist = "Lloyd Price", file = "personality.mp3"},
	{title = "Pistol Packin' Mama", artist = "Bing Crosby", file = "pistolpackinmama.mp3"},
	{title = "Praise the Lord", artist = "Kay Kyser", file = "praisethelord.mp3"},
	{title = "Rocket 69", artist = "Connee Allen", file = "rocket69.mp3"},
	{title = "Sixty Minuteman", artist = "Billy Ward", file = "sixtyminuteman.mp3"},
	{title = "Uranium Fever", artist = "Elton Britt", file = "uraniumfever.mp3"},
	{title = "The Wanderer", artist = "Dion DiMucci", file = "wanderer.mp3"},
	{title = "Way Back Home", artist = "Bob Crosby", file = "waybackhome.mp3"},
	{title = "Wonderful Guy", artist = "Mitzi Gaynor", file = "wonderfulguy.mp3"},
	{title = "Hello Mister X", artist = "Gerhard Trede", file = "hellomrx.ogg"},
	{title = "Roundhouse Rock", artist = "Bert Weedon", file = "roundhouse_rock.ogg"},
	{title = "American Swing", artist = "Gerhard Trede", file = "american_swing.ogg"},
	{title = "It's a Sin", artist = "Eddy Arnold", file = "itsasin.ogg"},
	{title = "Goin' Under", artist = "Tommy Smith", file = "going_under.ogg"},
	{title = "Blues for You", artist = "Gabriel Pares", file = "blues_for_you.mp3"},
	{title = "I'm Movin' Out", artist = "The Roues Brothers", file = "im_movin_out.ogg"},
	{title = "Shadow of the Valley", artist = "Lost Weekend", file = "shadow_valley.ogg"},
	{title = "It's a Sin to Tell a Lie", artist = "Bill Kenny", file = "sin_to_lie.ogg"},
	{title = "Begin Again", artist = "Vera Keyes", file = "begin_again.mp3"},
	{title = "Nuka World", artist = "Nuka Cola Company", file = "nuka_world.ogg"},
	{title = "Concerto Grosso No.1", artist = "Unknown", file = "conerto_grosso_01.ogg"},
	{title = "Concerto Grosso No.2", artist = "Unknown", file = "conerto_grosso_02.ogg"},
	{title = "Flight of the Valkyries", artist = "Wilhelm Wagner", file = "valkyries.ogg"},
	{title = "Battle Hymn", artist = "The Enclave", file = "battle_hymn_of_republic.mp3"},
	{title = "Invicible Eagle", artist = "The Enclave", file = "invincible_eagle.mp3"},
	{title = "Johnny Comes Home", artist = "The Enclave", file = "johnny_comes_home.mp3"},
	{title = "Over There", artist = "The Enclave", file = "over_there.mp3"},
	{title = "National Anthem", artist = "The Enclave", file = "star_banner.mp3"},
}
