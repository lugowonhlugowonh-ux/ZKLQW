local scriptOk, scriptErr = pcall(function()

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
while not Players.LocalPlayer do task.wait(0.1) end
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- KAMERA BISA MENEMBUS TEMBOK
-- ==========================================
pcall(function()
    LocalPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
end)

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local ProximityPromptService = game:GetService("ProximityPromptService")

local isFarming = false
local farmThread = nil
local startTime = 0

local settings = {
    batchAmount = 1,
    loopBatch = true,
    stopIfDead = true
}

local mBags = {
    "Marshmallow", "Marshmellow", "Large Marshmallow Bag", "Large Marshmellow Bag",
    "Medium Marshmallow Bag", "Medium Marshmellow Bag", "Small Marshmallow Bag", "Small Marshmellow Bag"
}

-- Koordinat Y dinaikkan sedikit (4.5) agar tidak mendarat menembus lantai
local shopPos = Vector3.new(510.50, 4.5, 598.28)
local sellPos = shopPos

-- ==========================================
-- KORDINAT DAPUR
-- ==========================================
local ApartmentData = {
    { ID = 1, BuyPos = Vector3.new(1108.82, 10.11, 453.35), DoorPos = Vector3.new(1115.17, 10.11, 456.57), KitchenPos = Vector3.new(1142.81, 4.11, 449.94) },
    { ID = 2, BuyPos = Vector3.new(1108.79, 10.11, 424.20), DoorPos = Vector3.new(1114.19, 10.11, 428.26), KitchenPos = Vector3.new(1142.80, 4.14, 423.56) },
    { ID = 3, BuyPos = Vector3.new(1018.19, 10.11, 246.44), DoorPos = Vector3.new(1012.79, 10.11, 242.32), KitchenPos = Vector3.new(984.11, 4.11, 247.28) },
    { ID = 4, BuyPos = Vector3.new(1018.12, 10.11, 218.03), DoorPos = Vector3.new(1012.66, 10.08, 213.73), KitchenPos = Vector3.new(984.15, 4.11, 218.77) },
    { ID = 5, BuyPos = Vector3.new(927.72, 10.11, 72.27), DoorPos = Vector3.new(931.79, 10.11, 67.12), KitchenPos = Vector3.new(926.84, 4.11, 38.49) },
    { ID = 6, BuyPos = Vector3.new(899.17, 10.11, 72.51), DoorPos = Vector3.new(902.99, 10.11, 67.16), KitchenPos = Vector3.new(898.65, 4.11, 38.53) },
    { ID = 7, BuyPos = Vector3.new(1197.11, 3.71, -237.50), DoorPos = Vector3.new(1199.14, 3.71, -243.04), KitchenPos = Vector3.new(1202.15, -2.29, -220.04) },
    { ID = 8, BuyPos = Vector3.new(1196.79, 3.71, -201.87), DoorPos = Vector3.new(1199.00, 3.71, -207.04), KitchenPos = Vector3.new(1202.14, -2.29, -180.56) },
    { ID = 9, BuyPos = Vector3.new(1185.65, 3.71, -207.83), DoorPos = Vector3.new(1183.52, 3.71, -202.90), KitchenPos = Vector3.new(1180.38, -2.29, -188.99) },
    { ID = 10, BuyPos = Vector3.new(1185.42, 3.71, -243.37), DoorPos = Vector3.new(1183.58, 3.71, -238.20), KitchenPos = Vector3.new(1180.41, -2.29, -227.24) }
}

_G.OwnedKitchenPos = nil
_G.OwnedDoorPos = nil
local originalGravity = Workspace.Gravity

-- ==========================================
-- ANTI-AFK SYSTEM
-- ==========================================
task.spawn(function()
    pcall(function()
        if getconnections then
            for _, conn in ipairs(getconnections(LocalPlayer.Idled)) do
                if conn.Disable then conn:Disable()
                elseif conn.Disconnect then conn:Disconnect() end
            end
        else
            local vim = game:GetService("VirtualInputManager")
            LocalPlayer.Idled:Connect(function()
                vim:SendKeyEvent(true, Enum.KeyCode.F15, false, game)
                task.wait(0.05)
                vim:SendKeyEvent(false, Enum.KeyCode.F15, false, game)
            end)
        end
    end)
end)

-- ==========================================
-- INSTANT PROXIMITY PROMPT
-- ==========================================
local function makePromptInstant(prompt)
    if prompt:IsA("ProximityPrompt") then
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
    end
end

for _, obj in ipairs(Workspace:GetDescendants()) do makePromptInstant(obj) end
Workspace.DescendantAdded:Connect(makePromptInstant)
ProximityPromptService.PromptShown:Connect(makePromptInstant)

-- ==========================================
-- INVENTORY MANAGER
-- ==========================================
local function countTool(nameOrList)
    local count = 0
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    
    local function checkContainer(container)
        if not container then return end
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") then
                if type(nameOrList) == "table" then
                    for _, name in ipairs(nameOrList) do
                        if item.Name == name then count = count + 1 end
                    end
                elseif item.Name == nameOrList then
                    count = count + 1
                end
            end
        end
    end
    
    checkContainer(char)
    checkContainer(backpack)
    return count
end

local function hasTool(toolName) return countTool(toolName) > 0 end

local function equipTool(toolName)
    local char = LocalPlayer.Character
    if not char then return false end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return false end
    
    if char:FindFirstChild(toolName) then return true end
    humanoid:UnequipTools()
    task.wait(0.05) 

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local targetTool = backpack and backpack:FindFirstChild(toolName)
    
    if targetTool then
        humanoid:EquipTool(targetTool)
        task.wait(0.1)
        return true
    end
    return false
end

-- ==========================================
-- UI SETUP & LOADING SCREEN
-- ==========================================
local UI_Target = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

for _, name in ipairs({"LuzorHub", "LuzorLoadingScreen"}) do
    if UI_Target:FindFirstChild(name) then UI_Target[name]:Destroy() end
end

local LoadGui = Instance.new("ScreenGui")
LoadGui.Name = "LuzorLoadingScreen"
LoadGui.IgnoreGuiInset = true 
LoadGui.ResetOnSpawn = false
LoadGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LoadGui.DisplayOrder = 999
LoadGui.Parent = UI_Target

local LoadFrame = Instance.new("Frame")
LoadFrame.Size = UDim2.new(1, 0, 1, 0)
LoadFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LoadFrame.BackgroundTransparency = 1
LoadFrame.Parent = LoadGui

local LoadText = Instance.new("TextLabel")
LoadText.AnchorPoint = Vector2.new(0.5, 0.5)
LoadText.Position = UDim2.new(0.5, 0, 0.5, 0)
LoadText.Size = UDim2.new(0, 250, 0, 50)
LoadText.BackgroundTransparency = 1
LoadText.Font = Enum.Font.GothamBold
LoadText.Text = "wait..."
LoadText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadText.TextSize = 26
LoadText.TextTransparency = 1
LoadText.Parent = LoadFrame

local isLoading = false
local function showLoadingScreen()
    isLoading = true
    task.spawn(function()
        local dots = 0
        while isLoading do
            dots = (dots + 1) % 4
            LoadText.Text = "wait" .. string.rep(".", dots)
            task.wait(0.35)
        end
    end)
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(LoadFrame, tweenInfo, {BackgroundTransparency = 0}):Play()
    local fadeText = TweenService:Create(LoadText, tweenInfo, {TextTransparency = 0})
    fadeText:Play()
    fadeText.Completed:Wait()
end

local function hideLoadingScreen()
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(LoadFrame, tweenInfo, {BackgroundTransparency = 1}):Play()
    local fadeText = TweenService:Create(LoadText, tweenInfo, {TextTransparency = 1})
    fadeText:Play()
    fadeText.Completed:Wait()
    isLoading = false
end

local function checkDeathStatus()
    if settings.stopIfDead then
        local char = LocalPlayer.Character
        if not char then return true end
        local hum = char:FindFirstChild("Humanoid")
        if hum and hum.Health <= 0 then return true end
    end
    return false
end

-- ==========================================
-- GHOST MODE & MOVEMENT
-- ==========================================
local modifiedParts = {}
local ghostConn = nil

local function startGhostMode()
    if ghostConn then return end
    
    ghostConn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        local hum = char:FindFirstChild("Humanoid")
        if hum and hum.Sit then return end 
        
        local hrp = char.HumanoidRootPart
        
        local function processNoclipPart(part)
            if not part or not part:IsA("BasePart") or part:IsA("Terrain") then return end
            if part:IsDescendantOf(char) then return end
            
            if part:IsA("Seat") or part:IsA("VehicleSeat") or part.Name:lower():find("seat") then return end
            local model = part:FindFirstAncestorOfClass("Model")
            if model and (model:FindFirstChildOfClass("VehicleSeat", true) or model:FindFirstChildOfClass("Seat", true)) then
                return
            end
            
            if not modifiedParts[part] then
                modifiedParts[part] = { CanCollide = part.CanCollide, CanTouch = part.CanTouch }
            end
            part.CanCollide = false
            part.CanTouch = false
        end

        for _, part in ipairs(hrp:GetTouchingParts()) do
            processNoclipPart(part)
        end
        
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {char}
        
        local checkDirs = {
            Vector3.new(0, -4, 0),
            hrp.CFrame.LookVector * 3.5,
            -hrp.CFrame.LookVector * 3.5,
            hrp.CFrame.RightVector * 3.5,
            -hrp.CFrame.RightVector * 3.5
        }
        for _, dir in ipairs(checkDirs) do
            local res = workspace:Raycast(hrp.Position, dir, params)
            if res and res.Instance then
                processNoclipPart(res.Instance)
            end
        end
    end)
