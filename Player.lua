Player = Class{}

function Player:init(paddle, score)
    self.paddle = paddle
    self.score = score or 0
end

--[[
    Controlla se la palla sta avendo una collisione con il
    riquadro del giocatore
    @return true se c'è una collisione, altrimenti false
]]
function Player:isColliding(ball)
    -- Controlla che la palla sia prima o dopo il riquadro
    if ball.x > self.paddle.x + self.paddle.width or
       ball.x + ball.width < self.paddle.x then
        return false
    end
    
    -- Controllo che la palla sia sopra o sotto il riquadro
    if ball.y > self.paddle.y + self.paddle.height or
       ball.y + ball.height < self.paddle.y then
        return false
    end

    return true
end

function Player:update(dt)
    self.paddle:update(dt)
end

function Player:render()
    self.paddle:render()
end