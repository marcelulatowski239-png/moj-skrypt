-- language: Lua, file: ghost_packet_lagger.lua, target: Roblox Executor / GHOST Hub
-- *GHOST Packet Lagger Widget - Exact replication of client sync mechanism with Ziva/Ghost UI*

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local remoteEvent = ReplicatedStorage:FindFirstChild("SyncEvent") or ReplicatedStorage:FindFirstChild("RemoteEvent")

-- Purge stale instances
local playerGui = localPlayer:WaitForChild("PlayerGui")
for _, name in ipairs({"GhostPacketLaggerGui", "ZivaPacketLaggerGui", "GhostHubGui", "AdaptHubGui", "CursedHubLagger"}) do
    local old = playerGui:FindFirstChild(name)
    if old then old:Destroy() end
end

local LaggerState = {
    Active = false,
    Power = 10000,
    Keybind = Enum.KeyCode.G,
    MaxPackets = 30000
}

local packetQueue = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GhostPacketLaggerGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.fromOffset(300, 310)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -155)
mainFrame.BackgroundColor3 = Color3.fromRGB(85, 37, 150)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(130, 60, 220)
stroke.Thickness = 2
stroke.Transparency = 0.2

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -30, 0, 35)
titleLabel.Position = UDim2.new(0, 16, 0, 14)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "GHOST PACKET LAGGER"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

local powerTitle = Instance.new("TextLabel")
powerTitle.Size = UDim2.new(1, -30, 0, 20)
powerTitle.Position = UDim2.new(0, 16, 0, 52)
powerTitle.BackgroundTransparency = 1
powerTitle.Text = "power"
powerTitle.TextColor3 = Color3.fromRGB(210, 190, 240)
powerTitle.Font = Enum.Font.GothamMedium
powerTitle.TextSize = 13
powerTitle.TextXAlignment = Enum.TextXAlignment.Left
powerTitle.Parent = mainFrame

local powerBox = Instance.new("TextBox")
powerBox.Size = UDim2.fromOffset(210, 42)
powerBox.Position = UDim2.new(0, 16, 0, 76)
powerBox.BackgroundColor3 = Color3.fromRGB(28, 20, 50)
powerBox.TextColor3 = Color3.fromRGB(255, 255, 255)
powerBox.Font = Enum.Font.GothamBold
powerBox.TextSize = 16
powerBox.Text = tostring(LaggerState.Power)
powerBox.Parent = mainFrame
Instance.new("UICorner", powerBox).CornerRadius = UDim.new(0, 8)

local minusBtn = Instance.new("TextButton")
minusBtn.Size = UDim2.fromOffset(32, 20)
minusBtn.Position = UDim2.new(0, 236, 0, 76)
minusBtn.BackgroundColor3 = Color3.fromRGB(65, 30, 115)
minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minusBtn.Font = Enum.Font.GothamBold
minusBtn.TextSize = 16
minusBtn.Text = "-"
minusBtn.Parent = mainFrame
Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 6)

local plusBtn = Instance.new("TextButton")
plusBtn.Size = UDim2.fromOffset(32, 20)
plusBtn.Position = UDim2.new(0, 236, 0, 98)
plusBtn.BackgroundColor3 = Color3.fromRGB(65, 30, 115)
plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
plusBtn.Font = Enum.Font.GothamBold
plusBtn.TextSize = 16
plusBtn.Text = "+"
plusBtn.Parent = mainFrame
Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 6)

minusBtn.MouseButton1Click:Connect(function()
    LaggerState.Power = math.max(1000, LaggerState.Power - 1000)
    powerBox.Text = tostring(LaggerState.Power)
end)

plusBtn.MouseButton1Click:Connect(function()
    LaggerState.Power = math.min(50000, LaggerState.Power + 1000)
    powerBox.Text = tostring(LaggerState.Power)
end)

powerBox.FocusLost:Connect(function()
    local val = tonumber(powerBox.Text)
    if val then LaggerState.Power = val else powerBox.Text = tostring(LaggerState.Power) end
end)

local keybindTitle = Instance.new("TextLabel")
keybindTitle.Size = UDim2.new(1, -30, 0, 20)
keybindTitle.Position = UDim2.new(0, 16, 0, 132)
keybindTitle.BackgroundTransparency = 1
keybindTitle.Text = "keybind"
keybindTitle.TextColor3 = Color3.fromRGB(210, 190, 240)
keybindTitle.Font = Enum.Font.GothamMedium
keybindTitle.TextSize = 13
keybindTitle.TextXAlignment = Enum.TextXAlignment.Left
keybindTitle.Parent = mainFrame

local keybindBtn = Instance.new("TextButton")
keybindBtn.Size = UDim2.fromOffset(268, 42)
keybindBtn.Position = UDim2.new(0, 16, 0, 156)
keybindBtn.BackgroundColor3 = Color3.fromRGB(28, 20, 50)
keybindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
keybindBtn.Font = Enum.Font.GothamBold
keybindBtn.TextSize = 16
keybindBtn.Text = LaggerState.Keybind.Name
keybindBtn.Parent = mainFrame
Instance.new("UICorner", keybindBtn).CornerRadius = UDim.new(0, 8)

local listening = false
keybindBtn.MouseButton1Click:Connect(function()
    listening = true
    keybindBtn.Text = "..."
end)

UserInputService.InputBegan:Connect(function(input)
    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
        listening = false
        LaggerState.Keybind = input.KeyCode
        keybindBtn.Text = LaggerState.Keybind.Name
    end
end)

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.fromOffset(268, 52)
toggleBtn.Position = UDim2.new(0, 16, 0, 222)
toggleBtn.BackgroundColor3 = Color3.fromRGB(130, 95, 210)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.Text = "Wyłączone"
toggleBtn.Parent = mainFrame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 10)

local function setLaggerState(active)
    LaggerState.Active = active
    if active then
        toggleBtn.Text = "Włączone"
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 220, 120)}):Play()
    else
        toggleBtn.Text = "Wyłączone"
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(130, 95, 210)}):Play()
        
        if remoteEvent and #packetQueue > 0 then
            task.spawn(function()
                for _, pkt in ipairs(packetQueue) do
                    pcall(function() remoteEvent:FireServer(unpack(pkt)) end)
                end
                packetQueue = {}
            end)
        else
            packetQueue = {}
        end
    end
end

toggleBtn.MouseButton1Click:Connect(function()
    setLaggerState(not LaggerState.Active)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == LaggerState.Keybind then
        setLaggerState(not LaggerState.Active)
    end
end)

RunService.RenderStepped:Connect(function()
    local char = localPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or not remoteEvent then return end

    local packetData = {"RequestSync", nil, hrp.CFrame, os.clock()}

    if LaggerState.Active then
        table.insert(packetQueue, packetData)
        if #packetQueue > LaggerState.Power then
            table.remove(packetQueue, 1)
        end
    else
        pcall(function() remoteEvent:FireServer(unpack(packetData)) end)
    end
end)
