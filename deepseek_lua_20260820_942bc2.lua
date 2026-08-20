local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NIcoGabrielRealYtr/Ather-Hub-Library/refs/heads/main/Source"))()

local Window = Library:Window({
    Name = 'luzor',
    Subtitle = 'South Bronx: The Trenches',
    Logo = "rbxassetid://133425623304338" -- Anda bisa ganti dengan logo sendiri
})

-- ============================================
-- COMBAT PAGE
-- ============================================
local Combat = Window:Page({
    Name = "Combat",
    Description = "Combat features",
    Icon = "lucide:sword",
    Search = true
})

local CombatSub = Combat:SubPage({
    Name = "Silent Aim",
    Icon = "lucide:target",
    DisplayName = true
})

local WhitelistSub = Combat:SubPage({
    Name = "Whitelist",
    Icon = "lucide:shield",
    DisplayName = true
})

-- ============================================
-- SILENT AIM SETTINGS
-- ============================================
local AimSection = CombatSub:Section({
    Name = "Aimbot Settings",
    Side = 1
})

-- Konfigurasi Silent Aim
local CFG = {
    ENABLED = true,
    WALLBANG = false,
    FOV_RADIUS = 180,
    FOV_COLOR = Color3.fromRGB(255, 255, 255),
    FOV_THICK = 1.5,
    SHOW_FOV = true,
    SHOW_TRACER = true,
    TRACER_COLOR = Color3.fromRGB(255, 255, 255),
    TARGET_PART = "Head",
    MOBILE_Y_OFFSET = 107
}

local Whitelist = {}

-- Silent Aim Toggle
local aimbotToggle = AimSection:Toggle({
    Name = "Enable Silent Aim",
    Flag = "SilentAimEnabled",
    Default = CFG.ENABLED,
    Callback = function(Value)
        CFG.ENABLED = Value
    end
})

aimbotToggle:Keybind({
    Flag = "SilentAimKeybind",
    Default = Enum.KeyCode.K,
    Mode = "Toggle",
    Callback = function()
        CFG.ENABLED = not CFG.ENABLED
        aimbotToggle:Set(CFG.ENABLED)
    end
})

aimbotToggle:Colorpicker({
    Flag = "SilentAimColor",
    Default = CFG.FOV_COLOR,
    Callback = function(Color)
        CFG.FOV_COLOR = Color
    end
})

-- Wallbang
local wallbangToggle = AimSection:Toggle({
    Name = "Wallbang",
    Flag = "WallbangEnabled",
    Default = CFG.WALLBANG,
    Callback = function(Value)
        CFG.WALLBANG = Value
    end
})

wallbangToggle:Keybind({
    Flag = "WallbangKeybind",
    Default = Enum.KeyCode.L,
    Mode = "Toggle",
    Callback = function()
        CFG.WALLBANG = not CFG.WALLBANG
        wallbangToggle:Set(CFG.WALLBANG)
    end
})

-- FOV Slider
AimSection:Slider({
    Name = "FOV Radius",
    Flag = "FOVRadius",
    Default = CFG.FOV_RADIUS,
    Min = 10,
    Max = 800,
    Decimals = 0,
    Suffix = "px",
    Callback = function(Value)
        CFG.FOV_RADIUS = Value
    end
})

-- Target Part Dropdown
AimSection:Dropdown({
    Name = "Target Part",
    Flag = "TargetPart",
    Items = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    Default = "Head",
    Callback = function(Value)
        CFG.TARGET_PART = Value
    end
})

-- ============================================
-- VISUAL SETTINGS (COMBAT SUB)
-- ============================================
local VisualSection = CombatSub:Section({
    Name = "Visual Settings",
    Side = 2
})

VisualSection:Toggle({
    Name = "Show FOV Circle",
    Flag = "ShowFOV",
    Default = CFG.SHOW_FOV,
    Callback = function(Value)
        CFG.SHOW_FOV = Value
    end
})

VisualSection:Toggle({
    Name = "Show Tracer",
    Flag = "ShowTracer",
    Default = CFG.SHOW_TRACER,
    Callback = function(Value)
        CFG.SHOW_TRACER = Value
    end
})

VisualSection:Label({
    Name = "Tracer Color"
}):Colorpicker({
    Flag = "TracerColor",
    Default = CFG.TRACER_COLOR,
    Callback = function(Color)
        CFG.TRACER_COLOR = Color
    end
})