end

local function stopGhostMode()
    if ghostConn then ghostConn:Disconnect(); ghostConn = nil end
    for part, state in pairs(modifiedParts) do
        if part and part.Parent then
            part.CanCollide = state.CanCollide
            part.CanTouch = state.CanTouch
        end
    end
    modifiedParts = {}
end

local function discreteStepTP(startP, endP)
    local stepDistance = 0.8
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local hrp = char.HumanoidRootPart
    
    while isFarming do
        if checkDeathStatus() then return false end
        local dist = (endP - hrp.Position).Magnitude
        if dist <= stepDistance then
            hrp.CFrame = CFrame.new(endP)
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            return true
        else
            hrp.CFrame = CFrame.new(hrp.Position + ((endP - hrp.Position).Unit * stepDistance))
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
        task.wait(0.08)
    end
    return false
end

local function blinkTeleport(targetPos, isUnderground)
    if isUnderground then showLoadingScreen() end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild('HumanoidRootPart') then 
        if isUnderground then hideLoadingScreen() end return 
    end
    
    startGhostMode()
    local hrp = char.HumanoidRootPart
    local humanoid = char:FindFirstChild('Humanoid')
    humanoid.PlatformStand = true
    Workspace.Gravity = 0
    
    if isUnderground then
        local underY = -4
        discreteStepTP(hrp.Position, Vector3.new(hrp.Position.X, underY, hrp.Position.Z))
        discreteStepTP(hrp.Position, Vector3.new(targetPos.X, underY, targetPos.Z))
        discreteStepTP(hrp.Position, targetPos)
    else
        discreteStepTP(hrp.Position, targetPos)
    end
    
    Workspace.Gravity = originalGravity 
    humanoid.PlatformStand = false
    
    stopGhostMode() 
    
    if isUnderground then hideLoadingScreen() end
