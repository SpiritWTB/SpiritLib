--[[
===========            v    SpiritLib Notes:    v            ===========


Don't forget there are always more errors in your log file! Go to windows explorer and paste in or navigate to:           %appdata%\..\LocalLow\happyninjagames\WorldToBuild

DO NOT CLICK ON THE "SpiritLib Default Models" SCRIPT file in the script editor unless you want to wait a while

To use SpiritLib effectively, you must always add the "SpiritLib Setup" section to the beginning of your script. 
This gives you access to GetModule( moduleName).Call( functionName, arguments ), which returns values as well

You cannot pass certain types, (namely functions & tables) between scripts.
If you check the log file and see errors about


You CAN however call a function on another script. To do this easily set up your script as a SpiritLib module, so that you can call your scripts functions with CallModuleFunciton:
	- Ddd it to the SpiritLib.Modules table below as ["<your_module_name>"]
	- Do one of these:
		- name your script "SpiritLib <your_module_name>" and paste it in the script editor
		- add your script to your "SpiritLib\Scripts" folder, name the file "SpiritLib <your_module_name>" and run the SpiritLib installer on your file

If you're making a weapon, the weaponScript must start with the same prefix as the other weaponScripts. In other words it must be called "Weapon <your_weapon_name>".


===========            ^    SpiritLib Notes:    ^            =========== ]]


SpiritLibSetup = [[
	local CachedSpiritLibPart = nil

	local function SpiritLib()
		if (CachedSpiritLibPart == nil) then
			CachedSpiritLibPart = PartByName('SpiritLib')
		end
		return CachedSpiritLibPart.scripts[1] 
	end

	local function GetModule(moduleName)
			return SpiritLib().Globals.SpiritLib.Modules[moduleName].scripts[1]
	end
]]

SpiritLib = {}
SpiritLib.Modules = {
	["Core"] = This,

	["Networking"] = false,
	["MousePos"] = false,
	["Attachments"] = false,
	["Default Objects"] = false,
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



-- dunno if we can use this from here but lets keep it around so it doesn't get lost
-- it takes pitch/yaw/roll angles and converts them to direction vector like blah.forward
function AngleToDirectionVector(_angle)
	return newVector3( math.cos(_angle.y)*math.cos(_angle.x), math.sin(_angle.y)*math.cos(_angle.x), math.sin(_angle.x) )
end