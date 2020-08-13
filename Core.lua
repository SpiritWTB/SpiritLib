SpiritLib = {}

SpiritLib.Modules = {
	["Networking"] = {}
}

function Start()
	-- attempt to load all the modules
	for moduleName, v in pairs(SpiritLib.Modules) do
		local modulePart = PartByName("SpiritLib " .. moduleName)

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