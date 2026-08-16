--[[
  ██████  QUICKZ AUTOFARM – ORIGINAL (NO KEY)  ██████
  Semua fitur asli, tanpa verifikasi token.
  Deobfuscated & cleaned by request.
]]

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 15)
local tweenService = game:GetService("TweenService")
local userInput = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local httpService = game:GetService("HttpService")

-- ============================================================
-- SETTINGS (load/save)
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
-- THEME
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
-- 1. HAPUS BANGUNAN BAWAH (seperti asli)
-- ============================================================
local function deleteUnderBuildingParts()
    local map = workspace:FindFirstChild("Map")
    if not map then return end

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
                    local interior = apt:FindFirstChild("Interior")
                    if interior then
                        for _, child in ipairs(interior:GetChildren()) do
                            if not child:IsA("ProximityPrompt") and child.Name ~= "Cooking Pot" then
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
                                for _, obj in ipairs(interior:GetChildren()) do
                                    if not obj:IsA("ProximityPrompt") and obj.Name ~= "Cooking Pot" then
                                        obj:Destroy()
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end

-- ============================================================
-- 2. EXPAND PROMPT (MaxActivationDistance = 9999)
-- ============================================================
local function expandAllPrompts()
    local map = workspace:FindFirstChild("Map")
    if not map then return end

    local function scan(obj)
        for _, prompt in ipairs(obj:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                pcall(function()
                    prompt.MaxActivationDistance = 9999
                    prompt.RequiresLineOfSight = false
                end)
            end
        end
    end

    local houses = map:FindFirstChild("Houses")
    if houses then
        local wh1 = houses:FindFirstChild("WH1")
        if wh1 then
            local interior = wh1:FindFirstChild("Interior")
            if interior then scan(interior) end
        end
    end

    local apartments = map:FindFirstChild("Apartments")
    if apartments then
        for _, aptFolder in ipairs(apartments:GetChildren()) do
            pcall(function()
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
            end)
        end
    end
end

-- ============================================================
-- 3. AMBIL SEMUA PROMPT DARI COOKING POT
-- ============================================================
local function getAllCookingPrompts()
    local prompts = {}
    local map = workspace:FindFirstChild("Map")
    if not map then return prompts end

    local function scan(obj)
        for _, child in ipairs(obj:GetDescendants()) do
            if child:IsA("ProximityPrompt") and child.Parent and child.Parent.Name == "Cooking Pot" then
                table.insert(prompts, child)
            end
        end
    end

    local houses = map:FindFirstChild("Houses")
    if houses then
        local wh1 = houses:FindFirstChild("WH1")
        if wh1 then
            local interior = wh1:FindFirstChild("Interior")
            if interior then scan(interior) end
        end
    end

    local apartments = map:FindFirstChild("Apartments")
    if apartments then
        for _, aptFolder in ipairs(apartments:GetChildren()) do
            pcall(function()
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
            end)
        end
    end

    return prompts
end

-- ============================================================
-- 4. FIRE PROMPT
-- ============================================================
local function fireAllPrompts()
    local prompts = getAllCookingPrompts()
    for _, prompt in ipairs(prompts) do
        pcall(function() fireproximityprompt(prompt) end)
        task.wait(0.05)
    end
end

-- ============================================================
-- 5. UNDERGROUND PLATFORM
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

player.CharacterRemoving:Connect(function()
    if platformPart and platformPart.Parent then platformPart:Destroy() end
    undergroundActive = false
    savedCFrame = nil
    platformPart = nil
end)

-- ============================================================
-- 6. UTILITY FUNCTIONS
-- ============================================================
local function hasItem(name)
    local bp = player:FindFirstChild("Backpack")
    local char = player.Character
    if bp and bp:FindFirstChild(name) then return true end
    if char and char:FindFirstChild(name) then return true end
    return false
end

local function equipTool(name)
    local bp = player:FindFirstChild("Backpack")
    local char = player.Character
    local tool = bp and bp:FindFirstChild(name)
    if not tool then return false end
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    pcall(function() humanoid:EquipTool(tool) end)
    for _ = 1, 20 do
        if char and char:FindFirstChild(name) then return true end
        task.wait(0.05)
    end
    return false
end

local function countItem(name)
    local count = 0
    local bp = player:FindFirstChild("Backpack")
    local char = player.Character
    if bp then
        for _, child in ipairs(bp:GetChildren()) do
            if child.Name == name then count = count + 1 end
        end
    end
    if char then
        for _, child in ipairs(char:GetChildren()) do
            if child.Name == name then count = count + 1 end
        end
    end
    return count
end

-- ============================================================
-- 7. COUNTERS (money, materials, general)
-- ============================================================
local counters = { money = nil, materials = nil, general = nil }

local function toggleCounter(type)
    if counters[type] and counters[type].Parent then
        counters[type]:Destroy()
        counters[type] = nil
        return
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "QuickzCounter_" .. type
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999
    pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if not gui.Parent then gui.Parent = playerGui end
    counters[type] = gui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 0)
    frame.Position = UDim2.new(type == "money" and 0.41 or 0.6, 0, 0.38, 0)
    frame.BackgroundColor3 = colors.MainBG
    frame.BorderSizePixel = 0
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    local stroke = Instance.new("UIStroke")
    stroke.Color = colors.Border
    stroke.Thickness = 1
    stroke.Parent = frame

    local title = Instance.new("Frame")
    title.Size = UDim2.new(1, 0, 0, 32)
    title.BackgroundColor3 = colors.BarBG
    title.BorderSizePixel = 0
    title.Parent = frame
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 4)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -40, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = (type == "money" and "Money Counter" or type == "materials" and "Materials Counter" or "General Counter")
    lbl.TextColor3 = colors.Text
    lbl.Font = Enum.Font.RobotoMono
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = title

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 22, 0, 22)
    close.Position = UDim2.new(1, -28, 0.5, -11)
    close.BackgroundColor3 = colors.Accent
    close.Text = "×"
    close.TextColor3 = colors.SubText
    close.Font = Enum.Font.RobotoMono
    close.TextSize = 13
    close.BorderSizePixel = 0
    close.AutoButtonColor = true
    close.ZIndex = 10
    close.Parent = title
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 3)
    close.MouseButton1Click:Connect(function() toggleCounter(type) end)

    -- drag
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

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.BackgroundTransparency = 1
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Parent = frame
    local cLayout = Instance.new("UIListLayout")
    cLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cLayout.Padding = UDim.new(0, 3)
    cLayout.Parent = content
    local cPadding = Instance.new("UIPadding")
    cPadding.PaddingLeft = UDim.new(0, 10)
    cPadding.PaddingRight = UDim.new(0, 10)
    cPadding.PaddingTop = UDim.new(0, 8)
    cPadding.PaddingBottom = UDim.new(0, 10)
    cPadding.Parent = content

    if type == "general" then
        local function makeRow(labelText, order)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 20)
            row.BackgroundTransparency = 1
            row.LayoutOrder = order
            row.Parent = content
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(0.6, 0, 1, 0)
            l.BackgroundTransparency = 1
            l.Text = labelText
            l.TextColor3 = colors.SubText
            l.Font = Enum.Font.RobotoMono
            l.TextSize = 10
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Parent = row
            local val = Instance.new("TextLabel")
            val.Size = UDim2.new(0.4, 0, 1, 0)
            val.Position = UDim2.new(0.6, 0, 0, 0)
            val.BackgroundTransparency = 1
            val.Text = "0"
            val.TextColor3 = colors.Text
            val.Font = Enum.Font.RobotoMono
            val.TextSize = 10
            val.TextXAlignment = Enum.TextXAlignment.Right
            val.Parent = row
            return val
        end
        local farmTime = makeRow("Farm Time", 0)
        local bagsSession = makeRow("Bags (session)", 1)
        local bagsTotal = makeRow("Bags (total)", 2)

        local resetBtn = Instance.new("TextButton")
        resetBtn.Size = UDim2.new(1, 0, 0, 22)
        resetBtn.BackgroundColor3 = colors.Accent
        resetBtn.BorderSizePixel = 1
        resetBtn.BorderColor3 = colors.Border
        resetBtn.Font = Enum.Font.RobotoMono
        resetBtn.Text = "Reset Counter"
        resetBtn.TextColor3 = colors.SubText
        resetBtn.TextSize = 10
        resetBtn.LayoutOrder = 3
        resetBtn.Parent = content
        Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 3)

        local startTime = tick()
        local sessionBags = 0
        local totalBags = 0
        local lastCount = countItem("Small Marshmallow Bag") + countItem("Medium Marshmallow Bag") + countItem("Large Marshmallow Bag")

        local function updateGeneral()
            local currentBags = countItem("Small Marshmallow Bag") + countItem("Medium Marshmallow Bag") + countItem("Large Marshmallow Bag")
            if lastCount > 0 and currentBags > lastCount then
                local diff = currentBags - lastCount
                sessionBags = sessionBags + diff
                totalBags = totalBags + diff
            end
            lastCount = currentBags
            farmTime.Text = string.format("%02d:%02d", math.floor((tick() - startTime) / 60), math.floor((tick() - startTime) % 60))
            bagsSession.Text = tostring(sessionBags)
            bagsTotal.Text = tostring(totalBags)
        end

        resetBtn.MouseButton1Click:Connect(function()
            startTime = tick()
            sessionBags = 0
            totalBags = 0
            lastCount = countItem("Small Marshmallow Bag") + countItem("Medium Marshmallow Bag") + countItem("Large Marshmallow Bag")
        end)

        local conn = runService.Heartbeat:Connect(function(dt)
            local elapsed = 0
            elapsed = elapsed + dt
            if elapsed >= 0.5 then
                elapsed = 0
                pcall(updateGeneral)
            end
        end)
        gui:SetAttribute("conn", conn)

    elseif type == "money" or type == "materials" then
        local itemList = type == "money" and {
            { short = "Small Bag", full = "Small Marshmallow Bag" },
            { short = "Medium Bag", full = "Medium Marshmallow Bag" },
            { short = "Large Bag", full = "Large Marshmallow Bag" }
        } or {
            { short = "Water", full = "Water" },
            { short = "Gelatin", full = "Gelatin" },
            { short = "Sugar Bag", full = "Sugar Block Bag" }
        }

        local labels = {}
        for i, data in ipairs(itemList) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 18)
            row.BackgroundTransparency = 1
            row.LayoutOrder = i - 1
            row.Parent = content
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(0.62, 0, 1, 0)
            l.BackgroundTransparency = 1
            l.Text = data.short
            l.TextColor3 = colors.SubText
            l.Font = Enum.Font.RobotoMono
            l.TextSize = 10
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.TextTruncate = Enum.TextTruncate.AtEnd
            l.Parent = row
            local val = Instance.new("TextLabel")
            val.Size = UDim2.new(0.38, 0, 1, 0)
            val.Position = UDim2.new(0.62, 0, 0, 0)
            val.BackgroundTransparency = 1
            val.Text = "0"
            val.TextColor3 = colors.Text
            val.Font = Enum.Font.RobotoMono
            val.TextSize = 10
            val.TextXAlignment = Enum.TextXAlignment.Right
            val.Parent = row
            labels[data.short] = { row = row, lbl = l, val = val }
        end

        local totalRow = Instance.new("Frame")
        totalRow.Size = UDim2.new(1, 0, 0, 20)
        totalRow.BackgroundTransparency = 1
        totalRow.LayoutOrder = #itemList + 1
        totalRow.Parent = content
        local totalLbl = Instance.new("TextLabel")
        totalLbl.Size = UDim2.new(0.5, 0, 1, 0)
        totalLbl.BackgroundTransparency = 1
        totalLbl.Text = "TOTAL"
        totalLbl.TextColor3 = colors.Text
        totalLbl.Font = Enum.Font.RobotoMono
        totalLbl.TextSize = 11
        totalLbl.TextXAlignment = Enum.TextXAlignment.Left
        totalLbl.Parent = totalRow
        local totalVal = Instance.new("TextLabel")
        totalVal.Size = UDim2.new(0.5, 0, 1, 0)
        totalVal.Position = UDim2.new(0.5, 0, 0, 0)
        totalVal.BackgroundTransparency = 1
        totalVal.Text = type == "money" and "$0" or "0"
        totalVal.TextColor3 = colors.Text
        totalVal.Font = Enum.Font.RobotoMono
        totalVal.TextSize = 11
        totalVal.TextXAlignment = Enum.TextXAlignment.Right
        totalVal.Parent = totalRow

        local function updateCounter()
            local counts = {}
            for _, data in ipairs(itemList) do
                counts[data.short] = countItem(data.full)
            end
            local total = 0
            for _, data in ipairs(itemList) do
                local count = counts[data.short] or 0
                labels[data.short].val.Text = tostring(count)
                if count == 0 then
                    labels[data.short].lbl.TextColor3 = colors.Border
                    labels[data.short].val.TextColor3 = colors.Border
                else
                    labels[data.short].lbl.TextColor3 = colors.SubText
                    labels[data.short].val.TextColor3 = colors.Text
                end
                if type == "money" then
                    total = total + count * (data.full == "Small Marshmallow Bag" and 1470 or data.full == "Medium Marshmallow Bag" and 2840 or 4150)
                else
                    total = total + count
                end
            end
            totalVal.Text = type == "money" and "$" .. tostring(total) or tostring(total)
        end

        local conn = runService.Heartbeat:Connect(function(dt)
            local elapsed = 0
            elapsed = elapsed + dt
            if elapsed >= 0.5 then
                elapsed = 0
                pcall(updateCounter)
            end
        end)
        gui:SetAttribute("conn", conn)
    end
