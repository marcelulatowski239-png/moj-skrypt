-- language: Lua, file: panel.lua, target: Roblox Client / Neon Cyberpunk Theme
-- *Nowoczesny, dynamiczny motyw w odcianiach głębokiego fioletu, neonowego błękitu i magenty*

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

-- Główny Kontener (Cyberpunk Glow)
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(320, 410)
frame.Position = UDim2.new(0.5, -160, 0.5, -205)
frame.BackgroundColor3 = Color3.fromRGB(13, 11, 20)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
frame.Active = true
frame.ClipsDescendants = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(160, 50, 255)
stroke.Thickness = 2
stroke.Transparency = 0.2

local bgGradient = Instance.new("UIGradient")
bgGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 15, 38)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 6, 14))
})
bgGradient.Rotation = 135
bgGradient.Parent = frame

-- Nagłówek
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = Color3.fromRGB(35, 20, 55)
title.BackgroundTransparency = 0.4
title.Text = "  MADlUM // CYBER PANEL"
title.TextColor3 = Color3.fromRGB(210, 100, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 16)

-- Ping Display Box
local pingLabel = Instance.new("TextLabel")
pingLabel.Size = UDim2.new(0.9, 0, 0, 34)
pingLabel.Position = UDim2.new(0.05, 0, 0, 55)
pingLabel.BackgroundColor3 = Color3.fromRGB(20, 14, 32)
pingLabel.Text = "SERVER PING: -- ms"
pingLabel.TextColor3 = Color3.fromRGB(100, 220, 255)
pingLabel.Font = Enum.Font.GothamBold
pingLabel.TextSize = 12
pingLabel.Parent = frame
Instance.new("UICorner", pingLabel).CornerRadius = UDim.new(0, 10)

-- Input Box
local inputFrame = Instance.new("Frame")
inputFrame.Size = UDim2.new(0.9, 0, 0, 44)
inputFrame.Position = UDim2.new(0.05, 0, 0, 100)
inputFrame.BackgroundColor3 = Color3.fromRGB(20, 14, 32)
inputFrame.Parent = frame
Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 10)

local packetInput = Instance.new("TextBox")
packetInput.Size = UDim2.new(1, -20, 1, 0)
packetInput.Position = UDim2.new(0, 10, 0, 0)
packetInput.BackgroundTransparency = 1
packetInput.Text = "100000"
packetInput.PlaceholderText = "Wpisz ilość (1 - 500000)"
packetInput.TextColor3 = Color3.fromRGB(240, 240, 255)
packetInput.PlaceholderColor3 = Color3.fromRGB(110, 95, 140)
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
chaosBtn.Position = UDim2.new(0.05, 0, 0, 155)
chaosBtn.BackgroundColor3 = Color3.fromRGB(45, 15, 60)
chaosBtn.Text = "AUTO-CHAOS: OFF"
chaosBtn.TextColor3 = Color3.fromRGB(255, 130, 210)
chaosBtn.Font = Enum.Font.GothamBold
chaosBtn.TextSize = 12
chaosBtn.AutoButtonColor = false
chaosBtn.Parent = frame
Instance.new("UICorner", chaosBtn).CornerRadius = UDim.new(0, 10)

local chaosEnabled = false
chaosBtn.MouseButton1Click:Connect(function()
    chaosEnabled = not chaosEnabled
    TweenService:Create(chaosBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = chaosEnabled and Color3.fromRGB(140, 20, 120) or Color3.fromRGB(45, 15, 60)
    }):Play()
    chaosBtn.Text = chaosEnabled and "AUTO-CHAOS: ON" or "AUTO-CHAOS: OFF"
end)

-- Main Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 48)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 204)
toggleBtn.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
toggleBtn.Text = "ACTIVATE LAG"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = frame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 10)

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 25)
statusLabel.Position = UDim2.new(0.05, 0, 0, 263)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "STATUS: IDLE"
statusLabel.TextColor3 = Color3.fromRGB(130, 115, 160)
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextSize = 12
statusLabel.Parent = frame

-- Credits
local credits = Instance.new("TextLabel")
credits.Size = UDim2.new(1, 0, 0, 20)
credits.Position = UDim2.new(0, 0, 1, -26)
credits.BackgroundTransparency = 1
credits.Text = "crafted by R9K"
credits.TextColor3 = Color3.fromRGB(80, 60, 110)
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
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(220, 40, 90)}):Play()
        toggleBtn.Text = "STOP LAG"
        statusLabel.Text = "STATUS: ACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 120)

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
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 35, 60)}):Play()
        toggleBtn.Text = "ACTIVATE LAG"
        statusLabel.Text = "STATUS: IDLE"
        statusLabel.TextColor3 = Color3.fromRGB(130, 115, 160)
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
