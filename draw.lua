local love = require("love")
-- local Math = require("math")
local DrawMain = {}
DrawMain.__index = DrawMain

local self = {}
function DrawMain.new()
	setmetatable(self, DrawMain)
	return self
end

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600

local drawCircles = false
local circleSize = 50
local currentCanvas
local emptyCanvas
local lastPoint = {
	x,
	y,
}

local myShader = love.graphics.newShader("shader.frag.shader")

function DrawMain.load()
	love.graphics.setCanvas()
	currentCanvas = love.graphics.newCanvas(SCREEN_WIDTH, SCREEN_HEIGHT, { msaa = 16 })
	emptyCanvas = love.graphics.newCanvas(SCREEN_WIDTH, SCREEN_HEIGHT, { msaa = 16 })

	myShader:send("circleSize", circleSize)
end

table.insert(KeyPressed, function(key)
	if key == "space" then
		drawCircles = not drawCircles
	end
end)

local particles = {}

table.insert(Update, function(dt)
	local maxDist = 5
	if love.mouse.isDown(1) then
		local x, y = love.mouse.getPosition()

		if lastPoint.x == nil then
			lastPoint.x = x
			lastPoint.y = y
			particles[#particles + 1] = { x, y }
		end
		local p = {}
		p[1] = x
		p[2] = y
		local dx = p[1] - lastPoint.x
		local dy = p[2] - lastPoint.y
		local dist = math.sqrt(dx * dx + dy * dy)
		-- if dist > maxDist then
		-- 	particles[#particles + 1] = p
		-- end

		---if there is a gap, fill it
		if dist > maxDist then
			local angle = math.atan2(dy, dx)
			local cosine = math.cos(angle)
			local sine = math.sin(angle)
			for i = 1, dist, maxDist do
				local p2 = {}
				p2[1] = lastPoint.x + i * cosine
				p2[2] = lastPoint.y + i * sine
				particles[#particles + 1] = p2
			end
			lastPoint.x = x
			lastPoint.y = y
		end

		if #particles > 0 then
			myShader:send("particles", unpack(particles))
		end
		myShader:send("particleCount", #particles)
	else
		lastPoint.x = nil
	end
	myShader:send("time", love.timer.getTime())
end)

function DrawMain.draw()
	love.graphics.setColor(1, 1, 1, 1)

	currentCanvas:renderTo(function()
		love.graphics.clear()
		love.graphics.setShader()
		if #particles > 0 then
			local limit = #particles > 100 and #particles - 99 or 1
			for i = #particles, limit, -1 do
				local p = particles[i]
				love.graphics.circle("fill", p[1], p[2], circleSize)
			end
		end
		love.graphics.setShader(myShader)
	end)
	if drawCircles then
		love.graphics.setShader()
		love.graphics.draw(currentCanvas)
	else
		love.graphics.setShader(myShader)
		love.graphics.draw(emptyCanvas)
	end
end

return DrawMain