end

-- ============================================================
-- 8. AUTOFARM LOOP
-- ============================================================
local running = false
local farmTask = nil
local statusLabel = nil
local startBtn = nil
local qtyInput = nil

local function setStatus(text)
    if statusLabel then statusLabel.Text = text end
end

local function waitFor(seconds, label)
    local elapsed = 0
    while running and elapsed < seconds do
        task.wait(0.5)
        elapsed = elapsed + 0.5
        setStatus(string.format("[af] %s — %ds", label, math.ceil(seconds - elapsed)))
    end
end

local function autofarmLoop()
    while running do
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

local function toggleAutofarm()
    if running then
        running = false
        if farmTask then task.cancel(farmTask) end
        goSurface()
        if startBtn then startBtn.Text = "Start Autofarm" end
        return
    end

    local qty = tonumber(qtyInput and qtyInput.Text or "1")
    if not qty or qty < 1 then
        setStatus("[error] enter a valid quantity")
        return
    end

    if countItem("Water") < qty or countItem("Sugar Block Bag") < qty or countItem("Gelatin") < qty then
        setStatus("[auto] not enough materials (need " .. qty .. " of each)")
        return
    end

    running = true
    startBtn.Text = "Stop Autofarm"

    pcall(deleteUnderBuildingParts)
    pcall(expandAllPrompts)
    goUnderground()

    farmTask = task.spawn(autofarmLoop)
