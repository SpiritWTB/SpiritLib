local SpiritLib = function() return PartByName("SpiritLib").scripts[1] end
local SLNet = function(...) SpiritLib().Call("ExecuteFunction", "Networking", ...) end

function CallModuleFunction(moduleName, name, ...) return SpiritLib().Globals.SpiritLib.Modules[moduleName].scripts[1].Call(name, ...) end
function GetModuleVariable(moduleName, name) return SpiritLib().Globals.SpiritLib.Modules[moduleName].scripts[1].Globals[name] end

function Update()
	if InputPressed("z") then
		CallModuleFunction("Networking", "CreateStreamedValue", "MousePos:" .. LocalPlayer().id, MousePosWorld())
	elseif InputPressed("x") then
		for i, player in pairs(GetAllPlayers()) do
			local key = "MousePos:" .. player.id

			if player.table[key] then
				print(player.id, player.table[key].position)
			end
		end
	elseif InputPressed("c") then
		CallModuleFunction("Networking", "UpdateStreamedValue", "MousePos:" .. LocalPlayer().id, MousePosWorld())
	end
end