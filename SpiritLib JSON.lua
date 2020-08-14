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

function SaveModel(name, parts)
	if type(name) ~= "string" or #name < 1 or type(parts) ~= "table" or #parts < 1 then
		return
	end

	local allParts = {}

	for i, part in pairs(parts) do
		local data = GenerateData(part)

		if data then
			table.insert(allParts, data)
		end
	end

	File.WriteCompressed(name, ToJson(allParts))
end

function LoadModel(name)
	if type(name) ~= "string" or #name < 1 then
		return
	end

	if not File.Exists(name) then
		return
	end

	local json = File.ReadCompressed(name)
	local allParts = FromJson(json)

	local returnData = {}

	for i, part in pairs(allParts) do
		local generated = GeneratePart(part)

		if generated then
			table.insert(returnData, generated)
		end
	end

	return returnData
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

local bruh = {PartByName("1"), PartByName("2"), PartByName("3")}

function Update()
	if InputPressed("q") then
		SaveModel("hurb", bruh)
	end
end