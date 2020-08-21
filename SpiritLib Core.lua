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
	["Q Menu"] = false,
	["Weapons"] = false
}

function Start()
	This.name = "SpiritLib"

	for name, active in pairs(SpiritLib.Modules) do
		if not active then
			local modulePart = CreatePart(0)
			modulePart.visible = false
			modulePart.cancollide = false
			modulePart.name = "SpiritLib " .. name
			modulePart.script = "SpiritLib " .. name

			SpiritLib.Modules[name] = modulePart

			print(name .. " module started!")
		end
	end
end

function FixedCall(moduleName, functionName, token, ...)
	local activeModule = SpiritLib.Modules[moduleName]

	if activeModule then
		if activeModule.scripts[1]["ReturnCall"] then
			if activeModule.scripts[1][functionName] and type(activeModule.scripts[1][functionName]) == "function" then
				activeModule.Call("ReturnCall", This, token, moduleName, functionName, ...)
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

	while returnTokensByPart[token] do
		token = token + 1
	end

	returnTokensByPart[token] = true

    return token
end