-- language: Lua, file: packet_lagger.lua, target: Roblox Executor / GHOST Hub
-- *ZIVA / GHOST Packet Lagger - Pełna synchronizacja bufora sieciowego*

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local remoteEvent = ReplicatedStorage:FindFirstChild("SyncEvent") or ReplicatedStorage:FindFirstChild("RemoteEvent")

-- Konfiguracja laggera wzorowana na filmie
local LaggerState = {
    Active = false,
    PingMs = 22000, -- Czas buforowania w ms (np. 22s tak jak na nagraniu)
    Keybind = Enum.KeyCode.E,
    MaxPackets = 2000
}

local packetQueue = {}

-- Tworzenie mini panelu statusu na ekranie (ZIVA STYLE)
local gui = localPlayer:WaitForChild("PlayerGui")
local oldGui = gui:FindFirstChild("ZivaPacketLaggerGui")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZivaPacketLaggerGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = gui

local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.fromOffset(200, 46)
statusFrame.Position = UDim2.new(0, 20, 0.5, -23)
statusFrame.BackgroundColor3 = Color3.fromRGB(15, 13, 22)
statusFrame.BackgroundTransparency = 0.1
statusFrame.Parent = screenGui
Instance.new("UICorner", statusFrame).CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", statusFrame)
stroke.Color = Color3.fromRGB(140, 50, 255)
stroke.Thickness = 2

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 1, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "ZIVA LAG: OFF [E]"
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 13
statusLabel.Parent = statusFrame

-- Główna funkcja włączania / wyłączania laggera
local function toggleLagger(newState)
    LaggerState.Active = newState
    
    if LaggerState.Active then
        statusLabel.Text = "ZIVA LAG: ACTIVE [" .. LaggerState.Keybind.Name .. "]"
        statusLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
    else
        statusLabel.Text = "ZIVA LAG: OFF [" .. LaggerState.Keybind.Name .. "]"
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        
        -- FLUSH: Natychmiastowe wysłanie wszystkich zaległych pakietów po wyłączeniu (efekt "teleportu" u przeciwnika)
        if remoteEvent and #packetQueue > 0 then
            task.spawn(function()
                for _, pkt in ipairs(packetQueue) do
                    pcall(function()
                        remoteEvent:FireServer(unpack(pkt))
                    end)
                end
                packetQueue = {}
            end)
        else
            packetQueue = {}
        end
    end
end

-- Pętla przechwytująca i buforująca pozycję / pakiety
RunService.RenderStepped:Connect(function()
    local char = localPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or not remoteEvent then return end

    local packetData = {"RequestSync", nil, hrp.CFrame, os.clock()}

    if LaggerState.Active then
        table.insert(packetQueue, packetData)
        -- Ograniczenie bufora, żeby executor nie zużył za dużo pamięci RAM
        if #packetQueue > LaggerState.MaxPackets then
            table.remove(packetQueue, 1)
        end
    else
        pcall(function()
            remoteEvent:FireServer(unpack(packetData))
        end)
    end
end)

-- Nasłuch klawisza aktywacji (domyślnie E)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == LaggerState.Keybind then
        toggleLagger(not LaggerState.Active)
    end
end)
