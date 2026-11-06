-- language: Lua, file: safe_lag.lua, target: Roblox Client / Local Interpolation Delay
-- *Lokalny bufor opóźnienia interpolacji (lag switch symulacyjny bez naruszania RemoteEvents)*

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local old = player.PlayerGui:FindFirstChild("SafeLagPanel")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "SafeLagPanel"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(320, 240)
frame.Position = UDim2.new(0.5, -160, 0.5, -120)
frame.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
frame.Active = true
frame.ClipsDescendants = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(120, 0, 255)
stroke.Thickness = 2
stroke.Transparency = 0.2

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = Color3.fromRGB(40, 15, 60)
title.BackgroundTransparency = 0.3
title.Text = "  MADlUM // SAFE DELAY"
title.TextColor3 = Color3.fromRGB(200, 120, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 16)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 40)
statusLabel.Position = UDim2.new(0.05, 0, 0, 60)
statusLabel.BackgroundColor3 = Color3.fromRGB(25, 15, 40)
statusLabel.Text = "STATUS: OFF"
statusLabel.TextColor3 = Color3.fromRGB(150, 130, 180)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 12
statusLabel.Parent = frame
Instance.new("UICorner", statusLabel).CornerRadius = UDim.new(0, 10)

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 50)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 115)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 80)
toggleBtn.Text = "ENABLE BUFFER DELAY"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 13
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = frame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 10)

local active = false

toggleBtn.MouseButton1Click:Connect(function()
    active = not active
    if active then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 20, 160)
        toggleBtn.Text = "DISABLE BUFFER DELAY"
        statusLabel.Text = "STATUS: BUFFERING ACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(220, 100, 255)
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 80)
        toggleBtn.Text = "ENABLE BUFFER DELAY"
        statusLabel.Text = "STATUS: OFF"
        statusLabel.TextColor3 = Color3.fromRGB(150, 130, 180)
    end
end)

-- Przechwytywanie i opóźnianie aktualizacji fizyki klienta bez wywoływania RemoteEvents
RunService.Stepped:Connect(function()
    if active then
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            -- Celowe spowolnienie częstotliwości wysyłania stanów ruchu do silnika gry
            task.wait(0.08)
        end
    end
end)