VisualSection:Label({
    Name = "FOV Circle Color"
}):Colorpicker({
    Flag = "FOVColor",
    Default = CFG.FOV_COLOR,
    Callback = function(Color)
        CFG.FOV_COLOR = Color
    end
})

-- ============================================
-- NOCLIP SETTINGS
-- ============================================
local NoclipSection = CombatSub:Section({
    Name = "Noclip",
    Side = 1
})

getgenv().NoclipActive = false
getgenv().OriginalPartStates = getgenv().OriginalPartStates or {}

local noclipToggle = NoclipSection:Toggle({
    Name = "Enable Noclip",
    Flag = "NoclipEnabled",
    Default = false,
    Callback = function(Value)
        getgenv().NoclipActive = Value
        if Value then
            StartNoclip()
        else
            restoreAllParts()
        end
    end
})

noclipToggle:Keybind({
    Flag = "NoclipKeybind",
    Default = Enum.KeyCode.J,
    Mode = "Toggle",
    Callback = function()
        local state = not getgenv().NoclipActive
        getgenv().NoclipActive = state
        noclipToggle:Set(state)
        if state then
            StartNoclip()
        else
            restoreAllParts()
        end
    end
})

-- ============================================
-- WHITELIST SUB PAGE
-- ============================================
local WLMainSection = WhitelistSub:Section({
    Name = "Whitelisted Players",
    Side = 1
})

-- Label untuk menampilkan jumlah whitelist
local wlStatusLabel = WLMainSection:Label({
    Name = "Whitelisted: 0 players"
})

-- Fungsi untuk refresh whitelist display
local function RefreshWhitelistDisplay()
    local count = 0
    for _ in pairs(Whitelist) do
        count = count + 1
    end
    wlStatusLabel:Set("Whitelisted: " .. count .. " players")
end

-- Tombol untuk menambah player ke whitelist
WLMainSection:Textbox({
    Name = "Add Player to Whitelist",
    Flag = "AddWhitelist",
    Default = "",
    Placeholder = "Enter player name...",
    Finished = true,
    Callback = function(Value)
        if Value and Value ~= "" then
            local found = false
            for _, plr in ipairs(game.Players:GetPlayers()) do
                if string.lower(plr.Name) == string.lower(Value) or string.lower(plr.DisplayName) == string.lower(Value) then
                    Whitelist[plr.Name] = true
                    found = true
                    Window:Notify({
                        Title = "Added to Whitelist",
                        Description = plr.Name .. " has been whitelisted!",
                        Duration = 3
                    })
                    RefreshWhitelistDisplay()
                    break
                end
            end
            if not found then
                Window:Notify({
                    Title = "Player Not Found",
                    Description = "Could not find player: " .. Value,
                    Duration = 3
                })
            end
        end
    end
})

-- Tombol hapus dari whitelist
WLMainSection:Textbox({
    Name = "Remove Player from Whitelist",
    Flag = "RemoveWhitelist",
    Default = "",
    Placeholder = "Enter player name...",
    Finished = true,
    Callback = function(Value)
        if Value and Value ~= "" then
            if Whitelist[Value] then
                Whitelist[Value] = nil
                Window:Notify({
                    Title = "Removed from Whitelist",
                    Description = Value .. " has been removed!",
                    Duration = 3
                })
                RefreshWhitelistDisplay()
            else
                Window:Notify({
                    Title = "Not Whitelisted",
                    Description = Value .. " is not in the whitelist.",
                    Duration = 3
                })
            end
        end
    end
})

-- Tombol reset whitelist
WLMainSection:Button({
    Name = "Clear All Whitelist",
    Callback = function()
        Window:Dialog({
            Title = "Clear Whitelist",
            Description = "Are you sure you want to clear all whitelisted players?"
        }):AddButton("Yes", function()
            for name in pairs(Whitelist) do
                Whitelist[name] = nil
            end
            RefreshWhitelistDisplay()
            Window:Notify({
                Title = "Cleared",
                Description = "All whitelisted players have been removed.",
                Duration = 3
            })
        end):AddButton("No", function() end)
    end
})

-- List whitelisted players
local wlListSection = WhitelistSub:Section({
    Name = "Current Whitelist",
    Side = 2
})

local wlListLabel = wlListSection:Label({
    Name = "No whitelisted players yet."
})

local function UpdateWhitelistList()
    local names = {}
    for name in pairs(Whitelist) do
        table.insert(names, name)
    end
    if #names > 0 then
        wlListLabel:Set("• " .. table.concat(names, "\n• "))
    else
        wlListLabel:Set("No whitelisted players yet.")
    end
    RefreshWhitelistDisplay()
