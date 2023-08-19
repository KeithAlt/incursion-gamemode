-- MySQL is a type of database that you can use to store data. If you don't care about sharing data across servers or using the data on things like websites then you should just leave this file alone.
-- Should data be stored to a remote SQL databse?
noSayBlacklist.Database.UseMySQL = false

noSayBlacklist.Database.Creds = {}
noSayBlacklist.Database.Creds.ip = "ip.ip.ip.ip" -- The IP of the database server
noSayBlacklist.Database.Creds.user = "database_user" -- The MySQL user for your connecting user
noSayBlacklist.Database.Creds.password = "pa$$w0rd" -- The password for said user
noSayBlacklist.Database.Creds.database = "database_database" -- The database to create the tables in
noSayBlacklist.Database.Creds.port = 3306 -- This probably doesn't need changing

-- This is used to allow you to store all your NoSay tables in the same database under unique names. Or to be used to share tables across multiple servers.
-- If you want all your server to have unique strikes, you should give each server a unique identity. Ensure it is all lowercase with no special characters or spaces.
-- If the database you're using is the main one for your server, simply leave this as `nosay`
noSayBlacklist.Database.Identity = "nosay"