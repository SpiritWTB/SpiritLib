--[[
SpiritLib Notes:

You cannot pass certain types, (mainly functions, there may be others) between scripts



]]

SpiritLib = {}
SpiritLib.Modules = {
	["Core"] = This,

	["Attachments"] = false,
	["Default Models"] = false,
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


function FixedCall(moduleName, functionName, token, ...)
	local activeModule = SpiritLib.Modules[moduleName]

	if activeModule then
		if activeModule.scripts[1]["ReturnCall"] then
			if activeModule.scripts[1][functionName] and type(activeModule.scripts[1][functionName]) == "function" then
				activeModule.scripts[1].Call("ReturnCall", This, token, moduleName, functionName, ...)
				return This.table[token]
			else
				print("CallModuleFunction: Module \"" .. moduleName .. "\" does not contain function \"" .. functionName .. "\"")
			end
		else
			print("CallModuleFunction: Module \"" .. moduleName .. "\" has not implemented ReturnCall. Add this function to the module you're trying to call.")
		end
	else
		print("CallModuleFunction: Module \"" .. moduleName .. "\" does not exist.")
	end

	return nil
end

function ReturnCall(caller, token, functionName, ...)
	caller.table.spiritLibReturns[token] = _G[functionName](...)
end

local returnTokensByPart = {}

function GetToken(part)
	local token = 1

	while returnTokensByPart[part][token] do
		token = token + 1
	end

	returnTokensByPart[part][token] = true

    return token
end