end

-- Override Whitelist functions untuk update UI
local originalAdd = function() end
for _, plr in ipairs(game.Players:GetPlayers()) do
    if Whitelist[plr.Name] then
        UpdateWhitelistList()
    end
end

-- ============================================
-- VISUALS PAGE
-- ============================================
local Visuals = Window:Page({
    Name = "Visuals",
    Description = "Visual enhancements",
    Icon = "lucide:eye"
})

local ESPSub = Visuals:SubPage({
    Name = "ESP",
    Icon = "lucide:eye",
    DisplayName = true
})

local ESPMainSection = ESPSub:Section({
    Name = "ESP Settings",
    Side = 1
})

ESPMainSection:Toggle({
    Name = "Enable ESP",
    Flag = "ESPEnabled",
    Default = false,
    Callback = function(Value)
        print("ESP Enabled:", Value)
        -- Disini Anda bisa tambahkan logika ESP
    end
})

ESPMainSection:Toggle({
    Name = "Box ESP",
    Flag = "BoxESP",
    Default = true,
    Callback = function(Value)
        print("Box ESP:", Value)
    end
})

ESPMainSection:Toggle({
    Name = "Name ESP",
    Flag = "NameESP",
    Default = true,
    Callback = function(Value)
        print("Name ESP:", Value)
    end
})

ESPMainSection:Toggle({
    Name = "Health Bar",
    Flag = "HealthBar",
    Default = true,
    Callback = function(Value)
        print("Health Bar:", Value)
    end
})

ESPMainSection:Label({
    Name = "ESP Color"
}):Colorpicker({
    Flag = "ESPColor",
    Default = Color3.fromRGB(0, 255, 0),
    Callback = function(Color)
        print("ESP Color:", Color)
    end
})

ESPMainSection:Slider({
    Name = "ESP Distance",
    Flag = "ESPDistance",
    Default = 500,
    Min = 50,
    Max = 1000,
    Decimals = 0,
    Suffix = " studs",
    Callback = function(Value)
        print("ESP Distance:", Value)
    end
})

-- Status widget
local statusWidget = ESPSub:Section({
    Name = "ESP Status",
    Side = 2
})

local playerCountStatus = statusWidget:Status({
    Name = "Players"
})

local fpsStatus = statusWidget:Status({
    Name = "FPS"
})

