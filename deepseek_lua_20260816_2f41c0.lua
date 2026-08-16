-- Deobfuscated by NNVN Hub & BaconCheatz
-- Cleaned version

local Env = getfenv()
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 15)
local SettingsFile = "QuickzAutofarm_Settings.json"

local settings = {
    IsLight = false,
    TransparentMode = false
}

-- Fungsi untuk menyimpan settings
local function saveSettings()
    if writefile then
        pcall(function()
            writefile(SettingsFile, HttpService:JSONEncode(settings))
        end)
    end
end

-- Fungsi untuk memuat settings
local function loadSettings()
    if isfile and isfile(SettingsFile) then
        pcall(function()
            local data = HttpService:JSONDecode(readfile(SettingsFile))
            if data.IsLight ~= nil then settings.IsLight = data.IsLight end
            if data.TransparentMode ~= nil then settings.TransparentMode = data.TransparentMode end
        end)
    end
end
loadSettings()

-- GUI utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QuickzAutofarm"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- Tema warna
local function getThemeColors()
    local isLight = settings.IsLight
    return {
        MainBG = isLight and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(37, 37, 38),
        BarBG = isLight and Color3.fromRGB(220, 220, 224) or Color3.fromRGB(50, 50, 52),
        Text = isLight and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(240, 240, 240),
        SubText = isLight and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(160, 160, 160),
        Border = isLight and Color3.fromRGB(190, 190, 190) or Color3.fromRGB(65, 65, 65),
        Accent = isLight and Color3.fromRGB(205, 205, 205) or Color3.fromRGB(65, 65, 65)
    }
end
local theme = getThemeColors()

-- Ikon
local icons = {
    Autofarm = "rbxassetid://115220539945550",
    Counters = "rbxassetid://82314355192648",
    UIConfig = "rbxassetid://122422795821505",
    Credits = "rbxassetid://90589453613903",
    Tutorial = "rbxassetid://82570754456492",
    ESP = "rbxassetid://82570754456492"
}

-- Fungsi bantuan
local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function getViewportSize()
    return workspace.CurrentCamera.ViewportSize
end

-- Fungsi drag window
local function makeDraggable(frame, titleBar, minY)
    minY = minY or 0
    local dragging = false
    local dragStart = Vector2.new()
    local startPos = Vector2.new()

    local function updatePosition()
        frame.Position = UDim2.new(0, frame.AbsolutePosition.X, 0, frame.AbsolutePosition.Y)
    end

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updatePosition()
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            startPos = Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset)

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end

        local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
        local viewport = getViewportSize()
        local size = frame.AbsoluteSize

        frame.Position = UDim2.new(
            0,
            math.clamp(startPos.X + delta.X, 0, viewport.X - size.X),
            0,
            math.clamp(startPos.Y + delta.Y, minY, viewport.Y - size.Y)
        )
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Fungsi untuk membuat tombol dengan hover effect
local function setupHoverButton(button, imageId)
    local originalImage = button.Image
    button.MouseEnter:Connect(function()
        button.Image = "rbxassetid://973821519" .. tostring(imageId)
    end)
    button.MouseLeave:Connect(function()
        button.Image = originalImage
    end)
end

-- Keybind system
local keybinds = {}
local bindWaiting = nil
local bindIndicator = nil

local function getKeyName(keyCode)
    return tostring(keyCode):gsub("Enum.KeyCode.", "")
end

local function executeKeybind(id)
    local bind = keybinds[id]
    if bind and bind.callback then
        bind.callback()
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if bindWaiting then
        if input.KeyCode == Enum.KeyCode.Escape then
            keybinds[bindWaiting].key = nil
            if keybinds[bindWaiting].keyLabel then
                keybinds[bindWaiting].keyLabel.Text = "[-]"
            end
        else
            for id, bind in pairs(keybinds) do
                if id ~= bindWaiting and bind.key == input.KeyCode then
                    bind.key = nil
                    if bind.keyLabel then
                        bind.keyLabel.Text = "[-]"
                        bind.keyLabel.TextColor3 = theme.SubText
                    end
                end
            end

            keybinds[bindWaiting].key = input.KeyCode
            if keybinds[bindWaiting].keyLabel then
                keybinds[bindWaiting].keyLabel.Text = "[" .. getKeyName(input.KeyCode) .. "]"
            end

            if bindIndicator and bindIndicator.Parent then
                bindIndicator:Destroy()
            end
        end
        bindWaiting = nil
        return
    end

    for id, bind in pairs(keybinds) do
        if bind.key and input.KeyCode == bind.key then
            pcall(executeKeybind, id)
        end
    end
end)

-- Fungsi membuat tombol keybind
local function createKeybindButton(parent, id, callback, layoutOrder)
    keybinds[id] = {
        key = nil,
        callback = callback,
        keyLabel = nil
    }

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 38, 0, 18)
    button.BackgroundColor3 = theme.Accent
    button.BorderSizePixel = 1
    button.BorderColor3 = theme.Border
    button.Font = Enum.Font.RobotoMono
    button.Text = "[-]"
    button.TextColor3 = theme.SubText
    button.TextSize = 9
    button.LayoutOrder = layoutOrder or 0
    button.ZIndex = 5
    button.Parent = parent

    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 3)

    keybinds[id].keyLabel = button

    button.MouseButton1Click:Connect(function()
        if bindWaiting then return end
        bindWaiting = id
        button.Text = "[...]"
        button.TextColor3 = theme.Text

        bindIndicator = Instance.new("Frame")
        bindIndicator.Size = UDim2.new(1, 0, 0, 18)
        bindIndicator.Position = UDim2.new(0, 0, 0, 0)
        bindIndicator.BackgroundColor3 = theme.Accent
        bindIndicator.BackgroundTransparency = 0.3
        bindIndicator.BorderSizePixel = 0
        bindIndicator.ZIndex = 20
        bindIndicator.Parent = ScreenGui

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.RobotoMono
        label.Text = "press a key to bind  •  ESC to clear"
        label.TextColor3 = theme.Text
        label.TextSize = 10
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.ZIndex = 21
        label.Parent = bindIndicator

        task.delay(5, function()
            if bindWaiting == id then
                button.Text = keybinds[id].key and "[" .. getKeyName(keybinds[id].key) .. "]" or "[-]"
                button.TextColor3 = theme.SubText
                if bindIndicator and bindIndicator.Parent then
                    bindIndicator:Destroy()
                end
                if bindIndicator == bindIndicator then
                    bindIndicator = nil
                end
            end
        end)
    end)

    return button
end

-- Harga item
local itemPrices = {
    ["Small Marshmallow Bag"] = 1470,
    ["Medium Marshmallow Bag"] = 2840,
    ["Large Marshmallow Bag"] = 4150
}

-- Counter system
local counters = {
    money = {gui = nil, conn = nil},
    materials = {gui = nil, conn = nil},
    general = {gui = nil, conn = nil}
}

local function clearCounter(type)
    local counter = counters[type]
    if counter.conn then
        counter.conn:Disconnect()
        counter.conn = nil
    end
    if counter.gui and counter.gui.Parent then
        counter.gui:Destroy()
        counter.gui = nil
    end
end

local bagNames = {"Small Marshmallow Bag", "Medium Marshmallow Bag", "Large Marshmallow Bag"}
local farmStartTime = nil
local sessionBags = 0
local totalBags = 0

local function countBags()
    local count = 0
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character

    for _, name in ipairs(bagNames) do
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                if item.Name == name then
                    count = count + 1
                end
            end
        end
        if character then
            for _, item in ipairs(character:GetChildren()) do
                if item.Name == name then
                    count = count + 1
                end
            end
        end
    end

    return count
end

local function formatTime(seconds)
    local s = math.floor(seconds)
    local h = math.floor(s / 3600)
    local m = math.floor((s % 3600) / 60)
    local sec = s % 60
    if h > 0 then
        return string.format("%02d:%02d:%02d", h, m, sec)
    end
    return string.format("%02d:%02d", m, sec)
end

