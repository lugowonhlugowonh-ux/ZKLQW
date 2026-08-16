--[[
  AutoFarm Marshmallow – Versi Simpel & Aman
  - Hanya menghapus bagian bawah bangunan (collision parts & housed.0052) seperti original
  - UI minimalis: tombol Start/Stop, status, keybind, counter kecil
  - Autofarm di bawah tanah (platform)
  - Tema gelap/terang & transparansi (opsional)
]]

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 15)
local tweenService = game:GetService("TweenService")
local userInput = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local httpService = game:GetService("HttpService")

-- ============================================================
-- SETTINGS
-- ============================================================
local settings = { IsLight = false, TransparentMode = false }
local SETTINGS_FILE = "QuickzAutofarm_Settings.json"

local function saveSettings()
    if writefile then
        pcall(function() writefile(SETTINGS_FILE, httpService:JSONEncode(settings)) end)
    end
end
pcall(function()
    if isfile and isfile(SETTINGS_FILE) then
        local data = httpService:JSONDecode(readfile(SETTINGS_FILE))
        if data then
            settings.IsLight = data.IsLight or false
            settings.TransparentMode = data.TransparentMode or false
        end
    end
end)

-- ============================================================
-- THEME COLORS
-- ============================================================
local function getColors()
    local light = settings.IsLight
    return {
        MainBG = light and Color3.fromRGB(240,240,240) or Color3.fromRGB(37,37,38),
        BarBG  = light and Color3.fromRGB(220,220,224) or Color3.fromRGB(50,50,52),
        Text   = light and Color3.fromRGB(30,30,30)   or Color3.fromRGB(240,240,240),
        SubText= light and Color3.fromRGB(100,100,100) or Color3.fromRGB(160,160,160),
        Border = light and Color3.fromRGB(190,190,190) or Color3.fromRGB(65,65,65),
        Accent = light and Color3.fromRGB(205,205,205) or Color3.fromRGB(65,65,65)
    }
end
local colors = getColors()

