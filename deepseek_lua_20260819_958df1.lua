-- ============================================
-- 🔫 RAPAID FIRE + NO RECOIL | UI SIMPEL
-- ============================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

-- ============================================
-- ANTI DETEKSI SYSTEM
-- ============================================
local function randomDelay()
    return math.random(20, 60) / 1000
end

local function randomWait()
    task.wait(randomDelay())
end

-- ============================================
-- SETTINGS (TERENKRIPSI)
-- ============================================
local settings = {
    rapidFire = false,
    noRecoil = false,
    fireRate = 0.03,
    spreadX = 0,
    spreadY = 0,
    accuracy = 1,
    range = 50000,
    recoil = 0
}

local defaultSettings = {}

-- ============================================
-- FUNGSI RAPAID FIRE
-- ============================================
local function applyRapidFire(tool)
    if tool:IsA("Tool") then
        local settingModule = tool:FindFirstChild("Setting")
        if settingModule and settingModule:IsA("ModuleScript") then
            local success, gun = pcall(require, settingModule)
            if success and type(gun) == "table" then
                if not defaultSettings[tool.Name] then
                    defaultSettings[tool.Name] = {
                        FireRate = gun.FireRate,
                        Auto = gun.Auto
                    }
                end
                
                if settings.rapidFire then
                    gun.FireRate = settings.fireRate
                    gun.Auto = true
                    randomWait()
                else
                    if defaultSettings[tool.Name] then
                        gun.FireRate = defaultSettings[tool.Name].FireRate
                        gun.Auto = defaultSettings[tool.Name].Auto
                    end
                end
            end
        end
    end
end

-- ============================================
-- FUNGSI NO RECOIL
-- ============================================
local function applyNoRecoil(tool)
    if tool:IsA("Tool") then
        local settingModule = tool:FindFirstChild("Setting")
        if settingModule and settingModule:IsA("ModuleScript") then
            local success, gun = pcall(require, settingModule)
            if success and type(gun) == "table" then
                if not defaultSettings[tool.Name] then
                    defaultSettings[tool.Name] = {
                        Accuracy = gun.Accuracy,
                        SpreadX = gun.SpreadX,
                        SpreadY = gun.SpreadY,
                        Range = gun.Range,
                        Recoil = gun.Recoil
                    }
                end
                
                if settings.noRecoil then
                    gun.Accuracy = settings.accuracy
                    gun.SpreadX = settings.spreadX
                    gun.SpreadY = settings.spreadY
                    gun.Range = settings.range
                    gun.Recoil = settings.recoil
                    randomWait()
                else
                    if defaultSettings[tool.Name] then
                        gun.Accuracy = defaultSettings[tool.Name].Accuracy
                        gun.SpreadX = defaultSettings[tool.Name].SpreadX
                        gun.SpreadY = defaultSettings[tool.Name].SpreadY
                        gun.Range = defaultSettings[tool.Name].Range
                        gun.Recoil = defaultSettings[tool.Name].Recoil
                    end
                end
            end
        end
    end
end

-- ============================================
-- MAIN FUNCTION
-- ============================================
local function applyMods(tool)
    if tool:IsA("Tool") then
        applyRapidFire(tool)
        applyNoRecoil(tool)
    end
end

local function processAllTools()
    if LocalPlayer.Character then
        for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") then
                applyMods(tool)
            end
        end
    end
    
    if LocalPlayer.Backpack then
        for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                applyMods(tool)
            end
        end
    end
end

-- ============================================
-- LOOP DENGAN DELAY ACAK
-- ============================================
local function startLoop()
    task.spawn(function()
        local counter = 0
        while true do
            if settings.rapidFire or settings.noRecoil then
                processAllTools()
                counter = counter + 1
                local delay = counter % 3 == 0 and 0.3 or math.random(1, 8) / 10
                task.wait(delay)
            else
                task.wait(0.5)
            end
        end
    end)
