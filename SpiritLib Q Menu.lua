local tabsHeight = 28
local tabsPadding = 4

local panelPadding = 4

local buttonsSize = newVector2(120, 120)
local buttonsPadding = 4

local allTabs = {}
local tabsRowWidth = 0
local currentTab

local allButtons = {}
local spawnButtonRowWidth = newVector2(buttonsPadding, buttonsPadding)
local currentButton

local mainWindowSize = newVector2(ScreenSize().x - 168, ScreenSize().y - 120)
local mainWindowPos = newVector2(60, 60)
local mainWindow = MakeUIPanel(mainWindowPos, mainWindowSize)
mainWindow.color = newColor(0.14, 0.14, 0.14, 0.98)
mainWindow.enabled = false

local tabsWindowSize = newVector2(0, tabsHeight + tabsPadding * 2)
local tabsWindowPos = newVector2(0, -tabsWindowSize.y)
local tabsWindow = MakeUIPanel(Vector2.zero, tabsWindowSize)
tabsWindow.name = "Tabs Window"
tabsWindow.parent = mainWindow
tabsWindow.position = tabsWindowPos
tabsWindow.color = newColor(0.14, 0.14, 0.14, 0.98)

local function CreateTab(name, width)
	local holderSize = newVector2(width, tabsHeight)
	local holderPos = newVector2(tabsRowWidth + tabsPadding, tabsPadding)
	local holder = MakeUIPanel(Vector2.zero, holderSize)
	holder.name = name .. " Holder"
	holder.parent = tabsWindow
	holder.position = holderPos
	holder.color = Color.clear

	local button = MakeUIButton(Vector2.zero, holderSize, "<b>" .. name .. "</b>")
	button.name = name
	button.parent = holder
	button.position = newVector2(0, 0)
	button.textSize = 12
	button.textAlignment = "MiddleCenter"

	local panel = MakeUIPanel(Vector2.zero, mainWindowSize - newVector2(panelPadding * 2, panelPadding * 2))
	panel.name = name .. " Panel"
	panel.parent = mainWindow
	panel.position = newVector2(panelPadding, panelPadding)
	panel.color = Color.clear

	allTabs[name] = {
		button = button,
		panel = panel
	}

	if currentTab then
		button.color = newColor(0.26, 0.26, 0.26, 1)
		button.textColor = newColor(0.6, 0.6, 0.6, 1)
		panel.enabled = false
	else
		button.color = newColor(0.46, 0.46, 0.46, 1)
		button.textColor = newColor(0.8, 0.8, 0.8, 1)
		currentTab = allTabs[name]
	end

	tabsRowWidth = tabsRowWidth + width
	tabsWindow.size = newVector2(tabsRowWidth + tabsPadding * 2, tabsWindowSize.y)

	return panel
end

local function SelectTab(name)
	local selected = allTabs[name]

	if selected and selected ~= currentTab then
		currentTab.button.color = newColor(0.26, 0.26, 0.26, 1)
		currentTab.button.textColor = newColor(0.6, 0.6, 0.6, 1)
		currentTab.panel.enabled = false

		currentTab = selected

		currentTab.button.color = newColor(0.46, 0.46, 0.46, 1)
		currentTab.buttontextColor = newColor(0.8, 0.8, 0.8, 1)
		currentTab.panel.enabled = true
	end
end

local function CreateButton(name, panel)
	local holderSize = buttonsSize
	local holderPos = spawnButtonRowWidth
	local holder = MakeUIPanel(Vector2.zero, holderSize)
	holder.name = name .. " Holder"
	holder.parent = panel
	holder.position = holderPos
	holder.color = Color.clear

	local button = MakeUIButton(Vector2.zero, holderSize, "<b>" .. name .. "</b>")
	button.name = name
	button.parent = holder
	button.position = newVector2(0, 0)
	button.textSize = 12
	button.textAlignment = "MiddleCenter"

	button.color = newColor(0.26, 0.26, 0.26, 1)
	button.textColor = newColor(0, 0, 0, 1)

	-- figure out the size of the button with its padding
	local realSize = buttonsSize + newVector2(buttonsPadding, buttonsPadding)

	--add the realsize x
	spawnButtonRowWidth = spawnButtonRowWidth + newVector2(realSize.x, 0)

	-- find the right side (include right-side padding)
	local rightEdgeX = panel.position.x + panel.size.x - panelPadding

	-- uncomment to show right edge and positions being checked against it
	--MakeUIButton(newVector2(rightEdgeX, 100), Vector2.one*100, "R-Edge")
	--MakeUIButton(newVector2(panel.position.x + spawnButtonRowWidth.x, 180), Vector2.one*100, "SBRWidth")

	-- if the spawnButtonRowWidth has increased past the right edge X, set x to 0 and increase the spawnButtonRowWidth y
	if panel.position.x + spawnButtonRowWidth.x + realSize.x > rightEdgeX then
		spawnButtonRowWidth = newVector2(buttonsPadding, spawnButtonRowWidth.y + realSize.y)
	end
end

function OnUIButtonClick(button)
	if button.parent and button.parent.parent and button.parent.parent.parent and button.parent.parent.parent == mainWindow then
		SelectTab(button.name)
	end
end

function Update()
	if InputPressed("q") then
		mainWindow.enabled = true
	elseif InputReleased("q") then
		mainWindow.enabled = false
	end
end

local hello = CreateTab("Spawnlists", 80)

for i = 1, 100 do
	CreateButton("Test " .. i, hello)
end

CreateTab("Weapons", 80)
CreateTab("Entities", 80)
CreateTab("NPCs", 80)
CreateTab("Vehicles", 80)
CreateTab("Dupes", 80)
CreateTab("Saves", 80)