-- ============================================================
-- BUILDING DELETION (SAMA SEPERTI ORIGINAL)
-- ============================================================
local function deleteBuildingParts()
    local map = workspace:FindFirstChild("Map")
    if not map then return end

    -- Hapus housed.0052 & collision parts di Apartments (seperti original)
    local apartments = map:FindFirstChild("Apartments")
    if apartments then
        for _, aptFolder in ipairs(apartments:GetChildren()) do
            pcall(function()
                local apt = aptFolder:FindFirstChild("Apartment")
                if apt then
                    -- Hapus housed.0052 di Exterior
                    local exterior = apt:FindFirstChild("Exterior")
                    if exterior then
                        local housed = exterior:FindFirstChild("housed.0052")
                        if housed then housed:Destroy() end
                    end
                    -- Hapus semua collision parts di Interior
                    local interior = apt:FindFirstChild("Interior")
                    if interior then
                        for _, child in ipairs(interior:GetChildren()) do
                            child:Destroy()
                        end
                    end
                end
                -- Cek juga Folder/Model di dalam aptFolder
                for _, child in ipairs(aptFolder:GetChildren()) do
                    if child:IsA("Folder") or child:IsA("Model") then
                        local subApt = child:FindFirstChild("Apartment")
                        if subApt then
                            local interior = subApt:FindFirstChild("Interior")
                            if interior then
                                for _, obj in ipairs(interior:GetChildren()) do
                                    obj:Destroy()
                                end
                            end
                        end
                    end
                end
            end)
        end
    end

    -- Expand semua ProximityPrompt (jarak tak terbatas)
    local function expandPromptsIn(obj)
        for _, prompt in ipairs(obj:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                pcall(function()
                    prompt.MaxActivationDistance = 9999
                    prompt.RequiresLineOfSight = false
                end)
            end
        end
    end

    -- WH1
    local houses = map:FindFirstChild("Houses")
    if houses then
        local wh1 = houses:FindFirstChild("WH1")
        if wh1 then
            local interior = wh1:FindFirstChild("Interior")
            if interior then expandPromptsIn(interior) end
        end
    end

    -- Apartments
    if apartments then
        for _, aptFolder in ipairs(apartments:GetChildren()) do
            pcall(function()
                local apt = aptFolder:FindFirstChild("Apartment")
                if apt then
                    local interior = apt:FindFirstChild("Interior")
                    if interior then expandPromptsIn(interior) end
                end
                for _, child in ipairs(aptFolder:GetChildren()) do
                    if child:IsA("Folder") or child:IsA("Model") then
                        local subApt = child:FindFirstChild("Apartment")
                        if subApt then
                            local interior = subApt:FindFirstChild("Interior")
                            if interior then expandPromptsIn(interior) end
                        end
                    end
                end
            end)
        end
    end
end

-- Jalankan penghapusan saat script di-load (sama seperti original)
task.spawn(function()
    task.wait(2)
    pcall(deleteBuildingParts)
    print("[AutoFarm] Building deletion completed.")
end)

-- ============================================================
-- UNDERGROUND PLATFORM
-- ============================================================
local undergroundActive = false
local platformPart = nil
local savedCFrame = nil

local function goUnderground()
    if undergroundActive then return end
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local platform = Instance.new("Part")
    platform.Name = "Quickz_Platform"
    platform.Size = Vector3.new(40, 1, 40)
    platform.Transparency = 1
    platform.Anchored = true
    platform.CanCollide = true
    platform.CFrame = hrp.CFrame - Vector3.new(0, 11, 0)
    platform.Parent = workspace

    platformPart = platform
    savedCFrame = hrp.CFrame

    task.wait(0.1)
    hrp.CFrame = platform.CFrame + Vector3.new(0, 3.5, 0)
    undergroundActive = true
end

local function goSurface()
    if not undergroundActive then return end
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if savedCFrame then
        hrp.CFrame = savedCFrame
    else
        hrp.CFrame = hrp.CFrame + Vector3.new(0, 11, 0)
    end

    if platformPart and platformPart.Parent then
        platformPart:Destroy()
    end
    undergroundActive = false
    savedCFrame = nil
    platformPart = nil
end

-- Reset platform jika karakter mati/respawn
player.CharacterRemoving:Connect(function()
    if platformPart and platformPart.Parent then
        platformPart:Destroy()
    end
    undergroundActive = false
    savedCFrame = nil
    platformPart = nil
end)

-- ============================================================
-- AUTOFARM CORE FUNCTIONS
-- ============================================================
local running = false
local farmTask = nil
local statusLabel = nil
local startBtn = nil

local function setStatus(text)
    if statusLabel then statusLabel.Text = text end
end

-- Cari semua ProximityPrompt di Cooking Pot
local function getAllPrompts()
    local prompts = {}
    local map = workspace:FindFirstChild("Map")
    if not map then return prompts end

    local function scan(obj)
        for _, prompt in ipairs(obj:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and prompt.Parent and prompt.Parent.Name == "Cooking Pot" then
                table.insert(prompts, prompt)
            end
        end
    end

    pcall(function()
        local houses = map:FindFirstChild("Houses")
        if houses then
            local wh1 = houses:FindFirstChild("WH1")
            if wh1 then
                local interior = wh1:FindFirstChild("Interior")
                if interior then scan(interior) end
            end
        end
    end)

    pcall(function()
        local apartments = map:FindFirstChild("Apartments")
        if apartments then
            for _, aptFolder in ipairs(apartments:GetChildren()) do
                local apt = aptFolder:FindFirstChild("Apartment")
                if apt then
                    local interior = apt:FindFirstChild("Interior")
                    if interior then scan(interior) end
                end
                for _, child in ipairs(aptFolder:GetChildren()) do
                    if child:IsA("Folder") or child:IsA("Model") then
                        local subApt = child:FindFirstChild("Apartment")
                        if subApt then
                            local interior = subApt:FindFirstChild("Interior")
                            if interior then scan(interior) end
                        end
                    end
                end
            end
        end
    end)

    return prompts
end

-- Fire semua prompt
local function fireAllPrompts()
    local prompts = getAllPrompts()
    for _, prompt in ipairs(prompts) do
        pcall(function()
            fireproximityprompt(prompt)
        end)
        task.wait(0.05)
    end
end

-- Cek apakah item ada
local function hasItem(itemName)
    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character
    if backpack and backpack:FindFirstChild(itemName) then return true end
    if character and character:FindFirstChild(itemName) then return true end
    return false
end

-- Equip tool
local function equipTool(itemName)
    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character
    local tool = backpack and backpack:FindFirstChild(itemName)
    if not tool then return false end
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    pcall(function()
        humanoid:EquipTool(tool)
    end)
    for _ = 1, 20 do
        if character and character:FindFirstChild(itemName) then return true end
        task.wait(0.05)
    end
    return false
end

-- Jumlah item (untuk counter)
local function countItem(itemName)
    local count = 0
    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character
    if backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            if child.Name == itemName then count = count + 1 end
        end
    end
    if character then
        for _, child in ipairs(character:GetChildren()) do
            if child.Name == itemName then count = count + 1 end
        end
    end
    return count
end

-- Menunggu dengan status
local function waitFor(seconds, label)
    local elapsed = 0
    while running and elapsed < seconds do
        task.wait(0.5)
        elapsed = elapsed + 0.5
        setStatus(string.format("[af] %s — %ds", label, math.ceil(seconds - elapsed)))
    end
end

-- Loop utama autofarm (DI BAWAH PANCI)
local function autofarmLoop()
    while running do
        -- 1. Water
        if hasItem("Water") then
            setStatus("[af] equipping Water...")
            if equipTool("Water") then
                task.wait(0.3)
                setStatus("[af] pressing E — Water")
                fireAllPrompts()
                waitFor(21, "waiting after Water")
                if not running then break end
            end
        end
        if not running then break end

        -- 2. Sugar Block Bag
        if hasItem("Sugar Block Bag") then
            setStatus("[af] equipping Sugar Bag...")
            if equipTool("Sugar Block Bag") then
                task.wait(1)
                if not running then break end
                setStatus("[af] pressing E — Sugar Bag")
                fireAllPrompts()
            end
        end
        if not running then break end

        -- 3. Gelatin
        if hasItem("Gelatin") then
            setStatus("[af] equipping Gelatin...")
            if equipTool("Gelatin") then
                task.wait(1)
                if not running then break end
                setStatus("[af] pressing E — Gelatin")
                fireAllPrompts()
            end
        end
        if not running then break end

        -- 4. Empty Bag (long cycle)
        if hasItem("Empty Bag") then
            setStatus("[af] equipping Empty Bag...")
            if equipTool("Empty Bag") then
                local elapsed = 0
                while running and elapsed < 46 do
                    task.wait(0.5)
                    elapsed = elapsed + 0.5
                    setStatus(string.format("[af] empty bag — firing in %ds", math.max(0, math.ceil(46 - elapsed))))
                end
                if not running then break end
                setStatus("[af] pressing E — Empty Bag (end of cycle)")
                fireAllPrompts()
                task.wait(0.5)
                if not running then break end
                -- jika tidak ada item sama sekali, retry
                if not hasItem("Water") and not hasItem("Sugar Block Bag") and not hasItem("Gelatin") and not hasItem("Empty Bag") then
                    setStatus("[af] no items found — retrying...")
                    task.wait(2)
                end
            end
        end
        task.wait(1)
    end
    setStatus("[autofarm] idle")
end

-- Toggle autofarm
local function toggleAutofarm()
    if running then
        running = false
        if farmTask then task.cancel(farmTask) end
        goSurface()
        if startBtn then startBtn.Text = "Start Autofarm" end
        return
    end

    local qty = tonumber(qtyInput and qtyInput.Text or "100")
    if not qty or qty < 1 then
        setStatus("[error] enter a valid quantity")
        return
    end

    -- Cek kecukupan bahan (Water, Sugar, Gelatin) minimal qty
    if countItem("Water") < qty or countItem("Sugar Block Bag") < qty or countItem("Gelatin") < qty then
        setStatus("[auto] not enough materials (need " .. qty .. " of each)")
        return
    end

    running = true
    if startBtn then startBtn.Text = "Stop Autofarm" end

    -- Pindah ke bawah tanah
    goUnderground()

    -- Jalankan loop
    farmTask = task.spawn(autofarmLoop)
end

-- Panggil delete building sekali lagi saat start (seperti original)
local originalToggle = toggleAutofarm
toggleAutofarm = function()
    if not running then
        pcall(deleteBuildingParts)
    end
    originalToggle()
end

-- ============================================================
-- UI SEDERHANA (tanpa tab, hanya frame utama)
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "QuickzAutofarm"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 200)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -100)
mainFrame.BackgroundColor3 = colors.MainBG
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 4)

