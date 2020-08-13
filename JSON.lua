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
	output.script = part.script

	return output
end

local function GeneratePart(data)
	local part = CreatePart(data.parttype, data.position, data.angles)
	part.name = data.name
	part.size = data.size
	part.color = data.color
	part.bevel = data.bevel
	part.visible = data.visible
	part.cancollide = data.cancollide
	part.script = data.script
end

function SaveWorld(name)
	local allParts = {}

	for i, part in pairs(GetAllParts()) do
		local data = GenerateData(part)

		if data then
			table.insert(allParts, data)
		end
	end

	File.Write(name, ToJson(allParts))
end

function LoadWorld(name)
	if File.Exists(name) then
		local json = File.Read(name)
		local allParts = FromJson(json)

		for i, part in pairs(allParts) do
			GeneratePart(part)
		end
	end
end

function Update()
	if InputPressed("q") then
		SaveWorld("Bruh")
	elseif InputPressed("e") then
		LoadWorld("Bruh")
	end
end