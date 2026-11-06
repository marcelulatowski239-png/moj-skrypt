-- MADlUM | HARDCORE LAG SIMULATOR (v3.0)
-- OSTRZEŻENIE: Ten skrypt mocno obciąża procesor i może zawiesić grę.
-- Nie wysyła fałszywych pakietów, ale symuluje "zamrożenie" klienta.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Usuwanie starego GUI
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
main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = true
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)

local outline = Instance.new("UIStroke", main)
outline.Color = Color3.fromRGB(255, 50, 50)
outline.Thickness = 2
outline.Transparency = 0.3

-- Funkcja pomocnicza
local function create(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    obj.Parent = parent
    return obj
end

-- ==================== NAGŁÓWEK ====================
local header = create("Frame", {
    Size = UDim2.new(1, 0, 0, 55),
    BackgroundColor3 = Color3.fromRGB(20, 10, 10),
    BorderSizePixel = 0
}, main)

Instance.new("UICorner", header).CornerRadius = UDim.new(0, 16)

create("Frame", {
    Size = UDim2.new(1, 0, 0, 2),
    Position = UDim2.new(0, 0, 1, -2),
    BackgroundColor3 = Color3.fromRGB(255, 50, 50),
    BorderSizePixel = 0
}, header)

create("TextLabel", {
    Size = UDim2.new(1, -100, 1, 0),
    Position = UDim2.fromOffset(20, 0),
    BackgroundTransparency = 1,
    Text = "MADlUM | HARDCORE LAG",
    TextColor3 = Color3.fromRGB(255, 100, 100),
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
    BackgroundColor3 = Color3.fromRGB(45, 25, 25),
    Text = "-",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 22,
    AutoButtonColor = false
}, header)

Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 8)

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
        BackgroundColor3 = Color3.fromRGB(25, 15, 15),
        Text = text,
        TextColor3 = color or Color3.fromRGB(220, 225, 240),
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    }, content)
    Instance.new("UICorner", l).CornerRadius = UDim.new(0, 8)
    return l
end

local pingLabel = createLabel("YOUR PING: Loading...", 15, Color3.fromRGB(255, 100, 100))
local fpsLabel = createLabel("YOUR FPS: Loading...", 58, Color3.fromRGB(255, 100, 100))

-- Sekcja celu
local targetHeader = createLabel("--- TARGET DATA ---", 101, Color3.fromRGB(255, 150, 150))
targetHeader.TextXAlignment = Enum.TextXAlignment.Center
targetHeader.BackgroundTransparency = 1

local targetPingLabel = createLabel("TARGET PING: 0 ms", 139, Color3.fromRGB(255, 80, 80))
local targetLossLabel = createLabel("TARGET LOSS: 0%", 182, Color3.fromRGB(255, 80, 80))

-- ==================== POLA WPROWADZANIA ====================
-- Nick celu
local targetNickBg = create("Frame", {
    Size = UDim2.new(1, -40, 0, 35),
    Position = UDim2.fromOffset(20, 225),
    BackgroundColor3 = Color3.fromRGB(25, 15, 15)
}, content)
Instance.new("UICorner", targetNickBg).CornerRadius = UDim.new(0, 8)

create("TextLabel", {
    Size = UDim2.fromOffset(80, 35),
    Position = UDim2.fromOffset(10, 0),
    BackgroundTransparency = 1,
    Text = "TARGET:",
    TextColor3 = Color3.fromRGB(255, 120, 120),
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
    Position = UDim2.fromOffset(20, 270),
    BackgroundColor3 = Color3.fromRGB(25, 15, 15)
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
    TextColor3 = Color3.fromRGB(255, 120, 120),
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
        Size = UDim2.new(1, -40, 0, 40),
        Position = UDim2.fromOffset(20, y),
        BackgroundColor3 = color,
        Text = text,
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        AutoButtonColor = false
    }, content)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end

local enabled = false
local toggle = createButton("ACTIVATE HARD LAG", 325, Color3.fromRGB(150, 30, 30))
local reset = createButton("RESET SIMULATION", 375, Color3.fromRGB(60, 60, 70))

-- ==================== LOGIKA LAGOWANIA ====================
local lagConnection
local frames = 0
local last = os.clock()

toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    
    if enabled then
        toggle.Text = "LAG ACTIVE - HOLD ON..."
        toggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        
        -- TWARDA PĘTLA OBCIĄŻAJĄCA PROCESOR (SYMULACJA ZAMROŻENIA)
        lagConnection = RunService.RenderStepped:Connect(function()
            local currentPackets = getPacketValue()
            local loopCount = currentPackets / 10 -- Im więcej pakietów, tym więcej obliczeń
            
            -- Pętla matematyczna zmuszająca CPU do pracy
            local x = 0
            for i = 1, loopCount do
                x = math.sin(i) * math.cos(i) + math.sqrt(i)
            end
            
            -- Losowe mikrozacięcia (od 1 do 10 klatek)
            if math.random(1, 100) > 95 then
                task.wait(math.random(1, 5) / 60) 
            end
        end)
    else
        if lagConnection then lagConnection:Disconnect() end
        toggle.Text = "ACTIVATE HARD LAG"
        toggle.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
    end
end)

reset.MouseButton1Click:Connect(function()
    enabled = false
    if lagConnection then lagConnection:Disconnect() end
    toggle.Text = "ACTIVATE HARD LAG"
    toggle.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
    targetPingLabel.Text = "TARGET PING: 0 ms"
    targetLossLabel.Text = "TARGET LOSS: 0%"
    packetInput.Text = "100000"
    targetInput.Text = "Player123"
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

-- ==================== LIVE LOGIC (STATYSTYKI) ====================
RunService.RenderStepped:Connect(function()
    frames += 1
    local now = os.clock()

    if now - last >= 1 then
        local fps = frames
        frames = 0
        last = now

        fpsLabel.Text = "YOUR FPS: " .. fps
        local ok, ping = pcall(function() return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() end)
        pingLabel.Text = ok and ("YOUR PING: " .. math.floor(ping) .. " ms") or "YOUR PING: unavailable"

        if enabled then
            local currentPackets = getPacketValue()
            local targetName = targetInput.Text ~= "" and targetInput.Text or "Unknown"
            
            -- Wizualne wartości (im więcej, tym gorzej)
            local fakePing = math.clamp(math.floor(currentPackets / 10), 100, 9999)
            local fakeLoss = math.clamp(math.floor((currentPackets / 100000) * 100), 1, 100)
            
            targetPingLabel.Text = string.format("TARGET [%s] PING: %d ms", targetName, fakePing)
            targetLossLabel.Text = string.format("TARGET LOSS: %d%%", fakeLoss)
        else
            targetPingLabel.Text = "TARGET PING: 0 ms"
            targetLossLabel.Text = "TARGET LOSS: 0%"
        end
    end
end)

print("MADlUM Hardcore Lag Simulator loaded. Use at your own risk.")
