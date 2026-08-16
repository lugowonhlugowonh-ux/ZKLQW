-- MARSHMALLOW AUTOFARM SIMPLE
-- Based on the uploaded Quickz Autofarm script.
-- Simple UI + fixed farm/sell cycle.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local farming = false
local farmThread = nil
local status = "Idle"
local cyclesDone = 0

local function setStatus(text)
    status = text
end

local function getCharacter()
    return LocalPlayer.Character
end

local function getContainerItems()
    local result = {}
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = getCharacter()

    if backpack then
        for _, v in ipairs(backpack:GetChildren()) do
            result[v.Name] = v
        end
    end

    if character then
        for _, v in ipairs(character:GetChildren()) do
            result[v.Name] = v
        end
    end

    return result
end

local function hasItem(name)
    local items = getContainerItems()
    return items[name] ~= nil
end

local function countItem(name)
    local n = 0
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = getCharacter()

    if backpack then
        for _, v in ipairs(backpack:GetChildren()) do
            if v.Name == name then
                n += 1
            end
        end
    end

    if character then
        for _, v in ipairs(character:GetChildren()) do
            if v.Name == name then
                n += 1
            end
        end
    end

    return n
end

local function equipItem(name)
    local character = getCharacter()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not character or not backpack then
        return false
    end

    local tool = backpack:FindFirstChild(name)
    if not tool then
        if character:FindFirstChild(name) then
            return true
        end
        return false
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return false
    end

    local ok = pcall(function()
        humanoid:EquipTool(tool)
    end)

    if not ok then
        return false
    end

    for _ = 1, 30 do
        if character:FindFirstChild(name) then
            return true
        end
        task.wait(0.05)
    end

    return character:FindFirstChild(name) ~= nil
end

local function getCookingInteriors()
    local interiors = {}
    local map = workspace:FindFirstChild("Map")
    if not map then
        return interiors
    end

    local houses = map:FindFirstChild("Houses")
    if houses then
        local wh1 = houses:FindFirstChild("WH1")
        local interior = wh1 and wh1:FindFirstChild("Interior")
        if interior then
            table.insert(interiors, interior)
        end
    end

    local apartments = map:FindFirstChild("Apartments")
    if apartments then
        for _, child in ipairs(apartments:GetChildren()) do
            local apt = child:FindFirstChild("Apartment")
            if apt then
                local interior = apt:FindFirstChild("Interior")
                if interior then
                    table.insert(interiors, interior)
                end
            end
        end
    end

    return interiors
end

