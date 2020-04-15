push = require 'lib/push'
Class = require 'lib/class'

require 'Ball'
require 'Player'
require 'Paddle'

-- Parametri per impostare la dimensione della finestra
SCREEN_WIDTH = 1280
SCREEN_HEIGHT = 720

--[[
    Parametri per impostare la dimensione della finesta virtuale.
    È importante che il rapporto tra larghezza e altezza della
    finestra virtuale sia uguale al rapporto tra le misure della
    finestra reale, altrimenti il gioco per manetere le proprie
    proporzioni schiaccerà la finestra virtuale
]]
VIRTUAL_SCREEN_WIDTH = 503
VIRTUAL_SCREEN_HEIGHT = 283

TITLE_HEIGHT = 30
FOOTER_HEIGHT = 10

GAME_AREA_WIDTH = VIRTUAL_SCREEN_WIDTH
GAME_AREA_HEIGHT = VIRTUAL_SCREEN_HEIGHT - TITLE_HEIGHT - FOOTER_HEIGHT

BACKGROUND_COLOR = {225, 194, 26, 255}

PADDLE_SPEED = 200

POINTS_TO_WIN = 5

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle("MyPong")
    push:setupScreen(VIRTUAL_SCREEN_WIDTH, VIRTUAL_SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    math.randomseed(os.time())

    smallFont = love.graphics.newFont('fonts/font.ttf', 8)
    mediumFont = love.graphics.newFont('fonts/font.ttf', 16)
    largeFont = love.graphics.newFont('fonts/font.ttf', 24)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/score.wav', 'static')
    }

    ball = Ball(GAME_AREA_WIDTH / 2 - 2, VIRTUAL_SCREEN_HEIGHT / 2 - 2, 4, 4)
    player1 = Player(Paddle(10, TITLE_HEIGHT + 5, 5, 20), 0)
    player2 = Player(Paddle(GAME_AREA_WIDTH - 15, VIRTUAL_SCREEN_HEIGHT - FOOTER_HEIGHT - 25, 5, 20))
    servingPlayer = math.random(2)
    winner = 0;

    --[[
        I valori di gameStatus sono:
        - start: il gioco è appena stato avviato ed è in attesa che inizi una partita
        - serve: in attesa che il giocatore di turno serva
        - play:  c'è una partita in corso
        - end:   la partita è terminata
    ]]
    gameStatus = 'start'
end

function love.resize(width, height)
    push:resize(width, height)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then 
        if gameStatus == 'start' then
            gameStatus = 'serve'
        elseif gameStatus == 'serve' then
            gameStatus = 'play'
        elseif gameStatus == 'end' then
            gameStatus = 'start'
            player1.score = 0
            player2.score = 0
            if winner == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end     
end

function love.update(dt)
    if gameStatus == 'serve' then
        ball.dy = math.random(-50, 50)
        ball.dx = math.random(140, 200)
        if servingPlayer == 2 then
            ball.dx = -ball.dx
        end
    elseif gameStatus == 'play' then
        --[[
            Controllo delle collisioni con i giocatori
        ]]
        if player1:isColliding(ball) then
            ball.x = player1.paddle.x + player1.paddle.width
            --[[
                Inverte la velocità orizzontale in modo che poi la
                palla vada nella direzione opposta e la aumenta.
                La velocità verticale viene anch'essa inverita (se
                la palla arriva dall'alto viene fatta rimbalazare in
                basso) e le viene assegnato un valore casuale
            ]]
            ball.dx = -ball.dx * 1.05
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds['paddle_hit']:play()
        elseif player2:isColliding(ball) then
            ball.x = player2.paddle.x - ball.width
            ball.dx = -ball.dx * 1.05
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds['paddle_hit']:play()
        end

        --[[
            Controllo delle collisioni con il bordo superiore e inferiore
        ]]
        if ball.y <= TITLE_HEIGHT then
            ball.y = TITLE_HEIGHT
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        elseif ball.y + ball.height >= GAME_AREA_HEIGHT + TITLE_HEIGHT then
            ball.y = GAME_AREA_HEIGHT + TITLE_HEIGHT - ball.height
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        --[[
            Controllo della posizione orizzontale della palla
        ]]
        if ball.x < 0 then
            player2.score = player2.score + 1

            if player2.score == POINTS_TO_WIN then
                winner = 2
                gameStatus = 'end'
            else
                ball:reset()
                gameStatus = 'serve'
                servingPlayer = 1
            end
            sounds['score']:play()
        elseif ball.x > GAME_AREA_WIDTH then
            player1.score = player1.score + 1
            
            if player1.score == POINTS_TO_WIN then
                winner = 1
                gameStatus = 'end'
            else
                ball:reset()
                gameStatus = 'serve'
                servingPlayer = 2
            end
            sounds['score']:play()
        end

        ball:update(dt)
    end

    --[[
        Controllo del movimento dei giocatori
    ]]
    -- Giocatore 1
    if love.keyboard.isDown('w') then
        player1.paddle.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.paddle.dy = PADDLE_SPEED
    else
        player1.paddle.dy = 0
    end

    -- Giocatore 2
    if love.keyboard.isDown('up') then
        player2.paddle.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.paddle.dy = PADDLE_SPEED
    else
        player2.paddle.dy = 0
    end

    player1:update(dt)
    player2:update(dt)
