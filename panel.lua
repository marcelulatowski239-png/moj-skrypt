
-- MADlUM | PACKET LAGGER GUI
-- Local diagnostic simulator
-- Movable window + Ping + FPS + Packet Loss simulation

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
main.Size = UDim2.fromOffset(440, 340)
main.Position = UDim2.new(0.5, -220, 0.5, -170)
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
    Text = "MADlUM  |  PACKET LAGGER",
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

local function label(text, y)
    local l = create("TextLabel", {
        Size = UDim2.new(1, -32, 0, 35),
        Position = UDim2.fromOffset(16, y),
        BackgroundColor3 = Color3.fromRGB(27, 31, 46),
        Text = text,
        TextColor3 = Color3.fromRGB(230, 235, 250),
        Font = Enum.Font.Gotham,
        TextSize = 13
    }, content)

    Instance.new("UICorner", l).CornerRadius = UDim.new(0, 7)
    return l
end

local pingLabel = label("PING: Loading...", 15)
local fpsLabel = label("FPS: Loading...", 58)
local lossLabel = label("SIMULATED PACKET LOSS: 0%", 101)
local delayLabel = label("SIMULATED DELAY: 0 ms", 144)

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
local toggle = button("SIMULATION: OFF", 192, Color3.fromRGB(55, 75, 145))

toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggle.Text = enabled and "SIMULATION: ON" or "SIMULATION: OFF"
    toggle.BackgroundColor3 = enabled
        and Color3.fromRGB(35, 145, 100)
        or Color3.fromRGB(55, 75, 145)
end)

local reset = button("RESET SIMULATION", 237, Color3.fromRGB(80, 85, 105))

reset.MouseButton1Click:Connect(function()
    enabled = false
    toggle.Text = "SIMULATION: OFF"
    toggle.BackgroundColor3 = Color3.fromRGB(55, 75, 145)
    lossLabel.Text = "SIMULATED PACKET LOSS: 0%"
    delayLabel.Text = "SIMULATED DELAY: 0 ms"
end)

minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    main.Size = minimized
        and UDim2.fromOffset(440, 50)
        or UDim2.fromOffset(440, 340)
    minimize.Text = minimized and "+" or "-"
end)

-- LIVE PING AND FPS
local frames = 0
local last = os.clock()

RunService.RenderStepped:Connect(function()
    frames += 1
    local now = os.clock()

    if now - last >= 1 then
        local fps = frames
        frames = 0
        last = now

        fpsLabel.Text = "FPS: " .. fps

        local ok, ping = pcall(function()
            return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        end)

        pingLabel.Text = ok
            and ("PING: " .. math.floor(ping) .. " ms")
            or "PING: unavailable"

        if enabled then
            lossLabel.Text = "SIMULATED PACKET LOSS: 10%"
            delayLabel.Text = "SIMULATED DELAY: 100 ms"
        end
    end
end)

print("MADlUM GUI loaded successfully!")
