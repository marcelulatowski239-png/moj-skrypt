-- language: Lua, file: main.lua, target: Roblox Client
-- MADlUM | PANEL LAGGER (Client Freeze Simulation)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- Usuwanie starego GUI, jeśli istnieje
local old = player.PlayerGui:FindFirstChild("LagPanel")
if old then old:Destroy() end

-- Tworzenie GUI
local gui = Instance.new("ScreenGui")
gui.Name = "LagPanel"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(250, 150)
frame.Position = UDim2.new(0.5, -125, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(200, 50, 50)
stroke.Thickness = 2

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "MADlUM | LAG PANEL"
title.TextColor3 = Color3.fromRGB(255, 100, 100)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
toggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
toggleBtn.Text = "ACTIVATE LAG"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.Parent = frame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0.8, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "STATUS: OFF"
statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.Parent = frame

-- Logika lagowania
local enabled = false
local lagConnection

local function toggleLag()
    enabled = not enabled
    if enabled then
        toggleBtn.Text = "STOP LAG"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        statusLabel.Text = "STATUS: LAGGING (FREEZING CLIENT)"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)

        lagConnection = RunService.RenderStepped:Connect(function()
            -- Pętla obciążająca procesor (symulacja zamrożenia)
            local x = 0
            for i = 1, 200000 do
                x = math.sin(i) * math.cos(i) + math.sqrt(i)
            end
            -- Losowe mikrozacięcia
            if math.random(1, 100) > 90 then
                task.wait(0.05)
            end
        end)
    else
        if lagConnection then lagConnection:Disconnect() end
        toggleBtn.Text = "ACTIVATE LAG"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        statusLabel.Text = "STATUS: OFF"
        statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
end

toggleBtn.MouseButton1Click:Connect(toggleLag)
