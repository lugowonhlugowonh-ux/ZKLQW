local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

-- // LOADING SCREEN ELEGANT
do
    local LoadingGui = Instance.new("ScreenGui")
    LoadingGui.Name = "luzor_load_" .. HttpService:GenerateGUID(false)
    LoadingGui.IgnoreGuiInset = true
    LoadingGui.ResetOnSpawn = false
    LoadingGui.DisplayOrder = 9999
    LoadingGui.Parent = CoreGui

    local CenterContainer = Instance.new("Frame", LoadingGui)
    CenterContainer.Size = UDim2.new(0, 320, 0, 120)
    CenterContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    CenterContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    CenterContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    CenterContainer.BackgroundTransparency = 0.05

    local CCorner = Instance.new("UICorner", CenterContainer)
    CCorner.CornerRadius = UDim.new(0, 8)
    local CStroke = Instance.new("UIStroke", CenterContainer)
    CStroke.Color = Color3.fromRGB(108, 221, 255)
    CStroke.Thickness = 1

    local Title = Instance.new("TextLabel", CenterContainer)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Position = UDim2.new(0, 0, 0, 25)
    Title.BackgroundTransparency = 1
    Title.Text = "luzor"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 24

    local Shimmer = Instance.new("UIGradient", Title)
    Shimmer.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.45, Color3.fromRGB(108, 221, 255)),
        ColorSequenceKeypoint.new(0.55, Color3.fromRGB(108, 221, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    Shimmer.Offset = Vector2.new(-1, 0)

    task.spawn(function()
        while LoadingGui.Parent do
            TweenService:Create(Shimmer, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Offset = Vector2.new(1, 0)}):Play()
            task.wait(1.5)
            Shimmer.Offset = Vector2.new(-1, 0)
        end
    end)

    local SubText = Instance.new("TextLabel", CenterContainer)
    SubText.Size = UDim2.new(1, 0, 0, 20)
    SubText.Position = UDim2.new(0, 0, 0, 60)
    SubText.BackgroundTransparency = 1
    SubText.Text = "initializing system"
    SubText.TextColor3 = Color3.fromRGB(150, 150, 150)
    SubText.Font = Enum.Font.Gotham
    SubText.TextSize = 12

    local BarBg = Instance.new("Frame", CenterContainer)
    BarBg.Size = UDim2.new(1, -40, 0, 2)
    BarBg.Position = UDim2.new(0, 20, 0, 90)
    BarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    BarBg.BorderSizePixel = 0

    local BarFill = Instance.new("Frame", BarBg)
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundColor3 = Color3.fromRGB(108, 221, 255)
    BarFill.BorderSizePixel = 0

    local texts = {"initializing system", "bypassing restrictions", "fetching modules", "rendering interface", "finalizing setup"}
    local ti = 1
    task.spawn(function()
        while task.wait(0.5) do
            ti = ti + 1
            if ti > #texts then ti = 1 end
            TweenService:Create(SubText, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {TextTransparency = 1}):Play()
            task.wait(0.3)
            SubText.Text = texts[ti]
            TweenService:Create(SubText, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {TextTransparency = 0}):Play()
        end
    end)

    TweenService:Create(BarFill, TweenInfo.new(4.5, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    task.wait(4.8)

    TweenService:Create(CenterContainer, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {BackgroundTransparency = 1}):Play()
    TweenService:Create(CStroke, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {Transparency = 1}):Play()
    TweenService:Create(Title, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {TextTransparency = 1}):Play()
    TweenService:Create(SubText, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {TextTransparency = 1}):Play()
    TweenService:Create(BarBg, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {BackgroundTransparency = 1}):Play()
    TweenService:Create(BarFill, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {BackgroundTransparency = 1}):Play()
    task.wait(0.6)
    LoadingGui:Destroy()
end

-- // CORE ENGINE & UI BUILDER
local Library = {}

local function Create(className, properties)
    local instance = Instance.new(className)
    if className == "TextBox" then instance.Text = "" end
    for k, v in pairs(properties or {}) do instance[k] = v end
    if (className == "TextLabel" or className == "TextButton" or className == "TextBox") then
        if properties.TextSize and properties.RichText ~= true then
            instance.TextScaled = true
            local constraint = Instance.new("UITextSizeConstraint")
            constraint.MaxTextSize = properties.TextSize
            constraint.MinTextSize = 6
            constraint.Parent = instance
        end
    end
    return instance
end

local function BuildSearchIndex(card)
    local parts = {}
    for _, desc in ipairs(card:GetDescendants()) do
        if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
            if desc.Text and desc.Text ~= "" then
                table.insert(parts, desc.Text:lower())
            end
        end
    end
    return table.concat(parts, " ")
end

local function Tween(instance, properties, duration)
    duration = duration or 0.25
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function AddBounce(button, scaleFactor)
    scaleFactor = scaleFactor or 0.96
    local scaleObj = button:FindFirstChild("UIScale") or Create("UIScale", {Parent = button, Scale = 1})
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Tween(scaleObj, {Scale = scaleFactor}, 0.15)
        end
    end)
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Tween(scaleObj, {Scale = 1}, 0.15)
        end
    end)
    button.MouseLeave:Connect(function()
        Tween(scaleObj, {Scale = 1}, 0.15)
    end)
end

local function MakeDraggable(topbar, object)
    topbar.Active = true
    object.Active = true
    local dragging, dragInput, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(object, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.08)
        end
    end)
end

local AccentColor = Color3.fromRGB(108, 221, 255)
local BackgroundColor = Color3.fromRGB(18, 18, 20)
local CardColor = Color3.fromRGB(24, 24, 27)
local HoverColor = Color3.fromRGB(35, 35, 40)
local TextColor = Color3.fromRGB(240, 240, 240)
local SubTextColor = Color3.fromRGB(150, 150, 150)
local GlobalNotifContainer

function Library:Notify(options)
    if not GlobalNotifContainer then return end
    local title = options.Title or "Notification"
    local desc = options.Description or "Information updated."
    local duration = options.Duration or 3

    local Notif = Create("Frame", {Parent = GlobalNotifContainer, BackgroundColor3 = Color3.fromRGB(20, 20, 22), Size = UDim2.new(1, 0, 0, 65), BackgroundTransparency = 1, ZIndex = 201, ClipsDescendants = true})
    Create("UICorner", {Parent = Notif, CornerRadius = UDim.new(0, 8)})
    local Stroke = Create("UIStroke", {Parent = Notif, Color = AccentColor, Thickness = 1, Transparency = 1})
    local TitleText = Create("TextLabel", {Parent = Notif, Text = title, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = TextColor, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 15), Size = UDim2.new(1, -30, 0, 15), TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 202})
    local DescText = Create("TextLabel", {Parent = Notif, Text = desc, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = SubTextColor, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 32), Size = UDim2.new(1, -30, 0, 15), TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 202})

    Tween(Notif, {BackgroundTransparency = 0}, 0.3)
    Tween(Stroke, {Transparency = 0}, 0.3)
    Tween(TitleText, {TextTransparency = 0}, 0.3)
    Tween(DescText, {TextTransparency = 0}, 0.3)

    task.delay(duration, function()
        Tween(Notif, {BackgroundTransparency = 1}, 0.4)
        Tween(Stroke, {Transparency = 1}, 0.4)
        Tween(TitleText, {TextTransparency = 1}, 0.4)
        Tween(DescText, {TextTransparency = 1}, 0.4)
        task.wait(0.4)
        Notif:Destroy()
    end)