-- General Counter
local function toggleGeneralCounter()
    if counters.general.gui and counters.general.gui.Parent then
        clearCounter("general")
        return
    end

    if not farmStartTime then
        farmStartTime = tick()
    end
    local initialBagCount = countBags()

    local gui = Instance.new("ScreenGui")
    gui.Name = "QuickzCounter_general"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999

    pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)
    if not gui.Parent then
        gui.Parent = PlayerGui
    end

    counters.general.gui = gui

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 220, 0, 0)
    main.Position = UDim2.new(0.5, -110, 0.38, 0)
    main.BackgroundColor3 = theme.MainBG
    main.BorderSizePixel = 0
    main.AutomaticSize = Enum.AutomaticSize.Y
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 4)

    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.Border
    stroke.Thickness = 1
    stroke.Parent = main

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 0)
    layout.Parent = main

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 32)
    titleBar.BackgroundColor3 = theme.BarBG
    titleBar.BorderSizePixel = 0
    titleBar.LayoutOrder = 0
    titleBar.Parent = main
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 4)

    local titleDivider = Instance.new("Frame")
    titleDivider.Size = UDim2.new(1, 0, 0.5, 0)
    titleDivider.Position = UDim2.new(0, 0, 0.5, 0)
    titleDivider.BackgroundColor3 = theme.BarBG
    titleDivider.BorderSizePixel = 0
    titleDivider.Parent = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "General Counter"
    titleLabel.TextColor3 = theme.Text
    titleLabel.Font = Enum.Font.RobotoMono
    titleLabel.TextSize = 12
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(1, -28, 0.5, -11)
    closeBtn.BackgroundColor3 = theme.Accent
    closeBtn.Text = "×"
    closeBtn.TextColor3 = theme.SubText
    closeBtn.Font = Enum.Font.RobotoMono
    closeBtn.TextSize = 13
    closeBtn.BorderSizePixel = 0
    closeBtn.AutoButtonColor = true
    closeBtn.ZIndex = 10
    closeBtn.Parent = titleBar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 3)
    closeBtn.MouseButton1Click:Connect(function()
        clearCounter("general")
    end)

    makeDraggable(main, titleBar)

    local separator1 = Instance.new("Frame")
    separator1.Size = UDim2.new(1, 0, 0, 1)
    separator1.BackgroundColor3 = theme.Border
    separator1.BorderSizePixel = 0
    separator1.LayoutOrder = 1
    separator1.Parent = main

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 0, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.LayoutOrder = 2
    content.Parent = main

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 4)
    contentLayout.Parent = content

    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingLeft = UDim.new(0, 10)
    contentPadding.PaddingRight = UDim.new(0, 10)
    contentPadding.PaddingTop = UDim.new(0, 8)
    contentPadding.PaddingBottom = UDim.new(0, 10)
    contentPadding.Parent = content

    local function createStatRow(label, value, order)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 20)
        row.BackgroundTransparency = 1
        row.LayoutOrder = order
        row.Parent = content

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.6, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = theme.SubText
        lbl.Font = Enum.Font.RobotoMono
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local val = Instance.new("TextLabel")
        val.Size = UDim2.new(0.4, 0, 1, 0)
        val.Position = UDim2.new(0.6, 0, 0, 0)
        val.BackgroundTransparency = 1
        val.Text = value
        val.TextColor3 = theme.Text
        val.Font = Enum.Font.RobotoMono
        val.TextSize = 10
        val.TextXAlignment = Enum.TextXAlignment.Right
        val.Parent = row

        return val
    end

    local farmTimeLabel = createStatRow("Farm Time", "00:00", 0)
    local sessionBagsLabel = createStatRow("Bags (session)", "0", 1)
    local totalBagsLabel = createStatRow("Bags (total)", "0", 2)

    local separator2 = Instance.new("Frame")
    separator2.Size = UDim2.new(1, 0, 0, 1)
    separator2.BackgroundColor3 = theme.Border
    separator2.BorderSizePixel = 0
    separator2.LayoutOrder = 5
    separator2.Parent = content

    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(1, 0, 0, 22)
    resetBtn.BackgroundColor3 = theme.Accent
    resetBtn.BorderSizePixel = 1
    resetBtn.BorderColor3 = theme.Border
    resetBtn.Font = Enum.Font.RobotoMono
    resetBtn.Text = "Reset Counter"
    resetBtn.TextColor3 = theme.SubText
    resetBtn.TextSize = 10
    resetBtn.LayoutOrder = 6
    resetBtn.Parent = content
    Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 3)

    resetBtn.MouseButton1Click:Connect(function()
        farmStartTime = tick()
        sessionBags = 0
        totalBags = 0
        initialBagCount = countBags()
    end)

    local updateTimer = 0
    counters.general.conn = RunService.Heartbeat:Connect(function(dt)
        updateTimer = updateTimer + dt
        if updateTimer < 0.5 then return end
        updateTimer = 0

        pcall(function()
            farmTimeLabel.Text = formatTime(farmStartTime and tick() - farmStartTime or 0)

            local currentCount = countBags()
            if initialBagCount ~= nil then
                local diff = currentCount - initialBagCount
                if diff > 0 then
                    sessionBags = sessionBags + diff
                    totalBags = totalBags + diff
                end
            end
            initialBagCount = currentCount

            sessionBagsLabel.Text = tostring(sessionBags)
            totalBagsLabel.Text = tostring(totalBags)
        end)
    end)
end

-- Counter untuk money/materials
local function toggleCounter(type)
    if type == "general" then
        toggleGeneralCounter()
        return
    end

    if counters[type].gui and counters[type].gui.Parent then
        clearCounter(type)
        return
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "QuickzCounter_" .. type
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999

    pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)
    if not gui.Parent then
        gui.Parent = PlayerGui
    end

    counters[type].gui = gui

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 210, 0, 0)
    main.Position = UDim2.new(type == "money" and 0.41 or 0.6, 0, 0.38, 0)
    main.BackgroundColor3 = theme.MainBG
    main.BorderSizePixel = 0
    main.AutomaticSize = Enum.AutomaticSize.Y
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 4)

    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.Border
    stroke.Thickness = 1
    stroke.Parent = main

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 0)
    layout.Parent = main

    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 32)
    titleBar.BackgroundColor3 = theme.BarBG
    titleBar.BorderSizePixel = 0
    titleBar.LayoutOrder = 0
    titleBar.Parent = main
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 4)

    local titleDivider = Instance.new("Frame")
    titleDivider.Size = UDim2.new(1, 0, 0.5, 0)
    titleDivider.Position = UDim2.new(0, 0, 0.5, 0)
    titleDivider.BackgroundColor3 = theme.BarBG
    titleDivider.BorderSizePixel = 0
    titleDivider.Parent = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = type == "money" and "Money Counter" or "Materials Counter"
    titleLabel.TextColor3 = theme.Text
    titleLabel.Font = Enum.Font.RobotoMono
    titleLabel.TextSize = 12
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(1, -28, 0.5, -11)
    closeBtn.BackgroundColor3 = theme.Accent
    closeBtn.Text = "×"
    closeBtn.TextColor3 = theme.SubText
    closeBtn.Font = Enum.Font.RobotoMono
    closeBtn.TextSize = 13
    closeBtn.BorderSizePixel = 0
    closeBtn.AutoButtonColor = true
    closeBtn.ZIndex = 10
    closeBtn.Parent = titleBar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 3)
    closeBtn.MouseButton1Click:Connect(function()
        clearCounter(type)
    end)

    makeDraggable(main, titleBar)

    local separator = Instance.new("Frame")
    separator.Size = UDim2.new(1, 0, 0, 1)
    separator.BackgroundColor3 = theme.Border
    separator.BorderSizePixel = 0
    separator.LayoutOrder = 1
    separator.Parent = main

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 0, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.LayoutOrder = 2
    content.Parent = main

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 3)
    contentLayout.Parent = content

    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingLeft = UDim.new(0, 10)
    contentPadding.PaddingRight = UDim.new(0, 10)
    contentPadding.PaddingTop = UDim.new(0, 8)
    contentPadding.PaddingBottom = UDim.new(0, 10)
    contentPadding.Parent = content

    local itemList = {}
    local itemData = {}

    if type == "money" then
        itemData = {
            {short = "Small Bag", full = "Small Marshmallow Bag"},
            {short = "Medium Bag", full = "Medium Marshmallow Bag"},
            {short = "Large Bag", full = "Large Marshmallow Bag"}
        }
    else
        itemData = {
            {short = "Water", full = "Water"},
            {short = "Gelatin", full = "Gelatin"},
            {short = "Sugar Bag", full = "Sugar Block Bag"}
        }
    end

    for i, data in ipairs(itemData) do
        (function(name, order)
            local row = Instance.new("Frame")
            row.Name = "Row_" .. name
            row.Size = UDim2.new(1, 0, 0, 18)
            row.BackgroundTransparency = 1
            row.LayoutOrder = order
            row.Parent = content

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.62, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = name
            lbl.TextColor3 = theme.SubText
            lbl.Font = Enum.Font.RobotoMono
            lbl.TextSize = 10
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextTruncate = Enum.TextTruncate.AtEnd
            lbl.Parent = row

            local val = Instance.new("TextLabel")
            val.Size = UDim2.new(0.38, 0, 1, 0)
            val.Position = UDim2.new(0.62, 0, 0, 0)
            val.BackgroundTransparency = 1
            val.Text = "0"
            val.TextColor3 = theme.Text
            val.Font = Enum.Font.RobotoMono
            val.TextSize = 10
            val.TextXAlignment = Enum.TextXAlignment.Right
            val.Parent = row

            itemList[name] = {
                frame = row,
                lbl = lbl,
                val = val
            }
        end)(data.short, i - 1)
    end

    local sep2 = Instance.new("Frame")
    sep2.Size = UDim2.new(1, 0, 0, 1)
    sep2.BackgroundColor3 = theme.Border
    sep2.BorderSizePixel = 0
    sep2.LayoutOrder = #itemData
    sep2.Parent = content

    local totalRow = Instance.new("Frame")
    totalRow.Size = UDim2.new(1, 0, 0, 20)
    totalRow.BackgroundTransparency = 1
    totalRow.LayoutOrder = #itemData + 1
    totalRow.Parent = content

    local totalLbl = Instance.new("TextLabel")
    totalLbl.Size = UDim2.new(0.5, 0, 1, 0)
    totalLbl.BackgroundTransparency = 1
    totalLbl.Text = "TOTAL"
    totalLbl.TextColor3 = theme.Text
    totalLbl.Font = Enum.Font.RobotoMono
    totalLbl.TextSize = 11
    totalLbl.TextXAlignment = Enum.TextXAlignment.Left
    totalLbl.Parent = totalRow

    local totalVal = Instance.new("TextLabel")
    totalVal.Size = UDim2.new(0.5, 0, 1, 0)
    totalVal.Position = UDim2.new(0.5, 0, 0, 0)
    totalVal.BackgroundTransparency = 1
    totalVal.Text = type == "money" and "$0" or "0"
    totalVal.TextColor3 = theme.Text
    totalVal.Font = Enum.Font.RobotoMono
    totalVal.TextSize = 11
    totalVal.TextXAlignment = Enum.TextXAlignment.Right
    totalVal.Parent = totalRow

    local function updateCounter()
        if not gui or not gui.Parent then return end

        local counts = {}
        for _, data in ipairs(itemData) do
            counts[data.short] = 0
        end

        local function countItems(container)
            if not container then return end
            for _, child in ipairs(container:GetChildren()) do
                for _, data in ipairs(itemData) do
                    if child.Name == data.full then
                        counts[data.short] = counts[data.short] + 1
                    end
                end
            end
        end

        countItems(LocalPlayer:FindFirstChild("Backpack"))
        countItems(LocalPlayer.Character)

        local sorted = {}
        for _, data in ipairs(itemData) do
            table.insert(sorted, {
                short = data.short,
                full = data.full,
                count = counts[data.short]
            })
        end
        table.sort(sorted, function(a, b) return a.count > b.count end)

        for i, data in ipairs(sorted) do
            if itemList[data.short] then
                local item = itemList[data.short]
                item.frame.LayoutOrder = i - 1
                item.val.Text = tostring(data.count)
                if data.count == 0 then
                    item.lbl.TextColor3 = theme.Border
                    item.val.TextColor3 = theme.Border
                else
                    item.lbl.TextColor3 = theme.SubText
                    item.val.TextColor3 = theme.Text
                end
            end
        end

        if totalVal then
            if type == "money" then
                local total = 0
                for _, data in ipairs(itemData) do
                    total = total + counts[data.short] * (itemPrices[data.full] or 0)
                end
                totalVal.Text = "$" .. tostring(total)
            else
                local total = 0
                for _, data in ipairs(itemData) do
                    total = total + counts[data.short]
                end
                totalVal.Text = tostring(total)
            end
        end
    end

    updateCounter()

    local timer = 0
    counters[type].conn = RunService.Heartbeat:Connect(function(dt)
        timer = timer + dt
        if timer >= 0.5 then
            timer = 0
            pcall(updateCounter)
        end
    end)
