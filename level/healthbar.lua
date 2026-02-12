local lib = {}
local IMAGES = require('lib.images')

local frames = {
    [1] = IMAGES.library["healthbar_1"],
    [2] = IMAGES.library["healthbar_2"],
    [3] = IMAGES.library["healthbar_3"],
    [4] = IMAGES.library["healthbar_4"],
    [5] = IMAGES.library["healthbar_5"],
    [6] = IMAGES.library["healthbar_6"],
    [7] = IMAGES.library["healthbar_7"],
    [8] = IMAGES.library["healthbar_8"],
    [9] = IMAGES.library["healthbar_9"],
    [10] = IMAGES.library["healthbar_10"],
    [11] = IMAGES.library["healthbar_11"],
    [12] = IMAGES.library["healthbar_12"],
    [13] = IMAGES.library["healthbar_13"],
    [14] = IMAGES.library["healthbar_14"],
    [15] = IMAGES.library["healthbar_15"],
    [16] = IMAGES.library["healthbar_16"],
    [17] = IMAGES.library["healthbar_17"],
    [18] = IMAGES.library["healthbar_18"],
    [19] = IMAGES.library["healthbar_19"],
    [20] = IMAGES.library["healthbar_20"],
}

---draw health bar frame
---@param health integer 1-20
function lib.draw(health, x, y)
    love.graphics.setColor{1,1,1}
    love.graphics.draw(
        frames[health],
        x,
        y,
        0,
        1.5,
        1.5
    )
end

return lib