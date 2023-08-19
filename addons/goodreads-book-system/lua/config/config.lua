--[[-----------------------------------
AUTHOR: dougRiss
DATE: 11/7/2014
PURPOSE: Allow the configuration of the
mod for a more unique experience or 
whatever.
--]]-----------------------------------

--Server Admins do not subscribe to server limits.
ADMIN_IGNORE = false 

--allow players to save signs and books they do not own
ALLOW_SAVE_ON_VIEW = false

--allow what modules players can use
ALLOW_SIGNS = true
ALLOW_BOOKS = true
ALLOW_NOTES = true

--generate prefabricated content for new users (config/default_content.lua configures said content)
GEN_STARTER_BOOKS = true
GEN_STARTER_SIGNS = true

--Turn on debugging, making almost every function print something so you can follow steps.
DEBUGGING_MODE = false

--Maximum amount of signs a player can have at once.
MAX_SIGNS = 5 
MAX_BOOKS = 5
MAX_NOTES = 5

--maximum and minimum number of characters allowed in a sign, 0 means no limit
MAX_SIGN_CHARACTERS = 512
MAX_BOOK_CHARACTERS = 512
MAX_NOTE_CHARACTERS = 60 --sticky notes are hard limited to <= 160 characters
-------------------
MIN_SIGN_CHARACTERS = 0
MIN_BOOK_CHARACTERS = 0
MIN_NOTE_CHARACTERS = 0

--network strings to use for each entity type. It is strongly recommended you leave this be.
NW_STRING_BOOK = "nwstrbook"
NW_STRING_SIGN = "nwstrsign"
NW_STRING_NOTE = "nwstrnote"
--TODO: More