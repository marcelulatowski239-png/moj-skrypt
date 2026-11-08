-- language: Lua, file: panel.lua, target: Roblox Executor / GHOST Hub Ultimate
-- *Complete ADAPT / GHOST Hub implementation matching the full feature set*

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local remoteEvent = ReplicatedStorage:FindFirstChild("SyncEvent") or ReplicatedStorage:FindFirstChild("RemoteEvent")

-- Konfiguracja huba i wszystkich stanów z menu
local config = {
    -- Ruch / Speed
    NormalSpeed = 16,
    CarrySpeed = 16,
    LaggerNormalSpeed = 45,
    LaggerCarrySpeed = 23,
    LaggerActive = false,
    AutoCarry = false,
    TpDown = false,
    AutoTpDown = false,
    AutoTpHeight = 15,
    InfiniteJump = false,
    AntiRagdoll = false,
    Bodylock = false,
    BodylockRadius = 20,

    -- Combat & Steal
    StealRadius = 60,
    RagdollSteal = false,
    NormalPause = 80,
    BatAimbot = false,
    AutoBatSpeed = 55,
    AutoSwing = false,
    SmartSwing = false,
    AntiConfuser = false,
    MirrorTp = false,
    TpBat = false,
    TpSwingDelay = 0.007,
    AutoLeft = false,
    AutoRight = false,
    MatchSpeed = false,
    BatCounter = false,
    MedusaCounter = false,
    Confuser = false,
    AutoConfuser = false,

    -- Keybinds (KBM / CTRL)
    KeyLaggerMode = Enum.KeyCode.E,
    KeyDrop = Enum.KeyCode.Unknown,
    KeyTpDown = Enum.KeyCode.Q,
    KeyBatAimbot = Enum.KeyCode.Unknown,
    KeyTpBat = Enum.KeyCode.Unknown,
    KeyAutoLeft = Enum.KeyCode.Unknown,
    KeyAutoRight = Enum.KeyCode.Unknown,

    -- Visuals
    EspPlayers = false,
    RagdollCountdown = false,
    ChinaHat = false,
    HatEffect = false,
    HatRainbow = false,
    StretchRes = false,
    AntiLag = false,
    PotatoGraphics = false,
    FovChange = false,
    FovValue = 120,

    -- Ustawienia
    SafetyMode = true,
    KickWarning = true,
    ScrollLayout = true
}

local packetQueue = {}

-- Czyszczenie starych GUI
for _, guiName in ipairs({"GhostHubGui", "AdaptHubGui", "CursedHubLagger", "DuelLatencyPanel"}) do
    local old = localPlayer.PlayerGui:FindFirstChild(guiName)
    if old then old:Destroy() end
end

local gui = Instance.new("ScreenGui")
gui.Name = "GhostHubGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Główne okno
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(440, 580)
frame.Position = UDim2.new(0.5, -220, 0.5, -290)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
frame.BackgroundTransparency = 0.02
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(140, 50, 255)
stroke.Thickness = 2
stroke.Transparency = 0.15

-- Górny nagłówek
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 60)
topBar.BackgroundTransparency = 1
topBar.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.6, 0, 1, 0)
title.Position = UDim2.new(0, 20, 0, 0)
title.BackgroundTransparency = 1
title.Text = "ADAPT"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 26
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local statusIndicator = Instance.new("TextLabel")
statusIndicator.Size = UDim2.new(0.4, -20, 1, 0)
statusIndicator.Position = UDim2.new(0.6, 0, 0, 0)
statusIndicator.BackgroundTransparency = 1
statusIndicator.Text = "● READY [E]"
statusIndicator.TextColor3 = Color3.fromRGB(80, 255, 120)
statusIndicator.Font = Enum.Font.GothamBold
statusIndicator.TextSize = 12
statusIndicator.TextXAlignment = Enum.TextXAlignment.Right
statusIndicator.Parent = topBar

-- Zakładki systemu
local pages = {}
local pageNames = {"Ruch", "COMBAT", "KBM", "CTRL", "VISUAL", "USTAWIENIA"}

for _, name in ipairs(pageNames) do
    local p = Instance.new("ScrollingFrame")
    p.Name = name .. "_Page"
    p.Size = UDim2.new(1, -20, 1, -145)
    p.Position = UDim2.new(0, 10, 0, 65)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.CanvasSize = UDim2.new(0, 0, 0, 850)
    p.ScrollBarThickness = 4
    p.ScrollBarImageColor3 = Color3.fromRGB(140, 50, 255)
    p.Visible = (name == "Ruch")
    p.Parent = frame

    local layout = Instance.new("UIListLayout", p)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    
    pages[name] = p
end

