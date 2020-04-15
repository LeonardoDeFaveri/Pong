Ball = Class{}

function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    -- Variabili per tracciare la velocità della palla
    self.dx = 0
    self.dy = 0

    -- Variabili usate per resettare la posizione della palla
    self.defaultX = x
    self.defaultY = y
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

-- Resetta la posizione della palla
function Ball:reset()
    self.x = self.defaultX
    self.y = self.defaultY
    self.dx = 0
    self.dy = 0
end

-- Disegna la palla a schermo
function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end