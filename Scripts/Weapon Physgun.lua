--[[ Start SpiritLib Setup ]]

local SL_UsedReturnTokens = {}
local function SpiritLib() return PartByName("SpiritLib").scripts[1] end
local function GetModuleVariable(moduleName, name) return SpiritLib().Globals.SpiritLib.Modules[moduleName].scripts[1].Globals[name] end
local function GetToken() local token = 1; while SL_UsedReturnTokens[token] do token = token + 1 end SL_UsedReturnTokens[token] = true; return token end
local function CallModuleFunction(moduleName, functionName, ...) local token = GetToken(); SpiritLib().Call("FixedCall", This, moduleName, functionName, "!SLToken" .. token, ...); SL_UsedReturnTokens[token] = nil; return This.table["!SLToken" .. token] end
function ReturnCall(caller, token, functionName, ...) caller.table[token] = _G[functionName](...) end

-- [[ End SpiritLib Setup ]]


Name = "The Physgun"
Description = "Moves and rotates objects and SpiritModels"
Slot = 1

local CurrentObject = nil
local CurrentPhysDistance = 0
local CurrentPhysRotation = Vector3.zero

function Fire(ply, mousePos, entityHit)
	print("Fire " .. Name)

	if entityHit then
		-- self should work here, I googled it at some point
		CurrentObject = entityHit

		local diff = entityHit.position - ply.position
		local angle = diff.normalized

		CurrentPhysDistance = diff.magnitude
	end
end

--[[ function Update()
	if CurrentObject ~= nil then
		
	end
end ]]