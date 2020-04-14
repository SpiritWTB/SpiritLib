print("pathfinding loading")
local moduleName = "Pathfinding"

function TablePrint (tbl, indent)
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
        formatting = string.rep('  ', indent) .. tostring(k) .. ': ';
        if (type(v) == 'table') then
            print(formatting)
            TablePrint(v, indent+1)
        else
            print(formatting .. tostring(v))
        end
    end
end

SpiritLib = {}
SpiritLib[moduleName] = {}

-- this is a subsection of the Pathfinding module, the part that handles the creation and loading of the Baker
SpiritLib[moduleName].Baker = {}

-- change this every time we change the map, so that it wont use the old NapMap file
SpiritLib[moduleName].Baker.uniqueMapVersionName = "SL_zombieRush_1"

-- the actual list of nodes that are possible points an AI can go to
-- this table will have key--value as gridPosition--node
SpiritLib[moduleName].Baker.NodeMap = nil

-- the max angle of hill the AI can walk up
SpiritLib[moduleName].Baker.slopeAllowance = 50

-- distance between points that we check
SpiritLib[moduleName].Baker.gridPointSpacing = 2
SpiritLib[moduleName].Baker.gridSize = newVector3(20,10,20)

print("creating function list")

SpiritLib[moduleName].functions = {

	-- checks if the slope normal is within slopeAllowance. If it is, it's a ramp, if not, we consider it a wall
	-- TODO: make this actually work
	NormalMakesRamp = function(_slopeNormal)
		return true
	end,

	-- converts a WorldPosition to a GridPosition
	PositionToGridPosition = function(_pos)
		local gSpace = SpiritLib[moduleName].Baker.gridPointSpacing
		local gSize = SpiritLib[moduleName].Baker.gridSize

		-- borrowed snapping math from love2d.org/forums/viewtopic.php?t=65913
		-- then slapped a max and min on each
		return newVector3(
			math.min(gSize.x,math.max(0, math.floor((_pos.x + gSpace/2)/gSpace) )),
			math.min(gSize.y,math.max(0, math.floor((_pos.y + gSpace/2)/gSpace) )),
			math.min(gSize.z,math.max(0, math.floor((_pos.z + gSpace/2)/gSpace) ))
		)
	end,

	-- converts a WorldPosition directly to a node in the NodeMap (if one exists)
	PositionToNode = function(_pos)
		local gridPos = SpiritLib[moduleName].functions.PositionToGridPosition(_pos)

		-- IF THIS IS NIL THE ZOMBIE MADE IT OFF THE GRID, probably respawn him
		return SpiritLib[moduleName].Baker.NodeMap[gridPos]
	end,

	GetRootParent = function(_part)
		local nextParent = _part.parent
		if (nextParent ~= nil) then
			return SpiritLib[moduleName].functions.GetRootParent(nextParent);
		else
			return _part
		end
	end,

	BakeNodeMap = function()

		print("NavMap baking for this map, this is a heavy operation, please give it time.")

		for x=1, SpiritLib[moduleName].Baker.gridSize.x do
			for y=1, SpiritLib[moduleName].Baker.gridSize.y do
				for z=1, SpiritLib[moduleName].Baker.gridSize.z do
					-- in the future we'll do a Cube collision check here, but wtb doesn't have it rn
					-- so raycast from the top to the bottom of what would be the cube
					local imaginaryCubeTop = 		newVector3(x,y+10.5,z)
					local imaginaryCubeBottom = 	newVector3(x,y-0.5,z)
					local check = RayCast(imaginaryCubeTop, imaginaryCubeBottom)
					if (check and check.hitDistance>0 and check.hitObject~=nil and check.hitObject.name == "NavFloor") then
						if (SpiritLib[moduleName].functions.NormalMakesRamp(check.hitNormal)) then

							local gridPosition = newVector3(x,y,z)

							local pos = gridPosition * SpiritLib[moduleName].Baker.gridPointSpacing

							-- this is missing gcost and hcost but only because this is a node that's being saved. We only need the costs during actual pathfinding, we don't need them saved in json.
							local node = {
								position = pos,
								gridPos = gridPosition,
								neighborGridPositions = {}
							}


							SpiritLib[moduleName].Baker.NodeMap[gridPosition] = node
						end
					end
				end
			end
		end

		print("first loop traversed")

		for k,v in pairs(SpiritLib[moduleName].Baker.NodeMap) do
			-- raycast to all grid neighbors to see if they're node neighbors
			for rx=-1, 1 do
				for ry=-1, 1 do
					for rz=-1, 1 do
						local neighborGridPos = newVector3(k.x + rx, k.y + ry, k.z + rz)

						-- if this isn't the original position and it's a real node position
						if (neighborGridPos~=k and SpiritLib[moduleName].Baker.NodeMap[neighborGridPos]~=nil) then

							-- if we didn't hit anything going from one nodes gridposition to the other

							local hit = RayCast(v.position, SpiritLib[moduleName].Baker.NodeMap[neighborGridPos].position)
							if (hit == nil) then
								--they're neighbors!
								-- we might be able to just "v.neighborGridPositions" here but I dont' want to risk it for now
								table.insert(SpiritLib[moduleName].Baker.NodeMap[k].neighborGridPositions, neighborGridPos)

							end
						end
					end
				end
			end
		end

		print("nodemap was tested here and is full of juicy valid (format wise) data")

		print("second loop traversed")

		-- we baked our map! save it to json in a file
		local saveString = ToJson(SpiritLib[moduleName].Baker.NodeMap)
		
		if (File.Exists("SpiritLib_navmesh_" .. SpiritLib[moduleName].Baker.uniqueMapVersionName .. ".txt")) then
			print("NavMap already exists. It seems to have not loaded correctly though, so we'll overwrite it.")
		end
		--File.WriteCompressed("SpiritLib_navmesh_" .. SpiritLib[moduleName].Baker.uniqueMapVersionName .. ".txt")

		print("save commented")
	end,

	-- borrowed from https://forums.coronalabs.com/topic/61784-function-for-reversing-table-order/
	ReverseTable = function (_table)
		local i, j = 1, #_table

		while i < j do
			_table[i], _table[j] = _table[j], _table[i]

			i = i + 1
			j = j - 1
		end
	end,

	--"Manhatten Distance" means adding together the distances of each axis.
	ManhattenDistance = function(_pos1, _pos2)
		local m_dist = math.abs(_pos1.x - _pos2.x)
		m_dist = m_dist + math.abs(_pos1.y - _pos2.y)
		m_dist = m_dist + math.abs(_pos1.z - _pos2.z)

		return m_dist
	end,

	FindPath = function(_startPos, _endPos)
		print ("startpos: " .. tostring(_startPos))
		local startNode = SpiritLib[moduleName].functions.PositionToNode(_startPos)
		local targetNode = SpiritLib[moduleName].functions.PositionToNode(_endPos)

		print(startNode)
		print(targetNode)

		-- work backwards from the targetNode, finding our way
		local currentNode = targetNode
		local path = {}

		-- keep track of how many steps it's moved looking for a path, give up at a certain point so this loop doesn't kill us
		local maxComplexity = 300
		local complexity = 0

		local passedNodes = {}

		-- if we haven't broken our complexity limit, and we havne't reached the startNode yet ( starting from targetNode )
		while(currentNode~=startNode and complexity <= maxComplexity) do
			if (currentNode.gCost == nil) then
				currentNode.gCost = Vector3.Distance(currentNode.position, startNode.position)
				currentNode.hCost = SpiritLib[moduleName].functions.ManhattenDistance(currentNode.gridPos, targetNode.gridPos)
				
				currentNode.fCost = currentNode.gCost + currentNode.hCost
			end

			local chosenNextNode = nil
			-- check each neighbor and find the one with the least fCost
			for k,v in pairs(currentNode.neighborGridPositions) do
				local neighborNode = SpiritLib[moduleName].Baker.NodeMap[v]
				

				-- only calculate if we haven't already calculated these
				if (neighborNode.gCost == nil) then
					neighborNode.gCost = Vector3.Distance(neighborNode.position, startNode.position)
					neighborNode.hCost = SpiritLib[moduleName].functions.ManhattenDistance(neighborNode.gridPos, targetNode.gridPos)
					neighborNode.fCost = neighborNode.gCost + neighborNode.hCost
				else
					neighborNode.gCost = currentNode.gCost + Vector3.Distance(neighborNode.position, startNode.position)
				end
				
				if (neighborNode.fCost ~= nil and (chosenNextNode==nil or neighborNode.fCost < chosenNextNode.gCost) and passedNodes[neighborNode.gridPos]==nil) then
					chosenNextNode = neighborNode
				end
			end

			if (chosenNextNode ~= nil) then
				currentNode = chosenNextNode
				passedNodes[chosenNextNode.gridPos] = true
			end

			table.insert(path, currentNode);
			print(currentNode.gridPos)

			complexity = complexity + 1
		end

		print("returning path")
		return path;
	end

}

