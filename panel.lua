-- language: Lua, file: panel.lua, target: Roblox Client
-- MADlUM | ULTIMATE LAG PANEL (Ping, Packets, Auto-Chaos)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Usuwanie starego GUI
local old = player.PlayerGui:FindFirstChild("LagPanel")
if old then old:Destroy() end

-- Tworzenie GUI
local gui = Instance.new("ScreenGui")
gui.Name = "LagPanel"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(300, 380)
frame.Position = UDim2.new(0.5, -150, 0.5, -190)
frame.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.ClipsDescendants = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(200, 50, 50)
stroke.Thickness = 2

-- ==================== NAGŁÓWEK ====================
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(20, 24, 35)
title.Text = "MADlUM | ULTIMATE LAG"
title.TextColor3 = Color3.fromRGB(255, 100, 100)
title.Font = Enum.Font.GothamBlack
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

-- ==================== PING ====================
local pingLabel = Instance.new("TextLabel")
pingLabel.Size = UDim2.new(0.9, 0, 0, 25)
pingLabel.Position = UDim2.new(0.05, 0, 0, 45)
pingLabel.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
pingLabel.Text = "SERVER PING: -- ms"
pingLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
pingLabel.Font = Enum.Font.GothamBold
pingLabel.TextSize = 13
pingLabel.Parent = frame
Instance.new("UICorner", pingLabel).CornerRadius = UDim.new(0, 6)

-- ==================== INPUT PAKIETÓW ====================
local inputFrame = Instance.new("Frame")
inputFrame.Size = UDim2.new(0.9, 0, 0, 40)
inputFrame.Position = UDim2.new(0.05, 0, 0, 80)
inputFrame.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
inputFrame.Parent = frame
Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 6)

local packetInput = Instance.new("TextBox")
packetInput.Size = UDim2.new(1, -20, 1, 0)
packetInput.Position = UDim2.new(0, 10, 0, 0)
packetInput.BackgroundTransparency = 1
packetInput.Text = "100000"
packetInput.PlaceholderText = "Wpisz ilość pakietów (1 - 500000)"
packetInput.TextColor3 = Color3.new(1, 1, 1)
packetInput.Font = Enum.Font.GothamBold
packetInput.TextSize = 14
packetInput.TextXAlignment = Enum.TextXAlignment.Center
packetInput.ClearTextOnFocus = false
packetInput.Parent = inputFrame

-- Filtrowanie tekstu (tylko cyfry)
packetInput:GetPropertyChangedSignal("Text"):Connect(function()
    local cleaned = packetInput.Text:gsub("%D", "")
    if cleaned ~= packetInput.Text then
        packetInput.Text = cleaned
    end
end)

-- ==================== AUTO-CHAOS ====================
local chaosBtn = Instance.new("TextButton")
chaosBtn.Size = UDim2.new(0.9, 0, 0, 35)
chaosBtn.Position = UDim2.new(0.05, 0, 0, 130)
chaosBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 80)
chaosBtn.Text = "AUTO-CHAOS: OFF"
chaosBtn.TextColor3 = Color3.new(1, 1, 1)
chaosBtn.Font = Enum.Font.GothamBold
chaosBtn.TextSize = 13
chaosBtn.Parent = frame
Instance.new("UICorner", chaosBtn).CornerRadius = UDim.new(0, 6)

local chaosEnabled = false
chaosBtn.MouseButton1Click:Connect(function()
    chaosEnabled = not chaosEnabled
    if chaosEnabled then
        chaosBtn.Text = "AUTO-CHAOS: ON"
        chaosBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
    else
        chaosBtn.Text = "AUTO-CHAOS: OFF"
        chaosBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 80)
    end
end)

-- ==================== PRZYCISK START/STOP ====================
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 180)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
toggleBtn.Text = "ACTIVATE LAG"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 15
toggleBtn.Parent = frame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

-- ==================== STATUS ====================
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 25)
statusLabel.Position = UDim2.new(0.05, 0, 0, 235)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "STATUS: OFF"
statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.Parent = frame

-- ==================== AUTOR ====================
local credits = Instance.new("TextLabel")
credits.Size = UDim2.new(1, 0, 0, 20)
credits.Position = UDim2.new(0, 0, 1, -25)
credits.BackgroundTransparency = 1
credits.Text = "created by R9K"
credits.TextColor3 = Color3.fromRGB(80, 80, 90)
credits.Font = Enum.Font.Gotham
credits.TextSize = 10
credits.Parent = frame

-- ==================== LOGIKA ====================
local enabled = false
local lagConnection

local function getPacketValue()
    local num = tonumber(packetInput.Text)
    if not num then return 100000 end
    return math.clamp(math.floor(num), 1, 500000)
end

local function toggleLag()
    enabled = not enabled
    if enabled then
        toggleBtn.Text = "STOP LAG"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        statusLabel.Text = "STATUS: LAGGING"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)

        lagConnection = RunService.RenderStepped:Connect(function()
            local packets = getPacketValue()
            
            if chaosEnabled then
                packets = math.random(1000, 500000)
                packetInput.Text = tostring(packets)
            end
            
            local x = 0
            for i = 1, packets do
                x = math.sin(i) * math.cos(i) + math.sqrt(i)
            end
            
            if math.random(1, 100) > (90 - (packets / 10000)) then
                task.wait(0.05)
            end
        end)
    else
        if lagConnection then lagConnection:Disconnect() end
        toggleBtn.Text = "ACTIVATE LAG"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        statusLabel.Text = "STATUS: OFF"
        statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
end

toggleBtn.MouseButton1Click:Connect(toggleLag)

-- ==================== ODCZYT PINGU ====================
task.spawn(function()
    while gui.Parent do
        local ok, ping = pcall(function()
            return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        
        if ok and ping then
            pingLabel.Text = string.format("SERVER PING: %d ms", math.floor(ping))
        else
            pingLabel.Text = "SERVER PING: unavailable"
        end
        
        task.wait(1)
    end
end)

-- ==================== PRZECIĄGANIE GUI ====================
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
