--[[ Start SpiritLib Setup ]]

local SL_UsedReturnTokens = {}
local function SpiritLib() return PartByName("SpiritLib").scripts[1] end
local function GetModuleVariable(moduleName, name) return SpiritLib().Globals.SpiritLib.Modules[moduleName].scripts[1].Globals[name] end
local function GetToken() local token = 1; while SL_UsedReturnTokens[token] do token = token + 1 end SL_UsedReturnTokens[token] = true; return token end
local function CallModuleFunction(moduleName, functionName, ...) local token = GetToken(); SpiritLib().Call("FixedCall", This, moduleName, functionName, "!SLToken" .. token, ...); SL_UsedReturnTokens[token] = nil; return This.table["!SLToken" .. token] end
function ReturnCall(caller, token, functionName, ...) caller.table[token] = _G[functionName](...) end

-- [[ End SpiritLib Setup ]]


-- put all weapon ui in This.table.SpiritLibWeaponUI

Name = "The Packager"
Description = "Exports models"
Slot = 1

print(Name .. " initialized")

local objectCollection = {}
local markerCollection = {}

instantMode = false

function Fire(ply, mousePos, entityHit)
	if entityHit and entityHit.type == "Part" and (not objectCollection[entityHit.id]) then

		if instantMode then
			CallModuleFunction("Models", "SaveModelByName", entityHit.name, "Freshly generated.", entityHit.name)
		else
			if not objectCollection[entityHit] then
				objectCollection[entityHit] = entityHit.name
				local marker = CreatePart(entityHit.parttype, entityHit.position, entityHit.angles)

				local s = 0.015
				marker.size = entityHit.size + newVector3(s,s,s)
				marker.transparency = 0.8
				marker.color = newColor(0.3, 0.85, 0.3, 0.2)
				marker.ignoreRaycast = true

				table.insert(markerCollection, marker)
			end
		end
	end
end

instantModeIndicator = MakeUIText(newVector2(4, 4), newVector2(150, 180), "Instant mode is ON:")
instantModeIndicator.textColor = newColor(255, 0.3, 0.1, 0.6)
instantModeIndicator.textSize = 20
This.table.SpiritLibWeaponUI = instantModeIndicator

function Update()

	local mousepos = MousePosWorld()
	local player = LocalPlayer()

	local viewDirection = newVector3( math.cos(player.viewAngles.y)*math.cos(player.viewAngles.x), math.sin(player.viewAngles.y)*math.cos(player.viewAngles.x), math.sin(player.viewAngles.x) )
	local raycastStart = mousepos - viewDirection*0.04
	local hitdata = RayCast(raycastStart, mousepos + viewDirection * 0.04);

	local onOff ="OFF"
	if instantMode then
		onOff = "ON"
	end

	if hitdata and hitdata.hitObject then
		if (hitdata.hitObject.type == "Part") then
			instantModeIndicator.text = "Instant mode is " .. onOff .. ":\n" .. hitdata.hitObject.name
		end
	else
		instantModeIndicator.text = "Instant mode is " .. onOff .. ":"
	end
end

function Special(ply, mousePos, entityHit)

	instantMode = not instantMode

	if instantMode then
		instantModeIndicator.enabled = true
	else
		instantModeIndicator.enabled = false	
	end
end

function Reload(ply, mousePos, entityHit)
	clearCollection()
end

function Use(ply, mousePos, entityHit)
	saveModel(objectCollection)
	clearCollection()
end



function clearCollection()
	for i,marker in pairs(markerCollection) do
		marker.Remove()
	end

	objectCollection = {}
	markerCollection = {}
end

function timeString()
	return "model_" .. tostring(Time.year) .. "-" .. tostring(Time.month) .. "-" .. tostring(Time.day) .. "-" .. tostring(Time.hour) .. "-" .. tostring(Time.minute) .. "-" .. tostring(Time.second) .. "-" .. tostring(Time.millisecond) 
	
end

function saveModel(collection)
	local timename = timeString()

	for part, name in pairs(collection) do
		part.name = timename
	end

	-- can't pass the collection of objects over, no tables, have to name everything then set it back
	CallModuleFunction("Models", "SaveModelByName", timename, "Freshly generated.", timename)

	for part, name in pairs(collection) do
		part.name = name
	end
end

print("loaded packager successfully")