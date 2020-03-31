SpiritLib = nil
ModuleName = nil

-- variables ModuleName and SpiritLib will be set before this runs
function LoadModule()

	-- make sure spiritlib is installed
	local SpiritLibPart = PartByName("SpiritLib")
	SpiritLib = SpiritLibPart.scripts[1]
	if (SpiritLibPart == nil or SpiritLibPart.scripts[1] == nil) then print("PathFinding is part of SpiritLib, which cannot be found. Please install SpiritLib properly.") end

	SpiritLib.PathFinding = {}





	-- pathfinding module code goes here






	SpiritLib.Call("ModuleLoadFinished", This)

end


