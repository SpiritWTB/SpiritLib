--[[ Start SpiritLib Setup ]]

local SL_UsedReturnTokens = {}
local function SpiritLib() return PartByName("SpiritLib").scripts[1] end
local function GetModuleVariable(moduleName, name) return SpiritLib().Globals.SpiritLib.Modules[moduleName].scripts[1].Globals[name] end
local function GetToken() local token = 1; while SL_UsedReturnTokens[token] do token = token + 1 end SL_UsedReturnTokens[token] = true; return token end
local function CallModuleFunction(moduleName, functionName, ...) local token = GetToken(); SpiritLib().Call("FixedCall", This, moduleName, functionName, "!SLToken" .. token, ...); SL_UsedReturnTokens[token] = nil; return This.table["!SLToken" .. token] end
function ReturnCall(caller, token, functionName, ...) caller.table[token] = _G[functionName](...) end

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

	NetworkSendToHost("selectWeaponSlot", {entryNumber})
end

function ProcessFire(_input)

	local hitdata = RayCast(LocalPlayer().viewPosition, MousePosWorld());

	local hitObjectID = nil
	local hitObjectType = nil
	if (hitdata.hitObject ~= nil) then
		if (hitdata.hitObject.type == "Part") then
			hitObjectType = 1
		elseif (hitdata.hitObject.type == "Player") then
			hitObjectType = 2
		end

		hitObjectID = hitdata.hitObject.id

	end

	NetworkSendToHost("weaponInput", {_input, MousePosWorld(), hitObjectType, hitObjectID})
end

function Update()
	if InputPressed("x") then
		PreviousItem()
	elseif InputPressed("c") then
		NextItem()
	end

	if InputPressed("mouse 0") then
		ProcessFire(1)
	elseif InputReleased("mouse 0") then
		NetworkSendToHost("weaponInput", {2})
	elseif InputPressed("mouse 1") then
		ProcessFire(3)
	elseif InputReleased("mouse 1") then
		NetworkSendToHost("weaponInput", {4})
	elseif InputPressed("r") then
		NetworkSendToHost("weaponInput", {5})
	elseif InputPressed("e") then
		NetworkSendToHost("weaponInput", {6})
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

	if index == 10 then
		return "0"
	elseif index == 11 then
		return "-"
	elseif index == 12 then
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

function SpawnModel(name, objectJSON, position)
	local weaponPart = CallModuleFunction("Models", "GenerateModel", objectJSON, position)
	weaponPart.name = name

	return weaponPart
end

function GiveWeapon(player, weaponName, slot)
	if not playerWeaponInventories[player] or not WeaponsByName[weaponName] then
		return
	end

	local weaponTableInstance = CopyTable(WeaponsByName[weaponName])

	-- todo use LoadModel instead of just CreatePart, we need it to return before we can do that though
	weaponTableInstance.part = SpawnModel(weaponTableInstance.name, weaponTableInstance.modelJson, player.position) --CallModuleFunction("Models", "GenerateModel", weapon.model, )
	weaponTableInstance.part.frozen = true
	weaponTableInstance.part.cancollide = false
	weaponTableInstance.part.angles = player.angles

	CallModuleFunction("Attachments", "Attach", weaponTableInstance.part, player)

	weaponTableInstance.part.script = weaponTableInstance.weaponScript

	playerWeaponInventories[player][slot] = weaponTableInstance
	player.table.SelectedWeaponSlot = slot
	print("weapon give successful")
end

RegisteredWeapons = {}
WeaponsByName = {}

function RegisterWeapon(name, scriptName, modelJson)
	if not name or not scriptName or not modelJson then
		return
	end

	local weaponTable = FromJson(modelJson)
	weaponTable.modelJson = modelJson

	table.insert(RegisteredWeapons, weaponTable)
	WeaponsByName[weaponTable.name] = weaponTable
end

function NetworkStringReceive(player, name, data)
	if IsHost and name == "selectWeaponSlot" then
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

	if IsHost and name == "weaponInput" and player.table.SelectedWeaponSlot ~= nil then

		local slot = player.table.SelectedWeaponSlot

		if data[1] == 1 then
			local mousePos = data[2]

			local objectType = nil
			local objectID = nil

			if data[3] then
				objectType = data[3]
				objectID = data[4]
			end

			local hitObject = nil
			if objectType == 1 then
				hitObject = PartByID(objectID)
			elseif objectType == 2 then
				hitObject = PlayerByID(objectID)
			end

			playerWeaponInventories[player][slot].part.scripts[1].Call("Fire", player, mousePos, hitObject)

		elseif data[1] == 2 then
			playerWeaponInventories[player][slot].part.scripts[1].Call("FireRelease", player)
		elseif data[1] == 3 then
			playerWeaponInventories[player][slot].part.scripts[1].Call("AltFire", player, mousePos, hitObject)
		elseif data[1] == 4 then
			playerWeaponInventories[player][slot].part.scripts[1].Call("AltFireRelease", player)
		elseif data[1] == 5 then
			playerWeaponInventories[player][slot].part.scripts[1].Call("Reload", player)
		elseif data[1] == 6 then
			playerWeaponInventories[player][slot].part.scripts[1].Call("Use", player)
		end
	end
end


function InitializeWeapons()
	-- RegisterWeapon( "Physgun", "Weapon Physgun", GetModuleVariable("Default Models", "BuiltInModels"))
end

InitializeWeaponInventories()
InitializeWeapons()

-- http://lua-users.org/wiki/CopyTable

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