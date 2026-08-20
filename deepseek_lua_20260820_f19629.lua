local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NIcoGabrielRealYtr/Ather-Hub-Library/refs/heads/main/Source"))()

local Window = Library:Window({
    Name = '<font color="rgb(175, 102, 126)">ather.</font>hub',
    Logo = "rbxassetid://133425623304338"
})

-- ============================================
-- PAGES
-- ============================================
local TeleportPage = Window:Page({
    Name = "Teleport",
    Description = "Teleport to locations",
    Icon = "lucide:map-pin",
    Search = true
})

local TeleportSub = TeleportPage:SubPage({
    Name = "Locations",
    Icon = "lucide:map",
    DisplayName = true
})

local FarmingPage = Window:Page({
    Name = "Farming",
    Description = "Farm automation",
    Icon = "lucide:pickaxe",
    Search = true
})

local FarmSub = FarmingPage:SubPage({
    Name = "Auto Farm",
    Icon = "lucide:package",
    DisplayName = true
})

-- ============================================
-- VARIABLES & SETUP
-- ============================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local originalGravity = Workspace.Gravity
local isFarming = false
local farmThread = nil
local startTime = 0

-- ============================================
-- KORDINAT LENGKAP
-- ============================================

-- Shop Coordinates
local shopPos = Vector3.new(510.50, 4.5, 598.28)
local sellPos = Vector3.new(510.50, 4.5, 598.28)

-- Apartment Data (10 Units)
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

-- ATM Locations (15 Units)
local ATMLocations = {
    { Name = "ATM 1", Pos = Vector3.new(-33.1487, 3.7370, -299.5453) },
    { Name = "ATM 2", Pos = Vector3.new(538.4818, 3.7371, -349.0415) },
    { Name = "ATM 3", Pos = Vector3.new(497.8156, 3.7839, 405.5681) },
    { Name = "ATM 4", Pos = Vector3.new(236.1748, 3.1180, -165.3973) },
    { Name = "ATM 5", Pos = Vector3.new(-652.0219, 4.2857, 155.1690) },
    { Name = "ATM 6", Pos = Vector3.new(-455.1304, 4.3107, 370.8311) },
    { Name = "ATM 7", Pos = Vector3.new(-266.3022, 4.4058, -212.2364) },
    { Name = "ATM 8", Pos = Vector3.new(-10.4940, 3.7371, 233.9844) },
    { Name = "ATM 9", Pos = Vector3.new(717.0417, 3.8176, 413.7101) },
    { Name = "ATM 10", Pos = Vector3.new(-536.8209, 4.2857, -20.3541) },
    { Name = "ATM 11", Pos = Vector3.new(-652.0210, 4.2850, 155.1690) },
    { Name = "ATM 12", Pos = Vector3.new(714.4320, 4.2857, -240.3657) },
    { Name = "ATM 13", Pos = Vector3.new(-314.9244, 3.8715, 145.9376) },
    { Name = "ATM 14", Pos = Vector3.new(-377.9388, 4.3107, -359.7116) },
    { Name = "ATM 15", Pos = Vector3.new(360.0960, 3.7371, -359.4165) }
}

-- Spawn Locations (16 Locations)
local SpawnLocations = {
    { Name = "Gun Store 1", Pos = Vector3.new(206.7363, 3.7371, -188.6792) },
    { Name = "Gun Store 2", Pos = Vector3.new(-493.9350, 3.8621, 360.4673) },
    { Name = "Boxing Gym", Pos = Vector3.new(-563.9725, 3.5371, -66.1061) },
    { Name = "Garbage Job", Pos = Vector3.new(717.6342, 3.5372, 161.4455) },
    { Name = "Bank", Pos = Vector3.new(-56.4220, 3.7371, -329.5779) },
    { Name = "Studio", Pos = Vector3.new(468.3650, 4.1122, 159.9287) },
    { Name = "Police Station", Pos = Vector3.new(748.6832, 4.9121, -255.7487) },
    { Name = "Car Shop", Pos = Vector3.new(730.1787, 3.7098, 449.9476) },
    { Name = "Cosmic Cuts", Pos = Vector3.new(57.6060, 3.7371, -64.3018) },
    { Name = "Pluto's Headwear", Pos = Vector3.new(-269.4561, 3.8895, -333.5561) },
    { Name = "B&b (Glasses Store)", Pos = Vector3.new(-696.8394, 3.6121, -335.3162) },
    { Name = "Bronx Sneaker Club", Pos = Vector3.new(525.3108, 3.4871, -197.1698) },
    { Name = "Kevins Drip", Pos = Vector3.new(-202.8330, 3.4871, -59.0894) },
    { Name = "Apartments 1", Pos = Vector3.new(-518.3848, 3.7872, 210.3059) },
    { Name = "Apartments 2", Pos = Vector3.new(-276.6081, 4.3621, -475.6622) },
    { Name = "Apartments 3", Pos = Vector3.new(215.5399, 5.2371, 26.2235) }
}

