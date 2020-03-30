-- this library just fakes parenting without the scale until WTB has some way to make multiple objects into one
-- this is not going to work on overlapping physics objects


-- make sure spiritlib is installed
local SpiritLibPart = PartByName("SpiritLib")
SpiritLib = SpiritLibPart.scripts[1]
if (SpiritLibPart == nil or SpiritLibPart.scripts[1] == nil) then print("Attachment is part of SpiritLib, which cannot be found. Please install SpiritLib properly.") end

SpiritLib.Attachment = {}
SpiritLib.Attachment.attachments = {}

-- this will "parent" a part to another
SpiritLib.Attachment.Attach = function(_attachThis, _toThis)
	SpiritLib.Attachment.attachments[_attachThis.id] = {
		parentID = _toThis.id,
		posOffset = _attachThis.position - _toThis.position,
		angOffset = _attachThis.angles - _toThis.angles
	}
end

-- this will refresh the position and rotation offsets, they would use this after changing the position of a "child" object
SpiritLib.Attachment.RefreshAttachment = function(_attachThis)
	local attachInfo = SpiritLib.Attachment.attachments[_attachThis.id]
	if (attachInfo ~= nil) then
		attachInfo.posOffset = _attachThis.position - _toThis.position,
		attachInfo.angOffset = _attachThis.angles - _toThis.angles
	end
end

-- this will dupe a part with all its attached parts
SpiritLib.Attachment.Duplicate = function(_dupeThis)
	local dupe = _dupeThis.Duplicate()
	duplicateAttachments(_dupeThis, dupe)
end

-- this wont be public use, it recursively dupes children. Children of _original will be duped and parented to _dupe, then the same will be done for the children
local duplicateAttachments = function(_original, _dupe)
	-- find each "child"
	for attachedPartID, attachInfo in pairs(SpiritLib.Attachment.attachments) do
		if (attachInfo.parentID == _original.id) then
			local _originalChild = PartByName(attachedPartID)
			if (_originalChild ~= nil) then

				-- this part is just like Duplicate() except it has to attach the duped part
				local _dupedChild = _originalChild.Duplicate()
				SpiritLib.Attachment.Attach(_dupedChild, _dupe)
				duplicateAttachments(_originalChild, _dupedChild)

			end
		end
	end
end

function Update()
	for attachedPartID, attachInfo in pairs(SpiritLib.Attachment.attachments) do

		local attachedPart = PartByID(attachedPartID)
		local parentPart = PartByID(attachInfo.parentID)

		if (parentPart ~= nil) then
			attachedPart.position = parentPart.position - attachInfo.posOffset
			attachedPart.angles = parentPart.angles - attachInfo.angOffset
		end
	end
end