--[[ Start SpiritLib Setup ]]
loadstring(PartByName("SpiritLib").scripts[1].Globals.SpiritLibSetup)
-- [[ End SpiritLib Setup ]]

local mousePosRegistered = false

function Update()
	if mousePosRegistered==false then
		GetModule("Networking").Call( "CreateStreamedValue", "MousePos:" .. LocalPlayer().id, MousePosWorld())
    	mousePosRegistered = true
	else
		GetModule("Networking").Call( "UpdateStreamedValue", "MousePos:" .. LocalPlayer().id, MousePosWorld())
	end
end