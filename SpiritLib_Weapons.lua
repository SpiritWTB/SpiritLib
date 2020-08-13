local boxesCount = 10
local boxesSize = newVector2(52, 52)
local boxesSpacing = 6

local allBoxes = {}
local current = 1

local boxesHolderSize = newVector2(((boxesSize.x + boxesSpacing) * boxesCount) - boxesSpacing, boxesSize.y)
local boxesHolderPos = newVector2((ScreenSize().x / 2) - (boxesHolderSize.x / 2), ScreenSize().y - boxesHolderSize.y - 36)
local boxesHolder = MakeUIPanel(boxesHolderPos, boxesHolderSize)
boxesHolder.color = newColor(0, 0, 0, 0)

for i = 0, boxesCount - 1 do
	local boxBGPos = newVector2(((boxesSize.x + boxesSpacing) * i), 0)
	local boxBG = MakeUIPanel(boxBGPos, boxesSize, boxesHolder)
	boxBG.color = newColor(0.14, 0.14, 0.14, 0.76)

	local box = MakeUIPanel(newVector2(1, 1), newVector2(boxesSize.x - 2, boxesSize.y - 2), boxBG)

	local boxNumber = MakeUIText(newVector2(4, 4), newVector2(box.size.x - 8, box.size.y - 8), "<b>" .. i .. "</b>", box)
	boxNumber.textColor = newColor(0.8, 0.8, 0.8, 0.4)
	boxNumber.textAlignment = "TopRight"

	if i == 0 then
		box.color = newColor(boxBG.color.r + 0.28, boxBG.color.g + 0.28, boxBG.color.b + 0.28, 0.4)
	else
		box.color = newColor(boxBG.color.r + 0.28, boxBG.color.g + 0.28, boxBG.color.b + 0.28, 0)
	end

	table.insert(allBoxes, box)
end

function NextItem()
	allBoxes[current].color = newColor(allBoxes[current].color.r, allBoxes[current].color.g, allBoxes[current].color.b, 0)

	if allBoxes[current + 1] then
		current = current + 1
	else
		current = 1
	end

	allBoxes[current].color = newColor(allBoxes[current].color.r, allBoxes[current].color.g, allBoxes[current].color.b, 0.4)
end

function PreviousItem()
	allBoxes[current].color = newColor(allBoxes[current].color.r, allBoxes[current].color.g, allBoxes[current].color.b, 0)

	if allBoxes[current - 1] then
		current = current - 1
	else
		current = #allBoxes
	end

	allBoxes[current].color = newColor(allBoxes[current].color.r, allBoxes[current].color.g, allBoxes[current].color.b, 0.4)
end

function Update()
	if InputPressed("x") then
		PreviousItem()
	elseif InputPressed("c") then
		NextItem()
	end
end