local function getCookingPrompts()
    local prompts = {}
    local seen = {}

    for _, interior in ipairs(getCookingInteriors()) do
        for _, obj in ipairs(interior:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local cookingPot = obj:FindFirstAncestor("Cooking Pot")
                if cookingPot and not seen[obj] then
                    seen[obj] = true
                    table.insert(prompts, obj)
                end
            end
        end
    end

    return prompts
end

local function preparePrompts()
    local prompts = getCookingPrompts()

    for _, prompt in ipairs(prompts) do
        pcall(function()
            prompt.MaxActivationDistance = 9999
            prompt.RequiresLineOfSight = false
        end)
    end

    return #prompts
end

local function fireCookingPrompts()
    local prompts = getCookingPrompts()

    for _, prompt in ipairs(prompts) do
        if not farming then
            return
        end

        pcall(function()
            prompt.MaxActivationDistance = 9999
            prompt.RequiresLineOfSight = false
            fireproximityprompt(prompt)
        end)

        task.wait(0.08)
    end
end

local function waitFarm(seconds, text)
    local elapsed = 0

    while farming and elapsed < seconds do
        setStatus(text .. " " .. math.max(0, math.ceil(seconds - elapsed)) .. "s")
        task.wait(0.5)
        elapsed += 0.5
    end

    return farming
end

local function cookOneCycle()
    if not farming then
        return false
    end

    -- Water
    if not hasItem("Water") then
        setStatus("Water tidak ditemukan")
        return false
    end

    setStatus("Equip Water")
    if not equipItem("Water") then
        setStatus("Gagal equip Water")
        return false
    end

    task.wait(0.25)
    setStatus("Cooking: Water")
    fireCookingPrompts()

    if not waitFarm(21, "Menunggu Water") then
        return false
    end

    -- Sugar
    if not hasItem("Sugar Block Bag") then
        setStatus("Sugar Block Bag tidak ditemukan")
        return false
    end

    setStatus("Equip Sugar Block Bag")
    if not equipItem("Sugar Block Bag") then
        setStatus("Gagal equip Sugar")
        return false
    end

    task.wait(0.5)
    setStatus("Cooking: Sugar")
    fireCookingPrompts()

    if not waitFarm(1, "Menunggu Sugar") then
        return false
    end

    -- Gelatin
    if not hasItem("Gelatin") then
        setStatus("Gelatin tidak ditemukan")
        return false
    end

    setStatus("Equip Gelatin")
    if not equipItem("Gelatin") then
        setStatus("Gagal equip Gelatin")
        return false
    end

    task.wait(0.5)
    setStatus("Cooking: Gelatin")
    fireCookingPrompts()

    if not waitFarm(1, "Menunggu Gelatin") then
        return false
    end

    -- Empty Bag
    if not hasItem("Empty Bag") then
        setStatus("Empty Bag tidak ditemukan")
        return false
    end

    setStatus("Equip Empty Bag")
    if not equipItem("Empty Bag") then
        setStatus("Gagal equip Empty Bag")
        return false
    end

    if not waitFarm(46, "Menunggu Empty Bag") then
        return false
    end

    setStatus("Packing Marshmallow")
    fireCookingPrompts()
    task.wait(1)

    cyclesDone += 1
    return true
end

local function findLamontPrompt()
    local folders = workspace:FindFirstChild("Folders")
    local npcs = folders and folders:FindFirstChild("NPCs")
    local lamont = npcs and npcs:FindFirstChild("Lamont Bell")

    if not lamont then
        return nil
    end

    local torso = lamont:FindFirstChild("UpperTorso") or lamont:FindFirstChild("Torso")
    if torso then
        return torso:FindFirstChildOfClass("ProximityPrompt")
    end

    return lamont:FindFirstChildWhichIsA("ProximityPrompt", true)
end

local function sellMarshmallows()
    local prompt = findLamontPrompt()

    if not prompt then
        setStatus("Lamont Bell prompt tidak ditemukan")
        return false
    end

    local sold = 0

    for _ = 1, 30 do
        if not farming then
            return false
        end

        local bags =
            countItem("Small Marshmallow Bag")
            + countItem("Medium Marshmallow Bag")
            + countItem("Large Marshmallow Bag")

        if bags <= 0 then
            break
        end

        local bag =
            (getCharacter() and getCharacter():FindFirstChild("Large Marshmallow Bag"))
            or (getCharacter() and getCharacter():FindFirstChild("Medium Marshmallow Bag"))
            or (getCharacter() and getCharacter():FindFirstChild("Small Marshmallow Bag"))

        if not bag then
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            bag =
                (backpack and backpack:FindFirstChild("Large Marshmallow Bag"))
                or (backpack and backpack:FindFirstChild("Medium Marshmallow Bag"))
                or (backpack and backpack:FindFirstChild("Small Marshmallow Bag"))
        end

        if bag then
            equipItem(bag.Name)
        end

        pcall(function()
            fireproximityprompt(prompt)
        end)

        sold += 1
        setStatus("Selling marshmallow... " .. bags .. " bag(s)")
        task.wait(1.25)
    end

    return sold > 0
end

-- UI
local gui = Instance.new("ScreenGui")
gui.Name = "MarshmallowAutofarmSimple"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 300, 0, 190)
main.Position = UDim2.new(0.5, -150, 0.5, -95)
main.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
main.BorderSizePixel = 0
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(70, 70, 78)
stroke.Thickness = 1
stroke.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 35)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.Text = "🍡 Marshmallow Autofarm"
title.TextColor3 = Color3.fromRGB(245, 245, 245)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 32)
statusLabel.Position = UDim2.new(0, 10, 0, 43)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.fromRGB(170, 170, 180)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 11
statusLabel.TextWrapped = true
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = main

