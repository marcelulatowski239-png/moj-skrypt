-- language: Lua, file: panel.lua, target: Roblox Client / GHOST Hub
-- *GHOST.SYS | Real Network Replication & Packet Lagger Engine*

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- CONFIG
local Config = {
    Power = 10000,
    MinPower = 1000,
    MaxPower = 50000,
    Step = 1000,
    Keybind = Enum.KeyCode.F
}

local State = {
    Active = false,
    Listening = false,
    Queue = {}
}

-- CLEANUP
local old = PlayerGui:FindFirstChild("GhostPacketLaggerGui")
if old then old:Destroy() end

-- GUI
local Gui = Instance.new("ScreenGui")
Gui.Name = "GhostPacketLaggerGui"
Gui.ResetOnSpawn = false
Gui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(300, 315)
Main.Position = UDim2.new(0.5, -150, 0.5, -157)
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

Label("POWER (MAX PACKETS/QUEUE)",
    UDim2.fromOffset(14, 48),
    UDim2.fromOffset(270, 18))

local PowerBox = Instance.new("TextBox")
PowerBox.Size = UDim2.fromOffset(190, 35)
PowerBox.Position = UDim2.fromOffset(14, 72)
PowerBox.BackgroundColor3 = Color3.fromRGB(22, 17, 32)
PowerBox.TextColor3 = Color3.new(1, 1, 1)
PowerBox.Font = Enum.Font.Code
PowerBox.TextSize = 14
PowerBox.Text = tostring(Config.Power)
PowerBox.Parent = Main

Instance.new("UICorner", PowerBox).CornerRadius = UDim.new(0, 6)

local Minus = Button("-", UDim2.fromOffset(212, 72), UDim2.fromOffset(32, 35))
local Plus = Button("+", UDim2.fromOffset(250, 72), UDim2.fromOffset(32, 35))

Label("TRIGGER KEYBIND",
    UDim2.fromOffset(14, 116),
    UDim2.fromOffset(270, 18))

local KeyButton = Button("[F]",
    UDim2.fromOffset(14, 138),
    UDim2.fromOffset(268, 35))

local Toggle = Button("STATUS: IDLE",
    UDim2.fromOffset(14, 183),
    UDim2.fromOffset(128, 38))

local FlushBtn = Button("FLUSH",
    UDim2.fromOffset(154, 183),
    UDim2.fromOffset(128, 38))
FlushBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 120)

local StatsLabel = Label("PING: 0 ms | FPS: 0 | Q: 0",
    UDim2.fromOffset(14, 235),
    UDim2.fromOffset(270, 45))
StatsLabel.TextWrapped = true

local function UpdatePower(value)
    Config.Power = math.clamp(math.floor(value), Config.MinPower, Config.MaxPower)
    PowerBox.Text = tostring(Config.Power)
end

Minus.MouseButton1Click:Connect(function()
    UpdatePower(Config.Power - Config.Step)
end)

Plus.MouseButton1Click:Connect(function()
    UpdatePower(Config.Power + Config.Step)
end)

PowerBox.FocusLost:Connect(function()
    local val = tonumber(PowerBox.Text)
    if val then UpdatePower(val) else PowerBox.Text = tostring(Config.Power) end
end)

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

local function FlushQueue()
    if #State.Queue > 0 then
        task.spawn(function()
            local queueCopy = State.Queue
            State.Queue = {}
            for _, packetData in ipairs(queueCopy) do
                pcall(function()
                    if packetData.Remote and packetData.Remote.Parent then
                        packetData.Remote:FireServer(unpack(packetData.Args))
                    end
                end)
            end
        end)
    end
end

Toggle.MouseButton1Click:Connect(function()
    State.Active = not State.Active
    if not State.Active then
        FlushQueue()
    end
end)

FlushBtn.MouseButton1Click:Connect(function()
    FlushQueue()
end)

-- Metamethod Hook dla FireServer / InvokeServer (Przechwytywanie aktualizacji synchronizacji)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if State.Active and (method == "FireServer" or method == "InvokeServer") then
        -- Sprawdzamy czy to pakiet ruchu/synchronizacji
        table.insert(State.Queue, {
            Remote = self,
            Method = method,
            Args = args
        })

        if #State.Queue > Config.Power then
            table.remove(State.Queue, 1)
        end
        return
    end

    return oldNamecall(self, ...)
end)

-- Pętla monitorująca ping, FPS i stan synchronizacji
local lastTime = os.clock()
local frameCount = 0
local currentFPS = 60

RunService.RenderStepped:Connect(function(dt)
    frameCount = frameCount + 1
    if os.clock() - lastTime >= 1 then
        currentFPS = math.floor(frameCount / (os.clock() - lastTime))
        frameCount = 0
        lastTime = os.clock()
    end

    local pingVal = 0
    pcall(function()
        pingVal = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    end)

    if State.Active then
        Toggle.Text = "STATUS: ACTIVE"
        Toggle.BackgroundColor3 = Color3.fromRGB(110, 25, 180)
    else
        Toggle.Text = "STATUS: IDLE"
        Toggle.BackgroundColor3 = Color3.fromRGB(35, 25, 55)
    end

    StatsLabel.Text = string.format("PING: %d ms | FPS: %d | QUEUE: %d / %d", pingVal, currentFPS, #State.Queue, Config.Power)
end)
