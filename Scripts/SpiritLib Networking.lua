--[[ Start SpiritLib Setup ]]
loadstring(PartByName("SpiritLib").scripts[1].Globals.SpiritLibSetup)
-- [[ End SpiritLib Setup ]]

local StreamedValues = {}
local VacantSVO = nil

local SyncedValues = {}

local function IsEmpty(input)
	if input == nil then
		return true
	elseif type(input) == "string" then
		return string.match(input, "%S") == nil
	elseif type(input) == "table" then
		return next(input) == nil
	else
		return false
	end
end

local function IsVector3(input)
	return type(input) == "userdata" and input.x ~= nil and input.y ~= nil and input.z ~= nil
end

function CreateStreamedValue(name, --[[optional]] value, --[[optional]] invokerID)
	if not invokerID then
		invokerID = LocalPlayer().WTBID
	end

	-- print(name, value, invokerID)

	if IsEmpty(name) then
		print("A streamed value needs to have a name.")
	else
		name = tostring(name)
	end

	if StreamedValues[name] then
		print("Error: A streamed value of this name already exists!")
		return
	end

	if IsEmpty(value) then
		value = 0
	elseif type(value) ~= "number" and not IsVector3(value) then
		print("Error: The starting value can only be a number or Vector3.")
		return
	end

	if not IsHost then
		NetworkSendToHost("ProxyCreateStreamedValue", {name, value})
		return
	end

	StreamedValues[name] = {
		name = name,
		ownerID = invokerID,
		object = nil,
		entry = 0,
		type = 0
	}

	if IsVector3(value) then
		StreamedValues[name].type = 2
	else
		StreamedValues[name].type = 1
	end

	local svType = StreamedValues[name].type

	if VacantSVO and svType == 1 then
		local temp = VacantSVO.object.position

		StreamedValues[name].object = VacantSVO.object
		StreamedValues[name].entry = VacantSVO.open

		if VacantSVO.open == 1 then
			temp.x = value
		elseif VacantSVO.open == 2 then
			temp.y = value
		elseif VacantSVO.open == 3 then
			temp.z = value
		end

		StreamedValues[name].object.position = temp
	else
		local temp = CreatePart(0, newVector3(0, 0, 0), newVector3(0, 0, 0))

		temp.size = newVector3(0, 0, 0)
		temp.cancollide = false

		-- TO-DO: Wait until network fix for other clients
		temp.visible = false

		if svType == 1 then
			temp.position = newVector3(value, 0, 0)

			VacantSVO = {
				object = temp,
				open = 1
			}
		elseif svType == 2 then
			temp.position = value
		end

		StreamedValues[name].object = temp
		StreamedValues[name].entry = 1
	end

	if VacantSVO then
		if VacantSVO.open < 3 then
			VacantSVO.open = VacantSVO.open + 1
		else
			VacantSVO = nil
		end
	end

	NetworkSendToAll("AddStreamedValue", {StreamedValues[name], StreamedValues[name].object.id})
end

function GetStreamedValue(name)
	if IsEmpty(name) then
		print("You can't update an empty streamed value name.")
		return
	else
		name = tostring(name)
	end

	if not StreamedValues[name] then
		print("Unable to find " .. name .. " streamed value.")
		return
	end

	local entry = StreamedValues[name].entry
	local object = StreamedValues[name].object
	local svType = StreamedValues[name].type

	if svType == 1 then
		if entry == 1 then
			return object.position.x
		elseif entry == 2 then
			return object.position.y
		elseif entry == 3 then
			return object.position.z
		end
	elseif svType == 2 then
		return object.position
	end
end

