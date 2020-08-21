-- this library just fakes parenting without the scale until WTB has some way to make multiple objects into one
-- this is not going to work on overlapping physics objects
-- this file says "child" and "parent" a lot but it's talking about an object being attached to another, not default WTB parenting. The whole point of the Attachments library is to avoid WTB Parenting for now.

-- this is actually not usually necessary, since you can attach parts together without this by attaching 2 to the same 1:1:1 size part.
-- this should then, mainly, be used for parenting to players. Occasionally also if you really need nested parents




--[[ Start SpiritLib Setup ]]

local SpiritLib = function() return PartByName("SpiritLib").scripts[1] end

-- Calls functions from SpiritLib modules, and uses special sauce to give their return value
function CallModuleFunction(moduleName, functionName, ...) 
	local token = SpiritLib().Globals.SpiritLib.Call("GetToken", This)
	SpiritLib().Globals.SpiritLib.FixedCall(moduleName, functionName, token, ...) 
	return This.table.spiritLibReturns[token]
end

-- gets variables from SpiritLib modules
function GetModuleVariable(moduleName, name) return SpiritLib().Globals.SpiritLib.Modules[moduleName].scripts[1].Globals[name] end

-- this is our special cross-script version of "return"
function ReturnCall(caller, token, functionName, ...) caller.table.spiritLibReturns[token] = _G[functionName](...) end

-- [[ End SpiritLib Setup ]]





-- this table holds the info about the relation between a child and parent
attachments = {}

-- this table holds a table of all children for a given parent, it's used for speed and does not contain all the relationship info like the attachments table. It's just a list of children ids for each parent
reverseAssociations = {}

-- in case objects no longer exist, this keeps track of the id of the OneScaledParent we've created for an object, by that objects id, this is used because the part might get deleted
oneScaledParentAttachments = {}

--SpiritLib\[ModuleName\].*function\((.*)\)

-- this will "parent" a part to another. 
function Attach(_attachThis, _toThis, --[[optional = true]]useOneScaledParent)

	local id = _attachThis.id

	-- if it's nil or true we're good
	if useOneScaledParent ~= false then
		-- create a holster if this part doesn't have one yet
		if _toThis.table.OneScaledParent==nil then
			local oneScaledParent = CreatePart(0, _toThis.position, Vector3.zero)
			_toThis.table.OneScaledParent = part
			oneScaledParent.table.isHolster = true
			oneScaledParent.cancollide = false
			oneScaledParent.visible = false
			oneScaledParent.frozen = true
			oneScaledParent.ignoreRaycast = true
			oneScaledParentAttachments[_toThis.id] = oneScaledParent.id
		end

		id = _toThis.table.OneScaledParent.id
		_attachThis.parent = _toThis.table.OneScaledParent
	end

	-- add actual attachment info
	if not attachments[id] then
		attachments[id] = {
			parentType = _toThis.type,
			parentID = _toThis.id,
			posOffset = _attachThis.position - _toThis.position,
			angOffset = _attachThis.angles - _toThis.angles,
			lastParentPosition = _toThis.position,
			lastParentAngles = _toThis.angles
		}
	end

	-- make sure we can get the children just by knowing the parent
	if (reverseAssociations[id] == nil) then
		reverseAssociations[id] = {}
	end

	
	
	table.insert(reverseAssociations[id], _attachThis.id)
end