end

local function BypassTP(targetPos)
    showLoadingScreen()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 9e9, 0)
        bv.Parent = hrp
    end
    
    local newChar = LocalPlayer.CharacterAdded:Wait()
    local newHrp = newChar:WaitForChild("HumanoidRootPart", 10)
    if newHrp then
        task.wait(0.5) 
        newHrp.CFrame = CFrame.new(targetPos)
    end
    task.wait(1.2)
    hideLoadingScreen()
end

-- ==========================================
-- POSISI LOCK (DIAM PATUNG & TANPA MENTAL)
-- ==========================================
local function lockPosition(targetPos)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end
    
    startGhostMode() 
    
    Workspace.Gravity = 0
    humanoid.PlatformStand = true 
    
    local oldBv = hrp:FindFirstChild("FarmLock")
    if oldBv then oldBv:Destroy() end
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = "FarmLock"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp
    
    hrp.CFrame = CFrame.new(targetPos)
    hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
    hrp.Anchored = true 
end

local function unlockPosition()
    Workspace.Gravity = originalGravity
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    
    if hrp then
        local bv = hrp:FindFirstChild("FarmLock")
        if bv then bv:Destroy() end
        hrp.Anchored = false 
    end
    if humanoid then
        humanoid.PlatformStand = false
    end
    stopGhostMode() 
