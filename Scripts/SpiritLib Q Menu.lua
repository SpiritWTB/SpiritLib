--[[ Start SpiritLib Setup ]]
loadstring(PartByName("SpiritLib").scripts[1].Globals.SpiritLibSetup)
-- [[ End SpiritLib Setup ]]

ModuleSettings = {
	AllowQMenu = true,

	AllowedSpawnTypes = {
		["Model"] = true,
		["Weapon"] = true,
	}
}


function MakeUIButtonWithHolder(name, position, size, --[[optional = ""]] text, parentUI)
	local holderSize = size
	local holderPos = position
	local holder = MakeUIPanel(Vector2.zero, holderSize)
	holder.name = tostring(name) .. " Button Holder"
	holder.parent = parentUI
	holder.position = holderPos
	holder.color = Color.clear

	local button = MakeUIButton(Vector2.zero, holderSize, text or "")
	button.name = tostring(name) .. " Button"
	button.parent = holder
	button.position = newVector2(0, 0)
	button.textSize = 12
	button.textAlignment = "MiddleCenter"

	button.table.holder = holder

	return button
end

function MakeUITextWithHolder(name, position, size, --[[optional = ""]] text, --[[optional = nil]] parentUI, --[[optional = 0]] wrappingPadding)
	wrappingPadding = wrappingPadding or 0

	local holderSize = size
	local holderPos = position
	local holder = MakeUIPanel(Vector2.zero, holderSize)
	holder.name = tostring(name) .. " Label Holder"

	if parentUI then
		holder.parent = parentUI
	end

	holder.position = holderPos
	holder.color = Color.clear

	local label = MakeUIText(Vector2.zero, newVector2(holderSize.x-wrappingPadding*2, holderSize.y), text or "")
	label.name = tostring(name) .. " Label"
	label.parent = holder
	label.position = newVector2(wrappingPadding,0)
	label.textColor = newColor(0.6, 0.6, 0.6, 1)
	label.textSize = 12
	label.textAlignment = "MiddleCenter"

	label.table.holder = holder

	return label
end

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

local mainPanelSize = newVector2(ScreenSize().x - 136, ScreenSize().y - 256)
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
paginationPanel.parent = mainPanel
paginationPanel.name = "Pagination Panel"
paginationPanel.position = paginationPanelPos
paginationPanel.color = newColor(0.14, 0.14, 0.14, 0.98)


local firstButtonSize = pageButtonsSize
local firstButtonPos = newVector2(pageButtonsPadding, pageButtonsPadding)
local firstButton = MakeUIButtonWithHolder("First Page", firstButtonPos, firstButtonSize, "<b><<</b>", paginationPanel)
firstButton.table.isFirstPageButton = true
DisableButton(firstButton)

local prevButtonSize = pageButtonsSize
local prevButtonPos = newVector2(firstButtonPos.x + firstButtonSize.x+ pageButtonsPadding, pageButtonsPadding)
local prevButton = MakeUIButtonWithHolder("Previous Page", prevButtonPos, prevButtonSize, "<b><</b>", paginationPanel)
prevButton.table.isPreviousPageButton = true
DisableButton(prevButton)

local pageCountSize = newVector2(60, 28)
local pageCountPos = newVector2(prevButtonPos.x + prevButtonSize.x+ pageButtonsPadding, pageButtonsPadding)
local pageCount = MakeUITextWithHolder("Page Count", pageCountPos, pageCountSize, "0/0", paginationPanel)
pageCount.textSize = 10

local nextButtonSize = pageButtonsSize
local nextButtonPos = newVector2(pageCountPos.x + pageCountSize.x+ pageButtonsPadding, pageButtonsPadding)
local nextButton = MakeUIButtonWithHolder("Next Page", nextButtonPos, nextButtonSize, "<b>></b>", paginationPanel)
nextButton.table.isNextPageButton = true
DisableButton(nextButton)

local lastButtonSize = pageButtonsSize
local lastButtonPos = newVector2(nextButtonPos.x + nextButtonSize.x + pageButtonsPadding, pageButtonsPadding)
local lastButton = MakeUIButtonWithHolder("Last Page", lastButtonPos, lastButtonSize, "<b>>></b>", paginationPanel)
lastButton.table.isLastPageButton = true
DisableButton(lastButton)

paginationPanel.size = newVector2(pageButtonsPadding * 6 + pageButtonsSize.x * 4 + pageCountSize.x, pageButtonsPadding * 2 + pageButtonsSize.y)
paginationPanel.position = newVector2(mainPanelSize.x / 2 - paginationPanel.size.x / 2, mainPanelSize.y)