end

function love.draw()
    push:start()

    love.graphics.clear()
    printHeader(gameStatus)
    printFooter()
    love.graphics.setColor(255, 255, 255, 255)
    ball:render()
    player1:render()
    player2:render()
    push:finish()
end

--[[
    Stampa l'header del gioco.
    L'header cambia in baso allo stato del gioco
]]
function printHeader(gameStatus)
    love.graphics.setColor(BACKGROUND_COLOR)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_SCREEN_WIDTH, TITLE_HEIGHT)
    if gameStatus == 'start' then
        love.graphics.setFont(mediumFont)
        love.graphics.setColor(255, 19, 19, 255)
        love.graphics.printf("Welcome to MyPong", 0, 2, VIRTUAL_SCREEN_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.setColor(122, 8, 8, 255)
        love.graphics.printf("Press enter to start the game", 0, 20, VIRTUAL_SCREEN_WIDTH, 'center')
        ball:render()
    elseif gameStatus == 'serve' then
        love.graphics.setFont(mediumFont)
        love.graphics.setColor(255, 19, 19, 255)
        if servingPlayer == 1 then
            love.graphics.printf("Serving player 1", 0, 2, VIRTUAL_SCREEN_WIDTH, 'center')
        else
            love.graphics.printf("Serving player 2", 0, 2, VIRTUAL_SCREEN_WIDTH, 'center')
        end
        love.graphics.setFont(smallFont)
        love.graphics.setColor(122, 8, 8, 255)
        love.graphics.printf("Press enter to serve", 0, 20, VIRTUAL_SCREEN_WIDTH, 'center')
        printScore()
    elseif gameStatus == 'play' then
        printScore()
    elseif gameStatus == 'end' then
        love.graphics.setFont(mediumFont)
        love.graphics.setColor(255, 19, 19, 255)
        love.graphics.printf("Player " .. winner .. " wins!", 0, 2, VIRTUAL_SCREEN_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.setColor(122, 8, 8, 255)
        love.graphics.printf("Press enter to start a new game", 0, 20, VIRTUAL_SCREEN_WIDTH, 'center')
        printScore()
    end
end

--[[
    Stampa una barra nella parte inferiore dello schermo dove
    vengono mostrati gli FPS
]]
function printFooter()
    love.graphics.setColor(BACKGROUND_COLOR)
    love.graphics.rectangle('fill', 0, VIRTUAL_SCREEN_HEIGHT - FOOTER_HEIGHT, VIRTUAL_SCREEN_WIDTH, FOOTER_HEIGHT)
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 155, 100, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, VIRTUAL_SCREEN_HEIGHT - FOOTER_HEIGHT + 1)
end

--[[
    Stampa il punteggio dei giocatori
]]
function printScore()
    love.graphics.setFont(largeFont)
    love.graphics.setColor(122, 8, 8, 255)
    love.graphics.print(player1.score, VIRTUAL_SCREEN_WIDTH / 4, 2)
    love.graphics.print(player2.score, VIRTUAL_SCREEN_WIDTH * 3 / 4, 2)
end