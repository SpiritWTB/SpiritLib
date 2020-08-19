local SpiritLib = function() return PartByName("SpiritLib").scripts[1] end

function CallModuleFunction(moduleName, name, ...) return SpiritLib().Globals.SpiritLib.Modules[moduleName].scripts[1].Call(name, ...) end
function GetModuleVariable(moduleName, name) return SpiritLib().Globals.SpiritLib.Modules[moduleName].scripts[1].Globals[name] end

local function EnableButton(button, unhide)
	if button and button.type == "UIButton" then
		button.color = newColor(0.26, 0.26, 0.26, 1)
		button.textColor = newColor(0.6, 0.6, 0.6, 1)

		if unhide then
			button.enabled = true
		end
	end
end

local function DisableButton(button, hide)
	if button and button.type == "UIButton" then
		button.color = newColor(0.46, 0.46, 0.46, 1)
		button.textColor = newColor(0.8, 0.8, 0.8, 1)

		if hide then
			button.enabled = false
		end
	end
end

local tabButtonsHeight = 28
local tabButtonsPadding = 4

local panelPadding = 4

local buttonsSize = newVector2(120, 120)
local buttonsPadding = 4

local pageButtonsSize = newVector2(28, 28)
local pageButtonsPadding = 4

local tabsPanelSize = newVector2(0, tabButtonsHeight + tabButtonsPadding * 2)
local paginationPanelSize = newVector2(0, pageButtonsSize.y + pageButtonsPadding * 2)

local allTabs = {}
local tabsRowWidth = 0
local currentTab

local mainPanelSize = newVector2(ScreenSize().x - 120, ScreenSize().y - 156)
local mainPanelPos = newVector2(60, 96)
local mainPanel = MakeUIPanel(mainPanelPos, mainPanelSize)
mainPanel.color = newColor(0.14, 0.14, 0.14, 0.98)
mainPanel.enabled = false

local tabsPanelPos = newVector2(0, -tabsPanelSize.y)
local tabsPanel = MakeUIPanel(Vector2.zero, tabsPanelSize)
tabsPanel.name = "Tabs Panel"
tabsPanel.parent = mainPanel
tabsPanel.position = tabsPanelPos
tabsPanel.color = newColor(0.14, 0.14, 0.14, 0.98)

local paginationPanelPos = newVector2(mainPanelSize.x / 2 - paginationPanelSize.x / 2, mainPanelSize.y)
local paginationPanel = MakeUIPanel(Vector2.zero, paginationPanelSize)
paginationPanel.name = "Pagination Panel"
paginationPanel.parent = mainPanel
paginationPanel.position = paginationPanelPos
paginationPanel.color = newColor(0.14, 0.14, 0.14, 0.98)

local firstButtonSize = pageButtonsSize
local firstButtonPos = newVector2(pageButtonsPadding, pageButtonsPadding)
local firstButton = MakeUIButton(Vector2.zero, firstButtonSize, "<b><<</b>")
firstButton.name = "First Page"
firstButton.parent = paginationPanel
firstButton.position = firstButtonPos
DisableButton(firstButton)
firstButton.textSize = 12
firstButton.textAlignment = "MiddleCenter"

local prevButtonSize = pageButtonsSize
local prevButtonPos = newVector2(firstButtonPos.x + firstButtonSize.x, pageButtonsPadding)
local prevButton = MakeUIButton(Vector2.zero, prevButtonSize, "<b><</b>")
prevButton.name = "Previous Page"
prevButton.parent = paginationPanel
prevButton.position = prevButtonPos
DisableButton(prevButton)
prevButton.textSize = 12
prevButton.textAlignment = "MiddleCenter"

local pageCountSize = newVector2(60, 28)
local pageCountPos = newVector2(prevButtonPos.x + prevButtonSize.x, pageButtonsPadding)
local pageCount = MakeUIText(pageCountPos, pageCountSize, "0/0")
pageCount.name = "Page Count"
pageCount.parent = paginationPanel
pageCount.position = pageCountPos
pageCount.textColor = newColor(0.6, 0.6, 0.6, 1)
pageCount.textSize = 12
pageCount.textAlignment = "MiddleCenter"