-- this is used in cases like when one part no longer exists because it has been deleted. It just removes the object from any previous association.
function Unattach(_unattachThisID, _fromThisID)
	local thisID = _unattachThisID
	local fromID = _fromThisID

	-- if it has an entry here, its parenting is fake (see: real, it's confusing) so we can just unparent it and stop this function
	if oneScaledParentAttachments[thisID] then
		local partToBeUnnattached = PartByID(thisID)
		
		if partToBeUnnattached then
			partToBeUnnattached.parent = nil
		end
		
		-- if there wasn't one it doesn't matter, it got deleted and unity parenting will absorb that blow

		return
	end

	attachments[thisID] = nil

	-- find the list of children for the parent
	if (reverseAssociations[fromID] ~= nil) then
		for index, childID in pairs(reverseAssociations[fromID]) do
			if (childID == thisID) then
				reverseAssociations[fromID][index] = nil
			end
		end
	end
end

-- this is used in cases like when one part no longer exists because it has been deleted. It just removes the object from any previous association.
function UnattachFromAll(_unattachThisID)
	local thisID = _unattachThisID
	local fromID = _fromThisID

	attachments[thisID] = nil

	-- find the list of children for the parent
	if (reverseAssociations[fromID] ~= nil) then
		for index, childID in pairs(reverseAssociations[fromID]) do
			reverseAssociations[fromID][index] = nil
		end
	end
end


-- this will refresh the position and rotation offsets, they would use this after changing the position of a "child" object relative to the parent
function RefreshAttachment(_attachThis)
	local attachInfo = attachments[_attachThis.id]
	if (attachInfo ~= nil) then
		local angles = _toThis.angles

		_toThis.angles = newVector3(0,0,0);

		attachInfo.posOffset = _attachThis.position - _toThis.position
		attachInfo.angOffset = _attachThis.angles - _toThis.angles

		_toThis.angles = angles;
	end
end

-- this will dupe a part with all its attached parts
function Duplicate(_dupeThis)
	local dupe = _dupeThis.Duplicate()
	duplicateAttachments(_dupeThis, dupe)
end

-- this will delete a part with all its attached parts
function Remove(_deleteThis)
	deleteAttachments(_deleteThis)
	_deleteThis.Remove()
end



-- this wont be public use, it recursively dupes children. Children of _original will be duped and parented to _dupe, then the same will be done for the children
function duplicateAttachments(_original, _dupe)
	for k, attachedPartID in pairs(getAttachedIDS(_original)) do

		local _originalChild = PartByName(attachedPartID)

		if (_originalChild ~= nil) then

			-- this part is just like Duplicate() except it has to attach the duped part
			local _dupedChild = _originalChild.Duplicate()
			Attach(_dupedChild, _dupe)
			duplicateAttachments(_originalChild, _dupedChild)

		end
	end 
end

-- this wont be public use, it recursively deletes children objects
function deleteAttachments(_original)
	for k, attachedPartID in pairs(getAttachedIDS(_original)) do

		local _child = PartByName(attachedPartID)

		if (_child ~= nil) then

			-- this part is just like Remove()
			_child.Remove()
			deleteAttachments(_child)

		end
	end 
end

-- returns a list of ids for *direct* children of an object
function getAttachedIDS(_parent)
	if (reverseAssociations[_parent.id] ~= nil) then
		return reverseAssociations[_parent.id]
	end
end





function DrawUpdate()
	if (attachmentsUpdate ~= nil) then
		if (coroutine.status(attachmentsUpdate) == "suspended" or coroutine.running(attachmentsUpdate)==false) then
			coroutine.resume(attachmentsUpdate)
		end
	end
end




local partsUpdated = 0
function updateRoutine()

	for attachedPartID, attachInfo in pairs(attachments) do

		local parentPart
		if attachInfo.parentType == "Part" then
			parentPart = PartByID(attachInfo.parentID)
		else 
			parentPart = PlayerByID(attachInfo.parentID)
		end

		local shouldUpdateChildren = ( attachInfo.lastParentPosition ~= parentPart.position or attachInfo.lastParentAngles ~= parentPart.angles )

		if (parentPart ~= nil) then
			if (shouldUpdateChildren) then

				attachInfo.lastParentPosition = parentPart.position
				attachInfo.lastParentAngles = parentPart.angles

				local attachedPart = PartByID(attachedPartID)

				if (attachedPart ~= nil) then
					attachedPart.position = parentPart.position + attachInfo.posOffset.x*parentPart.right + attachInfo.posOffset.y*parentPart.up + attachInfo.posOffset.z*parentPart.forward
					attachedPart.angles = parentPart.angles - attachInfo.angOffset
				else 
					Unattach(attachInfo.parent)
				end

				partsUpdated = partsUpdated + 1

				if (partsUpdated > 175) then
					coroutine.yield()
					partsUpdated = 0
				end
			end
		else
			-- if we're here one of the parts was probably deleted
			Unattach(attachedPartID)
		end
	end

	attachmentsUpdate = coroutine.create(updateRoutine)
end

attachmentsUpdate = coroutine.create(updateRoutine)

