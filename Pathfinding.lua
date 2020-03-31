SpiritLib = nil
ModuleName = nil

-- variables ModuleName and SpiritLib will be set before this runs
function LoadModule()

	-- change this every time we change the map, so that it wont use the old NapMap file
	SpiritLib[ModuleName].BakeruniqueMapVersionName = "SL_zombieRush_1"

	-- this is a subsection of the Pathfinding module, the part that handles the creation and loading of the Baker
	SpiritLib[ModuleName].Baker = {}

	-- the actual list of nodes that are possible points an AI can go to
	-- this table will have key--value as gridPosition--node
	SpiritLib[ModuleName].Baker.NodeMap = {}
	
	-- the max angle of hill the AI can walk up
	SpiritLib[ModuleName].Baker.slopeAllowance = 50

	-- distance between points that we check
	SpiritLib[ModuleName].Baker.gridPointSpacing = 1
	SpiritLib[ModuleName].Baker.gridSize = newVector3(100,100,100)



	-- checks if the slope normal is within slopeAllowance. If it is, it's a ramp, if not, we consider it a wall
	-- TODO: make this actually work
	SpiritLib[ModuleName].Baker.NormalMakesRamp = function(_slopeNormal)
		return true
	end

	-- converts a WorldPosition to a GridPosition
	SpiritLib[ModuleName].Baker.PositionToGridPosition = function(_pos)
		local gSpace = SpiritLib[ModuleName].Baker.gridPointSpacing
		local gSize = SpiritLib[ModuleName].Baker.gridSize

		-- borrowed snapping math from love2d.org/forums/viewtopic.php?t=65913
		-- then slapped a max and min on each
		return newVector3(
			math.min(gSize.x,math.max(0,  math.floor((_pos.x + gSpace/2)/gSpace)*gSpace  )),
			math.min(gSize.y,math.max(0,  math.floor((_pos.y + gSpace/2)/gSpace)*gSpace  )),
			math.min(gSize.z,math.max(0,  math.floor((_pos.z + gSpace/2)/gSpace)*gSpace  ))
		)
	end

	-- converts a WorldPosition directly to a node in the NodeMap (if one exists)
	SpiritLib[ModuleName].Baker.GetCurrentNode = function(_pos)
		local gridPos = SpiritLib[ModuleName].Baker.PositionToGridPosition(_pos)

		-- IF THIS IS NIL THE ZOMBIE MADE IT OFF THE GRID, probably respawn him
		return SpiritLib[ModuleName].Baker.NodeMap[gridPos]
	end

	print("NavMap baking for this map, this is a heavy operation, please give it time.")


	local loadedSaveFile = File.ReadCompressed("SpiritLib_navmesh_" .. uniqueMapVersionName .. ".txt") 

	-- if we found a save file try to load it
	if (loadedSaveFile ~= nil) then
		SpiritLib[ModuleName].Baker.NodeMap = FromJson(loadedSaveFile)
	end

	-- if something went wrong during loading, clear the list (though if something went wrong we might have crashed)
	if (SpiritLib[ModuleName].Baker.NodeMap == nil) then
		SpiritLib[ModuleName].Baker.NodeMap = {}
	end

	-- if NodeMap is blank, either something went wrong or we don't have a map, so generate one 
	if (SpiritLib[ModuleName].Baker.NodeMap == {}) then
		for x=1, SpiritLib[ModuleName].Baker.gridSize.x do
			for y=1, SpiritLib[ModuleName].Baker.gridSize.y do
				for z=1, SpiritLib[ModuleName].Baker.gridSize.z do

					-- in the future we'll do a Cube collision check here, but wtb doesn't have it rn
					-- so raycast from the top to the bottom of what would be the cube
					local imaginaryCubeTop = 		newVector3(x,y+0.5,z)
					local imaginaryCubeBottom = 	newVector3(x,y-0.5,z)

					local check = RayCast(imaginaryCubeTop, imaginaryCubeBottom)
					if (check and check.hitDistance>0) then
						if (SpiritLib[ModuleName].Baker.NormalMakesRamp(check.hitNormal)) then

							local gridPosition = newVector3(x,y,z)

							local pos = gridPosition * SpiritLib[ModuleName].Baker.gridPointSpacing

							-- this is missing gcost and hcost but only because this is a node that's being saved. We only need the costs during actual pathfinding, we don't need them saved in json.
							local node = {
								position = pos,
								neighbors = {}
							}

							SpiritLib[ModuleName].Baker.NodeMap[gridPosition] = node
						end
					end
				end
			end
		end

		for k,v in pairs(SpiritLib[ModuleName].Baker.NodeMap) do
			-- raycast to all gridneighbors to see if they're node neighbors
			for rx=-1, 1 do
				for ry=-1, 1 do
					for rz=-1, 1 do
						local neighborGridPos = newVector3(k.x + rx, k.y + ry, k.z + rz)

						-- if this isn't the original position and it's a real node position
						if (neighborGridPos~=k and SpiritLib[ModuleName].Baker.NodeMap[neighborGridPos]~=nil) then

							-- if we didn't hit anything going from one nodes gridposition to the other
							if (RayCast(k, neighborGridPos).hitObject == nil) then
								--they're neighbors!
								-- we might be able to just "v.neighbors" here but I dont' want to risk it for now
								table.insert(SpiritLib[ModuleName].Baker.NodeMap[k].neighbors, neighborGridPos)
							end
						end
					end
				end
			end
		end

		-- we baked our map! save it to json in a file
		local saveString = ToJson(SpiritLib[ModuleName].Baker.NodeMap)
		
		if (File.Exists("SpiritLib_navmesh_" .. uniqueMapVersionName .. ".txt")) then
			print("NavMap already exists. It seems to have not loaded correctly though, so we'll overwrite it.")
		end
		File.WriteCompressed("SpiritLib_navmesh_" .. uniqueMapVersionName .. ".txt")

	end

	




	SpiritLib.Call("ModuleLoadFinished", This)

end

