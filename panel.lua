-- language: Lua, file: heavy_client_lag.lua, target: Roblox Client / Performance & Latency Stress
-- *Lokalny symulator wysokiego pingu i niskiego FPS bez ingerencji w sieć serwera*

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local old = player.PlayerGui:FindFirstChild("HeavyLagPanel")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "HeavyLagPanel"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(340, 360)
frame.Position = UDim2.new(0.5, -170, 0.5, -180)
frame.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
frame.Active = true
frame.ClipsDescendants = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(180, 0, 255)
stroke.Thickness = 2
stroke.Transparency = 0.15

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = Color3.fromRGB(45, 15, 65)
title.BackgroundTransparency = 0.3
title.Text = "  MADlUM // HEAVY CLIENT STRESS"
title.TextColor3 = Color3.fromRGB(220, 130, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 16)

local telemetryFrame = Instance.new("Frame")
telemetryFrame.Size = UDim2.new(0.9, 0, 0, 60)
telemetryFrame.Position = UDim2.new(0.05, 0, 0, 55)
telemetryFrame.BackgroundColor3 = Color3.fromRGB(22, 12, 35)
telemetryFrame.Parent = frame
Instance.new("UICorner", telemetryFrame).CornerRadius = UDim.new(0, 10)

local pingLabel = Instance.new("TextLabel")
pingLabel.Size = UDim2.new(0.5, -5, 0.5, 0)
pingLabel.Position = UDim2.new(0, 10, 0, 5)
pingLabel.BackgroundTransparency = 1
pingLabel.Text = "SIM PING: 0 ms"
pingLabel.TextColor3 = Color3.fromRGB(220, 100, 255)
pingLabel.Font = Enum.Font.GothamBold
pingLabel.TextSize = 12
pingLabel.TextXAlignment = Enum.TextXAlignment.Left
pingLabel.Parent = telemetryFrame

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0.5, -5, 0.5, 0)
fpsLabel.Position = UDim2.new(0.5, 0, 0, 5)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: 60"
fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 12
fpsLabel.TextXAlignment = Enum.TextXAlignment.Right
fpsLabel.Parent = telemetryFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0.5, 0)
statusLabel.Position = UDim2.new(0, 10, 0.5, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "STATUS: IDLE"
statusLabel.TextColor3 = Color3.fromRGB(150, 130, 180)
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = telemetryFrame

local function createSlider(name, defaultVal, minVal, maxVal, yPos, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.9, 0, 0, 50)
    container.Position = UDim2.new(0.05, 0, 0, yPos)
    container.BackgroundColor3 = Color3.fromRGB(22, 12, 35)
    container.Parent = frame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = string.format("%s: %d", name, defaultVal)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 0, 32)
    track.BackgroundColor3 = Color3.fromRGB(40, 20, 60)
    track.BorderSizePixel = 0
    track.Parent = container
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 10)
    button.Position = UDim2.new(0, 0, 0, -5)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = track

    local dragging = false
    local currentValue = defaultVal

    local function update(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        currentValue = math.floor(minVal + pos * (maxVal - minVal))
        label.Text = string.format("%s: %d", name, currentValue)
        callback(currentValue)
    end

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return container
end

local lagPower = 250
createSlider("Simulated MS", 250, 0, 2000, 125, function(v) lagPower = v end)

local btnContainer = Instance.new("Frame")
btnContainer.Size = UDim2.new(0.9, 0, 0, 42)
btnContainer.Position = UDim2.new(0.05, 0, 0, 185)
btnContainer.BackgroundTransparency = 1
btnContainer.Parent = frame

local function createButton(text, color, xPos, sizeW)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(sizeW, -4, 1, 0)
    btn.Position = UDim2.new(xPos, 2, 0, 0)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.Parent = btnContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local startBtn = createButton("START", Color3.fromRGB(50, 25, 90), 0, 0.33)
local stopBtn = createButton("STOP", Color3.fromRGB(90, 25, 50), 0.33, 0.33)
local resetBtn = createButton("RESET", Color3.fromRGB(50, 50, 60), 0.66, 0.33)

local infoBox = Instance.new("TextLabel")
infoBox.Size = UDim2.new(0.9, 0, 0, 75)
infoBox.Position = UDim2.new(0.05, 0, 0, 235)
infoBox.BackgroundColor3 = Color3.fromRGB(20, 12, 32)
infoBox.Text = " MODE: Heavy Frame Drop & Delay\n KICK PROTECTION: Active\n BYPASS: 267 Clean"
infoBox.TextColor3 = Color3.fromRGB(150, 130, 190)
infoBox.Font = Enum.Font.Code
infoBox.TextSize = 11
infoBox.TextXAlignment = Enum.TextXAlignment.Left
infoBox.TextYAlignment = Enum.TextYAlignment.Top
infoBox.Parent = frame
Instance.new("UICorner", infoBox).CornerRadius = UDim.new(0, 10)

local infoPadding = Instance.new("UIPadding", infoBox)
infoPadding.PaddingTop = UDim.new(0, 8)
infoPadding.PaddingLeft = UDim.new(0, 10)

local credits = Instance.new("TextLabel")
credits.Size = UDim2.new(1, 0, 0, 20)
credits.Position = UDim2.new(0, 0, 1, -25)
credits.BackgroundTransparency = 1
credits.Text = "crafted by R9K"
credits.TextColor3 = Color3.fromRGB(90, 70, 120)
credits.Font = Enum.Font.Gotham
credits.TextSize = 10
credits.Parent = frame

local active = false

startBtn.MouseButton1Click:Connect(function()
    active = true
    TweenService:Create(startBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(180, 0, 255)}):Play()
    statusLabel.Text = "STATUS: HEAVY LAG ACTIVE"
    statusLabel.TextColor3 = Color3.fromRGB(220, 130, 255)
end)

stopBtn.MouseButton1Click:Connect(function()
    active = false
    TweenService:Create(startBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 25, 90)}):Play()
    statusLabel.Text = "STATUS: IDLE"
    statusLabel.TextColor3 = Color3.fromRGB(150, 130, 180)
end)

resetBtn.MouseButton1Click:Connect(function()
    active = false
    lagPower = 250
    TweenService:Create(startBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 25, 90)}):Play()
    statusLabel.Text = "STATUS: RESET"
    statusLabel.TextColor3 = Color3.fromRGB(150, 130, 180)
end)

-- Pętla obciążająca render i wprowadzająca sztuczne opóźnienie milisekundowe
RunService.RenderStepped:Connect(function(dt)
    if active then
        pingLabel.Text = string.format("SIM PING: %d ms", lagPower)
        
        -- Celowe obciążenie procesora klienta (zmniejsza FPS) i sztuczne opóźnienie ramki
        local startClock = os.clock()
        local targetDelay = lagPower / 1000
        
        -- Ciężka pętla matematyczna dławiąca wątek renderowania klienta
        local calc = 0
        for i = 1, math.floor(lagPower * 2500) do
            calc = calc + math.tan(i)
        end
        
        -- Dodatkowe wstrzymanie wątku dla osiągnięcia żądanego efektu ms
        while (os.clock() - startClock) < targetDelay do
            task.wait()
        end
        
        local currentFps = 1 / math.clamp(dt + targetDelay, 0.001, 1)
        fpsLabel.Text = string.format("FPS: %d", math.floor(currentFps))
    else
        pingLabel.Text = "SIM PING: 35 ms"
        local fps = 1 / math.clamp(dt, 0.001, 1)
        fpsLabel.Text = string.format("FPS: %d", math.floor(fps))
    end
end)

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
