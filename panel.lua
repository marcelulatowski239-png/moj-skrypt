-- MADlUM | ADVANCED PACKET LAGGER SIMULATOR v2.0
-- Zaawansowany symulator diagnostyczny z interfejsem użytkownika
-- OSTRZEŻENIE: To jest symulacja WIZUALNA. Nie wysyła prawdziwych pakietów do innych graczy.

local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Usuwanie starego GUI, jeśli istnieje
local old = player.PlayerGui:FindFirstChild("MadiumGUI")
if old then old:Destroy() end

-- ==================== GŁÓWNE GUI ====================
local gui = Instance.new("ScreenGui")
gui.Name = "MadiumGUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(460, 520)
main.Position = UDim2.new(0.5, -230, 0.5, -260)
main.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = true
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)

local outline = Instance.new("UIStroke", main)
outline.Color = Color3.fromRGB(65, 105, 225)
outline.Thickness = 2
outline.Transparency = 0.2

-- Funkcja pomocnicza do tworzenia instancji
local function create(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    obj.Parent = parent
    return obj
end

-- ==================== NAGŁÓWEK ====================
local header = create("Frame", {
    Size = UDim2.new(1, 0, 0, 55),
    BackgroundColor3 = Color3.fromRGB(20, 24, 35),
    BorderSizePixel = 0
}, main)

Instance.new("UICorner", header).CornerRadius = UDim.new(0, 16)

-- Pasek dekoracyjny pod nagłówkiem
create("Frame", {
    Size = UDim2.new(1, 0, 0, 2),
    Position = UDim2.new(0, 0, 1, -2),
    BackgroundColor3 = Color3.fromRGB(65, 105, 225),
    BorderSizePixel = 0
}, header)

create("TextLabel", {
    Size = UDim2.new(1, -100, 1, 0),
    Position = UDim2.fromOffset(20, 0),
    BackgroundTransparency = 1,
    Text = "MADlUM | LAGGER v2.0",
    TextColor3 = Color3.fromRGB(120, 160, 255),
    Font = Enum.Font.GothamBlack,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left
}, header)

-- ==================== PRZECIĄGANIE ====================
local dragging, dragStart, startPosition

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ==================== MINIMALIZACJA ====================
local minimized = false
local minimizeBtn = create("TextButton", {
    Size = UDim2.fromOffset(32, 30),
    Position = UDim2.new(1, -44, 0, 12),
    BackgroundColor3 = Color3.fromRGB(45, 55, 75),
    Text = "-",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 22,
    AutoButtonColor = false
}, header)

Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 8)

minimizeBtn.MouseEnter:Connect(function()
    TweenService:Create(minimizeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(65, 85, 115)}):Play()
end)
minimizeBtn.MouseLeave:Connect(function()
    TweenService:Create(minimizeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 55, 75)}):Play()
end)

-- ==================== ZAWARTOŚĆ ====================
local content = create("Frame", {
    Size = UDim2.new(1, 0, 1, -55),
    Position = UDim2.fromOffset(0, 55),
    BackgroundTransparency = 1
}, main)

local function createLabel(text, y, color, sizeY)
    local l = create("TextLabel", {
        Size = UDim2.new(1, -40, 0, sizeY or 38),
        Position = UDim2.fromOffset(20, y),
        BackgroundColor3 = Color3.fromRGB(22, 26, 38),
        Text = text,
        TextColor3 = color or Color3.fromRGB(220, 225, 240),
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    }, content)
    Instance.new("UICorner", l).CornerRadius = UDim.new(0, 8)
    
    -- Dodanie lekkiego obrysu
    local stroke = Instance.new("UIStroke", l)
    stroke.Color = Color3.fromRGB(40, 45, 60)
    stroke.Thickness = 1
    return l
end

local pingLabel = createLabel("YOUR PING: Loading...", 15, Color3.fromRGB(100, 200, 255))
local fpsLabel = createLabel("YOUR FPS: Loading...", 58, Color3.fromRGB(100, 200, 255))

