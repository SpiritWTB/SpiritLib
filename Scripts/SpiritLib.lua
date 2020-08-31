--[[
===========            v    SpiritLib Notes:    v            ===========


Don't forget there are always more errors in your log file! Go to windows explorer and paste in or navigate to:           %appdata%\..\LocalLow\happyninjagames\WorldToBuild

DO NOT CLICK ON THE "SpiritLib Default Models" SCRIPT file in the script editor unless you want to wait a while

To use SpiritLib effectively, you must always add the "SpiritLib Setup" section to the beginning of your script. 
This gives you access to CallModuleFunction( moduleName, functionName, arguments ), which returns values as well

You cannot pass certain types, (namely functions & tables) between scripts.
If you check the log file and see errors about


You CAN however call a function on another script. To do this easily set up your script as a SpiritLib module, so that you can call your scripts functions with CallModuleFunciton:
	- Ddd it to the SpiritLib.Modules table below as ["<your_module_name>"]
	- Do one of these:
		- name your script "SpiritLib <your_module_name>" and paste it in the script editor
		- add your script to your "SpiritLib\Scripts" folder, name the file "SpiritLib <your_module_name>" and run the SpiritLib installer on your file

If you're making a weapon, the weaponScript must start with the same prefix as the other weaponScripts. In other words it must be called "Weapon <your_weapon_name>".


===========            ^    SpiritLib Notes:    ^            =========== ]]


SpiritLib = {}
SpiritLib.Modules = {
	["Core"] = This,

	["Attachments"] = false,
	["Default Objects"] = false,
	["Models"] = false,
	["Weapons"] = false,
	["Q Menu"] = false,
}

function Start()
	This.name = "SpiritLib"

	for name, part in pairs(SpiritLib.Modules) do
		if not part then
			local modulePart = CreatePart(0)
			modulePart.visible = false
			modulePart.cancollide = false
			modulePart.name = "SpiritLib " .. name
			modulePart.script = "SpiritLib " .. name

			SpiritLib.Modules[name] = modulePart

			print(name .. " module started!")
		end
	end

	LoadFinished()
end

-- this doesn't work yet, try to call this later so we can do init stuff once all the modules are loaded
function LoadFinished()
	for name, part in pairs(SpiritLib.Modules) do
		if part and part.type and part.type == "Part" then
			if part.script ~= nil and part.scripts[1].Globals["OnSpiritLibLoaded"] then
				part.scripts[1].Call("OnSpiritLibLoaded")
			end
		end
	end
end

function FixedCall(caller, moduleName, functionName, token, ...)
	local activeModule = SpiritLib.Modules[moduleName]

	if activeModule then
		if activeModule.scripts[1].Globals["ReturnCall"] then
			if activeModule.scripts[1].Globals[functionName] and type(activeModule.scripts[1].Globals[functionName]) == "function" then
				activeModule.scripts[1].Call("ReturnCall", caller, token, functionName, ...)
			else
				print("CallModuleFunction: Module \"" .. moduleName .. "\" does not contain function \"" .. functionName .. "\"")
			end
		else
			print("CallModuleFunction: Module \"" .. moduleName .. "\" has not implemented ReturnCall. Add this function to the module you're trying to call.")
		end
	else
		print("CallModuleFunction: Module \"" .. moduleName .. "\" does not exist.")
	end
end

function ReturnCall(caller, token, functionName, ...)
	caller.table.spiritLibReturns[token] = _G[functionName](...)
end