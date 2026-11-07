-- language: Lua, file: panel.lua, target: Roblox Executor / Steal a Brainrot Duels
-- *Panel diagnostyczny i system buforowania replikacji pozycji dla symulacji pingu*

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer

local remoteEvent = ReplicatedStorage:WaitForChild("SyncEvent", 5)
if not remoteEvent then
    warn("[-] SyncEvent not found in ReplicatedStorage!")
end

local simulatedDelayMs = 300
local testActive = true
local positionBuffers = {}

local oldGui = localPlayer.PlayerGui:FindFirstChild("DuelLatencyPanel")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "DuelLatencyPanel"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = localPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(360, 380)
frame.Position = UDim2.new(0.5, -180, 0.5, -190)
frame.BackgroundColor3 = Color3.fromRGB(15, 12, 25)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
frame.Active = true
frame.ClipsDescendants = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(255, 0, 128)
stroke.Thickness = 2
stroke.Transparency = 0.15

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = Color3.fromRGB(50, 15, 65)
title.BackgroundTransparency = 0.3
title.Text = "  MADlUM // PING LAGGER PANEL"
title.TextColor3 = Color3.fromRGB(255, 120, 210)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 16)

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(0.9, 0, 0, 70)
statsLabel.Position = UDim2.new(0.05, 0, 0, 55)
statsLabel.BackgroundColor3 = Color3.fromRGB(22, 14, 35)
statsLabel.TextColor3 = Color3.fromRGB(200, 180, 220)
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
sliderContainer.BackgroundColor3 = Color3.fromRGB(22, 14, 35)
sliderContainer.Parent = frame
Instance.new("UICorner", sliderContainer).CornerRadius = UDim.new(0, 10)

local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(1, -20, 0, 25)
sliderLabel.Position = UDim2.new(0, 10, 0, 5)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "Buffer Delay: 300 ms"
sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
sliderLabel.Font = Enum.Font.GothamBold
sliderLabel.TextSize = 12
sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
sliderLabel.Parent = sliderContainer

local track = Instance.new("Frame")
track.Size = UDim2.new(1, -20, 0, 6)
track.Position = UDim2.new(0, 10, 0, 38)
track.BackgroundColor3 = Color3.fromRGB(45, 20, 60)
track.BorderSizePixel = 0
track.Parent = sliderContainer
Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

local fill = Instance.new("Frame")
fill.Size = UDim2.new((simulatedDelayMs - 100) / 900, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(255, 0, 128)
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
        simulatedDelayMs = math.floor(100 + pos * 900)
        sliderLabel.Text = string.format("Buffer Delay: %d ms", simulatedDelayMs)
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

local startBtn = createButton("START", Color3.fromRGB(0, 180, 90), 0)
local stopBtn = createButton("STOP", Color3.fromRGB(180, 50, 50), 0.345)
local resetBtn = createButton("RESET", Color3.fromRGB(70, 70, 100), 0.69)

startBtn.MouseButton1Click:Connect(function() testActive = true end)
stopBtn.MouseButton1Click:Connect(function() testActive = false end)
resetBtn.MouseButton1Click:Connect(function() 
    simulatedDelayMs = 300
    fill.Size = UDim2.new((300 - 100) / 900, 0, 1, 0)
    sliderLabel.Text = "Buffer Delay: 300 ms"
    testActive = true
    positionBuffers = {}
end)

local infoBox = Instance.new("TextLabel")
infoBox.Size = UDim2.new(0.9, 0, 0, 55)
infoBox.Position = UDim2.new(0.05, 0, 0, 255)
infoBox.BackgroundColor3 = Color3.fromRGB(16, 10, 24)
infoBox.Text = " STATUS: Running\n TARGET: Server-Synced Buffer"
infoBox.TextColor3 = Color3.fromRGB(150, 130, 190)
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
credits.TextColor3 = Color3.fromRGB(90, 70, 120)
credits.Font = Enum.Font.Gotham
credits.TextSize = 10
credits.Parent = frame

if remoteEvent then
    remoteEvent.OnClientEvent:Connect(function(action, targetPlayer, cframe, timeStamp)
        if action == "CleanupPlayer" then
            if positionBuffers[targetPlayer] then
                positionBuffers[targetPlayer] = nil
            end
            return
        end

        if action == "UpdatePosition" and targetPlayer and targetPlayer ~= localPlayer then
            if not positionBuffers[targetPlayer] then
                positionBuffers[targetPlayer] = {}
            end
            table.insert(positionBuffers[targetPlayer], {
                cframe = cframe,
                time = os.clock()
            })
        end
    end)
end

local lastSend = 0
RunService.RenderStepped:Connect(function(dt)
    local fps = math.floor(1 / dt)
    local ping = math.floor(localPlayer:GetNetworkPing() * 1000)
    
    statsLabel.Text = string.format("FPS: %d | PING: %d ms\nDELAY: %d ms | STATUS: %s", 
        fps, ping, simulatedDelayMs, testActive and "ACTIVE" or "PAUSED")

    local now = os.clock()

    if testActive and remoteEvent and (now - lastSend >= 0.05) then
        lastSend = now
        local char = localPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                remoteEvent:FireServer("RequestSync", nil, char.HumanoidRootPart.CFrame, now)
            end)
        end
    end

    if testActive then
        local delaySec = simulatedDelayMs / 1000
        for player, buffer in pairs(positionBuffers) do
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                while #buffer > 0 and (now - buffer[1].time) >= delaySec do
                    local pastData = table.remove(buffer, 1)
                    char.HumanoidRootPart.CFrame = pastData.cframe
                end
            end
        end
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
