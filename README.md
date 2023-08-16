# ☢️ Claymore Gaming's Incursion Gamemode ☢️
## Pre-requisite information:
**This project isn't maintained and is in archive mode.** This means that we (the original developers) will not provide any support on gamemode setup, issues, bugs, whatever it maybe - don't contact us about it. With that being said, we'll provide you some helpful instructions on possibly setting this up for yourself but understand _**this gamemode will not work out of the box.**_ We put in deliberate effort to make sure this gamemode couldn't be ran where we didn't want it to be. However, it has been setup before multiple times in-fact.
## Setup:
1. Insert gamemodes files into your Gmod server's directory of the same name
2. Insert addons files into your Gmod server's directory of the same name
3. Install the content pack addons on the server as well, as we assume this is present for _some_ assets:
   https://steamcommunity.com/sharedfiles/filedetails/?id=948435070
4. Scalp through and either remove the addons/gamemode file systems that utilize remote databases for functionality or set them up on your Cloud provider of choice.
I've replaced remote database connection credentials with "remote_db_..." placeholders across the codebase that you may replace if you so wish. **Beware,** we don't include any database setup/hiberation scripts. You'll need to manifest your inner Alan Touring to figure out the database structure for some of these systems. I frankly would suggest just removing them.
5. Launch the gamemode/server, scan for startup errors, and address them as they appear (because there will definitely be some)

This will require ample effort to get working. There are probably setup requirement related issues you'll encounter that aren't being mentioned here. It will be up to you to figure them out as you encounter them.