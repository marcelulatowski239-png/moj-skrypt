-- language: Lua, file: packet_lagger.lua, target: Game Scripting / LÖVE2D / Client Environment
-- Functional specifications implementation for Packet Lagger MADlUM in Lua

local PacketLagger = {}
PacketLagger.__index = PacketLagger

function PacketLagger.new()
    local self = setmetatable({}, PacketLagger)
    
    -- Core States & Configs
    self.active = false
    self.delay_ms = 0          -- 0 to 1000 ms
    self.packet_loss = 0       -- 0 to 100 %
    self.duration = 0          -- 0 = infinite, else seconds
    self.elapsed_time = 0
    
    -- Live Telemetry Metrics
    self.current_ping = 25
    self.current_fps = 60
    self.loss_status = "STABLE"
    
    -- UI Slider Grids (Normalized 0.0 to 1.0 ranges mapped to metrics)
    self.sliders = {
        delay = { min = 0, max = 1000, value = 0, dragging = false },
        loss = { min = 0, max = 100, value = 0, dragging = false },
        duration = { min = 0, max = 60, value = 0, dragging = false }
    }
    
    -- Statistics History for Chart Rendering
    self.ping_history = {}
    for i = 1, 50 do table.insert(self.ping_history, 25) end
    
    return self
end

function PacketLagger:start()
    self.active = true
    self.elapsed_time = 0
    self.loss_status = "ACTIVE"
end

function PacketLagger:stop()
    self.active = false
    self.loss_status = "IDLE"
    self.current_ping = 25
    self.current_fps = 60
end

function PacketLagger:reset()
    self:stop()
    self.sliders.delay.value = 0
    self.sliders.loss.value = 0
    self.sliders.duration.value = 0
    self.delay_ms = 0
    self.packet_loss = 0
    self.duration = 0
end

function PacketLagger:update(dt)
    if not self.active then return end
    
    -- Handle Duration countdown
    if self.sliders.duration.value > 0 then
        self.elapsed_time = self.elapsed_time + dt
        if self.elapsed_time >= self.sliders.duration.value then
            self:stop()
            return
        end
    end
    
    -- Map slider configurations to live variables
    self.delay_ms = self.sliders.delay.value
    self.packet_loss = self.sliders.loss.value
    
    -- 1. Ping: measure actual network latency simulation with jitter
    local base_ping = 25
    local jitter = math.random(-5, 5)
    self.current_ping = math.floor(base_ping + self.delay_ms + jitter)
    
    -- 2. Packet Loss simulation tracking
    local dropped = (math.random(0, 100) < self.packet_loss)
    if dropped then
        self.loss_status = "PACKET LOST"
    else
        self.loss_status = "ACTIVE"
    end
    
    -- 4. FPS statistics reflection based on lag overhead
    if dropped then
        self.current_fps = math.max(10, 30 - math.floor(self.packet_loss / 3))
    else
        self.current_fps = math.max(15, 60 - math.floor(self.delay_ms / 20))
    end
    
    -- Update Chart History buffer
    table.remove(self.ping_history, 1)
    table.insert(self.ping_history, self.current_ping)
end

-- 8. GUI Rendering Hook (Compatible with LÖVE2D or similar Lua rendering contexts)
function PacketLagger:draw_gui(x, y)
    -- Background panel
    -- draw_rect(x, y, 400, 500, {0.1, 0.1, 0.1, 0.9})
    
    -- Title
    -- draw_text("PACKET LAGGER // MADlUM", x + 20, y + 20, {0, 1, 0.8})
    
    -- 4. Live Statistics HUD
    local stats_str = string.format("Ping: %d ms | FPS: %d | Status: %s", 
        self.current_ping, self.current_fps, self.loss_status)
    -- draw_text(stats_str, x + 20, y + 60, {1, 1, 1})
    
    -- Sliders & Controls Representation
    -- draw_slider("Delay", self.sliders.delay.value, 0, 1000, x + 20, y + 120)
    -- draw_slider("Packet Loss", self.sliders.loss.value, 0, 100, x + 20, y + 190)
    -- draw_slider("Duration", self.sliders.duration.value, 0, 60, x + 20, y + 260)
    
    -- 8. Chart Rendering (Ping history plot)
    -- for i = 1, #self.ping_history - 1 do
    --     draw_line(x + 20 + (i * 7), y + 420 - (self.ping_history[i] / 3), 
    --               x + 20 + ((i+1) * 7), y + 420 - (self.ping_history[i+1] / 3), {0, 1, 0.8})
    -- end
end

return PacketLagger
