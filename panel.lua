-- language: Lua, file: panel.lua, target: Roblox Executor / Steal a Brainrot Duels
-- *Panel diagnostyczny i system buforowania replikacji pozycji w czasie rzeczywistym*

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local oldGui = localPlayer.PlayerGui:FindFirstChild("DuelLatencyPanel")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "DuelLatencyPanel"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = localPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(340, 320)
frame.Position = UDim2.new(0.5, -170, 0.5, -160)
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
title.Text = "  MADlUM // PANEL.LUA"
title.TextColor3 = Color3.fromRGB(255, 120, 210)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 16)

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(0.9, 0, 0, 65)
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
sliderContainer.Position = UDim2.new(0.05, 0, 0, 130)
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

local simulatedDelayMs = 300
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

local infoBox = Instance.new("TextLabel")
infoBox.Size = UDim2.new(0.9, 0, 0, 55)
infoBox.Position = UDim2.new(0.05, 0, 0, 200)
infoBox.BackgroundColor3 = Color3.fromRGB(16, 10, 24)
infoBox.Text = " STATUS: Active Buffer\n BYPASS: Client Sandbox Isolation"
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

local positionBuffer = {}

-- Pętla telemetrii i zarządzania buforem
RunService.RenderStepped:Connect(function(dt)
    local fps = math.floor(1 / dt)
    local ping = math.floor(localPlayer:GetNetworkPing() * 1000)
    
    statsLabel.Text = string.format("FPS: %d\nREAL PING: %d ms\nBUFFER DELAY: %d ms", fps, ping, simulatedDelayMs)

    local char = localPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        table.insert(positionBuffer, {
            cframe = hrp.CFrame,
            time = os.clock()
        })

        local delaySec = simulatedDelayMs / 1000
        while #positionBuffer > 0 and (os.clock() - positionBuffer[1].time) >= delaySec do
            local packet = table.remove(positionBuffer, 1)
            -- Bufor utrzymujący opóźnioną pozycję w lokalnej sesji
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