local amountBox = Instance.new("TextBox")
amountBox.Size = UDim2.new(0, 115, 0, 32)
amountBox.Position = UDim2.new(0, 10, 0, 82)
amountBox.BackgroundColor3 = Color3.fromRGB(34, 34, 39)
amountBox.BorderSizePixel = 0
amountBox.Text = "10"
amountBox.PlaceholderText = "Cycles"
amountBox.TextColor3 = Color3.fromRGB(240, 240, 240)
amountBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 125)
amountBox.Font = Enum.Font.Gotham
amountBox.TextSize = 12
amountBox.Parent = main

Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 6)

local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0, 155, 0, 32)
startButton.Position = UDim2.new(0, 135, 0, 82)
startButton.BackgroundColor3 = Color3.fromRGB(70, 150, 90)
startButton.BorderSizePixel = 0
startButton.Text = "START FARM"
startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
startButton.Font = Enum.Font.GothamBold
startButton.TextSize = 11
startButton.Parent = main

Instance.new("UICorner", startButton).CornerRadius = UDim.new(0, 6)

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -20, 0, 50)
info.Position = UDim2.new(0, 10, 0, 125)
info.BackgroundTransparency = 1
info.Text = "Need: Water • Sugar Block Bag • Gelatin • Empty Bag"
info.TextColor3 = Color3.fromRGB(125, 125, 135)
info.Font = Enum.Font.Gotham
info.TextSize = 10
info.TextWrapped = true
info.TextXAlignment = Enum.TextXAlignment.Left
info.Parent = main

-- Drag
do
    local dragging = false
    local dragStart
    local startPos

    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPos = main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end)
end

local function updateUI()
    statusLabel.Text = "Status: " .. status .. "\nCycles: " .. tostring(cyclesDone)
end

task.spawn(function()
    while gui.Parent do
        updateUI()
        task.wait(0.25)
    end
end)

local function stopFarm()
    farming = false

    if farmThread then
        pcall(function()
            task.cancel(farmThread)
        end)
        farmThread = nil
    end

    setStatus("Stopped")
    startButton.Text = "START FARM"
    startButton.BackgroundColor3 = Color3.fromRGB(70, 150, 90)
end

local function startFarm()
    if farming then
        stopFarm()
        return
    end

    local amount = tonumber(amountBox.Text)
    if not amount or amount < 1 then
        amountBox.Text = "10"
        setStatus("Masukkan jumlah cycle >= 1")
        return
    end

    amount = math.floor(amount)
    cyclesDone = 0
    farming = true

    startButton.Text = "STOP FARM"
    startButton.BackgroundColor3 = Color3.fromRGB(170, 65, 65)

    farmThread = task.spawn(function()
        local promptCount = preparePrompts()

        if promptCount <= 0 then
            setStatus("Cooking Pot prompt tidak ditemukan")
            stopFarm()
            return
        end

        setStatus("Found " .. promptCount .. " cooking prompt(s)")

        while farming and cyclesDone < amount do
            if not cookOneCycle() then
                break
            end

            -- Sell whenever a marshmallow bag appears.
            if farming then
                sellMarshmallows()
            end

            task.wait(1)
        end

        if farming then
            setStatus("Farm selesai ✓")
        end

        farming = false
        farmThread = nil
        startButton.Text = "START FARM"
        startButton.BackgroundColor3 = Color3.fromRGB(70, 150, 90)
    end)
end

startButton.MouseButton1Click:Connect(startFarm)

-- F4 toggle
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end

    if input.KeyCode == Enum.KeyCode.F4 then
        startFarm()
    end
end)
