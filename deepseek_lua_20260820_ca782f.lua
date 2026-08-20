-- ============================================
-- SILENT AIM UI TOGGLE
-- Menggunakan Config.Silent dari file utama
-- ============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- ============================================
-- CEK APAKAH CONFIG SUDAH ADA
-- ============================================
if not Config or not Config.Silent then
    StarterGui:SetCore("SendNotification", {
        Title = "Error",
        Text = "Config.Silent tidak ditemukan! Jalankan script utama terlebih dahulu.",
        Duration = 5
    })
    return
end

-- ============================================
-- CREATE UI
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SilentAimToggle"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 90)
MainFrame.Position = UDim2.new(0.5, -100, 0.82, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.ClipsDescendants = true

-- Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Image = "rbxassetid://112971167999062"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(112, 112, 147, 147)
Shadow.SliceScale = 0.75
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.BackgroundTransparency = 1
Shadow.ZIndex = 0
Shadow.Parent = MainFrame

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(23, 23, 29)
Stroke.Thickness = 1
Stroke.Parent = MainFrame

-- Title
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 28)
TitleLabel.Position = UDim2.new(0, 0, 0, 4)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "SILENT AIM"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = MainFrame

-- Status Label (ON/OFF)
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0, 30)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "STATUS: OFF"
StatusLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
StatusLabel.TextSize = 13
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.Parent = MainFrame

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.7, 0, 0, 30)
ToggleButton.Position = UDim2.new(0.15, 0, 0.6, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(58, 58, 62)
ToggleButton.Text = "ENABLE"
ToggleButton.TextColor3 = Color3.fromRGB(200, 200, 200)
ToggleButton.TextSize = 14
ToggleButton.Font = Enum.Font.GothamSemibold
ToggleButton.BorderSizePixel = 0
ToggleButton.AutoButtonColor = false
ToggleButton.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = ToggleButton

-- Button hover effect
ToggleButton.MouseEnter:Connect(function()
    if not SilentAim.Enabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 78)
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    end
end)

ToggleButton.MouseLeave:Connect(function()
    if not SilentAim.Enabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(58, 58, 62)
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- ============================================
-- DRAG FUNCTIONALITY
-- ============================================
local dragging = false
local dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + (input.Position.X - dragStart.X),
            startPos.Y.Scale,
            startPos.Y.Offset + (input.Position.Y - dragStart.Y)
        )
    end
end)

-- ============================================
-- TOGGLE FUNCTION (Menggunakan Config.Silent)
-- ============================================
local function UpdateUI()
    if Config.Silent.Enabled then
        StatusLabel.Text = "STATUS: ON"
        StatusLabel.TextColor3 = Color3.fromRGB(70, 255, 70)
        ToggleButton.Text = "DISABLE"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        StarterGui:SetCore("SendNotification", {
            Title = "Silent Aim",
            Text = "Silent Aim ENABLED",
            Duration = 2
        })
    else
        StatusLabel.Text = "STATUS: OFF"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
        ToggleButton.Text = "ENABLE"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(58, 58, 62)
        ToggleButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        
        StarterGui:SetCore("SendNotification", {
            Title = "Silent Aim",
            Text = "Silent Aim DISABLED",
            Duration = 2
        })
    end
end

local function ToggleSilentAim()
    -- Menggunakan Config.Silent dari file utama
    Config.Silent.Enabled = not Config.Silent.Enabled
    
    -- Jika enabled, aktifkan targeting
    if Config.Silent.Enabled then
        Config.Silent.Targetting = true
    else
        Config.Silent.Targetting = false
        -- Reset target
        SilentTarget = nil
    end
    
    UpdateUI()
end

-- ============================================
-- BUTTON EVENT
-- ============================================
ToggleButton.MouseButton1Click:Connect(ToggleSilentAim)

-- ============================================
-- KEYBIND: INSERT
-- ============================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        ToggleSilentAim()
    end
end)

-- ============================================
-- UPDATE UI SAAT SCRIPT DIMUAT
-- ============================================
UpdateUI()

print("Silent Aim UI Loaded!")
print("Press INSERT to toggle Silent Aim")
print("Current Status:", Config.Silent.Enabled and "ON" or "OFF")