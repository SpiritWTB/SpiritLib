SpiritLib = {}

SpiritLib.Modules = {
	["Models"] = false,
	["Q Menu"] = false,
	["Weapons"] = false,
}

function Start()
	-- attempt to load all the modules
	for moduleName, v in pairs(SpiritLib.Modules) do
		local modulePart = CreatePart(0)
		modulePart.visible = false
		modulePart.cancollide = false
		modulePart.name = "SpiritLib " .. moduleName
		modulePart.script = "SpiritLib " .. moduleName

		SpiritLib.Modules[moduleName] = modulePart
	end
end

function OLDExecuteFunction(moduleName, name, ...)
	local args = {...}

	if args[2] == "GetVariable" then
		return SpiritLib.Modules[args[1]].scripts[1].Globals[args[3]]
	else
		return SpiritLib.Modules[args[1]].scripts[1].Call(args[2], table.unpack(args, 3))
	end
end