local nextButtonSize = pageButtonsSize
local nextButtonPos = newVector2(pageCountPos.x + pageCountSize.x, pageButtonsPadding)
local nextButton = MakeUIButton(Vector2.zero, nextButtonSize, "<b>></b>")
nextButton.name = "Next Page"
nextButton.parent = paginationPanel
nextButton.position = nextButtonPos
DisableButton(nextButton)
nextButton.textSize = 12
nextButton.textAlignment = "MiddleCenter"

local lastButtonSize = pageButtonsSize
local lastButtonPos = newVector2(nextButtonPos.x + nextButtonSize.x, pageButtonsPadding)
local lastButton = MakeUIButton(Vector2.zero, lastButtonSize, "<b>>></b>")
lastButton.name = "Last Page"
lastButton.parent = paginationPanel
lastButton.position = lastButtonPos
DisableButton(lastButton)
lastButton.textSize = 12
lastButton.textAlignment = "MiddleCenter"

paginationPanel.size = newVector2(pageButtonsPadding * 4 + pageButtonsSize.x * 4 + pageCountSize.x, pageButtonsPadding * 2 + pageButtonsSize.y)
paginationPanel.position = newVector2(mainPanelSize.x / 2 - paginationPanelSize.x / 2, mainPanelSize.y)

local function CreateTab(name, width)
	local holderSize = newVector2(width, tabButtonsHeight)
	local holderPos = newVector2(tabsRowWidth + tabButtonsPadding, tabButtonsPadding)
	local holder = MakeUIPanel(Vector2.zero, holderSize)
	holder.name = name .. " Holder"
	holder.parent = tabsPanel
	holder.position = holderPos
	holder.color = Color.clear

	local button = MakeUIButton(Vector2.zero, holderSize, "<b>" .. name .. "</b>")
	button.name = name
	button.parent = holder
	button.position = newVector2(0, 0)
	button.textSize = 12
	button.textAlignment = "MiddleCenter"
	button.table.isTab = true

	local panel = MakeUIPanel(Vector2.zero, mainPanelSize - newVector2(panelPadding * 2, panelPadding * 2))
	panel.name = name .. " Page 1"
	panel.parent = mainPanel
	panel.position = newVector2(panelPadding, panelPadding)
	panel.color = Color.clear

	panel.table.occupiedSize = newVector2(buttonsPadding, buttonsPadding)

	allTabs[name] = {
		button = button,
		pages = {panel},
		currentPage = 1
	}

	if currentTab then
		EnableButton(button, false)
		panel.enabled = false
	else
		DisableButton(button, false)
		currentTab = allTabs[name]
	end

	tabsRowWidth = tabsRowWidth + width
	tabsPanel.size = newVector2(tabsRowWidth + tabButtonsPadding * 2, tabsPanelSize.y)

	return panel
end

local function SelectTab(name)
	local selected = allTabs[name]

	if selected and selected ~= currentTab then
		EnableButton(currentTab.button, false)

		for i, page in pairs(currentTab.pages) do
			page.enabled = false
		end

		DisableButton(selected.button, false)
		selected.pages[selected.currentPage].enabled = true

		currentTab = selected
	end
end

