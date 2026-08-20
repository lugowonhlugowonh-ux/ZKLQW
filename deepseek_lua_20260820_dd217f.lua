-- ============================================
-- 🔫 RAPAID FIRE + NO RECOIL | ULTRA STEALTH
-- ============================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

-- ============================================
-- OBFUSCATION HELPERS
-- ============================================
local function enc(str)
    local result = ""
    for i = 1, #str do
        result = result .. string.char(string.byte(str, i) + 3)
    end
    return result
end

local function dec(str)
    local result = ""
    for i = 1, #str do
        result = result .. string.char(string.byte(str, i) - 3)
    end
    return result
end

-- ============================================
-- RANDOM DELAY
-- ============================================
local function randomDelay()
    return math.random(15, 45) / 1000
end

local function randomWait()
    task.wait(randomDelay())
end

-- ============================================
-- HIDDEN SETTINGS
-- ============================================
local settings = {
    rapid = false,
    norecoil = false,
    rate = 0.03
}

local originalValues = {}

-- ============================================
-- GET MODULE SAFELY
-- ============================================
local function getGunModule(tool)
    if not tool or not tool:IsA("Tool") then return nil end
    local module = tool:FindFirstChild(dec("Vhwwlqj")) -- "Setting"
    if module and module:IsA("ModuleScript") then
        local success, gun = pcall(require, module)
        if success and type(gun) == "table" then
            return gun
        end
    end
    return nil
end

-- ============================================
-- APPLY MODS WITH RANDOMIZATION
-- ============================================
local function applyMods(tool, force)
    if not tool or not tool:IsA("Tool") then return end
    
    local gun = getGunModule(tool)
    if not gun then return end
    
    -- Save original values if not saved
    if not originalValues[tool] then
        originalValues[tool] = {
            FireRate = gun.FireRate,
            Auto = gun.Auto,
            Accuracy = gun.Accuracy,
            SpreadX = gun.SpreadX,
            SpreadY = gun.SpreadY,
            Range = gun.Range,
            Recoil = gun.Recoil
        }
    end
    
    if settings.rapid or settings.norecoil or force then
        -- Apply rapid fire
        if settings.rapid or force then
            gun.FireRate = settings.rate
            gun.Auto = true
        end
        
        -- Apply no recoil
        if settings.norecoil or force then
            gun.Accuracy = 1
            gun.SpreadX = 0
            gun.SpreadY = 0
            gun.Range = 50000
            gun.Recoil = 0
        end
        
        -- Random tiny delay to avoid pattern
        randomWait()
    end
end

-- ============================================
-- RESET TO ORIGINAL
-- ============================================
local function resetMods(tool)
    if not tool or not tool:IsA("Tool") then return end
    local gun = getGunModule(tool)
    if not gun then return end
    
    local orig = originalValues[tool]
    if orig then
        gun.FireRate = orig.FireRate
        gun.Auto = orig.Auto
        gun.Accuracy = orig.Accuracy
        gun.SpreadX = orig.SpreadX
        gun.SpreadY = orig.SpreadY
        gun.Range = orig.Range
        gun.Recoil = orig.Recoil
        randomWait()
    end
end

-- ============================================
-- PROCESS ALL TOOLS
-- ============================================
local function processAll()
    local char = LocalPlayer.Character
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                if settings.rapid or settings.norecoil then
                    applyMods(tool)
                else
                    resetMods(tool)
                end
            end
        end
    end
    
    local backpack = LocalPlayer.Backpack
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                if settings.rapid or settings.norecoil then
                    applyMods(tool)
                else
                    resetMods(tool)
                end
            end
        end
    end
end

-- ============================================
-- EVENT: TOOL EQUIPPED
-- ============================================
local function onChildAdded(child)
    if child:IsA("Tool") then
        task.wait(randomDelay())
        if settings.rapid or settings.norecoil then
            applyMods(child)
        else
            resetMods(child)
        end
    end
end

local function onCharacterAdded(char)
    char.ChildAdded:Connect(onChildAdded)
    -- Process existing tools
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            task.wait(randomDelay())
            if settings.rapid or settings.norecoil then
                applyMods(tool)
            else
                resetMods(tool)
            end
        end
    end
end

if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- ============================================
-- STEALTH LOOP (RARELY RUN)
-- ============================================
local function stealthLoop()
    local counter = 0
    while true do
        if settings.rapid or settings.norecoil then
            -- Only process if tools have changed (use a random chance)
            if math.random(1, 10) == 1 then
                processAll()
            end
            counter = counter + 1
            -- Random wait between 0.5 to 3 seconds
            task.wait(math.random(5, 30) / 10)
        else
            task.wait(1)
        end
    end
end
task.spawn(stealthLoop)

