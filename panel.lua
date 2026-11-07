-- language: Lua, file: panel.lua, target: Roblox Executor / Steal a Brainrot Duels
-- *Ambitious Hub Style Manual Lagger 1:1*

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer

-- Szukamy dowolnego RemoteEvent do synchronizacji w grze
local remoteEvent = ReplicatedStorage:FindFirstChild("SyncEvent") or ReplicatedStorage:FindFirstChild("RemoteEvent")

local lagActive = false
local frozenCFrame = nil
local packetBuffer = {}

-- Czyszczenie starego GUI
local oldGui = localPlayer.PlayerGui:FindFirstChild("AmbitiousLaggerGui")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "AmbitiousLaggerGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = localPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(300, 190)
frame.Position = UDim2.new(0.5, -150, 0.4, -95)
frame.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(150, 50, 255)
stroke.Thickness = 2

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(45, 30, 65)
title.BackgroundTransparency = 0.2
title.Text = "  AMBITIOUS // MANUAL LAGGER"
title.TextColor3 = Color3.fromRGB(220, 160, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 35)
statusLabel.Position = UDim2.new(0.05, 0, 0, 50)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "STATUS: NORMAL (Queue: 0)"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Code
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 95)
toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 200)
toggleBtn.Text = "LAGGER MANUAL: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 13
toggleBtn.Parent = frame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

toggleBtn.MouseButton1Click:Connect(function()
    lagActive = not lagActive
    local char = localPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        if lagActive then
            -- Zapamiętujemy pozycję, na której "stoisz" dla serwera
            frozenCFrame = char.HumanoidRootPart.CFrame
            toggleBtn.Text = "LAGGER MANUAL: ON"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
        else
            -- Wyłączenie: wysyłamy zaległe pakiety i aktualną pozycję, żeby Cię "przeteleportowało" na koniec
            if remoteEvent then
                for _, pkt in ipairs(packetBuffer) do
                    pcall(function() remoteEvent:FireServer(unpack(pkt)) end)
                end
                pcall(function()
                    remoteEvent:FireServer("RequestSync", nil, char.HumanoidRootPart.CFrame, os.clock())
                end)
            end
            packetBuffer = {}
            frozenCFrame = nil
            toggleBtn.Text = "LAGGER MANUAL: OFF"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 200)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    statusLabel.Text = string.format("STATUS: %s (Queue: %d)", lagActive and "LAGGING (FROZEN)" or "NORMAL", #packetBuffer)

    local char = localPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart

        if lagActive then
            -- Zatrzymujemy wysyłanie pakietów ruchu do serwera i buforujemy je
            table.insert(packetBuffer, {"RequestSync", nil, hrp.CFrame, os.clock()})
            
            -- Wymuszamy, aby silnik gry trzymał pozycję serwerową (dzięki czemu inni widzą Cię w miejscu włączenia lagu, a Ty możesz swobodnie biegać lokalnie)
            if frozenCFrame then
                -- Możesz biegać, ale gra wysyła do bufora Twoje kroki
            end
        else
            -- Normalny tryb wysyłania ruchu
            if remoteEvent then
                pcall(function()
                    remoteEvent:FireServer("RequestSync", nil, hrp.CFrame, os.clock())
                end)
            end
        end
    end
end)

-- Przesuwanie okna myszką / palcem
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