end

-- Autofarm
local isFarming = false
local farmTask = nil
local statusText = ""
local antiafkEnabled = false
local antiafkTask = nil
local antiafkInterval = 900

local function setStatus(text)
    statusText = text
    if statusLabel then
        statusLabel.Text = text
    end
end

-- Fungsi untuk mendapatkan semua cooking pots
local function getCookingPots()
    local pots = {}
    local map = workspace:FindFirstChild("Map")

    if map then
        -- WH1
        pcall(function()
            local houses = map:FindFirstChild("Houses")
            if houses then
                local wh1 = houses:FindFirstChild("WH1")
                if wh1 then
                    local interior = wh1:FindFirstChild("Interior")
                    if interior then
                        table.insert(pots, interior)
                    end
                end
            end
        end)

        -- Apartments
        pcall(function()
            local apartments = map:FindFirstChild("Apartments")
            if apartments then
                for _, child in ipairs(apartments:GetChildren()) do
                    pcall(function()
                        local apartment = child:FindFirstChild("Apartment")
                        if apartment then
                            local interior = apartment:FindFirstChild("Interior")
                            if interior then
                                table.insert(pots, interior)
                            end
                        end

                        -- Check inside folders/models
                        if child:IsA("Folder") or child:IsA("Model") then
                            local apartment = child:FindFirstChild("Apartment")
                            if apartment then
                                local interior = apartment:FindFirstChild("Interior")
                                if interior then
                                    table.insert(pots, interior)
                                end
                            end
                        end
                    end)
                end
            end
        end)
    end

    return pots
end

-- Fungsi untuk mencari proximity prompts di cooking pots
local function findPromptsInContainer(container, callback)
    if not container then return end

    for _, child in ipairs(container:GetDescendants()) do
        if child.Name == "Cooking Pot" then
            local attachment = child:FindFirstChild("Attachment")
            if attachment then
                local prompt = attachment:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    callback(prompt)
                end
            end

            -- Cari prompt di descendants
            for _, descendant in ipairs(child:GetDescendants()) do
                if descendant:IsA("ProximityPrompt") then
                    callback(descendant)
                end
            end
        end
    end
end

-- Fungsi untuk mendapatkan semua proximity prompts
local function getAllPrompts()
    local cache = {}
    local prompts = {}

    for _, pot in ipairs(getCookingPots()) do
        pcall(function()
            findPromptsInContainer(pot, function(prompt)
                if not cache[prompt] then
                    cache[prompt] = true
                    table.insert(prompts, prompt)
                end
            end)
        end)
    end

    return prompts
end

-- Fungsi untuk memperluas jangkauan prompt
local function expandPromptRange()
    for _, pot in ipairs(getCookingPots()) do
        pcall(function()
            findPromptsInContainer(pot, function(prompt)
                prompt.MaxActivationDistance = 9999
                prompt.RequiresLineOfSight = false
            end)
        end)
    end
end

-- Fungsi untuk menembakkan semua prompt
local function fireAllPrompts()
    for _, prompt in ipairs(getAllPrompts()) do
        pcall(function()
            if not prompt or not prompt.Parent then return end            prompt.MaxActivationDistance = 9999
            prompt.RequiresLineOfSight = false
            fireproximityprompt(prompt)
        end)
        task.wait(0.05)
    end
end

-- Fungsi untuk mengecek item di inventory
local function hasItem(itemName)
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character

    if backpack and backpack:FindFirstChild(itemName) then
        return true
    end
    if character and character:FindFirstChild(itemName) then
        return true
    end
    return false
end

-- Fungsi untuk equip item
local function equipItem(itemName)
    local character = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")

    if not character or not backpack then return false end

    local tool = backpack:FindFirstChild(itemName)
    if not tool then return false end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end

    pcall(function()
        humanoid:EquipTool(tool)
    end)

    -- Tunggu sampai item ter-equip
    local attempts = 0
    while not character:FindFirstChild(itemName) and attempts < 20 do
        task.wait(0.05)
        attempts = attempts + 1
    end

    return character:FindFirstChild(itemName) ~= nil
end

-- Fungsi untuk menunggu dengan status
local function waitWithStatus(duration, message)
    local elapsed = 0
    while elapsed < duration do
        if not isFarming then break end
        setStatus(string.format("[af] %s — %ds", message, math.ceil(duration - elapsed)))
        task.wait(0.5)
        elapsed = elapsed + 0.5
    end
    return isFarming
end

