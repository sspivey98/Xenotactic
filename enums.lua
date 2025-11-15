local IMAGES = require('lib.images')

local lib = {}

lib.CLICK = {
    LEFT = 1,
    RIGHT = 2
}

lib.TILES = {
    EMPTY = 0,
    WALL = 1,
    SPAWN = 2,
    FINAL = 3,
    TURRET = 4
}

lib.COLORS = {
    [0] = {0.7, 0.8, 0.7}, --green
    [1] = {0.7, 0.7, 0.7}, --grey
    [2] = {0.2, 0.2, 0.8}, --blue
    [3] = {0.8, 0.2, 0.2} --red
}

lib.TURRET = {
    WALL = {
        cost = 2,
        sell = 1,
        range = 0,
        speed = 0,
        damage = 0,
        image = IMAGES.library["turret_wall"]
    },
    GATLING = {
        cost = 5,
        sell = 3,
        range = 60,
        speed = 2,
        damage = 10,
        image = IMAGES.library["turret_gatling"]
    },
    PLASMA = {
        cost = 15,
        sell = 8,
        range = 70,
        speed = 4,
        damage = 5,
        image = IMAGES.library["turret_plasma"]
    },
    SAM = {
        cost = 20,
        sell = 10,
        range = 90,
        speed = 1,
        damage = 8,
        image = IMAGES.library["turret_sam"]
    },
    DCA = {
        cost = 50,
        sell = 25,
        range = 60,
        speed = 3,
        damage = 20,
        image = IMAGES.library["turret_sam"]
    },
    FREEZE = {
        cost = 50,
        sell = 25,
        range = 50,
        speed = 2,
        damage = 10,
        image = IMAGES.library["turret_freeze"]
    },
    TESLA = {
        cost = 30,
        sell = 15,
        range = 40,
        speed = 2,
        damage = 10,
        image = IMAGES.library["turret_tesla"]
    }
}

--match number to enum
lib.TURRET_TYPE = {
    [1] = lib.TURRET.WALL,
    [2] = lib.TURRET.GATLING,
    [3] = lib.TURRET.PLASMA,
    [4] = lib.TURRET.SAM,
    [5] = lib.TURRET.DCA,
    [6] = lib.TURRET.FREEZE,
    [7] = lib.TURRET.TESLA,
}

return lib