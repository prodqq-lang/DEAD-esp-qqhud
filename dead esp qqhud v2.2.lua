--// QQ HUD
--// Put this LocalScript inside StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--------------------------------------------------
-- CONFIG
--------------------------------------------------

local CONFIG = {
	-- Softer highlight colors (easier on the eyes)
	NoobColor = Color3.fromRGB(255, 226, 110),
	ZombieColor = Color3.fromRGB(140, 215, 140),
	MapColor = Color3.fromRGB(80, 150, 255),

	-- Player switches
	HighlightNoobs = true,
	HighlightZombies = true,
	ShowPlayerInfo = true,
	ShowSurvivals = true,
	ShowInfections = true,
	ShowCash = true,

	-- Map switches
	HighlightMap = false,
	ShowMapInfo = false,

	-- Misc
	MuteIntro = false,

	-- Highlight transparency (0 = solid, 1 = invisible), controlled by sliders
	PlayerTransparency = 0.6,
	MapTransparency = 0.7,

	MaxDistance = 10000,
	MapMaxDistance = 300, -- map billboards only show within this range
}

local SWITCH_SOUND_ID = "rbxasset://Sounds/switch.wav"

-- Animated text gradient palettes
local NOOB_PALETTE = {
	Color3.fromRGB(255, 230, 80),   -- yellow
	Color3.fromRGB(70, 150, 255),   -- blue
	Color3.fromRGB(144, 238, 144),  -- light green
}

local ZOMBIE_PALETTE = {
	Color3.fromRGB(144, 238, 144),  -- light green
	Color3.fromRGB(139, 90, 43),    -- brown
}

--------------------------------------------------
-- CLEAN OLD GUI
--------------------------------------------------

local OldGui = PlayerGui:FindFirstChild("QQ HUD")
if OldGui then
	OldGui:Destroy()
end

--------------------------------------------------
-- GUI
--------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QQ HUD"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 240, 0, 440)
Main.Position = UDim2.new(0, 30, 0.5, -220)
Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- pure black inside
Main.BackgroundTransparency = 0
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Main

-- Thick neon red border (old Roblox GUI look)
local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(255, 20, 20)
Stroke.Transparency = 0
Stroke.Thickness = 3
Stroke.LineJoinMode = Enum.LineJoinMode.Round
Stroke.Parent = Main

-- Click sound for every switch
local SwitchSound = Instance.new("Sound")
SwitchSound.Name = "SwitchSound"
SwitchSound.SoundId = SWITCH_SOUND_ID
SwitchSound.Volume = 0.6
SwitchSound.Parent = ScreenGui

local function PlaySwitchSound()
	SwitchSound.TimePosition = 0
	SwitchSound:Play()
end

--------------------------------------------------
-- TITLE
--------------------------------------------------

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 42)
Title.BackgroundTransparency = 1
Title.Text = "QQ HUD"
Title.TextColor3 = Color3.fromRGB(190, 190, 190)
Title.TextSize = 20
Title.Font = Enum.Font.ArialBold
Title.Parent = Main

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -20, 0, 20)
Subtitle.Position = UDim2.new(0, 10, 0, 35)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "DEAD ESP"
Subtitle.TextColor3 = Color3.fromRGB(170, 170, 178)
Subtitle.TextSize = 11
Subtitle.Font = Enum.Font.Arial
Subtitle.Parent = Main

--------------------------------------------------
-- SCROLLING AREA
--------------------------------------------------

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 1, -70)
Scroll.Position = UDim2.new(0, 8, 0, 65)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 130)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 5)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Scroll

--------------------------------------------------
-- TOGGLE CREATOR
--------------------------------------------------

local BASE_ROW = Color3.fromRGB(0, 0, 0)
local HOVER_ROW = Color3.fromRGB(28, 28, 28)
local ROW_BORDER = Color3.fromRGB(80, 80, 80)
local OFF_COLOR = Color3.fromRGB(65, 65, 70)

