print("")
KeyPressed = {}
KeyReleased = {}
Update = {}

local draw = require("draw")
---@class love
local love = require("love")
require("bug")

function love.load()
	draw:load()
end

function love.draw()
	draw:draw()
end

function love.keypressed(key, unicode)
	for _, fn in pairs(KeyPressed) do
		fn(key, unicode)
	end
end

function love.keyreleased(key)
	for _, fn in pairs(KeyReleased) do
		fn(key)
	end
end

function love.update(dt)
	for _, fn in pairs(Update) do
		fn(dt)
	end
end
