-- language: Lua, file: panel.lua, target: Roblox Executor / Steal a Brainrot Duels
-- *ADAPT Hub - Full UI & Mechanics Panel*

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local remoteEvent = ReplicatedStorage:FindFirstChild("SyncEvent") or ReplicatedStorage:FindFirstChild("RemoteEvent")

-- Konfiguracja domyślna z menu Adapt
local config = {
    NormalSpeed = 16,
    CarrySpeed = 16,
    LaggerNormalSpeed = 45,
    LaggerCarrySpeed = 23,
    LaggerActive = false,
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
    NormalPause = 80,
    BatAimbot = false,
    AutoBatSpeed = 55,
    AutoSwing = false,
    SmartSwing = false
}

local packetQueue = {}

-- Czyszczenie starego GUI
local oldGui = localPlayer.PlayerGui:FindFirstChild("AdaptHubGui")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "AdaptHubGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Główne okno
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(380, 520)
frame.Position = UDim2.new(0.5, -190, 0.5, -260)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(40, 40, 50)
stroke.Thickness = 1.5

-- Nagłówek ADAPT (Stylizowany tekst)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 60)
title.BackgroundTransparency = 1
title.Text = "ADAPT"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 28
title.Parent = frame

-- Kontener zawartości zakładek
local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Size = UDim2.new(1, -20, 1, -130)
contentFrame.Position = UDim2.new(0, 10, 0, 65)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
contentFrame.ScrollBarThickness = 4
contentFrame.Parent = frame

local uiLayout = Instance.new("UIListLayout", contentFrame)
uiLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiLayout.Padding = UDim.new(0, 10)

-- Funkcja pomocnicza do tworzenia przełączników (Toggle)
local function createToggle(parent, text, defaultState, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    container.BorderSizePixel = 0
    container.Parent = parent
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(220, 220, 230)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 46, 0, 24)
    btn.Position = UDim2.new(1, -56, 0.5, -12)
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(40, 40, 50)
    btn.Text = ""
    btn.Parent = container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 20, 0, 20)
    circle.Position = defaultState and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.Parent = btn
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local state = defaultState
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(40, 40, 50)
        circle.Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        callback(state)
    end)
end

-- Generowanie elementów w zakładce Ruch (na podstawie Twoich zdjęć)
createToggle(contentFrame, "Tryb Auto Carry", config.AutoCarry, function(v) config.AutoCarry = v end)
createToggle(contentFrame, "TP Down", config.TpDown, function(v) config.TpDown = v end)
createToggle(contentFrame, "Auto TP Down", config.AutoTpDown, function(v) config.AutoTpDown = v end)
createToggle(contentFrame, "Nieskończony skok", config.InfiniteJump, function(v) config.InfiniteJump = v end)
createToggle(contentFrame, "Anti Ragdoll", config.AntiRagdoll, function(v) config.AntiRagdoll = v end)
createToggle(contentFrame, "Bodylock", config.Bodylock, function(v) config.Bodylock = v end)

-- Przycisk główny Laggra (odpowiadający konfiguracji z menu)
createToggle(contentFrame, "Lagger Manual (Ping Lagger)", config.LaggerActive, function(v) 
    config.LaggerActive = v
    if not v and remoteEvent then
        -- Release / Wypuszczenie pakietów po wyłączeniu
        for _, pkt in ipairs(packetQueue) do
            pcall(function() remoteEvent:FireServer(unpack(pkt)) end)
        end
        packetQueue = {}
    end
end)

-- Pasek dolny z zakładkami (Ruch, Combat, KBM, CTRL, Visual, Ustawienia)
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -20, 0, 45)
tabContainer.Position = UDim2.new(0, 10, 1, -55)
tabContainer.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
tabContainer.Parent = frame
Instance.new("UICorner", tabContainer).CornerRadius = UDim.new(0, 10)

local tabs = {"Ruch", "COMBAT", "KBM", "CTRL", "VISUAL", "USTAWIENIA"}
local tabWidth = 1 / #tabs
for i, name in ipairs(tabs) do
    local tBtn = Instance.new("TextButton")
    tBtn.Size = UDim2.new(tabWidth, -4, 1, -8)
    tBtn.Position = UDim2.new((i - 1) * tabWidth, 2, 0, 4)
    tBtn.BackgroundTransparency = (i == 1) and 0.2 or 1
    tBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    tBtn.Text = name
    tBtn.TextColor3 = (i == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 160)
    tBtn.Font = Enum.Font.GothamBold
    tBtn.TextSize = 10
    tBtn.Parent = tabContainer
    Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 6)
end

-- Główna pętla mechanik (Prędkość, Nieskończony skok, Lagger)
RunService.RenderStepped:Connect(function(dt)
    local char = localPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    if humanoid then
        -- Obsługa prędkości normalnej i laggra
        if config.LaggerActive then
            humanoid.WalkSpeed = config.LaggerNormalSpeed
        else
            humanoid.WalkSpeed = config.NormalSpeed
        end
    end

    -- Obsługa pakietów laggra (buforowanie i ruch)
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

-- Obsługa nieskończonego skoku
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

-- Przesuwanie okna myszką / na telefonie
local dragging, dragStart, startPos
title.InputBegan:Connect(function(input)
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