print("finished function list")

SpiritLib[moduleName].loadedSaveFile = nil

local loadNavPath = "SpiritLib_navmesh_" .. SpiritLib[moduleName].Baker.uniqueMapVersionName .. ".txt"
if (File.Exists(loadNavPath)) then
	SpiritLib[moduleName].loadedSaveFile = File.ReadCompressed()
end

print("tried to grab save file")

-- if we found a save file try to load it
if (SpiritLib[moduleName].loadedSaveFile ~= nil) then
	--FromJson seems broken internally right now so this is disabled, we'll bake every time
	--SpiritLib[moduleName].Baker.NodeMap = FromJson(loadedSaveFile)
end

print("tried to convert from json (not really its commented out rn")

print("we're still here")

-- if NodeMap is blank, either something went wrong or we don't have a map, so generate one 
if (SpiritLib[moduleName].Baker.NodeMap == nil or SpiritLib[moduleName].Baker.NodeMap == {}) then
	SpiritLib[moduleName].Baker.NodeMap = {}
	print("node bake")
	SpiritLib[moduleName].functions.BakeNodeMap()
	print("made it through bake")

	

	if (false) then
		print("visualizing nodemap")
		TablePrint(SpiritLib[moduleName].Baker.NodeMap)
	end

	print("getting path")

	local zombie = PartByName("Zombie")
	local player = PartByName("Player")
	local path = SpiritLib[moduleName].functions.FindPath(zombie.position, player.position)
	print("traversed findpath")

	print("path: " .. tostring(path))

	--SpiritLib[moduleName].Baker.NodeMap
	for k,v in pairs(SpiritLib[moduleName].Baker.NodeMap) do
		local part = CreatePart(0)
		part.position = v.position
		part.size = newVector3(0.2,0.2,0.2)
		part.cancollide = false
	end

	local i = 0
	for k,v in pairs(path) do
		i = i + 1
		local part = CreatePart(0)
		part.position = v.position + newVector3(0,0.075*i,0)
		part.cancollide = false

	end
	
end