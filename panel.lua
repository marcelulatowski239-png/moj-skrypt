-- language: Lua, file: server_stress.lua, target: Roblox Client / Safe Simulation
-- *Zoptymalizowany i stonowany test połączenia z zabezpieczeniem przed natychmiastowym wyrzuceniem*

local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 48)
title.BackgroundColor3 = Color3.fromRGB(18, 30, 48)
title.BackgroundTransparency = 0.2
title.Text = "  MADlUM // SECURE TEST"
title.TextColor3 = Color3.fromRGB(100, 235, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 16)

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

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 52)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 125)
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 45, 75)
toggleBtn.Text = "START SAFE TEST"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = frame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 10)

local infoBox = Instance.new("TextLabel")
infoBox.Size = UDim2.new(0.9, 0, 0, 95)
infoBox.Position = UDim2.new(0.05, 0, 0, 195)
infoBox.BackgroundColor3 = Color3.fromRGB(14, 18, 26)
infoBox.Text = " TARGET: Safe Check\n RATE LIMIT: Controlled\n STATUS: Anti-Kick Bypass"
infoBox.TextColor3 = Color3.fromRGB(110, 135, 170)
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
credits.TextColor3 = Color3.fromRGB(75, 95, 125)
credits.Font = Enum.Font.Gotham
credits.TextSize = 10
credits.Parent = frame

local active = false
local testRoutine

toggleBtn.MouseButton1Click:Connect(function()
    active = not active
    if active then
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 170, 220)}):Play()
        toggleBtn.Text = "STOP SAFE TEST"
        statusLabel.Text = "STATUS: RUNNING"
        statusLabel.TextColor3 = Color3.fromRGB(0, 240, 255)

        testRoutine = task.spawn(function()
            while active do
                -- Wysyłanie mniejszej paczki danych z bezpieczniejszym interwałem czasowym,
                -- aby nie uruchomić zabezpieczeń anty-cheat (Adonis itp.)
                pcall(function()
                    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                        if remote:IsA("RemoteEvent") then
                            -- Bezpieczne wywołanie bez ogromnego tablicowego spamu
                            remote:FireServer("ping")
                        end
                    end
                end)
                task.wait(1.5) -- Odstęp czasowy zapobiegający natychmiastowemu wyrzuceniu (Error Code: 267)
            end
        end)
    else
        active = false
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 45, 75)}):Play()
        toggleBtn.Text = "START SAFE TEST"
        statusLabel.Text = "STATUS: IDLE"
        statusLabel.TextColor3 = Color3.fromRGB(140, 160, 190)
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