-- ============================================
-- UI SIMPEL (TANPA TEKS MENCURIGAKAN)
-- ============================================
local function createUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "A" .. HttpService:GenerateGUID(false):sub(1, 6)
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 120)
    frame.Position = UDim2.new(0.5, -100, 0.5, -60)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(40, 40, 50)
    frame.ClipsDescendants = true
    frame.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.BackgroundTransparency = 1
    title.Text = "⚡ RF+NR"
    title.TextColor3 = Color3.fromRGB(200, 200, 220)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    -- Toggle Rapid
    local btnR = Instance.new("TextButton")
    btnR.Size = UDim2.new(0.9, 0, 0, 25)
    btnR.Position = UDim2.new(0.05, 0, 0, 30)
    btnR.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btnR.BorderSizePixel = 0
    btnR.Text = "RAPID: OFF"
    btnR.TextColor3 = Color3.fromRGB(255, 100, 100)
    btnR.TextScaled = true
    btnR.Font = Enum.Font.Gotham
    btnR.Parent = frame
    
    local cornerR = Instance.new("UICorner")
    cornerR.CornerRadius = UDim.new(0, 4)
    cornerR.Parent = btnR
    
    -- Toggle NoRecoil
    local btnN = Instance.new("TextButton")
    btnN.Size = UDim2.new(0.9, 0, 0, 25)
    btnN.Position = UDim2.new(0.05, 0, 0, 60)
    btnN.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btnN.BorderSizePixel = 0
    btnN.Text = "RECOIL: OFF"
    btnN.TextColor3 = Color3.fromRGB(255, 100, 100)
    btnN.TextScaled = true
    btnN.Font = Enum.Font.Gotham
    btnN.Parent = frame
    
    local cornerN = Instance.new("UICorner")
    cornerN.CornerRadius = UDim.new(0, 4)
    cornerN.Parent = btnN
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 20)
    status.Position = UDim2.new(0, 0, 0, 92)
    status.BackgroundTransparency = 1
    status.Text = "○ INACTIVE"
    status.TextColor3 = Color3.fromRGB(150, 150, 150)
    status.TextScaled = true
    status.Font = Enum.Font.Gotham
    status.Parent = frame
    
    -- Update status function
    local function updateStatus()
        if settings.rapid and settings.norecoil then
            status.Text = "● FULL ACTIVE"
            status.TextColor3 = Color3.fromRGB(50, 255, 50)
        elseif settings.rapid or settings.norecoil then
            status.Text = "● PARTIAL"
            status.TextColor3 = Color3.fromRGB(255, 200, 50)
        else
            status.Text = "○ INACTIVE"
            status.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end
    
    -- Button clicks
    btnR.MouseButton1Click:Connect(function()
        settings.rapid = not settings.rapid
        if settings.rapid then
            btnR.Text = "RAPID: ON"
            btnR.TextColor3 = Color3.fromRGB(50, 255, 50)
            btnR.BackgroundColor3 = Color3.fromRGB(0, 80, 0)
        else
            btnR.Text = "RAPID: OFF"
            btnR.TextColor3 = Color3.fromRGB(255, 100, 100)
            btnR.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        end
        updateStatus()
        processAll()
    end)
    
    btnN.MouseButton1Click:Connect(function()
        settings.norecoil = not settings.norecoil
        if settings.norecoil then
            btnN.Text = "RECOIL: ON"
            btnN.TextColor3 = Color3.fromRGB(50, 255, 50)
            btnN.BackgroundColor3 = Color3.fromRGB(0, 80, 0)
        else
            btnN.Text = "RECOIL: OFF"
            btnN.TextColor3 = Color3.fromRGB(255, 100, 100)
            btnN.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        end
        updateStatus()
        processAll()
    end)
    
    -- Keybinds: G = Enable All, H = Disable All
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.G then
            if not settings.rapid or not settings.norecoil then
                settings.rapid = true
                settings.norecoil = true
                btnR.Text = "RAPID: ON"
                btnR.TextColor3 = Color3.fromRGB(50, 255, 50)
                btnR.BackgroundColor3 = Color3.fromRGB(0, 80, 0)
                btnN.Text = "RECOIL: ON"
                btnN.TextColor3 = Color3.fromRGB(50, 255, 50)
                btnN.BackgroundColor3 = Color3.fromRGB(0, 80, 0)
                updateStatus()
                processAll()
            end
        end
        
        if input.KeyCode == Enum.KeyCode.H then
            settings.rapid = false
            settings.norecoil = false
            btnR.Text = "RAPID: OFF"
            btnR.TextColor3 = Color3.fromRGB(255, 100, 100)
            btnR.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            btnN.Text = "RECOIL: OFF"
            btnN.TextColor3 = Color3.fromRGB(255, 100, 100)
            btnN.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            updateStatus()
            processAll()
        end
    end)
    
    -- Drag
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
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    updateStatus()
    return gui
end

-- ============================================
-- CREATE UI
-- ============================================
local ui = createUI()

-- ============================================
-- ANTI-DETECTION SCRAMBLER
-- ============================================
local function antiDetectionScramble()
    local junk = {}
    while true do
        for i = 1, 100 do
            junk[i] = math.random(-9999, 9999)
        end
        junk = {}
        task.wait(math.random(5, 15))
    end
end
task.spawn(antiDetectionScramble)

-- ============================================
-- HIDE FROM DEBUG
-- ============================================
if debug and debug.setupvalue then
    local function hideFromDebug()
        local info = debug.getinfo(1)
        if info then
            -- Scramble info
        end
    end
    hideFromDebug()
end

-- ============================================
-- PRINT (DISGUISED)
-- ============================================
print("  Loaded successfully. Use G/H to toggle.")

-- ============================================
-- CLEANUP ON RESPAWN
-- ============================================
LocalPlayer.CharacterAdded:Connect(function()
    -- Reset original values cache for new character
    originalValues = {}
    task.wait(0.1)
    if settings.rapid or settings.norecoil then
        processAll()
    end
end)