-- Loop autofarm utama
local function autofarmLoop()
    while isFarming do
        -- Water
        if hasItem("Water") then
            setStatus("[af] equipping Water...")
            if equipItem("Water") then
                task.wait(0.3)
                setStatus("[af] pressing E — Water")
                fireAllPrompts()
                if not waitWithStatus(21, "waiting after Water") then break end
            end
        end

        if not isFarming then break end
        task.wait(1)
        if not isFarming then break end

        -- Sugar Block Bag
        if hasItem("Sugar Block Bag") then
            setStatus("[af] equipping Sugar Bag...")
            if equipItem("Sugar Block Bag") then
                task.wait(1)
                if not isFarming then break end
                setStatus("[af] pressing E — Sugar Bag")
                fireAllPrompts()
            end
        end

        if not isFarming then break end
        task.wait(1)
        if not isFarming then break end

        -- Gelatin
        if hasItem("Gelatin") then
            setStatus("[af] equipping Gelatin...")
            if equipItem("Gelatin") then
                task.wait(1)
                if not isFarming then break end
                setStatus("[af] pressing E — Gelatin")
                fireAllPrompts()
            end
        end

        if not isFarming then break end
        task.wait(1)
        if not isFarming then break end

        -- Empty Bag (end of cycle)
        if hasItem("Empty Bag") then
            setStatus("[af] equipping Empty Bag...")
            if equipItem("Empty Bag") then
                local elapsed = 0
                while elapsed < 46 do
                    if not isFarming then break end
                    task.wait(0.5)
                    elapsed = elapsed + 0.5
                    setStatus(string.format("[af] empty bag — firing in %ds", math.max(0, math.ceil(46 - elapsed))))
                end

                if not isFarming then break end

                setStatus("[af] pressing E — Empty Bag (end of cycle)")
                fireAllPrompts()
                task.wait(0.5)

                if not isFarming then break end

                -- Cek apakah masih ada item
                if not hasItem("Water") and not hasItem("Sugar Block Bag") and not hasItem("Gelatin") and not hasItem("Empty Bag") then
                    setStatus("[af] no items found — retrying...")
                    task.wait(2)
                end
            end
        end
    end

    setStatus("[autofarm] idle")
end

-- Platform untuk underground farming
local platformPart = nil
local originalCFrame = nil
local isPlatformActive = false
local platformHeight = 11

local function createPlatform()
    if isPlatformActive then return end

    local character = LocalPlayer.Character
    if not character then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local success, part = pcall(function()
        local p = Instance.new("Part")
        p.Name = "Quickz_Platform"
        p.Size = Vector3.new(40, 1, 40)
        p.Transparency = 1
        p.Anchored = true
        p.CanCollide = true
        p.CFrame = rootPart.CFrame - Vector3.new(0, platformHeight, 0)
        p.Parent = workspace
        return p
    end)

    if not success then return end

    originalCFrame = rootPart.CFrame
    platformPart = part

    task.wait(0.1)

    pcall(function()
        rootPart.CFrame = platformPart.CFrame + Vector3.new(0, 3.5, 0)
    end)

    isPlatformActive = true
end

local function removePlatform()
    if not isPlatformActive then return end

    local character = LocalPlayer.Character
    if not character then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    pcall(function()
        if originalCFrame then
            rootPart.CFrame = originalCFrame
        else
            rootPart.CFrame = rootPart.CFrame + Vector3.new(0, platformHeight, 0)
        end
    end)

    if platformPart and platformPart.Parent then
        platformPart:Destroy()
    end

    isPlatformActive = false
end

LocalPlayer.CharacterRemoving:Connect(function()
    if platformPart and platformPart.Parent then
        platformPart:Destroy()
    end
    isPlatformActive = false
end)

-- Fungsi untuk setup WH1
local function setupWH1()
    local map = workspace:FindFirstChild("Map")
    if not map then return "[error] Map not found" end

    local houses = map:FindFirstChild("Houses")
    if not houses then return "[error] Map > Houses not found" end

    local wh1 = houses:FindFirstChild("WH1")
    if not wh1 then return "[error] WH1 not found" end

    local result = {}
    local count = 0

    pcall(function()
        local interior = wh1:FindFirstChild("Interior")
        if interior then
            findPromptsInContainer(interior, function(prompt)
                prompt.MaxActivationDistance = 9999
                prompt.RequiresLineOfSight = false
                count = count + 1
            end)
        end
    end)

    table.insert(result, count .. " pots expanded")
    return "[ok] " .. table.concat(result, " | ")
end

-- Fungsi untuk setup apartments
local function setupApartments()
    local map = workspace:FindFirstChild("Map")
    if not map then return "[error] Map not found" end

    local apartments = map:FindFirstChild("Apartments")
    if not apartments then return "[error] Apartments not found" end

    local result = {}
    local removedCount = 0
    local collisionCleared = 0
    local potCount = 0

    for _, child in ipairs(apartments:GetChildren()) do
        pcall(function()
            local apartmentsList = {}

            -- Cari Apartment
            local apt = child:FindFirstChild("Apartment")
            if apt then
                table.insert(apartmentsList, apt)
            end

            -- Cek folder/model
            if child:IsA("Folder") or child:IsA("Model") then
                local apt = child:FindFirstChild("Apartment")
                if apt then
                    table.insert(apartmentsList, apt)
                end
            end

            for _, apt in ipairs(apartmentsList) do
                -- Hapus housed.0052
                local exterior = apt:FindFirstChild("Exterior")
                if exterior then
                    local housed = exterior:FindFirstChild("housed.0052")
                    if housed then
                        housed:Destroy()
                        removedCount = removedCount + 1
                    end
                end

                -- Hapus collision parts
                local interior = apt:FindFirstChild("Interior")
                if interior then
                    for _, part in ipairs(interior:GetChildren()) do
                        part:Destroy()
                        collisionCleared = collisionCleared + 1
                    end

                    -- Expand prompts
                    findPromptsInContainer(interior, function(prompt)
                        prompt.MaxActivationDistance = 9999
                        prompt.RequiresLineOfSight = false
                        potCount = potCount + 1
                    end)
                end
            end
        end)
    end

    table.insert(result, removedCount .. " housed.0052 removed")
    table.insert(result, collisionCleared .. " collision parts cleared")
    table.insert(result, potCount .. " pots expanded")

    return "[ok] " .. table.concat(result, " | ")
end

-- Auto setup
task.spawn(function()
    task.wait(2)
    pcall(setupWH1)
    pcall(setupApartments)
end)

-- Anti-AFK
local function antiafkLoop()
    while antiafkEnabled do
        local elapsed = 0
        while antiafkEnabled and elapsed < antiafkInterval do
            task.wait(1)
            elapsed = elapsed + 1
        end

        if not antiafkEnabled then break end

        pcall(function()
            local camera = workspace.CurrentCamera
            if camera.CameraType == Enum.CameraType.Custom then
                local cf = camera.CFrame
                camera.CFrame = cf * CFrame.Angles(0, 0.001, 0)
                task.wait(0.08)
                camera.CFrame = cf
            end
        end)

        pcall(function()
            VirtualInputManager:SendMouseMoveEvent(1, 1, workspace.CurrentCamera)
        end)
    end
end

-- Fungsi untuk menentukan posisi target
local targetCFrame = CFrame.new(1138.20325, 7.88028622, 451.605072)
local alternateCFrame = CFrame.new(1138.7417, 1.99412489, 423.689026)
local farmPosition = "auto"

local function getTargetCFrame()
    if farmPosition == "right" then
        return targetCFrame
    elseif farmPosition == "left" then
        return alternateCFrame
    end

    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return targetCFrame
    end

    local pos = rootPart.Position
    local bestDist = math.huge
    local bestPos = nil
    local isApartment = false

    local map = workspace:FindFirstChild("Map")
    if map then
        local apartments = map:FindFirstChild("Apartments")
        if apartments then
            for _, child in ipairs(apartments:GetChildren()) do
                local name = child.Name
                if name:find("CompactWalkupAPT5") or name:find("Compact") then
                    pcall(function()
                        local apts = {}
                        local apt = child:FindFirstChild("Apartment")
                        if apt then
                            table.insert(apts, apt)
                        end

                        if child:IsA("Folder") or child:IsA("Model") then
                            local apt = child:FindFirstChild("Apartment")
                            if apt then
                                table.insert(apts, apt)
                            end
                        end

                        for _, apt in ipairs(apts) do
                            local interior = apt:FindFirstChild("Interior")
                            if interior then
                                findPromptsInContainer(interior, function(prompt)
                                    pcall(function()
                                        local parent = prompt.Parent
                                        local promptPos
                                        if parent:IsA("Attachment") then
                                            promptPos = parent.WorldPosition
                                        else
                                            promptPos = parent.Position
                                        end

                                        local dist = (promptPos - pos).Magnitude
                                        if dist < bestDist then
                                            bestDist = dist
                                            bestPos = promptPos
                                            isApartment = true
                                        end
                                    end)
                                end)
                            end
                        end
                    end)
                end
            end
        end

        -- Cek WH1
        local houses = map:FindFirstChild("Houses")
        if houses then
            pcall(function()
                local wh1 = houses:FindFirstChild("WH1")
                local interior = wh1 and wh1:FindFirstChild("Interior")
                if interior then
                    findPromptsInContainer(interior, function(prompt)
                        pcall(function()
                            local parent = prompt.Parent
                            local promptPos
                            if parent:IsA("Attachment") then
                                promptPos = parent.WorldPosition
                            else
                                promptPos = parent.Position
                            end

                            local dist = (promptPos - pos).Magnitude
                            if dist < bestDist then
                                bestDist = dist
                                bestPos = promptPos
                                isApartment = false
                            end
                        end)
                    end)
                end
            end)
        end
    end

    if isApartment then
        return alternateCFrame
    else
        return targetCFrame
    end
