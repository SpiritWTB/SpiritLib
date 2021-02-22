--[[ Start SpiritLib Setup ]]
loadstring(PartByName("SpiritLib").scripts[1].Globals.SpiritLibSetup)
-- [[ End SpiritLib Setup ]]


Name = "The Physgun"
Description = "Moves and rotates objects and SpiritModels"
Slot = 1

local CurrentObject = nil
local CurrentPhysDistance = 0
local CurrentPhysRotation = Vector3.zero
local CurrentPhysHeight = 0

function Fire(ply, mousePos, entityHit)
	
	if entityHit then

		CurrentObject = entityHit
		CurrentObject.ignoreRaycast = true

		local diff = entityHit.position - ply.position
		local angle = diff.normalized

		CurrentPhysDistance = diff.magnitude

		CurrentPhysHeight = CurrentObject.position.y
	end
end

function FireRelease(ply, mousePos, entityHit)
	if CurrentObject ~= nil then
		CurrentObject.ignoreRaycast = false
		CurrentObject = nil
	end
end

function Update()
	if CurrentObject ~= nil then

		local mousePos = GetModule("Networking").Call("GetStreamedValue", "MousePos:" .. LocalPlayer().id)

		CurrentObject.position = newVector3(mousePos.x, CurrentPhysHeight, mousePos.z)  
	end
end