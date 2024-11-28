local love = require("love")
local math = require("math")
local DrawMain = {}
DrawMain.__index = DrawMain

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600

local self = {}
function DrawMain.new()
	setmetatable(self, DrawMain)
	return self
end

local mainCanvas = love.graphics.newCanvas(SCREEN_WIDTH, SCREEN_HEIGHT, { msaa = 16 })
local meshCanvas = love.graphics.newCanvas(SCREEN_WIDTH, SCREEN_HEIGHT, { msaa = 16 })
local log = love.graphics.newText(love.graphics.getFont(), "")
local logCircle = {}
local requireMeshUpdate = false
local meshes = {}
local cursorRadius = 30
local cursorDigPower = 0.25
local meshDebug = 1
local meshMaxRadius = 50

---@param pivotV2 table Vector2 with x and y of the center vertex
---@param minRadius number
---@param maxRadius number
---@param vertCount number
---@return table vertices x,y,x,y...
local function generateVertices(pivotV2, minRadius, maxRadius, vertCount)
	local vertices = {}
	local rotationHour = 360 / vertCount

	for i = 1, vertCount do
		local radius = love.math.random(minRadius, maxRadius)
		local angle = love.math.random(rotationHour * (i - 1), rotationHour * i)

		vertices[#vertices + 1] = pivotV2.x + radius * math.cos(math.rad(angle))
		vertices[#vertices + 1] = pivotV2.y + radius * math.sin(math.rad(angle))
	end

	return vertices
end

local function flattenMap(Map)
	local flat = {}
	for _, v in pairs(Map) do
		flat[#flat + 1] = {}
		flat[#flat][1] = v[1]
		flat[#flat][2] = v[2]
		flat[#flat][3], flat[#flat][4], flat[#flat][5], flat[#flat][6], flat[#flat][7] =
			0,
			0,
			meshDebug and love.math.random(0, 1) or 0,
			meshDebug and love.math.random(0, 1) or 0,
			meshDebug and love.math.random(0, 1) or 0

		flat[#flat + 1] = {}
		flat[#flat][1] = v[3]
		flat[#flat][2] = v[4]
		flat[#flat][3], flat[#flat][4], flat[#flat][5], flat[#flat][6], flat[#flat][7] =
			0,
			0,
			meshDebug and love.math.random(0, 1) or 0,
			meshDebug and love.math.random(0, 1) or 0,
			meshDebug and love.math.random(0, 1) or 0

		flat[#flat + 1] = {}
		flat[#flat][1] = v[5]
		flat[#flat][2] = v[6]
		flat[#flat][3], flat[#flat][4], flat[#flat][5], flat[#flat][6], flat[#flat][7] =
			0,
			0,
			meshDebug and love.math.random(0, 1) or 0,
			meshDebug and love.math.random(0, 1) or 0,
			meshDebug and love.math.random(0, 1) or 0
	end
	return flat
end

local function normalizeBorder(meshvert, maxDistance)
	local maxSqr = maxDistance ^ 2
	local i = 1
	while i < #meshvert.verticesBorder do
		local fx = meshvert.verticesBorder[i]
		local fy = meshvert.verticesBorder[i + 1]

		local lx = meshvert.verticesBorder[i + 2] or meshvert.verticesBorder[1]
		local ly = meshvert.verticesBorder[i + 3] or meshvert.verticesBorder[2]

		local distSqr = (fx - lx) ^ 2 + (fy - ly) ^ 2
		if distSqr > maxSqr then
			local scale = math.floor(math.sqrt(distSqr) / maxDistance)
			for j = 1, scale do
				local pos = j / (scale + 1)
				i = i + 2
				table.insert(meshvert.verticesBorder, i, fy + (ly - fy) * pos)
				table.insert(meshvert.verticesBorder, i, fx + (lx - fx) * pos)
			end
		else
			local minDistance = maxDistance / 10
			local minSqr = minDistance ^ 2
			if distSqr < minSqr then
				table.remove(meshvert.verticesBorder, i)
				table.remove(meshvert.verticesBorder, i)
				i = i - 2
			end
		end
		i = i + 2
	end

	if #meshvert.verticesBorder < 6 then
		return false
	end
	return true
end
---@param m table meshes
---@return boolean true if meshes was changed
local function updateMesh(meshes, pos)
	requireMeshUpdate = true
	local modified = false
	local m = meshes[pos]
	if m == nil then
		return true
	end

	if normalizeBorder(m, meshMaxRadius) then
		wtf = function()
			table.remove(meshes, pos)
			modified = true
		end
		triangulate = function()
			m.verticesTriangle = flattenMap(love.math.triangulate(m.verticesBorder))
			m.mesh = love.graphics.newMesh(m.verticesTriangle, "triangles", "dynamic")
		end
		xpcall(triangulate, wtf)
		modified = false
		return modified
	else
		table.remove(meshes, pos)
		modified = true
		return modified
	end
end
local function addMesh(meshes, vertBorder)
	meshes[#meshes + 1] = {}
	meshes[#meshes].verticesBorder = vertBorder
	updateMesh(meshes, #meshes)
end

local function generateMesh(x, y, min, max, vertCount)
	addMesh(meshes, generateVertices({ x = x, y = y }, min, max, vertCount))
end

local function isCCW(p1, p2, p3)
	return (p2[1] - p1[1]) * (p3[2] - p1[2]) - (p2[2] - p1[2]) * (p3[1] - p1[1]) > 0
end

-- Function to check if two line segments intersect
local function doSegmentsIntersect(p1, p2, q1, q2)
	return isCCW(p1, q1, q2) ~= isCCW(p2, q1, q2) and isCCW(p1, p2, q1) ~= isCCW(p1, p2, q2)
end

local function splitMesh(meshes, pos, iFirst, iLast, jFirst, jLast)
	local m = meshes[pos]
	local v = m.verticesBorder
	print("#meshes", #meshes)
	print("#meshes[pos].verticesBorder", #meshes[pos].verticesBorder)
	-- print(#meshes[2].verticesBorder)
	table.remove(meshes, pos)
	local newBorder1 = {}
	local newBorder2 = {}
	print(iFirst, iLast, jFirst, jLast)

	local i = (iLast + 2) % #v
	-- local imax = (jFirst + #v - 2) % #v
	while i ~= jFirst do
		newBorder1[#newBorder1 + 1] = v[i]
		newBorder1[#newBorder1 + 1] = v[i + 1]
		i = (i + 2) % #v
	end

	print("1 ", #newBorder1)
	if #newBorder1 >= 8 then
		addMesh(meshes, newBorder1)
	end

	i = (jLast + 2) % #v
	-- imax = (iFirst + #v - 2) % #v
	while i ~= iFirst do
		newBorder2[#newBorder2 + 1] = v[i]
		newBorder2[#newBorder2 + 1] = v[i + 1]
		i = (i + 2) % #v
	end

	print("2 ", #newBorder2)
	if #newBorder2 >= 8 then
		addMesh(meshes, newBorder2)
	end
	if #newBorder1 < 8 and #newBorder2 < 8 then
		requireMeshUpdate = true
	end
	print("#meshes", #meshes)
end

---@param meshes table
---@param pos number
---@param i number index of vertex that changed
---@return boolean true if meshes was split
local function trySplitMesh(meshes, pos, i)
	local v = meshes[pos].verticesBorder
	if #v < 20 then
		return false
	end
	local i0 = i
	local i2 = i
	if i == 1 then
		i0 = #v + 1
	elseif i == #v - 1 then
		i2 = -1
	end

	local v1 = {}
	v1.f = { v[i0 - 2], v[i0 - 1] }
	v1.l = { v[i], v[i + 1] }
	local v2 = {}
	v2.f = { v[i], v[i + 1] }
	v2.l = { v[i2 + 2], v[i2 + 3] }

	local j = (i + 2) % #v
	local loopj = ((i + #v) - 4) % #v
	while j ~= loopj do
		local j1 = (j + 2) % #v
		local j2 = (j + 4) % #v

		v3 = {}
		v3.f = { v[j], v[j + 1] }
		v3.l = { v[j1], v[j + 1] }
		v4 = {}
		v4.f = { v[j1], v[j1 + 1] }
		v4.l = { v[j2], v[j2 + 1] }
		-- if v3.l[1] == nil then
		-- print(#v, j0, j, j2)
		-- end
		-- print(#v, i0, i, i2, j, j1, j2)
		-- print("v1", v1.f[1], v1.f[2], v1.l[1], v1.l[2], v3.f[1], v3.f[2], v3.l[1], v3.l[2])
		if doSegmentsIntersect(v1.f, v1.l, v3.f, v3.l) then
			print(loopj, #v, i0, i, i2, j, j1, j2)
			print("v1", v1.f[1], v1.f[2], v1.l[1], v1.l[2], v3.f[1], v3.f[2], v3.l[1], v3.l[2])
			splitMesh(meshes, pos, i0 - 2, i, j, j1)
			return true
		elseif doSegmentsIntersect(v2.f, v2.l, v4.f, v4.l) then
			print(loopj, #v, i0, i, i2, j, j1, j2)
			print(v2.f[1], v2.f[2], v2.l[1], v2.l[2], v4.f[1], v4.f[2], v4.l[1], v4.l[2])
			splitMesh(meshes, pos, i, i2 + 2, j1, j2)
			return true
		end

		j = j + 2
		j = j % #v
	end
	return false
end

local function windingNumber(px, py, vertices)
	local winding_number = 0
	local bx = vertices[1] - px
	local by = vertices[2] - py
	local b_below_p = by <= 0

	local n = math.floor(#vertices / 2) -- Number of points in the polygon
	for i = 1, n do
		local ax, ay = bx, by
		local a_below_p = b_below_p

		local j = (i % n) * 2 + 1
		bx = vertices[j] - px
		by = vertices[j + 1] - py
		b_below_p = by <= 0

		local point_left_of_edge = ax * by - ay * bx -- 2 * signed area of the triangle abp

		if a_below_p and not b_below_p and point_left_of_edge > 0 then
			winding_number = winding_number + 1 -- Upward edge
		elseif b_below_p and not a_below_p and point_left_of_edge < 0 then
			winding_number = winding_number - 1 -- Downward edge
		end
	end

	return winding_number
end

local function dig(radius, force)
	local radSqr = radius * radius
	local x, y = love.mouse.getPosition()
	for pos, meshvert in pairs(meshes) do
		local v = meshvert.verticesBorder
		local changed = false
		for i = 1, #v - 1, 2 do
			local nowX = v[i]
			local nowY = v[i + 1]

			if radSqr > ((nowX - x) ^ 2 + (nowY - y) ^ 2) then
				local ang = math.atan2(nowY - y, nowX - x)
				local dist = math.sqrt((nowX - x) ^ 2 + (nowY - y) ^ 2)
				local digStep = force * radius

				local cos = digStep * math.cos(ang)
				local sin = digStep * math.sin(ang)

				local newX = nowX - cos
				local newY = nowY - sin

				local wind = windingNumber(newX, newY, v)

				if wind == 0 then
					newX = nowX + cos
					newY = nowY + sin

					local wind = windingNumber(newX, newY, v)

					if wind == 0 then
						local prevX = v[i - 2] or v[#v - 1]
						local prevY = v[i - 1] or v[#v]
						local nextX = v[i + 2] or v[1]
						local nextY = v[i + 3] or v[2]
						local leftAng = math.atan2(nextY - nowY, nextX - nowX)
						local rightAng = math.atan2(prevY - nowY, prevX - nowX)
						local diffL = ((leftAng + math.pi * 2) - (ang + math.pi * 2)) % math.pi * 2
						local diffR = ((rightAng + math.pi * 2) - (ang + math.pi * 2)) % math.pi * 2
						if math.min(diffL, math.pi * 2 - diffL) < math.min(diffR, math.pi * 2 - diffR) then
							newX = nowX + digStep * math.cos(leftAng)
							newY = nowY + digStep * math.sin(leftAng)
						else
							newX = nowX + digStep * math.cos(rightAng)
							newY = nowY + digStep * math.sin(rightAng)
						end
					end
				end

				v[i] = newX
				v[i + 1] = newY
				logCircle = { newX, newY, 5 }
				changed = true
				if trySplitMesh(meshes, pos, i) then
					-- dig(radius, force)
					return
				end
			end
		end
		if changed then
			if updateMesh(meshes, pos) then
				-- dig(radius, force)
				return
			end
		end
	end
end

function DrawMain.load()
	generateMesh(600, 300, 100, 300, 10)
	generateMesh(200, 300, 50, 100, 10)
end

table.insert(KeyPressed, function(key, unicode)
	if key == "escape" then
		love.event.quit()
	end
	if key == "space" then
		meshes = {}
		generateMesh(600, 300, 100, 300, 10)
		generateMesh(200, 300, 50, 100, 10)
	end
	-- local x, y = love.mouse.getPosition()
	-- canvas:renderTo(function()
	-- 	mainCircle(x, y)
	-- end)
end)

table.insert(Update, function(dt)
	--
	if love.mouse.isDown(1) then
		dig(cursorRadius, cursorDigPower)
	end
end)

local renderMesh = function()
	love.graphics.clear()

	love.graphics.setLineJoin("miter")
	love.graphics.setLineStyle("smooth")
	love.graphics.setLineWidth(10)

	for _, meshvert in pairs(meshes) do
		if meshDebug then
			love.graphics.setColor(1, 1, 1)
		else
			love.graphics.setColor(0.212, 0.106, 0.094)
		end
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(meshvert.mesh)
		love.graphics.setColor(0.149, 0.075, 0.063, 1)

		local vertices = {}
		for i = 1, #meshvert.verticesBorder do
			table.insert(vertices, meshvert.verticesBorder[i])
		end
		table.insert(vertices, meshvert.verticesBorder[1])
		table.insert(vertices, meshvert.verticesBorder[2])

		love.graphics.line(vertices)
		-- love.graphics.setColor(1, 1, 1)
		-- love.graphics.draw(meshvert.mesh)
	end
	requireMeshUpdate = false
end

local drawCursor = function()
	love.graphics.clear()
	if love.mouse.isDown(1) then
		local x, y = love.mouse.getPosition()
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setLineWidth(3)
		love.graphics.circle("line", x, y, cursorRadius)
	end
end

local function updateCanvases()
	love.graphics.setCanvas()
	if requireMeshUpdate then
		meshCanvas:renderTo(renderMesh)
	end
	mainCanvas:renderTo(drawCursor)
end

function DrawMain.draw()
	updateCanvases()

	love.graphics.draw(meshCanvas)
	love.graphics.draw(mainCanvas)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(log)
	if logCircle[1] then
		love.graphics.circle("fill", logCircle[1], logCircle[2], logCircle[3])
	end
end

return DrawMain
