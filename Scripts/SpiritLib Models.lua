--[[ Start SpiritLib Setup ]]
loadstring(PartByName("SpiritLib").scripts[1].Globals.SpiritLibSetup)
-- [[ End SpiritLib Setup ]]

local function CreateBoundingBox(parts)
	if type(parts) ~= "table" or #parts < 1 then
		return
	end

	local corners = {}

	for i, part in pairs(parts) do
		local fDir = part.forward * (part.size.z / 2)
		local rDir = part.right * (part.size.x / 2)
		local uDir = part.up * (part.size.y / 2)

		table.insert(corners, part.position + fDir + rDir + uDir)
		table.insert(corners, part.position + fDir + rDir - uDir)
		table.insert(corners, part.position + fDir - rDir + uDir)
		table.insert(corners, part.position + fDir - rDir - uDir)
		table.insert(corners, part.position - fDir + rDir + uDir)
		table.insert(corners, part.position - fDir + rDir - uDir)
		table.insert(corners, part.position - fDir - rDir + uDir)
		table.insert(corners, part.position - fDir - rDir - uDir)
	end

	local xMax, xMin, yMax, yMin, zMax, zMin = corners[1].x, corners[1].x, corners[1].y, corners[1].y, corners[1].z, corners[1].z

	for i, corner in pairs(corners) do
		if corner.x > xMax then xMax = corner.x end
		if corner.x < xMin then xMin = corner.x end
		if corner.y > yMax then yMax = corner.y end
		if corner.y < yMin then yMin = corner.y end
		if corner.z > zMax then zMax = corner.z end
		if corner.z < zMin then zMin = corner.z end
	end

	local diff = newVector3(xMax - xMin, yMax - yMin, zMax - zMin)
	local center = newVector3(xMin + diff.x / 2, yMin + diff.y / 2, zMin + diff.z / 2)

	local encompasser = CreatePart(0, center, Vector3.zero)
	encompasser.size = diff
	encompasser.visible = false
	encompasser.ignoreRaycast = true

	local renderParent = CreatePart(0, center, Vector3.zero)
	renderParent.cancollide = false
	renderParent.frozen = true
	renderParent.visible = false
	renderParent.ignoreRaycast = true

	for i, part in pairs(parts) do
		part.parent = renderParent
		part.cancollide = false
	end

	GetModule("Attachments").Call("Attach", renderParent, encompasser, false)

	encompasser.frozen = false
	encompasser.cancollide = true

	return encompasser
end

local function GenerateData(part)
	local output = {}

	if part.light or part.particles or part.text then
		return
	end

	output.name = part.name
	output.parttype = part.parttype
	output.position = part.position
	output.angles = part.angles
	output.size = part.size
	output.color = newColor(part.color.r, part.color.g, part.color.b, 1 - part.transparency)
	output.bevel = part.bevel
	output.visible = part.visible
	output.cancollide = part.cancollide

	if part.script then
		output.script = part.script
	end

	return output
end

local function GeneratePart(data, --[[optional = false]] isMapPart, ignoreRaycast)
	local part = CreatePart(data.parttype, data.position, data.angles)
	part.name = data.name
	part.size = data.size
	part.color = newColor(data.color.x, data.color.y, data.color.z, data.color.w)
	part.bevel = data.bevel
	part.visible = data.visible
	part.cancollide = data.cancollide

	if isMapPart then
		part.frozen = data.frozen
	else
		part.ignoreRaycast = ignoreRaycast or true
	end

	if data.script then
		part.script = data.script
	end

	return part
end

function SaveModelByName(name, description, partsName)
	SaveObject("Models", name, description, PartsByName(partsName))
end

--can't use this from CallModuleFunction because it uses a table of parts
function SaveModel(name, description, parts)
	SaveObject("Models", name, description, parts)
end

function SaveObject(objectType, name, description, parts)
	if type(objectType) ~= "string" or #objectType < 1 or type(name) ~= "string" or #name < 1 or type(description) ~= "string" or #description < 1 or type(parts) ~= "table" or #parts < 1 then
		print("Invalid model setup for" .. tostring(name))
		return
	end

	print("saving model: " .. name)

	local allParts = {
		name = name,
		description = description,
		objectType = objectType,
		data = {}
	}

	for i, part in pairs(parts) do
		local data = GenerateData(part)

		if data then
			table.insert(allParts.data, data)
		end
	end

	File.Write("model_" .. name, ToJson(allParts))
end

function GenerateKnownModel(name, --[[optional]] position, --[[optional]]ignoreRaycast)
	print("trying to generate model " .. name)
	print(ModelsByName[name].objectJson)
	if ModelsByName[name] and ModelsByName[name].objectJson then
		return GenerateModel(ModelsByName[name].objectJson, position or Vector3.zero, ignoreRaycast)
	end
end

function GenerateModel(objectJson, --[[optional]]position, --[[optional]]ignoreRaycast, --[[optional]]partNameOverride)
	print("Generating model...")

	local modelTable

	if type(objectJson) == "string" then
		print(1)
		modelTable = FromJson(objectJson)
	end

	local modelParts = {}

	for i, part in pairs(modelTable.data) do
		local generated = GeneratePart(part, false, ignoreRaycast)

		if generated then
			table.insert(modelParts, generated)
		end
	end

	local rootPart

	if (modelParts) then
		rootPart = CreateBoundingBox(modelParts)
		rootPart.name = modelTable.name

		if position then
			rootPart.position = position
		end
	else
		print("Issue creating model - modelParts does not exist")
	end

	return rootPart
end

function LoadModel(name)
	if type(name) ~= "string" or #name < 1 then
		return
	end

	if not File.Exists(name) then
		return
	end

	local json = File.ReadCompressed(name)
	local modelTable = FromJson(json)

	return GenerateModel(modelTable)
end

function SaveWorld(name)
	if type(name) ~= "string" or #name < 1 then
		return
	end

	local allParts = {}

	for i, part in pairs(GetAllParts()) do
		local data = GenerateData(part)

		if data then
			table.insert(allParts, data)
		end
	end

	File.WriteCompressed(name, ToJson(allParts))
end

function LoadWorld(name)
	if type(name) ~= "string" or #name < 1 then
		return
	end

	if not File.Exists(name) then
		return
	end

	local json = File.ReadCompressed(name)
	local allParts = FromJson(json)

	for i, part in pairs(GetAllParts()) do
		part.Remove()
	end

	local returnData = {}

	for i, part in pairs(allParts) do
		local generated = GeneratePart(part, true)

		if generated then
			table.insert(returnData, generated)
		end
	end

	return returnData
end

RegisteredModels = {}
ModelsByName = {}

function RegisterModel(name, objectJson)
	if not name or not objectJson then
		return
	end

	local modelTable = FromJson(objectJson)
	modelTable.objectJson = objectJson

	table.insert(RegisteredModels, modelTable)
	ModelsByName[modelTable.name] = modelTable
	
end