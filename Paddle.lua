Paddle = Class{}

function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self.dy = 0
end

function Paddle:update(dt)
    -- Muove il paddle
    self.y = self.y + self.dy * dt
    
    --[[
        Se il paddle sta uscendo dalla parte superiore dello
        schermo, resetto la coordinata y a 0 in modo che il
        bordo superiore del paddle sia appoggiato alla parte
        superiore della finestra
    ]]
    if self.y < TITLE_HEIGHT then
        self.y = TITLE_HEIGHT
    else
        --[[
            Se il paddle sta uscendo dalla parte inferiore dello
            schermo, resetto la coordinata y in modo che il bordo
            inferiore del paddle sia appoggiato alla base della
            finestra
        ]]
        if self.y + self.height > GAME_AREA_HEIGHT + TITLE_HEIGHT then
            self.y = GAME_AREA_HEIGHT + TITLE_HEIGHT - self.height
        end 
    end
end

function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end