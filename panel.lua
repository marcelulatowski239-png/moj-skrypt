-- language: Lua, file: panel.lua, target: Roblox Client
-- MADlUM | ADVANCED LAG PANEL (Ping & Packet Control)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer

-- Usuwanie starego GUI
local old = player.PlayerGui:FindFirstChild("LagPanel")
if old then old:Destroy() end

-- Tworzenie GUI
local gui = Instance.new("ScreenGui")
gui.Name = "LagPanel"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(280, 260)
frame.Position = UDim2.new(0.5, -140, 0.5, -130)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(200, 50, 50)
stroke.Thickness = 2

-- Nagłówek
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "MADlUM | LAG PANEL"
title.TextColor3 = Color3.fromRGB(255, 100, 100)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

-- Ping serwera
local pingLabel = Instance.new("TextLabel")
pingLabel.Size = UDim2.new(1, 0, 0, 20)
pingLabel.Position = UDim2.new(0, 0, 0, 30)
pingLabel.BackgroundTransparency = 1
pingLabel.Text = "SERVER PING: -- ms"
pingLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
pingLabel.Font = Enum.Font.GothamBold
pingLabel.TextSize = 12
pingLabel.Parent = frame

-- Pole na pakiety
local inputFrame = Instance.new("Frame")
inputFrame.Size = UDim2.new(0.9, 0, 0, 35)
inputFrame.Position = UDim2.new(0.05, 0, 0, 60)
inputFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
inputFrame.Parent = frame
Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 6)

local packetInput = Instance.new("TextBox")
packetInput.Size = UDim2.new(1, -10, 1, 0)
packetInput.Position = UDim2.new(0, 5, 0, 0)
packetInput.BackgroundTransparency = 1
packetInput.Text = "100000"
packetInput.PlaceholderText = "Wpisz ilość pakietów..."
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

-- Przycisk
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 105)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
toggleBtn.Text = "ACTIVATE LAG"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.Parent = frame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

-- Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 160)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "STATUS: OFF"
statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.Parent = frame

-- Autor
local credits = Instance.new("TextLabel")
credits.Size = UDim2.new(1, 0, 0, 20)
credits.Position = UDim2.new(0, 0, 1, -25)
credits.BackgroundTransparency = 1
credits.Text = "created by R9K"
credits.TextColor3 = Color3.fromRGB(80, 80, 90)
credits.Font = Enum.Font.Gotham
credits.TextSize = 10
credits.Parent = frame

-- Logika
local enabled = false
local lagConnection

local function getPacketValue()
    local num = tonumber(packetInput.Text)
    if not num then return 100000 end
    return math.clamp(math.floor(num), 1, 500000) -- Max 500k dla bezpieczeństwa
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
            
            -- Główna pętla obciążająca procesor
            local x = 0
            for i = 1, packets do
                x = math.sin(i) * math.cos(i) + math.sqrt(i)
            end
            
            -- Losowe mikrozacięcia (im więcej pakietów, tym częstsze)
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

-- Odczyt pingu w czasie rzeczywistym
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
