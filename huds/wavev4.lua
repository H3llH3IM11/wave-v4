-- Wave V4 HUD Preview v3
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

for _, v in ipairs(CoreGui:GetChildren()) do
    if v.Name == "WaveV4HUD_Preview" then v:Destroy() end
end

local THEME = {
    bg = Color3.fromRGB(20, 20, 20),
    border = Color3.fromRGB(42, 42, 42),
    accent = Color3.fromRGB(61, 51, 144),      -- #3d3390, ещё темнее
    text = Color3.fromRGB(240, 238, 235),
    credit = Color3.fromRGB(140, 140, 140),
}

local FONT_MED = Enum.Font.GothamMedium
local FONT_MAIN = Enum.Font.Gotham

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WaveV4HUD_Preview"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = CoreGui

local wm = Instance.new("Frame", screenGui)
wm.Size = UDim2.new(0, 440, 0, 40)
wm.Position = UDim2.new(0, 20, 0, 20)
wm.BackgroundColor3 = THEME.bg
wm.BorderSizePixel = 0
wm.Active = true

local wmStroke = Instance.new("UIStroke", wm)
wmStroke.Color = THEME.border
wmStroke.Thickness = 2
wmStroke.Transparency = 0

local topBar = Instance.new("Frame", wm)
topBar.Size = UDim2.new(1, 0, 0, 3)
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundColor3 = THEME.accent
topBar.BorderSizePixel = 0

local mainLabel = Instance.new("TextLabel", wm)
mainLabel.Size = UDim2.new(1, -20, 1, 0)
mainLabel.Position = UDim2.new(0, 10, 0, 0)
mainLabel.BackgroundTransparency = 1
mainLabel.TextColor3 = THEME.text
mainLabel.Font = FONT_MED
mainLabel.TextSize = 14
mainLabel.TextXAlignment = Enum.TextXAlignment.Left

-- credit в правом нижнем углу
local creditLabel = Instance.new("TextLabel", wm)
creditLabel.Size = UDim2.new(1, -10, 0, 12)
creditLabel.Position = UDim2.new(0, 0, 1, -12)
creditLabel.BackgroundTransparency = 1
creditLabel.TextColor3 = THEME.credit
creditLabel.Font = FONT_MAIN
creditLabel.TextSize = 9
creditLabel.TextTransparency = 0.4
creditLabel.TextXAlignment = Enum.TextXAlignment.Right
creditLabel.Text = "@tsmgr made this lol"

local showUsername = true

local function updateText()
    local base = "Wave [private] alpha - 2.7"
    if showUsername then
        mainLabel.Text = base .. "  |  " .. LocalPlayer.DisplayName
    else
        mainLabel.Text = base
    end
end

updateText()

local dragging, dragInput, dragStart, startPos
wm.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = wm.Position
    end
end)
wm.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        wm.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

task.spawn(function()
    task.wait(3)
    showUsername = false
    updateText()
    task.wait(3)
    showUsername = true
    updateText()
end)
