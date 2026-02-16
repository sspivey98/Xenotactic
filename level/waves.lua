---load waves for each level
local WAVES = require('waves')

local lib = {}

lib.level1 = WAVES:new(20, 35, 0.5, true)
lib.level2 = WAVES:new(20, 26)
lib.level3 = WAVES:new(30, 26)
lib.level4 = WAVES:new(40, 25)
lib.level5 = WAVES:new(50, 24)
lib.level6 = WAVES:new(100, 24)

---waves are the same 1-50 across first 5 levels
---1-50
for i=1,5 do
    ---@type WAVES
    local wave = lib["level"..i]
    wave:load(1, 10, "SCORPION", 20)
    wave:load(2, 10, "ALIEN", 24)
    wave:load(3, 10, "BOSS1", 29)
    wave:load(4, 10, "GOBLIN", 33)
    wave:load(5, 10, "TERMITE", 36)
    wave:load(6, 10, "SLIME", 60)
    wave:load(7, 10, "SPIDER", 40)
    wave:load(8, 1, "QUEEN", 528, 20, 0.8, true)
    wave:load(9, 10, "WENDIGO", 58)
    wave:load(10, 10, "TURTLE", 66)
    wave:load(11, 10, "REDCYBORG", 73)
    wave:load(12, 10, "SCORPION", 79, 1.5)
    wave:load(13, 10, "SLIME", 132, 8, 1, false, {amount=2, type="CYBORG"})
    wave:load(14, 10, "HELICOPTER", 44)
    wave:load(15, 10, "SCORPION", 96)
    wave:load(16, 1, "BOSS1", 1544, 0.8)
    wave:load(17, 10, "REDCYBORG", 145)
    wave:load(18, 10, "WENDIGO", 160)
    wave:load(19, 10, "SCORPION", 174, 1.5)
    wave:load(20, 4, "SLIME", 290)
end

---30-50
for i=3,5 do
    ---@type WAVES
    local wave = lib["level"..i]
    wave:load(21, 10, "HELICOPTER", 193)
    wave:load(22, 10, "QUEEN", 212)
    wave:load(23, 10, "WENDIGO", 283)
    wave:load(24, 3, "TURTLE", 1597, 0.8)
    wave:load(25, 10, "REDCYBORG", 353)
    wave:load(26, 10, "SCORPION", 383, 1.5)
    wave:load(27, 5, "SLIME", 638)
    wave:load(28, 10, "HELICOPTER", 425)
    wave:load(29, 10, "SCORPION", 468)
    wave:load(30, 10, "ALIEN", 623)
end

---40-50
for i=4,5 do
    ---@type WAVES
    local wave = lib["level"..i]
    wave:load(31, 10, "BOSS1", 702)
    wave:load(32, 1, "WENDIGO", 9332, 0.8)
    wave:load(33, 10, "SCORPION", 843, 1.5)
    wave:load(34, 4, "SLIME", 1405)
    wave:load(35, 10, "HELICOPTER", 937)
    wave:load(36, 10, "QUEEN", 1030)
    wave:load(37, 10, "WENDIGO", 1370)
    wave:load(38, 10, "TURTLE", 1546)
    wave:load(39, 10, "REDCYBORG", 1711)
    wave:load(40, 1, "SCORPION", 12263, 1.25)
end

---50
lib.level5:load(41, 5, "SLIME", 1546)
lib.level5:load(42, 10, "HELICOPTER", 2061)
lib.level5:load(43, 10, "SCORPION", 2267, 1.5)
lib.level5:load(44, 10, "ALIEN", 3015)
lib.level5:load(45, 10, "BOSS1", 3401)
lib.level5:load(46, 10, "WENDIGO", 3764)
lib.level5:load(47, 10, "SCORPION", 4081, 1.5)
lib.level5:load(48, 1, "SLIME", 81633, 0.75)
lib.level5:load(49, 1, "HELICOPTER", 27211)
lib.level5:load(50, 10, "QUEEN", 1744)

return lib