print("physgun started")
--[[ Start SpiritLib Setup ]]

local SpiritLib = function() return PartByName("SpiritLib").scripts[1] end

-- Calls functions from SpiritLib modules, and uses special sauce to give their return value
function CallModuleFunction(moduleName, functionName, ...) 
	local token = SpiritLib().Globals.SpiritLib.Call("GetToken", This)
	SpiritLib().Globals.SpiritLib.FixedCall(moduleName, functionName, token, ...) 
	return This.table.spiritLibReturns[token]
end

-- gets variables from SpiritLib modules
function GetModuleVariable(moduleName, name) return SpiritLib().Globals.SpiritLib.Modules[moduleName].scripts[1].Globals[name] end

-- this is our special cross-script version of "return"
function ReturnCall(caller, token, functionName, ...) caller.table.spiritLibReturns[token] = _G[functionName](...) end

-- [[ End SpiritLib Setup ]]


Name = "The Grabber"
Description = "Moves and rotates objects and SpiritModels"
Slot = 1

local CurrentObject = nil
local CurrentPhysDistance = 0
local CurrentPhysRotation = Vector3.zero

function Fire(ply, mousePos, entityHit)

	print(ply)
	print(mousePos)
	print(entityHit)
	
	-- self should work here, I googled it at some point
	CurrentObject = hitEnt

	local diff = hitEnt.position - ply.position
	local angle = diff.normalized

	CurrentPhysDistance = diff.magnitude


	


end

function Update()
	if (CurrentObject ~= nil ) then
		
	end
end