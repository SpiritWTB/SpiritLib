--[[ Start SpiritLib Setup ]]

local SL_UsedReturnTokens = {}
local function SpiritLib() return PartByName("SpiritLib").scripts[1] end
local function GetModuleVariable(moduleName, name) return SpiritLib().Globals.SpiritLib.Modules[moduleName].scripts[1].Globals[name] end
local function GetToken() local token = 1; while SL_UsedReturnTokens[token] do token = token + 1 end SL_UsedReturnTokens[token] = true; return token end
local function CallModuleFunction(moduleName, functionName, ...) local token = GetToken(); SpiritLib().Call("FixedCall", This, moduleName, functionName, "!SLToken" .. token, ...); SL_UsedReturnTokens[token] = nil; return This.table["!SLToken" .. token] end
function ReturnCall(caller, token, functionName, ...) caller.table[token] = _G[functionName](...) end

-- [[ End SpiritLib Setup ]]

local slotCount = 10
local slotUIBoxSize = newVector2(52, 52)
local slotUIBoxSpacing = 6

local slotUIBoxes = {}
local selectedUIBox = nil
-- when we run out of things in the slot we will go to the next slot (todo: make sure that doesn't crash if there's no weapons trying to constantly move left or right or both)

local myPly = LocalPlayer()

local slotUIHolderSize = newVector2(((slotUIBoxSize.x + slotUIBoxSpacing) * slotCount) - slotUIBoxSpacing, slotUIBoxSize.y)
local slotUIHolderPos = newVector2((ScreenSize().x / 2) - (slotUIHolderSize.x / 2), ScreenSize().y - slotUIHolderSize.y - 36)
local slotUIHolder = MakeUIPanel(slotUIHolderPos, slotUIHolderSize)
slotUIHolder.color = newColor(0, 0, 0, 0)


