printTable = function(t)
	for pos, val in pairs(t) do
		print("[" .. tostring(pos) .. "] => " .. tostring(val))
	end
	print("table end")
end
printTableRecursive = function(t)
	local indent = "Table: "
	local printTable_cache = {}
	local function sub_printTable(t, indent)
		if printTable_cache[tostring(t)] then
			print(indent .. "*" .. tostring(t))
		else
			printTable_cache[tostring(t)] = true
			if type(t) == "table" then
				for pos, val in pairs(t) do
					local poss = tostring(pos)
					if type(pos) == "table" then
						print(indent .. "[" .. poss .. "] => " .. tostring(t) .. " {")
						sub_printTable(pos, indent .. string.rep(" ", string.len(poss) + 8))
						print(indent .. string.rep(" ", string.len(poss) + 6) .. "}")
					end
					if type(val) == "table" then
						print(indent .. "[" .. poss .. "] => " .. tostring(t) .. " {")
						sub_printTable(val, indent .. string.rep(" ", string.len(poss) + 8))
						print(indent .. string.rep(" ", string.len(poss) + 6) .. "}")
					elseif type(val) == "string" then
						print(indent .. "[" .. poss .. '] => "' .. val .. '"')
					else
						print(indent .. "[" .. poss .. "] => " .. tostring(val))
					end
				end
			else
				print(indent .. tostring(t))
			end
		end
	end
	sub_printTable(t, "")
	print("table end")
end