end

-- ==========================================
-- PROMPT & FARMING LOGIC
-- ==========================================
local function matchPromptText(actionText, keyword)
    if not keyword then return true end
    local text = string.lower(actionText or "")
    keyword = string.lower(keyword)
    if keyword == "lock" and string.find(text, "unlock") then return false end
    return string.find(text, keyword) ~= nil
end

local function firePromptAt(pos, maxDist, keyword)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local pPos = obj.Parent and (obj.Parent:IsA("BasePart") and obj.Parent.Position or (obj.Parent:IsA("Attachment") and obj.Parent.WorldPosition))
            if pPos and (pos - pPos).Magnitude <= maxDist then
                if matchPromptText(obj.ActionText, keyword) then
                    obj.RequiresLineOfSight = false
                    obj.HoldDuration = 0
                    if fireproximityprompt then
                        fireproximityprompt(obj, 0)
                    else
                        obj:InputHoldBegin(); task.wait(0.05); obj:InputHoldEnd()
                    end
                    return true
                end
            end
        end
    end
    return false
end

local function checkPromptExistsAt(pos, maxDist, keyword)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local pPos = obj.Parent and (obj.Parent:IsA("BasePart") and obj.Parent.Position or (obj.Parent:IsA("Attachment") and obj.Parent.WorldPosition))
            if pPos and (pos - pPos).Magnitude <= maxDist then
                if matchPromptText(obj.ActionText, keyword) then
                    return true
                end
            end
        end
    end
    return false
end

local function secureDoor(doorPos)
    local maxAttempts = 10
    for i = 1, maxAttempts do
        if not isFarming then return false end
        if checkPromptExistsAt(doorPos, 8, "unlock") then return true end
        if checkPromptExistsAt(doorPos, 8, "lock") then
            firePromptAt(doorPos, 8, "lock")
            task.wait(0.5) 
            if checkPromptExistsAt(doorPos, 8, "unlock") then
                return true
            else
                firePromptAt(doorPos, 8, "open")
                task.wait(0.7)
            end
        else
            firePromptAt(doorPos, 8, "open")
            task.wait(0.5)
        end
    end
    return false
end

local function SetupApartment()
    local targetData = nil
    for _, data in ipairs(ApartmentData) do
        if not isFarming then return end
        local isVacant = false
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("TextLabel") and string.find(string.upper(obj.Text), "VACANT") then
                local gui = obj:FindFirstAncestorOfClass("SurfaceGui") or obj:FindFirstAncestorOfClass("BillboardGui")
                local uiPart = gui and (gui.Adornee or gui.Parent)
                if uiPart and uiPart:IsA("BasePart") and (uiPart.Position - data.BuyPos).Magnitude <= 5 then 
                    isVacant = true; break 
                end
            end
        end
        if isVacant then targetData = data; break end
    end

    if targetData then
        BypassTP(targetData.BuyPos)
        firePromptAt(targetData.BuyPos, 5, "purchase"); task.wait(1)
        _G.OwnedKitchenPos = targetData.KitchenPos
        _G.OwnedDoorPos = targetData.DoorPos
        blinkTeleport(targetData.DoorPos, false)
        task.wait(0.8)
        secureDoor(targetData.DoorPos)
        return true
    end
    return false
end