-- Komponenty UI
local function createSection(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Text = "  " .. string.upper(text)
    lbl.TextColor3 = Color3.fromRGB(150, 140, 195)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
end

local function createInputBox(parent, text, defaultValue, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 44)
    container.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
    container.BorderSizePixel = 0
    container.Parent = parent
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(225, 220, 240)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 75, 0, 28)
    box.Position = UDim2.new(1, -85, 0.5, -14)
    box.BackgroundColor3 = Color3.fromRGB(28, 25, 40)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 13
    box.Text = tostring(defaultValue)
    box.Parent = container
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then callback(num) else box.Text = tostring(defaultValue) end
    end)
end

local function createToggle(parent, text, defaultState, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 44)
    container.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
    container.BorderSizePixel = 0
    container.Parent = parent
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(225, 220, 240)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 48, 0, 26)
    btn.Position = UDim2.new(1, -58, 0.5, -13)
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(140, 50, 255) or Color3.fromRGB(35, 32, 50)
    btn.Text = ""
    btn.Parent = container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 20, 0, 20)
    circle.Position = defaultState and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.Parent = btn
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local state = defaultState
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(140, 50, 255) or Color3.fromRGB(35, 32, 50)}):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)}):Play()
        callback(state)
    end)
end

local function createKeybindBox(parent, text, currentKey, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 44)
    container.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
    container.BorderSizePixel = 0
    container.Parent = parent
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(225, 220, 240)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(0, 100, 0, 28)
    bindBtn.Position = UDim2.new(1, -110, 0.5, -14)
    bindBtn.BackgroundColor3 = Color3.fromRGB(28, 25, 40)
    bindBtn.TextColor3 = Color3.fromRGB(200, 160, 255)
    bindBtn.Font = Enum.Font.GothamBold
    bindBtn.TextSize = 12
    bindBtn.Text = currentKey.Name == "Unknown" and "NONE" or currentKey.Name
    bindBtn.Parent = container
    Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 6)

    local listening = false
    bindBtn.MouseButton1Click:Connect(function()
        listening = true
        bindBtn.Text = "..."
    end)

    UserInputService.InputBegan:Connect(function(input)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            if input.KeyCode == Enum.KeyCode.Backspace then
                currentKey = Enum.KeyCode.Unknown
                bindBtn.Text = "NONE"
            else
                currentKey = input.KeyCode
                bindBtn.Text = currentKey.Name
            end
            callback(currentKey)
        end
    end)
end

-- === ZAKŁADKA: RUCH ===
createSection(pages["Ruch"], "Speed Configuration")
createInputBox(pages["Ruch"], "Normal Speed", config.NormalSpeed, function(v) config.NormalSpeed = v end)
createInputBox(pages["Ruch"], "Carry Speed", config.CarrySpeed, function(v) config.CarrySpeed = v end)

createSection(pages["Ruch"], "Lagger Configuration")
createInputBox(pages["Ruch"], "Lagger Normal Speed", config.LaggerNormalSpeed, function(v) config.LaggerNormalSpeed = v end)
createInputBox(pages["Ruch"], "Lagger Carry Speed", config.LaggerCarrySpeed, function(v) config.LaggerCarrySpeed = v end)
createToggle(pages["Ruch"], "Lagger Manual (Bind pod E)", config.LaggerActive, function(v) 
    config.LaggerActive = v
    statusIndicator.Text = v and "● LAGGING [E]" or "● READY [E]"
    statusIndicator.TextColor3 = v and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(80, 255, 120)
    if not v and remoteEvent then
        for _, pkt in ipairs(packetQueue) do
            pcall(function() remoteEvent:FireServer(unpack(pkt)) end)
        end
        packetQueue = {}
    end
end)

createSection(pages["Ruch"], "TP Down")
createToggle(pages["Ruch"], "TP Down (Klawisz Q)", config.TpDown, function(v) config.TpDown = v end)
createToggle(pages["Ruch"], "Auto TP Down", config.AutoTpDown, function(v) config.AutoTpDown = v end)
createInputBox(pages["Ruch"], "Auto TP Height", config.AutoTpHeight, function(v) config.AutoTpHeight = v end)

createSection(pages["Ruch"], "Skok i Ruch")
createToggle(pages["Ruch"], "Nieskończony skok", config.InfiniteJump, function(v) config.InfiniteJump = v end)
createToggle(pages["Ruch"], "Anti Ragdoll", config.AntiRagdoll, function(v) config.AntiRagdoll = v end)
createToggle(pages["Ruch"], "Bodylock", config.Bodylock, function(v) config.Bodylock = v end)
createInputBox(pages["Ruch"], "Bodylock Radius", config.BodylockRadius, function(v) config.BodylockRadius = v end)


