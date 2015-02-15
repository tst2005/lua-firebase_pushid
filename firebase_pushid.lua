--[[--------------------------------------------------------
	-- Firebase PushID - A Lua implementation of Firebase PushID
	-- Copyright (c) 2014-2015 TsT tst005@gmail.com --
--]]--------------------------------------------------------

-- Sample of use:
--[[
local firebase_pushid = require("firebase_pushid")
local p1 = firebase_pushid() -- or firebase_pushid.new()
local p2 = firebase_pushid()
print( p1:next_id(), p2:next_id() )
for i=1,100,1 do
	print( p1:next_id() )
end
]]--

local random = {random = require("math").random } -- emul the pythonic random.random 
local int = require("math").floor
local time = { time = require("socket").gettime } -- like the pythonic time.time
local ValueError = error

local function __init__(self)
	-- Timestamp of last push, used to prevent local collisions if you
	-- pushtwice in one ms.
	self.lastPushTime = 0

	-- We generate 72-bits of randomness which get turned into 12
	-- characters and appended to the timestamp to prevent
	-- collisions with other clients.  We store the last characters
	-- we generated because in the event of a collision, we'll use
	-- those same characters except "incremented" by one.
	self.lastRandChars = {} -- table of 12 int
end

--[[
local cc2 = require("classcommons2.init") -- See https://github.com/tst2005/lua-classcommons2
local class, instance = cc2.class, cc2.instance

local PushID = class("PushID", {init = __init__})
local new = function() return instance(PushID) end}
]]--

-- minimal class system without external dependency
local PushID = {}
PushID.__index = PushID

local new = function()
	local i = setmetatable({}, PushID)
	__init__(i)
	return i
end


-- Modeled after base64 web-safe chars, but ordered by ASCII.
local PUSH_CHARS = ('-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz')

function PushID:next_id()
	local now = int(time.time() * 1000)
	local duplicateTime = (now == self.lastPushTime)
	self.lastPushTime = now
	local timeStampChars = {} -- table of 8 str

	for i = 7, -1, -1 do
		local n = now % 64 +1
		timeStampChars[i+1] = PUSH_CHARS:sub(n, n)
		now = int(now / 64)
	end

	if not (now == 0) then
		ValueError('We should have converted the entire timestamp.')
	end

	local uid = table.concat(timeStampChars, '')

	if not duplicateTime then
		for i = 1, 12 ,1 do
			self.lastRandChars[i] = int(random.random(0, 63))
		end
	else
		local i
		-- If the timestamp hasn't changed since last push, use the
		-- same random number, except incremented by 1.
		for j = 12, -1, -1 do
			if self.lastRandChars[j] == 63 then
				self.lastRandChars[j] = 0
			else
				i = j
				break
			end
		end
		self.lastRandChars[i] = (self.lastRandChars[i] or 0) + 1
	end

	for i = 1, 12, 1 do
		local n = (self.lastRandChars[i] or 0) +1
		uid = uid .. PUSH_CHARS:sub(n, n)
	end

	if not (#uid == 20) then
		ValueError('Length should be 20.')
	end
	return uid
end

return setmetatable({new = new}, { __call = new })