-- Auto Farm Positions (Chips Farm)
local ChipPositions = {
    Vector3.new(-461.62, 3.86, -467.55),
    Vector3.new(-461.6, 3.86, -473.63),
    Vector3.new(-466.43, 3.96, -500.60),
    Vector3.new(-462.67, 3.86, -522.34),
    Vector3.new(-468.11, 3.86, -494.76),
    Vector3.new(-515.34, 3.86, -482.29),
    Vector3.new(-492, 4, -473),
    Vector3.new(-480, 4, -434)
}

-- Box Farm Positions
local BoxPositions = {
    Vector3.new(-551.46, 3.54, -86.13),
    Vector3.new(-540.16, 3.54, -83.06),
    Vector3.new(-401.42, 3.36, -70.90)
}

-- ============================================
-- TELEPORT SYSTEM (Dari manzz.txt)
-- ============================================

local modifiedParts = {}
local ghostConn = nil
local isTeleporting = false

-- GHOST MODE (Noclip)
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

-- DISCRETE STEP TELEPORT
local function discreteStepTP(startP, endP)
    local stepDistance = 0.8
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local hrp = char.HumanoidRootPart
    
    local maxSteps = 100
    local steps = 0
    
    while isTeleporting or not isFarming do
        if steps > maxSteps then
            hrp.CFrame = CFrame.new(endP)
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            return true
        end
        
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
        steps = steps + 1
    end
    return false
end

-- MAIN BYPASS TELEPORT
local function BypassTP(targetPos)
    if isTeleporting then return end
    isTeleporting = true
    
    local char = LocalPlayer.Character
    if not char then 
        isTeleporting = false
        return 
    end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    
    if not hrp or not humanoid then
        isTeleporting = false
        return
    end
    
    -- Aktifkan ghost mode
    startGhostMode()
    
    -- Persiapkan teleport
    humanoid.PlatformStand = true
    Workspace.Gravity = 0
    
    -- Teleport bertahap
    local success = discreteStepTP(hrp.Position, targetPos)
    
    -- Kembalikan normal
    Workspace.Gravity = originalGravity
    humanoid.PlatformStand = false
    
    stopGhostMode()
    
    isTeleporting = false
    return success
end

-- BLINK TELEPORT (Dengan Loading)
local function BlinkTP(targetPos, showLoading)
    if isTeleporting then return end
    
    if showLoading then
        Window:Notify({
            Title = "Teleporting",
            Description = "Moving to location...",
            Duration = 2
        })
    end
    
    BypassTP(targetPos)
end

-- INSTANT TELEPORT (Langsung tanpa efek)
local function InstantTP(targetPos)
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(targetPos)
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end

-- ============================================
-- UI - TELEPORT SECTION
-- ============================================

local TeleportSection = TeleportSub:Section({
    Name = "Teleport to Location",
    Side = 1
})

-- DROPDOWN UNTUK SPAWN LOCATIONS
local spawnItems = {}
for _, loc in ipairs(SpawnLocations) do
    table.insert(spawnItems, loc.Name)
end

local selectedSpawn = TeleportSection:Dropdown({
    Name = "Spawn Locations",
    Flag = "SpawnLocation",
    Items = spawnItems,
    Default = spawnItems[1],
    Callback = function(Value)
        -- Simpan pilihan
        for _, loc in ipairs(SpawnLocations) do
            if loc.Name == Value then
                selectedSpawnPos = loc.Pos
                break
            end
        end
    end
})

local selectedSpawnPos = SpawnLocations[1].Pos

TeleportSection:Button({
    Name = "Teleport to Spawn",
    Callback = function()
        if selectedSpawnPos then
            BlinkTP(selectedSpawnPos, true)
            Window:Notify({
                Title = "Teleported",
                Description = "Arrived at location",
                Duration = 2
            })
        end
    end
})

-- ATM TELEPORT
local atmItems = {}
for _, atm in ipairs(ATMLocations) do
    table.insert(atmItems, atm.Name)
end

local selectedATM = TeleportSection:Dropdown({
    Name = "ATM Locations",
    Flag = "ATMLocation",
    Items = atmItems,
    Default = atmItems[1],
    Callback = function(Value)
        for _, atm in ipairs(ATMLocations) do
            if atm.Name == Value then
                selectedATMPos = atm.Pos
                break
            end
        end
    end
})

local selectedATMPos = ATMLocations[1].Pos

TeleportSection:Button({
    Name = "Teleport to ATM",
    Callback = function()
        if selectedATMPos then
            BlinkTP(selectedATMPos, true)
            Window:Notify({
                Title = "Teleported",
                Description = "Arrived at ATM",
                Duration = 2
            })
        end
    end
})

-- APARTMENT TELEPORT
local aptItems = {}
for _, apt in ipairs(ApartmentData) do
    table.insert(aptItems, "Apartment " .. apt.ID)
end

local selectedApt = TeleportSection:Dropdown({
    Name = "Apartment Locations",
    Flag = "ApartmentLocation",
    Items = aptItems,
    Default = aptItems[1],
    Callback = function(Value)
        for _, apt in ipairs(ApartmentData) do
            if "Apartment " .. apt.ID == Value then
                selectedAptPos = apt.KitchenPos
                break
            end
        end
    end
})