local function CreateTab(name, width)
	local buttonSize = newVector2(width, tabButtonsHeight)
	local buttonPos = newVector2(tabsRowWidth + tabButtonsPadding, tabButtonsPadding)

	local button = MakeUIButtonWithHolder(name, buttonPos, buttonSize, "<b>" .. name .. "</b>", tabsPanel)
	button.table.isTab = true
	button.table.tabName = name

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

	if #currentTab.pages < 2 then
		DisableButton(firstButton, true)
		DisableButton(prevButton, true)
		DisableButton(nextButton, true)
		DisableButton(lastButton, true)
	end

	pageCount.text = "<b> Page " .. tostring(currentTab.currentPage) .. "/" .. tostring(#currentTab.pages) .. "</b>"
end

local function CreateButton(name, description, tab, objectName, objectType)
	local panel = tab.pages[#tab.pages]

	local buttonSize = buttonsSize
	local buttonPos = panel.table.occupiedSize
	local button = MakeUIButtonWithHolder(name, buttonPos, buttonSize, "", panel)

	local safetyPadding = 6
	local nameLabelSize = newVector2(buttonSize.x, buttonSize.y/3)
	local descLabelSize = newVector2(buttonSize.x, buttonSize.y/2)
	local descLabelPos = newVector2(0, buttonSize.y/2.6)

	local nameLabel = MakeUITextWithHolder(tostring(name) .. " Button Name Label", newVector2(0,12), nameLabelSize, "<b>" .. name .. "</b>\n--------", button, safetyPadding)
	nameLabel.textColor = newColor(0.6, 0.6, 0.6, 1)
	nameLabel.textAlignment = "TopCenter"

	local descLabel = MakeUITextWithHolder(tostring(name) .. " Button Description Label", descLabelPos, descLabelSize, description, button, safetyPadding)
	descLabel.textColor = newColor(0.6, 0.6, 0.6, 1)
	descLabel.textSize = 11
	descLabel.textAlignment = "TopCenter"

	EnableButton(button, false)

	button.table.isSpiritLibSpawnButton = true
	button.table.objectName = objectName
	button.table.objectType = objectType

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

	print(button.table.isSpiritLibSpawnButton)
	print(button.table.objectName)
	print(button.table.objectType)

	if button.table.isFirstPageButton then
		SelectPage(1)
	elseif button.table.isPreviousPageButton then
		SelectPage(currentTab.currentPage - 1)
	elseif button.table.isNextPageButton then
		SelectPage(currentTab.currentPage + 1)
	elseif button.table.isLastPageButton then
		SelectPage(#currentTab.pages)
	elseif button.table.isTab then
		SelectTab(button.table.tabName)
	elseif button.table.isSpiritLibSpawnButton and button.table.objectName and button.table.objectType then

		local spawnPos = LocalPlayer().position + LocalPlayer().forward

		local modelTable = GetModule("Models").Globals[ "ModelsByName"]

		print("button click")

		if ModuleSettings.AllowedSpawnTypes[button.table.objectType] then

			if button.table.objectType == "Model" then

				local part = GetModule("Models").Call( "GenerateKnownModel", button.table.objectName, spawnPos, false)

				if part then
					part.position = LocalPlayer().position + LocalPlayer().forward * (part.size.z+0.5) + newVector3(0,part.size.y/2-0.35,0)

					local angles = LocalPlayer().angles
					angles.x = 0
					angles.y = angles.y + 180
					part.angles = angles
				end
			elseif button.table.objectType == "Weapon" then
				NetworkSendToHost("requestWeapon", {button.table.objectName})
			end
		end
	end
end

function Update()
	if InputPressed("q") then
		if ModuleSettings.AllowQMenu then
			mainPanel.enabled = true
		end
	elseif InputReleased("q") then
		mainPanel.enabled = false
	end
end

function OnSpiritLibLoaded()

	-- Create the tabs for the UI
	CreateTab("Models", 60)
	CreateTab("Weapons", 70)
	CreateTab("Entities", 80)
	CreateTab("NPCs", 40)
	CreateTab("Vehicles", 80)
	CreateTab("Saves", 50)


	-- Import the default objects pack

	for i, objectJson in pairs(GetModule("Default Objects").Globals[ "BuiltInObjects"]) do
	    local object = FromJson(objectJson)

	    if object.objectType == "Model" then
	    	-- Register model with models system instead of only keeping the json in the button tables
	    	GetModule("Models").Call( "RegisterModel", object.name, objectJson)

	    	CreateButton(object.name, object.description, allTabs["Models"], object.name, object.objectType)
	    elseif object.objectType == "Weapon" and object.weaponScript then
		    GetModule("Weapons").Call( "RegisterWeapon", object.name, objectJson)

		    CreateButton(object.name, object.description, allTabs["Weapons"], object.name, object.objectType)
		end

	    
	end

	UpdatePagination()
end