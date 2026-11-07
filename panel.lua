-- language: Lua, file: panel.lua, target: Roblox Executor / Steal a Brainrot Duels
-- *Cursed Hub Style Ping Lagger*

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

local lagActive = false
local packetQueue = {}

-- Czyszczenie starego GUI
local oldGui = localPlayer.PlayerGui:FindFirstChild("CursedHubLagger")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "CursedHubLagger"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = localPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(280, 180)
frame.Position = UDim2.new(0.3, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(35, 10, 12)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(180, 30, 30)
stroke.Thickness = 2

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(50, 12, 15)
title.BackgroundTransparency = 0.2
title.Text = "  Cursed Hub Ping Lagger"
title.TextColor3 = Color3.fromRGB(255, 120, 120)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 40)
statusLabel.Position = UDim2.new(0.05, 0, 0, 45)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: NORMAL (0 pkts)"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Code
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 95)
toggleBtn.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
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
        toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 160, 60)
    else
        toggleBtn.Text = "ENABLE"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
        -- Wypuszczenie skumulowanych pakietów po wyłączeniu
        if remoteEvent then
            for _, pkt in ipairs(packetQueue) do
                pcall(function() remoteEvent:FireServer(unpack(pkt)) end)
            end
        end
        packetQueue = {}
    end
end)

RunService.RenderStepped:Connect(function()
    statusLabel.Text = string.format("Status: %s (%d pkts)", lagActive ? "FROZEN / LAGGING" : "NORMAL", #packetQueue)

    local char = localPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") and remoteEvent then
        local hrp = char.HumanoidRootPart
        local packetData = {"RequestSync", nil, hrp.CFrame, os.clock()}

        if lagActive then
            table.insert(packetQueue, packetData)
        else
            pcall(function()
                remoteEvent:FireServer(unpack(packetData))
            end)
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