end

-- ============================================================
-- 9. MAIN GUI (TABBED – ORIGINAL STYLE)
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "QuickzAutofarm"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 560, 0, 380)
mainFrame.Position = UDim2.new(0.5, -280, 0.5, -190)
mainFrame.BackgroundColor3 = colors.MainBG
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 4)

local border = Instance.new("UIStroke")
border.Color = colors.Border
border.Thickness = 1
border.Parent = mainFrame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = colors.BarBG
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 4)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Quickz Autofarm"
titleLabel.TextColor3 = colors.Text
titleLabel.Font = Enum.Font.RobotoMono
titleLabel.TextSize = 12
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -28, 0.5, -11)
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

-- Drag
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

-- Tab Bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 28)
tabBar.Position = UDim2.new(0, 0, 0, 32)
tabBar.BackgroundColor3 = colors.BarBG
tabBar.BorderSizePixel = 0
tabBar.Parent = mainFrame
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 3)

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 5)
tabLayout.Parent = tabBar

local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingLeft = UDim.new(0, 6)
tabPadding.PaddingRight = UDim.new(0, 4)
tabPadding.Parent = tabBar

local tabContainer = Instance.new("ScrollingFrame")
tabContainer.Size = UDim2.new(1, 0, 1, -60)
tabContainer.Position = UDim2.new(0, 0, 0, 60)
tabContainer.BackgroundTransparency = 1
tabContainer.BorderSizePixel = 0
tabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
tabContainer.ScrollBarThickness = 4
tabContainer.Parent = mainFrame

