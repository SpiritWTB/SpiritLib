local SpiritLib = function() return PartByName("SpiritLib").scripts[1] end

function CallModuleFunction(moduleName, name, ...) return SpiritLib().Globals.SpiritLib.Modules[moduleName].scripts[1].Call(name, ...) end
function GetModuleVariable(moduleName, name) return SpiritLib().Globals.SpiritLib.Modules[moduleName].scripts[1].Globals[name] end

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

	button.table.isTab = true

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

local function CreateButton(name, description, panel, modelDataJson)
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

	button.table.isSpiritLibSpawnButton = true
	button.table.spawnData = modelDataJson

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
	if button.table.isTab then
		SelectTab(button.name)
	end

	if button.table.isSpiritLibSpawnButton and button.table.spawnData then
		local spawnPos = LocalPlayer().position + LocalPlayer().forward
		CallModuleFunction("Models", "GenerateModel", button.table.spawnData, spawnPos)
	end
end

function Update()
	if InputPressed("q") then
		mainWindow.enabled = true
	elseif InputReleased("q") then
		mainWindow.enabled = false
	end
end

CreateTab("Models", 60)
CreateTab("Weapons", 70)
CreateTab("Entities", 80)
CreateTab("NPCs", 40)
CreateTab("Vehicles", 80)
CreateTab("Dupes", 50)
CreateTab("Saves", 50)

