-- language: Lua, file: panel.lua, target: Roblox Executor / GHOST Hub Ultimate
-- *GHOST Hub - Next-Gen UI & Packet Throttle System*

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local remoteEvent = ReplicatedStorage:FindFirstChild("SyncEvent") or ReplicatedStorage:FindFirstChild("RemoteEvent")

-- Konfiguracja GHOST Hub
local config = {
    NormalSpeed = 16,
    CarrySpeed = 16,
    LaggerNormalSpeed = 45,
    LaggerCarrySpeed = 23,
    LaggerActive = false,
    ToggleKey = Enum.KeyCode.E, -- Klawisz do włączania/wyłączania laggra w locie
    AutoCarry = false,
    TpDown = false,
    AutoTpDown = false,
    AutoTpHeight = 10,
    InfiniteJump = false,
    AntiRagdoll = false,
    Bodylock = false,
    BodylockRadius = 20,
    StealRadius = 60,
    RagdollSteal = false,
    BatAimbot = false,
    AutoBatSpeed = 55,
    AutoSwing = false,
    SmartSwing = false
}

local packetQueue = {}

-- Pełne czyszczenie starego GUI
if localPlayer.PlayerGui:FindFirstChild("GhostHubGui") then
    localPlayer.PlayerGui.GhostHubGui:Destroy()
end
if localPlayer.PlayerGui:FindFirstChild("AdaptHubGui") then
    localPlayer.PlayerGui.AdaptHubGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "GhostHubGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Główne okno GHOST Hub
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(420, 560)
frame.Position = UDim2.new(0.5, -210, 0.5, -280)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
frame.BackgroundTransparency = 0.02
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(130, 50, 255)
stroke.Thickness = 2
stroke.Transparency = 0.1

-- Górny nagłówek z logo GHOST i wskaźnikiem statusu
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 60)
topBar.BackgroundTransparency = 1
topBar.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.7, 0, 1, 0)
title.Position = UDim2.new(0, 20, 0, 0)
title.BackgroundTransparency = 1
title.Text = "GHOST"
title.TextColor3 = Color3.fromRGB(245, 245, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 24
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local statusIndicator = Instance.new("TextLabel")
statusIndicator.Size = UDim2.new(0.3, -20, 1, 0)
statusIndicator.Position = UDim2.new(0.7, 0, 0, 0)
statusIndicator.BackgroundTransparency = 1
statusIndicator.Text = "● READY"
statusIndicator.TextColor3 = Color3.fromRGB(80, 220, 120)
statusIndicator.Font = Enum.Font.GothamBold
statusIndicator.TextSize = 12
statusIndicator.TextXAlignment = Enum.TextXAlignment.Right
statusIndicator.Parent = topBar

-- Kontener przewijany zawartości
local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Size = UDim2.new(1, -20, 1, -135)
contentFrame.Position = UDim2.new(0, 10, 0, 65)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 700)
contentFrame.ScrollBarThickness = 4
contentFrame.ScrollBarImageColor3 = Color3.fromRGB(130, 50, 255)
contentFrame.Parent = frame

local uiLayout = Instance.new("UIListLayout", contentFrame)
uiLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiLayout.Padding = UDim.new(0, 10)

-- Nagłówki sekcji
local function createSection(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Text = "  " .. string.upper(text)
    lbl.TextColor3 = Color3.fromRGB(150, 140, 190)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = contentFrame
end

-- Pola tekstowe na prędkości
local function createInputBox(text, defaultValue, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 44)
    container.BackgroundColor3 = Color3.fromRGB(18, 17, 26)
    container.BorderSizePixel = 0
    container.Parent = contentFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(220, 215, 235)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 70, 0, 28)
    box.Position = UDim2.new(1, -80, 0.5, -14)
    box.BackgroundColor3 = Color3.fromRGB(28, 26, 38)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 13
    box.Text = tostring(defaultValue)
    box.Parent = container
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then
            callback(num)
        else
            box.Text = tostring(defaultValue)
        end
    end)
end

-- Przełączniki (Toggles) z płynną animacją
local function createToggle(text, defaultState, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 44)
    container.BackgroundColor3 = Color3.fromRGB(18, 17, 26)
    container.BorderSizePixel = 0
    container.Parent = contentFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(220, 215, 235)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 48, 0, 26)
    btn.Position = UDim2.new(1, -58, 0.5, -13)
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(130, 50, 255) or Color3.fromRGB(35, 33, 48)
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
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(130, 50, 255) or Color3.fromRGB(35, 33, 48)}):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)}):Play()
        callback(state)
    end)