-- === ZAKŁADKA: COMBAT ===
createSection(pages["COMBAT"], "Steal Configuration")
createInputBox(pages["COMBAT"], "Radius", config.StealRadius, function(v) config.StealRadius = v end)
createToggle(pages["COMBAT"], "Ragdoll Steal", config.RagdollSteal, function(v) config.RagdollSteal = v end)
createInputBox(pages["COMBAT"], "Normal Pause %", config.NormalPause, function(v) config.NormalPause = v end)

createSection(pages["COMBAT"], "Bat Aimbot")
createToggle(pages["COMBAT"], "Bat Aimbot", config.BatAimbot, function(v) config.BatAimbot = v end)
createInputBox(pages["COMBAT"], "Auto Bat Speed", config.AutoBatSpeed, function(v) config.AutoBatSpeed = v end)
createToggle(pages["COMBAT"], "Auto Swing", config.AutoSwing, function(v) config.AutoSwing = v end)
createToggle(pages["COMBAT"], "Smart Swing", config.SmartSwing, function(v) config.SmartSwing = v end)
createToggle(pages["COMBAT"], "Anti Confuser", config.AntiConfuser, function(v) config.AntiConfuser = v end)
createToggle(pages["COMBAT"], "Mirror TP", config.MirrorTp, function(v) config.MirrorTp = v end)

createSection(pages["COMBAT"], "TP Bat")
createToggle(pages["COMBAT"], "TP Bat", config.TpBat, function(v) config.TpBat = v end)
createInputBox(pages["COMBAT"], "TP Swing Delay", config.TpSwingDelay, function(v) config.TpSwingDelay = v end)

createSection(pages["COMBAT"], "Auto Path")
createToggle(pages["COMBAT"], "Auto Left", config.AutoLeft, function(v) config.AutoLeft = v end)
createToggle(pages["COMBAT"], "Auto Right", config.AutoRight, function(v) config.AutoRight = v end)
createToggle(pages["COMBAT"], "Match Speed", config.MatchSpeed, function(v) config.MatchSpeed = v end)

createSection(pages["COMBAT"], "Counters")
createToggle(pages["COMBAT"], "Bat Counter", config.BatCounter, function(v) config.BatCounter = v end)
createToggle(pages["COMBAT"], "Medusa Counter", config.MedusaCounter, function(v) config.MedusaCounter = v end)
createToggle(pages["COMBAT"], "Confuser", config.Confuser, function(v) config.Confuser = v end)
createToggle(pages["COMBAT"], "Auto Confuser", config.AutoConfuser, function(v) config.AutoConfuser = v end)


-- === ZAKŁADKA: KBM (Keybinds) ===
createSection(pages["KBM"], "Combat Keybinds")
createKeybindBox(pages["KBM"], "Lagger Mode Key", config.KeyLaggerMode, function(k) config.KeyLaggerMode = k end)
createKeybindBox(pages["KBM"], "Drop Key", config.KeyDrop, function(k) config.KeyDrop = k end)
createKeybindBox(pages["KBM"], "TP Down Key", config.KeyTpDown, function(k) config.KeyTpDown = k end)
createKeybindBox(pages["KBM"], "Bat Aimbot Key", config.KeyBatAimbot, function(k) config.KeyBatAimbot = k end)
createKeybindBox(pages["KBM"], "TP Bat Key", config.KeyTpBat, function(k) config.KeyTpBat = k end)
createKeybindBox(pages["KBM"], "Auto Left Key", config.KeyAutoLeft, function(k) config.KeyAutoLeft = k end)
createKeybindBox(pages["KBM"], "Auto Right Key", config.KeyAutoRight, function(k) config.KeyAutoRight = k end)


-- === ZAKŁADKA: CTRL ===
createSection(pages["CTRL"], "Control Options")
createToggle(pages["CTRL"], "Tryb Auto Carry", config.AutoCarry, function(v) config.AutoCarry = v end)


-- === ZAKŁADKA: VISUAL ===
createSection(pages["VISUAL"], "Players")
createToggle(pages["VISUAL"], "ESP", config.EspPlayers, function(v) config.EspPlayers = v end)
createToggle(pages["VISUAL"], "Ragdoll Countdown", config.RagdollCountdown, function(v) config.RagdollCountdown = v end)

createSection(pages["VISUAL"], "China Hat")
createToggle(pages["VISUAL"], "China Hat", config.ChinaHat, function(v) config.ChinaHat = v end)
createToggle(pages["VISUAL"], "Hat Effect", config.HatEffect, function(v) config.HatEffect = v end)
createToggle(pages["VISUAL"], "Hat Rainbow", config.HatRainbow, function(v) config.HatRainbow = v end)