local border = Instance.new("UIStroke")
border.Color = colors.Border
border.Thickness = 1
border.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 28)
titleBar.BackgroundColor3 = colors.BarBG
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 4)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -30, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "AutoFarm"
titleLabel.TextColor3 = colors.Text
titleLabel.Font = Enum.Font.RobotoMono
titleLabel.TextSize = 12
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Position = UDim2.new(1, -24, 0.5, -10)
closeBtn.BackgroundColor3 = colors.Accent
closeBtn.Text = "×"
closeBtn.TextColor3 = colors.SubText
closeBtn.Font = Enum.Font.RobotoMono
closeBtn.TextSize = 13
closeBtn.BorderSizePixel = 0
closeBtn.AutoButtonColor = true
closeBtn.ZIndex = 10
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 3)
closeBtn.MouseButton1Click:Connect(function()
    if running then toggleAutofarm() end
    screenGui:Destroy()
end)

-- Drag function
local function makeDraggable(frame, title)
    local dragging, dragStart, startPos
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            startPos = Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    userInput.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
        local viewport = workspace.CurrentCamera.ViewportSize
        local size = frame.AbsoluteSize
        frame.Position = UDim2.new(0, math.clamp(startPos.X + delta.X, 0, viewport.X - size.X),
                                   0, math.clamp(startPos.Y + delta.Y, 0, viewport.Y - size.Y))
    end)
    userInput.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end