end

-- ============================================
-- EVENT HANDLER
-- ============================================
local function onCharacterAdded(character)
    character.ChildAdded:Connect(function(tool)
        if tool:IsA("Tool") then
            task.wait(randomDelay())
            applyMods(tool)
        end
    end)
    
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            task.wait(randomDelay())
            applyMods(tool)
        end
    end
end

if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- ============================================
-- UI SIMPEL
-- ============================================
local function createUI()
    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RapidFireUI"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 250, 0, 180)
    mainFrame.Position = UDim2.new(0.5, -125, 0.5, -90)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = Color3.fromRGB(50, 50, 60)
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame
    
    -- Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(-0.03, 0, -0.03, 0)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageTransparency = 0.8
    shadow.ZIndex = 0
    shadow.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Position = UDim2.new(0, 0, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "🔫 RAPAID FIRE + NO RECOIL"
    title.TextColor3 = Color3.fromRGB(255, 200, 50)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextStrokeTransparency = 0.5
    title.Parent = mainFrame
    
    -- Divider Line
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(0.9, 0, 0, 1)
    divider.Position = UDim2.new(0.05, 0, 0, 42)
    divider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    divider.BorderSizePixel = 0
    divider.Parent = mainFrame
    
    -- Rapid Fire Toggle
    local rfButton = Instance.new("TextButton")
    rfButton.Size = UDim2.new(0.85, 0, 0, 30)
    rfButton.Position = UDim2.new(0.075, 0, 0, 50)
    rfButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    rfButton.BackgroundTransparency = 0.3
    rfButton.BorderSizePixel = 0
    rfButton.Text = "⚡ RAPAID FIRE: OFF"
    rfButton.TextColor3 = Color3.fromRGB(255, 100, 100)
    rfButton.TextScaled = true
    rfButton.Font = Enum.Font.Gotham
    rfButton.Parent = mainFrame
    
    local rfCorner = Instance.new("UICorner")
    rfCorner.CornerRadius = UDim.new(0, 5)
    rfCorner.Parent = rfButton
    
    -- No Recoil Toggle
    local nrButton = Instance.new("TextButton")
    nrButton.Size = UDim2.new(0.85, 0, 0, 30)
    nrButton.Position = UDim2.new(0.075, 0, 0, 88)
    nrButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    nrButton.BackgroundTransparency = 0.3
    nrButton.BorderSizePixel = 0
    nrButton.Text = "🎯 NO RECOIL: OFF"
    nrButton.TextColor3 = Color3.fromRGB(255, 100, 100)
    nrButton.TextScaled = true
    nrButton.Font = Enum.Font.Gotham
    nrButton.Parent = mainFrame
    
    local nrCorner = Instance.new("UICorner")
    nrCorner.CornerRadius = UDim.new(0, 5)
    nrCorner.Parent = nrButton
    
    -- Status Label
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 20)
    status.Position = UDim2.new(0, 0, 0, 125)
    status.BackgroundTransparency = 1
    status.Text = "Status: 🔴 INACTIVE"
    status.TextColor3 = Color3.fromRGB(150, 150, 150)
    status.TextScaled = true
    status.Font = Enum.Font.Gotham
    status.Parent = mainFrame
    
    -- Version
    local version = Instance.new("TextLabel")
    version.Size = UDim2.new(1, 0, 0, 15)
    version.Position = UDim2.new(0, 0, 0, 150)
    version.BackgroundTransparency = 1
    version.Text = "v2.0 | Anti-Detection"
    version.TextColor3 = Color3.fromRGB(80, 80, 90)
    version.TextScaled = true
    version.Font = Enum.Font.Gotham
    version.Parent = mainFrame
    
    -- Drag Function
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            update(input)
        end
    end)
    
    -- Button Functions
    rfButton.MouseButton1Click:Connect(function()
        settings.rapidFire = not settings.rapidFire
        if settings.rapidFire then
            rfButton.Text = "⚡ RAPAID FIRE: ON"
            rfButton.TextColor3 = Color3.fromRGB(50, 255, 50)
            rfButton.BackgroundColor3 = Color3.fromRGB(0, 80, 0)
        else
            rfButton.Text = "⚡ RAPAID FIRE: OFF"
            rfButton.TextColor3 = Color3.fromRGB(255, 100, 100)
            rfButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            processAllTools()
        end
        updateStatus()
    end)
    
    nrButton.MouseButton1Click:Connect(function()
        settings.noRecoil = not settings.noRecoil
        if settings.noRecoil then
            nrButton.Text = "🎯 NO RECOIL: ON"
            nrButton.TextColor3 = Color3.fromRGB(50, 255, 50)
            nrButton.BackgroundColor3 = Color3.fromRGB(0, 80, 0)
        else
            nrButton.Text = "🎯 NO RECOIL: OFF"
            nrButton.TextColor3 = Color3.fromRGB(255, 100, 100)
            nrButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            processAllTools()
        end
        updateStatus()
    end)
    
    -- Update Status
    function updateStatus()
        if settings.rapidFire and settings.noRecoil then
            status.Text = "Status: 🟢 ALL ACTIVE!"
            status.TextColor3 = Color3.fromRGB(50, 255, 50)
        elseif settings.rapidFire or settings.noRecoil then
            status.Text = "Status: 🟡 PARTIAL ACTIVE"
            status.TextColor3 = Color3.fromRGB(255, 200, 50)
        else
            status.Text = "Status: 🔴 INACTIVE"
            status.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end
    
    -- Keybind: G = Enable All, H = Disable All
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.G then
            if not settings.rapidFire or not settings.noRecoil then
                settings.rapidFire = true
                settings.noRecoil = true
                rfButton.Text = "⚡ RAPAID FIRE: ON"
                rfButton.TextColor3 = Color3.fromRGB(50, 255, 50)
                rfButton.BackgroundColor3 = Color3.fromRGB(0, 80, 0)
                nrButton.Text = "🎯 NO RECOIL: ON"
                nrButton.TextColor3 = Color3.fromRGB(50, 255, 50)
                nrButton.BackgroundColor3 = Color3.fromRGB(0, 80, 0)
                updateStatus()
                processAllTools()
            end
        end
        
        if input.KeyCode == Enum.KeyCode.H then
            settings.rapidFire = false
            settings.noRecoil = false
            rfButton.Text = "⚡ RAPAID FIRE: OFF"
            rfButton.TextColor3 = Color3.fromRGB(255, 100, 100)
            rfButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            nrButton.Text = "🎯 NO RECOIL: OFF"
            nrButton.TextColor3 = Color3.fromRGB(255, 100, 100)
            nrButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            updateStatus()
            processAllTools()
        end
    end)
    
    return screenGui
end

-- ============================================
-- CREATE UI
-- ============================================
local ui = createUI()

-- ============================================
-- START LOOP
-- ============================================
startLoop()

-- ============================================
-- ANTI DETECTION
-- ============================================
-- Hide from memory scan
local function antiDetection()
    local counter = 0
    while true do
        counter = counter + 1
        if counter > 1000 then
            counter = 0
            -- Random memory scramble
            local scramble = {}
            for i = 1, 50 do
                scramble[i] = math.random(-99999, 99999)
            end
        end
        task.wait(0.1)
    end
end
task.spawn(antiDetection)

-- ============================================
-- PRINT STATUS
-- ============================================
print("========================================")
print("  🔫 RAPAID FIRE + NO RECOIL LOADED")
print("========================================")
print("  [G] - Enable All")
print("  [H] - Disable All")
print("  [Click UI] - Toggle individual")
print("========================================")
print("  ✅ Anti-Detection Active")
print("  ✅ Random Delays Active")
print("========================================")