-- [[ Begin Host Section]]

	-- [[ Begin Utility Functions Section]]

		local function CopyTable(orig, --[[optional]]copies)
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

		local function CountTable(_table)
			local count = 0
			for k,v in pairs(_table) do
				count = count + 1
			end
			return count
		end

		local function rolloverIndex(_index, _table)
			if not _table[_index] then
				if _index < 1 then
					_index = #_table
				else
					_index = 1
				end
			end

			return _index
		end

	-- [[ End Utility Functions Section]]



	-- [[ Begin Useful Functions Section]]

		function SpawnModel(name, position)
			local weaponPart = CallModuleFunction("Models", "GenerateKnownModel", name, position)
			weaponPart.name = name

			return weaponPart
		end

		function InstantiateAndAttachWeapon(_player, _weaponTable)

			-- todo use LoadModel instead of just CreatePart, we need it to return before we can do that though
			local part = SpawnModel(_weaponTable.name, _player.position + _player.forward*0.7)

			part.frozen = true
			part.cancollide = false
			part.angles = _player.angles

			CallModuleFunction("Attachments", "Attach", part, _player)

			part.script = _weaponTable.weaponScript

			return part
		end

		function GiveWeapon(player, weaponName, shouldEquip)

			local weaponTemplate = WeaponsByName[weaponName]
			local playerInventory = playerWeaponInventories[player]

			-- make sure the player has an inventory and that the weapon we're trying to give them exists
			if not playerInventory or not weaponTemplate then
				print("Giveweapon statement invalid.")
				return
			end

			-- figure out what slot the weapon wants
			local weaponSlot = weaponTemplate.weaponSlot

			-- if the player doesn't have the slot the weapon wants, create it
			if not playerInventory[weaponSlot] then
				playerInventory[weaponSlot] = {}
			end

			-- go through the weapons slot, make sure they don't already have this weapon
			for k,v in pairs(playerInventory[weaponSlot]) do
				if v.name == weaponName then
					print("You already have this weapon!")
				end
			end

			-- figure out where the weapon will go in the slot
			local weaponSlotIndex = #playerInventory[weaponSlot] + 1

			local currentSlot = player.table.SelectedWeaponSlot
			local currentSlotIndex = player.table.SelectedWeaponSlotIndex

			-- if we by off chance added a weapon to a slot we already have equipped, select the current slot
			if currentSlot and currentSlotIndex and currentSlot == weaponSlot and currentSlotIndex == weaponSlotIndex then
				SelectSlot(player, weaponSlot, weaponSlotIndex)
				return
			end

			-- if they don't have any weapons in this slot yet add a table to this slot for their weapons to be listed in
			if not playerInventory[weaponSlot] then
				playerInventory[weaponSlot] = {}
			end


			-- make a new instance of the weapon template table
			local weaponTableInstance = CopyTable(weaponTemplate)
			weaponTableInstance.template = weaponTemplate

			weaponTableInstance.slot = weaponSlot
			weaponTableInstance.slotIndex = weaponSlotIndex

			weaponTableInstance.part = InstantiateAndAttachWeapon(player, weaponTemplate)
			

			table.insert(playerInventory[weaponSlot], weaponTableInstance)

			if shouldEquip then
				SelectSlot(player, weaponSlot, weaponSlotIndex)
			end
		end

	-- [[ End Useful Functions Section]]



	-- [[ Begin Setup Section]]

		RegisteredWeapons = {}
		WeaponsByName = {}

		function RegisterWeapon(name, objectJson)
			if not name or not objectJson then
				return
			end

			local weaponTable = FromJson(objectJson)
			weaponTable.objectJson = objectJson

			table.insert(RegisteredWeapons, weaponTable)
			WeaponsByName[weaponTable.name] = weaponTable
		end

		-- TODO: RUN THIS ON FIXED CONNECT
		function InitializeWeaponInventories()
			-- use player ID as key, table as a value
			playerWeaponInventories = {}

			for _, ply in pairs(GetAllPlayers()) do
				playerWeaponInventories[ply] = {}
			end
		end

	-- [[ End Setup Section]]



	-- [[ Begin Selection Functions ]]

		function NextItem(player)
			local playerInventory = playerWeaponInventories[player]

			-- no weapons equipped, do nothing
			if CountTable(playerInventory) < 1 then return end

			-- increase the index in the slot
			player.table.SelectedWeaponSlotIndex = player.table.SelectedWeaponSlotIndex + 1

			-- if there's no weapon there, go back to in-slot-index 1 and bump forward to the next slot 
			if not playerInventory[player.table.SelectedWeaponSlotIndex] then
				player.table.SelectedWeaponSlotIndex = 1

				-- if we get to the end of the players weapon inventory we go back to the beginning
				slotNumber = rolloverIndex(slotNumber + 1, playerInventory)
			end

		end

		function PreviousItem(player)
			local playerInventory = playerWeaponInventories[player]

			-- no weapons equipped, do nothing
			if CountTable(playerInventory) < 1 then return end

			-- increase the index in the slot
			player.table.SelectedWeaponSlotIndex = player.table.SelectedWeaponSlotIndex - 1

			-- if there's no weapon there, go back to in-slot-index 1 and bump forward to the next slot 
			if not playerInventory[player.table.SelectedWeaponSlotIndex] then
				player.table.SelectedWeaponSlotIndex = 1

				-- if we get to the end of the players weapon inventory we go back to the beginning
				slotNumber = rolloverIndex(slotNumber - 1, playerInventory)
			end
		end

		-- Selects the slot index inside the given slot number
		function SelectSlot(player, slotNumber, slotIndex)
			print("SelectSlot: Input:  Slot Number:" .. tostring(slotNumber) .. ",  Index in slot: " .. tostring(slotIndex))

			if not player then
				print("SelectIndexSlot: Player argument can't be null")
				return
			end

			if not slotNumber or type(slotNumber) ~= "number" or slotNumber < 1 then
				print("SelectIndexSlot: Invalid slot number")
				return
			end

			if not slotIndex or type(slotIndex) ~= "number" or slotIndex < 1 then
				slotIndex = 1

				-- print("SelectIndexSlot: Invalid slot index")
				-- return
			end

			local originalSlot = player.table.SelectedWeaponSlot
			local originalIndex = player.table.SelectedWeaponSlotIndex
			local slotChanged = false

			if originalSlot ~= slotNumber then
				player.table.SelectedWeaponSlot = slotNumber
				slotChanged = true
			end

			if originalIndex ~= slotIndex then
				player.table.SelectedWeaponSlotIndex = slotIndex
				slotChanged = true
			end

			if slotChanged then

				-- remove the old weapon if we need to
				local oldSlot = playerWeaponInventories[player][originalSlot]
				local oldWeaponExists = oldSlot and oldSlot[originalIndex] and oldSlot[originalIndex].part

				if oldWeaponExists then

					local oldWeapon = oldSlot[originalIndex].part

					if oldWeapon then
						if oldWeapon.table and oldWeapon.table.SpiritLibWeaponUI then
							oldWeapon.table.SpiritLibWeaponUI.Remove()
						end

						CallModuleFunction("Attachments", "Remove", oldWeapon)
						oldSlot[originalIndex].part = nil
					end
				end

				-- if we're re-equipping a weapon we need to recreate it
				local newSlot = playerWeaponInventories[player][player.table.SelectedWeaponSlot]
				if newSlot then
					local newWepTable = newSlot[player.table.SelectedWeaponSlotIndex]
					if newWepTable and newWepTable.part == nil then
						newWepTable.part = InstantiateAndAttachWeapon(player, newWepTable)

					end
				end
				NetworkSendToPlayer("setSelectedBox", {slotNumber}, player)
			end

			print("SelectSlot: Final:  Slot Number:" .. tostring(player.table.SelectedWeaponSlot) .. ",  Index in slot: " .. tostring(player.table.SelectedWeaponSlotIndex))
		end
	-- [[ End Selection Functions ]]