local tabData = {
    { "Autofarm", "rbxassetid://115220539945550", 1 },
    { "Counters", "rbxassetid://82314355192648", 2 },
    { "UIConfig", "rbxassetid://122422795821505", 3 },
    { "Credits",  "rbxassetid://90589453613903", 4 },
}

local tabs = {}
local tabButtons = {}
local tabContents = {}

local function createTab(name, icon, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 0, 1, 0)
    btn.AutomaticSize = Enum.AutomaticSize.X
    btn.BackgroundColor3 = colors.BarBG
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = tabBar

    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 1, 0)
    holder.BackgroundTransparency = 1
    holder.Parent = btn

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = holder

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(0, 13, 0, 13)
    img.BackgroundTransparency = 1
    img.Image = icon
    img.ImageColor3 = colors.SubText
    img.ScaleType = Enum.ScaleType.Fit
    img.LayoutOrder = 1
    img.Parent = holder

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -22, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.RobotoMono
    lbl.Text = name
    lbl.TextColor3 = colors.SubText
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = 2
    lbl.Parent = holder

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.Parent = tabContainer

    table.insert(tabButtons, btn)
    table.insert(tabContents, content)
    tabs[name] = { btn = btn, content = content, img = img, lbl = lbl }

    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(tabButtons) do t.BackgroundColor3 = colors.BarBG end
        for _, c in ipairs(tabContents) do c.Visible = false end
        for _, t in pairs(tabs) do
            t.img.ImageColor3 = colors.SubText
            t.lbl.TextColor3 = colors.SubText
        end
        btn.BackgroundColor3 = colors.Accent
        content.Visible = true
        img.ImageColor3 = colors.Text
        lbl.TextColor3 = colors.Text
        task.wait()
        tabContainer.CanvasSize = UDim2.new(0, 0, 0, content.AbsoluteContentSize.Y + 20)
    end)
    return content
