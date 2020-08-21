SpiritLib = {}

SpiritLib.Modules = {
	["Attachments"] = false,
	["Models"] = false,
	["Default Models"] = false,
	["Q Menu"] = false,
	["Weapons"] = false,
}

function Start()
	This.name = "SpiritLib"

	for moduleName, v in pairs(SpiritLib.Modules) do
		local modulePart = CreatePart(0)
		modulePart.visible = false
		modulePart.cancollide = false
		modulePart.name = "SpiritLib " .. moduleName
		modulePart.script = "SpiritLib " .. moduleName

		SpiritLib.Modules[moduleName] = modulePart

		print(moduleName .. " module loaded!")
	end
end

function CallModuleFunction(caller, token, moduleName, functionName, ...)
	local selectedModule = SpiritLib.Modules[moduleName]

	if selectedModule then
		selectedModule.scripts[1].Call("ReceiveCall", caller, token, functionName, ...)
	end
end