makeDraggable(mainFrame, titleBar)

-- Konten
local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -28)
content.Position = UDim2.new(0, 0, 0, 28)
content.BackgroundTransparency = 1
content.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 6)
layout.Parent = content

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 8)
padding.Parent = content

-- Status
statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 16)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.RobotoMono
statusLabel.Text = "[autofarm] idle"
statusLabel.TextColor3 = colors.Text
statusLabel.TextSize = 10
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.LayoutOrder = 0
statusLabel.Parent = content

-- Quantity input
local qtyFrame = Instance.new("Frame")
qtyFrame.Size = UDim2.new(1, 0, 0, 24)
qtyFrame.BackgroundTransparency = 1
qtyFrame.LayoutOrder = 1
qtyFrame.Parent = content

local qtyLabel = Instance.new("TextLabel")
qtyLabel.Size = UDim2.new(0.4, 0, 1, 0)
qtyLabel.BackgroundTransparency = 1
qtyLabel.Text = "Quantity:"
qtyLabel.TextColor3 = colors.Text
qtyLabel.Font = Enum.Font.RobotoMono
qtyLabel.TextSize = 11
qtyLabel.TextXAlignment = Enum.TextXAlignment.Left
qtyLabel.Parent = qtyFrame

local qtyInput = Instance.new("TextBox")
qtyInput.Size = UDim2.new(0.4, 0, 1, 0)
qtyInput.Position = UDim2.new(0.4, 0, 0, 0)
qtyInput.BackgroundColor3 = colors.BarBG
qtyInput.BorderSizePixel = 0
qtyInput.Font = Enum.Font.RobotoMono
qtyInput.Text = "100"
qtyInput.TextColor3 = colors.Text
qtyInput.TextSize = 11
qtyInput.TextXAlignment = Enum.TextXAlignment.Center
qtyInput.ClearTextOnFocus = false
qtyInput.Parent = qtyFrame
Instance.new("UICorner", qtyInput).CornerRadius = UDim.new(0, 3)

-- Start/Stop button
startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(1, 0, 0, 28)
startBtn.BackgroundColor3 = colors.Accent
startBtn.BorderSizePixel = 1
startBtn.BorderColor3 = colors.Border
startBtn.Font = Enum.Font.RobotoMono
startBtn.Text = "Start Autofarm"
startBtn.TextColor3 = colors.Text
startBtn.TextSize = 11
startBtn.LayoutOrder = 2
startBtn.Parent = content
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 3)
startBtn.MouseButton1Click:Connect(toggleAutofarm)

-- Keybind
local keybindFrame = Instance.new("Frame")
keybindFrame.Size = UDim2.new(1, 0, 0, 22)
keybindFrame.BackgroundTransparency = 1
keybindFrame.LayoutOrder = 3
keybindFrame.Parent = content

local keybindLabel = Instance.new("TextLabel")
keybindLabel.Size = UDim2.new(0.6, 0, 1, 0)
keybindLabel.BackgroundTransparency = 1
keybindLabel.Text = "Keybind:"
keybindLabel.TextColor3 = colors.SubText
keybindLabel.Font = Enum.Font.RobotoMono
keybindLabel.TextSize = 10
keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
keybindLabel.Parent = keybindFrame

local keybindBtn = Instance.new("TextButton")
keybindBtn.Size = UDim2.new(0, 38, 0, 18)
keybindBtn.Position = UDim2.new(0.6, 0, 0.5, -9)
keybindBtn.BackgroundColor3 = colors.Accent
keybindBtn.BorderSizePixel = 1
keybindBtn.BorderColor3 = colors.Border
keybindBtn.Font = Enum.Font.RobotoMono
keybindBtn.Text = "[-]"
keybindBtn.TextColor3 = colors.SubText
keybindBtn.TextSize = 9
keybindBtn.Parent = keybindFrame
Instance.new("UICorner", keybindBtn).CornerRadius = UDim.new(0, 3)