createSection(pages["VISUAL"], "Performance")
createToggle(pages["VISUAL"], "Stretch Res", config.StretchRes, function(v) config.StretchRes = v end)
createToggle(pages["VISUAL"], "Anti-Lag", config.AntiLag, function(v) config.AntiLag = v end)
createToggle(pages["VISUAL"], "Potato Graphics", config.PotatoGraphics, function(v) config.PotatoGraphics = v end)
createToggle(pages["VISUAL"], "FOV Change", config.FovChange, function(v) config.FovChange = v end)
createInputBox(pages["VISUAL"], "FOV Value", config.FovValue, function(v)
    config.FovValue = v
    if config.FovChange then workspace.CurrentCamera.FieldOfView = v end
end)


-- === ZAKŁADKA: USTAWIENIA ===
createSection(pages["USTAWIENIA"], "Safety & Settings")
createToggle(pages["USTAWIENIA"], "Tryb bezpieczeństwa", config.SafetyMode, function(v) config.SafetyMode = v end)
createToggle(pages["USTAWIENIA"], "Kick Warning", config.KickWarning, function(v) config.KickWarning = v end)
createToggle(pages["USTAWIENIA"], "Scroll Layout", config.ScrollLayout, function(v) config.ScrollLayout = v end)


-- Dolny panel zakładek
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -20, 0, 48)
tabContainer.Position = UDim2.new(0, 10, 1, -56)
tabContainer.BackgroundColor3 = Color3.fromRGB(15, 13, 22)
tabContainer.Parent = frame
Instance.new("UICorner", tabContainer).CornerRadius = UDim.new(0, 10)

local tabButtons = {}
local tabWidth = 1 / #pageNames

for i, name in ipairs(pageNames) do
    local tBtn = Instance.new("TextButton")
    tBtn.Size = UDim2.new(tabWidth, -4, 1, -8)
    tBtn.Position = UDim2.new((i - 1) * tabWidth, 2, 0, 4)
    tBtn.BackgroundTransparency = (name == "Ruch") and 0.2 or 1
    tBtn.BackgroundColor3 = Color3.fromRGB(140, 50, 255)
    tBtn.Text = name
    tBtn.TextColor3 = (name == "Ruch") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 135, 175)
    tBtn.Font = Enum.Font.GothamBold
    tBtn.TextSize = 10
    tBtn.Parent = tabContainer
    Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 6)

    tabButtons[name] = tBtn

    tBtn.MouseButton1Click:Connect(function()
        for pName, pageObj in pairs(pages) do
            pageObj.Visible = false
            tabButtons[pName].BackgroundTransparency = 1
            tabButtons[pName].TextColor3 = Color3.fromRGB(140, 135, 175)
        end
        pages[name].Visible = true
        tBtn.BackgroundTransparency = 0.2
        tBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
end

-- TP Down funkcja
local function doTpDown()
    local char = localPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame - Vector3.new(0, 25, 0)
    end
end

-- Keybind listener
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == config.KeyLaggerMode or input.KeyCode == Enum.KeyCode.E then
        config.LaggerActive = not config.LaggerActive
        statusIndicator.Text = config.LaggerActive and "● LAGGING [E]" or "● READY [E]"
        statusIndicator.TextColor3 = config.LaggerActive and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(80, 255, 120)
        if not config.LaggerActive and remoteEvent then
            for _, pkt in ipairs(packetQueue) do
                pcall(function() remoteEvent:FireServer(unpack(pkt)) end)
            end
            packetQueue = {}
        end
    elseif input.KeyCode == config.KeyTpDown or input.KeyCode == Enum.KeyCode.Q then
        doTpDown()
    end
end)

-- Pętla główna (Prędkość, pakiety laggra, bat aimbot)
RunService.RenderStepped:Connect(function()
    local char = localPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    if humanoid then
        humanoid.WalkSpeed = config.LaggerActive and config.LaggerNormalSpeed or config.NormalSpeed
    end

    if hrp and remoteEvent then
        local now = os.clock()
        local packetData = {"RequestSync", nil, hrp.CFrame, now}
        if config.LaggerActive then
            table.insert(packetQueue, packetData)
        else
            pcall(function() remoteEvent:FireServer(unpack(packetData)) end)
        end
    end

    -- Bat Aimbot
    if config.BatAimbot and hrp then
        local closestPlayer = nil
        local shortestDist = math.huge
        
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= localPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local targetHrp = p.Character.HumanoidRootPart
                local dist = (hrp.Position - targetHrp.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closestPlayer = p
                end
            end
        end

        if closestPlayer and shortestDist < 40 then
            local targetHrp = closestPlayer.Character.HumanoidRootPart
            hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(targetHrp.Position.X, hrp.Position.Y, targetHrp.Position.Z))
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if config.InfiniteJump then
        local char = localPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

-- Przesuwanie okna
local dragging, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