local function CreateToggle(text, default, onColor, callback)

	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, -4, 0, 36)
	Button.BackgroundColor3 = BASE_ROW
	Button.BorderSizePixel = 0
	Button.AutoButtonColor = false
	Button.Text = ""
	Button.Parent = Scroll

	local ButtonCorner = Instance.new("UICorner")
	ButtonCorner.CornerRadius = UDim.new(0, 7)
	ButtonCorner.Parent = Button

	local ButtonStroke = Instance.new("UIStroke")
	ButtonStroke.Color = ROW_BORDER
	ButtonStroke.Thickness = 1
	ButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	ButtonStroke.Parent = Button

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -55, 1, 0)
	Label.Position = UDim2.new(0, 12, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Color3.fromRGB(230, 230, 235)
	Label.TextSize = 13
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Font = Enum.Font.Arial
	Label.Parent = Button

	local Indicator = Instance.new("Frame")
	Indicator.Size = UDim2.new(0, 32, 0, 18)
	Indicator.Position = UDim2.new(1, -43, 0.5, -9)
	Indicator.BorderSizePixel = 0
	Indicator.Parent = Button

	local IndicatorCorner = Instance.new("UICorner")
	IndicatorCorner.CornerRadius = UDim.new(1, 0)
	IndicatorCorner.Parent = Indicator

	local Circle = Instance.new("Frame")
	Circle.Size = UDim2.new(0, 14, 0, 14)
	Circle.Position = UDim2.new(0, 2, 0.5, -7)
	Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Circle.BorderSizePixel = 0
	Circle.Parent = Indicator

	local CircleCorner = Instance.new("UICorner")
	CircleCorner.CornerRadius = UDim.new(1, 0)
	CircleCorner.Parent = Circle

	local State = default

	local function Apply()
		if State then
			Indicator.BackgroundColor3 = onColor
			Circle.Position = UDim2.new(1, -16, 0.5, -7)
		else
			Indicator.BackgroundColor3 = OFF_COLOR
			Circle.Position = UDim2.new(0, 2, 0.5, -7)
		end

		callback(State)
	end

	Button.MouseButton1Click:Connect(function()
		State = not State
		Apply()
		PlaySwitchSound()
	end)

	Button.MouseEnter:Connect(function()
		Button.BackgroundColor3 = HOVER_ROW
	end)

	Button.MouseLeave:Connect(function()
		Button.BackgroundColor3 = BASE_ROW
	end)

	Apply()

	return Button
end

--------------------------------------------------
-- SLIDER CREATOR (value = 0..1)
--------------------------------------------------

local function CreateSlider(text, default, color, callback)

	local Holder = Instance.new("Frame")
	Holder.Size = UDim2.new(1, -4, 0, 50)
	Holder.BackgroundColor3 = BASE_ROW
	Holder.BorderSizePixel = 0
	Holder.Parent = Scroll

	local HolderCorner = Instance.new("UICorner")
	HolderCorner.CornerRadius = UDim.new(0, 7)
	HolderCorner.Parent = Holder

	local HolderStroke = Instance.new("UIStroke")
	HolderStroke.Color = ROW_BORDER
	HolderStroke.Thickness = 1
	HolderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	HolderStroke.Parent = Holder

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -70, 0, 22)
	Label.Position = UDim2.new(0, 12, 0, 4)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Color3.fromRGB(230, 230, 235)
	Label.TextSize = 13
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Font = Enum.Font.Arial
	Label.Parent = Holder

	local ValueLabel = Instance.new("TextLabel")
	ValueLabel.Size = UDim2.new(0, 50, 0, 22)
	ValueLabel.Position = UDim2.new(1, -62, 0, 4)
	ValueLabel.BackgroundTransparency = 1
	ValueLabel.TextColor3 = color
	ValueLabel.TextSize = 12
	ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
	ValueLabel.Font = Enum.Font.ArialBold
	ValueLabel.Parent = Holder

	local Track = Instance.new("Frame")
	Track.Size = UDim2.new(1, -24, 0, 6)
	Track.Position = UDim2.new(0, 12, 0, 34)
	Track.BackgroundColor3 = Color3.fromRGB(60, 60, 66)
	Track.BorderSizePixel = 0
	Track.Parent = Holder

	local TrackCorner = Instance.new("UICorner")
	TrackCorner.CornerRadius = UDim.new(1, 0)
	TrackCorner.Parent = Track

	local Fill = Instance.new("Frame")
	Fill.Size = UDim2.new(default, 0, 1, 0)
	Fill.BackgroundColor3 = color
	Fill.BorderSizePixel = 0
	Fill.Parent = Track

	local FillCorner = Instance.new("UICorner")
	FillCorner.CornerRadius = UDim.new(1, 0)
	FillCorner.Parent = Fill

	local Knob = Instance.new("Frame")
	Knob.Size = UDim2.new(0, 12, 0, 12)
	Knob.AnchorPoint = Vector2.new(0.5, 0.5)
	Knob.Position = UDim2.new(default, 0, 0.5, 0)
	Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Knob.BorderSizePixel = 0
	Knob.Parent = Track

	local KnobCorner = Instance.new("UICorner")
	KnobCorner.CornerRadius = UDim.new(1, 0)
	KnobCorner.Parent = Knob

	-- Invisible hit area so the slider is easy to grab
	local Hit = Instance.new("TextButton")
	Hit.Size = UDim2.new(1, 0, 0, 26)
	Hit.Position = UDim2.new(0, 0, 0, 24)
	Hit.BackgroundTransparency = 1
	Hit.Text = ""
	Hit.Parent = Holder

	local function Set(alpha)
		alpha = math.clamp(alpha, 0, 1)
		Fill.Size = UDim2.new(alpha, 0, 1, 0)
		Knob.Position = UDim2.new(alpha, 0, 0.5, 0)
		ValueLabel.Text = math.floor(alpha * 100 + 0.5) .. "%"
		callback(alpha)
	end

	local function FromInput(input)
		Set((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X)
	end

	local Sliding = false

	Hit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			Sliding = true
			FromInput(input)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if Sliding and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			FromInput(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			Sliding = false
		end
	end)

	Set(default)

	return Holder
end

--------------------------------------------------
-- SECTION LABEL
--------------------------------------------------

local function CreateSection(text)

	local Section = Instance.new("TextLabel")
	Section.Size = UDim2.new(1, -4, 0, 25)
	Section.BackgroundTransparency = 1
	Section.Text = text
	Section.TextColor3 = Color3.fromRGB(255, 255, 255)
	Section.TextSize = 11
	Section.TextXAlignment = Enum.TextXAlignment.Left
	Section.Font = Enum.Font.ArialBold
	Section.Parent = Scroll

	return Section
end

--------------------------------------------------
-- TOGGLES + SLIDERS
-- (switch color matches the highlight color it controls)
--------------------------------------------------

CreateSection("PLAYER ESP")

CreateToggle("Noob Highlights", CONFIG.HighlightNoobs, CONFIG.NoobColor, function(value)
	CONFIG.HighlightNoobs = value
end)

CreateToggle("Zombie Highlights", CONFIG.HighlightZombies, CONFIG.ZombieColor, function(value)
	CONFIG.HighlightZombies = value
end)

CreateSlider("Player Highlight Transparency", CONFIG.PlayerTransparency, CONFIG.NoobColor, function(value)
	CONFIG.PlayerTransparency = value
end)

CreateToggle("Name + Distance", CONFIG.ShowPlayerInfo, Color3.fromRGB(235, 235, 240), function(value)
	CONFIG.ShowPlayerInfo = value
end)

CreateToggle("Survivals", CONFIG.ShowSurvivals, CONFIG.ZombieColor, function(value)
	CONFIG.ShowSurvivals = value
end)

CreateToggle("Infections", CONFIG.ShowInfections, Color3.fromRGB(235, 110, 110), function(value)
	CONFIG.ShowInfections = value
end)

CreateToggle("Cash", CONFIG.ShowCash, CONFIG.NoobColor, function(value)
	CONFIG.ShowCash = value
end)

CreateSection("MAP ESP")

CreateToggle("Map Highlights", CONFIG.HighlightMap, CONFIG.MapColor, function(value)
	CONFIG.HighlightMap = value
end)

CreateSlider("Map Highlight Transparency", CONFIG.MapTransparency, CONFIG.MapColor, function(value)
	CONFIG.MapTransparency = value
end)

CreateToggle("Map Item Billboards", CONFIG.ShowMapInfo, CONFIG.MapColor, function(value)
	CONFIG.ShowMapInfo = value
end)

CreateSection("MISC")

CreateToggle("Mute IntroMusic", CONFIG.MuteIntro, Color3.fromRGB(255, 150, 70), function(value)
	CONFIG.MuteIntro = value
end)

--------------------------------------------------
-- CANVAS SIZE
--------------------------------------------------

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
end)

