SpiritLib = {}

SpiritLib.Modules = {
	["Attachment"] = false,
	["Model"] = false,
	["Default Model"] = false,
	["Q Menu"] = false,
	["Weapon"] = false,
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