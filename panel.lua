-- language: Lua, file: panel.lua, target: Roblox Executor / Ping Lagger & Packet Freezer
-- *Zaawansowany panel pinger/lagger z buforowaniem pakietów wychodzących*

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer

local remoteEvent = ReplicatedStorage:FindFirstChild("SyncEvent")
if not remoteEvent and RunService:IsServer() then
    remoteEvent = Instance.new("RemoteEvent")
    remoteEvent.Name = "SyncEvent"
    remoteEvent.Parent = ReplicatedStorage
elseif not remoteEvent then
    remoteEvent = ReplicatedStorage:WaitForChild("SyncEvent", 5)
end

local lagMs = 500 -- domyślny lag pakietów w ms
local lagActive = false
local outboundPacketBuffer = {}

local oldGui = localPlayer.PlayerGui:FindFirstChild("PingLaggerPanel")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "PingLaggerPanel"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = localPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(360, 390)
frame.Position = UDim2.new(0.5, -180, 0.5, -195)
frame.BackgroundColor3 = Color3.fromRGB(12, 10, 20)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
frame.Active = true
frame.ClipsDescendants = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(255, 50, 50)
stroke.Thickness = 2
stroke.Transparency = 0.15

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = Color3.fromRGB(60, 12, 20)
title.BackgroundTransparency = 0.3
title.Text = "  MADlUM // PACKET LAGGER v2"
title.TextColor3 = Color3.fromRGB(255, 90, 90)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 16)

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(0.9, 0, 0, 70)
statsLabel.Position = UDim2.new(0.05, 0, 0, 55)
statsLabel.BackgroundColor3 = Color3.fromRGB(20, 14, 28)
statsLabel.TextColor3 = Color3.fromRGB(220, 180, 180)
statsLabel.Font = Enum.Font.Code
statsLabel.TextSize = 11
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.TextYAlignment = Enum.TextYAlignment.Center
statsLabel.Parent = frame
Instance.new("UICorner", statsLabel).CornerRadius = UDim.new(0, 10)

local padding = Instance.new("UIPadding", statsLabel)
padding.PaddingLeft = UDim.new(0, 12)

local sliderContainer = Instance.new("Frame")
sliderContainer.Size = UDim2.new(0.9, 0, 0, 60)
sliderContainer.Position = UDim2.new(0.05, 0, 0, 135)
sliderContainer.BackgroundColor3 = Color3.fromRGB(20, 14, 28)
sliderContainer.Parent = frame
Instance.new("UICorner", sliderContainer).CornerRadius = UDim.new(0, 10)

local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(1, -20, 0, 25)
sliderLabel.Position = UDim2.new(0, 10, 0, 5)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "Packet Lag: 500 ms"
sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
sliderLabel.Font = Enum.Font.GothamBold
sliderLabel.TextSize = 12
sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
sliderLabel.Parent = sliderContainer

local track = Instance.new("Frame")
track.Size = UDim2.new(1, -20, 0, 6)
track.Position = UDim2.new(0, 10, 0, 38)
track.BackgroundColor3 = Color3.fromRGB(50, 20, 30)
track.BorderSizePixel = 0
track.Parent = sliderContainer
Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

local fill = Instance.new("Frame")
fill.Size = UDim2.new((lagMs - 100) / 1900, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
fill.BorderSizePixel = 0
fill.Parent = track
Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

local sliderBtn = Instance.new("TextButton")
sliderBtn.Size = UDim2.new(1, 0, 1, 10)
sliderBtn.Position = UDim2.new(0, 0, 0, -5)
sliderBtn.BackgroundTransparency = 1
sliderBtn.Text = ""
sliderBtn.Parent = track

local isDragging = false
sliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        lagMs = math.floor(100 + pos * 1900)
        sliderLabel.Text = string.format("Packet Lag: %d ms", lagMs)
    end
end)

local btnContainer = Instance.new("Frame")
btnContainer.Size = UDim2.new(0.9, 0, 0, 40)
btnContainer.Position = UDim2.new(0.05, 0, 0, 205)
btnContainer.BackgroundTransparency = 1
btnContainer.Parent = frame