--------------------------------------------------
-- DRAGGING
--------------------------------------------------

local Dragging = false
local DragStart
local StartPosition

Title.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		Dragging = true
		DragStart = input.Position
		StartPosition = Main.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				Dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)

	if not Dragging then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.MouseMovement
		and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local Delta = input.Position - DragStart

	Main.Position = UDim2.new(
		StartPosition.X.Scale,
		StartPosition.X.Offset + Delta.X,
		StartPosition.Y.Scale,
		StartPosition.Y.Offset + Delta.Y
	)
end)

--------------------------------------------------
-- MINIMIZE (RIGHT CTRL)
--------------------------------------------------

UserInputService.InputBegan:Connect(function(input, gameProcessed)

	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.RightControl then
		Main.Visible = not Main.Visible
		PlaySwitchSound()
	end
end)

--------------------------------------------------
-- ANIMATED GRADIENT HELPERS
--------------------------------------------------

local function SampleCycle(palette, x)
	local n = #palette
	x = (x % 1) * n
	local i = math.floor(x)
	local f = x - i
	local a = palette[i % n + 1]
	local b = palette[(i + 1) % n + 1]
	return a:Lerp(b, f)
end

-- Builds a looping ColorSequence; shifting "phase" makes it flow
local function BuildSequence(palette, phase)
	local Keys = {}
	local Steps = 8

	for s = 0, Steps do
		local t = s / Steps
		table.insert(Keys, ColorSequenceKeypoint.new(t, SampleCycle(palette, phase + t)))
	end

	return ColorSequence.new(Keys)
