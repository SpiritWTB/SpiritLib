SpiritLib = {}

SpiritLib.Modules = {
	["Attachments"] = false,
	["Models"] = false,
	["Q Menu"] = false,
	["Weapons"] = false,
}

function Start()
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