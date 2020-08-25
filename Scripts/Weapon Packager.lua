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


Name = "The Packager"
Description = "Exports models"
Slot = 1

local objectCollection = {}
local markerCollection = {}

function Fire(ply, mousePos, entityHit)
	if entityHit and entityHit.type == "Part" and (not objectCollection[entityHit]) then
		objectCollection[entityHit] = true
		table.insert(objectCollection, entityHit)
		local marker = CreatePart(entityHit.parttype, entityHit.position, entityHit.angles)

		local s = 0.015
		marker.size = entityHit.size + newVector3(s,s,s)
		marker.transparency = 0.8
		marker.color = newColor(0.3, 0.85, 0.3, 0.2)
		marker.ignoreRaycast = true

		table.insert(markerCollection, marker)
	end
end

function Reload(ply)
	objectCollection = {}

	for i,marker in pairs(markerCollection) do
		marker.Remove()
	end
	markerCollection = {}
end

function Use(ply)
	
	local timename = "model_" .. tostring(Time.year) .. "-" .. tostring(Time.month) .. "-" .. tostring(Time.day) .. "-" .. tostring(Time.hour) .. "-" .. tostring(Time.minute) .. "-" .. tostring(Time.second) .. "-" .. tostring(Time.millisecond) 
	
	local partsIDs = {}

	for i, part in pairs(objectCollection) do
		table.insert(partsIDs,part.id)
	end

	CallModuleFunction("Models", "SaveModel", timename, "Freshly generated.", partsIDs)
end

function Update()
	if (CurrentObject ~= nil ) then
		
	end
end