end

function Library:CreateWindow(options)
    local hubName = "luzor"
    local subText = "South Bronx: The Trenches"
    local subColor = AccentColor
    local sphWords = "open"
    local sphImage = nil
    local topbarLogo = nil
    local logoSize = 32

    if type(options) == "table" then
        hubName = options.Title or hubName
        subText = options.Subtitle or subText
        subColor = options.SubtitleColor or subColor
        if options.SphereWords ~= nil then
            local wordList = string.split(tostring(options.SphereWords), " ")
            if #wordList > 2 then sphWords = wordList[1] .. " " .. wordList[2] else sphWords = tostring(options.SphereWords) end
        end
        sphImage = options.SphereImage
        topbarLogo = options.Logo
        logoSize = options.LogoSize or 32
    elseif type(options) == "string" then
        hubName = options
    end

    local uniqueID = HttpService:GenerateGUID(false)
    local ScreenGui = Create("ScreenGui", {
        Name = "luzor_UI_" .. uniqueID,
        Parent = RunService:IsStudio() and game.Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui,
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })

    local NotifContainer = Create("Frame", {
        Parent = ScreenGui,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 320, 1, -20),
        Position = UDim2.new(1, -340, 0, 10),
        ZIndex = 200,
        Active = false
    })
    Create("UIListLayout", {Parent = NotifContainer, VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12)})
    GlobalNotifContainer = NotifContainer

    -- UI dikecilkan ke 76% (Scale 0.76)
    local MainFrame = Create("Frame", {Parent = ScreenGui, BackgroundColor3 = BackgroundColor, Size = UDim2.new(0, 650, 0, 420), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), ClipsDescendants = true, BackgroundTransparency = 1, Active = true})
    local MainScale = Create("UIScale", {Parent = MainFrame, Scale = 0.5})
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 8)})
    local MainStroke = Create("UIStroke", {Parent = MainFrame, Color = AccentColor, Thickness = 1})

    Tween(MainScale, {Scale = 0.76}, 0.5)
    Tween(MainFrame, {BackgroundTransparency = 0}, 0.5)

    local BottomDragHitbox = Create("Frame", {Parent = ScreenGui, BackgroundTransparency = 1, Size = UDim2.new(0, 350, 0, 30), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 145, Active = true})
    local FloatingBottomBar = Create("Frame", {Parent = BottomDragHitbox, BackgroundColor3 = CardColor, BackgroundTransparency = 0, Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0.5, -3), ZIndex = 146})
    Create("UICorner", {Parent = FloatingBottomBar, CornerRadius = UDim.new(1, 0)})
    local BottomBarStroke = Create("UIStroke", {Parent = FloatingBottomBar, Color = AccentColor, Thickness = 1, Transparency = 0})
    MakeDraggable(BottomDragHitbox, MainFrame)

    RunService.RenderStepped:Connect(function()
        if MainFrame and MainFrame.Visible then
            BottomDragHitbox.Visible = true
            local currentScale = MainScale.Scale
            local frameHeight = 420 * currentScale
            local frameWidth = 650 * currentScale
            BottomDragHitbox.Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset + (frameHeight / 2) + 20)
            BottomDragHitbox.Size = UDim2.new(0, frameWidth * 0.6, 0, 30 * currentScale)
            FloatingBottomBar.Size = UDim2.new(1, 0, 0, 6 * currentScale)
            FloatingBottomBar.Position = UDim2.new(0, 0, 0.5, -(3 * currentScale))
        else
            BottomDragHitbox.Visible = false
        end
    end)

    local TopBar = Create("Frame", {Parent = MainFrame, BackgroundColor3 = BackgroundColor, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0, 0), Active = true})
    MakeDraggable(TopBar, MainFrame)

    local titleOffsetX = 15
    if topbarLogo then
        local TopbarIcon = Create("ImageLabel", {Parent = TopBar, BackgroundTransparency = 1, Size = UDim2.new(0, logoSize, 0, logoSize), Position = UDim2.new(0, 8, 0.5, -(logoSize / 2)), Image = topbarLogo, ScaleType = Enum.ScaleType.Fit})
        titleOffsetX = 8 + logoSize + 8
    end

    local TitleContainer = Create("Frame", {Parent = TopBar, BackgroundTransparency = 1, Size = UDim2.new(0, 250, 1, 0), Position = UDim2.new(0, titleOffsetX, 0, 0)})
    local Title = Create("TextLabel", {Parent = TitleContainer, Text = hubName, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = TextColor, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 5), Size = UDim2.new(1, 0, 0, 16), TextXAlignment = Enum.TextXAlignment.Left})
    local Subtitle = Create("TextLabel", {Parent = TitleContainer, Text = subText, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = subColor, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 22), Size = UDim2.new(1, 0, 0, 12), TextXAlignment = Enum.TextXAlignment.Left})

    local SearchBar = Create("Frame", {Parent = TopBar, BackgroundColor3 = CardColor, Size = UDim2.new(0, 250, 0, 26), Position = UDim2.new(0, 270, 0.5, -13)})
    Create("UICorner", {Parent = SearchBar, CornerRadius = UDim.new(0, 6)})
    local SearchIcon = Create("ImageLabel", {Parent = SearchBar, BackgroundTransparency = 1, Image = "rbxassetid://6031154871", ImageColor3 = SubTextColor, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 8, 0.5, -7)})
    local SearchInput = Create("TextBox", {Parent = SearchBar, BackgroundTransparency = 1, Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 30, 0, 0), Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = TextColor, PlaceholderText = "Search..", TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false})

    local CloseBtn = Create("TextButton", {Parent = TopBar, Text = "X", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(1, -35, 0, 0)})
    local MinBtn = Create("TextButton", {Parent = TopBar, Text = "—", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(1, -65, 0, 0)})

    local Sidebar = Create("Frame", {Parent = MainFrame, BackgroundColor3 = BackgroundColor, BackgroundTransparency = 1, Size = UDim2.new(0, 160, 1, -40), Position = UDim2.new(0, 0, 0, 40), Active = true})
    local TabSearchBox = Create("TextBox", {Parent = Sidebar, BackgroundColor3 = CardColor, Size = UDim2.new(1, -20, 0, 26), Position = UDim2.new(0, 10, 0, 5), Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = TextColor, PlaceholderText = "Search tabs...", TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false})
    Create("UIPadding", {Parent = TabSearchBox, PaddingLeft = UDim.new(0, 8)})
    Create("UICorner", {Parent = TabSearchBox, CornerRadius = UDim.new(0, 4)})
    Create("UIStroke", {Parent = TabSearchBox, Color = Color3.fromRGB(45, 45, 50), Thickness = 1})

    local TabContainer = Create("ScrollingFrame", {Parent = Sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, -15, 1, -40), Position = UDim2.new(0, 10, 0, 40), ScrollBarThickness = 0})
    Create("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
    local Divider = Create("Frame", {Parent = MainFrame, BackgroundColor3 = Color3.fromRGB(40, 40, 45), BorderSizePixel = 0, Size = UDim2.new(0, 1, 1, -40), Position = UDim2.new(0, 160, 0, 40)})

    local ContentArea = Create("Frame", {Parent = MainFrame, BackgroundTransparency = 1, Size = UDim2.new(1, -165, 1, -40), Position = UDim2.new(0, 165, 0, 40), Active = true})

    local Sphere = Create("TextButton", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0, Size = UDim2.new(0, 45, 0, 45), Position = UDim2.new(0.1, 0, 0.1, 0), AnchorPoint = Vector2.new(0.5, 0.5), Visible = true, AutoButtonColor = false, ClipsDescendants = true})
    Create("UICorner", {Parent = Sphere, CornerRadius = UDim.new(1, 0)})
    local SphereTextLabel = Create("TextLabel", {Parent = Sphere, Text = sphWords, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), TextTransparency = 0, Visible = true})
    MakeDraggable(Sphere, Sphere)

    local Window = {CurrentTab = nil, Tabs = {}, Title = Title, AllCards = {}, MainFrame = MainFrame, CurrentTransparency = 0, ConfigElements = {}, ScreenGui = ScreenGui}

    function Window:ToggleUI()
        if MainFrame.Visible then
            Tween(MainScale, {Scale = 0}, 0.6)
            Tween(MainFrame, {BackgroundTransparency = 1}, 0.6)
            Tween(FloatingBottomBar, {BackgroundTransparency = 1}, 0.6)
            Tween(BottomBarStroke, {Transparency = 1}, 0.6)
            task.wait(0.4)
            MainFrame.Visible = false
            BottomDragHitbox.Visible = false
        else
            MainFrame.Visible = true
            BottomDragHitbox.Visible = true
            Tween(MainScale, {Scale = 0.76}, 0.5)
            Tween(MainFrame, {BackgroundTransparency = Window.CurrentTransparency}, 0.5)
            Tween(FloatingBottomBar, {BackgroundTransparency = Window.CurrentTransparency > 0 and 0.2 or 0}, 0.5)
            Tween(BottomBarStroke, {Transparency = 0}, 0.5)
        end
    end

    function Window:SetTransparency(val)
        Window.CurrentTransparency = val
        if MainFrame.Visible then
            Tween(MainFrame, {BackgroundTransparency = val}, 0.3)
            Tween(FloatingBottomBar, {BackgroundTransparency = val > 0 and 0.2 or 0}, 0.3)
        end
    end

    MinBtn.MouseButton1Click:Connect(function() Window:ToggleUI() end)
    Sphere.MouseButton1Click:Connect(function() Window:ToggleUI() end)

    local Popup = Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ZIndex = 100, Visible = false, Active = true})
    local PopupCard = Create("Frame", {Parent = Popup, BackgroundColor3 = Color3.fromRGB(20, 20, 24), Size = UDim2.new(0, 320, 0, 160), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 101, BackgroundTransparency = 1, ClipsDescendants = false})
    Create("UICorner", {Parent = PopupCard, CornerRadius = UDim.new(0, 12)})
    local PopupScale = Create("UIScale", {Parent = PopupCard, Scale = 0.8})
    local PopupStroke = Create("UIStroke", {Parent = PopupCard, Color = AccentColor, Thickness = 1, Transparency = 1})
    local PopupTitle = Create("TextLabel", {Parent = PopupCard, Text = "exit luzor", Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = TextColor, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 25), ZIndex = 102, TextTransparency = 1, TextXAlignment = Enum.TextXAlignment.Center})
    local PopupText = Create("TextLabel", {Parent = PopupCard, Text = "are you sure you want to close this ui?", Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 0, 40), Position = UDim2.new(0, 20, 0, 55), ZIndex = 102, TextTransparency = 1, TextXAlignment = Enum.TextXAlignment.Center, TextWrapped = true})
    
    local YesBtn = Create("TextButton", {Parent = PopupCard, Text = "Confirm", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = AccentColor, Size = UDim2.new(0, 125, 0, 36), Position = UDim2.new(0.5, 10, 0, 105), ZIndex = 102, BackgroundTransparency = 1, TextTransparency = 1, AutoButtonColor = false})
    Create("UICorner", {Parent = YesBtn, CornerRadius = UDim.new(0, 6)})
    AddBounce(YesBtn)
    
    local NoBtn = Create("TextButton", {Parent = PopupCard, Text = "Cancel", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = TextColor, BackgroundColor3 = Color3.fromRGB(40, 40, 45), Size = UDim2.new(0, 125, 0, 36), Position = UDim2.new(0.5, -135, 0, 105), ZIndex = 102, BackgroundTransparency = 1, TextTransparency = 1, AutoButtonColor = false})
    Create("UICorner", {Parent = NoBtn, CornerRadius = UDim.new(0, 6)})
    AddBounce(NoBtn)

    CloseBtn.MouseButton1Click:Connect(function()
        Popup.Visible = true
        Tween(Popup, {BackgroundTransparency = 0.5}, 0.3)
        Tween(PopupCard, {BackgroundTransparency = 0}, 0.3)
        Tween(PopupScale, {Scale = 1}, 0.3)
        Tween(PopupStroke, {Transparency = 0}, 0.3)
        Tween(PopupTitle, {TextTransparency = 0}, 0.3)
        Tween(PopupText, {TextTransparency = 0}, 0.3)
        Tween(YesBtn, {BackgroundTransparency = 0, TextTransparency = 0}, 0.3)
        Tween(NoBtn, {BackgroundTransparency = 0, TextTransparency = 0}, 0.3)
    end)

    YesBtn.MouseButton1Click:Connect(function()
        Tween(Popup, {BackgroundTransparency = 1}, 0.3)
        Tween(PopupCard, {BackgroundTransparency = 1}, 0.3)
        Tween(PopupStroke, {Transparency = 1}, 0.3)
        Tween(PopupTitle, {TextTransparency = 1}, 0.3)
        Tween(PopupText, {TextTransparency = 1}, 0.3)
        Tween(YesBtn, {BackgroundTransparency = 1, TextTransparency = 1}, 0.3)
        Tween(NoBtn, {BackgroundTransparency = 1, TextTransparency = 1}, 0.3)
        
        Tween(MainScale, {Scale = 0}, 0.8)
        Tween(MainFrame, {BackgroundTransparency = 1}, 0.8)
        Tween(FloatingBottomBar, {BackgroundTransparency = 1}, 0.8)
        Tween(BottomBarStroke, {Transparency = 1}, 0.8)
        Tween(Sphere, {Size = UDim2.new(0, 0, 0, 0)}, 0.8)
        Tween(SphereTextLabel, {TextTransparency = 1}, 0.8)

        for _, desc in ipairs(MainFrame:GetDescendants()) do
            if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
                Tween(desc, {TextTransparency = 1}, 0.8)
                if desc.BackgroundTransparency < 1 then Tween(desc, {BackgroundTransparency = 1}, 0.8) end
            elseif desc:IsA("ImageLabel") or desc:IsA("ImageButton") then
                Tween(desc, {ImageTransparency = 1}, 0.8)
            elseif desc:IsA("Frame") or desc:IsA("ScrollingFrame") then
                if desc.BackgroundTransparency < 1 then Tween(desc, {BackgroundTransparency = 1}, 0.8) end
            elseif desc:IsA("UIStroke") then
                Tween(desc, {Transparency = 1}, 0.8)
            end
        end
        task.wait(0.85)
        ScreenGui:Destroy()
    end)

    NoBtn.MouseButton1Click:Connect(function()
        Tween(Popup, {BackgroundTransparency = 1}, 0.3)
        Tween(PopupCard, {BackgroundTransparency = 1}, 0.3)
        Tween(PopupScale, {Scale = 0.8}, 0.3)
        Tween(PopupStroke, {Transparency = 1}, 0.3)
        Tween(PopupTitle, {TextTransparency = 1}, 0.3)
        Tween(PopupText, {TextTransparency = 1}, 0.3)
        Tween(YesBtn, {BackgroundTransparency = 1, TextTransparency = 1}, 0.3)
        Tween(NoBtn, {BackgroundTransparency = 1, TextTransparency = 1}, 0.3)
        task.wait(0.3)
        Popup.Visible = false
    end)

    TabSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = TabSearchBox.Text:lower()
        for _, tabInfo in ipairs(Window.Tabs) do
            if query == "" or string.find(tabInfo.Txt.Text:lower(), query) then
                tabInfo.Button.Visible = true
            else
                tabInfo.Button.Visible = false
            end
        end
    end)

    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchInput.Text:lower()
        if query == "" then
            for _, data in ipairs(Window.AllCards) do
                data.Card.Parent = data.OrigParent; data.Card.Visible = true
            end
        else
            if not Window.CurrentTab or not Window.CurrentTab.CurrentPage then return end
            local activeLeft = Window.CurrentTab.CurrentPage.LeftCol
            local activeRight = Window.CurrentTab.CurrentPage.RightCol
            local placeLeft = true
            for _, data in ipairs(Window.AllCards) do
                local card = data.Card
                if data.Tab == Window.CurrentTab then
                    if not data.SearchIndex then data.SearchIndex = BuildSearchIndex(card) end
                    local match = string.find(data.SearchIndex, query, 1, true)
                    if match then
                        card.Parent = placeLeft and activeLeft or activeRight; placeLeft = not placeLeft; card.Visible = true
                    else
                        card.Visible = false
                    end
                else
                    card.Parent = data.OrigParent; card.Visible = true
                end
            end
        end
    end)

    function Window:CreateTab(tabName, isDefault)
        local TabBtn = Create("TextButton", {Parent = TabContainer, Text = "", BackgroundColor3 = HoverColor, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 35), AutoButtonColor = false})
        Create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 6)})
        AddBounce(TabBtn, 0.98)
        local Indicator = Create("Frame", {Name = "Indicator", Parent = TabBtn, BackgroundColor3 = AccentColor, Size = UDim2.new(0, 3, 0, 0), Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)})
        Create("UICorner", {Parent = Indicator, CornerRadius = UDim.new(1, 0)})
        local Txt = Create("TextLabel", {Parent = TabBtn, Text = tabName, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 15, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})

        local TabContent = Create("Frame", {Parent = ContentArea, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false})
        local PageNav = Create("Frame", {Parent = TabContent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 35)})
        Create("UIListLayout", {Parent = PageNav, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 15), VerticalAlignment = Enum.VerticalAlignment.Center})
        local PageContainer = Create("Frame", {Parent = TabContent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -35), Position = UDim2.new(0, 0, 0, 35)})

        local TabConfig = {Button = TabBtn, Content = TabContent, Indicator = Indicator, Txt = Txt, Pages = {}, CurrentPage = nil}
        table.insert(Window.Tabs, TabConfig)

        TabBtn.MouseButton1Click:Connect(function()
            if Window.CurrentTab == TabConfig then return end
            if Window.CurrentTab then
                Tween(Window.CurrentTab.Button, {BackgroundTransparency = 1}, 0.2)
                Tween(Window.CurrentTab.Indicator, {Size = UDim2.new(0, 3, 0, 0)}, 0.2)
                Tween(Window.CurrentTab.Txt, {TextColor3 = SubTextColor}, 0.2)
                Window.CurrentTab.Content.Visible = false
            end
            Window.CurrentTab = TabConfig
            TabConfig.Content.Visible = true
            TabConfig.Content.Position = UDim2.new(0, 0, 0, 15)
            Tween(TabConfig.Content, {Position = UDim2.new(0, 0, 0, 0)}, 0.35)
            Tween(TabBtn, {BackgroundTransparency = 0}, 0.2)
            Tween(Indicator, {Size = UDim2.new(0, 3, 0, 18)}, 0.3)
            Tween(Txt, {TextColor3 = TextColor}, 0.2)

            if #TabConfig.Pages > 0 then
                local firstPage = TabConfig.Pages[1]
                if TabConfig.CurrentPage ~= firstPage then
                    if TabConfig.CurrentPage then
                        Tween(TabConfig.CurrentPage.Btn, {TextColor3 = SubTextColor}, 0)
                        Tween(TabConfig.CurrentPage.Highlight, {Size = UDim2.new(0, 0, 0, 2), BackgroundTransparency = 1}, 0)
                        TabConfig.CurrentPage.Scroll.Visible = false
                    end
                    TabConfig.CurrentPage = firstPage
                    firstPage.Scroll.Visible = true
                    firstPage.Scroll.Position = UDim2.new(0, 5, 0, 15)
                    Tween(firstPage.Scroll, {Position = UDim2.new(0, 5, 0, 5)}, 0.35)
                    Tween(firstPage.Btn, {TextColor3 = TextColor}, 0)
                    Tween(firstPage.Highlight, {Size = UDim2.new(1, 0, 0, 2), BackgroundTransparency = 0}, 0)
                end
            end
        end)

        function TabConfig:CreatePage(pageName)
            local PageBtn = Create("TextButton", {Parent = PageNav, Text = pageName, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X})
            local PageHighlight = Create("Frame", {Parent = PageBtn, BackgroundColor3 = AccentColor, Size = UDim2.new(0, 0, 0, 2), Position = UDim2.new(0.5, 0, 1, -5), AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1})
            
            local PageScroll = Create("ScrollingFrame", {Parent = PageContainer, BackgroundTransparency = 1, Size = UDim2.new(1, -10, 1, -10), Position = UDim2.new(0, 5, 0, 5), ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(60, 60, 65), Visible = false, BorderSizePixel = 0})
            local LeftColumn = Create("Frame", {Parent = PageScroll, BackgroundTransparency = 1, Size = UDim2.new(0.5, -5, 1, 0)})
            local RightColumn = Create("Frame", {Parent = PageScroll, BackgroundTransparency = 1, Size = UDim2.new(0.5, -5, 1, 0), Position = UDim2.new(0.5, 5, 0, 0)})
            
            local L_Layout = Create("UIListLayout", {Parent = LeftColumn, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
            local R_Layout = Create("UIListLayout", {Parent = RightColumn, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})

            L_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() PageScroll.CanvasSize = UDim2.new(0, 0, 0, 0) end)
            R_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() PageScroll.CanvasSize = UDim2.new(0, 0, 0, 0) end)

            local PageObj = {Scroll = PageScroll, Btn = PageBtn, Highlight = PageHighlight, Left = true, LeftCol = LeftColumn, RightCol = RightColumn}
            table.insert(TabConfig.Pages, PageObj)

            PageBtn.MouseButton1Click:Connect(function()
                if TabConfig.CurrentPage == PageObj then return end
                if TabConfig.CurrentPage then
                    Tween(TabConfig.CurrentPage.Btn, {TextColor3 = SubTextColor}, 0.2)
                    Tween(TabConfig.CurrentPage.Highlight, {Size = UDim2.new(0, 0, 0, 2), BackgroundTransparency = 1}, 0.2)
                    TabConfig.CurrentPage.Scroll.Visible = false
                end
                TabConfig.CurrentPage = PageObj
                PageObj.Scroll.Visible = true
                PageObj.Scroll.Position = UDim2.new(0, 5, 0, 20)
                Tween(PageObj.Scroll, {Position = UDim2.new(0, 5, 0, 5)}, 0.35)
                Tween(PageBtn, {TextColor3 = TextColor}, 0.2)
                Tween(PageHighlight, {Size = UDim2.new(1, 0, 0, 2), BackgroundTransparency = 0}, 0.3)
            end)

            if #TabConfig.Pages == 1 then
                TabConfig.CurrentPage = PageObj
                PageObj.Scroll.Visible = true
                PageBtn.TextColor3 = TextColor
                PageHighlight.Size = UDim2.new(1, 0, 0, 2)
                PageHighlight.BackgroundTransparency = 0
            end

            function PageObj:CreateSection(sectionName)
                local targetColumn = PageObj.Left and LeftColumn or RightColumn
                PageObj.Left = not PageObj.Left

                local SectionContainer = Create("Frame", {Parent = targetColumn, BackgroundColor3 = CardColor, Size = UDim2.new(1, 0, 0, 30), AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = true})
                Create("UICorner", {Parent = SectionContainer, CornerRadius = UDim.new(0, 6)})
                table.insert(Window.AllCards, {Card = SectionContainer, OrigParent = targetColumn, Tab = TabConfig, Page = PageObj, SearchIndex = nil})

                Create("TextLabel", {Parent = SectionContainer, Text = sectionName, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = TextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                
                local ItemContainer = Create("Frame", {Parent = SectionContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 30), AutomaticSize = Enum.AutomaticSize.Y})
                Create("UIPadding", {Parent = ItemContainer, PaddingBottom = UDim.new(0, 10), PaddingTop = UDim.new(0, 5)})
                Create("UIListLayout", {Parent = ItemContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})

                local Elements = {}

                function Elements:AddButton(name, callback, infoData)
                    local BtnFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30)})
                    local Btn = Create("TextButton", {Parent = BtnFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = TextColor, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), AutoButtonColor = false})
                    Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 4)})
                    Create("UIStroke", {Parent = Btn, Color = Color3.fromRGB(45, 45, 50), Thickness = 1})
                    AddBounce(Btn)

                    Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = HoverColor}, 0.2) end)
                    Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = BackgroundColor}, 0.2) end)
                    Btn.MouseButton1Click:Connect(function() if callback then callback() end end)
                end

                function Elements:AddToggle(name, default, callback, infoData)
                    local state = default or false
                    local TogFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24)})
                    Create("TextLabel", {Parent = TogFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                    
                    local Lever = Create("TextButton", {Parent = TogFrame, Text = "", BackgroundColor3 = state and AccentColor or Color3.fromRGB(45, 45, 50), Size = UDim2.new(0, 36, 0, 18), Position = UDim2.new(1, -46, 0.5, -9), AutoButtonColor = false})
                    Create("UICorner", {Parent = Lever, CornerRadius = UDim.new(1, 0)})
                    AddBounce(Lever)
                    
                    local Knob = Create("Frame", {Parent = Lever, BackgroundColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(0, 14, 0, 14), Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)})
                    Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})

                    local function internalSet(val)
                        state = val
                        Tween(Lever, {BackgroundColor3 = state and AccentColor or Color3.fromRGB(45, 45, 50)}, 0.3)
                        Tween(Knob, {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}, 0.3)
                        if callback then callback(state) end
                    end

                    Lever.MouseButton1Click:Connect(function() internalSet(not state) end)
                    Window.ConfigElements[name] = { Set = internalSet, Get = function() return state end }
                end

                function Elements:AddToggleWithBind(name, default, bindDefault, callback)
                    local state = default
                    local TogFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24)})
                    Create("TextLabel", {Parent = TogFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -120, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                    
                    local Lever = Create("TextButton", {Parent = TogFrame, Text = "", BackgroundColor3 = state and AccentColor or Color3.fromRGB(45, 45, 50), Size = UDim2.new(0, 36, 0, 18), Position = UDim2.new(1, -96, 0.5, -9), AutoButtonColor = false})
                    Create("UICorner", {Parent = Lever, CornerRadius = UDim.new(1, 0)})
                    local Knob = Create("Frame", {Parent = Lever, BackgroundColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(0, 14, 0, 14), Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)})
                    Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})

                    local bindState = bindDefault
                    local KeyBtn = Create("TextButton", {Parent = TogFrame, Text = bindState.Name, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = TextColor, BackgroundColor3 = Color3.fromRGB(40, 40, 45), Size = UDim2.new(0, 40, 0, 18), Position = UDim2.new(1, -46, 0.5, -9), AutoButtonColor = false})
                    Create("UICorner", {Parent = KeyBtn, CornerRadius = UDim.new(0, 4)})

                    local function internalSet(val)
                        state = val
                        Tween(Lever, {BackgroundColor3 = state and AccentColor or Color3.fromRGB(45, 45, 50)}, 0.3)
                        Tween(Knob, {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}, 0.3)
                        if callback then callback(state) end
                    end

                    Lever.MouseButton1Click:Connect(function() internalSet(not state) end)

                    local listening = false
                    KeyBtn.MouseButton1Click:Connect(function()
                        listening = true
                        KeyBtn.Text = "..."
                    end)
                    UserInputService.InputBegan:Connect(function(input, gpe)
                        if listening then
                            listening = false
                            if input.KeyCode ~= Enum.KeyCode.Unknown then
                                bindState = input.KeyCode
                                KeyBtn.Text = bindState.Name
                            else
                                KeyBtn.Text = bindState.Name
                            end
                        elseif input.KeyCode == bindState and not gpe then
                            internalSet(not state)
                        end
                    end)
                    Window.ConfigElements[name] = { Set = internalSet, Get = function() return state end }
                end

                function Elements:AddSlider(name, min, max, defaultVal, callback)
                    local frame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 45)})
                    local label = Create("TextLabel", {Parent = frame, Text = name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -60, 0, 20), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                    local valLabel = Create("TextLabel", {Parent = frame, Text = tostring(defaultVal), Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = TextColor, BackgroundTransparency = 1, Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0, 0), TextXAlignment = Enum.TextXAlignment.Right})
                    
                    local sliderBG = Create("TextButton", {Parent = frame, Text = "", BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, -20, 0, 8), Position = UDim2.new(0, 10, 0, 25), AutoButtonColor = false})
                    Create("UICorner", {Parent = sliderBG, CornerRadius = UDim.new(1, 0)})
                    Create("UIStroke", {Parent = sliderBG, Color = Color3.fromRGB(45, 45, 50), Thickness = 1})
                    
                    local fillPct = (defaultVal - min) / (max - min)
                    local sliderFill = Create("Frame", {Parent = sliderBG, BackgroundColor3 = AccentColor, Size = UDim2.new(fillPct, 0, 1, 0)})
                    Create("UICorner", {Parent = sliderFill, CornerRadius = UDim.new(1, 0)})

                    local dragging = false
                    sliderBG.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = true
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = false
                        end
                    end)
                    UserInputService.InputChanged:Connect(function(input)
                        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            local mouseLoc = UserInputService:GetMouseLocation()
                            local relX = math.clamp((mouseLoc.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
                            sliderFill.Size = UDim2.new(relX, 0, 1, 0)
                            local val = math.floor(min + ((max - min) * relX))
                            valLabel.Text = tostring(val)
                            if callback then callback(val) end
                        end
                    end)
                end

                function Elements:AddColorPicker(name, defaultColor, callback, infoData)
                    local color = defaultColor or Color3.fromRGB(255, 255, 255)
                    local h, s, v_hsv = color:ToHSV()
                    local dropped = false

                    local CFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), ClipsDescendants = true})
                    Create("TextLabel", {Parent = CFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -60, 0, 30), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                    
                    local DisplayBtn = Create("TextButton", {Parent = CFrame, Text = "", BackgroundColor3 = color, Size = UDim2.new(0, 30, 0, 16), Position = UDim2.new(1, -40, 0.5, -8), AutoButtonColor = false})
                    Create("UICorner", {Parent = DisplayBtn, CornerRadius = UDim.new(0, 4)})
                    Create("UIStroke", {Parent = DisplayBtn, Color = Color3.fromRGB(255,255,255), Transparency = 0.8, Thickness = 1})
                    AddBounce(DisplayBtn)

                    local PickerArea = Create("Frame", {Parent = CFrame, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, -20, 0, 110), Position = UDim2.new(0, 10, 0, 35)})
                    Create("UICorner", {Parent = PickerArea, CornerRadius = UDim.new(0, 4)})
                    
                    local PickerCloseBtn = Create("TextButton", {Parent = PickerArea, Text = "×", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = SubTextColor, BackgroundColor3 = Color3.fromRGB(30, 20, 20), Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -24, 0, 4), ZIndex = 50, AutoButtonColor = false})
                    Create("UICorner", {Parent = PickerCloseBtn, CornerRadius = UDim.new(0, 4)})
                    AddBounce(PickerCloseBtn)

                    PickerCloseBtn.MouseButton1Click:Connect(function()
                        dropped = false
                        Tween(CFrame, {Size = UDim2.new(1, 0, 0, 30)}, 0.3)
                    end)

                    local SVMap = Create("TextButton", {Parent = PickerArea, Text = "", BackgroundColor3 = Color3.fromHSV(h, 1, 1), Size = UDim2.new(1, -45, 0, 60), Position = UDim2.new(0, 10, 0, 10), AutoButtonColor = false, Active = true})
                    Create("UICorner", {Parent = SVMap, CornerRadius = UDim.new(0, 4)})
                    local WhiteGrad = Create("Frame", {Parent = SVMap, Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.new(1,1,1), ZIndex = 2})
                    Create("UIGradient", {Parent = WhiteGrad, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}), Rotation = 0})
                    Create("UICorner", {Parent = WhiteGrad, CornerRadius = UDim.new(0, 4)})
                    local BlackGrad = Create("Frame", {Parent = SVMap, Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.new(0,0,0), ZIndex = 3})
                    Create("UIGradient", {Parent = BlackGrad, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}), Rotation = 90})
                    Create("UICorner", {Parent = BlackGrad, CornerRadius = UDim.new(0, 4)})
                    local SVRing = Create("Frame", {Parent = BlackGrad, Size = UDim2.new(0, 8, 0, 8), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(s, 0, 1-v_hsv, 0), BackgroundColor3 = Color3.new(1,1,1), ZIndex = 4})
                    Create("UICorner", {Parent = SVRing, CornerRadius = UDim.new(1, 0)})
                    Create("UIStroke", {Parent = SVRing, Color = Color3.new(0,0,0), Thickness = 1})

                    local HueSlider = Create("TextButton", {Parent = PickerArea, Text = "", Size = UDim2.new(1, -20, 0, 12), Position = UDim2.new(0, 10, 0, 75), AutoButtonColor = false, BackgroundColor3 = Color3.new(1,1,1), Active = true})
                    Create("UICorner", {Parent = HueSlider, CornerRadius = UDim.new(0, 4)})
                    local HueGradient = Create("UIGradient", {Parent = HueSlider, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))})})
                    local HueRing = Create("Frame", {Parent = HueSlider, Size = UDim2.new(0, 5, 0, 12), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(h, 0, 0.5, 0), BackgroundColor3 = Color3.new(1,1,1)})
                    Create("UICorner", {Parent = HueRing, CornerRadius = UDim.new(0, 2)})
                    Create("UIStroke", {Parent = HueRing, Color = Color3.new(0,0,0), Thickness = 1})

                    local HexBox = Create("TextBox", {Parent = PickerArea, Text = "#"..color:ToHex():upper(), Font = Enum.Font.Code, TextSize = 12, TextColor3 = TextColor, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 92), ClearTextOnFocus = false})
                    Create("UICorner", {Parent = HexBox, CornerRadius = UDim.new(0, 4)})
                    Create("UIPadding", {Parent = HexBox, PaddingLeft = UDim.new(0, 5)})

                    local function internalSet(hexString)
                        if not string.find(hexString, "^#") then hexString = "#" .. hexString end
                        local s_check, c = pcall(function() return Color3.fromHex(hexString) end)
                        if s_check and c then
                            color = c
                            h, s, v_hsv = color:ToHSV()
                            DisplayBtn.BackgroundColor3 = color
                            SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                            SVRing.Position = UDim2.new(s, 0, 1-v_hsv, 0)
                            HueRing.Position = UDim2.new(h, 0, 0.5, 0)
                            HexBox.Text = "#"..color:ToHex():upper()
                            if callback then callback(color) end
                        end
                    end

                    local function UpdateColor()
                        color = Color3.fromHSV(h, s, v_hsv)
                        DisplayBtn.BackgroundColor3 = color
                        SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                        HexBox.Text = "#"..color:ToHex():upper()
                        if callback then callback(color) end
                    end

                    local draggingSV = false
                    local draggingHue = false
                    SVMap.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            draggingSV = true
                            if PageObj and PageObj.Scroll then PageObj.Scroll.ScrollingEnabled = false end
                        end
                    end)
                    HueSlider.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            draggingHue = true
                            if PageObj and PageObj.Scroll then PageObj.Scroll.ScrollingEnabled = false end
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            draggingSV = false
                            draggingHue = false
                            if PageObj and PageObj.Scroll then PageObj.Scroll.ScrollingEnabled = true end
                        end
                    end)
                    UserInputService.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                            if draggingSV then
                                local relX = math.clamp((input.Position.X - SVMap.AbsolutePosition.X) / SVMap.AbsoluteSize.X, 0, 1)
                                local relY = math.clamp((input.Position.Y - SVMap.AbsolutePosition.Y) / SVMap.AbsoluteSize.Y, 0, 1)
                                s = relX; v_hsv = 1 - relY
                                SVRing.Position = UDim2.new(s, 0, 1-v_hsv, 0)
                                UpdateColor()
                            elseif draggingHue then
                                local relX = math.clamp((input.Position.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
                                h = relX
                                HueRing.Position = UDim2.new(h, 0, 0.5, 0)
                                UpdateColor()
                            end
                        end
                    end)
                    HexBox.FocusLost:Connect(function() internalSet(HexBox.Text) end)
                    DisplayBtn.MouseButton1Click:Connect(function()
                        dropped = not dropped
                        Tween(CFrame, {Size = UDim2.new(1, 0, 0, dropped and 150 or 30)}, 0.3)
                    end)
                    Window.ConfigElements[name] = { Set = internalSet, Get = function() return color:ToHex() end }
                end

                function Elements:AddKeybind(name, defaultKey, callback)
                    local bindState = defaultKey
                    local KFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24)})
                    Create("TextLabel", {Parent = KFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -70, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                    
                    local KeyBtn = Create("TextButton", {Parent = KFrame, Text = bindState.Name, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = TextColor, BackgroundColor3 = Color3.fromRGB(40, 40, 45), Size = UDim2.new(0, 50, 0, 20), Position = UDim2.new(1, -60, 0.5, -10), AutoButtonColor = false})
                    Create("UICorner", {Parent = KeyBtn, CornerRadius = UDim.new(0, 4)})
                    
                    local listening = false
                    KeyBtn.MouseButton1Click:Connect(function()
                        listening = true
                        KeyBtn.Text = "..."
                    end)
                    UserInputService.InputBegan:Connect(function(input, gpe)
                        if listening then
                            listening = false
                            if input.KeyCode ~= Enum.KeyCode.Unknown then
                                bindState = input.KeyCode
                                KeyBtn.Text = bindState.Name
                            else
                                KeyBtn.Text = bindState.Name
                            end
                        elseif input.KeyCode == bindState and not gpe then
                            if callback then callback(bindState) end
                        end
                    end)
                end

                return Elements
            end

            return PageObj
        end

        if isDefault then
            TabBtn.BackgroundTransparency = 0
            Indicator.Size = UDim2.new(0, 3, 0, 18)
            Txt.TextColor3 = TextColor
            TabContent.Visible = true
            Window.CurrentTab = TabConfig
        end

        return TabConfig
    end

    return Window
end

-- // ============================================
-- // KILL AURA & TELEPORT FEATURES
-- // ============================================

local KillAuraCFG = {
    ENABLED = false,
    RADIUS = 350,
    HITBOX_PART = "Head",
    TEAM_CHECK = false,
    WALL_CHECK = false
}

local TeleportCFG = {
    ENABLED = false,
    TARGET_PART = "HumanoidRootPart"
}

local SavedLocations = {}
local SelectedLocation = nil

-- Get nearest player
local function GetNearestPlayer()
    local nearest = nil
    local nearestDist = KillAuraCFG.RADIUS
    local lChar = LP.Character
    local lHRP = lChar and lChar:FindFirstChild("HumanoidRootPart")
    if not lHRP then return nil end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        if KillAuraCFG.TEAM_CHECK and plr.Team == LP.Team then continue end
        
        local char = plr.Character
        if not char then continue end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        local hrp = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
        if not hrp then continue end
        
        local dist = (hrp.Position - lHRP.Position).Magnitude
        if dist < nearestDist then
            if KillAuraCFG.WALL_CHECK then
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Exclude
                params.FilterDescendantsInstances = {lChar}
                local ray = workspace:Raycast(lHRP.Position, (hrp.Position - lHRP.Position).Unit * dist, params)
                if ray then
                    local hit = ray.Instance
                    if hit and hit:FindFirstAncestorWhichIsA("Model") == char then
                        nearest = plr
                        nearestDist = dist
                    end
                else
                    nearest = plr
                    nearestDist = dist
                end
            else
                nearest = plr
                nearestDist = dist
            end
        end
    end
    return nearest
end

-- Kill Aura loop
local KillAuraConnection = nil
local function StartKillAura()
    if KillAuraConnection then KillAuraConnection:Disconnect() end
    
    KillAuraConnection = RunService.Heartbeat:Connect(function()
        if not KillAuraCFG.ENABLED then return end
        
        local target = GetNearestPlayer()
        if not target then return end
        
        local char = target.Character
        if not char then return end
        
        local targetPart = char:FindFirstChild(KillAuraCFG.HITBOX_PART) or char:FindFirstChild("HumanoidRootPart")
        if not targetPart then return end
        
        local lChar = LP.Character
        if not lChar then return end
        
        -- Simulate damage/click
        local tool = lChar:FindFirstChildOfClass("Tool")
        if tool then
            -- Activate tool to simulate attack
            tool:Activate()
        end
        
        -- Alternative: fire clickdetector if exists
        local clickDetector = targetPart:FindFirstChildOfClass("ClickDetector")
        if clickDetector then
            fireclickdetector(clickDetector)
        end
    end)
end

-- Teleport functions
local function TeleportToPlayer(plr)
    if not plr or not plr.Character then return end
    local targetHRP = plr.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end
    
    local lChar = LP.Character
    if not lChar then return end
    local lHRP = lChar:FindFirstChild("HumanoidRootPart")
    if not lHRP then return end
    
    lHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
end

local function TeleportToLocation(locationName)
    local loc = SavedLocations[locationName]
    if not loc then return end
    
    local lChar = LP.Character
    if not lChar then return end
    local lHRP = lChar:FindFirstChild("HumanoidRootPart")
    if not lHRP then return end
    
    lHRP.CFrame = CFrame.new(loc) + Vector3.new(0, 3, 0)
end

local function SaveCurrentLocation(name)
    local lChar = LP.Character
    if not lChar then return end
    local lHRP = lChar:FindFirstChild("HumanoidRootPart")
    if not lHRP then return end
    
    SavedLocations[name] = lHRP.Position
end

-- Teleport menu (player list)
local function OpenTeleportMenu()
    local TeleportGui = Instance.new("ScreenGui")
    TeleportGui.Name = "luzor_teleport_" .. HttpService:GenerateGUID(false)
    TeleportGui.Parent = CoreGui
    TeleportGui.ResetOnSpawn = false
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Parent = TeleportGui
    MainFrame.Size = UDim2.new(0, 300, 0, 350)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = BackgroundColor
    MainFrame.ClipsDescendants = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", MainFrame).Color = AccentColor
    
    local Header = Instance.new("Frame")
    Header.Parent = MainFrame
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = CardColor
    MakeDraggable(Header, MainFrame)
    
    local Title = Instance.new("TextLabel")
    Title.Parent = Header
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Teleport"
    Title.TextColor3 = TextColor
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = Header
    CloseBtn.Size = UDim2.new(0, 35, 1, 0)
    CloseBtn.Position = UDim2.new(1, -38, 0, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = SubTextColor
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.MouseButton1Click:Connect(function() TeleportGui:Destroy() end)
    
    local Container = Instance.new("ScrollingFrame")
    Container.Parent = MainFrame
    Container.Size = UDim2.new(1, -20, 1, -50)
    Container.Position = UDim2.new(0, 10, 0, 50)
    Container.BackgroundTransparency = 1
    Container.ScrollBarThickness = 3
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local Layout = Instance.new("UIListLayout")
    Layout.Parent = Container
    Layout.Padding = UDim.new(0, 5)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        local Btn = Instance.new("TextButton")
        Btn.Parent = Container
        Btn.Size = UDim2.new(1, 0, 0, 35)
        Btn.BackgroundColor3 = CardColor
        Btn.Text = plr.DisplayName .. " (" .. plr.Name .. ")"
        Btn.TextColor3 = TextColor
        Btn.Font = Enum.Font.Gotham
        Btn.TextSize = 12
        Btn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
        AddBounce(Btn)
        Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = HoverColor}, 0.2) end)
        Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = CardColor}, 0.2) end)
        Btn.MouseButton1Click:Connect(function()
            TeleportToPlayer(plr)
            TeleportGui:Destroy()
        end)
    end
