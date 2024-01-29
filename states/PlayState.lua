--[[
    PlayState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The PlayState class is the bulk of the game, where the player actually controls the bird and
    avoids pipes. When the player collides with a pipe, we should go to the GameOver state, where
    we then go back to the main menu.
]] PlayState = Class {
    __includes = BaseState
}

PIPE_SPEED = 60
PIPE_WIDTH = 70
PIPE_HEIGHT = 288

BIRD_WIDTH = 38
BIRD_HEIGHT = 24

GAP_BASE_HEIGHT = 90
GAP_VARIATION = 20

PIPE_FREQ_FAST = 2
PIPE_FREQ_SLOW = 5

function PlayState:init()
    self.bird = Bird()
    self.pipePairs = {}
    self.timer = 0
    self.score = 0

    -- initialize our last recorded Y value for a gap placement to base other gaps off of
    self.lastY = -PIPE_HEIGHT + math.random(80) + 20

    -- initialize first pipe immediately
    self.pipeFrequency = 0
end

function PlayState:update(dt)
    -- update timer for pipe spawning
    if paused == false then
        self.timer = self.timer + dt

        pipeFrequency = math.random(PIPE_FREQ_FAST, PIPE_FREQ_SLOW)

        -- spawn a new pipe pair when timer reaches pipeFrequency
        if self.timer > self.pipeFrequency then

            local gapHeight = math.random(GAP_BASE_HEIGHT - GAP_VARIATION, GAP_BASE_HEIGHT + GAP_VARIATION)

            -- modify the last Y coordinate we placed so pipe gaps aren't too far apart
            -- no higher than 10 pixels below the top edge of the screen,
            -- and no lower than a gap length (randomized) from the bottom
            local y = math.max(-PIPE_HEIGHT + 10,
                math.min(self.lastY + math.random(-20, 20), VIRTUAL_HEIGHT - gapHeight - PIPE_HEIGHT))
            self.lastY = y

            -- add a new pipe pair at the end of the screen at our new Y
            table.insert(self.pipePairs, PipePair(y, gapHeight))

            -- get new pipe frequency
            self.pipeFrequency = math.random() * (PIPE_FREQ_SLOW - PIPE_FREQ_FAST) + PIPE_FREQ_FAST

            -- reset timer
            self.timer = 0
        end

        -- for every pair of pipes..
        for k, pair in pairs(self.pipePairs) do
            -- score a point if the pipe has gone past the bird to the left all the way
            -- be sure to ignore it if it's already been scored
            if not pair.scored then
                if pair.x + PIPE_WIDTH < self.bird.x then
                    self.score = self.score + 1
                    pair.scored = true
                    sounds['score']:play()
                end
            end

            -- update position of pair
            pair:update(dt)
        end

        -- we need this second loop, rather than deleting in the previous loop, because
        -- modifying the table in-place without explicit keys will result in skipping the
        -- next pipe, since all implicit keys (numerical indices) are automatically shifted
        -- down after a table removal
        for k, pair in pairs(self.pipePairs) do
            if pair.remove then
                table.remove(self.pipePairs, k)
            end
        end

        -- simple collision between bird and all pipes in pairs
        for k, pair in pairs(self.pipePairs) do
            for l, pipe in pairs(pair.pipes) do
                if self.bird:collides(pipe) then
                    sounds['explosion']:play()
                    sounds['hurt']:play()

                    gStateMachine:change('score', {
                        score = self.score
                    })
                end
            end
        end

        -- update bird based on gravity and input
        self.bird:update(dt)

        -- reset if we get to the ground
        if self.bird.y > VIRTUAL_HEIGHT - 15 then
            sounds['explosion']:play()
            sounds['hurt']:play()

            gStateMachine:change('score', {
                score = self.score
            })
        end

    end
    -- pause if p is pressed
    if love.keyboard.wasPressed('p') then
        if paused == false then
            paused = true
            sounds['pause']:play()
			sounds['music']:pause()
        else
            paused = false
            sounds['unpause']:play()
			sounds['music']:play()
        end
    end
end

function PlayState:render()
    for k, pair in pairs(self.pipePairs) do
        pair:render()
    end

    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: ' .. tostring(self.score), 8, 8)

    self.bird:render()

    if paused == true then
        local rectWidth = 20
        local rectHeight = 80
        local rectGap = 20

        love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - rectGap / 2 - rectWidth,
            VIRTUAL_HEIGHT / 2 - rectHeight / 2, rectWidth, rectHeight)
        love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 + rectGap / 2, VIRTUAL_HEIGHT / 2 - rectHeight / 2, rectWidth, rectHeight)

		love.graphics.setFont(smallFont)
		love.graphics.printf('P: to unpause', 0, VIRTUAL_HEIGHT / 2 + 50, VIRTUAL_WIDTH, 'center')
	else
		love.graphics.setFont(smallFont)
		love.graphics.printf('P: to pause', 0, 10, VIRTUAL_WIDTH - 10, 'right')
    end
end

--[[
    Called when this state is transitioned to from another state.
]]
function PlayState:enter()
    -- if we're coming from death, restart scrolling
    scrolling = true
end

--[[
    Called when this state changes to another state.
]]
function PlayState:exit()
    -- stop scrolling for the death/score screen
    scrolling = false
end
