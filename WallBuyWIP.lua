PartByName("SpiritLib").scripts[1].Call("RegisterWallBuy", This, "Pistol")
--
	-- actual wallbuy script above, GameManager script below
--

-- make sure spiritlib is installed
local SpiritLibPart = PartByName("SpiritLib")
SpiritLib = SpiritLibPart.scripts[1]
if (SpiritLibPart == nil or SpiritLibPart.scripts[1] == nil) then print("WallBuys is built on SpiritLib, which cannot be found. Please install SpiritLib properly.") end
if (SpiritLib.WeaponSystem == nil) then print("WallBuys is built on SpiritLib.WeaponSystem, which cannot be found. Please install WeaponSystem properly.") end
if (SpiritLib.PlayerData == nil) then print("WallBuys is built on SpiritLib.PlayerData, which cannot be found. Please install PlayerData properly.") end


local buyDistance = 10
local isWithinDistance = false
local purchaseHintText

local WallBuyInfo = {
	
	Pistol = {
		price = 450,
		ammoPrice = 100
	},

	Shotgun = {
		price = 1050,
		ammoPrice = 300
	},

}

local WallBuyLocations = {}

function Update()
	CheckRadiusForKeypress()
end

function CheckRadiusForKeypress()
	local player = LocalPlayer();

	for wallBuyID, wallBuyLocation in pairs(WallBuyLocations) do

		local wallBuyPart = PartByID(wallBuyID)

		-- if the local player is in range
		if (Vector3.Distance(player.position, wallBuyPart.position) < buyDistance) then

			-- If they just entered into range, we're gonna show the "press e to buy" text
			if (!isWithinDistance) then
				isWithinDistance = true
				ShowPurchaseHint()
				-- show thingy
			end

			-- If we press e tell the server we want to buy this weapon
			if (InputPressed("e")) then
				NetworkSendToHost("tryBuyWeapon", {id = wallBuyID})
			end

		else
			isWithinDistance = false
			ClosePurchaseHint()
		end
	end
end

function ShowPurchaseHint()
	local textPos = newVector2(ScreenSize().x/2,ScreenSize().y/2);
	local textSize = 7
	purchaseHintText = MakeUIText(textPos, textSize, "Press E to buy a " + );
end

function ClosePurchaseHint()
	purchaseHintText.Close()
end

function OnConnect(_player)
	if (SpiritLib.PlayerData[_player] == nil) then
		SpiritLib.PlayerData[_player] = {} 
	end

	SpiritLib.PlayerData[_player].money = 0
end

function AddMoney(_player, _amount)
	SpiritLib.PlayerData[_player].money = SpiritLib.PlayerData[_player].money - _amount
end

function SetMoney(_player, _amount)
	SpiritLib.PlayerData[_player].money = _amount
end 

function NetworkStringReceive( _player, _msgName, _data )

	-- this message will only be sent to hosts, so this is host-side or server-side
	if (_msgName == "tryBuyWeapon") then

		-- get the wallbuy they're trying to buy from
		if (_data.id ~= nil) then
			local wallBuy = WallBuyLocations[_data.id]
			if (wallBuy ~= nil) then

				-- check the player position, make sure they're close enough to this wallbuy
				if (Vector3.Distance(_player.position, WallBuy.position) < buyDistance) then

					-- grab the price
					local weaponName = WallBuy.type
					local weaponPrice = WallBuyInfo[WallBuy.type].price

					-- make sure they have enough money for the weapon
					if (_player.money >= weaponPrice) then

						-- take away the cost of the weapon and give them the weapon
						AddMoney(_player, -weaponPrice)
						SpiritLib.WeaponSystem.Call("GiveWeapon", _player, weaponName)
					end
				end
			end
		end
	end
end

function RegisterWallBuy(_wallBuyPart, _type)
	WallBuyLocations[_wallBuyPart.id] = {
		type = _type,
		position = _wallBuyPart.position
	}
end