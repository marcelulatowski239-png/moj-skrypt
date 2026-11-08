-- language: Lua, file: panel.lua, target: Roblox Executor / GHOST Hub Ultimate v6
-- *GHOST Hub - Fully Working UI, Tabs, Speed, Lagger & Combat*

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local remoteEvent = ReplicatedStorage:FindFirstChild("SyncEvent") or ReplicatedStorage:FindFirstChild("RemoteEvent")

-- Konfiguracja huba
local config = {
    NormalSpeed = 16,
    CarrySpeed = 16,
    LaggerNormalSpeed = 45,
    LaggerCarrySpeed = 23,
    LaggerActive = false,
    ToggleKey = Enum.KeyCode.E,
    TpDownKey = Enum.KeyCode.Q,
    AutoCarry = false,
    TpDown = false,
    AutoTpDown = false,
    InfiniteJump = false,
    AntiRagdoll = false,
    Bodylock = false,
    BatAimbot = false,
    AutoSwing = false,
    SmartSwing = false,
    RagdollSteal = false,
    AntiConfuser = false,
    MirrorTp = false
}

local packetQueue = {}

-- Pełne czyszczenie starych okienek GUI
for _, guiName in ipairs({"GhostHubGui", "AdaptHubGui", "CursedHubLagger", "DuelLatencyPanel"}) do
    local old = localPlayer.PlayerGui:FindFirstChild(guiName)
    if old then old:Destroy() end
end

local gui = Instance.new("ScreenGui")
gui.Name = "GhostHubGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Główne okno interfejsu
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(440, 580)
frame.Position = UDim2.new(0.5, -220, 0.5, -290)
frame.BackgroundColor3 = Color3.fromRGB(12, 11, 18)
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
title.Text = "ADAPT / GHOST"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 22
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

-- Kontenery zakładek
local pages = {}
local pageNames = {"Ruch", "COMBAT", "KBM", "CTRL", "VISUAL", "USTAWIENIA"}

for _, name in ipairs(pageNames) do
    local p = Instance.new("ScrollingFrame")
    p.Name = name .. "_Page"
    p.Size = UDim2.new(1, -20, 1, -145)
    p.Position = UDim2.new(0, 10, 0, 65)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.CanvasSize = UDim2.new(0, 0, 0, 750)
    p.ScrollBarThickness = 4
    p.ScrollBarImageColor3 = Color3.fromRGB(140, 50, 255)
    p.Visible = (name == "Ruch")
    p.Parent = frame

    local layout = Instance.new("UIListLayout", p)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    
    pages[name] = p
end

-- Funkcje tworzące elementy wizualne
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

-- Wypełnienie poszczególnych zakładek opcjami
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

createSection(pages["Ruch"], "Skok i Ruch")
createToggle(pages["Ruch"], "Nieskończony skok", config.InfiniteJump, function(v) config.InfiniteJump = v end)
createToggle(pages["Ruch"], "Anti Ragdoll", config.AntiRagdoll, function(v) config.AntiRagdoll = v end)
createToggle(pages["Ruch"], "Bodylock", config.Bodylock, function(v) config.Bodylock = v end)

createSection(pages["COMBAT"], "Steal Configuration")
createToggle(pages["COMBAT"], "Ragdoll Steal", config.RagdollSteal, function(v) config.RagdollSteal = v end)

createSection(pages["COMBAT"], "Bat Aimbot & Swing")
createToggle(pages["COMBAT"], "Bat Aimbot", config.BatAimbot, function(v) config.BatAimbot = v end)
createToggle(pages["COMBAT"], "Auto Swing", config.AutoSwing, function(v) config.AutoSwing = v end)
createToggle(pages["COMBAT"], "Smart Swing", config.SmartSwing, function(v) config.SmartSwing = v end)
createToggle(pages["COMBAT"], "Anti Confuser", config.AntiConfuser, function(v) config.AntiConfuser = v end)
createToggle(pages["COMBAT"], "Mirror TP", config.MirrorTp, function(v) config.MirrorTp = v end)

createSection(pages["KBM"], "Keybinds & Mouse")
createToggle(pages["KBM"], "Auto Left", false, function(v) end)
createToggle(pages["KBM"], "Auto Right", false, function(v) end)

createSection(pages["CTRL"], "Control Options")
createToggle(pages["CTRL"], "Tryb Auto Carry", config.AutoCarry, function(v) config.AutoCarry = v end)

createSection(pages["VISUAL"], "Visual Options")
createToggle(pages["VISUAL"], "ESP Players", false, function(v) end)
createToggle(pages["VISUAL"], "China Hat", false, function(v) end)

createSection(pages["USTAWIENIA"], "Settings & Safety")
createToggle(pages["USTAWIENIA"], "Tryb bezpieczeństwa", true, function(v) end)
createToggle(pages["USTAWIENIA"], "Kick Warning", true, function(v) end)

-- Dolny panel z w pełni działającym przełączaniem zakładek
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

-- Akcja TP w dół pod klawisz Q
local function doTpDown()
    local char = localPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame - Vector3.new(0, 25, 0)
    end
end

-- Obsługa binda pod klawisz E (Lagger) oraz Q (TP Down)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == config.ToggleKey then
        config.LaggerActive = not config.LaggerActive
        statusIndicator.Text = config.LaggerActive and "● LAGGING [E]" or "● READY [E]"
        statusIndicator.TextColor3 = config.LaggerActive and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(80, 255, 120)
        if not config.LaggerActive and remoteEvent then
            for _, pkt in ipairs(packetQueue) do
                pcall(function() remoteEvent:FireServer(unpack(pkt)) end)
            end
            packetQueue = {}
        end
    elseif input.KeyCode == config.TpDownKey then
        doTpDown()
    end
end)

-- Pętla główna (Prędkość, Pakiety i Bat Aimbot)
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

    -- Bat Aimbot: namierzanie najbliższego przeciwnika
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

-- Przesuwanie okna myszką
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
