--[[ Start SpiritLib Setup ]]

local SL_UsedReturnTokens = {}
local function SpiritLib() return PartByName("SpiritLib").scripts[1] end
local function GetModuleVariable(moduleName, name) return SpiritLib().Globals.SpiritLib.Modules[moduleName].scripts[1].Globals[name] end
local function GetToken() local token = 1; while SL_UsedReturnTokens[token] do token = token + 1 end SL_UsedReturnTokens[token] = true; return token end
local function CallModuleFunction(moduleName, functionName, ...) local token = GetToken(); SpiritLib().Call("FixedCall", This, moduleName, functionName, "!SLToken" .. token, ...); SL_UsedReturnTokens[token] = nil; return This.table["!SLToken" .. token] end
function ReturnCall(caller, token, functionName, ...) caller.table[token] = _G[functionName](...) end

-- [[ End SpiritLib Setup ]]


Name = "The Packager"
Description = "Exports models"
Slot = 1

local objectCollection = {}

local markerCollection = {}

function Fire(ply, mousePos, entityHit)
	if entityHit and entityHit.type == "Part" and (not objectCollection[entityHit.id]) then
		objectCollection[entityHit] = entityHit.name

		table.insert(objectCollection, entityHit.id)
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
	clearCollection()
end


previousNames = {}
function Use(ply)

	saveModel(objectCollection)

	clearCollection()
end

function Update()
	if (CurrentObject ~= nil ) then
		
	end
end


function clearCollection()
	for i,marker in pairs(markerCollection) do
		marker.Remove()
	end

	objectCollection = {}
	markerCollection = {}
end

function saveModel(collection)
	local timename = "model_" .. tostring(Time.year) .. "-" .. tostring(Time.month) .. "-" .. tostring(Time.day) .. "-" .. tostring(Time.hour) .. "-" .. tostring(Time.minute) .. "-" .. tostring(Time.second) .. "-" .. tostring(Time.millisecond) 
	
	for part, name in pairs(collection) do
		part.name = timename
	end

	-- can't pass the collection of objects over, no tables
	CallModuleFunction("Models", "SaveModelByName", timename, "Freshly generated.", timename)

	for part, name in pairs(collection) do
		part.name = name
	end
end