--
	-- WallBuy Module Usage:

	-- 			make a script with, PartByName("SpiritLib").scripts[1].Call("RegisterWallBuy", This, "Pistol") (<- old syntax, needs update)
	-- 			switch out "Pistol" for the weapon you want
	-- 			make sure the Weapon exists in the WallBuyInfo table, AND that there is a Weapon of the same name registered in SpiritLib.WeaponSystem 
--

	SpiritLib.Call("RequireModule", "WeaponSystem")
	SpiritLib.Call("RequireModule", "PlayerData")

	buyDistance = 10
	isWithinDistance = false
	purchaseHintText

	WallBuyInfo = {
		
		Pistol = {
			price = 450,
			ammoPrice = 100
		},

		Shotgun = {
			price = 1050,
			ammoPrice = 300
		},

	}

	WallBuyLocations = {}

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

	

	function AddMoney(_player, _amount)
		SpiritLib.PlayerData[_player].money = SpiritLib.PlayerData[_player].money - _amount
	end

	function SetMoney(_player, _amount)
		SpiritLib.PlayerData[_player].money = _amount
	end 

	function RegisterWallBuy(_wallBuyPart, _type)
		WallBuyLocations[_wallBuyPart.id] = {
			type = _type,
			position = _wallBuyPart.position
		}
	end







	HookFunction("Update", function()
		CheckRadiusForKeypress()
	end)

	HookFunction("OnConnect", function(_player)
		if (SpiritLib.PlayerData[_player] == nil) then
			SpiritLib.PlayerData[_player] = {} 
		end

		SpiritLib.PlayerData[_player].money = 0
	end)

	HookFunction("NetworkStringReceive", function( _player, _msgName, _data )

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
	end)

	SpiritLib.Call("ModuleLoadFinished", This)