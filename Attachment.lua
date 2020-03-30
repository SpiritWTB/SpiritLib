-- this library just fakes parenting without the scale until WTB has some way to make multiple objects into one

-- make sure spiritlib is installed
local SpiritLibPart = PartByName("SpiritLib")
SpiritLib = SpiritLibPart.scripts[1]
if (SpiritLibPart == nil or SpiritLibPart.scripts[1] == nil) then print("WallBuys is built on SpiritLib, which cannot be found. Please install SpiritLib properly.") end

SpiritLib.Attachment = {}
SpiritLib.Attachment.attachments = {}

SpiritLib.Attachment.AttachPart = function(_attachThis, _toThis)
	SpiritLib.Attachment.attachments[_attachThis.id] = {
		parentID = _toThis.id,
		posOffset = _attachThis.position - _toThis.position,
		angOffset = _attachThis.angles - _toThis.angles
	}
end

SpiritLib.Attachment.Refresh = function(_attachThis)
	local attachInfo = SpiritLib.Attachment.attachments[_attachThis.id]
	if (attachInfo ~= nil) then
		attachInfo.posOffset = _attachThis.position - _toThis.position,
		attachInfo.angOffset = _attachThis.angles - _toThis.angles
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