local function robustBuy()
    local target = settings.batchAmount
    while isFarming do
        if checkDeathStatus() then return end
        local wCount = countTool({"Water", "Water23"})
        local sCount = countTool("Sugar Block Bag")
        local gCount = countTool("Gelatin")
        if wCount >= target and sCount >= target and gCount >= target then break end
        
        local rs = ReplicatedStorage:FindFirstChild("RemoteEvents")
        if rs and rs:FindFirstChild("ReliableRemoteEvent") then
            local remote = rs.ReliableRemoteEvent
            if gCount < target then
                local buf = buffer.create(3)
                buffer.writeu8(buf, 0, 24); buffer.writeu8(buf, 1, 19); buffer.writeu8(buf, 2, 1)
                remote:FireServer(buf); task.wait(0.35)
            end
            if sCount < target then
                local buf = buffer.create(3)
                buffer.writeu8(buf, 0, 24); buffer.writeu8(buf, 1, 19); buffer.writeu8(buf, 2, 2)
                remote:FireServer(buf); task.wait(0.35)
            end
            if wCount < target then
                local buf = buffer.create(3)
                buffer.writeu8(buf, 0, 24); buffer.writeu8(buf, 1, 19); buffer.writeu8(buf, 2, 3)
                remote:FireServer(buf); task.wait(0.35)
            end
        end
        task.wait(0.4)
    end
end

local function robustPutIngredient(toolNameOrList, waitTimeAfter)
    if not isFarming then return false end
    local initialCount = countTool(toolNameOrList)
    if initialCount == 0 then return false end
    
    local attempts = 0
    local maxAttempts = 30
    
    while isFarming and countTool(toolNameOrList) >= initialCount and attempts < maxAttempts do
        if checkDeathStatus() then return false end
        if type(toolNameOrList) == "table" then
            for _, name in ipairs(toolNameOrList) do
                if countTool(name) > 0 then equipTool(name); break end
            end
        else
            equipTool(toolNameOrList)
        end
        task.wait(0.2)
        firePromptAt(_G.OwnedKitchenPos, 8)
        task.wait(1.2)
        attempts = attempts + 1
    end
    
    if countTool(toolNameOrList) < initialCount then
        if waitTimeAfter and waitTimeAfter > 0 then
            local waitStart = os.clock()
            while isFarming and (os.clock() - waitStart) < waitTimeAfter do
                if checkDeathStatus() then return false end
                task.wait(0.5)
            end
        end
        return true
    end
    return false
end

local function CookAndPackRobust(currentBatchNum)
    if not isFarming then return end
    local wSuccess = robustPutIngredient({"Water", "Water23"}, 23)
    if not wSuccess then return end
    robustPutIngredient("Sugar Block Bag", 0)
    robustPutIngredient("Gelatin", 47)

    if not isFarming then return end
    
    local initialMarshmallows = countTool(mBags)
    local timeout = 0
    
    while isFarming and countTool(mBags) <= initialMarshmallows and timeout < 100 do
        if checkDeathStatus() then return end
        equipTool("Empty Bag")
        firePromptAt(_G.OwnedKitchenPos, 10)
        task.wait(0.3)
        timeout = timeout + 1
    end
    
    if isFarming and countTool({"Water", "Water23"}) > 0 then equipTool("Water") end
end

local function sellAllBags()
    if not isFarming then return end
    for _, name in ipairs(mBags) do
        while hasTool(name) and isFarming do
            if checkDeathStatus() then isFarming = false break end
            equipTool(name)
            task.wait(0.25)
            local char = LocalPlayer.Character
            if char and char:FindFirstChild(name) then
                firePromptAt(sellPos, 8); task.wait(0.4)
            else
                task.wait(0.2)
            end
        end
    end
    task.wait(0.4) 
end