local selectedAptPos = ApartmentData[1].KitchenPos

TeleportSection:Button({
    Name = "Teleport to Apartment",
    Callback = function()
        if selectedAptPos then
            BlinkTP(selectedAptPos, true)
            Window:Notify({
                Title = "Teleported",
                Description = "Arrived at apartment",
                Duration = 2
            })
        end
    end
})

-- QUICK TELEPORT
local QuickSection = TeleportSub:Section({
    Name = "Quick Teleport",
    Side = 2
})

QuickSection:Button({
    Name = "Teleport to Shop",
    Callback = function()
        BlinkTP(shopPos, true)
        Window:Notify({
            Title = "Teleported",
            Description = "Arrived at shop",
            Duration = 2
        })
    end
})

QuickSection:Button({
    Name = "Teleport to Sell",
    Callback = function()
        BlinkTP(sellPos, true)
        Window:Notify({
            Title = "Teleported",
            Description = "Arrived at sell point",
            Duration = 2
        })
    end
})

-- ============================================
-- UI - FARMING SECTION
-- ============================================

local FarmSection = FarmSub:Section({
    Name = "Auto Farm",
    Side = 1
})

local farmToggle = FarmSection:Toggle({
    Name = "Enable Auto Farm",
    Flag = "AutoFarm",
    Default = false,
    Callback = function(Value)
        isFarming = Value
        if isFarming then
            startTime = os.time()
            Window:Notify({
                Title = "Farming Started",
                Description = "Auto farm is now running",
                Duration = 3
            })
            startFarm()
        else
            Window:Notify({
                Title = "Farming Stopped",
                Description = "Auto farm stopped",
                Duration = 3
            })
            stopFarm()
        end
    end
})

-- FARM TYPE SELECTION
FarmSection:Dropdown({
    Name = "Farm Type",
    Flag = "FarmType",
    Items = {"Marshmallow", "Chips", "Box"},
    Default = "Marshmallow",
    Callback = function(Value)
        farmType = Value
    end
})

local farmType = "Marshmallow"

-- FARM LOOP
local function startFarm()
    farmThread = task.spawn(function()
        while isFarming do
            if farmType == "Marshmallow" then
                runMarshmallowFarm()
            elseif farmType == "Chips" then
                runChipsFarm()
            elseif farmType == "Box" then
                runBoxFarm()
            end
            task.wait(1)
        end
    end)
end

local function stopFarm()
    isFarming = false
    if farmThread then
        task.cancel(farmThread)
        farmThread = nil
    end
end

-- MARSHMALLOW FARM
local function runMarshmallowFarm()
    -- Teleport ke toko
    BlinkTP(shopPos, true)
    task.wait(1)
    
    -- Beli bahan (simulasi)
    Window:Notify({
        Title = "Marshmallow Farm",
        Description = "Buying ingredients...",
        Duration = 2
    })
    
    -- Teleport ke apartemen
    if selectedAptPos then
        BlinkTP(selectedAptPos, true)
        task.wait(1)
    end
    
    -- Masak (simulasi)
    task.wait(3)
    
    -- Teleport ke toko untuk jual
    BlinkTP(shopPos, true)
    task.wait(1)
end

-- CHIPS FARM
local function runChipsFarm()
    for _, pos in ipairs(ChipPositions) do
        if not isFarming then break end
        BlinkTP(pos, false)
        task.wait(0.5)
    end
    Window:Notify({
        Title = "Chips Farm",
        Description = "Completed one cycle",
        Duration = 2
    })
end

-- BOX FARM
local function runBoxFarm()
    for _, pos in ipairs(BoxPositions) do
        if not isFarming then break end
        BlinkTP(pos, false)
        task.wait(0.5)
    end
    Window:Notify({
        Title = "Box Farm",
        Description = "Completed one cycle",
        Duration = 2
    })
end

-- ============================================
-- SETTINGS & AUTO LOAD
-- ============================================

local SettingsPage = Window:CreateSettingsPage()
SettingsPage:CreateConfigsSection()
SettingsPage:CreateThemingSection()

Library:CheckForAutoLoad()

-- ============================================
-- KEYBIND UNTUK TELEPORT CEPAT
-- ============================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- T = Teleport ke Shop
    if input.KeyCode == Enum.KeyCode.T then
        BlinkTP(shopPos, true)
        Window:Notify({
            Title = "Quick Teleport",
            Description = "Teleported to Shop",
            Duration = 2
        })
    end
    
    -- B = Teleport ke Back (posisi terakhir)
    if input.KeyCode == Enum.KeyCode.B then
        if lastPosition then
            BlinkTP(lastPosition, true)
        end
    end
end)

-- ============================================
-- NOTIFICATION STARTUP
-- ============================================

Window:Notify({
    Title = "Teleport Hub Loaded",
    Description = "Press T to teleport to Shop",
    Duration = 5
})

print("✅ Teleport Hub Loaded!")
print("📍 " .. #SpawnLocations .. " spawn locations loaded")
print("🏧 " .. #ATMLocations .. " ATM locations loaded")
print("🏢 " .. #ApartmentData .. " apartments loaded")