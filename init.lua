--[[--------------------------------------------------------
	-- Firebase PushID - A Lua implementation of Firebase PushID
	-- Copyright (c) 2014-2015 TsT tst005@gmail.com --
--]]--------------------------------------------------------

local path = (... or ""):gsub("%.init$", "")
path = path ~= "" and path.."." or ""
return require(path .. "firebase_pushid")

