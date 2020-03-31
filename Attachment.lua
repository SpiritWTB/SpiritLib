-- this library just fakes parenting without the scale until WTB has some way to make multiple objects into one
-- this is not going to work on overlapping physics objects
-- this file says "child" and "parent" a lot but it's talking about an object being attached to another, not default WTB parenting. The whole point of the Attachments library is to avoid WTB Parenting for now.

-- this is actually not usually necessary, since you can attach parts together without this by attaching 2 to the same 1:1:1 ratio part.
-- this should then, mainly, be used for parenting to players. Occasionally also if you really need nested parents



SpiritLib = nil
ModuleName = nil

-- variables ModuleName and SpiritLib will be set before this runs
function LoadModule()

	-- this table holds the info about the relation between a child and parent
	SpiritLib[ModuleName].attachments = {}

	-- this table holds a table of all children for a given parent, it's used for speed and does not contain all the relationship info like the attachments table. It's just a list of children ids for each parent
	SpiritLib[ModuleName].reverseAssociations = {}

	-- this will "parent" a part to another
	SpiritLib[ModuleName].Attach = function(_attachThis, _toThis)

		-- add actual attachment info
		SpiritLib[ModuleName].attachments[_attachThis.id] = {
			parentID = _toThis.id,
			posOffset = _attachThis.position - _toThis.position,
			angOffset = _attachThis.angles - _toThis.angles
		}


		-- make sure we can get the children just by knowing the parent
		if (SpiritLib[ModuleName].reverseAssociations[_toThis.id] == nil) then
			SpiritLib[ModuleName].reverseAssociations[_toThis.id] = {}
		end
		table.insert(SpiritLib[ModuleName].reverseAssociations[_toThis.id], _attachThis.id)

	end



	-- this will refresh the position and rotation offsets, they would use this after changing the position of a "child" object
	SpiritLib[ModuleName].RefreshAttachment = function(_attachThis)
		local attachInfo = SpiritLib[ModuleName].attachments[_attachThis.id]
		if (attachInfo ~= nil) then
			attachInfo.posOffset = _attachThis.position - _toThis.position,
			attachInfo.angOffset = _attachThis.angles - _toThis.angles
		end
	end

	-- this will dupe a part with all its attached parts
	SpiritLib[ModuleName].Duplicate = function(_dupeThis)
		local dupe = _dupeThis.Duplicate()
		duplicateAttachments(_dupeThis, dupe)
	end

	-- this will delete a part with all its attached parts
	SpiritLib[ModuleName].Remove = function(_deleteThis)
		deleteAttachments(_deleteThis)
		_deleteThis.Remove()
	end



	-- this wont be public use, it recursively dupes children. Children of _original will be duped and parented to _dupe, then the same will be done for the children
	SpiritLib[ModuleName].duplicateAttachments = function(_original, _dupe)
		for k, attachedPartID in pairs(getAttachedIDS(_original)) do

			local _originalChild = PartByName(attachedPartID)

			if (_originalChild ~= nil) then

				-- this part is just like Duplicate() except it has to attach the duped part
				local _dupedChild = _originalChild.Duplicate()
				SpiritLib[ModuleName].Attach(_dupedChild, _dupe)
				duplicateAttachments(_originalChild, _dupedChild)

			end
		end 
	end

	-- this wont be public use, it recursively deletes children objects
	SpiritLib[ModuleName].deleteAttachments = function(_original)
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
	SpiritLib[ModuleName].getAttachedIDS = function(_parent)
		if (SpiritLib[ModuleName].reverseAssociations[_parent.id] ~= nil) then
			return SpiritLib[ModuleName].reverseAssociations[_parent.id]
		end
	end

	-- this is used in cases like when one part no longer exists because it has been deleted. It just removes the object from any previous association.
	SpiritLib[ModuleName].ClearAttachmentData = function(_unattachThisID, _fromThisID)
		SpiritLib[ModuleName].attachments[_unattachThisID] = nil

		-- find the list of children for the parent
		if (SpiritLib[ModuleName].reverseAssociations[_fromThisID] ~= nil) then
			for index, childID in pairs(SpiritLib[ModuleName].reverseAssociations[_fromThisID]) do
				if (childID == _unattachThisID) then
					SpiritLib[ModuleName].reverseAssociations[_fromThisID][index] = nil
				end
			end
		end
	end




	SpiritLib[ModuleName].HookFunction("Update", function()
		for attachedPartID, attachInfo in pairs(SpiritLib[ModuleName].attachments) do

			local attachedPart = PartByID(attachedPartID)
			local parentPart = PartByID(attachInfo.parentID)

			if (parentPart ~= nil) then
				if (attachedPart ~= nil) then
					attachedPart.position = parentPart.position - attachInfo.posOffset
					attachedPart.angles = parentPart.angles - attachInfo.angOffset
				else 
					ClearAttachmentData(attachInfo.parent)
				end
			else
				-- if we're here one of the parts was probably deleted
				ClearAttachmentData(attachedPartID)
			end
		end
	end)

end

SpiritLib.Call("ModuleLoadFinished", This)