end

--------------------------------------------------
-- STORAGE
--------------------------------------------------

local PlayerObjects = {}
local MapObjects = {}

--------------------------------------------------
-- GET ROOT PART
--------------------------------------------------

local function GetRoot(Object)

	if not Object then
		return nil
	end

	if Object:IsA("BasePart") then
		return Object
	end

	if Object:IsA("Model") then
		return Object.PrimaryPart
			or Object:FindFirstChild("HumanoidRootPart")
			or Object:FindFirstChildWhichIsA("BasePart", true)
	end

	return Object:FindFirstChildWhichIsA("BasePart", true)
end

--------------------------------------------------
-- PLAYER KIND (Noob / Zombie / nil)
--------------------------------------------------

local function GetPlayerKind(Player)

	local Team = Player.Team

	if not Team then
		return nil
	end

	local Name = string.lower(Team.Name)

	-- Spectators are ignored (matches "Spectator", "Spectators", etc.)
	if string.find(Name, "spectat", 1, true) then
		return nil
	end

	-- Zombie-side teams ("Zombie", "Zombies", "Infected", ...)
	if string.find(Name, "zombie", 1, true) or string.find(Name, "infect", 1, true) then
		return "Zombie"
	end

	-- Every other team counts as the noob side
	return "Noob"
end

