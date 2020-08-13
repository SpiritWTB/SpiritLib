local cachedPlayers = {}

function SLOnConnect(playerInfo)
	print(playerInfo.name .. " joined in!")
end

function SLOnDisconnect(playerInfo)
	print(playerInfo.name .. " bruh....")
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
				SLOnDisconnect(player)
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
			SLOnConnect(playerInfo)
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
	SLOnConnect(playerInfo)
else
	NetworkSendToHost("Connected", {})
end