-- language: Lua, file: packet_lagger.lua, target: LÖVE2D / Lua Framework
-- Fixed Mouse Handling, Sliders, Hitboxes, and Live Telemetry

local PacketLagger = {}
PacketLagger.__index = PacketLagger

function PacketLagger.new()
    local self = setmetatable({}, PacketLagger)
    
    -- Status i konfiguracja
    self.active = false
    self.elapsed_time = 0
    
    -- Wartości suwaków
    self.delay_setting = 0      -- 0 - 1000 ms
    self.loss_setting = 0       -- 0 - 100 %
    self.duration_setting = 0   -- 0 - 60 s (0 = infinite)
    
    -- Statystyki na żywo
    self.current_ping = 25
    self.current_fps = 60
    self.actual_loss_pct = 0
    self.status_text = "IDLE"
    
    -- Liczniki pakietów
    self.total_packets = 0
    self.lost_packets = 0
    self.sample_timer = 0
    
    -- Historia wykresu
    self.ping_history = {}
    for i = 1, 50 do table.insert(self.ping_history, 25) end
    
    -- Blokada podwójnego kliknięcia
    self.clicked = false
    
    return self
end

function PacketLagger:start()
    self.active = true
    self.elapsed_time = 0
    self.total_packets = 0
    self.lost_packets = 0
    self.status_text = "ACTIVE"
end

function PacketLagger:stop()
    self.active = false
    self.status_text = "STOPPED"
end

function PacketLagger:reset()
    self:stop()
    self.delay_setting = 0
    self.loss_setting = 0
    self.duration_setting = 0
    self.elapsed_time = 0
    self.current_ping = 25
    self.current_fps = 60
    self.actual_loss_pct = 0
    self.total_packets = 0
    self.lost_packets = 0
    self.status_text = "IDLE"
    for i = 1, 50 do self.ping_history[i] = 25 end
end

function PacketLagger:update(dt)
    if love and love.timer then
        self.current_fps = love.timer.getFPS()
    else
        self.current_fps = math.floor(1 / math.max(dt, 0.001))
    end
    
    if not self.active then return end

    if self.duration_setting > 0 then
        self.elapsed_time = self.elapsed_time + dt
        if self.elapsed_time >= self.duration_setting then
            self:stop()
            self.status_text = "FINISHED"
            return
        end
    end

    self.sample_timer = self.sample_timer + dt
    if self.sample_timer >= 0.1 then
        self.sample_timer = 0
        self.total_packets = self.total_packets + 1
        
        local is_lost = (math.random(1, 100) <= self.loss_setting)
        if is_lost then
            self.lost_packets = self.lost_packets + 1
        end
        
        if self.total_packets > 0 then
            self.actual_loss_pct = math.floor((self.lost_packets / self.total_packets) * 100)
        end
        
        local base_ping = 20
        local jitter = math.random(-4, 4)
        if is_lost then
            self.current_ping = 999
        else
            self.current_ping = math.max(5, math.floor(base_ping + self.delay_setting + jitter))
        end
        
        table.remove(self.ping_history, 1)
        table.insert(self.ping_history, self.current_ping)
    end
end