-- [[ End Host Section ]]






-- [[ Begin Client Section ]]


	function ProcessFire(_input)
		local hitdata = RayCast(LocalPlayer().viewPosition, MousePosWorld());

		local hitObjectID = nil
		local hitObjectType = nil
		if hitdata and hitdata.hitObject then
			if (hitdata.hitObject.type == "Part") then
				hitObjectType = 1
			elseif (hitdata.hitObject.type == "Player") then
				hitObjectType = 2
			end

			hitObjectID = hitdata.hitObject.id

		end

		NetworkSendToHost("weaponInput", {_input, MousePosWorld(), hitObjectType, hitObjectID})
	end

	function HandleNetworkInputs()
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
		elseif InputPressed("g") then
			NetworkSendToHost("weaponInput", {7})
		end
	end

	local function selectUIBox(slot)
		if selectedUIBox then
			selectedUIBox.color = newColor(selectedUIBox.color.r, selectedUIBox.color.g, selectedUIBox.color.b, 0)
		end

		selectedUIBox = slotUIBoxes[slot]

		selectedUIBox.color = newColor(selectedUIBox.color.r, selectedUIBox.color.g, selectedUIBox.color.b, 0.4)

	end

	function Update()
		if InputPressed("x") then
			NetworkSendToHost("previousWeapon", {})
			--PreviousItem()
		elseif InputPressed("c") then
			NetworkSendToHost("nextWeapon", {})
			--NextItem()
		end

		HandleNetworkInputs()

		for k, v in pairs(slotUIBoxes) do
			if InputPressed(v.table.keyBind) then
				NetworkSendToHost("selectSlot", {v.table.index})
			end
		end
	end

	function SpawnUIBoxes()
		for i = 1, slotCount do
			local keyBind = IndexToKeyBind(i)

			local boxBGPos = newVector2(((slotUIBoxSize.x + slotUIBoxSpacing) * i), 0)
			local boxBG = MakeUIPanel(boxBGPos, slotUIBoxSize, slotUIHolder)
			boxBG.color = newColor(0.14, 0.14, 0.14, 0.76)

			local box = MakeUIPanel(newVector2(1, 1), newVector2(slotUIBoxSize.x - 2, slotUIBoxSize.y - 2), boxBG)

			local labelText = "<b>" .. keyBind .. "</b>"

			local boxNumberLabel = MakeUIText(newVector2(4, 4), newVector2(box.size.x - 8, box.size.y - 8), labelText, box)
			boxNumberLabel.textColor = newColor(0.8, 0.8, 0.8, 0.4)
			boxNumberLabel.textAlignment = "TopRight"

			local alpha = 0
			if i == originalSlot then
				alpha = 0.4
			end

			box.color = newColor(boxBG.color.r + 0.28, boxBG.color.g + 0.28, boxBG.color.b + 0.28, alpha)

			box.table.keyBind = keyBind
			box.table.index = i

			table.insert(slotUIBoxes, box)
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