function UpdateStreamedValue(name, value, invokerID)
	if not invokerID then
		invokerID = LocalPlayer().WTBID
	end

	if IsEmpty(name) then
		print("You can't update an empty streamed value name.")
		return
	else
		name = tostring(name)
	end

	if not StreamedValues[name] then
		print("Unable to find the " .. name .. " streamed value.")
		return
	end

	if invokerID ~= StreamedValues[name].ownerID then
		print("Unauthorized to change the " .. name .. " streamed value.")
		return
	end

	if IsEmpty(value) then
		value = 0
	elseif type(value) ~= "number" and not IsVector3(value) then
		print("Error: The starting value can only be a number or Vector3.")
		return
	end

	if not IsHost then
		NetworkSendToHost("ProxyUpdateStreamedValue", {name, value})
		return
	end

	local entry = StreamedValues[name].entry
	local object = StreamedValues[name].object
	local svType = StreamedValues[name].type

	if svType == 1 then
		if IsEmpty(value) then
			value = 0
		elseif type(value) ~= "number" then
			print("Error: The starting value can only be a number.")
			return
		end
	elseif svType == 2 and not IsVector3(value) then
		print("Error: The starting value can only be a Vector3.")
		return
	end

	local temp = object.position

	if svType == 1 then
		if entry == 1 then
			temp.x = value
		elseif entry == 2 then
			temp.y = value
		elseif entry == 3 then
			temp.z = value
		end
	elseif svType == 2 then
		temp = value
	end

	object.position = temp
end

function SetSyncedValue(name, --[[optional]] value, --[[optional]] invokerID)
	if not invokerID then
		invokerID = LocalPlayer().WTBID
	end

	if IsEmpty(name) then
		print("A synced value needs to have a name.")
	else
		name = tostring(name)
	end

	if SyncedValues[name] and invokerID ~= SyncedValues[name].ownerID then
		print("Unauthorized to change the " .. name .. " synced value.")
		return
	end

	if SyncedValues[name] then
		if invokerID ~= SyncedValues[name].ownerID then
			print("Unauthorized to change the " .. name .. " synced value.")
			return
		end

		SyncedValues[name].value = value
	else
		SyncedValues[name] = {
			name = name,
			value = value,
			ownerID = invokerID
		}
	end

	if IsHost then
		NetworkSendToAll("SetSyncedValue", SyncedValues[name])
	else
		NetworkSendToHost("ProxySetSyncedValue", SyncedValues[name])
	end
end

function GetSyncedValue(name)
	if IsEmpty(name) then
		print("You can't update an empty synced value name.")
		return
	else
		name = tostring(name)
	end

	if not SyncedValues[name] then
		print("Unable to find " .. name .. " synced value.")
		return
	end

	return SyncedValues[name].value
end

function NetworkStringReceive(player, name, data)
	if name == "AddStreamedValue" and player.IsHost() then
		data[1].object = PartByID(data[2])

		StreamedValues[data[1].name] = data[1]

		-- string.sub(data[1].name, 1, string.find(data[1].name, ":") - 1)
		if string.match(data[1].name, "MousePos") ~= nil then
			for i, plr in pairs(GetAllPlayers()) do
				if plr.WTBID == data[1].ownerID then
					plr.table["MousePosObject"] = data[1].object
				end
			end
		end

	elseif name == "SetSyncedValue" and player.IsHost() then
		SyncedValues[data.name] = data

	elseif name == "ProxyCreateStreamedValue" then
		CreateStreamedValue(data[1], data[2], player.WTBID)

	elseif name == "ProxyUpdateStreamedValue" then
		UpdateStreamedValue(data[1], data[2], player.WTBID)

	elseif name == "ProxySetSyncedValue" then
		SetSyncedValue(data.name, data.value, player.WTBID)
	end
end

--[[ function Update()
	if InputPressed("z") then
		CreateStreamedValue("Test", newVector3(1, 2, 4))
	elseif InputPressed("x") then
		print(GetStreamedValue("Test"))
	elseif InputPressed("c") then
		UpdateStreamedValue("Test", newVector3(10, 20, 40))
	elseif InputPressed("v") then
		SetSyncedValue("Bob", newVector2(420, 69))
	elseif InputPressed("b") then
		SetSyncedValue("Bob", newVector2(42, 1337))
	elseif InputPressed("n") then
		print(GetSyncedValue("Bob"))
	elseif InputPressed("m") then
		NetworkSendToHost("AddStreamedValue", {})
	end
end ]]