end

for _, data in ipairs(tabData) do
    createTab(data[1], data[2], data[3])
end

-- Aktifkan tab pertama
local firstTab = tabData[1][1]
tabs[firstTab].btn.BackgroundColor3 = colors.Accent
tabs[firstTab].content.Visible = true
tabs[firstTab].img.ImageColor3 = colors.Text
tabs[firstTab].lbl.TextColor3 = colors.Text

-- ============================================================
-- TAB 1: AUTOFARM
-- ============================================================
local afTab = tabs["Autofarm"].content
local afLayout = Instance.new("UIListLayout")
afLayout.SortOrder = Enum.SortOrder.LayoutOrder
afLayout.Padding = UDim.new(0, 4)
afLayout.Parent = afTab

local afPadding = Instance.new("UIPadding")
afPadding.PaddingLeft = UDim.new(0, 10)
afPadding.PaddingRight = UDim.new(0, 10)
afPadding.PaddingTop = UDim.new(0, 8)
afPadding.PaddingBottom = UDim.new(0, 10)
afPadding.Parent = afTab

local function makeLabel(text, order, color)
    color = color or colors.SubText
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.RobotoMono
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order or 0
    lbl.Parent = afTab
    return lbl
end

statusLabel = makeLabel("[autofarm] idle", 0, colors.Text)

local qtyFrame = Instance.new("Frame")
qtyFrame.Size = UDim2.new(1, 0, 0, 24)
qtyFrame.BackgroundTransparency = 1
qtyFrame.LayoutOrder = 1
qtyFrame.Parent = afTab

local qtyLabel = Instance.new("TextLabel")
qtyLabel.Size = UDim2.new(0.4, 0, 1, 0)
qtyLabel.BackgroundTransparency = 1
qtyLabel.Text = "Quantity:"
qtyLabel.TextColor3 = colors.Text
qtyLabel.Font = Enum.Font.RobotoMono
qtyLabel.TextSize = 11
qtyLabel.TextXAlignment = Enum.TextXAlignment.Left
qtyLabel.Parent = qtyFrame

qtyInput = Instance.new("TextBox")
qtyInput.Size = UDim2.new(0.3, 0, 1, 0)
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
startBtn.Parent = afTab
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 3)
startBtn.MouseButton1Click:Connect(toggleAutofarm)

-- Keybind
local keybindLabel = makeLabel("Keybind: press a key to bind", 3, colors.SubText)
local keybindBtn = Instance.new("TextButton")
keybindBtn.Size = UDim2.new(0, 38, 0, 18)
keybindBtn.BackgroundColor3 = colors.Accent
keybindBtn.BorderSizePixel = 1
keybindBtn.BorderColor3 = colors.Border
keybindBtn.Font = Enum.Font.RobotoMono
keybindBtn.Text = "[-]"
keybindBtn.TextColor3 = colors.SubText
keybindBtn.TextSize = 9
keybindBtn.LayoutOrder = 4
keybindBtn.ZIndex = 5
keybindBtn.Parent = afTab
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

-- ============================================================
-- TAB 2: COUNTERS
-- ============================================================
local counterTab = tabs["Counters"].content
local cLayout = Instance.new("UIListLayout")
cLayout.SortOrder = Enum.SortOrder.LayoutOrder
cLayout.Padding = UDim.new(0, 8)
cLayout.Parent = counterTab
local cPadding = Instance.new("UIPadding")
cPadding.PaddingLeft = UDim.new(0, 10)
cPadding.PaddingRight = UDim.new(0, 10)
cPadding.PaddingTop = UDim.new(0, 8)
cPadding.PaddingBottom = UDim.new(0, 10)
cPadding.Parent = counterTab

