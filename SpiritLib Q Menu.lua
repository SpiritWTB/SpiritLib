local allTabs = {
	{
		name = "Spawnlists",
		width = 80
	},
	{
		name = "Weapons",
		width = 80
	},
	{
		name = "Entities",
		width = 80
	},
	{
		name = "NPCs",
		width = 80
	},
	{
		name = "Vehicles",
		width = 80
	},
	{
		name = "Dupes",
		width = 80
	},
	{
		name = "Saves",
		width = 80
	}
}

local tabsHeight = 32
local tabsPadding = 4

local mainWindowSize = newVector2(ScreenSize().x - 120, ScreenSize().y - 120)
local mainWindowPos = newVector2(60, 60)
local mainWindow = MakeUIPanel(mainWindowPos, mainWindowSize)
mainWindow.color = newColor(0.14, 0.14, 0.14, 0.98)
mainWindow.enabled = false

local tabsWindowSize = newVector2(0, tabsHeight + tabsPadding * 2)
local tabsWindowPos = newVector2(0, -tabsWindowSize.y + 2)
local tabsWindow = MakeUIPanel(tabsWindowPos, tabsWindowSize, mainWindow)
tabsWindow.color = newColor(0.14, 0.14, 0.14, 0.98)

local allWidth = 0
local currentButton = allTabs[1]

for i, tab in pairs(allTabs) do
	local holderSize = newVector2(tab.width, tabsHeight)
	local holderPos = newVector2(allWidth + tabsPadding, tabsPadding)
	local holder = MakeUIPanel(holderPos, holderSize, tabsWindow)

	local button = MakeUIButton(Vector2.zero, holderSize)
	button.parent = holder
	button.position = newVector2(0, 0)
	button.name = tab.name

	print(holder.position, button.position)

	if i == 1 then
		button.color = newColor(0.4, 0.4, 0.4, 1)
	else
		button.color = newColor(0.26, 0.26, 0.26, 1)
	end

	local textBox = MakeUIText(Vector2.zero, holderSize, "<b>" .. tab.name .. "</b>", button)
	textBox.textColor = newColor(0.6, 0.6, 0.6, 1)
	textBox.textSize = 12
	textBox.textAlignment = "MiddleCenter"

	tab.holder = holder
	tab.button = button
	tab.label = textBox

	allWidth = allWidth + tab.width
end

tabsWindow.size = newVector2(allWidth + tabsPadding * 2, tabsWindowSize.y)

for i, tab in pairs(allTabs) do
	tab.button.position = tab.button.position - newVector2(tabsWindowSize.x / 2, ScreenSize().y)
end

function OnUIButtonClick(button)
	if button.parent == tabsWindow then
		print("hurb")
	end
end

function Update()
	if InputPressed("q") then
		mainWindow.enabled = true
	elseif InputReleased("q") then
		mainWindow.enabled = false
	end
end