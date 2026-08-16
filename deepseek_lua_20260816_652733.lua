-- Script AutoFarm Marshmallow - Versi Simpel & Efektif
-- Fitur: Autofarm otomatis, interaksi jarak jauh, penghapusan bagian bangunan yang tidak perlu

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 15)
local runService = game:GetService("RunService")
local userInput = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

-- ============================================================
-- KONFIGURASI
-- ============================================================
local CONFIG = {
    AutoFarm = false,
    Quantity = 100,
}

-- ============================================================
-- FUNGSI DELETE BANGUNAN (HANYA BAGIAN BAWAH/COLLISION)
-- ============================================================
local function deleteBuildingParts()
    local map = workspace:FindFirstChild("Map")
    if not map then return end

    -- 1. Hapus housed.0052 di Exterior (hanya itu, bukan semua)
    local apartments = map:FindFirstChild("Apartments")
    if apartments then
        for _, aptFolder in ipairs(apartments:GetChildren()) do
            pcall(function()
                local apt = aptFolder:FindFirstChild("Apartment")
                if apt then
                    local exterior = apt:FindFirstChild("Exterior")
                    if exterior then
                        local housed = exterior:FindFirstChild("housed.0052")
                        if housed then housed:Destroy() end
                    end
                end
                -- Cek juga di Folder/Model
                for _, child in ipairs(aptFolder:GetChildren()) do
                    if child:IsA("Folder") or child:IsA("Model") then
                        local subApt = child:FindFirstChild("Apartment")
                        if subApt then
                            local exterior = subApt:FindFirstChild("Exterior")
                            if exterior then
                                local housed = exterior:FindFirstChild("housed.0052")
                                if housed then housed:Destroy() end
                            end
                        end
                    end
                end
            end)
        end
    end

    -- 2. Hapus collision parts di Interior (hanya parts, bukan semua child)
    if apartments then
        for _, aptFolder in ipairs(apartments:GetChildren()) do
            pcall(function()
                local apt = aptFolder:FindFirstChild("Apartment")
                if apt then
                    local interior = apt:FindFirstChild("Interior")
                    if interior then
                        for _, child in ipairs(interior:GetChildren()) do
                            if child:IsA("BasePart") and child.Name ~= "Cooking Pot" then
                                child:Destroy()
                            end
                        end
                    end
                end
                for _, child in ipairs(aptFolder:GetChildren()) do
                    if child:IsA("Folder") or child:IsA("Model") then
                        local subApt = child:FindFirstChild("Apartment")
                        if subApt then
                            local interior = subApt:FindFirstChild("Interior")
                            if interior then
                                for _, part in ipairs(interior:GetChildren()) do
                                    if part:IsA("BasePart") and part.Name ~= "Cooking Pot" then
                                        part:Destroy()
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end

    -- 3. Expand semua ProximityPrompt (jarak tak terbatas & hold duration 0)
    local function expandPrompts(obj)
        for _, prompt in ipairs(obj:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                pcall(function()
                    prompt.MaxActivationDistance = 9999
                    prompt.RequiresLineOfSight = false
                    prompt.HoldDuration = 0
                    prompt.ActivationDistance = 9999
                end)
            end
        end
    end

    -- Cari semua Cooking Pot dan expand prompt di dalamnya
    local function scanForPots(obj)
        for _, child in ipairs(obj:GetChildren()) do
            if child.Name == "Cooking Pot" then
                expandPrompts(child)
            elseif child:IsA("Model") or child:IsA("Folder") then
                scanForPots(child)
            end
        end
    end

    -- Scan WH1
    local houses = map:FindFirstChild("Houses")
    if houses then
        local wh1 = houses:FindFirstChild("WH1")
        if wh1 then
            local interior = wh1:FindFirstChild("Interior")
            if interior then scanForPots(interior) end
        end
    end

    -- Scan Apartments
    if apartments then
        for _, aptFolder in ipairs(apartments:GetChildren()) do
            pcall(function()
                local apt = aptFolder:FindFirstChild("Apartment")
                if apt then
                    local interior = apt:FindFirstChild("Interior")
                    if interior then scanForPots(interior) end
                end
                for _, child in ipairs(aptFolder:GetChildren()) do
                    if child:IsA("Folder") or child:IsA("Model") then
                        local subApt = child:FindFirstChild("Apartment")
                        if subApt then
                            local interior = subApt:FindFirstChild("Interior")
                            if interior then scanForPots(interior) end
                        end
                    end
                end
            end)
        end
    end
end

-- Jalankan sekali saat load
task.spawn(function()
    task.wait(2)
    pcall(deleteBuildingParts)
    print("[AutoFarm] Building optimization done.")
end)

-- ============================================================
-- FUNGSI AUTOFARM
-- ============================================================
local running = false
local farmTask = nil
local statusText = "Idle"

local function setStatus(text)
    statusText = text
    if statusLabel then statusLabel.Text = text end
end

-- Cari semua ProximityPrompt (sudah di-expand)
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

-- Cek item
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

-- Jumlah item
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

-- Platform bawah tanah (opsional, bisa dinonaktifkan)
local platformPart = nil
local savedCFrame = nil
local underground = false

local function goUnderground()
    if underground then return end
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
    underground = true
end

local function goSurface()
    if not underground then return end
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
    underground = false
    platformPart = nil
    savedCFrame = nil
end

player.CharacterRemoving:Connect(function()
    if platformPart and platformPart.Parent then
        platformPart:Destroy()
    end
    underground = false
    savedCFrame = nil
    platformPart = nil
end)

-- Loop autofarm
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

    if countItem("Water") < qty or countItem("Sugar Block Bag") < qty or countItem("Gelatin") < qty then
        setStatus("[auto] not enough materials (need " .. qty .. " of each)")
        return
    end

    running = true
    if startBtn then startBtn.Text = "Stop Autofarm" end

    -- Jalankan sekali lagi delete & expand untuk memastikan
    pcall(deleteBuildingParts)

    -- Pindah ke bawah tanah
    goUnderground()

    farmTask = task.spawn(autofarmLoop)
end

-- ============================================================
-- UI SEDERHANA (TANPA TAB)
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "QuickzAutoFarm"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 200)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(37,37,38)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 4)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(50,50,52)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 4)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "AutoFarm"
titleLabel.TextColor3 = Color3.fromRGB(240,240,240)
titleLabel.Font = Enum.Font.RobotoMono
titleLabel.TextSize = 12
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -28, 0.5, -11)
closeBtn.BackgroundColor3 = Color3.fromRGB(65,65,65)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(160,160,160)
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

