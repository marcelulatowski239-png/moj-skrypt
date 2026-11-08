-- GHOST.SYS | panel.lua
-- Local Packet Lag Simulation
-- Roblox Client / LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- CONFIG
local Config = {
    Power = 1000,
    MinPower = 100,
    MaxPower = 5000,
    Step = 100,
    Keybind = Enum.KeyCode.F
}

local State = {
    Active = false,
    Listening = false,
    Buffer = {}
}

-- CLEANUP
local old = PlayerGui:FindFirstChild("GhostPacketLaggerGui")
if old then old:Destroy() end

local oldGhost = workspace:FindFirstChild("GhostLocalMarker")
if oldGhost then oldGhost:Destroy() end

-- GUI
local Gui = Instance.new("ScreenGui")
Gui.Name = "GhostPacketLaggerGui"
Gui.ResetOnSpawn = false
Gui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(290, 265)
Main.Position = UDim2.new(0.5, -145, 0.5, -132)
Main.BackgroundColor3 = Color3.fromRGB(12, 10, 18)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 9)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(160, 50, 255)
Stroke.Thickness = 1.5

local function Label(text, position, size)
    local obj = Instance.new("TextLabel")
    obj.Size = size
    obj.Position = position
    obj.BackgroundTransparency = 1
    obj.Text = text
    obj.TextColor3 = Color3.fromRGB(200, 170, 255)
    obj.Font = Enum.Font.Code
    obj.TextSize = 12
    obj.TextXAlignment = Enum.TextXAlignment.Left
    obj.Parent = Main
    return obj
end

local function Button(text, position, size)
    local obj = Instance.new("TextButton")
    obj.Size = size
    obj.Position = position
    obj.BackgroundColor3 = Color3.fromRGB(35, 25, 55)
    obj.TextColor3 = Color3.fromRGB(255, 255, 255)
    obj.Font = Enum.Font.Code
    obj.TextSize = 14
    obj.Text = text
    obj.Parent = Main
    Instance.new("UICorner", obj).CornerRadius = UDim.new(0, 6)
    return obj
end

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(25, 18, 38)
Header.BorderSizePixel = 0
Header.Parent = Main

Label("// GHOST.SYS // PACKET LAGGER",
    UDim2.fromOffset(12, 0),
    UDim2.new(1, -24, 0, 35))

Label("BUFFER DELAY (MS)",
    UDim2.fromOffset(14, 48),
    UDim2.fromOffset(250, 18))

local PowerBox = Instance.new("TextBox")
PowerBox.Size = UDim2.fromOffset(180, 35)
PowerBox.Position = UDim2.fromOffset(14, 72)
PowerBox.BackgroundColor3 = Color3.fromRGB(22, 17, 32)
PowerBox.TextColor3 = Color3.new(1, 1, 1)
PowerBox.Font = Enum.Font.Code
PowerBox.TextSize = 14
PowerBox.Text = tostring(Config.Power)
PowerBox.Parent = Main

Instance.new("UICorner", PowerBox).CornerRadius = UDim.new(0, 6)

local Minus = Button("-", UDim2.fromOffset(202, 72), UDim2.fromOffset(32, 35))
local Plus = Button("+", UDim2.fromOffset(240, 72), UDim2.fromOffset(32, 35))

local KeyLabel = Label("TRIGGER KEY",
    UDim2.fromOffset(14, 116),
    UDim2.fromOffset(250, 18))

local KeyButton = Button("[F]",
    UDim2.fromOffset(14, 138),
    UDim2.fromOffset(258, 35))

local Toggle = Button("STATUS: IDLE",
    UDim2.fromOffset(14, 188),
    UDim2.fromOffset(258, 42))

local Info = Label("GHOST BUFFER: 0",
    UDim2.fromOffset(14, 238),
    UDim2.fromOffset(260, 18))

-- LOCAL GHOST MARKER
local Ghost = Instance.new("Part")
Ghost.Name = "GhostLocalMarker"
Ghost.Size = Vector3.new(2, 3, 1)
Ghost.Anchored = true
Ghost.CanCollide = false
Ghost.CanTouch = false
Ghost.CanQuery = false
Ghost.Material = Enum.Material.Neon
Ghost.Color = Color3.fromRGB(170, 50, 255)
Ghost.Transparency = 0.55
Ghost.Parent = workspace

local function UpdatePower(value)
    Config.Power = math.clamp(
        math.floor(value),
        Config.MinPower,
        Config.MaxPower
    )

    PowerBox.Text = tostring(Config.Power)
end

Minus.MouseButton1Click:Connect(function()
    UpdatePower(Config.Power - Config.Step)
end)

Plus.MouseButton1Click:Connect(function()
    UpdatePower(Config.Power + Config.Step)
end)

PowerBox.FocusLost:Connect(function()
    local value = tonumber(PowerBox.Text)

    if value then
        UpdatePower(value)
    else
        PowerBox.Text = tostring(Config.Power)
    end
end)

-- KEYBIND
KeyButton.MouseButton1Click:Connect(function()
    State.Listening = true
    KeyButton.Text = "[PRESS KEY]"
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if State.Listening and input.UserInputType == Enum.UserInputType.Keyboard then
        Config.Keybind = input.KeyCode
        State.Listening = false
        KeyButton.Text = "[" .. input.KeyCode.Name .. "]"
        return
    end

    if processed then return end

    if input.KeyCode == Config.Keybind then
        State.Active = not State.Active
    end
end)

-- TOGGLE
Toggle.MouseButton1Click:Connect(function()
    State.Active = not State.Active
end)

local function GetDelayedPosition()
    local targetTime = os.clock() - Config.Power / 1000

    for i = #State.Buffer, 1, -1 do
        local entry = State.Buffer[i]

        if entry.Time <= targetTime then
            return entry.CFrame
        end
    end

    return nil
end

-- BUFFER ENGINE
RunService.Heartbeat:Connect(function()
    local character = Player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not root then
        Ghost.Transparency = 1
        return
    end

    if State.Active then
        table.insert(State.Buffer, {
            Time = os.clock(),
            CFrame = root.CFrame
        })

        local cutoff = os.clock() - 6

        while #State.Buffer > 0 and State.Buffer[1].Time < cutoff do
            table.remove(State.Buffer, 1)
        end

        local delayed = GetDelayedPosition()

        if delayed then
            Ghost.CFrame = delayed
            Ghost.Transparency = 0.55
        else
            Ghost.Transparency = 1
        end

        Info.Text = "GHOST BUFFER: " .. #State.Buffer
    else
        table.clear(State.Buffer)
        Ghost.Transparency = 1
        Info.Text = "GHOST BUFFER: 0"
    end

    if State.Active then
        Toggle.Text = "STATUS: ACTIVE"
        Toggle.BackgroundColor3 = Color3.fromRGB(110, 25, 180)
    else
        Toggle.Text = "STATUS: IDLE"
        Toggle.BackgroundColor3 = Color3.fromRGB(35, 25, 55)
    end
end)

-- CLEANUP
Gui.Destroying:Connect(function()
    Ghost:Destroy()
end)
