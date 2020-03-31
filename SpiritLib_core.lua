SpiritLib = {}

local modules = {
	Animation = false, 
	WeaponSystem  = false, 
	Attachment  = false, 
	Pathfinding  = false,
	PlayerData = false
}


-- attempt to load all the modules
for k, moduleName in pairs(modules) do
	-- the loader runs a script, which registers stuff with 
    local loader = CreatePart(0, newVector3(0, 0, 0), newVector3(0, 0, 0))
    loader.visible = false
    loader.cancollide = false

    -- Load module script
    loader.script = moduleName

    loader.scripts[1].SpiritLib = SpiritLib
    loader.scripts[1].ModuleName = moduleName

    if (loader.scripts[1]["LoadModule"] ~= nil) then
    	loader.scripts[1].Call("LoadModule")
	end

    print("Loading " .. v .. " module...")
end

-- call the Update functions in the modules if they exist
function Update()
	for moduleName, isLoaded in pairs(modules) do

		local Module = This.scripts[1][moduleName]

		if (Module ~= nil and Module.Update ~= nil) then
			Module.Update()
		end
	end
end

-- you don't have to use the return on this, you can just RequireModule and it will tell you if there's a problem
function RequireModule(_moduleName)
	if (modules[_moduleName] == nil) then
		print("Module " .. _moduleName .. " could not be found.")
		return false
	end

	if (modules[_moduleName] ~= true) then
		print("Module " .. _moduleName .. " could not load properly or has not finished loading.")
		return false
	end

	return true
end


function ModuleLoadFinished(_loader)
	if (_loader.scripts[1] ~= nil and _loader.scripts[1].ModuleName ~= nil) then
		if (modules[_loader.scripts[1].ModuleName] ~= nil) then
			modules[_loader.scripts[1].ModuleName] = true
		end
	else
		print("ERROR: Module name not found, please contact SpiritLib devs and make sure you're not deleting the loader parts while SpiritLib is loading modules.")
	end
end


function TableContains(_table, _value)
	for k,v in pairs(_table) do
		if (v == _value) then
			return true
		end
	end

	return false
end

