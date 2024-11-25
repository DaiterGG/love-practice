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

local canvas = love.graphics.newCanvas(SCREEN_WIDTH, SCREEN_HEIGHT, { msaa = 16 })
local circle = {}
circle.pivot = {}
circle.pivot.x = SCREEN_WIDTH / 2
circle.pivot.y = SCREEN_HEIGHT / 2
circle.x = circle.pivot.x
circle.y = circle.pivot.y
circle.speed = {}
circle.speed.x = 0
circle.speed.y = 0

SPEED_MULTIPLIER = 1
AIR_FRICTION = 0.95

function DrawMain.load()
	love.graphics.setCanvas(self.canvas)
end

table.insert(KeyPressed, function(key, unicode)
	-- print(key)
	if key == "escape" then
		love.event.quit()
	end
	-- if key == "space" then
	-- local x, y = love.mouse.getPosition()
	-- canvas:renderTo(function()
	-- 	mainCircle(x, y)
	-- end)
	-- end
end)

table.insert(Update, function(dt)
	local xAcc = 0
	local yAcc = 0
	if love.mouse.isDown(1) then
		local x, y = love.mouse.getPosition()
		xAcc = (x - circle.x) * SPEED_MULTIPLIER
		yAcc = (y - circle.y) * SPEED_MULTIPLIER
	else
		xAcc = (circle.pivot.x - circle.x) * SPEED_MULTIPLIER
		yAcc = (circle.pivot.y - circle.y) * SPEED_MULTIPLIER
	end

	-- if love.keyboard.isDown("space") then

	-- else

	-- end

	circle.speed.x = (circle.speed.x + xAcc) * AIR_FRICTION
	circle.speed.y = (circle.speed.y + yAcc) * AIR_FRICTION
	circle.x = circle.x + circle.speed.x * dt
	circle.y = circle.y + circle.speed.y * dt

	canvas:renderTo(function()
		mainCircle(circle.x, circle.y)
	end)
end)

function DrawMain.draw()
	love.graphics.draw(canvas)
end

function mainCircle(w, h)
	love.graphics.clear()
	love.graphics.circle("fill", w, h, 50)
end

return DrawMain
