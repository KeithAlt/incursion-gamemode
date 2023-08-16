              __                        ___ 
   ____ ___  / /   ____  ____ ______   |__ \
  / __  __ \/ /   / __ \/ __  / ___/   __/ /
 / / / / / / /___/ /_/ / /_/ (__  )   / __/ 
/_/ /_/ /_/_____/\____/\__, /____/   /____/ 
                      /____/                       
---------------------------------------------
		     INTEGRATION GUIDE
---------------------------------------------

mLogs 2 is based on categories and loggers. In a category there are many loggers to do with that category.

The folder "samplelogger" is an example of what a category should look like.
Categories are placed in mlogs/logger/loggers/ and you can view the default ones that come with mLogs 2.

The following is an explanation on how the system works, you should be able to figure it out without reading this if you
are familiar with glua but if not taking a read of this should help you understand it.

-- Guide --

Things to note:
- In your category folder you should have a file __category.lua which contains the definitions and category information.
- You must add a check to make sure the logger is only loaded when your addon is present

You can use the following options to format the data correctly:
- TYPE: function to use
- Player: mLogs.logger.getPlayerData(Player ply)
- Weapon: mLogs.logger.getWeaponData(Weapon wep)
- Vehicle: mLogs.logger.getVehicleData(Vehicle veh)
- Entity: mLogs.logger.getEntityData(Entity ent)
- World: mLogs.logger.getWorld()
- Unknown: mLogs.logger.getUnknown()

You can also store player position data, however use this on logs that don't spam as it is a lot of data to store:
- mLogs.logger.getPlayerPosData(Table players)
- The table should contain array of players (entities)
- e.g. {ply1,ply2}

-- What are definitions? --
Definitions are the way mLogs displays data to the client in a modular way.
They are a function that returns a table with all the data the client needs.

All loggers should use mLogs.doLogReplace(data) to convert their message into the proper format.
mLogs.doLogReplace(data) takes a table as an input with an array of strings. These can be normal strings or variables from the log table marked with an ^

For example, if a log is stored with the data {player1=mLogs.getPlayerData(ply)}, in the definition you could write {"^player1", "did something"}
The table is split with a space separator so you do not have to include spaces in the definition.

If you have any other questions or are confused feel free to open a support ticket.