math.randomseed(os.time())
local function SpiritLib() return PartByName("SpiritLib").scripts[1] end

local function FixedCall(moduleName, functionName, ...)
	local token = ""

	for i = 1, 16 do
		token = token .. string.format("%x", math.random(0, 255))
	end

	SpiritLib().Call("CallModuleFunction", This, token, moduleName, functionName, ...)
	return This.table[token]
end

function ReceiveCall(caller, token, functionName, ...)
	if _G[functionName] and type(_G[functionName]) == "function" then
		caller.table[token] = _G[functionName](...)
	end
end

function Update()
	if InputPressed("q") then
		print(FixedCall("TestFunc"))
	end
end
