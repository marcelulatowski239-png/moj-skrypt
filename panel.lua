-- MADlUM | PACKET LAGGER GUI (Targeted Simulation)
-- Local diagnostic simulator with UI showing targeted lag
-- WARNING: This is a VISUAL simulation only. It does NOT send actual packets to other players.

local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local old = player.PlayerGui:FindFirstChild("MadiumGUI")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "MadiumGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(440, 480) -- Увеличили высоту для новых настроек
main.Position = UDim2.new(0.5, -220, 0.5, -240)
main.BackgroundColor3 = Color3.fromRGB(15, 17, 27)
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

local outline = Instance.new("UIStroke", main)
outline.Color = Color3.fromRGB(75, 110, 255)
outline.Thickness = 1.5

local function create(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

-- HEADER
local header = create("Frame", {
    Size = UDim2.new(1, 0, 0, 50),
    BackgroundColor3 = Color3.fromRGB(25, 29, 45),
    BorderSizePixel = 0
}, main)

Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)

create("TextLabel", {
    Size = UDim2.new(1, -90, 1, 0),
    Position = UDim2.fromOffset(16, 0),
    BackgroundTransparency = 1,
    Text = "MADlUM | TARGETED LAGGER",
    TextColor3 = Color3.fromRGB(120, 155, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    TextXAlignment = Enum.TextXAlignment.Left
}, header)

-- DRAG
local dragging = false
local dragStart
local startPosition

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- MINIMIZE
local minimized = false
local minimize = create("TextButton", {
    Size = UDim2.fromOffset(32, 30),
    Position = UDim2.new(1, -42, 0, 10),
    BackgroundColor3 = Color3.fromRGB(65, 85, 155),
    Text = "-",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 20
}, header)

Instance.new("UICorner", minimize).CornerRadius = UDim.new(0, 7)

-- CONTENT
local content = create("Frame", {
    Size = UDim2.new(1, 0, 1, -50),
    Position = UDim2.fromOffset(0, 50),
    BackgroundTransparency = 1
}, main)

local function label(text, y, color)
    local l = create("TextLabel", {
        Size = UDim2.new(1, -32, 0, 35),
        Position = UDim2.fromOffset(16, y),
        BackgroundColor3 = Color3.fromRGB(27, 31, 46),
        Text = text,
        TextColor3 = color or Color3.fromRGB(230, 235, 250),
        Font = Enum.Font.Gotham,
        TextSize = 13
    }, content)

    Instance.new("UICorner", l).CornerRadius = UDim.new(0, 7)
    return l
end

local pingLabel = label("YOUR PING: Loading...", 15, Color3.fromRGB(100, 200, 255))
local fpsLabel = label("YOUR FPS: Loading...", 58, Color3.fromRGB(100, 200, 255))
local targetPingLabel = label("TARGET PING: 0 ms", 101, Color3.fromRGB(255, 100, 100))
local targetLossLabel = label("TARGET LOSS: 0%", 144, Color3.fromRGB(255, 100, 100))

-- ==================== TEXTBOX ДЛЯ ВВОДА ====================
local inputBg = create("Frame", {
    Size = UDim2.new(1, -32, 0, 35),
    Position = UDim2.fromOffset(16, 187),
    BackgroundColor3 = Color3.fromRGB(27, 31, 46)
}, content)

Instance.new("UICorner", inputBg).CornerRadius = UDim.new(0, 7)

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
    TextColor3 = Color3.fromRGB(120, 155, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Right
}, inputBg)

packetInput:GetPropertyChangedSignal("Text"):Connect(function()
    local cleaned = packetInput.Text:gsub("%D", "")
    if cleaned ~= packetInput.Text then
        packetInput.Text = cleaned
    end
end)

local function getPacketValue()
    local num = tonumber(packetInput.Text)
    if not num then return 50000 end
    if num < 1 then return 1 end
    if num > 100000 then return 100000 end
    return math.floor(num)
end

-- ==================== КНОПКИ ====================
local function button(text, y, color)
    local b = create("TextButton", {
        Size = UDim2.new(1, -32, 0, 35),
        Position = UDim2.fromOffset(16, y),
        BackgroundColor3 = color,
        Text = text,
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 13
    }, content)

    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    return b
end

local enabled = false
local toggle = button("TARGETED SIMULATION: OFF", 235, Color3.fromRGB(55, 75, 145))

toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggle.Text = enabled and "TARGETED SIMULATION: ON" or "TARGETED SIMULATION: OFF"
    toggle.BackgroundColor3 = enabled
        and Color3.fromRGB(200, 50, 50)
        or Color3.fromRGB(55, 75, 145)
end)

local reset = button("RESET SIMULATION", 280, Color3.fromRGB(80, 85, 105))

reset.MouseButton1Click:Connect(function()
    enabled = false
    toggle.Text = "TARGETED SIMULATION: OFF"
    toggle.BackgroundColor3 = Color3.fromRGB(55, 75, 145)
    targetPingLabel.Text = "TARGET PING: 0 ms"
    targetLossLabel.Text = "TARGET LOSS: 0%"
    packetInput.Text = "100000"
end)

minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    main.Size = minimized
        and UDim2.fromOffset(440, 50)
        or UDim2.fromOffset(440, 480)
    minimize.Text = minimized and "+" or "-"
end)

-- ==================== LIVE LOGIC ====================
local frames = 0
local last = os.clock()

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

        -- Твой пинг отображается всегда, он зависит только от твоего интернета
        pingLabel.Text = ok
            and ("YOUR PING: " .. math.floor(ping) .. " ms")
            or "YOUR PING: unavailable"

        -- СИМУЛЯЦИЯ ЛАГОВ ЦЕЛИ (Визуальная)
        if enabled then
            local currentPackets = getPacketValue()
            
            -- При 100 000 пакетов: 100% потерь и огромный пинг (до 9999 мс)
            local lossPercent = math.clamp(math.floor(currentPackets / 1000), 1, 100)
            local delayMs = math.clamp(math.floor(currentPackets / 10), 100, 9999)
            
            targetLossLabel.Text = "TARGET LOSS: " .. lossPercent .. "%"
            targetPingLabel.Text = "TARGET PING: " .. delayMs .. " ms"
        else
            targetLossLabel.Text = "TARGET LOSS: 0%"
            targetPingLabel.Text = "TARGET PING: 0 ms"
        end
    end
end)

print("MADlUM GUI (Targeted Simulation) loaded successfully!")
