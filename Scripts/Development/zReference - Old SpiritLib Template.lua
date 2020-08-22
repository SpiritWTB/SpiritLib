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



	-- if you're going to do some setup right when the module gets loaded, do it down here after the functions, otherwise, if you try to run them, theoretically they'll no exist yet



	-- If you need to use override functions, you must register them with SpiritLib by defining them like this
	SpiritLib[ModuleName].HookFunction("Start", function()
		print("The module template has hit the Start() hook")
	end)




	SpiritLib.Call("ModuleLoadFinished", This)

end