end

-- Wypełnienie menu opcjami
createSection("Konfiguracja Prędkości")
createInputBox("Normal Speed", config.NormalSpeed, function(v) config.NormalSpeed = v end)
createInputBox("Carry Speed", config.CarrySpeed, function(v) config.CarrySpeed = v end)

createSection("Konfiguracja Laggra (Ping Lagger)")
createInputBox("Lagger Normal Speed", config.LaggerNormalSpeed, function(v) config.LaggerNormalSpeed = v end)
createInputBox("Lagger Carry Speed", config.LaggerCarrySpeed, function(v) config.LaggerCarrySpeed = v end)
createToggle("Lagger Manual (Bind pod E)", config.LaggerActive, function(v) 
    config.LaggerActive = v
    statusIndicator.Text = v and "● LAGGING" or "● READY"
    statusIndicator.TextColor3 = v and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(80, 220, 120)
    if not v and remoteEvent then
        for _, pkt in ipairs(packetQueue) do
            pcall(function() remoteEvent:FireServer(unpack(pkt)) end)
        end
        packetQueue = {}
    end
end)

createSection("Ruch i Akcje")
createToggle("Tryb Auto Carry", config.AutoCarry, function(v) config.AutoCarry = v end)
createToggle("TP Down", config.TpDown, function(v) config.TpDown = v end)
createToggle("Auto TP Down", config.AutoTpDown, function(v) config.AutoTpDown = v end)
createToggle("Nieskończony skok", config.InfiniteJump, function(v) config.InfiniteJump = v end)
createToggle("Anti Ragdoll", config.AntiRagdoll, function(v) config.AntiRagdoll = v end)

-- Dolny pasek zakładek
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -20, 0, 48)
tabContainer.Position = UDim2.new(0, 10, 1, -58)
tabContainer.BackgroundColor3 = Color3.fromRGB(15, 14, 20)
tabContainer.Parent = frame
Instance.new("UICorner", tabContainer).CornerRadius = UDim.new(0, 10)

local tabs = {"Ruch", "COMBAT", "KBM", "CTRL", "VISUAL", "USTAWIENIA"}
local tabWidth = 1 / #tabs
for i, name in ipairs(tabs) do
    local tBtn = Instance.new("TextButton")
    tBtn.Size = UDim2.new(tabWidth, -4, 1, -8)
    tBtn.Position = UDim2.new((i - 1) * tabWidth, 2, 0, 4)
    tBtn.BackgroundTransparency = (i == 1) and 0.2 or 1
    tBtn.BackgroundColor3 = Color3.fromRGB(130, 50, 255)
    tBtn.Text = name
    tBtn.TextColor3 = (i == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 135, 175)
    tBtn.Font = Enum.Font.GothamBold
    tBtn.TextSize = 10
    tBtn.Parent = tabContainer
    Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 6)
end

-- Obsługa klawisza E (Bind)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == config.ToggleKey then
        config.LaggerActive = not config.LaggerActive
        statusIndicator.Text = config.LaggerActive and "● LAGGING" or "● READY"
        statusIndicator.TextColor3 = config.LaggerActive and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(80, 220, 120)
        if not config.LaggerActive and remoteEvent then
            for _, pkt in ipairs(packetQueue) do
                pcall(function() remoteEvent:FireServer(unpack(pkt)) end)
            end
            packetQueue = {}
        end
    end
end)

-- Główna pętla sterująca prędkością i buforem sieciowym
RunService.RenderStepped:Connect(function(dt)
    local char = localPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    if humanoid then
        if config.LaggerActive then
            humanoid.WalkSpeed = config.LaggerNormalSpeed
        else
            humanoid.WalkSpeed = config.NormalSpeed
        end
    end

    if hrp and remoteEvent then
        local now = os.clock()
        local packetData = {"RequestSync", nil, hrp.CFrame, now}

        if config.LaggerActive then
            table.insert(packetQueue, packetData)
        else
            pcall(function()
                remoteEvent:FireServer(unpack(packetData))
            end)
        end
    end
end)

-- Nieskończony skok
UserInputService.JumpRequest:Connect(function()
    if config.InfiniteJump then
        local char = localPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- Przesuwanie okna myszką / palcem
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