-- Drag sederhana
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = Vector2.new(input.Position.X, input.Position.Y)
        startPos = Vector2.new(mainFrame.Position.X.Offset, mainFrame.Position.Y.Offset)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
userInput.InputChanged:Connect(function(input)
    if not dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
    local viewport = workspace.CurrentCamera.ViewportSize
    local size = mainFrame.AbsoluteSize
    mainFrame.Position = UDim2.new(0, math.clamp(startPos.X + delta.X, 0, viewport.X - size.X),
                                   0, math.clamp(startPos.Y + delta.Y, 0, viewport.Y - size.Y))
end)
userInput.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Konten
local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -30)
content.Position = UDim2.new(0, 0, 0, 30)
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
statusLabel.TextColor3 = Color3.fromRGB(160,160,160)
statusLabel.TextSize = 10
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.LayoutOrder = 0
statusLabel.Parent = content

-- Quantity
local qtyFrame = Instance.new("Frame")
qtyFrame.Size = UDim2.new(1, 0, 0, 24)
qtyFrame.BackgroundTransparency = 1
qtyFrame.LayoutOrder = 1
qtyFrame.Parent = content

local qtyLabel = Instance.new("TextLabel")
qtyLabel.Size = UDim2.new(0.4, 0, 1, 0)
qtyLabel.BackgroundTransparency = 1
qtyLabel.Text = "Quantity:"
qtyLabel.TextColor3 = Color3.fromRGB(240,240,240)
qtyLabel.Font = Enum.Font.RobotoMono
qtyLabel.TextSize = 11
qtyLabel.TextXAlignment = Enum.TextXAlignment.Left
qtyLabel.Parent = qtyFrame

qtyInput = Instance.new("TextBox")
qtyInput.Size = UDim2.new(0.4, 0, 1, 0)
qtyInput.Position = UDim2.new(0.4, 0, 0, 0)
qtyInput.BackgroundColor3 = Color3.fromRGB(50,50,52)
qtyInput.BorderSizePixel = 0
qtyInput.Font = Enum.Font.RobotoMono
qtyInput.Text = "100"
qtyInput.TextColor3 = Color3.fromRGB(240,240,240)
qtyInput.TextSize = 11
qtyInput.TextXAlignment = Enum.TextXAlignment.Center
qtyInput.ClearTextOnFocus = false
qtyInput.Parent = qtyFrame
Instance.new("UICorner", qtyInput).CornerRadius = UDim.new(0, 3)

-- Start button
startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(1, 0, 0, 28)
startBtn.BackgroundColor3 = Color3.fromRGB(65,65,65)
startBtn.BorderSizePixel = 1
startBtn.BorderColor3 = Color3.fromRGB(65,65,65)
startBtn.Font = Enum.Font.RobotoMono
startBtn.Text = "Start Autofarm"
startBtn.TextColor3 = Color3.fromRGB(240,240,240)
startBtn.TextSize = 11
startBtn.LayoutOrder = 2
startBtn.Parent = content
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 3)
startBtn.MouseButton1Click:Connect(toggleAutofarm)

print("[AutoFarm] UI loaded. Ready to farm!")