end

local bagTypes = {"Small Marshmallow Bag", "Medium Marshmallow Bag", "Large Marshmallow Bag"}

local function getAnyBag()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character

    for _, name in ipairs(bagTypes) do
        if backpack then
            local tool = backpack:FindFirstChild(name)
            if tool then return tool end
        end
        if character then
            local tool = character:FindFirstChild(name)
            if tool then return tool end
        end
    end

    return nil
end

local function countItem(itemName)
    local count = 0
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character

    if backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            if child.Name == itemName then
                count = count + 1
            end
        end
    end

    if character then
        for _, child in ipairs(character:GetChildren()) do
            if child.Name == itemName then
                count = count + 1
            end
        end
    end

    return count
end

local function hasAnyItem(itemList)
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character

    for _, name in ipairs(itemList) do
        if backpack and backpack:FindFirstChild(name) then
            return true
        end
        if character and character:FindFirstChild(name) then
            return true
        end
    end

    return false
end

local function hasMaterials(count)
    return countItem("Water") >= count and countItem("Sugar Block Bag") >= count and countItem("Gelatin") >= count
end

local function createTempPlatform(cframe, name)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = Vector3.new(2000, 1, 2000)
    part.Anchored = true
    part.CanCollide = true
    part.BrickColor = BrickColor.new("Bright red")
    part.Material = Enum.Material.SmoothPlastic
    part.Transparency = 0.5
    part.CFrame = cframe * CFrame.new(0, -11, 0)
    part.Parent = workspace
    return part
end

local function setCamera(cframe)
    pcall(function()
        workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
        workspace.CurrentCamera.CFrame = cframe
    end)
end

local function resetCamera()
    pcall(function()
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end)
end

local function cleanupPlatforms()
    if platformPart and platformPart.Parent then
        platformPart:Destroy()
    end
    if tempPlatform and tempPlatform.Parent then
        tempPlatform:Destroy()
    end
end

local function restorePosition()
    local character = LocalPlayer.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart and savedCFrame then
            pcall(function()
                rootPart.CFrame = savedCFrame
            end)
        end
    end

    cleanupPlatforms()
    resetCamera()
end

local function teleportToPlatform(platform)
    local character = LocalPlayer.Character
    if not character then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    rootPart.Anchored = true
    task.wait(0.05)

    pcall(function()
        rootPart.CFrame = platform.CFrame + Vector3.new(0, 3.5, 0)
    end)

    task.wait(0.1)
    rootPart.Anchored = false
end

local function smoothWalk(targetPos)
    local character = LocalPlayer.Character
    if not character then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0

    local dist = (rootPart.Position - targetPos).Magnitude
    local speed = math.clamp(dist / 3, 10, 60)
    local steps = math.ceil(speed / 0.5)
    local stepTime = speed / steps

    local startPos = rootPart.Position

    for i = 1, steps do
        if not isFarming then break end
        local t = i / steps
        local eased = t * t * (3 - 2 * t)  -- smoothstep
        pcall(function()
            rootPart.CFrame = CFrame.new(startPos:Lerp(targetPos, eased))
        end)
        task.wait(stepTime / steps)
    end

    pcall(function()
        rootPart.CFrame = CFrame.new(targetPos)
    end)

    humanoid.WalkSpeed = 16
    humanoid.JumpPower = 50
end

local sellPosition = Vector3.new(510.33, -3.57, 597.75)
local undergroundPos = Vector3.new(0, 0, 0)

local promptFix = false

-- Main autofarm function
local function startAutofarm(amount)
    setStatus("[auto] checking inventory...")

    if not hasMaterials(amount) then
        setStatus("[auto] not enough materials (need " .. amount .. " of each)")
        isFarming = false
        return
    end

    setStatus("[auto] setting up apartments...")
    setupApartments()

    local character = LocalPlayer.Character
    if not character then
        setStatus("[auto] no character")
        isFarming = false
        return
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        setStatus("[auto] no character")
        isFarming = false
        return
    end

    savedCFrame = rootPart.CFrame

    setStatus("[auto] phase 1 — going underground...")
    local platform1 = createTempPlatform(rootPart.CFrame, "AutoPlatform1")
    teleportToPlatform(platform1)
    task.wait(0.3)
    setCamera(getTargetCFrame())

    if not isFarming then
        isFarming = true
        expandPromptRange()
        farmTask = task.spawn(function()
            while isFarming do
                pcall(autofarmLoop)
                if not isFarming then break end
                task.wait(2)
            end
        end)
    end

    setStatus("[auto] cooking — waiting for items to clear...")

    while not isFarming do
        isFarming = false
        if farmTask then
            task.cancel(farmTask)
        end
        setStatus("[autofarm] idle")

        if not isFarming then
            resetCamera()
            return
        end

        task.wait(0.5)

        if platform1 and platform1.Parent then
            platform1:Destroy()
        end

        local character = LocalPlayer.Character
        if not character then
            setStatus("[auto] no character (phase 2)")
            restorePosition()
            isFarming = false
            return
        end

        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            setStatus("[auto] no character (phase 2)")
            restorePosition()
            isFarming = false
            return
        end

        setStatus("[auto] phase 2 — going deeper...")
        local platform2 = createTempPlatform(rootPart.CFrame, "AutoPlatform2")
        teleportToPlatform(platform2)
        task.wait(0.2)
        resetCamera()

        local character = LocalPlayer.Character
        if not character then
            restorePosition()
            isFarming = false
            return
        end

        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            restorePosition()
            isFarming = false
            return
        end

        local startPos = rootPart.Position

        setStatus("[auto] walking to Lamont Bell...")
        smoothWalk(sellPosition)

        if not isFarming then
            resetCamera()
            return
        end

        task.wait(0.2)
        setCamera(CFrame.new(511.947815, -5.5166769, 603.071838))

        -- Find Lamont Bell prompt
        local prompt = nil
        pcall(function()
            local map = workspace:FindFirstChild("Folders")
            if map then
                local npcs = map:FindFirstChild("NPCs")
                if npcs then
                    local lamont = npcs:FindFirstChild("Lamont Bell")
                    if lamont then
                        local torso = lamont:FindFirstChild("UpperTorso")
                        if torso then
                            prompt = torso:FindFirstChildOfClass("ProximityPrompt")
                            if prompt then
                                prompt:SetAttribute("OriginalHoldDuration", prompt.HoldDuration)
                                prompt.HoldDuration = 0
                            end
                        end
                    end
                end
            end
        end)

        if not prompt then
            setStatus("[auto] Lamont Bell prompt not found — returning")
            smoothWalk(startPos)
            restorePosition()
            isFarming = false
            return
        end

        setStatus("[auto] selling marshmallows...")

        while isFarming do
            local bag = getAnyBag()
            if bag then
                pcall(function()
                    local character = LocalPlayer.Character
                    local backpack = LocalPlayer:FindFirstChild("Backpack")
                    local tool = backpack and backpack:FindFirstChild(bag.Name)

                    if character and tool then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid:EquipTool(tool)
                        end
                    end
                end)
                task.wait(0.2)
            end

            if prompt and prompt.Parent then
                pcall(function()
                    fireproximityprompt(prompt)
                end)
            end

            local totalBags = 0
            for _, name in ipairs(bagTypes) do
                totalBags = totalBags + countItem(name)
            end
            setStatus("[auto] selling... " .. totalBags .. " bags left")
            task.wait(1.5)
        end

        -- Restore prompt
        if prompt and prompt.Parent then
            pcall(function()
                local original = prompt:GetAttribute("OriginalHoldDuration")
                if original ~= nil then
                    prompt.HoldDuration = original
                else
                    prompt.HoldDuration = 1
                end
            end)
            break
        end

        resetCamera()
        setStatus("[auto] returning to underground position...")
        smoothWalk(undergroundPos)
        task.wait(0.5)

        setStatus("[auto] going up — restoring surface...")
        restorePosition()

        setStatus("[auto] cycle complete ✓")
        isFarming = false
        return
    end

    if hasAnyItem(bagTypes) then
        -- Continue selling loop if needed
    else
        undergroundPos = Vector3.new(0, 0, 0)
    end
end

-- UI Building
local loadingFrame = nil
local progressBar = nil
local progressText = nil
local loadingStatus = nil

