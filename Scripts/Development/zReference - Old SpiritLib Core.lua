SpiritLib = {}

local modules = {
	Animation = false, 
	WeaponSystem  = false, 
	Attachment  = false, 
	Pathfinding  = false,
	PlayerData = false
}

local moduleLoaders = {}

function Start()
	-- attempt to load all the modules
	for moduleName, v in pairs(modules) do
		-- the loader runs a script, which registers stuff with 
	    local loader = CreatePart(0, newVector3(0, 0, 0), newVector3(0, 0, 0))
	    loader.visible = false
	    loader.cancollide = false
	
	    -- Load module script
	    loader.script = moduleName

	    moduleLoaders[moduleName] = loader
	

		if (loader ~=nil and loader.scripts[1]~= nil and loader.scripts[1].Globals.SpiritLib[moduleName] ~= nil) then
		
			SpiritLib[moduleName] = SafeGetTable(loader.scripts[1], loader.scripts[1].Globals.SpiritLib[moduleName])
	
		    print("Loading " .. moduleName .. " module...")
		else
			if (moduleName ~= nil) then
				print("module " .. moduleName .. " failed to load")
			end
		end
	end


	SpiritLib.Pathfinding.Baker.BakeNodeMap()
end


function SafeGetTable(_script, _table, _moduleName)
	local copy = {}

	for k,v in pairs(_table) do
		-- if it's a table go through again, this will be recursive since tables seem to be the problem
		if (type(v) == "table") then
			copy[k] = SafeGetTable(_script, v)
		elseif (type(v) == "function") then
			copy[k] = v
		else
			print(type(v))
			copy[k] = v
		end
	end

	return copy
end



local regsiteredOverrides = {}

function HookFunction(_overrideFunctionName, _function)
	if (TableContains(registeredOverrides, _overrideFunctionName)) then
		local originalFunction = This.scripts[1][_overrideFunctionName];
		This.scripts[1][_overrideFunctionName] = function(...)
			originalFunction(...)
			_function(...)
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
	if (_loader.scripts[1] ~= nil and _loader.scripts[1].Global.ModuleName ~= nil) then
		if (modules[_loader.scripts[1].Globals.ModuleName] ~= nil) then
			modules[_loader.scripts[1].Globals.ModuleName] = true
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