end

-- // CREATE WINDOW & TABS
local Window = Library:CreateWindow({Title = "luzor", Subtitle = "South Bronx: The Trenches", SphereText = true, SphereWords = "open"})

-- // COMBAT TAB
local CombatTab = Window:CreateTab("Combat", true)
local CombatPage = CombatTab:CreatePage("Combat")

-- Kill Aura Section
local AuraSection = CombatPage:CreateSection("Kill Aura")

-- Toggle with keybind (Z)
AuraSection:AddToggleWithBind("Enable Kill Aura", false, Enum.KeyCode.Z, function(state)
    KillAuraCFG.ENABLED = state
    if state then
        StartKillAura()
    else
        if KillAuraConnection then
            KillAuraConnection:Disconnect()
            KillAuraConnection = nil
        end
    end
end)

AuraSection:AddSlider("Aura Radius", 50, 1000, KillAuraCFG.RADIUS, function(val)
    KillAuraCFG.RADIUS = val
end)

AuraSection:AddToggle("Team Check", false, function(state)
    KillAuraCFG.TEAM_CHECK = state
end)

AuraSection:AddToggle("Wall Check", false, function(state)
    KillAuraCFG.WALL_CHECK = state
end)

-- Hitbox part selector (using a button)
local hitboxOptions = {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"}
local hitboxIndex = 1
local hitboxFrame = Create("Frame", {Parent = AuraSection.Container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24)})
Create("TextLabel", {Parent = hitboxFrame, Text = "Hitbox Part", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(0.5, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
local hitboxBtn = Create("TextButton", {Parent = hitboxFrame, Text = "Head", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = TextColor, BackgroundColor3 = CardColor, Size = UDim2.new(0.4, -10, 1, 0), Position = UDim2.new(0.6, 0, 0, 0), AutoButtonColor = false})
Create("UICorner", {Parent = hitboxBtn, CornerRadius = UDim.new(0, 4)})
AddBounce(hitboxBtn)
hitboxBtn.MouseButton1Click:Connect(function()
    hitboxIndex = hitboxIndex % #hitboxOptions + 1
    hitboxBtn.Text = hitboxOptions[hitboxIndex]
    KillAuraCFG.HITBOX_PART = hitboxOptions[hitboxIndex]
end)

-- Teleport Section
local TeleportSection = CombatPage:CreateSection("Teleport")

TeleportSection:AddButton("Select Location", function()
    OpenTeleportMenu()
end)

-- Saved Locations Section
local LocationSection = CombatPage:CreateSection("Saved Locations")

local function RefreshLocations()
    for _, child in ipairs(LocationSection.Container:GetChildren()) do
        if child:IsA("Frame") and child.Name == "LocationItem" then
            child:Destroy()
        end
    end
    
    for name, pos in pairs(SavedLocations) do
        local LocFrame = Create("Frame", {Parent = LocationSection.Container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), Name = "LocationItem"})
        local LocBtn = Create("TextButton", {Parent = LocFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = TextColor, BackgroundColor3 = CardColor, Size = UDim2.new(0.8, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0), AutoButtonColor = false})
        Create("UICorner", {Parent = LocBtn, CornerRadius = UDim.new(0, 4)})
        AddBounce(LocBtn)
        LocBtn.MouseButton1Click:Connect(function() TeleportToLocation(name) end)
        
        local DelBtn = Create("TextButton", {Parent = LocFrame, Text = "✕", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.fromRGB(255, 100, 100), BackgroundColor3 = Color3.fromRGB(40, 20, 20), Size = UDim2.new(0.15, -10, 1, 0), Position = UDim2.new(0.85, 0, 0, 0), AutoButtonColor = false})
        Create("UICorner", {Parent = DelBtn, CornerRadius = UDim.new(0, 4)})
        AddBounce(DelBtn)
        DelBtn.MouseButton1Click:Connect(function()
            SavedLocations[name] = nil
            RefreshLocations()
        end)
    end
end

TeleportSection:AddButton("Save Current Location", function()
    local SaveGui = Instance.new("ScreenGui")
    SaveGui.Name = "luzor_save_" .. HttpService:GenerateGUID(false)
    SaveGui.Parent = CoreGui
    
    local Frame = Create("Frame", {Parent = SaveGui, Size = UDim2.new(0, 280, 0, 120), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = BackgroundColor})
    Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 10)})
    Create("UIStroke", {Parent = Frame, Color = AccentColor})
    
    local Title = Create("TextLabel", {Parent = Frame, Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 10), BackgroundTransparency = 1, Text = "Save Location", TextColor3 = TextColor, Font = Enum.Font.GothamBold, TextSize = 14})
    local Input = Create("TextBox", {Parent = Frame, Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 45), BackgroundColor3 = CardColor, Text = "", PlaceholderText = "Location Name...", TextColor3 = TextColor, Font = Enum.Font.Gotham, TextSize = 12})
    Create("UICorner", {Parent = Input, CornerRadius = UDim.new(0, 4)})
    Create("UIPadding", {Parent = Input, PaddingLeft = UDim.new(0, 8)})
    
    local BtnFrame = Create("Frame", {Parent = Frame, Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 80), BackgroundTransparency = 1})
    local SaveBtn = Create("TextButton", {Parent = BtnFrame, Size = UDim2.new(0.4, -5, 1, 0), Position = UDim2.new(0.1, 0, 0, 0), BackgroundColor3 = AccentColor, Text = "Save", TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false})
    Create("UICorner", {Parent = SaveBtn, CornerRadius = UDim.new(0, 4)})
    AddBounce(SaveBtn)
    local CancelBtn = Create("TextButton", {Parent = BtnFrame, Size = UDim2.new(0.4, -5, 1, 0), Position = UDim2.new(0.5, 5, 0, 0), BackgroundColor3 = CardColor, Text = "Cancel", TextColor3 = TextColor, Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false})
    Create("UICorner", {Parent = CancelBtn, CornerRadius = UDim.new(0, 4)})
    AddBounce(CancelBtn)
    
    SaveBtn.MouseButton1Click:Connect(function()
        if Input.Text ~= "" then
            SaveCurrentLocation(Input.Text)
            RefreshLocations()
        end
        SaveGui:Destroy()
    end)
    CancelBtn.MouseButton1Click:Connect(function() SaveGui:Destroy() end)
end)

-- Dealer Ship (example - replace with actual coordinates)
TeleportSection:AddButton("Dealer Ship", function()
    local dealerPos = Vector3.new(0, 10, 0) -- GANTI DENGAN KOORDINAT ASLI
    local lChar = LP.Character
    if lChar then
        local lHRP = lChar:FindFirstChild("HumanoidRootPart")
        if lHRP then
            lHRP.CFrame = CFrame.new(dealerPos) + Vector3.new(0, 3, 0)
        end
    end
end)

RefreshLocations()

-- // SETTINGS TAB
local SettingsTab = Window:CreateTab("Settings")
local SettingsPage = SettingsTab:CreatePage("Settings")
local ThemeSection = SettingsPage:CreateSection("Settings")

ThemeSection:AddColorPicker("Accent Color", AccentColor, function(color)
    AccentColor = color
    Window.MainFrame:FindFirstChild("UIStroke").Color = color
    -- Update other strokes if needed
end)

ThemeSection:AddKeybind("Toggle UI", Enum.KeyCode.RightAlt, function()
    Window:ToggleUI()
end)

-- Expose globals
getgenv().LuzorWindow = Window
getgenv().LuzorLibrary = Library

return Library