local function GetKindColor(Kind)
	if Kind == "Noob" then
		return CONFIG.NoobColor
	end

	return CONFIG.ZombieColor
end

--------------------------------------------------
-- FIND PLAYER TOOL
--------------------------------------------------

local function FindPlayerTool(Player)

	local Character = Player.Character

	if Character then
		for _, Object in ipairs(Character:GetChildren()) do
			if Object:IsA("Tool") then
				return Object.Name
			end
		end
	end

	local Backpack = Player:FindFirstChildOfClass("Backpack")

	if Backpack then
		for _, Object in ipairs(Backpack:GetChildren()) do
			if Object:IsA("Tool") then
				return Object.Name
			end
		end
	end

	return nil
end

--------------------------------------------------
-- STATS
--------------------------------------------------

local function FindStat(Player, Name)

	local Leaderstats = Player:FindFirstChild("leaderstats")

	if Leaderstats then
		local Stat = Leaderstats:FindFirstChild(Name)

		if Stat then
			return Stat
		end
	end

	return Player:FindFirstChild(Name)
end

local function GetStatText(Player, Name)

	local Stat = FindStat(Player, Name)

	if not Stat then
		return nil
	end

	return tostring(Stat.Value)
end

--------------------------------------------------
-- CREATE PLAYER BILLBOARD
--------------------------------------------------

local function MakeTextGradient(Label)
	local Gradient = Instance.new("UIGradient")
	Gradient.Parent = Label
	return Gradient
end

local function CreatePlayerBillboard(Player, Character)

	local Root = GetRoot(Character)

	if not Root then
		return
	end

	local Billboard = Instance.new("BillboardGui")
	Billboard.Name = "QQPlayerInfo"
	Billboard.Adornee = Root
	Billboard.Size = UDim2.new(0, 190, 0, 80)
	Billboard.StudsOffset = Vector3.new(0, 3.5, 0)
	Billboard.AlwaysOnTop = true
	Billboard.MaxDistance = CONFIG.MaxDistance
	Billboard.Parent = Root

	-- Name + distance (robotic font)
	local NameLabel = Instance.new("TextLabel")
	NameLabel.Name = "Name"
	NameLabel.Size = UDim2.new(1, 0, 0, 18)
	NameLabel.BackgroundTransparency = 1
	NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	NameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	NameLabel.TextStrokeTransparency = 0.45
	NameLabel.TextSize = 15
	NameLabel.Font = Enum.Font.SciFi
	NameLabel.Parent = Billboard

	-- Stats
	local InfoLabel = Instance.new("TextLabel")
	InfoLabel.Name = "Info"
	InfoLabel.Position = UDim2.new(0, 0, 0, 18)
	InfoLabel.Size = UDim2.new(1, 0, 1, -18)
	InfoLabel.BackgroundTransparency = 1
	InfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	InfoLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	InfoLabel.TextStrokeTransparency = 0.5
	InfoLabel.TextSize = 12
	InfoLabel.Font = Enum.Font.Code
	InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
	InfoLabel.Parent = Billboard

	PlayerObjects[Player] = PlayerObjects[Player] or {}
	PlayerObjects[Player].Billboard = Billboard
	PlayerObjects[Player].NameLabel = NameLabel
	PlayerObjects[Player].InfoLabel = InfoLabel
	PlayerObjects[Player].Gradients = {
		MakeTextGradient(NameLabel),
		MakeTextGradient(InfoLabel),
	}
end

--------------------------------------------------
-- CREATE PLAYER HIGHLIGHT
--------------------------------------------------

local function CreatePlayerHighlight(Player, Character, Kind)

	local Color = GetKindColor(Kind)

	local Highlight = Instance.new("Highlight")
	Highlight.Name = "QQPlayerHighlight"
	Highlight.FillColor = Color
	Highlight.OutlineColor = Color
	Highlight.FillTransparency = CONFIG.PlayerTransparency
	Highlight.OutlineTransparency = 0.3
	Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	Highlight.Adornee = Character
	Highlight.Parent = Character

	PlayerObjects[Player] = PlayerObjects[Player] or {}
	PlayerObjects[Player].Highlight = Highlight
