local SOUNDS = require('lib.sounds')
local UTIL = require('level.util')

---wave object. Wave class contains an array of this
---@class WAVE
---@field enemies {horizontal: {[number]: ENEMY}, vertical: {[number]: ENEMY}} number correlates to spawn time; enemy is type
---@field timer number actual running timer

---class to handle waves logic
---@class WAVES
---@field current integer current ongoing wave
---@field amount integer total amount of waves
---@field waves WAVE[] array of all waves for the level
---@field protected timer number default timer amount for each wave
local lib = {}

---create new wave instance
---@param amount integer the amount of waves
---@return WAVES
function lib:new(amount, timer)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.amount = amount
    o.current = 0
    o.waves = {}
    for i=1, o.amount do
        o.waves[i] = {timer = timer}
    end
    return o
end

---initialize wave(s); enemies must be all the same type
---@param wave_number integer
---@param enemy_amount integer
---@param enemy ENEMY
---@return boolean success
function lib:load(wave_number, enemy_amount, enemy)
    if wave_number < 1 or wave_number > self.amount then
        return false
    end

    --randomly place enemies in wave number based on timer
    local enemies = {}
    for i=1,enemy_amount do
        enemies[i] = enemy
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
    --update timer
    self.waves[self.current].timer = self.waves[self.current] - dt
    if self.waves[self.current].timer <= 0 then
        self:next()
    end

    --spawn enemy and remove from stack of current wave
    
end

return lib