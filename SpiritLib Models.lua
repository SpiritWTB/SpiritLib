local SpiritLib = function() return PartByName("SpiritLib").scripts[1] end

function CallModuleFunction(moduleName, name, ...) return SpiritLib().Globals.SpiritLib.Modules[moduleName].scripts[1].Call(name, ...) end
function GetModuleVariable(moduleName, name) return SpiritLib().Globals.SpiritLib.Modules[moduleName].scripts[1].Globals[name] end

local function CreateBoundingBox(parts)
	if type(parts) ~= "table" or #parts < 1 then
		return
	end

	local corners = {}

	for i, part in pairs(parts) do
		local fDir = part.forward * (part.size.x / 2)
		local rDir = part.right * (part.size.z / 2)
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
		--[[ local point = CreatePart(1, corner, Vector3.zero)
		point.size = newVector3(0.1, 0.1, 0.1) ]]

		if corner.x > xMax then xMax = corner.x end
		if corner.x < xMin then xMin = corner.x end
		if corner.y > yMax then yMax = corner.y end
		if corner.y < yMin then yMin = corner.y end
		if corner.z > zMax then zMax = corner.z end
		if corner.z < zMin then zMin = corner.z end
	end

	-- get half of the difference between these. Basically, these 3 are the distances it takes to get halfway from min to max (for that axis)
	local diff = newVector3(xMax - xMin, yMax - yMin, zMax - zMin)
	local center = newVector3(xMin + diff.x / 2, yMin + diff.y / 2, zMin + diff.z / 2)

	local encompasser = CreatePart(0, center, Vector3.zero)
	encompasser.size = diff
	encompasser.color = newColor(1, 0, 0, 0.5)

	for i, part in pairs(parts) do
		part.frozen = true
		part.cancollide = false
		part.parent = encompasser
	end

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
	output.color = part.color
	output.bevel = part.bevel
	output.visible = part.visible
	output.cancollide = part.cancollide

	if part.script then
		output.script = part.script
	end

	return output
end

local function GeneratePart(data)
	local part = CreatePart(data.parttype, data.position + newVector3(0, 5, 0), data.angles)
	part.name = data.name
	part.size = data.size
	part.color = newColor(data.color.x, data.color.y, data.color.z, data.color.w)
	part.bevel = data.bevel
	part.visible = data.visible
	part.cancollide = data.cancollide

	if data.script then
		part.script = data.script
	end

	return part
end

function SaveModel(name, description, parts)
	if type(name) ~= "string" or #name < 1 or type(description) ~= "string" or #description < 1 or type(parts) ~= "table" or #parts < 1 then
		print("Invalid model setup for" .. tostring(name))
		return
	end

	print("saving model: " .. name)

	local allParts = {
		name = name,
		description = description,
		data = {}
	}

	for i, part in pairs(parts) do
		local data = GenerateData(part)

		if data then
			table.insert(allParts.data, data)
		end
	end

	File.WriteCompressed("model_" .. name, ToJson(allParts))
end

function GenerateModel(modelTable, --[[optional]]position)
	local modelParts = {}

	for i, part in pairs(modelTable.data) do
		local generated = GeneratePart(part)

		if generated then
			table.insert(returnData, generated)
		end
	end

	local rootPart
	
	if (modelParts) then
		rootPart = CreateBoundingBox(modelParts)
	else
		print("Issue creating model - modelParts does not exist")
	end

	rootPart.name = modelTable.name

	if (position ~= nil) then
		rootPart.position = position
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
		local generated = GeneratePart(part)

		if generated then
			table.insert(returnData, generated)
		end
	end

	return returnData
end

function Update()
	if InputPressed("q") then
		--SaveModel("hurb", bruh)
	elseif InputPressed("e") then
		--local model = LoadModel("hurb")
	end

	if (InputPressed("t")) then
		SaveModel("WoodCrate", "A small wooden crate", PartsByName("WoodCrate"))
		SaveModel("Physgun", "The model to be for the Physgun weapon", PartsByName("Physgun"))
		SaveModel("Traffic Cone", "A classic orange and white traffic cone", PartsByName("TrafficCone"))
		SaveModel("Fence ", "A fence piece to be used for yard fences or insecure walls", PartsByName("Fence"))
	end
end

