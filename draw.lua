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
local img = love.graphics.newImage(love.filesystem.newFileData("assets/circle.png"))

local myShader = love.graphics.newShader("shader.frag.shader")
local myTrail = love.graphics.newShader("trail.frag.shader")
local circle = {
	pivot = {
		x = SCREEN_WIDTH / 2,
		y = SCREEN_HEIGHT / 2,
	},
	speed = {
		x = 0,
		y = 0,
	},
}
circle.x = circle.pivot.x
circle.y = circle.pivot.y

SPEED_MULTIPLIER = 1
AIR_FRICTION = 0.95

-- (abs(sin((screen_coords.x + screen_coords.y) / 70)) * abs(cos(screen_coords.y / 50))) * .7 + .5,
-- (abs(sin(screen_coords.x / 45)) * abs(cos((screen_coords.x + screen_coords.y / 2) / 56))) * .7 + .5,
-- (abs(cos(screen_coords.x / 40)) * abs(sin((screen_coords.x + screen_coords.y) / 80))) * .7 + .5,
function DrawMain.load()
	currentCanvas = love.graphics.newCanvas(SCREEN_WIDTH, SCREEN_HEIGHT, { msaa = 16 })
	otherCanvas = love.graphics.newCanvas(SCREEN_WIDTH, SCREEN_HEIGHT, { msaa = 16 })

	love.graphics.setCanvas()
	currentCanvas:renderTo(function() end)

	-- myShader:send("text", img)
	-- myShader:send("SCREEN_WIDTH", SCREEN_WIDTH)
	-- myShader:send("SCREEN_HEIGHT", SCREEN_HEIGHT)
end

table.insert(KeyPressed, function(key)
	if key == "f1" then
		debug.debug()
	elseif key == "escape" then
		love.event.quit()
	end
end)

local function mainCircle(w, h)
	love.graphics.draw(img, w - 50, h - 50, 0, 0.2, 0.2)
end

local mouseParticles = {}

table.insert(Update, function(dt)
	myShader:send("time", love.timer.getTime())
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

	circle.speed.x = (circle.speed.x + xAcc) * AIR_FRICTION
	circle.speed.y = (circle.speed.y + yAcc) * AIR_FRICTION
	circle.x = circle.x + circle.speed.x * dt
	circle.y = circle.y + circle.speed.y * dt

	local p = {}
	p.x = circle.x
	p.y = circle.y
	mouseParticles[#mouseParticles + 1] = p

	local dx = p.x - lastPoint.x
	local dy = p.y - lastPoint.y
	local dist = math.sqrt(dx * dx + dy * dy)

	---if there is a gap, fill it
	if dist > 1 then
		local angle = math.atan2(dy, dx)
		local cosine = math.cos(angle)
		local sine = math.sin(angle)
		for i = 1, dist, 1 do
			local p2 = {}
			p2.x = lastPoint.x + i * cosine
			p2.y = lastPoint.y + i * sine
			mouseParticles[#mouseParticles + 1] = p2
		end
	end

	lastPoint.x = circle.x
	lastPoint.y = circle.y
end)

function DrawMain.draw()
	love.graphics.setShader(myShader)

	-- currentCanvas:renderTo(function()
	-- 	love.graphics.setColor(1, 1, 1, 1)

	-- 	if #mouseParticles > 0 then
	-- 		for i = 1, #mouseParticles do
	-- 			local p = mouseParticles[i]
	-- 			love.graphics.circle("fill", p.x, p.y, 50)
	-- 		end
	-- 		mouseParticles = {}
	-- 	end
	-- end)

	-- otherCanvas:renderTo(function()
	-- 	love.graphics.draw(currentCanvas)
	-- end)

	-- currentCanvas:renderTo(function()
	-- 	love.graphics.clear()
	-- 	love.graphics.draw(otherCanvas)
	-- end)

	-- otherCanvas:renderTo(function()
	-- 	love.graphics.clear()
	-- end)
	-- love.graphics.draw(currentCanvas)

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
