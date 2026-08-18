-- Script Rapid Fire Only dengan UI
-- Cocok untuk game DodgeBros (South Bronx)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Variabel global
local rapidFireEnabled = false
local fireRateValue = 0.147 -- default

-- ================== BUAT UI SEDERHANA ==================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RapidFireUI"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Frame utama (draggable)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 120)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -60)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Biar bisa di-drag
local function makeDraggable(frame)
    local dragging = false
    local dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(mainFrame)

-- Corner
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Judul
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "⚡ Rapid Fire"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Toggle Rapid Fire
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.8, 0, 0, 30)
toggleButton.Position = UDim2.new(0.1, 0, 0.35, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleButton.Text = "OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.Gotham
toggleButton.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = toggleButton

toggleButton.MouseButton1Click:Connect(function()
    rapidFireEnabled = not rapidFireEnabled
    toggleButton.Text = rapidFireEnabled and "ON" or "OFF"
    toggleButton.BackgroundColor3 = rapidFireEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 60, 60)
    applyRapidFireToAllTools() -- terapkan ke semua tool saat toggle
end)

-- Slider Fire Rate
local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(0.4, 0, 0, 20)
sliderLabel.Position = UDim2.new(0.05, 0, 0.7, 0)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "Rate: 0.147"
sliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
sliderLabel.TextScaled = true
sliderLabel.Font = Enum.Font.Gotham
sliderLabel.Parent = mainFrame

local slider = Instance.new("Frame")
slider.Size = UDim2.new(0.5, 0, 0, 6)
slider.Position = UDim2.new(0.45, 0, 0.73, 0)
slider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
slider.Parent = mainFrame

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.5, 0, 1, 0) -- nilai awal 50%
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
sliderFill.Parent = slider

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0, 3)
sliderCorner.Parent = sliderFill

-- Fungsi update slider
local function updateSlider(value)
    local minVal = 0.03
    local maxVal = 0.147
    fireRateValue = minVal + (maxVal - minVal) * value
    fireRateValue = math.round(fireRateValue * 1000) / 1000
    sliderFill.Size = UDim2.new(value, 0, 1, 0)
    sliderLabel.Text = "Rate: " .. string.format("%.3f", fireRateValue)
    if rapidFireEnabled then
        applyRapidFireToAllTools()
    end
end

-- Biar slider bisa di-drag
local draggingSlider = false
slider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = true
    end
end)
slider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
        local relX = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        updateSlider(relX)
    end
end)

-- Inisialisasi slider ke nilai tengah
updateSlider(0.5)

-- ================== FUNGSI RAPID FIRE ==================
local function applyRapidFireToTool(tool)
    if not tool:IsA("Tool") then return end
    local settingModule = tool:FindFirstChild("Setting")
    if settingModule and settingModule:IsA("ModuleScript") then
        local success, settings = pcall(require, settingModule)
        if success and type(settings) == "table" then
            if rapidFireEnabled then
                settings.FireRate = fireRateValue
                settings.Auto = true
            else
                -- Kembalikan ke default (bisa disesuaikan)
                settings.FireRate = 0.147
                settings.Auto = false
            end
        end
    end
end

local function applyRapidFireToAllTools()
    -- Terapkan ke semua tool di karakter
    local character = LocalPlayer.Character
    if character then
        for _, child in ipairs(character:GetChildren()) do
            applyRapidFireToTool(child)
        end
    end
    -- Terapkan ke semua tool di backpack
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            applyRapidFireToTool(child)
        end
    end
end

-- Event saat tool ditambahkan ke karakter atau backpack
local function onChildAdded(parent, child)
    if child:IsA("Tool") then
        applyRapidFireToTool(child)
    end
end

LocalPlayer.CharacterAdded:Connect(function(character)
    character.ChildAdded:Connect(function(child)
        onChildAdded(character, child)
    end)
    -- Terapkan ulang saat respawn
    task.wait(0.5)
    applyRapidFireToAllTools()
end)

local backpack = LocalPlayer:FindFirstChild("Backpack")
if backpack then
    backpack.ChildAdded:Connect(function(child)
        onChildAdded(backpack, child)
    end)
end

-- Terapkan saat pertama kali dijalankan
task.wait(1)
applyRapidFireToAllTools()

print("✅ Rapid Fire Only UI loaded! (Toggle ON/OFF, geser slider untuk atur kecepatan)")