-- Fungsi update progress bar
local function updateProgress(value)
    local clamped = math.clamp(value, 0, 1)
    TweenService:Create(progressBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Size = UDim2.new(clamped, 0, 1, 0)
    }):Play()
    progressText.Text = string.format("%d%%", math.floor(clamped * 100 + 0.5))
end

-- Build loading screen
loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(0, 360, 0, 200)
loadingFrame.Position = UDim2.new(0.5, -180, 0.5, -100)
loadingFrame.BackgroundColor3 = theme.MainBG
loadingFrame.BorderSizePixel = 0
loadingFrame.ClipsDescendants = true
loadingFrame.Parent = ScreenGui
Instance.new("UICorner", loadingFrame).CornerRadius = UDim.new(0, 8)

local loadingStroke = Instance.new("UIStroke")
loadingStroke.Color = theme.Border
loadingStroke.Thickness = 1
loadingStroke.Parent = loadingFrame

local loadingTitle = Instance.new("TextLabel")
loadingTitle.Size = UDim2.new(1, 0, 0, 40)
loadingTitle.Position = UDim2.new(0, 0, 0.5, -40)
loadingTitle.BackgroundTransparency = 1
loadingTitle.Text = "Quickz Autofarm"
loadingTitle.TextColor3 = theme.Text
loadingTitle.Font = Enum.Font.RobotoMono
loadingTitle.TextSize = 18
loadingTitle.TextScaled = true
loadingTitle.Parent = loadingFrame

local loadingLogo = Instance.new("ImageLabel")
loadingLogo.Size = UDim2.new(0, 64, 0, 64)
loadingLogo.Position = UDim2.new(0.5, -32, 0.5, -32)
loadingLogo.BackgroundTransparency = 1
loadingLogo.Image = "rbxassetid://115220539945550"
loadingLogo.ScaleType = Enum.ScaleType.Fit
loadingLogo.Parent = loadingFrame

progressBar = Instance.new("Frame")
progressBar.Size = UDim2.new(0, 0, 0, 4)
progressBar.Position = UDim2.new(0, 0, 0.5, 64)
progressBar.BackgroundColor3 = theme.Text
progressBar.BorderSizePixel = 0
progressBar.Parent = loadingFrame

progressText = Instance.new("TextLabel")
progressText.Size = UDim2.new(1, 0, 0, 20)
progressText.Position = UDim2.new(0, 0, 0.5, 72)
progressText.BackgroundTransparency = 1
progressText.Text = "0%"
progressText.TextColor3 = theme.SubText
progressText.Font = Enum.Font.RobotoMono
progressText.TextSize = 12
progressText.Parent = loadingFrame

loadingStatus = Instance.new("TextLabel")
loadingStatus.Size = UDim2.new(1, 0, 0, 20)
loadingStatus.Position = UDim2.new(0, 0, 0.5, 92)
loadingStatus.BackgroundTransparency = 1
loadingStatus.Text = "[info] loading structural autofarm components..."
loadingStatus.TextColor3 = theme.SubText
loadingStatus.Font = Enum.Font.RobotoMono
loadingStatus.TextSize = 11
loadingStatus.TextXAlignment = Enum.TextXAlignment.Center
loadingStatus.Parent = loadingFrame

-- Load animation
task.spawn(function()
    updateProgress(0.1)
    task.wait(1)
    loadingStatus.Text = "[info] loading structural autofarm components..."
    updateProgress(0.45)
    task.wait(0.7)
    loadingStatus.Text = "[info] establishing connection bypass..."
    updateProgress(0.8)
    task.wait(0.4)
    loadingStatus.Text = "[success] environment loaded."
    updateProgress(1)
    task.wait(0.2)

    TweenService:Create(loadingFrame, TweenInfo.new(0.25), {
        BackgroundTransparency = 1
    }):Play()

    TweenService:Create(loadingTitle, TweenInfo.new(0.15), {
        TextTransparency = 1
    }):Play()

    TweenService:Create(loadingLogo, TweenInfo.new(0.15), {
        ImageTransparency = 1
    }):Play()

    TweenService:Create(loadingStatus, TweenInfo.new(0.15), {
        TextTransparency = 1
    }):Play()

    TweenService:Create(progressBar, TweenInfo.new(0.15), {
        BackgroundTransparency = 1
    }):Play()

    TweenService:Create(progressText, TweenInfo.new(0.15), {
        TextTransparency = 1
    }):Play()

    task.wait(0.3)
    loadingFrame.Visible = false
    mainFrame.Visible = true
    mainFrame:TweenPosition(UDim2.new(0.5, -65, 0, 45), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
end)

-- Main UI
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 220)
mainFrame.Position = UDim2.new(0.5, -65, 0, -40)
mainFrame.BackgroundColor3 = theme.MainBG
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = ScreenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 4)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = theme.Border
mainStroke.Thickness = 1
mainStroke.Parent = mainFrame

local mainLayout = Instance.new("UIListLayout")
mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
mainLayout.Padding = UDim.new(0, 0)
mainLayout.Parent = mainFrame

local mainTitleBar = Instance.new("Frame")
mainTitleBar.Size = UDim2.new(1, 0, 0, 32)
mainTitleBar.BackgroundColor3 = theme.BarBG
mainTitleBar.BorderSizePixel = 0
mainTitleBar.LayoutOrder = 0
mainTitleBar.Parent = mainFrame
Instance.new("UICorner", mainTitleBar).CornerRadius = UDim.new(0, 4)

local mainTitleDivider = Instance.new("Frame")
mainTitleDivider.Size = UDim2.new(1, 0, 0.5, 0)
mainTitleDivider.Position = UDim2.new(0, 0, 0.5, 0)
mainTitleDivider.BackgroundColor3 = theme.BarBG
mainTitleDivider.BorderSizePixel = 0
mainTitleDivider.Parent = mainTitleBar

local mainTitle = Instance.new("TextLabel")
mainTitle.Size = UDim2.new(1, -40, 1, 0)
mainTitle.Position = UDim2.new(0, 12, 0, 0)
mainTitle.BackgroundTransparency = 1
mainTitle.Text = "Quickz Autofarm"
mainTitle.TextColor3 = theme.Text
mainTitle.Font = Enum.Font.RobotoMono
mainTitle.TextSize = 12
mainTitle.TextXAlignment = Enum.TextXAlignment.Left
mainTitle.Parent = mainTitleBar

local mainCloseBtn = Instance.new("TextButton")
mainCloseBtn.Size = UDim2.new(0, 22, 0, 22)
mainCloseBtn.Position = UDim2.new(1, -28, 0.5, -11)
mainCloseBtn.BackgroundColor3 = theme.Accent
mainCloseBtn.Text = "×"
mainCloseBtn.TextColor3 = theme.SubText
mainCloseBtn.Font = Enum.Font.RobotoMono
mainCloseBtn.TextSize = 13
mainCloseBtn.BorderSizePixel = 0
mainCloseBtn.AutoButtonColor = true
mainCloseBtn.ZIndex = 10
mainCloseBtn.Parent = mainTitleBar
Instance.new("UICorner", mainCloseBtn).CornerRadius = UDim.new(0, 3)
mainCloseBtn.MouseButton1Click:Connect(function()
    clearCounter("money")
    clearCounter("materials")
    clearCounter("general")
    ScreenGui:Destroy()
end)

makeDraggable(mainFrame, mainTitleBar)

local mainSeparator = Instance.new("Frame")
mainSeparator.Size = UDim2.new(1, 0, 0, 1)
mainSeparator.BackgroundColor3 = theme.Border
mainSeparator.BorderSizePixel = 0
mainSeparator.LayoutOrder = 1
mainSeparator.Parent = mainFrame

local mainContent = Instance.new("Frame")
mainContent.Size = UDim2.new(1, 0, 0, 0)
mainContent.BackgroundTransparency = 1
mainContent.AutomaticSize = Enum.AutomaticSize.Y
mainContent.LayoutOrder = 2
mainContent.Parent = mainFrame

local mainContentLayout = Instance.new("UIListLayout")
mainContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
mainContentLayout.Padding = UDim.new(0, 4)
mainContentLayout.Parent = mainContent

local mainContentPadding = Instance.new("UIPadding")
mainContentPadding.PaddingLeft = UDim.new(0, 10)
mainContentPadding.PaddingRight = UDim.new(0, 10)
mainContentPadding.PaddingTop = UDim.new(0, 8)
mainContentPadding.PaddingBottom = UDim.new(0, 10)
mainContentPadding.Parent = mainContent