-- Sekcja celu
local targetHeader = createLabel("--- TARGET DATA ---", 101, Color3.fromRGB(255, 150, 150))
targetHeader.TextXAlignment = Enum.TextXAlignment.Center
targetHeader.BackgroundTransparency = 1

local targetPingLabel = createLabel("TARGET PING: 0 ms", 139, Color3.fromRGB(255, 80, 80))
local targetLossLabel = createLabel("TARGET LOSS: 0%", 182, Color3.fromRGB(255, 80, 80))

-- Pasek postępu (Lag Bar)
local barBg = create("Frame", {
    Size = UDim2.new(1, -40, 0, 12),
    Position = UDim2.fromOffset(20, 225),
    BackgroundColor3 = Color3.fromRGB(30, 30, 40),
    ClipsDescendants = true
}, content)
Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 6)

local barFill = create("Frame", {
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(255, 50, 50),
    BorderSizePixel = 0
}, barBg)
Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 6)

-- ==================== POLA WPROWADZANIA ====================
-- Nick celu
local targetNickBg = create("Frame", {
    Size = UDim2.new(1, -40, 0, 35),
    Position = UDim2.fromOffset(20, 250),
    BackgroundColor3 = Color3.fromRGB(22, 26, 38)
}, content)
Instance.new("UICorner", targetNickBg).CornerRadius = UDim.new(0, 8)

create("TextLabel", {
    Size = UDim2.fromOffset(80, 35),
    Position = UDim2.fromOffset(10, 0),
    BackgroundTransparency = 1,
    Text = "TARGET:",
    TextColor3 = Color3.fromRGB(120, 160, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left
}, targetNickBg)

local targetInput = create("TextBox", {
    Size = UDim2.new(1, -100, 1, 0),
    Position = UDim2.fromOffset(80, 0),
    BackgroundTransparency = 1,
    Text = "Player123",
    PlaceholderText = "Wpisz nick...",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false
}, targetNickBg)

-- Ilość pakietów
local inputBg = create("Frame", {
    Size = UDim2.new(1, -40, 0, 35),
    Position = UDim2.fromOffset(20, 295),
    BackgroundColor3 = Color3.fromRGB(22, 26, 38)
}, content)
Instance.new("UICorner", inputBg).CornerRadius = UDim.new(0, 8)

local packetInput = create("TextBox", {
    Size = UDim2.new(1, -100, 1, 0),
    Position = UDim2.fromOffset(10, 0),
    BackgroundTransparency = 1,
    Text = "100000",
    PlaceholderText = "1 - 100000",
    TextColor3 = Color3.fromRGB(230, 235, 250),
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false
}, inputBg)

create("TextLabel", {
    Size = UDim2.fromOffset(80, 35),
    Position = UDim2.new(1, -85, 0, 0),
    BackgroundTransparency = 1,
    Text = "PACKETS",
    TextColor3 = Color3.fromRGB(120, 160, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Right
}, inputBg)

packetInput:GetPropertyChangedSignal("Text"):Connect(function()
    local cleaned = packetInput.Text:gsub("%D", "")
    if cleaned ~= packetInput.Text then packetInput.Text = cleaned end
end)

local function getPacketValue()
    local num = tonumber(packetInput.Text)
    if not num then return 100000 end
    return math.clamp(math.floor(num), 1, 100000)
end

-- ==================== PRZYCISKI ====================
local function createButton(text, y, color)
    local b = create("TextButton", {
        Size = UDim2.new(1, -40, 0, 38),
        Position = UDim2.fromOffset(20, y),
        BackgroundColor3 = color,
        Text = text,
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        AutoButtonColor = false
    }, content)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    
    b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play() end)
    return b
end

local enabled = false
local toggle = createButton("TARGETED SIMULATION: OFF", 345, Color3.fromRGB(55, 75, 145))
local reset = createButton("RESET SIMULATION", 390, Color3.fromRGB(70, 75, 90))

-- ==================== LOGIKA PRZYCISKÓW ====================
local pulseConnection

toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    if enabled then
        toggle.Text = "TARGETED SIMULATION: ON"
        TweenService:Create(toggle, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play()
        
        -- Efekt pulsowania
        if pulseConnection then pulseConnection:Disconnect() end
        pulseConnection = RunService.RenderStepped:Connect(function()
            local pulse = math.abs(math.sin(os.clock() * 5)) * 0.4 + 0.6
            toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50):Lerp(Color3.fromRGB(100, 20, 20), pulse)
        end)
    else
        if pulseConnection then pulseConnection:Disconnect() end
        toggle.Text = "TARGETED SIMULATION: OFF"
        TweenService:Create(toggle, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(55, 75, 145)}):Play()
    end
