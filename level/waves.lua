---load waves for each level
local WAVES = require('waves')
local ENUMS = require('enums')

local lib = {}

local LAT = ENUMS.FLOWFIELD.LATITUDE
local LON = ENUMS.FLOWFIELD.LONGITUDE

lib.level1 = WAVES:new(20, 35, 0.3, true)
lib.level2 = WAVES:new(20, 35)
lib.level3 = WAVES:new(30, 26)
lib.level4 = WAVES:new(40, 25)
lib.level5 = WAVES:new(50, 24)
lib.level6 = WAVES:new(100, 23)

lib.level1:load(1, 10, "SCORPION")
lib.level1:load(2, 10, "ALIEN")
lib.level1:load(3, 10, "BOSS1")
lib.level1:load(4, 10, "GOBLIN")
lib.level1:load(5, 10, "TERMITE")
lib.level1:load(6, 10, "SLIME")
lib.level1:load(7, 10, "SPIDER")
lib.level1:load(8, 1, "QUEEN")
lib.level1:load(9, 10, "WENDIGO")
lib.level1:load(10, 10, "TURTLE")
lib.level1:load(11, 10, "REDCYBORG")
lib.level1:load(12, 10, "SCORPION")
lib.level1:load(13, 10, "SLIME")
lib.level1:load(14, 10, "HELICOPTER")
lib.level1:load(15, 10, "SCORPION")
lib.level1:load(16, 1, "BOSS1")
lib.level1:load(17, 10, "REDCYBORG")
lib.level1:load(18, 10, "WENDIGO")
lib.level1:load(19, 10, "SCORPION")
lib.level1:load(20, 10, "SLIME")

lib.level2:load(1, 10, "SCORPION")

return lib