local function createButton(name, color, posX)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.31, 0, 1, 0)
    btn.Position = UDim2.new(posX, 0, 0, 0)
    btn.BackgroundColor3 = color
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = btnContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local freezeBtn = createButton("FREEZE", Color3.fromRGB(200, 40, 40), 0)
local releaseBtn = createButton("RELEASE", Color3.fromRGB(40, 160, 80), 0.345)
local flushBtn = createButton("FLUSH", Color3.fromRGB(80, 80, 120), 0.69)

freezeBtn.MouseButton1Click:Connect(function() lagActive = true end)
releaseBtn.MouseButton1Click:Connect(function() 
    lagActive = false 
    outboundPacketBuffer = {}
end)
flushBtn.MouseButton1Click:Connect(function()
    -- Natychmiastowe wypuszczenie wszystkich skumulowanych pakietów
    if remoteEvent then
        for _, pkt in ipairs(outboundPacketBuffer) do
            pcall(function()
                remoteEvent:FireServer(unpack(pkt))
            end)
        end
    end
    outboundPacketBuffer = {}
end)

local infoBox = Instance.new("TextLabel")
infoBox.Size = UDim2.new(0.9, 0, 0, 55)
infoBox.Position = UDim2.new(0.05, 0, 0, 255)
infoBox.BackgroundColor3 = Color3.fromRGB(16, 12, 22)
infoBox.Text = " STATUS: Lagger Ready\n MODE: Outbound Packet Buffer"
infoBox.TextColor3 = Color3.fromRGB(190, 130, 130)
infoBox.Font = Enum.Font.Code
infoBox.TextSize = 11
infoBox.TextXAlignment = Enum.TextXAlignment.Left
infoBox.TextYAlignment = Enum.TextYAlignment.Center
infoBox.Parent = frame
Instance.new("UICorner", infoBox).CornerRadius = UDim.new(0, 10)

local infoPadding = Instance.new("UIPadding", infoBox)
infoPadding.PaddingLeft = UDim.new(0, 10)

local credits = Instance.new("TextLabel")
credits.Size = UDim2.new(1, 0, 0, 20)
credits.Position = UDim2.new(0, 0, 1, -25)
credits.BackgroundTransparency = 1
credits.Text = "crafted by R9K"
credits.TextColor3 = Color3.fromRGB(100, 70, 90)
credits.Font = Enum.Font.Gotham
credits.TextSize = 10
credits.Parent = frame

-- Główna pętla zatrzymująca i uwalniająca pakiety wychodzące
RunService.RenderStepped:Connect(function(dt)
    local fps = math.floor(1 / dt)
    local packetsInQueue = #outboundPacketBuffer
    
    statsLabel.Text = string.format("FPS: %d | QUEUE: %d PKTS\nLAG: %d ms | STATE: %s", 
        fps, packetsInQueue, lagMs, lagActive and "FROZEN (LAGGING)" : "NORMAL")

    local now = os.clock()

    -- Symulacja wysyłania pakietu ruchu z ograniczeniem częstotliwości (20 Hz)
    if remoteEvent and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = localPlayer.Character.HumanoidRootPart
        local packetData = {"RequestSync", nil, hrp.CFrame, now}

        if lagActive then
            -- Zatrzymujemy pakiet w buforze lokalnym zamiast wysyłać do serwera
            table.insert(outboundPacketBuffer, {time = now, data = packetData})
        else
            -- Normalny tryb / wypuszczanie zaległych pakietów z opóźnieniem
            pcall(function()
                remoteEvent:FireServer(unpack(packetData))
            end)

            -- Wypuszczanie pakietów z bufora po upłynięciu lagMs
            local delaySec = lagMs / 1000
            while #outboundPacketBuffer > 0 and (now - outboundPacketBuffer[1].time) >= delaySec do
                local pkt = table.remove(outboundPacketBuffer, 1)
                pcall(function()
                    remoteEvent:FireServer(unpack(pkt.data))
                end)
            end
        end
    end
end)

-- Przesuwanie okna myszką
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