BuiltInModels = {
	'{"name":"Traffic Cone","description":"A classic orange and white traffic cone","data":[{"name":"TrafficCone","parttype":0,"position":{x: -2.70359, y: 1.242865, z: 3.589343},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.9295015, y: 0.1022455, z: 0.9295015},"color":{x: 0.972549, y: 0.254902, z: 0.1882353, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"TrafficCone","parttype":4,"position":{x: -2.703588, y: 1.772532, z: 3.589342},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.5873281, y: 0.9660257, z: 0.5873281},"color":{x: 0.8980392, y: 0.5019608, z: 0.2, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"TrafficCone","parttype":4,"position":{x: -2.703589, y: 1.77319, z: 3.589343},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.5873281, y: 0.9660257, z: 0.5873281},"color":{x: 0.972549, y: 0.254902, z: 0.1882353, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"TrafficCone","parttype":4,"position":{x: -2.703589, y: 1.82006, z: 3.589343},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.4853157, y: 0.6902756, z: 0.4853157},"color":{x: 1, y: 1, z: 1, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"TrafficCone","parttype":4,"position":{x: -2.703589, y: 1.97006, z: 3.589343},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.3049602, y: 0.3837534, z: 0.3049602},"color":{x: 1, y: 1, z: 1, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"TrafficCone","parttype":0,"position":{x: -2.70359, y: 1.242865, z: 3.589343},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.9154018, y: 0.1006946, z: 0.9154018},"color":{x: 0.8980392, y: 0.5019608, z: 0.2, w: 1},"bevel":true,"visible":true,"cancollide":true}]}',
	'{"name":"WoodCrate","description":"A small wooden crate","data":[{"name":"WoodCrate","parttype":0,"position":{x: 2.099818, y: 1.865, z: 1.916675},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.1999999, y: 0.5999999, z: 0.1999999},"color":{x: 0.3764706, y: 0.227451, z: 0.1568628, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"WoodCrate","parttype":0,"position":{x: 2.899818, y: 1.865, z: 1.916675},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.1999999, y: 0.5999999, z: 0.1999999},"color":{x: 0.3764706, y: 0.227451, z: 0.1568628, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"WoodCrate","parttype":0,"position":{x: 2.899818, y: 1.865, z: 1.116674},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.1999999, y: 0.5999999, z: 0.1999999},"color":{x: 0.3764706, y: 0.227451, z: 0.1568628, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"WoodCrate","parttype":0,"position":{x: 2.099818, y: 1.865, z: 1.116674},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.1999999, y: 0.5999999, z: 0.1999999},"color":{x: 0.3764706, y: 0.227451, z: 0.1568628, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"WoodCrate","parttype":0,"position":{x: 2.499818, y: 1.465001, z: 1.916674},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.5999999, y: 0.1999999, z: 0.1999999},"color":{x: 0.3764706, y: 0.227451, z: 0.1568628, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"WoodCrate","parttype":0,"position":{x: 2.499818, y: 1.465001, z: 1.116673},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.5999999, y: 0.1999999, z: 0.1999999},"color":{x: 0.3764706, y: 0.227451, z: 0.1568628, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"WoodCrate","parttype":0,"position":{x: 2.499818, y: 2.265001, z: 1.116673},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.5999999, y: 0.1999999, z: 0.1999999},"color":{x: 0.3764706, y: 0.227451, z: 0.1568628, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"WoodCrate","parttype":0,"position":{x: 2.499818, y: 2.265001, z: 1.916674},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.5999999, y: 0.1999999, z: 0.1999999},"color":{x: 0.3764706, y: 0.227451, z: 0.1568628, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"WoodCrate","parttype":0,"position":{x: 2.099818, y: 2.265001, z: 1.516674},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.1999999, y: 0.1999999, z: 1},"color":{x: 0.3764706, y: 0.227451, z: 0.1568628, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"WoodCrate","parttype":0,"position":{x: 2.899818, y: 2.265001, z: 1.516674},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.1999999, y: 0.1999999, z: 1},"color":{x: 0.3764706, y: 0.227451, z: 0.1568628, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"WoodCrate","parttype":0,"position":{x: 2.899818, y: 1.465001, z: 1.516674},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.1999999, y: 0.1999999, z: 1},"color":{x: 0.3764706, y: 0.227451, z: 0.1568628, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"WoodCrate","parttype":0,"position":{x: 2.099818, y: 1.465001, z: 1.516674},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.1999999, y: 0.1999999, z: 1},"color":{x: 0.3764706, y: 0.227451, z: 0.1568628, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"WoodCrate","parttype":0,"position":{x: 2.499818, y: 1.865001, z: 1.516674},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.7690598, y: 0.7690598, z: 0.7690598},"color":{x: 0.3764706, y: 0.227451, z: 0.1568628, w: 1},"bevel":false,"visible":true,"cancollide":true}]}',
	'{"name":"Physgun","description":"The model to be for the Physgun weapon","data":[{"name":"Physgun","parttype":0,"position":{x: 0.7776691, y: 2.372158, z: 3.527275},"angles":{x: -2.049057E-05, y: 0, z: 0},"size":{x: 0.3494445, y: 0.2, z: 0.2694452},"color":{x: 0.09803922, y: 0.09803922, z: 0.09803922, w: 1},"bevel":false,"visible":true,"cancollide":false},{"name":"Physgun","parttype":0,"position":{x: 0.7726693, y: 2.453192, z: 4.055526},"angles":{x: -2.049057E-05, y: 0, z: 0},"size":{x: 0.11, y: 0.11, z: 0.7494453},"color":{x: 0.4901961, y: 0.7294118, z: 0.9529412, w: 1},"bevel":true,"visible":true,"cancollide":false},{"name":"Physgun","parttype":2,"position":{x: 0.8837144, y: 2.49032, z: 3.419743},"angles":{x: 29.99999, y: 180.0001, z: -5.641095E-12},"size":{x: 0.1051069, y: 0.1051069, z: 0.1051069},"color":{x: 0.4901961, y: 0.7294118, z: 0.9529412, w: 1},"bevel":false,"visible":true,"cancollide":false},{"name":"Physgun","parttype":0,"position":{x: 0.2717658, y: 2.399264, z: 3.610444},"angles":{x: -2.049057E-05, y: 0, z: 0},"size":{x: 0.1201054, y: 0.1707214, z: 0.1707214},"color":{x: 0.4901961, y: 0.7294118, z: 0.9529412, w: 1},"bevel":true,"visible":true,"cancollide":false},{"name":"Physgun","parttype":0,"position":{x: 0.4081386, y: 2.399264, z: 3.610444},"angles":{x: -2.049057E-05, y: 0, z: 0},"size":{x: 0.2799995, y: 0.101, z: 0.101},"color":{x: 0.3921569, y: 0.3921569, z: 0.3921569, w: 1},"bevel":false,"visible":true,"cancollide":false},{"name":"Physgun","parttype":0,"position":{x: 0.7776692, y: 2.135939, z: 3.411176},"angles":{x: 315, y: 0, z: 0},"size":{x: 0.1443028, y: 0.1833965, z: 0.4580714},"color":{x: 0.09803922, y: 0.09803922, z: 0.09803922, w: 1},"bevel":false,"visible":true,"cancollide":false},{"name":"Physgun","parttype":0,"position":{x: 0.7776692, y: 2.135619, z: 3.411497},"angles":{x: 315, y: 0, z: 0},"size":{x: 0.1833975, y: 0.1243024, z: 0.4580713},"color":{x: 0.09803922, y: 0.09803922, z: 0.09803922, w: 1},"bevel":false,"visible":true,"cancollide":false},{"name":"Physgun","parttype":0,"position":{x: 0.7776692, y: 1.96499, z: 3.243405},"angles":{x: 315, y: 0, z: 0},"size":{x: 0.103042, y: 0.1030415, z: 0.1784013},"color":{x: 0.3921569, y: 0.3921569, z: 0.3921569, w: 1},"bevel":false,"visible":true,"cancollide":false},{"name":"Physgun","parttype":0,"position":{x: 0.7776693, y: 2.458192, z: 3.905545},"angles":{x: -2.049057E-05, y: 0, z: 0},"size":{x: 0.16, y: 0.22, z: 0.9194456},"color":{x: 0.3921569, y: 0.3921569, z: 0.3921569, w: 1},"bevel":true,"visible":true,"cancollide":false},{"name":"Physgun","parttype":0,"position":{x: 0.7776691, y: 2.332157, z: 4.00375},"angles":{x: -2.049057E-05, y: 0, z: 0},"size":{x: 0.3494445, y: 0.2, z: 0.2694452},"color":{x: 0.09803922, y: 0.09803922, z: 0.09803922, w: 1},"bevel":true,"visible":true,"cancollide":false},{"name":"Physgun","parttype":0,"position":{x: 0.7776692, y: 2.399264, z: 3.688537},"angles":{x: -2.049057E-05, y: 0, z: 0},"size":{x: 0.3666723, y: 0.3998346, z: 0.4334079},"color":{x: 0.3921569, y: 0.3921569, z: 0.3921569, w: 1},"bevel":false,"visible":true,"cancollide":false},{"name":"Physgun","parttype":0,"position":{x: 0.7776692, y: 2.324264, z: 3.688537},"angles":{x: -2.049057E-05, y: 0, z: 0},"size":{x: 0.6494446, y: 0.4494447, z: 0.6494453},"color":{x: 0.09803922, y: 0.09803922, z: 0.09803922, w: 1},"bevel":true,"visible":true,"cancollide":false},{"name":"Physgun","parttype":0,"position":{x: 0.7776692, y: 2.099429, z: 3.377844},"angles":{x: 315, y: 0, z: 0},"size":{x: 0.1583596, y: 0.1583608, z: 0.4209192},"color":{x: 0.09803922, y: 0.09803922, z: 0.09803922, w: 1},"bevel":false,"visible":true,"cancollide":false}]}',
	'{"name":"Fence ","description":"A fence piece to be used for yard fences or insecure walls","data":[{"name":"Fence","parttype":0,"position":{x: 9.142446, y: 4.868464, z: 13.19534},"angles":{x: 0, y: 0, z: 275.8658},"size":{x: 0.3675291, y: 4.980514, z: 0.1045292},"color":{x: 0.3764706, y: 0.227451, z: 0.1568628, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"Fence","parttype":0,"position":{x: 9.388923, y: 2.63609, z: 13.19534},"angles":{x: 0, y: 0, z: 285.9571},"size":{x: 0.3675291, y: 4.980514, z: 0.1045292},"color":{x: 0.3764706, y: 0.227451, z: 0.1568628, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"Fence","parttype":0,"position":{x: 7.493279, y: 3.599243, z: 13.10234},"angles":{x: 0, y: 0, z: 357.2724},"size":{x: 0.3675291, y: 4.980514, z: 0.1045292},"color":{x: 0.3764706, y: 0.227451, z: 0.1568628, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"Fence","parttype":0,"position":{x: 10.40439, y: 3.81103, z: 13.10234},"angles":{x: 0, y: 0, z: 359.9142},"size":{x: 0.3675291, y: 4.980514, z: 0.1045292},"color":{x: 0.3764706, y: 0.227451, z: 0.1568628, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"Fence","parttype":0,"position":{x: 11.09275, y: 3.739253, z: 13.10234},"angles":{x: 0, y: 0, z: 3},"size":{x: 0.3675291, y: 4.980514, z: 0.1045292},"color":{x: 0.3764706, y: 0.227451, z: 0.1568628, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"Fence","parttype":0,"position":{x: 9.692061, y: 3.739253, z: 13.10234},"angles":{x: 0, y: 0, z: -9.071345E-06},"size":{x: 0.3675291, y: 4.980514, z: 0.1045292},"color":{x: 0.3764706, y: 0.227451, z: 0.1568628, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"Fence","parttype":0,"position":{x: 8.986076, y: 3.754663, z: 13.10234},"angles":{x: 0, y: 0, z: 0.9999934},"size":{x: 0.3675291, y: 4.980514, z: 0.1045292},"color":{x: 0.3764706, y: 0.227451, z: 0.1568628, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"Fence","parttype":0,"position":{x: 8.26298, y: 3.776123, z: 13.10234},"angles":{x: 0, y: 0, z: 359},"size":{x: 0.3675291, y: 4.980514, z: 0.1045292},"color":{x: 0.3764706, y: 0.227451, z: 0.1568628, w: 1},"bevel":false,"visible":true,"cancollide":true}]}',
	'{"name":"Spirit Table ","description":"Author: Reman\n\nA table with a little spirit buddy","data":[{"name":"SpiritTable","parttype":0,"position":{x: -7.131211, y: 1.619509, z: -1.025175},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.1060969, y: 0.9130948, z: 0.1018997},"color":{x: 0.1058824, y: 0.1098039, z: 0.1411765, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"SpiritTable","parttype":0,"position":{x: -7.131211, y: 1.619509, z: -2.312873},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.1060969, y: 0.9130948, z: 0.1018997},"color":{x: 0.1058824, y: 0.1098039, z: 0.1411765, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"SpiritTable","parttype":0,"position":{x: -10.32672, y: 1.619509, z: -2.312873},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.1060969, y: 0.9130948, z: 0.1018997},"color":{x: 0.1058824, y: 0.1098039, z: 0.1411765, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"SpiritTable","parttype":0,"position":{x: -9.680696, y: 2.33921, z: -1.3233},"angles":{x: 0, y: 10, z: 0},"size":{x: 0.100593, y: 0.1446968, z: 0.1122988},"color":{x: 0.972549, y: 0.254902, z: 0.1882353, w: 1},"bevel":true,"visible":true,"cancollide":true},{"name":"SpiritTable","parttype":0,"position":{x: -9.559369, y: 2.33921, z: -1.344693},"angles":{x: 0, y: 10, z: 0},"size":{x: 0.100593, y: 0.1446968, z: 0.1122988},"color":{x: 0.972549, y: 0.254902, z: 0.1882353, w: 1},"bevel":true,"visible":true,"cancollide":true},{"name":"SpiritTable","parttype":0,"position":{x: -9.638781, y: 2.29506, z: -1.466553},"angles":{x: 0, y: 10, z: 0},"size":{x: 0.3804937, y: 0.3491969, z: 0.3446994},"color":{x: 1, y: 1, z: 1, w: 1},"bevel":true,"visible":true,"cancollide":true},{"name":"SpiritTable","parttype":0,"position":{x: -10.32672, y: 1.619509, z: -1.025174},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.1060969, y: 0.9130948, z: 0.1018997},"color":{x: 0.1058824, y: 0.1098039, z: 0.1411765, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"SpiritTable","parttype":0,"position":{x: -8.718118, y: 2.067759, z: -1.680551},"angles":{x: 0, y: 0, z: 0},"size":{x: 3.078495, y: 0.1027968, z: 1.208799},"color":{x: 1, y: 1, z: 1, w: 0.19},"bevel":false,"visible":true,"cancollide":true},{"name":"SpiritTable","parttype":0,"position":{x: -7.123664, y: 2.053327, z: -1.668601},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.1529971, y: 0.1968968, z: 1.254499},"color":{x: 0.3921569, y: 0.3921569, z: 0.3921569, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"SpiritTable","parttype":0,"position":{x: -10.32796, y: 2.053327, z: -1.655051},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.1529971, y: 0.1968968, z: 1.227399},"color":{x: 0.3921569, y: 0.3921569, z: 0.3921569, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"SpiritTable","parttype":0,"position":{x: -8.723775, y: 2.053459, z: -2.326951},"angles":{x: 0, y: 0, z: 0},"size":{x: 3.371592, y: 0.2031968, z: 0.1547998},"color":{x: 0.3921569, y: 0.3921569, z: 0.3921569, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"SpiritTable","parttype":0,"position":{x: -8.727661, y: 2.053459, z: -1.027951},"angles":{x: 0, y: 0, z: 0},"size":{x: 3.363194, y: 0.2031968, z: 0.1547998},"color":{x: 0.3921569, y: 0.3921569, z: 0.3921569, w: 1},"bevel":false,"visible":true,"cancollide":true}]}',
	'{"name":"Blocky Tree","description":"Author: Reman\n\nA nice looking block-style tree","data":[{"name":"RemanTree","parttype":0,"position":{x: 0.1378196, y: 5.059734, z: -0.3239154},"angles":{x: 355.0191, y: 0.4368803, z: 354.981},"size":{x: 2.075217, y: 0.9032981, z: 2.137599},"color":{x: 0, y: 0.3019608, z: 0.02352941, w: 1},"bevel":false,"visible":true,"cancollide":false},{"name":"RemanTree","parttype":0,"position":{x: 0.1363226, y: 5.547444, z: -0.3995384},"angles":{x: 4.980929, y: 0.4368803, z: 5.019004},"size":{x: 1.863099, y: 0.9523005, z: 1.896804},"color":{x: 0, y: 0.3019608, z: 0.02352941, w: 1},"bevel":false,"visible":true,"cancollide":false},{"name":"RemanTree","parttype":0,"position":{x: 0.1023775, y: 6.20932, z: -0.3729203},"angles":{x: 354.9809, y: 0.4335677, z: 0.01900285},"size":{x: 1.6306, y: 0.7765008, z: 1.5144},"color":{x: 0, y: 0.3019608, z: 0.02352941, w: 1},"bevel":false,"visible":true,"cancollide":false},{"name":"RemanTree","parttype":0,"position":{x: 0.2453499, y: 1.873301, z: -0.2254999},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.3752998, y: 0.5466014, z: 0.3259999},"color":{x: 0.5764706, y: 0.3019608, z: 0.1764706, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"RemanTree","parttype":0,"position":{x: -0.03929991, y: 1.692201, z: -0.2371498},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.6591997, y: 0.1844013, z: 0.5384999},"color":{x: 0.5764706, y: 0.3019608, z: 0.1764706, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"RemanTree","parttype":0,"position":{x: -0.1408501, y: 1.727951, z: -0.6853498},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.5024997, y: 0.2559012, z: 0.7172998},"color":{x: 0.5764706, y: 0.3019608, z: 0.1764706, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"RemanTree","parttype":0,"position":{x: 0.4357999, y: 1.794401, z: -0.4097998},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.6809996, y: 0.3888012, z: 0.5402001},"color":{x: 0.5764706, y: 0.3019608, z: 0.1764706, w: 1},"bevel":false,"visible":true,"cancollide":true},{"name":"RemanTree","parttype":0,"position":{x: 0.09280002, y: 3.466351, z: -0.3141999},"angles":{x: 0, y: 0, z: 0},"size":{x: 0.4813997, y: 3.732701, z: 0.3716001},"color":{x: 0.5764706, y: 0.3019608, z: 0.1764706, w: 1},"bevel":false,"visible":true,"cancollide":true}]}'
}

for i, modelJson in pairs(BuiltInModels) do
	model = FromJson(modelJson)

	-- once we get scripts on the side pass through the model, not the modelJson
	CreateButton(model.name, model.description, allTabs["Models"].panel, modelJson)
end