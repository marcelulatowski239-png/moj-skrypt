local PacketLagger

function love.load()
    love.window.setTitle("MADlUM Network Simulator")
    love.window.setMode(480, 560, {
        resizable = false,
        vsync = 1
    })

    math.randomseed(os.time())

    PacketLagger = require("packet_lagger")
    app = PacketLagger.new()
end

function love.update(dt)
    app:update(dt)
end

function love.draw()
    app:draw(20, 20)
end

function love.mousepressed(x, y, button)
    app:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    app:mousereleased(button)
end

function love.mousemoved(x, y, dx, dy)
    app:mousemoved(x, y)
end