task.spawn(function()
    while task.wait(1) do
        playerCountStatus:Set("Players: " .. #game.Players:GetPlayers())
        fpsStatus:Set("FPS: " .. math.floor(1 / task.wait()))
    end
end)

-- ============================================
-- SETTINGS PAGE
-- ============================================
local SettingsPage = Window:CreateSettingsPage()
SettingsPage:CreateConfigsSection()
SettingsPage:CreateThemingSection()

-- ============================================
-- AUTO-LOAD CONFIG
-- ============================================
Library:CheckForAutoLoad()

-- ============================================
-- CORE SILENT AIM LOGIC (Dari skrip sebelumnya)
-- ============================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Drawing objects
local circle = Drawing.new("Circle")
circle.Radius = CFG.FOV_RADIUS
circle.Color = CFG.FOV_COLOR
circle.Thickness = CFG.FOV_THICK
circle.Filled = false
circle.NumSides = 64
circle.Visible = CFG.SHOW_FOV

local tracer = Drawing.new("Line")
tracer.Color = CFG.TRACER_COLOR
tracer.Thickness = 1.5
tracer.Visible = false

local CurrentTarget = nil

-- Helper Functions
local function getAimPosition()
    local mouseLoc = UserInputService:GetMouseLocation()
    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        local viewport = Camera.ViewportSize
        return Vector2.new(viewport.X / 2, (viewport.Y / 2) - CFG.MOBILE_Y_OFFSET)
    else
        return mouseLoc
    end
end

local function toScreen(worldPos)
    local v, on = Camera:WorldToViewportPoint(worldPos)
    return Vector2.new(v.X, v.Y), on
end

local function isAlive(char)
    local h = char and char:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function isWhitelisted(plr)
    return Whitelist[plr.Name] == true
end

local function getTarget()
    if not CFG.ENABLED then return nil end
    local mp = getAimPosition()
    local best = math.huge
    local found = nil
    local camPos = Camera.CFrame.Position

    for _, plr in Players:GetPlayers() do
        if plr == LP or isWhitelisted(plr) then continue end
        local char = plr.Character
        if not char or not isAlive(char) then continue end
        local targetPart = char:FindFirstChild(CFG.TARGET_PART)
        if not targetPart then continue end

        local sp, onScreen = toScreen(targetPart.Position)
        if not onScreen then continue end
        local screenDist = (sp - mp).Magnitude
        if screenDist < CFG.FOV_RADIUS then
            local worldDist = (camPos - targetPart.Position).Magnitude
            if worldDist < best then
                best = worldDist
                found = targetPart
            end
        end
    end
    return found
end

-- Metatable Hook
local Mouse = LP:GetMouse()
local mt = getrawmetatable(Mouse)
local oldIndex = mt.__index
setreadonly(mt, false)

mt.__index = function(self, key)
    if CurrentTarget and CFG.ENABLED and (key == "X" or key == "Y" or key == "Hit" or key == "Target") then
        if key == "Hit" then
            return CFrame.new(CurrentTarget.Position, Camera.CFrame.Position)
        elseif key == "Target" then
            return CurrentTarget
        elseif key == "X" then
            return Camera:WorldToScreenPoint(CurrentTarget.Position).X
        elseif key == "Y" then
            return Camera:WorldToScreenPoint(CurrentTarget.Position).Y
        end
    end
    return oldIndex(self, key)
end
setreadonly(mt, true)

-- Wallbang Hook
local function SearchGc(FunctionName)
    local Gc = getgc()
    for i, v in pairs(Gc) do
        if type(v) == "function" then
            local info = debug.getinfo(v)
            if info.name == FunctionName then return v end
        end
    end
end

local CastBlacklist = SearchGc("CastBlacklist")
local CastWhitelist = SearchGc("CastWhitelist")

if CastBlacklist and CastWhitelist then
    local OldCastBlacklist = hookfunction(CastBlacklist, function(...)
        local args = {...}
        if CFG.WALLBANG and CFG.ENABLED and CurrentTarget and CurrentTarget.Parent and typeof(args[1]) == "Vector3" and typeof(args[2]) == "Vector3" then
            local dir = CurrentTarget.Position - args[1]
            return CastWhitelist(args[1], dir.Unit * 999999, {CurrentTarget.Parent})
        end
        return OldCastBlacklist(...)
    end)
end

-- Gun Mod
local function modifyGun(tool)
    if tool:IsA("Tool") and tool:FindFirstChild("Setting") then
        local success, settings = pcall(require, tool.Setting)
        if success and type(settings) == "table" then
            settings.Range = 999999
            settings.Accuracy = 9999
            settings.SpreadX = 0
            settings.SpreadY = 0
            settings.Recoil = 10
        end
    end
end

local function setupCharacter(character)
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") then modifyGun(child) end
    end
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then modifyGun(child) end
    end)
end

if LP.Character then setupCharacter(LP.Character) end
LP.CharacterAdded:Connect(setupCharacter)

-- Noclip Functions
local function restoreAllParts()
    for part, state in pairs(getgenv().OriginalPartStates) do
        if part and part.Parent then
            pcall(function()
                if part.CanCollide ~= state.CanCollide then part.CanCollide = state.CanCollide end
                if part.CanTouch ~= state.CanTouch then part.CanTouch = state.CanTouch end
            end)
        end
    end
    table.clear(getgenv().OriginalPartStates)
end

