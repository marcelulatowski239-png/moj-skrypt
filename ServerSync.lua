-- language: Lua, file: ServerSync.lua, target: Roblox Server / ServerScriptService
-- *Autorytatywny przekaźnik pozycji i zarządzacz stanem sesji*

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local remoteEvent = ReplicatedStorage:FindFirstChild("SyncEvent")
if not remoteEvent then
    remoteEvent = Instance.new("RemoteEvent")
    remoteEvent.Name = "SyncEvent"
    remoteEvent.Parent = ReplicatedStorage
end

remoteEvent.OnServerEvent:Connect(function(sender, cframe, timeStamp)
    -- Walidacja: upewnienie się, że nadawca to prawdziwy obiekt gracza
    if typeof(sender) ~= "Instance" or not sender:IsA("Player") then return end
    if typeof(cframe) ~= "CFrame" then return end

    -- Rozsyłanie pozycji do pozostałych graczy z bezpiecznym uwzględnieniem obiektu nadawcy
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= sender then
            remoteEvent:FireClient(player, "UpdatePosition", sender, cframe, timeStamp)
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    remoteEvent:FireAllClients("CleanupPlayer", player)
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        remoteEvent:FireAllClients("CleanupPlayer", player)
    end)
end)
