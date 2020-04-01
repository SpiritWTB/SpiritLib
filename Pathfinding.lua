-- variables ModuleName and SpiritLib will be set before this runs
function LoadModule(SpiritLib, ModuleName)

	-- at the end we'll set the other things table to this table
	local Module = {}

	-- this is a subsection of the Pathfinding module, the part that handles the creation and loading of the Baker
	Module.Baker = {}

	-- change this every time we change the map, so that it wont use the old NapMap file
	Module.Baker.uniqueMapVersionName = "SL_zombieRush_1"

	-- the actual list of nodes that are possible points an AI can go to
	-- this table will have key--value as gridPosition--node
	Module.Baker.NodeMap = {}
	
	-- the max angle of hill the AI can walk up
	Module.Baker.slopeAllowance = 50

	-- distance between points that we check
	Module.Baker.gridPointSpacing = 1
	Module.Baker.gridSize = newVector3(100,100,100)

	-- checks if the slope normal is within slopeAllowance. If it is, it's a ramp, if not, we consider it a wall
	-- TODO: make this actually work
	Module.Baker.NormalMakesRamp = function(_slopeNormal)
		return true
	end

	-- converts a WorldPosition to a GridPosition
	Module.Baker.PositionToGridPosition = function(_pos)
		local gSpace = Module.Baker.gridPointSpacing
		local gSize = Module.Baker.gridSize

		-- borrowed snapping math from love2d.org/forums/viewtopic.php?t=65913
		-- then slapped a max and min on each
		return newVector3(
			math.min(gSize.x,math.max(0,  math.floor((_pos.x + gSpace/2)/gSpace)*gSpace  )),
			math.min(gSize.y,math.max(0,  math.floor((_pos.y + gSpace/2)/gSpace)*gSpace  )),
			math.min(gSize.z,math.max(0,  math.floor((_pos.z + gSpace/2)/gSpace)*gSpace  ))
		)
	end

	-- converts a WorldPosition directly to a node in the NodeMap (if one exists)
	Module.Baker.PositionToNode = function(_pos)
		local gridPos = Module.Baker.PositionToGridPosition(_pos)

		-- IF THIS IS NIL THE ZOMBIE MADE IT OFF THE GRID, probably respawn him
		return Module.Baker.NodeMap[gridPos]
	end

	Module.Baker.BakeNodeMap = function()

		print("NavMap baking for this map, this is a heavy operation, please give it time.")

		for x=1, Module.Baker.gridSize.x do
			for y=1, Module.Baker.gridSize.y do
				for z=1, Module.Baker.gridSize.z do

					-- in the future we'll do a Cube collision check here, but wtb doesn't have it rn
					-- so raycast from the top to the bottom of what would be the cube
					local imaginaryCubeTop = 		newVector3(x,y+0.5,z)
					local imaginaryCubeBottom = 	newVector3(x,y-0.5,z)

					local check = RayCast(imaginaryCubeTop, imaginaryCubeBottom)
					if (check and check.hitDistance>0) then
						if (Module.Baker.NormalMakesRamp(check.hitNormal)) then

							local gridPosition = newVector3(x,y,z)

							local pos = gridPosition * Module.Baker.gridPointSpacing

							-- this is missing gcost and hcost but only because this is a node that's being saved. We only need the costs during actual pathfinding, we don't need them saved in json.
							local node = {
								position = pos,
								gridPos = gridPosition,
								neighborGridPositions = {}
							}

							Module.Baker.NodeMap[gridPosition] = node
						end
					end
				end
			end
		end

		for k,v in pairs(Module.Baker.NodeMap) do
			-- raycast to all grid neighbors to see if they're node neighbors
			for rx=-1, 1 do
				for ry=-1, 1 do
					for rz=-1, 1 do
						local neighborGridPos = newVector3(k.x + rx, k.y + ry, k.z + rz)

						-- if this isn't the original position and it's a real node position
						if (neighborGridPos~=k and Module.Baker.NodeMap[neighborGridPos]~=nil) then

							-- if we didn't hit anything going from one nodes gridposition to the other
							if (RayCast(k, neighborGridPos).hitObject == nil) then
								--they're neighbors!
								-- we might be able to just "v.neighborGridPositions" here but I dont' want to risk it for now
								table.insert(Module.Baker.NodeMap[k].neighborGridPositions, neighborGridPos)
							end
						end
					end
				end
			end
		end

		-- we baked our map! save it to json in a file
		local saveString = ToJson(Module.Baker.NodeMap)
		
		if (File.Exists("SpiritLib_navmesh_" .. Module.Baker.uniqueMapVersionName .. ".txt")) then
			print("NavMap already exists. It seems to have not loaded correctly though, so we'll overwrite it.")
		end
		File.WriteCompressed("SpiritLib_navmesh_" .. Module.Baker.uniqueMapVersionName .. ".txt")
	end

	-- borrowed from https://forums.coronalabs.com/topic/61784-function-for-reversing-table-order/
	Module.Baker.ReverseTable = function (_table)
		local i, j = 1, #_table

		while i < j do
			_table[i], _table[j] = _table[j], _table[i]

			i = i + 1
			j = j - 1
		end
	end

	--"Manhatten Distance" means adding together the distances of each axis.
	Module.Baker.ManhattenDistance = function(_pos1, _pos2)
		local m_dist = math.abs(_pos1.x - _pos2.x)
		m_dist = m_dist + math.abs(_pos1.y - _pos2.y)
		m_dist = m_dist + math.abs(_pos1.z - _pos2.z)

		return m_dist
	end

	Module.Baker.FindPath = function(_startPos, _endPos)
		local startNode = Module.Baker.PositionToNode(_startPos)
		local targetNode = Module.Baker.PositionToNode(_endPos)

		-- work backwards from the targetNode, finding our way
		local currentNode = targetNode
		local path = {}

		-- keep track of how many steps it's moved looking for a path, give up at a certain point so this loop doesn't kill us
		local maxComplexity = 300
		local complexity = 0

		-- if we haven't broken our complexity limit, and we havne't reached the startNode yet ( starting from targetNode )
		while(currentNode~=startNode and complexity <= maxComplexity) do
			-- check each neighbor and find the one with the least fCost
			for k,v in pairs(currentNode.neighborGridPositions) do
				local neighborNode = Module.Baker.NodeMap[v]

				-- only calculate if we haven't already calculated these
				if (neighborNode.gCost == nil) then
					neighborNode.gCost = Vector3.Distance(neighborNode.position, startNode.position)
					neighborNode.hCost = Module.Baker.ManhattenDistance(neighborNode.gridPos, targetNode.gridPos)
					neighborNode.fCost = gCost + hCost
				end

				if (fCost < currentNode.fCost) then
					currentNode = neighborNode
				end
			end

			complexity = complexity + 1
		end

		return path;
	end

	local loadedSaveFile = File.ReadCompressed("SpiritLib_navmesh_" .. uniqueMapVersionName .. ".txt") 

	-- if we found a save file try to load it
	if (loadedSaveFile ~= nil) then
		Module.Baker.NodeMap = FromJson(loadedSaveFile)
	end

	-- if something went wrong during loading, clear the list (though if something went wrong we might have crashed)
	if (Module.Baker.NodeMap == nil) then
		Module.Baker.NodeMap = {}
	end

	-- if NodeMap is blank, either something went wrong or we don't have a map, so generate one 
	if (Module.Baker.NodeMap == {}) then
		Module.Baker.BakeNodeMap()
	end

	SpiritLib[ModuleName] = Module

	SpiritLib.Call("ModuleLoadFinished", This)

end

