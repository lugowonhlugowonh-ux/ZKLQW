-- ============================================================
-- AUTOFARM MARSHMALLOW – VERSI SIMPEL & ORIGINAL
-- ============================================================
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 15)

-- Hapus bagian bawah (housed.0052 & collision parts)
local function hapusBawah()
    local map = workspace:FindFirstChild("Map")
    if not map then return end
    local apartments = map:FindFirstChild("Apartments")
    if not apartments then return end
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
            -- cek folder/model
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

-- Expand semua prompt
local function expandPrompt()
    local function scan(obj)
        for _, p in ipairs(obj:GetDescendants()) do
            if p:IsA("ProximityPrompt") then
                pcall(function()
                    p.MaxActivationDistance = 9999
                    p.RequiresLineOfSight = false
                end)
            end
        end
    end
    local map = workspace:FindFirstChild("Map")
    if not map then return end
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

-- Dapatkan prompt dari Cooking Pot
local function getPrompts()
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

local function firePrompts()
    for _, p in ipairs(getPrompts()) do
        pcall(function() fireproximityprompt(p) end)
        task.wait(0.05)
    end
end

-- Underground
local underground = false
local platform = nil
local savedCF = nil

local function goDown()
    if underground then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local p = Instance.new("Part")
    p.Name = "Quickz_Platform"
    p.Size = Vector3.new(40,1,40)
    p.Transparency = 1
    p.Anchored = true
    p.CanCollide = true
    p.CFrame = hrp.CFrame - Vector3.new(0,11,0)
    p.Parent = workspace
    platform = p
    savedCF = hrp.CFrame
    task.wait(0.1)
    hrp.CFrame = p.CFrame + Vector3.new(0,3.5,0)
    underground = true
end

local function goUp()
    if not underground then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if savedCF then hrp.CFrame = savedCF else hrp.CFrame = hrp.CFrame + Vector3.new(0,11,0) end
    if platform and platform.Parent then platform:Destroy() end
    underground = false
    platform = nil
    savedCF = nil
end

player.CharacterRemoving:Connect(function()
    if platform and platform.Parent then platform:Destroy() end
    underground = false
    platform = nil
    savedCF = nil
end)

-- Utility
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
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    pcall(function() hum:EquipTool(tool) end)
    for _=1,20 do
        if char and char:FindFirstChild(name) then return true end
        task.wait(0.05)
    end
    return false
end

local function countItem(name)
    local count=0
    local bp=player:FindFirstChild("Backpack")
    local char=player.Character
    if bp then for _,c in ipairs(bp:GetChildren()) do if c.Name==name then count=count+1 end end end
    if char then for _,c in ipairs(char:GetChildren()) do if c.Name==name then count=count+1 end end end
    return count
end

-- Status
local running = false
local taskHandle = nil
local statusLabel = nil
local startBtn = nil
local qtyInput = nil

local function setStatus(text)
    if statusLabel then statusLabel.Text = text end
end

local function waitFor(sec, label)
    local elapsed=0
    while running and elapsed<sec do
        task.wait(0.5)
        elapsed=elapsed+0.5
        setStatus(string.format("[af] %s — %ds", label, math.ceil(sec-elapsed)))
    end
end

local function loop()
    while running do
        if hasItem("Water") then
            setStatus("[af] equipping Water...")
            if equipTool("Water") then
                task.wait(0.3)
                setStatus("[af] pressing E — Water")
                firePrompts()
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
                firePrompts()
            end
        end
        if not running then break end
        if hasItem("Gelatin") then
            setStatus("[af] equipping Gelatin...")
            if equipTool("Gelatin") then
                task.wait(1)
                if not running then break end
                setStatus("[af] pressing E — Gelatin")
                firePrompts()
            end
        end
        if not running then break end
        if hasItem("Empty Bag") then
            setStatus("[af] equipping Empty Bag...")
            if equipTool("Empty Bag") then
                local elapsed=0
                while running and elapsed<46 do
                    task.wait(0.5)
                    elapsed=elapsed+0.5
                    setStatus(string.format("[af] empty bag — firing in %ds", math.max(0, math.ceil(46-elapsed))))
                end
                if not running then break end
                setStatus("[af] pressing E — Empty Bag (end)")
                firePrompts()
                task.wait(0.5)
                if not running then break end
                if not hasItem("Water") and not hasItem("Sugar Block Bag") and not hasItem("Gelatin") and not hasItem("Empty Bag") then
                    setStatus("[af] no items — retrying...")
                    task.wait(2)
                end
            end
        end
        task.wait(1)
    end
    setStatus("[autofarm] idle")