end

--------------------------------------------------
-- SETUP / CLEAN PLAYER
--------------------------------------------------

local function CleanPlayer(Player)

	local Data = PlayerObjects[Player]

	if Data then
		if Data.Highlight then
			Data.Highlight:Destroy()
		end

		if Data.Billboard then
			Data.Billboard:Destroy()
		end

		PlayerObjects[Player] = nil
	end
end

local function SetupPlayer(Player)

	if Player == LocalPlayer then
		return
	end

	CleanPlayer(Player)

	local Character = Player.Character

	if not Character then
		return
	end

	local Kind = GetPlayerKind(Player)

	if not Kind then
		return
	end

	PlayerObjects[Player] = {}

	CreatePlayerHighlight(Player, Character, Kind)
	CreatePlayerBillboard(Player, Character)
end

--------------------------------------------------
-- PLAYER EVENTS
--------------------------------------------------

local function ConnectPlayer(Player)

	if Player == LocalPlayer then
		return
	end

	Player.CharacterAdded:Connect(function()
		task.wait(0.5)
		SetupPlayer(Player)
	end)

	Player:GetPropertyChangedSignal("Team"):Connect(function()
		task.wait()
		SetupPlayer(Player)
	end)

	if Player.Character then
		task.spawn(function()
			task.wait(0.5)
			SetupPlayer(Player)
		end)
	end
end

for _, Player in ipairs(Players:GetPlayers()) do
	ConnectPlayer(Player)
end

Players.PlayerAdded:Connect(ConnectPlayer)
Players.PlayerRemoving:Connect(CleanPlayer)

-- Safety net: every second, make sure everyone who should have ESP has it
task.spawn(function()
	while ScreenGui.Parent do

		for _, Player in ipairs(Players:GetPlayers()) do

			if Player ~= LocalPlayer and Player.Character then

				local Kind = GetPlayerKind(Player)
				local Data = PlayerObjects[Player]

				if Kind then
					if not Data
						or not Data.Highlight
						or not Data.Highlight.Parent
						or Data.Highlight.Adornee ~= Player.Character
						or not Data.Billboard
						or not Data.Billboard.Parent then
						SetupPlayer(Player)
					end
				elseif Data then
					CleanPlayer(Player)
				end
			end
		end

		task.wait(1)
	end
end)

--------------------------------------------------
-- MAP FOLDER ESP
-- One Highlight on the whole MapFolder (updates automatically
-- when things are placed / deleted), plus a small billboard
-- per item that is added / removed live.
--------------------------------------------------

local MapHighlight = Instance.new("Highlight")
MapHighlight.Name = "QQMapHighlight"
MapHighlight.FillColor = CONFIG.MapColor
MapHighlight.OutlineColor = CONFIG.MapColor
MapHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
MapHighlight.Enabled = false
MapHighlight.Parent = workspace

local MapBillboards = Instance.new("Folder")
MapBillboards.Name = "QQMapBillboards"
MapBillboards.Parent = ScreenGui

local MapFolder = nil
local MapConnections = {}

local function RemoveMapItem(Item)

	local Data = MapObjects[Item]

	if Data then
		if Data.Billboard then
			Data.Billboard:Destroy()
		end

		MapObjects[Item] = nil
	end
end

