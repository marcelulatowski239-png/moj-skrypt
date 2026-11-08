-- language: Lua, file: ghost_packet_lagger_minimal.lua, target: Roblox Executor / GHOST Hub
-- *GHOST Packet Lagger - Minimalist Dark Cyber / Neon Violet Variant*

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

for _, name in ipairs({"GhostPacketLaggerGui", "ZivaPacketLaggerGui"}) do
    local old = playerGui:FindFirstChild(name)
    if old then old:Destroy() end
end

local LaggerState = {
    Active = false,
    Power = 10000,
    Keybind = Enum.KeyCode.F
}

local buffer = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GhostPacketLaggerGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Nowy, bardziej agresywny i minimalistyczny design (Dark Cyber / Tech)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.fromOffset(280, 270)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -135)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 10, 18)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(160, 50, 255)
stroke.Thickness = 1.5

-- Nagłówek w stylu terminala
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 32)
topBar.BackgroundColor3 = Color3.fromRGB(22, 18, 32)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -16, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "// GHOST.SYS // LAGGER"
titleLabel.TextColor3 = Color3.fromRGB(200, 150, 255)
titleLabel.Font = Enum.Font.Code
titleLabel.TextSize = 13
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

-- Sekcja Power
local powerLabel = Instance.new("TextLabel")
powerLabel.Size = UDim2.new(1, -24, 0, 18)
powerLabel.Position = UDim2.new(0, 12, 0, 48)
powerLabel.BackgroundTransparency = 1
powerLabel.Text = "BUFFER POWER"
powerLabel.TextColor3 = Color3.fromRGB(130, 110, 160)
powerLabel.Font = Enum.Font.Code
powerLabel.TextSize = 11
powerLabel.TextXAlignment = Enum.TextXAlignment.Left
powerLabel.Parent = mainFrame

local powerBox = Instance.new("TextBox")
powerBox.Size = UDim2.fromOffset(190, 36)
powerBox.Position = UDim2.new(0, 12, 0, 70)
powerBox.BackgroundColor3 = Color3.fromRGB(18, 14, 28)
powerBox.TextColor3 = Color3.fromRGB(255, 255, 255)
powerBox.Font = Enum.Font.Code
powerBox.TextSize = 14
powerBox.Text = tostring(LaggerState.Power)
powerBox.Parent = mainFrame
Instance.new("UICorner", powerBox).CornerRadius = UDim.new(0, 6)

local minusBtn = Instance.new("TextButton")
minusBtn.Size = UDim2.fromOffset(30, 36)
minusBtn.Position = UDim2.new(0, 208, 0, 70)
minusBtn.BackgroundColor3 = Color3.fromRGB(35, 25, 55)
minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minusBtn.Font = Enum.Font.Code
minusBtn.TextSize = 14
minusBtn.Text = "-"
minusBtn.Parent = mainFrame
Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 6)

local plusBtn = Instance.new("TextButton")
plusBtn.Size = UDim2.fromOffset(30, 36)
plusBtn.Position = UDim2.new(0, 242, 0, 70)
plusBtn.BackgroundColor3 = Color3.fromRGB(35, 25, 55)
plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
plusBtn.Font = Enum.Font.Code
plusBtn.TextSize = 14
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

-- Sekcja Keybind
local keyLabel = Instance.new("TextLabel")
keyLabel.Size = UDim2.new(1, -24, 0, 18)
keyLabel.Position = UDim2.new(0, 12, 0, 118)
keyLabel.BackgroundTransparency = 1
keyLabel.Text = "TRIGGER KEY"
keyLabel.TextColor3 = Color3.fromRGB(130, 110, 160)
keyLabel.Font = Enum.Font.Code
keyLabel.TextSize = 11
keyLabel.TextXAlignment = Enum.TextXAlignment.Left
keyLabel.Parent = mainFrame

local keybindBtn = Instance.new("TextButton")
keybindBtn.Size = UDim2.fromOffset(256, 36)
keybindBtn.Position = UDim2.new(0, 12, 0, 140)
keybindBtn.BackgroundColor3 = Color3.fromRGB(18, 14, 28)
keybindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
keybindBtn.Font = Enum.Font.Code
keybindBtn.TextSize = 14
keybindBtn.Text = "[" .. LaggerState.Keybind.Name .. "]"
keybindBtn.Parent = mainFrame
Instance.new("UICorner", keybindBtn).CornerRadius = UDim.new(0, 6)

local listening = false
keybindBtn.MouseButton1Click:Connect(function()
    listening = true
    keybindBtn.Text = "[...]"
end)

UserInputService.InputBegan:Connect(function(input)
    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
        listening = false
        LaggerState.Keybind = input.KeyCode
        keybindBtn.Text = "[" .. LaggerState.Keybind.Name .. "]"
    end
end)

-- Przycisk aktywacji (Neon Status)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.fromOffset(256, 44)
toggleBtn.Position = UDim2.new(0, 12, 0, 196)
toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 20, 80)
toggleBtn.TextColor3 = Color3.fromRGB(220, 180, 255)
toggleBtn.Font = Enum.Font.Code
toggleBtn.TextSize = 14
toggleBtn.Text = "STATUS: IDLE"
toggleBtn.Parent = mainFrame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

local function setLaggerState(active)
    LaggerState.Active = active
    if active then
        toggleBtn.Text = "STATUS: ACTIVE"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 20, 200)
        toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        toggleBtn.Text = "STATUS: IDLE"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 20, 80)
        toggleBtn.TextColor3 = Color3.fromRGB(220, 180, 255)
        
        if #buffer > 0 then
            task.spawn(function()
                local char = localPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = buffer[#buffer]
                end
                buffer = {}
            end)
        end
    end
end

toggleBtn.MouseButton1Click:Connect(function()
    setLaggerState(not LaggerState.Active)
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == LaggerState.Keybind then
        setLaggerState(not LaggerState.Active)
    end
end)

RunService.Heartbeat:Connect(function()
    local char = localPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if LaggerState.Active then
        table.insert(buffer, hrp.CFrame)
        if #buffer > LaggerState.Power then
            table.remove(buffer, 1)
        end
    else
        buffer = {}
    end
end)
