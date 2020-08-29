--[[ Start SpiritLib Setup ]]

local SL_UsedReturnTokens = {}
local function SpiritLib() return PartByName("SpiritLib").scripts[1] end
local function GetModuleVariable(moduleName, name) return SpiritLib().Globals.SpiritLib.Modules[moduleName].scripts[1].Globals[name] end
local function GetToken() local token = 1; while SL_UsedReturnTokens[token] do token = token + 1 end SL_UsedReturnTokens[token] = true; return token end
local function CallModuleFunction("Stream",moduleName, functionName, ...) local token = GetToken(); SpiritLib().Call("FixedCall", This, moduleName, functionName, "!SLToken" .. token, ...); SL_UsedReturnTokens[token] = nil; return This.table["!SLToken" .. token] end
function ReturnCall(caller, token, functionName, ...) caller.table[token] = _G[functionName](...) end

-- [[ End SpiritLib Setup ]]

function Update()
	if InputPressed("z") then
        CallModuleFunction("Stream","CreateStreamedValue", "Test", newVector3(1, 2, 4), 69)
    elseif InputPressed("x") then
        CallModuleFunction("Stream","GetStreamedValue", "Test")
    elseif InputPressed("c") then
        CallModuleFunction("Stream","UpdateStreamedValue", "Test", newVector3(10, 20, 40))
    elseif InputPressed("v") then
        CallModuleFunction("Stream","SetSyncedValue", "Bob", newVector2(420, 69))
    elseif InputPressed("b") then
        CallModuleFunction("Stream","SetSyncedValue", "Bob", newVector2(42, 1337))
    elseif InputPressed("n") then
        CallModuleFunction("Stream","GetSyncedValue", "Bob")
    elseif InputPressed("m") then
        NetworkSendToHost("AddStreamedValue", {})
    end
end