end)

reset.MouseButton1Click:Connect(function()
    enabled = false
    if pulseConnection then pulseConnection:Disconnect() end
    toggle.Text = "TARGETED SIMULATION: OFF"
    toggle.BackgroundColor3 = Color3.fromRGB(55, 75, 145)
    targetPingLabel.Text = "TARGET PING: 0 ms"
    targetLossLabel.Text = "TARGET LOSS: 0%"
    packetInput.Text = "100000"
    targetInput.Text = "Player123"
    TweenService:Create(barFill, TweenInfo.new(0.5), {Size = UDim2.new(0, 0, 1, 0)}):Play()
end)

minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    local targetSize = minimized and UDim2.fromOffset(460, 55) or UDim2.fromOffset(460, 520)
    
    TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
    minimizeBtn.Text = minimized and "+" or "-"
    
    if not minimized then
        content.Visible = true
    else
        task.delay(0.4, function() if minimized then content.Visible = false end end)
    end
end)

-- ==================== LIVE LOGIC ====================
local frames = 0
local last = os.clock()
local simulatedPacketsSent = 0

RunService.RenderStepped:Connect(function()
    frames += 1
    local now = os.clock()

    if now - last >= 1 then
        local fps = frames
        frames = 0
        last = now

        fpsLabel.Text = "YOUR FPS: " .. fps

        local ok, ping = pcall(function()
            return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        pingLabel.Text = ok and ("YOUR PING: " .. math.floor(ping) .. " ms") or "YOUR PING: unavailable"

        if enabled then
            local currentPackets = getPacketValue()
            local targetName = targetInput.Text ~= "" and targetInput.Text or "Unknown"
            
            -- Zaawansowana, "mocniejsza" symulacja
            -- Im więcej pakietów, tym bardziej chaotyczne wartości
            local chaosFactor = currentPackets / 100000
            local baseDelay = math.floor(currentPackets / 10)
            
            -- Losowe skoki opóźnienia (Delay Chaining)
            local randomJitter = math.random(-500, 1500) * chaosFactor
            local delayMs = math.clamp(math.floor(baseDelay + randomJitter), 50, 9999)
            
            -- Utrata pakietów rośnie nieliniowo
            local lossPercent = math.clamp(math.floor((currentPackets / 1000) * (1 + math.random() * 0.2)), 1, 100)
            
            targetPingLabel.Text = string.format("TARGET [%s] PING: %d ms", targetName, delayMs)
            targetLossLabel.Text = string.format("TARGET LOSS: %d%%", lossPercent)
            
            -- Animacja paska postępu
            local barWidth = (currentPackets / 100000) * (main.AbsoluteSize.X - 40)
            TweenService:Create(barFill, TweenInfo.new(0.3), {Size = UDim2.fromOffset(barWidth, 12)}):Play()
            
            -- Zmiana koloru paska w zależności od mocy
            if currentPackets > 80000 then
                barFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            elseif currentPackets > 40000 then
                barFill.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
            else
                barFill.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
            end
            
            simulatedPacketsSent += currentPackets
        else
            targetPingLabel.Text = "TARGET PING: 0 ms"
            targetLossLabel.Text = "TARGET LOSS: 0%"
            TweenService:Create(barFill, TweenInfo.new(0.5), {Size = UDim2.new(0, 0, 1, 0)}):Play()
        end
    end
end)

print("MADlUM Advanced GUI (v2.0) loaded successfully!")
