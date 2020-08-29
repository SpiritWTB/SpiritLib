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

		function SpawnModel(name, objectJSON, position)
			local weaponPart = CallModuleFunction("Models", "GenerateModel", objectJSON, position)
			weaponPart.name = name

			return weaponPart
		end

		function GiveWeapon(player, weaponName)

			-- make sure the player has an inventory and that the weapon we're trying to give them exists
			if not playerWeaponInventories[player] or not WeaponsByName[weaponName] then
				print("Giveweapon statement invalid.")
				return
			end

			local slot = WeaponsByName[weaponName].weaponSlot

			-- if they don't have any weapons in this slot yet add a table to this slot for their weapons

			if not playerWeaponInventories[player][slot] then
				playerWeaponInventories[player][slot] = {}
			end

			-- copy the table of the weapon we're giving them
			local weaponTableInstance = CopyTable(WeaponsByName[weaponName])

			-- todo use LoadModel instead of just CreatePart, we need it to return before we can do that though
			weaponTableInstance.part = SpawnModel(weaponTableInstance.name, weaponTableInstance.modelJson, player.position) --CallModuleFunction("Models", "GenerateModel", weapon.model, )
			weaponTableInstance.part.frozen = true
			weaponTableInstance.part.cancollide = false
			weaponTableInstance.part.angles = player.angles

			CallModuleFunction("Attachments", "Attach", weaponTableInstance.part, player)

			weaponTableInstance.part.script = weaponTableInstance.weaponScript
			
			weaponTableInstance.slot = slot
			weaponTableInstance.indexInSlot = #playerWeaponInventories[player][slot] + 1
			
			table.insert(playerWeaponInventories[player][slot], weaponTableInstance)
		end

	-- [[ End Useful Functions Section]]



	-- [[ Begin Setup Section]]

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
			-- no weapons equipped, do nothing
			if CountTable(playerWeaponInventories[player]) < 1 then return end

			-- increase the index in the slot
			player.table.SelectedWeaponIndexInSlot = player.table.SelectedWeaponIndexInSlot + 1

			-- if there's no weapon there, go back to in-slot-index 1 and bump forward to the next slot 
			if not playerWeaponInventories[player][player.table.SelectedWeaponIndexInSlot] then
				player.table.SelectedWeaponIndexInSlot = 1

				-- if we get to the end of the players weapon inventory we go back to the beginning
				slotNumber = rolloverIndex(slotNumber + 1, playerWeaponInventories[player])
			end

		end

		function PreviousItem(player)
			-- no weapons equipped, do nothing
			if CountTable(playerWeaponInventories[player]) < 1 then return end

			-- increase the index in the slot
			player.table.SelectedWeaponIndexInSlot = player.table.SelectedWeaponIndexInSlot - 1

			-- if there's no weapon there, go back to in-slot-index 1 and bump forward to the next slot 
			if not playerWeaponInventories[player][player.table.SelectedWeaponIndexInSlot] then
				player.table.SelectedWeaponIndexInSlot = 1

				-- if we get to the end of the players weapon inventory we go back to the beginning
				slotNumber = rolloverIndex(slotNumber - 1, playerWeaponInventories[player])
			end
		end

		-- Selects the slot index inside the given slot number
		function SelectSlot(player, slotNumber, slotIndex)
			if not player then
				print("SelectIndexSlot: Player argument can't be null")
				return
			end

			if not slotNumber or type(slotNumber) ~= "number" or slotNumber < 1 then
				print("SelectIndexSlot: Invalid slot number")
				return
			end

			if not slotIndex or type(slotIndex) ~= "number" or slotIndex < 1 then
				print("SelectIndexSlot: Invalid slot index")
				return
			end

			local originalSlot = player.table.SelectedWeaponSlot
			local originalIndex = player.table.SelectedWeaponSlotIndex
			local slotChanged = false

			if originalSlot and originalSlot ~= slotNumber then
				player.table.SelectedWeaponSlot = slotNumber
				slotChanged = true
			end

			if originalIndex and originalIndex ~= slotIndex then
				player.table.SelectedWeaponSlotIndex = slotIndex
				slotChanged = true
			end

			if slotChanged then
				local oldSlot = playerWeaponInventories[player][originalSlot]
				local oldWeapon = oldSlot[originalIndex].part
			end
		end

		function SelectSlot(player, slotNumber)
			-- no weapons equipped, do nothing
			if CountTable(playerWeaponInventories[player]) < 1 then return end

			-- if we get to the end of the players weapon inventory we go back to the beginning
			slotNumber = rolloverIndex(slotNumber, playerWeaponInventories[player])

			-- if we keep pressing 1 it will loop through the things in slot 1
			local originalSlot = player.table.SelectedWeaponSlot
			local originalIndex = player.table.SelectedWeaponIndexInSlot

			-- increase the slot number with rollover. If we selected the same slot we're on select the next thing in it
			if player.table.SelectedWeaponSlot ~= slotNumber then
				player.table.SelectedWeaponSlot = slotNumber
				player.table.SelectedWeaponIndexInSlot = 1
			else
				player.table.SelectedWeaponIndexInSlot = player.table.SelectedWeaponIndexInSlot + 1

				if not playerWeaponInventories[player][player.table.SelectedWeaponIndexInSlot] then
					player.table.SelectedWeaponIndexInSlot = 1
				end
			end

			-- if we actually changed,
			if originalSlot ~= player.table.SelectedWeaponSlot or originalIndex ~= player.table.SelectedWeaponIndexInSlot then
				print("Bob1")
				print(originalSlot)
				print("Bob2")
				print(originalIndex)

				local oldSlot = playerWeaponInventories[player][originalSlot]
				local oldWeapon = oldSlot[originalIndex].part

				print("change")
				if oldSlot then
					if oldSlot[originalIndex] and oldWeapon then
						print("valid")

						if oldSlot[originalIndex].part.table.SpiritLibWeaponUI then
							oldSlot[originalIndex].part.table.SpiritLibWeaponUI.Remove()
						end

						print("ui removed")
						print(0)
						CallModuleFunction("Attachments", "DeleteAttachments", oldWeapon)
						print(1)
						oldWeapon.Remove()
						print(2)
						print("m")
					end
				end
			end
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
		selectedUIBox.color = newColor(selectedUIBox.color.r, selectedUIBox.color.g, selectedUIBox.color.b, 0)

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

		for k,v in pairs(slotUIBoxes) do
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

	function HostReceive(client, name, data)
		if not client then return end
		if name == "requestWeapon" then
			if GetModuleVariable("Q Menu", "ModuleSettings").AllowedSpawnTypes["Models"] then
				GiveWeapon(client, data[1], data[2])
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
			if client.table.SelectedWeaponSlot ~= nil and client.table.SelectedWeaponIndexInSlot ~= nil then
				local slot = client.table.SelectedWeaponSlot
				local idInSlot = client.table.SelectedWeaponIndexInSlot

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

				if data[1] == 1 then
					playerWeaponInventories[client][slot][idInSlot].part.scripts[1].Call("Fire", client, mousePos, hitObject)
				elseif data[1] == 2 then
					playerWeaponInventories[client][slot][idInSlot].part.scripts[1].Call("FireRelease", client)
				elseif data[1] == 3 then
					playerWeaponInventories[client][slot][idInSlot].part.scripts[1].Call("AltFire", client, mousePos, hitObject)
				elseif data[1] == 4 then
					playerWeaponInventories[client][slot][idInSlot].part.scripts[1].Call("AltFireRelease", client)
				elseif data[1] == 5 then
					playerWeaponInventories[client][slot][idInSlot].part.scripts[1].Call("Reload", client, mousePos, hitObject)
				elseif data[1] == 6 then
					playerWeaponInventories[client][slot][idInSlot].part.scripts[1].Call("Use", client, mousePos, hitObject)
				elseif data[1] == 7 then
					playerWeaponInventories[client][slot][idInSlot].part.scripts[1].Call("Special", client, mousePos, hitObject)
				end
			end
		end
	end

	function ClientReceive(host, name, data)
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