local function UpdatePagination()
	if currentTab.currentPage == #currentTab.pages then
		DisableButton(nextButton, true)
		DisableButton(lastButton, true)
		EnableButton(prevButton, true)
		EnableButton(firstButton, true)
	elseif currentTab.currentPage == 1 then
		DisableButton(prevButton, true)
		DisableButton(firstButton, true)
		EnableButton(nextButton, true)
		EnableButton(lastButton, true)
	else
		EnableButton(nextButton, true)
		EnableButton(prevButton, true)
		EnableButton(firstButton, true)
		EnableButton(lastButton, true)
	end

	pageCount.text = "<b>" .. tostring(currentTab.currentPage) .. "/" .. tostring(#currentTab.pages) .. "</b>"
end

local function CreateButton(name, description, tab, modelDataJson)
	local panel = tab.pages[#tab.pages]

	local holderSize = buttonsSize
	local holderPos = panel.table.occupiedSize
	local holder = MakeUIPanel(Vector2.zero, holderSize)
	holder.name = name .. " Holder"
	holder.parent = panel
	holder.position = holderPos
	holder.color = Color.clear

	local button = MakeUIButton(Vector2.zero, holderSize, "<b>" .. name .. tostring(#tab.pages) .. "</b>")
	button.name = name
	button.parent = holder
	button.position = newVector2(0, 0)
	button.textSize = 12
	button.textAlignment = "MiddleCenter"

	EnableButton(button, false)

	button.table.isSpiritLibSpawnButton = true
	button.table.spawnData = modelDataJson

	-- figure out the size of the button with its padding
	local realSize = buttonsSize + newVector2(buttonsPadding, buttonsPadding)

	-- add the realsize x
	panel.table.occupiedSize = panel.table.occupiedSize + newVector2(realSize.x, 0)

	-- find the right side (include right-side padding)
	local panelEdge = panel.position + panel.size - newVector2(panelPadding, panelPadding)

	if panel.position.x + panel.table.occupiedSize.x + realSize.x > panelEdge.x then
		panel.table.occupiedSize = newVector2(buttonsPadding, panel.table.occupiedSize.y + realSize.y)
	end

	if panel.position.y + panel.table.occupiedSize.y + realSize.y > panelEdge.y then
		local newPanel = MakeUIPanel(Vector2.zero, mainPanelSize - newVector2(panelPadding * 2, panelPadding * 2))
		newPanel.name = name .. " Page " .. tostring(#tab.pages)
		newPanel.parent = mainPanel
		newPanel.position = newVector2(panelPadding, panelPadding)
		newPanel.color = Color.clear
		newPanel.enabled = false

		table.insert(tab.pages, newPanel)

		panel = newPanel
		panel.table.occupiedSize = newVector2(buttonsPadding, buttonsPadding)

		UpdatePagination()
	end
end

local function SelectPage(number)
	if not currentTab.pages[number] then
		return
	end

	currentTab.pages[currentTab.currentPage].enabled = false
	currentTab.pages[number].enabled = true
	currentTab.currentPage = number

	UpdatePagination()
end

function OnUIButtonClick(button)
	if button.name == "First Page" then
		SelectPage(1)
	elseif button.name == "Previous Page" then
		SelectPage(currentTab.currentPage - 1)
	elseif button.name == "Next Page" then
		SelectPage(currentTab.currentPage + 1)
	elseif button.name == "Last Page" then
		SelectPage(#currentTab.pages)
	elseif button.table.isTab then
		SelectTab(button.name)
	elseif button.table.isSpiritLibSpawnButton and button.table.spawnData then
		local spawnPos = LocalPlayer().position + LocalPlayer().forward
		CallModuleFunction("Models", "GenerateModel", button.table.spawnData, spawnPos)
	end
end

function Update()
	if InputPressed("q") then
		mainPanel.enabled = true
	elseif InputReleased("q") then
		mainPanel.enabled = false
	end
end

CreateTab("Models", 60)
CreateTab("Weapons", 70)
CreateTab("Entities", 80)
CreateTab("NPCs", 40)
CreateTab("Vehicles", 80)
CreateTab("Dupes", 50)
CreateTab("Saves", 50)

for i = 1, 100 do
    for i2, modelJson in pairs(GetModuleVariable("Default Models", "AllModels")) do
        local model = FromJson(modelJson)

        -- once we get scripts on the side pass through the model, not the modelJson
        CreateButton(model.name, model.description, allTabs["Models"], modelJson)
    end
end