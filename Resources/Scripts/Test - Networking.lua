local SpiritLib = PartByName("SpiritLib").scripts[1]
local SLNet = function(...) SpiritLib.Call("ExecuteFunction", "Networking", ...) end

function CallModuleFunction(moduleName, name, ...) return SpiritLib.Globals.SpiritLib.Modules[moduleName].scripts[1].Call(name, ...) end
function GetModuleVariable(moduleName, name) return SpiritLib.Globals.SpiritLib.Modules[moduleName].scripts[1].Globals[name] end

function Update()
	if InputPressed("q") then
		CallModuleFunction("Networking", "CreateStreamedValue", "Bob", 420, 69)
		CallModuleFunction("Networking", "GetStreamedValue", "Bob")

		print(GetModuleVariable("Networking", "Test"))
		-- print(SLNet("GetVariable", "Test"))
	end
end