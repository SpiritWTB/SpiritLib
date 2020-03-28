local GameManager = PartByName("GameManager").scripts[1]
GameManager.Call("RegisterWallBuy", This, "Pistol")
--
	-- actual wallbuy script above, GameManager script below
--


local buyDistance = 10

local isWithinDistance = false

local purchaseHintText

local WallBuyInfo = {
	
	["Pistol"] = {
		["Price"] = 450,
		["AmmoPrice"] = 100
	},

	["Shotgun"] = {
		["Price"] = 1050,
		["AmmoPrice"] = 300
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
				NetworkSendToHost("tryBuyWeapon", {})
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

function NetworkStringReceive( _player, _msgName, _data )
	if (_msgName == "tryBuyWeapon") then
		-- check player position, make sure they're close enough to this wallbuy
		-- if they're close enough, make sure they have money
		-- if they have money, take away the cost of the weapon and give them the weapon
	end
end

function RegisterWallBuy(_wallBuyPart, _type)
	WallBuyLocations[_wallBuyPart.id] = {
		["Type"] = _type,
		["Position"] = _wallBuyPart.position
	}
end