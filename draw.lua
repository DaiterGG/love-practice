local love = require("love")
-- local Math = require("math")
local DrawMain = {}
DrawMain.__index = DrawMain

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600

local self = {}
function DrawMain.new()
	setmetatable(self, DrawMain)
	return self
end

local currentCanvas
local otherCanvas
local lastPoint = {
	x = SCREEN_WIDTH / 2,
	y = SCREEN_HEIGHT / 2,
}
local img = love.graphics.newImage(love.filesystem.newFileData("assets/water.jpg"))

local myShader = love.graphics.newShader("shader.frag.shader")
local myTrail = love.graphics.newShader("trail.frag.shader")

SPEED_MULTIPLIER = 1
AIR_FRICTION = 0.95

function DrawMain.load()
	currentCanvas = love.graphics.newCanvas(SCREEN_WIDTH, SCREEN_HEIGHT, { msaa = 16 })

	love.graphics.setCanvas()
	currentCanvas:renderTo(function() end)
end

table.insert(KeyPressed, function(key)
	if key == "f1" then
		debug.debug()
	elseif key == "escape" then
		love.event.quit()
	end
end)

table.insert(Update, function()
	myShader:send("time", love.timer.getTime())
end)

function DrawMain.draw()
	love.graphics.setShader(myShader)

	-- love.graphics.setShader()
	-- love.graphics.setColor(0, 0, 0, 1)
	-- love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
	-- love.graphics.setColor(1, 0, 0, 1)
	love.graphics.setColor(1, 1, 1, 1)
	currentCanvas:renderTo(function()
		love.graphics.clear()
		-- love.graphics.circle("fill", circle.x, circle.y, 50)
		-- love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
		love.graphics.draw(img, 0, 0, 0, 1, 1)
	end)
	love.graphics.draw(currentCanvas)
	love.graphics.setColor(1, 1, 1, 1)
end

return DrawMain