local function AddMapItem(Item)

	if MapObjects[Item] then
		return
	end

	local Billboard = Instance.new("BillboardGui")
	Billboard.Name = "QQMapItem"
	Billboard.Adornee = GetRoot(Item) -- re-checked every update
	Billboard.Size = UDim2.new(0, 120, 0, 34)
	Billboard.StudsOffset = Vector3.new(0, 2, 0)
	Billboard.AlwaysOnTop = true
	Billboard.MaxDistance = CONFIG.MapMaxDistance
	Billboard.Enabled = false
	Billboard.Parent = MapBillboards

	-- Blue -> black panel
	local Panel = Instance.new("Frame")
	Panel.Size = UDim2.new(1, 0, 1, 0)
	Panel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Panel.BackgroundTransparency = 0.15
	Panel.BorderSizePixel = 0
	Panel.Parent = Billboard

	local PanelCorner = Instance.new("UICorner")
	PanelCorner.CornerRadius = UDim.new(0, 6)
	PanelCorner.Parent = Panel

	local PanelStroke = Instance.new("UIStroke")
	PanelStroke.Color = CONFIG.MapColor
	PanelStroke.Thickness = 1.2
	PanelStroke.Parent = Panel

	local PanelGradient = Instance.new("UIGradient")
	PanelGradient.Rotation = 90
	PanelGradient.Color = ColorSequence.new(
		Color3.fromRGB(70, 140, 255),
		Color3.fromRGB(0, 0, 0)
	)
	PanelGradient.Parent = Panel

	local Text = Instance.new("TextLabel")
	Text.Size = UDim2.new(1, -8, 1, 0)
	Text.Position = UDim2.new(0, 4, 0, 0)
	Text.BackgroundTransparency = 1
	Text.TextColor3 = Color3.fromRGB(255, 255, 255)
	Text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	Text.TextStrokeTransparency = 0.6
	Text.TextSize = 12
	Text.Font = Enum.Font.SciFi
	Text.TextTruncate = Enum.TextTruncate.AtEnd
	Text.Parent = Panel

	MapObjects[Item] = {
		Billboard = Billboard,
		Text = Text,
	}
end

local function AttachMapFolder(Folder)

	if Folder == MapFolder then
		return
	end

	for _, Connection in ipairs(MapConnections) do
		Connection:Disconnect()
	end

	MapConnections = {}

	for Item in pairs(MapObjects) do
		RemoveMapItem(Item)
	end

	MapFolder = Folder
	MapHighlight.Adornee = Folder

	for _, Item in ipairs(Folder:GetChildren()) do
		AddMapItem(Item)
	end

	table.insert(MapConnections, Folder.ChildAdded:Connect(AddMapItem))
	table.insert(MapConnections, Folder.ChildRemoved:Connect(RemoveMapItem))
end

task.spawn(function()
	AttachMapFolder(workspace:WaitForChild("MapItems"))
end)

-- If the game ever replaces the MapItems folder itself
workspace.ChildAdded:Connect(function(Child)
	if Child.Name == "MapItems" then
		AttachMapFolder(Child)
	end
end)

--------------------------------------------------
-- MUTE INTROMUSIC
--------------------------------------------------

local IntroSound = nil
local IntroOriginalVolume = nil
local IntroMutedByUs = false

task.spawn(function()
	while ScreenGui.Parent do

		if not IntroSound or not IntroSound.Parent then
			IntroSound = workspace:FindFirstChild("IntroMusic", true)
			IntroOriginalVolume = nil
			IntroMutedByUs = false
		end

		if IntroSound and IntroSound:IsA("Sound") then

			if CONFIG.MuteIntro then
				if IntroSound.Volume > 0 then
					IntroOriginalVolume = IntroSound.Volume
				end

				IntroSound.Volume = 0
				IntroMutedByUs = true

			elseif IntroMutedByUs then
				IntroSound.Volume = IntroOriginalVolume or 0.5
				IntroMutedByUs = false
			end
		end

		task.wait(0.2)
	end
end)

--------------------------------------------------
-- UPDATE LOOP
--------------------------------------------------

local UpdateTimer = 0
local MapTimer = 0

