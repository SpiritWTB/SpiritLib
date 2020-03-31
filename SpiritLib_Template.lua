SpiritLib = nil
ModuleName = nil

-- variables ModuleName and SpiritLib will be set before this runs
function LoadModule()
	SpiritLib[ModuleName] = {}





	-- Add your module functions and variables to SpiritLib[ModuleName] here






	SpiritLib.Call("ModuleLoadFinished", This)

end


