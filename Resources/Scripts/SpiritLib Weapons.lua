--[[ Start SpiritLib Setup ]]

local SpiritLib = function() return PartByName("SpiritLib").scripts[1] end

-- Calls functions from SpiritLib modules, and uses special sauce to give their return value
function CallModuleFunction(moduleName, functionName, ...) 
	local token = SpiritLib().Globals.SpiritLib.Call("GetToken", This)
	SpiritLib().Globals.SpiritLib.FixedCall(moduleName, functionName, token, ...) 
	return This.table.spiritLibReturns[token]
end

-- gets variables from SpiritLib modules
function GetModuleVariable(moduleName, name) return SpiritLib().Globals.SpiritLib.Modules[moduleName].scripts[1].Globals[name] end

-- this is our special cross-script version of "return"
function ReturnCall(caller, token, functionName, ...) caller.table.spiritLibReturns[token] = _G[functionName](...) end

-- [[ End SpiritLib Setup ]]


local boxesCount = 10
local boxesSize = newVector2(52, 52)
local boxesSpacing = 6

local allBoxes = {}
local current = 1

local boxesHolderSize = newVector2(((boxesSize.x + boxesSpacing) * boxesCount) - boxesSpacing, boxesSize.y)
local boxesHolderPos = newVector2((ScreenSize().x / 2) - (boxesHolderSize.x / 2), ScreenSize().y - boxesHolderSize.y - 36)
local boxesHolder = MakeUIPanel(boxesHolderPos, boxesHolderSize)
boxesHolder.color = newColor(0, 0, 0, 0)

function NextItem()
	SelectItem(current + 1)
end

function PreviousItem()
	SelectItem(current - 1)
end

function SelectItem(entryNumber)

	-- loop the value around so we don't have to do it in PreviousItem and NextItem
	if not allBoxes[entryNumber] then

		if entryNumber < 0 then
			entryNumber = boxesCount
		else
			entryNumber = 0
		end

	end

	allBoxes[current].color = newColor(allBoxes[current].color.r, allBoxes[current].color.g, allBoxes[current].color.b, 0)
	current = entryNumber
	allBoxes[current].color = newColor(allBoxes[current].color.r, allBoxes[current].color.g, allBoxes[current].color.b, 0.4)

	NetworkSendToHost("selectWeaponSlot", { entryNumber })
end

function Update()
	if InputPressed("x") then
		PreviousItem()
	elseif InputPressed("c") then
		NextItem()
	end

	if (InputPressed("mouse 1")) then
		NetworkSendToHost("weaponInput", {1})
	end

	for k,v in pairs(allBoxes) do
		if InputPressed(v.table.keyBind) then
			SelectItem(v.table.index)
		end
	end

end

function SpawnUIBoxes()
	for i = 1, boxesCount do

		local keyBind = IndexToKeyBind(i)
		

		local boxBGPos = newVector2(((boxesSize.x + boxesSpacing) * i), 0)
		local boxBG = MakeUIPanel(boxBGPos, boxesSize, boxesHolder)
		boxBG.color = newColor(0.14, 0.14, 0.14, 0.76)

		local box = MakeUIPanel(newVector2(1, 1), newVector2(boxesSize.x - 2, boxesSize.y - 2), boxBG)

		local labelText = "<b>" .. keyBind .. "</b>"

		local boxNumberLabel = MakeUIText(newVector2(4, 4), newVector2(box.size.x - 8, box.size.y - 8), labelText, box)
		boxNumberLabel.textColor = newColor(0.8, 0.8, 0.8, 0.4)
		boxNumberLabel.textAlignment = "TopRight"

		local alpha = 0
		if i == current then
			alpha = 0.4
		end
		
		box.color = newColor(boxBG.color.r + 0.28, boxBG.color.g + 0.28, boxBG.color.b + 0.28, alpha)

		box.table.keyBind = keyBind
		box.table.index = i

		table.insert(allBoxes, box)
	end
end

function IndexToKeyBind(index)

	local keyBind = tostring(index)

	if (index==10) then
		return "0"
	elseif (index==11) then
		return "-"
	elseif (index==12) then
		return "="
	end

	return keyBind
end

