--[[-----------------------------------
AUTHOR: dougRiss
DATE: 11/7/2014
PURPOSE: Generate content for players 
who are new to the server - this is also
where you configure what said content is
--]]-----------------------------------
include("config.lua")

function generateBooks()
	if(GEN_STARTER_BOOKS) then 
		if(!file.IsDir("goodreads/book", "DATA")) then
			file.CreateDir("goodreads/book")
		end
		
		--[[Use the following template to generate custom content]]--
		
		filename = "default" --change this every time
		if(!file.Exists("/goodreads/book/"..filename..".txt", "DATA")) then  --leave this alone
			book = {
				name = "Book Title", --make 100% sure there is a comma there.
				text = "Book Contents" --you can use [[Book Contents]] to make multi-lined strings
				}
			file.Write("goodreads/book/"..filename..".txt", util.TableToKeyValues(book))
			if(DEBUGGING_MODE) then print("Default content added: book/"..filename..".txt") end
		end

	end
end

function generateSigns()
	if(GEN_STARTER_SIGNS) then
		if(!file.IsDir("goodreads/book", "DATA") )then
			file.CreateDir("goodreads/book")
		end
		
		--[[Use the following template to generate custom content]]--
		
		filename = "default"
		if(!file.Exists("/goodreads/sign/"..filename..".txt", "DATA")) then 
			sign = {
				name = "Sign Title",
				text = "Sign Contents"
				}
			file.Write("goodreads/sign/"..filename..".txt", util.TableToKeyValues(sign))
			if(DEBUGGING_MODE) then print("Default content added: sign/"..filename..".txt") end
		end
			
	end
end