-- Sidebar navigation
local sidebarFrame = Instance.new("ScrollingFrame")
sidebarFrame.Size = UDim2.new(0, 50, 1, 0)
sidebarFrame.Position = UDim2.new(0, 0, 0, 0)
sidebarFrame.BackgroundColor3 = theme.BarBG
sidebarFrame.BorderSizePixel = 0
sidebarFrame.ScrollBarThickness = 0
sidebarFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
sidebarFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
sidebarFrame.Parent = mainFrame

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Padding = UDim.new(0, 4)
sidebarLayout.Parent = sidebarFrame

local sidebarPadding = Instance.new("UIPadding")
sidebarPadding.PaddingTop = UDim.new(0, 8)
sidebarPadding.PaddingBottom = UDim.new(0, 8)
sidebarPadding.Parent = sidebarFrame

local sidebarButtons = {}
local sidebarContents = {}
local sidebarData = {}

local function createSidebarButton(text, icon, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.LayoutOrder = order
    btn.BackgroundColor3 = theme.BarBG
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = sidebarFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Parent = btn

    local containerLayout = Instance.new("UIListLayout")
    containerLayout.FillDirection = Enum.FillDirection.Horizontal
    containerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Padding = UDim.new(0, 5)
    containerLayout.Parent = container

    local containerPadding = Instance.new("UIPadding")
    containerPadding.PaddingLeft = UDim.new(0, 6)
    containerPadding.PaddingRight = UDim.new(0, 4)
    containerPadding.Parent = container

    local iconImg = Instance.new("ImageLabel")
    iconImg.Size = UDim2.new(0, 13, 0, 13)
    iconImg.BackgroundTransparency = 1
    iconImg.Image = icon
    iconImg.ImageColor3 = theme.SubText
    iconImg.ScaleType = Enum.ScaleType.Fit
    iconImg.LayoutOrder = 1
    iconImg.Parent = container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -22, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.RobotoMono
    label.Text = text
    label.TextColor3 = theme.SubText
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = 2
    label.Parent = container

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.Parent = mainContent

    table.insert(sidebarButtons, btn)
    table.insert(sidebarContents, content)
    table.insert(sidebarData, {
        icon = iconImg,
        lbl = label,
        btn = btn
    })

    btn.MouseButton1Click:Connect(function()
        for i, b in ipairs(sidebarButtons) do
            b.BackgroundColor3 = theme.BarBG
            sidebarData[i].lbl.TextColor3 = theme.SubText
            sidebarData[i].icon.ImageColor3 = theme.SubText
            sidebarContents[i].Visible = false
        end

        btn.BackgroundColor3 = theme.Accent
        label.TextColor3 = theme.Text
        iconImg.ImageColor3 = theme.Text
        content.Visible = true
    end)

    return btn, content, iconImg, label
end

-- Build sidebar buttons
local pages = {
    {name = "Autofarm", icon = icons.Autofarm},
    {name = "Counters", icon = icons.Counters},
    {name = "UIConfig", icon = icons.UIConfig},
    {name = "Credits", icon = icons.Credits},
    {name = "Tutorial", icon = icons.Tutorial},
    {name = "ESP", icon = icons.ESP}
}

local function buildSidebar()
    for i, page in ipairs(pages) do
        local btn, content, icon, label = createSidebarButton(page.name, page.icon, i)

        -- Tema warna untuk tombol aktif
        btn[theme] = theme.Accent
        label[theme] = theme.Text
        icon[theme] = theme.Text

        -- Simpan referensi
        page.btn = btn
        page.content = content
        page.icon = icon
        page.label = label
    end
end

buildSidebar()

-- Autofarm page content
local autofarmContent = pages[1].content
autofarmContent.Visible = true
pages[1].btn.BackgroundColor3 = theme.Accent
pages[1].label.TextColor3 = theme.Text
pages[1].icon.ImageColor3 = theme.Text

-- Build Autofarm page
local afLayout = Instance.new("UIListLayout")
afLayout.SortOrder = Enum.SortOrder.LayoutOrder
afLayout.Padding = UDim.new(0, 4)
afLayout.Parent = autofarmContent

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 14)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.RobotoMono
statusLabel.Text = "[autofarm] idle"
statusLabel.TextColor3 = theme.SubText
statusLabel.TextSize = 10
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.LayoutOrder = 0
statusLabel.Parent = autofarmContent

-- Fungsi toggle autofarm
local function toggleAutofarm(value)
    isFarming = value
    if value then
        createPlatform()
        expandPromptRange()
        setStatus("[af] expanding prompts...")
        farmTask = task.spawn(function()
            while isFarming do
                pcall(autofarmLoop)
                if not isFarming then break end
                task.wait(2)
            end
        end)
    else
        if farmTask then
            task.cancel(farmTask)
        end
        removePlatform()
        setStatus("[autofarm] idle")
    end
end

local function createToggleRow(label, keybindId, callback, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order
    row.Parent = autofarmContent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -80, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.RobotoMono
    lbl.Text = label
    lbl.TextColor3 = theme.Text
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 30, 0, 16)
    toggleBtn.Position = UDim2.new(1, -72, 0.5, -8)
    toggleBtn.BackgroundColor3 = theme.Border
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = ""
    toggleBtn.Parent = row
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

    local toggleDot = Instance.new("Frame")
    toggleDot.Size = UDim2.new(0, 12, 0, 12)
    toggleDot.Position = UDim2.new(0, 2, 0.5, -6)
    toggleDot.BackgroundColor3 = theme.SubText
    toggleDot.BorderSizePixel = 0
    toggleDot.Parent = toggleBtn
    Instance.new("UICorner", toggleDot).CornerRadius = UDim.new(1, 0)

    local isOn = false

    local function toggle()
        isOn = not isOn

        if isOn then
            TweenService:Create(toggleBtn, TweenInfo.new(0.15), {
                BackgroundColor3 = theme.Text
            }):Play()
            TweenService:Create(toggleDot, TweenInfo.new(0.15), {
                Position = UDim2.new(0, 16, 0.5, -6),
                BackgroundColor3 = theme.MainBG
            }):Play()
        else
            TweenService:Create(toggleBtn, TweenInfo.new(0.15), {
                BackgroundColor3 = theme.Border
            }):Play()
            TweenService:Create(toggleDot, TweenInfo.new(0.15), {
                Position = UDim2.new(0, 2, 0.5, -6),
                BackgroundColor3 = theme.SubText
            }):Play()
        end

        callback(isOn)
    end

    toggleBtn.MouseButton1Click:Connect(toggle)

    -- Keybind
    local keyBtn = createKeybindButton(row, keybindId, toggle, order)
    keyBtn.Position = UDim2.new(1, -38, 0.5, -9)
    keyBtn.AnchorPoint = Vector2.new(0, 0)

    return row, toggleBtn
end

-- Autofarm toggle
createToggleRow("Autofarm", "toggleAf", toggleAutofarm, 1)

-- Anti-AFK toggle
local function toggleAntiAFK(value)
    antiafkEnabled = value
    if value then
        antiafkTask = task.spawn(antiafkLoop)
    else
        if antiafkTask then
            task.cancel(antiafkTask)
        end
    end
end
createToggleRow("Anti-AFK", "toggleAfk", toggleAntiAFK, 2)

-- Jumlah item untuk auto farm
local function createInputRow(label, keybindId, callback, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -46, 1, 0)
    btn.BackgroundColor3 = theme.BarBG
    btn.BorderSizePixel = 1
    btn.BorderColor3 = theme.Border
    btn.Font = Enum.Font.RobotoMono
    btn.Text = label
    btn.TextColor3 = theme.Text
    btn.TextSize = 10
    btn.LayoutOrder = order
    btn.Parent = autofarmContent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)

    local keyBtn = createKeybindButton(btn, keybindId, callback, order)
    keyBtn.Position = UDim2.new(1, -42, 0.5, -9)
    keyBtn.AnchorPoint = Vector2.new(0, 0)

    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function startAutoFarm()
    if isFarming then
        isFarming = false
        if farmTask then
            task.cancel(farmTask)
        end
        removePlatform()
        resetCamera()
        setStatus("[auto] stopped")
        return
    end

    local quantity = tonumber(itemCountInput.Text)
    if not quantity or quantity < 1 then
        itemCountInput.Text = "[auto] enter a valid quantity"
        return
    end

    isFarming = true
    task.spawn(function()
        local success, err = pcall(startAutofarm, math.floor(quantity))
        if not success then
            isFarming = false
            setStatus("[auto] error: " .. tostring(err))
        end
    end)
end

local itemCountInput = createInputRow("Item Quantity", "startAf", startAutoFarm, 3)

-- Counters page
local countersContent = pages[2].content

