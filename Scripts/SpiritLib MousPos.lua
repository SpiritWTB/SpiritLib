local SpiritLib = function() return PartByName("SpiritLib").scripts[1] end
local SLNet = function(...) SpiritLib().Call("ExecuteFunction", "Networking", ...) end

function CallModuleFunction(moduleName, name, ...) return SpiritLib().Globals.SpiritLib.Modules[moduleName].scripts[1].Call(name, ...) end
function GetModuleVariable(moduleName, name) return SpiritLib().Globals.SpiritLib.Modules[moduleName].scripts[1].Globals[name] end

local mousePosRegistered = false

function Update()
	if mousePosRegistered==false then
		CallModuleFunction("Networking", "CreateStreamedValue", "MousePos:" .. LocalPlayer().id, MousePosWorld())
    	mousePosRegistered = true
	else
		CallModuleFunction("Networking", "UpdateStreamedValue", "MousePos:" .. LocalPlayer().id, MousePosWorld())
	end
end