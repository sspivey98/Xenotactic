---load waves for each level
local WAVES = require('waves')
local ENUMS = require('enums')

local lib = {}

lib.level1 = WAVES:new(20, 35)
lib.level2 = WAVES:new(20, 35)
lib.level3 = WAVES:new(30, 35)
lib.level4 = WAVES:new(40, 35)
lib.level5 = WAVES:new(50, 35)
lib.level6 = WAVES:new(100, 35)

lib.level1:load(1, 10, ENUMS.ENEMY.SCORPION)
lib.level1:load(2, 10, ENUMS.ENEMY.ALIEN)
lib.level1:load(3, 10, ENUMS.ENEMY.BOSS1)
lib.level1:load(4, 10, ENUMS.ENEMY.GOBLIN)
lib.level1:load(5, 10, ENUMS.ENEMY.TERMITE)
lib.level1:load(6, 10, ENUMS.ENEMY.SLIME)
lib.level1:load(7, 10, ENUMS.ENEMY.SPIDER)
lib.level1:load(8, 1, ENUMS.ENEMY.QUEEN)
lib.level1:load(9, 10, ENUMS.ENEMY.WENDIGO)
lib.level1:load(10, 10, ENUMS.ENEMY.TURTLE)
lib.level1:load(11, 10, ENUMS.ENEMY.REDCYBORG)
lib.level1:load(12, 10, ENUMS.ENEMY.SCORPION)
lib.level1:load(13, 10, ENUMS.ENEMY.SLIME)
lib.level1:load(14, 10, ENUMS.ENEMY.HELICOPTER)
lib.level1:load(15, 10, ENUMS.ENEMY.SCORPION)
lib.level1:load(16, 1, ENUMS.ENEMY.BOSS1)
lib.level1:load(17, 10, ENUMS.ENEMY.REDCYBORG)
lib.level1:load(18, 10, ENUMS.ENEMY.WENDIGO)
lib.level1:load(19, 10, ENUMS.ENEMY.SCORPION)
lib.level1:load(20, 10, ENUMS.ENEMY.SLIME)

return lib