local function createCounterButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = colors.Accent
    btn.BorderSizePixel = 1
    btn.BorderColor3 = colors.Border
    btn.Font = Enum.Font.RobotoMono
    btn.Text = text
    btn.TextColor3 = colors.Text
    btn.TextSize = 11
    btn.Parent = counterTab
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

createCounterButton("Show Money Counter", function() toggleCounter("money") end)
createCounterButton("Show Materials Counter", function() toggleCounter("materials") end)
createCounterButton("Show General Counter", function() toggleCounter("general") end)

-- ============================================================
-- TAB 3: UICONFIG
-- ============================================================
local uiTab = tabs["UIConfig"].content
local uiLayout = Instance.new("UIListLayout")
uiLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiLayout.Padding = UDim.new(0, 8)
uiLayout.Parent = uiTab
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingLeft = UDim.new(0, 10)
uiPadding.PaddingRight = UDim.new(0, 10)
uiPadding.PaddingTop = UDim.new(0, 8)
uiPadding.PaddingBottom = UDim.new(0, 10)
uiPadding.Parent = uiTab

local function createToggleButton(text, getter, setter)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = colors.Accent
    btn.BorderSizePixel = 1
    btn.BorderColor3 = colors.Border
    btn.Font = Enum.Font.RobotoMono
    btn.Text = text .. ": " .. (getter() and "ON" or "OFF")
    btn.TextColor3 = colors.Text
    btn.TextSize = 11
    btn.Parent = uiTab
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
    btn.MouseButton1Click:Connect(function()
        setter(not getter())
        btn.Text = text .. ": " .. (getter() and "ON" or "OFF")
        saveSettings()
        colors = getColors()
        -- Refresh UI
        mainFrame.BackgroundColor3 = colors.MainBG
        border.Color = colors.Border
        titleBar.BackgroundColor3 = colors.BarBG
        titleLabel.TextColor3 = colors.Text
        closeBtn.BackgroundColor3 = colors.Accent
        closeBtn.TextColor3 = colors.SubText
        for _, t in ipairs(tabButtons) do
            t.BackgroundColor3 = colors.BarBG
        end
        for _, t in pairs(tabs) do
            t.img.ImageColor3 = colors.SubText
            t.lbl.TextColor3 = colors.SubText
        end
        tabs[firstTab].btn.BackgroundColor3 = colors.Accent
        tabs[firstTab].img.ImageColor3 = colors.Text
        tabs[firstTab].lbl.TextColor3 = colors.Text
        mainFrame.BackgroundTransparency = settings.TransparentMode and 0.15 or 0
    end)
    return btn
end

createToggleButton("Light Theme", function() return settings.IsLight end, function(v) settings.IsLight = v end)
createToggleButton("Transparent BG", function() return settings.TransparentMode end, function(v) settings.TransparentMode = v end)

-- ============================================================
-- TAB 4: CREDITS
-- ============================================================
local credTab = tabs["Credits"].content
local credLayout = Instance.new("UIListLayout")
credLayout.SortOrder = Enum.SortOrder.LayoutOrder
credLayout.Padding = UDim.new(0, 8)
credLayout.Parent = credTab
local credPadding = Instance.new("UIPadding")
credPadding.PaddingLeft = UDim.new(0, 10)
credPadding.PaddingRight = UDim.new(0, 10)
credPadding.PaddingTop = UDim.new(0, 8)
credPadding.PaddingBottom = UDim.new(0, 10)
credPadding.Parent = credTab

local function makeCredLabel(text, order, color)
    color = color or colors.SubText
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.RobotoMono
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order or 0
    lbl.Parent = credTab
    return lbl
end

makeCredLabel("Quickz Autofarm v2.0", 0, colors.Text)
makeCredLabel("Developed by: Quickz", 1, colors.SubText)
makeCredLabel("Discord: discord.gg/WdTbHzcqpU", 2, colors.SubText)

-- ============================================================
-- UPDATE CANVAS SAAT TAB DIKLIK
-- ============================================================
for _, tab in pairs(tabs) do
    local content = tab.content
    tab.btn.MouseButton1Click:Connect(function()
        task.wait()
        tabContainer.CanvasSize = UDim2.new(0, 0, 0, content.AbsoluteContentSize.Y + 20)
    end)
end

print("[AutoFarm] Original script loaded. No key required.")