end

local function toggle()
    if running then
        running = false
        if taskHandle then task.cancel(taskHandle) end
        goUp()
        if startBtn then startBtn.Text = "Start Autofarm" end
        return
    end
    local qty = tonumber(qtyInput and qtyInput.Text or "1")
    if not qty or qty<1 then setStatus("[error] enter valid quantity") return end
    if countItem("Water")<qty or countItem("Sugar Block Bag")<qty or countItem("Gelatin")<qty then
        setStatus("[auto] not enough materials (need "..qty.." each)")
        return
    end
    running = true
    startBtn.Text = "Stop Autofarm"
    pcall(hapusBawah)
    pcall(expandPrompt)
    goDown()
    taskHandle = task.spawn(loop)
end

-- UI Sederhana
local gui = Instance.new("ScreenGui")
gui.Name = "AutoFarm"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,260,0,150)
frame.Position = UDim2.new(0.5,-130,0.5,-75)
frame.BackgroundColor3 = Color3.fromRGB(37,37,38)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,6)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(50,50,52)
title.Text = "AutoFarm"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.RobotoMono
title.TextSize = 14
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0,6)

statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1,-20,0,20)
statusLabel.Position = UDim2.new(0,10,0,40)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "[autofarm] idle"
statusLabel.TextColor3 = Color3.fromRGB(200,200,200)
statusLabel.Font = Enum.Font.RobotoMono
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

local qtyLbl = Instance.new("TextLabel")
qtyLbl.Size = UDim2.new(0,60,0,20)
qtyLbl.Position = UDim2.new(0,10,0,65)
qtyLbl.BackgroundTransparency = 1
qtyLbl.Text = "Jumlah:"
qtyLbl.TextColor3 = Color3.fromRGB(200,200,200)
qtyLbl.Font = Enum.Font.RobotoMono
qtyLbl.TextSize = 11
qtyLbl.TextXAlignment = Enum.TextXAlignment.Left
qtyLbl.Parent = frame

qtyInput = Instance.new("TextBox")
qtyInput.Size = UDim2.new(0,60,0,20)
qtyInput.Position = UDim2.new(0,70,0,65)
qtyInput.BackgroundColor3 = Color3.fromRGB(60,60,60)
qtyInput.BorderSizePixel = 0
qtyInput.Font = Enum.Font.RobotoMono
qtyInput.Text = "1"
qtyInput.TextColor3 = Color3.fromRGB(255,255,255)
qtyInput.TextSize = 11
qtyInput.TextXAlignment = Enum.TextXAlignment.Center
qtyInput.ClearTextOnFocus = false
qtyInput.Parent = frame
Instance.new("UICorner", qtyInput).CornerRadius = UDim.new(0,3)

startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(1,-20,0,30)
startBtn.Position = UDim2.new(0,10,0,100)
startBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
startBtn.BorderSizePixel = 0
startBtn.Font = Enum.Font.RobotoMono
startBtn.Text = "Start Autofarm"
startBtn.TextColor3 = Color3.fromRGB(255,255,255)
startBtn.TextSize = 12
startBtn.Parent = frame
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0,4)
startBtn.MouseButton1Click:Connect(toggle)

local close = Instance.new("TextButton")
close.Size = UDim2.new(0,22,0,22)
close.Position = UDim2.new(1,-28,0,4)
close.BackgroundColor3 = Color3.fromRGB(70,70,70)
close.Text = "×"
close.TextColor3 = Color3.fromRGB(255,255,255)
close.Font = Enum.Font.RobotoMono
close.TextSize = 14
close.BorderSizePixel = 0
close.Parent = frame
Instance.new("UICorner", close).CornerRadius = UDim.new(0,4)
close.MouseButton1Click:Connect(function()
    if running then toggle() end
    gui:Destroy()
end)

-- Drag
local drag=false
local dragStart, startPos
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        drag=true
        dragStart=Vector2.new(input.Position.X, input.Position.Y)
        startPos=Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset)
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if not drag then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
    local vp = workspace.CurrentCamera.ViewportSize
    local sz = frame.AbsoluteSize
    frame.Position = UDim2.new(0, math.clamp(startPos.X+delta.X, 0, vp.X-sz.X),
                               0, math.clamp(startPos.Y+delta.Y, 0, vp.Y-sz.Y))
end)
game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then drag=false end
end)

print("[AutoFarm] Siap. UI sederhana.")