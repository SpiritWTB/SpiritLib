local SpiritLib = function(moduleName) return PartByName("SpiritLib").scripts[1].Globals.SpiritLib.Modules[moduleName] end
local SLNet = SpiritLib("Networking")

function Update()
	if InputPressed("z") then
		print(#SLNet)
        SLNet.Call("CreateStreamedValue", "Test", newVector3(1, 2, 4), 69)
    elseif InputPressed("x") then
        SLNet.Call("GetStreamedValue", "Test")
    elseif InputPressed("c") then
        SLNet.Call("UpdateStreamedValue", "Test", newVector3(10, 20, 40))
    elseif InputPressed("v") then
        SLNet.Call("SetSyncedValue", "Bob", newVector2(420, 69))
    elseif InputPressed("b") then
        SLNet.Call("SetSyncedValue", "Bob", newVector2(42, 1337))
    elseif InputPressed("n") then
        SLNet.Call("GetSyncedValue", "Bob")
    elseif InputPressed("m") then
        NetworkSendToHost("AddStreamedValue", {})
    end
end