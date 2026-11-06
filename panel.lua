-- language: Lua, file: panel.lua, target: Roblox Client / Modern UI Styling
-- *Zoptymalizowany, nowoczesny panel z płynnymi kolorami i dopracowanym interfejsem*

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local old = player.PlayerGui:FindFirstChild("LagPanel")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "LagPanel"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

-- Główny Kontener (Glassmorphism & Gradient)
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(320, 400)
frame.Position = UDim2.new(0.5, -160, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(15, 17, 23)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
frame.Active = true
frame.ClipsDescendants = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(255, 75, 75)
stroke.Thickness = 1.5
stroke.Transparency = 0.3

local bgGradient = Instance.new("UIGradient")
bgGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 26, 38)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 12, 16))
})
bgGradient.Rotation = 45
bgGradient.Parent = frame

-- Nagłówek
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = Color3.fromRGB(25, 30, 42)
title.BackgroundTransparency = 0.5
title.Text = "  MADlUM // PERFORMANCE SUITE"
title.TextColor3 = Color3.fromRGB(255, 90, 90)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 14)

-- Ping Display Box
local pingLabel = Instance.new("TextLabel")
pingLabel.Size = UDim2.new(0.9, 0, 0, 32)
pingLabel.Position = UDim2.new(0.05, 0, 0, 55)
pingLabel.BackgroundColor3 = Color3.fromRGB(20, 24, 33)
pingLabel.Text = "SERVER PING: -- ms"
pingLabel.TextColor3 = Color3.fromRGB(120, 210, 255)
pingLabel.Font = Enum.Font.GothamBold
pingLabel.TextSize = 12
pingLabel.Parent = frame
Instance.new("UICorner", pingLabel).CornerRadius = UDim.new(0, 8)

-- Input Box
local inputFrame = Instance.new("Frame")
inputFrame.Size = UDim2.new(0.9, 0, 0, 44)
inputFrame.Position = UDim2.new(0.05, 0, 0, 97)
inputFrame.BackgroundColor3 = Color3.fromRGB(20, 24, 33)
inputFrame.Parent = frame
Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 8)

local packetInput = Instance.new("TextBox")
packetInput.Size = UDim2.new(1, -20, 1, 0)
packetInput.Position = UDim2.new(0, 10, 0, 0)
packetInput.BackgroundTransparency = 1
packetInput.Text = "100000"
packetInput.PlaceholderText = "Wpisz ilość (1 - 500000)"
packetInput.TextColor3 = Color3.fromRGB(240, 240, 240)
packetInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
packetInput.Font = Enum.Font.GothamMedium
packetInput.TextSize = 13
packetInput.TextXAlignment = Enum.TextXAlignment.Center
packetInput.ClearTextOnFocus = false
packetInput.Parent = inputFrame

packetInput:GetPropertyChangedSignal("Text"):Connect(function()
    local cleaned = packetInput.Text:gsub("%D", "")
    if cleaned ~= packetInput.Text then
        packetInput.Text = cleaned
    end
end)

-- Auto-Chaos Button
local chaosBtn = Instance.new("TextButton")
chaosBtn.Size = UDim2.new(0.9, 0, 0, 38)
chaosBtn.Position = UDim2.new(0.05, 0, 0, 151)
chaosBtn.BackgroundColor3 = Color3.fromRGB(45, 30, 65)
chaosBtn.Text = "AUTO-CHAOS: OFF"
chaosBtn.TextColor3 = Color3.fromRGB(210, 160, 255)
chaosBtn.Font = Enum.Font.GothamBold
chaosBtn.TextSize = 12
chaosBtn.AutoButtonColor = false
chaosBtn.Parent = frame
Instance.new("UICorner", chaosBtn).CornerRadius = UDim.new(0, 8)

local chaosEnabled = false
chaosBtn.MouseButton1Click:Connect(function()
    chaosEnabled = not chaosEnabled
    TweenService:Create(chaosBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = chaosEnabled and Color3.fromRGB(110, 40, 170) or Color3.fromRGB(45, 30, 65)
    }):Play()
    chaosBtn.Text = chaosEnabled and "AUTO-CHAOS: ON" or "AUTO-CHAOS: OFF"
end)

-- Main Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 48)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 199)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 45, 55)
toggleBtn.Text = "ACTIVATE LAG"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = frame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 25)
statusLabel.Position = UDim2.new(0.05, 0, 0, 257)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "STATUS: IDLE"
statusLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextSize = 12
statusLabel.Parent = frame

-- Credits
local credits = Instance.new("TextLabel")
credits.Size = UDim2.new(1, 0, 0, 20)
credits.Position = UDim2.new(0, 0, 1, -24)
credits.BackgroundTransparency = 1
credits.Text = "crafted by R9K"
credits.TextColor3 = Color3.fromRGB(70, 70, 80)
credits.Font = Enum.Font.Gotham
credits.TextSize = 10
credits.Parent = frame

-- Logika działania
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
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play()
        toggleBtn.Text = "STOP LAG"
        statusLabel.Text = "STATUS: ACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(255, 90, 90)

        lagConnection = RunService.Stepped:Connect(function()
            local packets = getPacketValue()
            
            if chaosEnabled then
                packets = math.random(1000, 500000)
                packetInput.Text = tostring(packets)
            end
            
            local x = 0
            for i = 1, packets do
                x = x + math.tan(i) * math.atan(i)
            end
        end)
    else
        if lagConnection then lagConnection:Disconnect() end
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 45, 55)}):Play()
        toggleBtn.Text = "ACTIVATE LAG"
        statusLabel.Text = "STATUS: IDLE"
        statusLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
    end
end

toggleBtn.MouseButton1Click:Connect(toggleLag)

-- Odczyt pingu
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

-- Przeciąganie okna
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