local binding = false
local boundKey = nil
keybindBtn.MouseButton1Click:Connect(function()
    if binding then return end
    binding = true
    keybindBtn.Text = "[...]"
    keybindBtn.TextColor3 = colors.Text
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 0, 18)
    overlay.Position = UDim2.new(0, 0, 0, 0)
    overlay.BackgroundColor3 = colors.Accent
    overlay.BackgroundTransparency = 0.3
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 20
    overlay.Parent = screenGui
    local hint = Instance.new("TextLabel")
    hint.Size = UDim2.new(1, 0, 1, 0)
    hint.BackgroundTransparency = 1
    hint.Font = Enum.Font.RobotoMono
    hint.Text = "press a key to bind  •  ESC to clear"
    hint.TextColor3 = colors.Text
    hint.TextSize = 10
    hint.TextXAlignment = Enum.TextXAlignment.Center
    hint.ZIndex = 21
    hint.Parent = overlay
    task.delay(5, function()
        if binding then
            keybindBtn.Text = "[-]"
            keybindBtn.TextColor3 = colors.SubText
            overlay:Destroy()
            binding = false
        end
    end)
end)

userInput.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if binding then
        if input.KeyCode == Enum.KeyCode.Escape then
            boundKey = nil
            keybindBtn.Text = "[-]"
        else
            boundKey = input.KeyCode
            keybindBtn.Text = "[" .. tostring(input.KeyCode):gsub("Enum.KeyCode.", "") .. "]"
        end
        binding = false
        for _, child in ipairs(screenGui:GetChildren()) do
            if child:IsA("Frame") and child.ZIndex == 20 then child:Destroy() end
        end
        return
    end
    if boundKey and input.KeyCode == boundKey then
        toggleAutofarm()
    end
end)

-- Tombol toggle theme & transparansi (opsional, sederhana)
local function createToggleBtn(text, getter, setter)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.48, 0, 0, 22)
    btn.BackgroundColor3 = colors.Accent
    btn.BorderSizePixel = 1
    btn.BorderColor3 = colors.Border
    btn.Font = Enum.Font.RobotoMono
    btn.Text = text .. ": " .. (getter() and "ON" or "OFF")
    btn.TextColor3 = colors.Text
    btn.TextSize = 10
    btn.Parent = content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
    btn.MouseButton1Click:Connect(function()
        setter(not getter())
        btn.Text = text .. ": " .. (getter() and "ON" or "OFF")
        saveSettings()
        -- Update UI colors
        colors = getColors()
        mainFrame.BackgroundColor3 = colors.MainBG
        border.Color = colors.Border
        titleBar.BackgroundColor3 = colors.BarBG
        titleLabel.TextColor3 = colors.Text
        closeBtn.BackgroundColor3 = colors.Accent
        closeBtn.TextColor3 = colors.SubText
        statusLabel.TextColor3 = colors.Text
        qtyLabel.TextColor3 = colors.Text
        qtyInput.BackgroundColor3 = colors.BarBG
        qtyInput.TextColor3 = colors.Text
        startBtn.BackgroundColor3 = colors.Accent
        startBtn.BorderColor3 = colors.Border
        startBtn.TextColor3 = colors.Text
        keybindLabel.TextColor3 = colors.SubText
        keybindBtn.BackgroundColor3 = colors.Accent
        keybindBtn.BorderColor3 = colors.Border
        keybindBtn.TextColor3 = colors.SubText
        for _, btn in ipairs(content:GetChildren()) do
            if btn:IsA("TextButton") and btn ~= startBtn and btn ~= keybindBtn then
                btn.BackgroundColor3 = colors.Accent
                btn.BorderColor3 = colors.Border
                btn.TextColor3 = colors.Text
            end
        end
        mainFrame.BackgroundTransparency = settings.TransparentMode and 0.15 or 0
    end)
    return btn
end

local themeBtn = createToggleBtn("Theme", function() return settings.IsLight end, function(v) settings.IsLight = v end)
themeBtn.LayoutOrder = 4
local transBtn = createToggleBtn("Transparent", function() return settings.TransparentMode end, function(v) settings.TransparentMode = v end)
transBtn.LayoutOrder = 5

-- ============================================================
-- SELESAI
-- ============================================================
print("[AutoFarm] Simple UI loaded. Building deletion (bottom only) applied.")