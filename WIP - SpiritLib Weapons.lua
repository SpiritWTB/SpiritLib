local boxesCount = 10
local boxesSize = newVector2(52, 52)
local boxesSpacing = 6

local allBoxes = {}
local current = 1

local boxesHolderSize = newVector2(((boxesSize.x + boxesSpacing) * boxesCount) - boxesSpacing, boxesSize.y)
local boxesHolderPos = newVector2((ScreenSize().x / 2) - (boxesHolderSize.x / 2), ScreenSize().y - boxesHolderSize.y - 36)
local boxesHolder = MakeUIPanel(boxesHolderPos, boxesHolderSize)
boxesHolder.color = newColor(0, 0, 0, 0)

function NextItem()
	SelectItem(current + 1)
end

function PreviousItem()
	SelectItem(current - 1)
end

function SelectItem(entryNumber)

	-- loop the value around so we don't have to do it in PreviousItem and NextItem
	if not allBoxes[entryNumber] then

		if entryNumber < 0 then
			entryNumber = boxesCount
		else
			entryNumber = 0
		end

	end

	allBoxes[current].color = newColor(allBoxes[current].color.r, allBoxes[current].color.g, allBoxes[current].color.b, 0)
	current = entryNumber
	allBoxes[current].color = newColor(allBoxes[current].color.r, allBoxes[current].color.g, allBoxes[current].color.b, 0.4)
end

function Update()
	if InputPressed("x") then
		PreviousItem()
	elseif InputPressed("c") then
		NextItem()
	end

	for k,v in pairs(allBoxes) do
		if InputPressed(v.table.keyBind) then
			SelectItem(v.table.index)
		end
	end

end

function SpawnUIBoxes()
	for i = 1, boxesCount do

		local keyBind = IndexToKeyBind(i)
		

		local boxBGPos = newVector2(((boxesSize.x + boxesSpacing) * i), 0)
		local boxBG = MakeUIPanel(boxBGPos, boxesSize, boxesHolder)
		boxBG.color = newColor(0.14, 0.14, 0.14, 0.76)

		local box = MakeUIPanel(newVector2(1, 1), newVector2(boxesSize.x - 2, boxesSize.y - 2), boxBG)

		local labelText = "<b>" .. keyBind .. "</b>"

		local boxNumberLabel = MakeUIText(newVector2(4, 4), newVector2(box.size.x - 8, box.size.y - 8), labelText, box)
		boxNumberLabel.textColor = newColor(0.8, 0.8, 0.8, 0.4)
		boxNumberLabel.textAlignment = "TopRight"

		local alpha = 0
		if i == current then
			alpha = 0.4
		end
		
		box.color = newColor(boxBG.color.r + 0.28, boxBG.color.g + 0.28, boxBG.color.b + 0.28, alpha)

		box.table.keyBind = keyBind
		box.table.index = i

		table.insert(allBoxes, box)
	end
end

function IndexToKeyBind(index)

	local keyBind = tostring(index)

	if (index==10) then
		return "0"
	elseif (index==11) then
		return "-"
	elseif (index==12) then
		return "="
	end

	return keyBind
end

SpawnUIBoxes()