local function RunFarm()
    local isFirstRun = true
    while isFarming do
        if isFirstRun then
            BypassTP(shopPos)
            isFirstRun = false
        end

        robustBuy()
        if not isFarming then break end
        
        blinkTeleport(_G.OwnedKitchenPos, true)
        if not isFarming then break end

        lockPosition(_G.OwnedKitchenPos)

        local batchCounter = 1
        while isFarming and (countTool({"Water", "Water23"}) > 0 and countTool("Sugar Block Bag") > 0 and countTool("Gelatin") > 0) do
            if checkDeathStatus() then isFarming = false break end
            CookAndPackRobust(batchCounter)
            batchCounter = batchCounter + 1
        end

        unlockPosition()

        if not isFarming then break end

        blinkTeleport(shopPos, true)
        lockPosition(shopPos) 
        sellAllBags()
        unlockPosition()

        if not settings.loopBatch then break end
    end
    unlockPosition() 
end

-- ==========================================
-- DARK HUB / AETHER UI
-- UI saja yang diganti; logic farming di atas tetap
-- ==========================================

local Aether = loadstring(game:HttpGet("https://raw.githubusercontent.com/NIcoGabrielRealYtr/Aether.lua-Library/refs/heads/main/Source"))()

local MainWindow = Aether:CreateWindow({
    Title = "DARK HUB",
    SubText = "Marshmallow Farm",
    Image = "rbxassetid://95259225424429",
    IsMobile = true
})

local FarmTab = MainWindow:AddTab({
    Text = "Farm",
    Icon = "rbxassetid://108020878442937"
})

local FarmSection = FarmTab:AddSection({
    Title = "Marshmallow Farm",
    Side = "Left"
})

local SettingsSection = FarmTab:AddSection({
    Title = "Settings",
    Side = "Right"
})

local function notify(title, message)
    pcall(function()
        Aether:Notify({
            Title = title,
            Content = message,
            Lifetime = 3
        })
    end)
end

FarmSection:AddToggle({
    Text = "Farming",
    Flag = "dark_hub_farming",
    Default = false,
    Callback = function(value)
        isFarming = value

        if isFarming then
            startTime = os.time()
            notify("DARK HUB", "Farming started")

            farmThread = task.spawn(function()
                if not _G.OwnedKitchenPos then
                    local success = SetupApartment()
                    if not success then
                        isFarming = false
                        notify("DARK HUB", "No vacant apartment found")
                        return
                    end
                end

                if isFarming then
                    RunFarm()
                end

                if isFarming then
                    isFarming = false
                    notify("DARK HUB", "Farming finished")
                end
            end)
        else
            unlockPosition()
            notify("DARK HUB", "Farming stopped")
        end
    end
})

FarmSection:AddSlider({
    Text = "Batch Amount",
    Flag = "dark_hub_batch",
    Min = 1,
    Max = 50,
    Default = settings.batchAmount,
    Suffix = " batch",
    Callback = function(value)
        if not isFarming then
            settings.batchAmount = math.floor(value)
        end
    end
})

FarmSection:AddToggle({
    Text = "Loop Batch",
    Flag = "dark_hub_loop",
    Default = settings.loopBatch,
    Callback = function(value)
        settings.loopBatch = value
    end
})

SettingsSection:AddToggle({
    Text = "Stop If Dead",
    Flag = "dark_hub_stop_dead",
    Default = settings.stopIfDead,
    Callback = function(value)
        settings.stopIfDead = value
    end
})

SettingsSection:AddDropdown({
    Text = "Info",
    Flag = "dark_hub_info",
    Options = {"DARK HUB", "Marshmallow Farm"},
    Default = "DARK HUB",
    Callback = function(value)
        if value == "DARK HUB" then
            notify("DARK HUB", "Farm UI loaded")
        else
            notify("Marshmallow Farm", "Ready")
        end
    end
})

Aether:Notify({
    Title = "DARK HUB",
    Content = "Marshmallow Farm UI Loaded",
    Lifetime = 3
})

-- UI status monitor; tidak mengubah fungsi farming.
task.spawn(function()
    local lastState = isFarming
    while task.wait(0.75) do
        if not MainWindow then break end

        if isFarming ~= lastState then
            lastState = isFarming
        end

        if isFarming and checkDeathStatus() then
            isFarming = false
            unlockPosition()
            notify("DARK HUB", "Farming stopped: player died")
        end
    end
end)

end)

if not scriptOk then
    warn("Error:", scriptErr)
end