-- [[ End Client Section]]






-- [[ Begin Networking Section]]

	-- split these for simplicity/visibility, this system makes my head spin
	function NetworkStringReceive(sender, name, data)
		if IsHost then
			HostReceive(sender, name, data)
		end

		-- only accept info from the host for security sake. You can't even do that without hacking your client
		if sender.IsHost() then
			ClientReceive(sender, name, data)
		end
	end

	function FunctionExists(part, functionName)

		if part and part.scripts[1] then
			if part.scripts[1].Globals[functionName] and type(part.scripts[1].Globals[functionName]) == "function" then
				return true
			end
		end

		return false
	end

	function HostReceive(client, name, data)
		if not client then return end
		if name == "requestWeapon" then
			if GetModuleVariable("Q Menu", "ModuleSettings").AllowedSpawnTypes["Models"] then
				GiveWeapon(client, data[1], true)
			end
		end

		if name == "nextWeapon" then
			NextItem(client)
		elseif name == "previousWeapon" then
			PreviousItem(client)
		elseif name == "selectSlot" then
			SelectSlot(client, data[1])
		end

		if name == "weaponInput" then
			if client.table.SelectedWeaponSlot ~= nil and client.table.SelectedWeaponSlotIndex ~= nil then
				local slot = client.table.SelectedWeaponSlot
				local idInSlot = client.table.SelectedWeaponSlotIndex

				local slotHasWeaponAtIndex = (playerWeaponInventories[client] and playerWeaponInventories[client][slot] and playerWeaponInventories[client][slot][idInSlot])

				if slotHasWeaponAtIndex then

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

					local weapon = playerWeaponInventories[client][slot][idInSlot].part

					if data[1] == 1 then
						if FunctionExists(weapon, "Fire") then
							weapon.scripts[1].Call("Fire", client, mousePos, hitObject)
						end
					elseif data[1] == 2 then
						if FunctionExists(weapon, "FireRelease") then
							weapon.scripts[1].Call("FireRelease", client)
						end
					elseif data[1] == 3 then
						if FunctionExists(weapon, "AltFire") then
							weapon.scripts[1].Call("AltFire", client, mousePos, hitObject)
						end
					elseif data[1] == 4 then
						if FunctionExists(weapon, "AltFireRelease") then
							weapon.scripts[1].Call("AltFireRelease", client)
						end
					elseif data[1] == 5 then
						if FunctionExists(weapon, "Reload") then
							weapon.scripts[1].Call("Reload", client, mousePos, hitObject)
						end
					elseif data[1] == 6 then
						if FunctionExists(weapon, "Use") then
							weapon.scripts[1].Call("Use", client, mousePos, hitObject)
						end
					elseif data[1] == 7 then
						if FunctionExists(weapon, "Special") then
							weapon.scripts[1].Call("Special", client, mousePos, hitObject)
						end
					end
				end
			end
		end
	end

	function ClientReceive(host, name, data)
		print("ClientRec: " .. name)
		if name == "setSelectedBox" then
			selectUIBox(data[1])
		end
	end

-- [[ End Networking Section]]






-- http://lua-users.org/wiki/CopyTable

print("Loaded weapons successfully!")
if not IsHost then return end

function Start()
	InitializeWeaponInventories()
end