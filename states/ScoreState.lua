--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]] ScoreState = Class {
    __includes = BaseState
}

local medals = {
    ['Dectus'] = love.graphics.newImage('/medals/dectus.png'),
    ['Rold'] = love.graphics.newImage('/medals/rold.png'),
    ['Haligtree'] = love.graphics.newImage('/medals/haligtree.png')
}

local bronzeValue = 1
local silverValue = 2
local goldValue = 3

local gotMedal = ''

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    self.score = params.score

    gotMedal = self.score >= goldValue and 'Haligtree' or self.score >= silverValue and 'Rold' or self.score >= bronzeValue and 'Dectus' or
                   'Nothing :('

    drawMedal = medals[gotMedal]

end

function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    -- simply render the score to the middle of the screen
    love.graphics.setFont(flappyFont)
    love.graphics.printf('You got: ' .. gotMedal, 0, 64, VIRTUAL_WIDTH, 'center')

    if drawMedal then
        love.graphics.draw(drawMedal, VIRTUAL_WIDTH / 2 - drawMedal:getWidth() / 2, 120)
    end

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')

    love.graphics.printf('Press Enter to Play Again!', 0, 160, VIRTUAL_WIDTH, 'center')
end
