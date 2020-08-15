local allTabs = {
	{
		name = "Spawnlists",
		panel = MakeUIPanel(Vector2.zero, newVector2(40, 20))
	},
	{
		name = "Weapons",
		panel = MakeUIPanel(Vector2.zero, newVector2(40, 20))
	},
	{
		name = "Entities",
		panel = MakeUIPanel(Vector2.zero, newVector2(40, 20))
	},
	{
		name = "NPCs",
		panel = MakeUIPanel(Vector2.zero, newVector2(40, 20))
	},
	{
		name = "Vehicles",
		panel = MakeUIPanel(Vector2.zero, newVector2(40, 20))
	},
	{
		name = "Dupes",
		panel = MakeUIPanel(Vector2.zero, newVector2(40, 20))
	},
	{
		name = "Saves",
		panel = MakeUIPanel(Vector2.zero, newVector2(40, 20))
	}
}

local spawnWindowSize = newVector2(ScreenSize().x - 120, ScreenSize().y - 120)
local spawnWindowPos = newVector2(60, 60)
local spawnWindow = MakeUIPanel(spawnWindowPos, spawnWindowSize)
spawnWindow.color = newColor(0.14, 0.14, 0.14, 0.98)
spawnWindow.enabled = false

for i, tab in pairs(allTabs) do
	tab.panel.position = newVector2(60 * (i - 1) + (i - 1* tab.panel.size.x / 2), 60)
end

function Update()
	if InputPressed("q") then
		spawnWindow.enabled = true
	elseif InputReleased("q") then
		spawnWindow.enabled = false
	end
end