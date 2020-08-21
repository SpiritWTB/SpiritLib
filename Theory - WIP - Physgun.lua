local SpiritLib = function() return PartByName("SpiritLib").scripts[1] end
function CallModuleFunction(moduleName, name, ...) return SpiritLib().Globals.SpiritLib.Modules[moduleName].scripts[1].Call(name, ...) end
function GetModuleVariable(moduleName, name) return SpiritLib().Globals.SpiritLib.Modules[moduleName].scripts[1].Globals[name] end


WEAPON = {}

WEAPON.Name = "The Grabber"
WEAPON.Description = "Moves and rotates objects and SpiritModels"
WEAPON.Slot = 1

WEAPON.CurrentObject = nil
WEAPON.CurrentPhysDistance = 0
WEAPON.CurrentPhysRotation = Vector3.zero

WEAPON.Fire = function(ply, mousePos, hitEnt)

	self.CurrentObject = hitEnt
	self.CurrentPhysDistance = (distance from ply to hitEnt)
end

WEAPON.think = function(unsure if we need arguments)
	if IsHost then return end

	if (self.CurrentObject ~= nil ) then
		-- ****
	end
end


-- **  this will run on the server AND client, so let's make sure on the server (we'll do it on both for the heck of it) that they can indeed hit that entity. This is subject to a little lag if, for instance, the host runs around a corner as he's being shot, but it's decent host-level security, and that's all we have right now... we might can do this outside of the individual weapon before calling weapon.Fire

-- **** move self.CurrentObject in some way here, idk how we want to do that, we need to know if they're first person or third, so I think we need to lock them to one or the other like we said, and let them press F to change between them. Then the physgun can work different in first and third person. First person could be like gmod physgun, third person could be like the mouse moves it around on the ground and you have buttons for up/down and rotate pitch/yaw/roll