function PacketLagger:draw(x, y)
    x = x or 20
    y = y or 20
    
    love.graphics.push()
    love.graphics.translate(x, y)
    
    -- Tło panelu
    love.graphics.setColor(0.08, 0.08, 0.1, 0.95)
    love.graphics.rectangle("fill", 0, 0, 420, 520, 8, 8)
    
    love.graphics.setColor(0, 1, 0.8, 1)
    love.graphics.rectangle("line", 0, 0, 420, 520, 8, 8)
    
    -- Nagłówek
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.print("PACKET LAGGER // MADlUM", 20, 15)
    
    -- HUD Statystyk
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.setColor(0.15, 0.15, 0.2, 1)
    love.graphics.rectangle("fill", 20, 45, 380, 55, 4, 4)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(string.format("Ping: %d ms", self.current_ping), 30, 52)
    love.graphics.print(string.format("FPS: %d", self.current_fps), 160, 52)
    love.graphics.print(string.format("Loss: %d%%", self.actual_loss_pct), 270, 52)
    
    local status_color = (self.status_text == "ACTIVE") and {1, 0.2, 0.2} or {0.5, 0.5, 0.5}
    love.graphics.setColor(status_color)
    love.graphics.print("Status: " .. self.status_text, 30, 75)
    
    if self.duration_setting > 0 and self.active then
        love.graphics.setColor(1, 0.8, 0)
        love.graphics.print(string.format("Time: %.1fs / %ds", self.elapsed_time, self.duration_setting), 270, 75)
    end
    
    -- Suwaki
    self:draw_slider("Delay (Opóźnienie): " .. self.delay_setting .. " ms", 20, 120, self.delay_setting / 1000)
    self:draw_slider("Packet Loss: " .. self.loss_setting .. " %", 20, 180, self.loss_setting / 100)
    self:draw_slider("Duration: " .. (self.duration_setting > 0 and self.duration_setting .. " s" or "Infinite"), 20, 240, self.duration_setting / 60)
    
    -- Przyciski
    self:draw_button("START", 20, 300, 110, 35, {0.1, 0.6, 0.2}, function() self:start() end)
    self:draw_button("STOP", 155, 300, 110, 35, {0.7, 0.2, 0.2}, function() self:stop() end)
    self:draw_button("RESET", 290, 300, 110, 35, {0.3, 0.3, 0.4}, function() self:reset() end)
    
    -- Wykres na żywo
    love.graphics.setColor(0.12, 0.12, 0.16, 1)
    love.graphics.rectangle("fill", 20, 355, 380, 140, 4, 4)
    love.graphics.setColor(0.3, 0.3, 0.4, 1)
    love.graphics.rectangle("line", 20, 355, 380, 140, 4, 4)
    
    love.graphics.setColor(0, 1, 0.8, 0.8)
    for i = 1, #self.ping_history - 1 do
        local p1 = math.min(self.ping_history[i], 300) / 300 * 120
        local p2 = math.min(self.ping_history[i+1], 300) / 300 * 120
        local x1 = 25 + (i - 1) * (370 / 49)
        local x2 = 25 + i * (370 / 49)
        love.graphics.line(x1, 485 - p1, x2, 485 - p2)
    end
    
    love.graphics.pop()
end

function PacketLagger:draw_slider(label, x, y, norm_val)
    love.graphics.setColor(0.9, 0.9, 0.9, 1)
    love.graphics.print(label, x, y)
    
    love.graphics.setColor(0.2, 0.2, 0.25, 1)
    love.graphics.rectangle("fill", x, y + 20, 380, 10, 5, 5)
    
    love.graphics.setColor(0, 1, 0.8, 1)
    love.graphics.rectangle("fill", x, y + 20, 380 * norm_val, 10, 5, 5)
    love.graphics.circle("fill", x + (380 * norm_val), y + 25, 8)
end

function PacketLagger:draw_button(text, x, y, w, h, color, action)
    local mx, my = love.mouse.getPosition()
    -- Uwzględnienie przesunięcia okna (x=20, y=20) w testach hitboxów myszy
    local local_mx = mx - 20
    local local_my = my - 20
    
    local hover = local_mx >= x and local_mx <= x + w and local_my >= y and local_my <= y + h
    
    love.graphics.setColor(hover and {color[1]*1.2, color[2]*1.2, color[3]*1.2} or color)
    love.graphics.rectangle("fill", x, y, w, h, 4, 4)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(text, x + 15, y + 10)
    
    if hover and love.mouse.isDown(1) and not self.clicked then
        self.clicked = true
        action()
    end
end

function PacketLagger:mousepressed(mx, my, button)
    if button ~= 1 then return end
    
    -- Konwersja globalnych współrzędnych myszy na lokalne względem okna (przesunięcie o 20px)
    local local_mx = mx - 20
    local local_my = my - 20
    
    -- Poprawione strefy kliknięć suwaków wewnątrz panelu
    if local_mx >= 20 and local_mx <= 400 then
        if local_my >= 135 and local_my <= 155 then
            local norm = math.max(0, math.min(1, (local_mx - 20) / 380))
            self.delay_setting = math.floor(norm * 1000)
        elseif local_my >= 195 and local_my <= 215 then
            local norm = math.max(0, math.min(1, (local_mx - 20) / 380))
            self.loss_setting = math.floor(norm * 100)
        elseif local_my >= 255 and local_my <= 275 then
            local norm = math.max(0, math.min(1, (local_mx - 20) / 380))
            self.duration_setting = math.floor(norm * 60)
        end
    end
end

function PacketLagger:mousereleased(button)
    if button == 1 then self.clicked = false end
end

return PacketLagger
