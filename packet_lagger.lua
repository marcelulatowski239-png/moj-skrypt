local PacketLagger = {}
PacketLagger.__index = PacketLagger

local PANEL_W, PANEL_H = 440, 520

local function clamp(v, min, max)
    return math.max(min, math.min(max, v))
end

function PacketLagger.new()
    local self = setmetatable({}, PacketLagger)

    self.active = false
    self.elapsed_time = 0

    self.delay_setting = 0
    self.loss_setting = 0
    self.duration_setting = 0

    self.current_ping = 25
    self.current_fps = 60
    self.actual_loss_pct = 0

    self.total_packets = 0
    self.lost_packets = 0
    self.sample_timer = 0

    self.status_text = "IDLE"
    self.ping_history = {}

    self.dragging_slider = nil
    self.fonts = {}

    for i = 1, 50 do
        self.ping_history[i] = 25
    end

    return self
end

function PacketLagger:start()
    if self.active then return end

    self.active = true
    self.elapsed_time = 0
    self.sample_timer = 0
    self.total_packets = 0
    self.lost_packets = 0
    self.actual_loss_pct = 0
    self.status_text = "ACTIVE"
end

function PacketLagger:stop()
    self.active = false

    if self.status_text ~= "FINISHED" then
        self.status_text = "STOPPED"
    end
end

function PacketLagger:reset()
    self.active = false

    self.delay_setting = 0
    self.loss_setting = 0
    self.duration_setting = 0

    self.elapsed_time = 0
    self.current_ping = 25
    self.actual_loss_pct = 0

    self.total_packets = 0
    self.lost_packets = 0
    self.sample_timer = 0

    self.status_text = "IDLE"

    for i = 1, 50 do
        self.ping_history[i] = 25
    end
end

function PacketLagger:update(dt)
    self.current_fps = love.timer.getFPS()

    if not self.active then return end

    self.elapsed_time = self.elapsed_time + dt

    if self.duration_setting > 0
        and self.elapsed_time >= self.duration_setting then

        self.active = false
        self.status_text = "FINISHED"
        return
    end

    self.sample_timer = self.sample_timer + dt

    if self.sample_timer >= 0.1 then
        self.sample_timer = self.sample_timer - 0.1

        self.total_packets = self.total_packets + 1

        local lost = math.random(1, 100) <= self.loss_setting

        if lost then
            self.lost_packets = self.lost_packets + 1
            self.current_ping = 999
        else
            self.current_ping = math.max(
                5,
                20 + self.delay_setting + math.random(-4, 4)
            )
        end

        self.actual_loss_pct = math.floor(
            self.lost_packets / self.total_packets * 100
        )

        table.remove(self.ping_history, 1)
        table.insert(self.ping_history, self.current_ping)
    end
end

function PacketLagger:draw_slider(label, x, y, value, max_value)
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.print(label, x, y)

    local bar_y = y + 25

    love.graphics.setColor(0.2, 0.2, 0.25)
    love.graphics.rectangle("fill", x, bar_y, 380, 8, 4, 4)

    local ratio = clamp(value / max_value, 0, 1)

    love.graphics.setColor(0, 1, 0.8)
    love.graphics.rectangle("fill", x, bar_y, 380 * ratio, 8, 4, 4)
    love.graphics.circle("fill", x + 380 * ratio, bar_y + 4, 8)
end

function PacketLagger:draw_button(label, x, y, w, h, color)
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x, y, w, h, 5, 5)

    love.graphics.setColor(1, 1, 1)
    local font = love.graphics.getFont()
    local tw = font:getWidth(label)

    love.graphics.print(label, x + (w - tw) / 2, y + 10)
end

function PacketLagger:draw(x, y)
    love.graphics.push()
    love.graphics.translate(x, y)

    love.graphics.setColor(0.08, 0.08, 0.1, 0.98)
    love.graphics.rectangle("fill", 0, 0, PANEL_W, PANEL_H, 8, 8)

    love.graphics.setColor(0, 1, 0.8)
    love.graphics.rectangle("line", 0, 0, PANEL_W, PANEL_H, 8, 8)

    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.print("MADlUM // NETWORK SIMULATOR", 20, 15)

    love.graphics.setFont(love.graphics.newFont(12))

    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", 20, 45, 400, 65, 5, 5)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Ping: " .. self.current_ping .. " ms", 30, 55)
    love.graphics.print("FPS: " .. self.current_fps, 160, 55)
    love.graphics.print("Loss: " .. self.actual_loss_pct .. "%", 270, 55)

    love.graphics.print("Status: " .. self.status_text, 30, 83)

    self:draw_slider(
        "Delay: " .. self.delay_setting .. " ms",
        20, 130, self.delay_setting, 1000
    )

    self:draw_slider(
        "Packet Loss: " .. self.loss_setting .. "%",
        20, 195, self.loss_setting, 100
    )

    self:draw_slider(
        "Duration: " ..
        (self.duration_setting == 0 and "Infinite"
        or self.duration_setting .. " s"),
        20, 260, self.duration_setting, 60
    )

    self:draw_button("START", 20, 320, 110, 35, {0.1, 0.6, 0.2})
    self:draw_button("STOP", 165, 320, 110, 35, {0.7, 0.2, 0.2})
    self:draw_button("RESET", 310, 320, 110, 35, {0.3, 0.3, 0.4})

    love.graphics.setColor(0.12, 0.12, 0.16)
    love.graphics.rectangle("fill", 20, 375, 400, 120, 5, 5)

    love.graphics.setColor(0, 1, 0.8)

    for i = 1, #self.ping_history - 1 do
        local p1 = math.min(self.ping_history[i], 300) / 300 * 100
        local p2 = math.min(self.ping_history[i + 1], 300) / 300 * 100

        local x1 = 25 + (i - 1) * (390 / 49)
        local x2 = 25 + i * (390 / 49)

        love.graphics.line(
            x1, 490 - p1,
            x2, 490 - p2
        )
    end

    love.graphics.pop()
end

function PacketLagger:set_slider_value(mx, id)
    local ratio = clamp((mx - 40) / 380, 0, 1)

    if id == "delay" then
        self.delay_setting = math.floor(ratio * 1000)
    elseif id == "loss" then
        self.loss_setting = math.floor(ratio * 100)
    elseif id == "duration" then
        self.duration_setting = math.floor(ratio * 60)
    end
end

function PacketLagger:mousepressed(mx, my, button)
    if button ~= 1 then return end

    mx = mx - 20
    my = my - 20

    if mx >= 20 and mx <= 400 then
        if my >= 150 and my <= 165 then
            self.dragging_slider = "delay"
            self:set_slider_value(mx, "delay")
            return
        elseif my >= 215 and my <= 230 then
            self.dragging_slider = "loss"
            self:set_slider_value(mx, "loss")
            return
        elseif my >= 280 and my <= 295 then
            self.dragging_slider = "duration"
            self:set_slider_value(mx, "duration")
            return
        end
    end

    if mx >= 20 and mx <= 130 and my >= 320 and my <= 355 then
        self:start()
    elseif mx >= 165 and mx <= 275 and my >= 320 and my <= 355 then
        self:stop()
    elseif mx >= 310 and mx <= 420 and my >= 320 and my <= 355 then
        self:reset()
    end
end

function PacketLagger:mousemoved(mx, my)
    if not self.dragging_slider then return end

    self:set_slider_value(mx - 20, self.dragging_slider)
end

function PacketLagger:mousereleased(button)
    if button == 1 then
        self.dragging_slider = nil
    end
end

return PacketLagger
