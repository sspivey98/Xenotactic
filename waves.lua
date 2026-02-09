local SOUNDS = require('lib.sounds')
local UTIL = require('level.util')
local ENEMY = require('enemy')
local ENUMS = require('enums')

---wave object. Wave class contains an array of this
---@class WAVE
---@field enemies ENUMS.ENEMY_TYPE[] always deploy the same amount in vertical and horizontal
---@field timer number actual running timer
---@field spawnTimer number spawn timer

---class to handle waves logic
---@class WAVES
---@field current integer current ongoing wave
---@field amount integer total amount of waves
---@field waves WAVE[] array of all waves for the level
---@field protected timer number default timer amount for each wave
---@field protected spawnTimer number default amount for spawn timer
---@field private horizontalOnly boolean some levels only go left->right
local lib = {}

---create new wave instance
---@param amount integer the amount of waves
---@param timer number how long the wave lasts
---@param spawnTimer? number time between enemy spawns
---@param horizontalOnly? boolean ignore vertical path spawning
---@return WAVES
function lib:new(amount, timer, spawnTimer, horizontalOnly)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.amount = amount
    o.current = 0
    o.spawnTimer = spawnTimer or 0.2
    o.horizontalOnly = horizontalOnly or false
    o.waves = {}
    for i=1, o.amount do
        o.waves[i] = {timer = timer, spawnTimer = o.spawnTimer}
    end
    return o
end

---initialize wave(s); enemies must be all the same type
---@param wave_number integer
---@param enemy_amount integer
---@param enemyTypeName ENUMS.ENEMY_TYPE
---@return boolean success
function lib:load(wave_number, enemy_amount, enemyTypeName)
    if wave_number < 1 or wave_number > self.amount then
        return false
    end

    --randomly place enemies in wave number based on timer
    local enemies = {}
    for i=1,enemy_amount do
        enemies[i] = enemyTypeName
    end

    self.waves[wave_number].enemies = enemies

    return true
end

---send the next wave; can't send until current wave is all killed
function lib:next()
    --increment wave
    self.current = self.current + 1
    SOUNDS.library["round_start"]:play()

    --if boss round
    if UTIL.tableLength(self.waves[self.current].enemies) == 1 then
        --wait 0.2 seconds
        SOUNDS.library["round_start"]:play()
    end
    
end

---update timer and enemy created
---@param dt number delta time between last frame and current frame
---@param gameState GAME.GAMESTATE
function lib:update(dt, gameState)
    --wait until waves start
    if self.current > 0 then
        local wave = self.waves[self.current]

        --update timers
        wave.timer = wave.timer - dt
        wave.spawnTimer = wave.spawnTimer - dt


        --spawn enemies from queue
        if wave.spawnTimer <= 0 and #wave.enemies > 0 then
            ENEMY:new(gameState, wave.enemies[1], gameState.path1)
            if not self.horizontalOnly then
                ENEMY:new(gameState, wave.enemies[1], gameState.path2)
            end
            table.remove(wave.enemies, 1)

            --reset spawn timer
            if #wave.enemies > 0 then
                wave.spawnTimer = self.spawnTimer
            end
        end

        --send next wave if timer complete
        if wave.timer <= 0 then
            self:next()
        end
    end
end

return lib