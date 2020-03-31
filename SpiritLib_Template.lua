SpiritLib = nil
ModuleName = nil

-- variables ModuleName and SpiritLib will be set before this runs
function LoadModule()
	SpiritLib[ModuleName] = {}





	-- Add your module functions and variables to SpiritLib[ModuleName] here

	-- example: variable
	SpiritLib[ModuleName].MyVariable = true

	-- example: function
	SpiritLib[ModuleName].MyFunction = function()
		-- function contents here
	end



	-- If you need to use override functions, you must register them with SpiritLib by defining them like this
	SpiritLib[ModuleName].HookFunction("Start", function()
		print("The module template has hit the Start() hook")
	end)




	SpiritLib.Call("ModuleLoadFinished", This)

end