SpawnUIBoxes()




if not IsHost then return end

-- TODO: RUN THIS ON FIXED CONNECT
function InitializeWeaponInventories()
	-- use player ID as key, table as a value
	playerWeaponInventories = {}

	for _, ply in pairs(GetAllPlayers()) do
		playerWeaponInventories[ply] = {}
		ply.table.SelectedWeaponSlot = nil
	end
end 

local usedPartNameIndices = {}
local function GetUniqueName()
	local index = 1
	
	while usedPartNameIndices[index] do
		index = index + 1
	end

	local uniqueName = "SpiritLibWeapon##Spawned##//" .. index
	usedPartNameIndices[uniqueName] = true

	return uniqueName
end

local function RemoveUniqueName(uniqueName)
	usedPartNameIndices[uniqueName] = nil
end

function SpawnModel(objectJSON, position)
	local uniqueName = GetUniqueName()

	CallModuleFunction("Models", "GenerateModel", objectJSON, position, uniqueName)
	local weaponPart = PartByName(uniqueName)
	weaponPart.name = weapon
	RemoveUniqueName(uniqueName)
end

function GiveWeapon(player, weaponName, slot)
	if (playerWeaponInventories[player] ~= nil and WeaponsByName[weaponName]~=nil) then

		local weaponTableInstance = CopyTable(WeaponsByName[weaponName])

		local me = LocalPlayer()

		-- todo use LoadModel instead of just CreatePart, we need it to return before we can do that though
		weaponTableInstance.part = SpawnModel(weapon.json, me.position + me.forward) --CallModuleFunction("Models", "GenerateModel", weapon.model, )



		weaponTableInstance.part.frozen = true
		weaponTableInstance.part.cancollide = false

		weaponTableInstance.part.angles = LocalPlayer().angles

		CallModuleFunction("Attachments", "Attach", rootPart, LocalPlayer())

		weaponTableInstance.part.script = weaponTableInstance.weaponScript

		playerWeaponInventories[player][slot] = weaponTableInstance
		player.table.SelectedWeaponSlot = slot
	end
end

RegisteredWeapons = {}
WeaponsByName = {}

function RegisterWeapon(name, scriptName, modelJson)
	-- check to make sure they've got a name and stuff, basic things that will break the game if they aren't there
	if not name then return end
	if not scriptName then return end
	if not modelJson then return end

	local weaponTable = FromJson(modelJson)

	table.insert(RegisteredWeapons, weaponTable)
	WeaponsByName[weaponTable.name] = weaponTable
end

function NetworkStringReceive(player, name, data)

	if IsHost() and name=="selectWeaponSlot" then
		if playerWeaponInventories[player][data[1]] ~= nil then
			player.table.SelectedWeaponSlot = data[1]
		end
	end

	--[[
	
		weaponInput
	-------------------

		1 = Fire
		2 = FireRelease
		3 = AltFire
		4 = AltFireRelease
		5 = Reload
	]]


	if IsHost() and name == "weaponInput" and player.table.SelectedWeaponSlot ~= nil then
		local slot = player.table.SelectedWeaponSlot

		if data[1] == 1 then
			playerWeaponInventories[player][slot].part.scripts[1].Call("Fire")
		elseif data[1] == 2 then
			playerWeaponInventories[player][slot].part.scripts[1].Call("FireRelease")
		elseif data[1] == 3 then
			playerWeaponInventories[player][slot].part.scripts[1].Call("AltFire")
		elseif data[1] == 4 then
			playerWeaponInventories[player][slot].part.scripts[1].Call("AltFireRelease")
		elseif data[1] == 5 then
			playerWeaponInventories[player][slot].part.scripts[1].Call("Reload")
		end

	end
end


function InitializeWeapons()

	--RegisterWeapon( "Physgun", "Weapon Physgun", GetModuleVariable("Default Models", "BuiltInModels"))

end


InitializeWeaponInventories()
InitializeWeapons()


--http://lua-users.org/wiki/CopyTable

function CopyTable(orig, --[[optional]]copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[CopyTable(orig_key, copies)] = CopyTable(orig_value, copies)
            end
            setmetatable(copy, CopyTable(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end