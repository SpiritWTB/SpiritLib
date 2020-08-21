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

			print(name .. " module loaded!")
		end
	end
end

function FixedCall(moduleName, functionName, token, ...)
	local activeModule = SpiritLib.Modules[moduleName]

	-- make sure the module exists
	if activeModule then
		-- make sure the module has implemented ReceiveCall
		if activeModule.scripts[1].Globals.ReceiveCall then
			-- make sure the module has the function you're trying to call
			if activeModule.scripts[1].Globals[functionName] and type(activeModule.scripts[1].Globals[functionName]) == "function" then
				activeModule.Call("ReturnCall", This, token, moduleName, functionName, ...)
				return This.table[token]
			else
				print([[CallModuleFunction: Module "]] .. moduleName .. [[" does not contain function "]] .. functionName .. [["]])
			end
		else
			print([[CallModuleFunction: Module ]] .. moduleName .. [[ has not implemented "ReceiveCall(caller, token, functionName, ...)", please copy this function from SpiritLib Core to the module you're trying to run a script on ]])
		end
	else
		print([[CallModuleFunction: Module "]] .. moduleName .. [[" does not exist.]])
	end

	return nil
end

function ReturnCall(caller, token, functionName, ...)
	caller.table.spiritLibReturns[token] = _G[functionName](...)
end

local returnTokensByPart = {}
function GetToken(part)
	local token = 1
    while returnTokensByPart[token] do token = token + 1 end
    returnTokensByPart[token] = true
    return token
end