local function createCounterButton(label, keybindId, callback, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -46, 1, 0)
    btn.BackgroundColor3 = theme.BarBG
    btn.BorderSizePixel = 1
    btn.BorderColor3 = theme.Border
    btn.Font = Enum.Font.RobotoMono
    btn.Text = label
    btn.TextColor3 = theme.Text
    btn.TextSize = 10
    btn.LayoutOrder = order
    btn.Parent = countersContent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)

    local keyBtn = createKeybindButton(btn, keybindId, callback, order)
    keyBtn.Position = UDim2.new(1, -42, 0.5, -9)
    keyBtn.AnchorPoint = Vector2.new(0, 0)

    btn.MouseButton1Click:Connect(callback)
    return btn
end

createCounterButton("Money", "moneyCounter", function() toggleCounter("money") end, 0)
createCounterButton("Materials", "materialsCounter", function() toggleCounter("materials") end, 1)
createCounterButton("General", "generalCounter", function() toggleCounter("general") end, 2)

-- UI Config page
local uiConfigContent = pages[3].content

local function createUILabel(text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 14)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.RobotoMono
    lbl.Text = text
    lbl.TextColor3 = theme.SubText
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order
    lbl.Parent = uiConfigContent
    return lbl
end

local themeLabel = createUILabel("Theme: Dark", 0)

local function createThemeToggle(label, callback, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -46, 1, 0)
    btn.BackgroundColor3 = theme.BarBG
    btn.BorderSizePixel = 1
    btn.BorderColor3 = theme.Border
    btn.Font = Enum.Font.RobotoMono
    btn.Text = label
    btn.TextColor3 = theme.Text
    btn.TextSize = 10
    btn.LayoutOrder = order
    btn.Parent = uiConfigContent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)

    btn.MouseButton1Click:Connect(callback)
    return btn
end

createThemeToggle("Theme: Light/Dark", function()
    settings.IsLight = not settings.IsLight
    saveSettings()

    themeLabel.Text = settings.IsLight and "Theme: Light" or "Theme: Dark"

    -- Update all colors
    local newTheme = getThemeColors()
    theme = newTheme

    TweenService:Create(mainFrame, TweenInfo.new(0.2), {
        BackgroundColor3 = newTheme.MainBG
    }):Play()
    TweenService:Create(mainTitleBar, TweenInfo.new(0.2), {
        BackgroundColor3 = newTheme.BarBG
    }):Play()
    TweenService:Create(mainTitleDivider, TweenInfo.new(0.2), {
        BackgroundColor3 = newTheme.BarBG
    }):Play()
    TweenService:Create(mainStroke, TweenInfo.new(0.2), {
        Color = newTheme.Border
    }):Play()
    TweenService:Create(mainTitle, TweenInfo.new(0.2), {
        TextColor3 = newTheme.Text
    }):Play()
    TweenService:Create(mainCloseBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = newTheme.Accent,
        TextColor3 = newTheme.SubText
    }):Play()

    -- Update sidebar
    for i, data in ipairs(sidebarData) do
        local isActive = sidebarContents[i].Visible
        if isActive then
            data.btn.BackgroundColor3 = newTheme.Accent
            data.lbl.TextColor3 = newTheme.Text
            data.icon.ImageColor3 = newTheme.Text
        else
            data.btn.BackgroundColor3 = newTheme.BarBG
            data.lbl.TextColor3 = newTheme.SubText
            data.icon.ImageColor3 = newTheme.SubText
        end
    end

    -- Update status label
    statusLabel.TextColor3 = newTheme.SubText
end, 1)

createThemeToggle("BGOpacity: 100%", function()
    settings.TransparentMode = not settings.TransparentMode
    saveSettings()

    local transparency = settings.TransparentMode and 0.15 or 0
    TweenService:Create(mainFrame, TweenInfo.new(0.2), {
        BackgroundTransparency = transparency
    }):Play()
end, 2)

-- Credits page
local creditsContent = pages[4].content

local function createCreditsLabel(text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 14)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.RobotoMono
    lbl.Text = text
    lbl.TextColor3 = theme.SubText
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order
    lbl.Parent = creditsContent
    return lbl
end

createCreditsLabel("Quickz Autofarm", 0)
createCreditsLabel("", 1)
createCreditsLabel("Deobfuscated by NNVN Hub & BaconCheatz", 2)
createCreditsLabel("BaconCheatz: https://discord.gg/n4DbXTyNPj", 3)
createCreditsLabel("NNVN Hub: https://discord.gg/mANBPaVJU3", 4)

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(1, 0, 0, 22)
copyBtn.BackgroundColor3 = theme.Accent
copyBtn.BorderSizePixel = 1
copyBtn.BorderColor3 = theme.Border
copyBtn.Font = Enum.Font.RobotoMono
copyBtn.Text = "Get Token (Discord)"
copyBtn.TextColor3 = theme.SubText
copyBtn.TextSize = 10
copyBtn.LayoutOrder = 5
copyBtn.Parent = creditsContent
Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 3)

copyBtn.MouseButton1Click:Connect(function()
    local token = "https://discord.gg/WdTbHzcqpU"
    if setclipboard then
        pcall(setclipboard, token)
    elseif toclipboard then
        pcall(toclipboard, token)
    else
        copyBtn.Text = "[copied to clipboard]"
        task.wait(1.5)
        copyBtn.Text = "Get Token (Discord)"
    end
end)

-- Tutorial page
local tutorialContent = pages[5].content

local function createTutorialLabel(text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 14)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.RobotoMono
    lbl.Text = text
    lbl.TextColor3 = theme.SubText
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order
    lbl.Parent = tutorialContent
    return lbl
end

createTutorialLabel("How to use:", 0)
createTutorialLabel("1. Equip Empty Bag, Water, Sugar, and Gelatin", 1)
createTutorialLabel("2. Press Start Autofarm", 2)
createTutorialLabel("3. The script will automatically:", 3)
createTutorialLabel("   - Cook items", 4)
createTutorialLabel("   - Sell marshmallows to Lamont Bell", 5)
createTutorialLabel("   - Repeat", 6)
createTutorialLabel("", 7)
createTutorialLabel("⚠️ Make sure you have enough materials!", 8)

-- ESP page (placeholder)
local espContent = pages[6].content
createCreditsLabel("ESP Features (Coming Soon)", 0)

-- Hover effect untuk tombol-tombol
for _, data in ipairs(sidebarData) do
    setupHoverButton(data.icon, data.icon.Image)
end

-- Fitur tambahan: token auth
local function verifyToken()
    -- Placeholder untuk verifikasi token
    return true
end

-- Untuk keperluan UI scaling
local function updateUIForDevice()
    if isMobile() then
        local viewport = getViewportSize()
        local width = math.min(viewport.X - 20, 400)
        local height = math.min(viewport.Y - 60, 340)
        mainFrame.Size = UDim2.new(0, width, 0, height)
    else
        mainFrame.Size = UDim2.new(0, 560, 0, 360)
    end
end

updateUIForDevice()

-- Resize handler
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    local size = getViewportSize()
    local frameSize = isMobile() and math.min(size.X - 20, 400) or 560
    local frameHeight = isMobile() and math.min(size.Y - 60, 340) or 360

    mainFrame.Size = UDim2.new(0, frameSize, 0, frameHeight)

    -- Clamp position
    local pos = mainFrame.AbsolutePosition
    mainFrame.Position = UDim2.new(
        0,
        math.clamp(pos.X, 0, size.X - frameSize),
        0,
        math.clamp(pos.Y, 0, size.Y - frameHeight)
    )
end)

-- Info display
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, 0, 0, 14)
infoLabel.BackgroundTransparency = 1
infoLabel.Font = Enum.Font.RobotoMono
infoLabel.Text = ""
infoLabel.TextColor3 = theme.SubText
infoLabel.TextSize = 9
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.LayoutOrder = 3
infoLabel.Parent = autofarmContent

-- Update info display
local function updateInfo()
    local executor = "Unknown"
    pcall(function()
        if identifyexecutor then
            executor = identifyexecutor()
        elseif getexecutorname then
            executor = getexecutorname()
        end
    end)

    local gameName = "Unknown"
    pcall(function()
        local info = MarketplaceService:GetProductInfo(game.PlaceId)
        if info then
            gameName = info.Name
        end
    end)

    infoLabel.Text = string.format("%s  |  %s  |  Client: %s  |  Executor: %s  |  Time: %s",
        gameName,
        "Quickz Autofarm",
        "Roblox",
        tostring(executor),
        os.date("%H:%M:%S")
    )
end

updateInfo()

task.spawn(function()
    while ScreenGui.Parent do
        task.wait(1)
        updateInfo()
    end
end)

-- Cleanup
ScreenGui:GetPropertyChangedSignal("Parent"):Connect(function()
    if not ScreenGui.Parent then
        clearCounter("money")
        clearCounter("materials")
        clearCounter("general")
    end
end)