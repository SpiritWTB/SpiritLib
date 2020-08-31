--[[
===========            v    SpiritLib Notes:    v            ===========


Don't forget there are always more errors in your log file! Go to windows explorer and paste in or navigate to:           %appdata%\..\LocalLow\happyninjagames\WorldToBuild

DO NOT CLICK ON THE "SpiritLib Default Models" SCRIPT file in the script editor unless you want to wait a while

To use SpiritLib effectively, you must always add the "SpiritLib Setup" section to the beginning of your script. 
This gives you access to CallModuleFunction( moduleName, functionName, arguments ), which returns values as well

You cannot pass certain types, (namely functions & tables) between scripts.
If you check the log file and see errors about


You CAN however call a function on another script. To do this easily set up your script as a SpiritLib module, so that you can call your scripts functions with CallModuleFunciton:
	- Ddd it to the SpiritLib.Modules table below as ["<your_module_name>"]
	- Do one of these:
		- name your script "SpiritLib <your_module_name>" and paste it in the script editor
		- add your script to your "SpiritLib\Scripts" folder, name the file "SpiritLib <your_module_name>" and run the SpiritLib installer on your file

===========            ^    SpiritLib Notes:    ^            =========== ]]


SpiritLib = {}
SpiritLib.Modules = {
	["Core"] = This,

	["Attachments"] = false,
	["Default Models"] = false,
	["Models"] = false,
	["Weapons"] = false,
	["Q Menu"] = false,
}

function Start()
	This.name = "SpiritLib"

	for name, part in pairs(SpiritLib.Modules) do
		if not part then
			local modulePart = CreatePart(0)
			modulePart.visible = false
			modulePart.cancollide = false
			modulePart.name = "SpiritLib " .. name
			modulePart.script = "SpiritLib " .. name

			SpiritLib.Modules[name] = modulePart

			print(name .. " module started!")
		end
	end

	LoadFinished()
end

-- this doesn't work yet, try to call this later so we can do init stuff once all the modules are loaded
function LoadFinished()
	for name, part in pairs(SpiritLib.Modules) do
		if part and part.type and part.type == "Part" then
			if part.script ~= nil and part.scripts[1].Globals["OnSpiritLibLoaded"] then
				part.scripts[1].Call("OnSpiritLibLoaded")
			end
		end
	end
end

function FixedCall(caller, moduleName, functionName, token, ...)
	local activeModule = SpiritLib.Modules[moduleName]

	if activeModule then
		if activeModule.scripts[1].Globals["ReturnCall"] then
			if activeModule.scripts[1].Globals[functionName] and type(activeModule.scripts[1].Globals[functionName]) == "function" then
				activeModule.scripts[1].Call("ReturnCall", caller, token, functionName, ...)
			else
				print("CallModuleFunction: Module \"" .. moduleName .. "\" does not contain function \"" .. functionName .. "\"")
			end
		else
			print("CallModuleFunction: Module \"" .. moduleName .. "\" has not implemented ReturnCall. Add this function to the module you're trying to call.")
		end
	else
		print("CallModuleFunction: Module \"" .. moduleName .. "\" does not exist.")
	end
end

function ReturnCall(caller, token, functionName, ...)
	caller.table.spiritLibReturns[token] = _G[functionName](...)
end



-- hooks

local hookedFunctions = {}

function CallHook(_hookName, ...)
	for hookName, part in pairs(hookedFunctions) do
		if part == nil then
			print("CallHook: Invalid part")
		elseif part.scripts[1] == nil then
			print("CallHook: Part has no script")
		elseif part.scripts[1].Globals[_hookName] == nil then
			print("CallHook: Function does not exist")
		elseif type(part.scripts[1].Globals[_hookName]) ~= "function" then
			print("CallHook: Not a function")
		else
			part.scripts[1].Call(_hookName, ...)
		end
	end
end

function HookFunction(_part, _hookName)
	if (hookedFunctions[_hookName] == nil) then
		hookedFunctions[_hookName] = {}
	end

	table.insert(hookedFunctions[_hookName], _part )
end


-- fixed connect

local cachedPlayers = {}

function FixedOnConnect(playerInfo)
	print(playerInfo.name .. " joined in!")
	CallHook("FixedOnConnect")
end

function FixedOnDisconnect(playerInfo)
	print(playerInfo.name .. " bruh....")
	CallHook("FixedOnConnect")
end

function OnDisconnect()
	if IsHost then
		local allPlayers = GetAllPlayers()

		for id, player in pairs(cachedPlayers) do
			local isOnline = false

			for i, onlinePlr in pairs(allPlayers) do
				if player.id == onlinePlr.id then
					isOnline = true
					break
				end
			end

			if not isOnline then
				FixedOnDisconnect(player)
				cachedPlayers[id] = nil
			end
		end
	end
end

function NetworkStringReceive(player, name, data)
	if name == "Connected" then
		if not cachedPlayers[player.id] then
			local playerInfo = {
				id = player.id,
				name = player.name,
				WTBID = player.WTBID
			}

			cachedPlayers[player.id] = playerInfo
			FixedOnConnect(playerInfo)
		end
	end
end

if IsHost then
	local playerInfo = {
		id = LocalPlayer().id,
		name = LocalPlayer().name,
		WTBID = LocalPlayer().WTBID
	}

	cachedPlayers[LocalPlayer().id] = playerInfo
	FixedOnConnect(playerInfo)
else
	NetworkSendToHost("Connected", {})
end