local NoclipConnection = nil
local function StartNoclip()
    if NoclipConnection then NoclipConnection:Disconnect() end
    
    local charCache, hrpCache, charParts
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude

    local function updateCharCache()
        local charsFolder = workspace:FindFirstChild("Characters")
        local c = charsFolder and charsFolder:FindFirstChild(LP.Name) or LP.Character
        if not c then return false end
        charCache = c
        hrpCache = c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart or c:FindFirstChildWhichIsA("BasePart")
        charParts = {}
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then charParts[p] = true end
        end
        params.FilterDescendantsInstances = {c}
        return true
    end

    local function getHRP()
        if not charCache or not charCache.Parent then updateCharCache() end
        return hrpCache, charCache
    end

    local function isProtected(part, model)
        if part:FindFirstAncestorOfClass("Tool") then return true end
        if model and model:FindFirstChildOfClass("VehicleSeat", true) then return true end
        if part.Size.X > 300 or part.Size.Z > 300 then return true end
        local pName = string.lower(part.Name)
        local mName = model and string.lower(model.Name) or ""
        if string.find(pName, "baseplate") or string.find(pName, "floor") or string.find(pName, "lantai") or 
           string.find(pName, "stair") or string.find(pName, "step") or string.find(pName, "tangga") or 
           string.find(pName, "weapon") or string.find(pName, "gun") or string.find(pName, "sword") or 
           string.find(pName, "mobil") or string.find(pName, "car") or string.find(pName, "vehicle") then
            return true
        end
        if string.find(mName, "stair") or string.find(mName, "vehicle") or string.find(mName, "car") or string.find(mName, "mobil") then
            return true
        end
        return false
    end

    local function isWalkableSurface(part, feetY)
        if not feetY then return false end
        local topY = part.Position.Y + part.Size.Y/2
        if part.CFrame.UpVector.Y > 0.6 and topY <= feetY + 1 and topY >= feetY - 2.5 then
            return true
        end
        return false
    end

    local function noclipPart(part, feetY)
        if charParts and charParts[part] then return end
        if isWalkableSurface(part, feetY) then return end
        local model = part:FindFirstAncestorWhichIsA("Model")
        if isProtected(part, model) then return end
        if not getgenv().OriginalPartStates[part] then
            getgenv().OriginalPartStates[part] = {
                CanCollide = part.CanCollide,
                CanTouch = part.CanTouch
            }
        end
        if part.CanCollide then part.CanCollide = false end
        if part.CanTouch then part.CanTouch = false end
    end

    local function processTarget(part, feetY)
        local model = part:FindFirstAncestorWhichIsA("Model")
        if model and model:FindFirstChildOfClass("Humanoid") then
            for _, p in ipairs(model:GetDescendants()) do
                if p:IsA("BasePart") then noclipPart(p, feetY) end
            end
        else
            noclipPart(part, feetY)
        end
    end

    local function findSolidBelow(origin)
        local ray = workspace:Raycast(origin, Vector3.new(0, -20, 0), params)
        if ray and ray.Instance then
            local p = ray.Instance
            if p:IsA("BasePart") and not p:IsA("Terrain") and p.CFrame.UpVector.Y > 0.5 then
                return p
            end
        end
        return nil
    end

    local tickCounter = 0
    local cleanupTimer = 0

    NoclipConnection = RunService.Heartbeat:Connect(function(dt)
        if not getgenv().NoclipActive then return end
        local hrp = getHRP()
        if not hrp then return end
        local feetY = hrp.Position.Y - 3
        local origin = hrp.Position

        tickCounter = tickCounter + 1
        if tickCounter % 3 == 0 then
            local solid = findSolidBelow(origin)
            if solid and not solid.CanCollide then
                solid.CanCollide = true
            end
        end

        for _, part in ipairs(hrp:GetTouchingParts()) do
            processTarget(part, feetY)
        end
        local look = hrp.CFrame.LookVector * 4
        local rayLook = workspace:Raycast(origin, look, params)
        if rayLook and rayLook.Instance then processTarget(rayLook.Instance, feetY) end

        cleanupTimer = cleanupTimer + dt
        if cleanupTimer >= 2 then
            cleanupTimer = 0
            local hrpPos = hrp.Position
            for part, state in pairs(getgenv().OriginalPartStates) do
                if not part or not part.Parent then
                    getgenv().OriginalPartStates[part] = nil
                else
                    if (part.Position - hrpPos).Magnitude > 60 then
                        pcall(function()
                            part.CanCollide = state.CanCollide
                            part.CanTouch = state.CanTouch
                        end)
                        getgenv().OriginalPartStates[part] = nil
                    end
                end
            end
        end
    end)
end

-- Main Render Loop
RunService.RenderStepped:Connect(function()
    local mp = getAimPosition()
    CurrentTarget = getTarget()

    circle.Position = mp
    circle.Visible = CFG.SHOW_FOV and CFG.ENABLED
    circle.Radius = CFG.FOV_RADIUS
    circle.Color = CFG.FOV_COLOR

    if CurrentTarget and CFG.ENABLED then
        local sp, on = toScreen(CurrentTarget.Position)
        if on then
            tracer.From = mp
            tracer.To = sp
            tracer.Visible = CFG.SHOW_TRACER
            tracer.Color = CFG.TRACER_COLOR
        else
            tracer.Visible = false
        end
    else
        tracer.Visible = false
    end
end)

-- ============================================
-- NOTIFICATIONS
-- ============================================
Window:Notify({
    Title = "luzor",
    Description = "Script loaded successfully!",
    Duration = 3
})

print("luzor UI loaded with Ather-Hub Library!")