RunService.RenderStepped:Connect(function(Delta)

	UpdateTimer += Delta
	MapTimer += Delta

	if UpdateTimer < 0.05 then
		return
	end

	UpdateTimer = 0

	local Phase = (os.clock() * 0.25) % 1
	local NoobSequence = BuildSequence(NOOB_PALETTE, Phase)
	local ZombieSequence = BuildSequence(ZOMBIE_PALETTE, Phase)

	local PlayerOutline = math.clamp(CONFIG.PlayerTransparency * 0.5, 0, 1)

	--------------------------------------------------
	-- MAP HIGHLIGHT (does not need my character)
	--------------------------------------------------

	MapHighlight.Enabled = CONFIG.HighlightMap
	MapHighlight.FillTransparency = CONFIG.MapTransparency
	MapHighlight.OutlineTransparency = math.clamp(CONFIG.MapTransparency * 0.5, 0, 1)

	local MyCharacter = LocalPlayer.Character
	local MyRoot = GetRoot(MyCharacter)

	if not MyRoot then
		return
	end

	--------------------------------------------------
	-- PLAYERS
	--------------------------------------------------

	for Player, Data in pairs(PlayerObjects) do

		if not Player.Parent or not Player.Character then
			continue
		end

		local Character = Player.Character
		local Root = GetRoot(Character)

		if not Root then
			continue
		end

		local Kind = GetPlayerKind(Player)

		if not Kind then
			if Data.Highlight then
				Data.Highlight.Enabled = false
			end

			if Data.Billboard then
				Data.Billboard.Enabled = false
			end

			continue
		end

		local Color = GetKindColor(Kind)

		if Data.Highlight then
			if Kind == "Noob" then
				Data.Highlight.Enabled = CONFIG.HighlightNoobs
			else
				Data.Highlight.Enabled = CONFIG.HighlightZombies
			end

			Data.Highlight.FillColor = Color
			Data.Highlight.OutlineColor = Color
			Data.Highlight.FillTransparency = CONFIG.PlayerTransparency
			Data.Highlight.OutlineTransparency = PlayerOutline
			Data.Highlight.Adornee = Character
		end

		if Data.Billboard and Data.NameLabel and Data.InfoLabel then

			Data.Billboard.Enabled = CONFIG.ShowPlayerInfo

			local Distance = math.floor((Root.Position - MyRoot.Position).Magnitude + 0.5)

			Data.NameLabel.Text = string.upper(Player.DisplayName) .. "  |  " .. Distance .. " studs"

			local Lines = {}

			if CONFIG.ShowSurvivals then
				local Value = GetStatText(Player, "Survivals")

				if Value then
					table.insert(Lines, "Survivals: " .. Value)
				end
			end

			if CONFIG.ShowInfections then
				local Value = GetStatText(Player, "Infections")

				if Value then
					table.insert(Lines, "Infections: " .. Value)
				end
			end

			if CONFIG.ShowCash then
				local Value = GetStatText(Player, "Cash")

				if Value then
					table.insert(Lines, "Cash: " .. Value)
				end
			end

			local ToolName = FindPlayerTool(Player)

			if ToolName then
				table.insert(Lines, "Item: " .. ToolName)
			end

			Data.InfoLabel.Text = table.concat(Lines, "\n")

			-- Animated gradient
			local Sequence = (Kind == "Noob") and NoobSequence or ZombieSequence

			for _, Gradient in ipairs(Data.Gradients) do
				Gradient.Color = Sequence
			end
		end
	end

	--------------------------------------------------
	-- MAP ITEM BILLBOARDS (slower tick)
	--------------------------------------------------

	if MapTimer < 0.25 then
		return
	end

	MapTimer = 0

	for Item, Data in pairs(MapObjects) do

		Data.Billboard.Enabled = CONFIG.ShowMapInfo

		if not CONFIG.ShowMapInfo then
			continue
		end

		local Root = GetRoot(Item)

		if Data.Billboard.Adornee ~= Root then
			Data.Billboard.Adornee = Root
		end

		if not Root then
			continue
		end

		local Distance = math.floor((Root.Position - MyRoot.Position).Magnitude + 0.5)

		Data.Text.Text = string.upper(Item.Name) .. "\n" .. Distance .. " studs"
	end
end)
