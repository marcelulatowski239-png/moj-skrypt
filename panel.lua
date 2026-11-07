-- language: Lua, file: panel.lua, target: Roblox Executor / Steal a Brainrot Duels
-- *Adapt Hub Style Ping Lagger - Płynny bufor ruchowy*

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local remoteEvent = ReplicatedStorage:FindFirstChild("SyncEvent") or ReplicatedStorage:FindFirstChild("RemoteEvent")

local lagActive = false
local packetQueue = {}

-- Czyszczenie starego GUI
local oldGui = localPlayer.PlayerGui:FindFirstChild("AdaptLaggerGui")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "AdaptLaggerGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = localPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(280, 180)
frame.Position = UDim2.new(0.7, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(160, 40, 40)
stroke.Thickness = 2

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(45, 15, 18)
title.BackgroundTransparency = 0.2
title.Text = "  Cursed Hub Ping Lagger"
title.TextColor3 = Color3.fromRGB(255, 100, 100)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 40)
statusLabel.Position = UDim2.new(0.05, 0, 0, 45)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: LAGGING (0 pkts)"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Code
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 95)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 160, 60)
toggleBtn.Text = "ENABLE"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.Parent = frame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

toggleBtn.MouseButton1Click:Connect(function()
    lagActive = not lagActive
    if lagActive then
        toggleBtn.Text = "DISABLE"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    else
        toggleBtn.Text = "ENABLE"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 160, 60)
        
        -- Wypuszczenie wszystkich zaległych pakietów po wyłączeniu (Release)
        if remoteEvent then
            for _, pkt in ipairs(packetQueue) do
                pcall(function()
                    remoteEvent:FireServer(unpack(pkt))
                end)
            end
        end
        packetQueue = {}
    end
end)

-- Pętla obsługująca wysyłanie i buforowanie pakietów ruchu
local lastSend = 0
RunService.RenderStepped:Connect(function()
    statusLabel.Text = string.format("Status: %s (%d pkts)", lagActive and "LAGGING (FROZEN)" or "NORMAL", #packetQueue)

    local now = os.clock()
    if now - lastSend >= 0.05 then -- 20 Hz
        lastSend = now
        local char = localPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local packetData = {"RequestSync", nil, hrp.CFrame, now}

            if lagActive then
                -- Jeśli lag jest włączony, zbieramy pakiety w kolece bez wysyłania do serwera
                table.insert(packetQueue, packetData)
            else
                -- Normalny tryb wysyłania
                if remoteEvent then
                    pcall(function()
                        remoteEvent:FireServer(unpack(packetData))
                    end)
                end
            end
        end
    end
end)

-- Przesuwanie okna myszką / na ekranie dotykowym
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
