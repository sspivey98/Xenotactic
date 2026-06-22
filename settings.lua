---@alias dimension {WIDTH:number,HEIGHT:number}
---@class SETTINGS
local lib = {}

--[[
4:3 
    - 800x600
    - 1024x768
16:9
    - 1280x720 
    - 1366x768
    - 1600x900 
    - 1920x1080
--]]
---@type dimension
lib.resolution = {WIDTH=1280, HEIGHT=720}
lib.scale = 1.5
lib.easyPlacementMode = false
lib.CANVAS = {
    GAME = nil,
    OFFSET = {
        x = 0,
        y = 0
    },
    SCALE = 1
}

function lib:setResolution(width, height)
    if width == 1280 and height == 720 then
        self.resolution.WIDTH = 1280
        self.resolution.HEIGHT = 720
        self.TILE_SIZE = 24
        self.scale = 1.5
    elseif width == 1600 and height == 900 then
        self.resolution.WIDTH = 1600
        self.resolution.HEIGHT = 900
        self.TILE_SIZE = 30
        self.scale = 1.8
    elseif width == 1920 and height == 1080 then
        self.resolution.WIDTH = 1920
        self.resolution.HEIGHT = 1080
        self.TILE_SIZE = 36
        self.scale = 2.3
    else
        error("Bad argument")
    end
    if not self.isMobile() then
        love.window.setMode(width,height)
    end
    self.SCREEN.MAP = {
        WIDTH = self.map.Width * self.TILE_SIZE,
        HEIGHT = self.map.Height * self.TILE_SIZE
    }
    self.load()
end

---@type number size of a side of square tile in pixels
lib.TILE_SIZE = 24

---@type {Width:number, Height:number} dimension in tiles
lib.map = {
    Width = 33,
    Height = 30
}

---@type {MAP:dimension,UI:dimension,WIDTH:number,HEIGHT:number}
lib.SCREEN = {
    MAP = {
        WIDTH = lib.map.Width * lib.TILE_SIZE,
        HEIGHT = lib.map.Height * lib.TILE_SIZE
    }
}

---load default window settings
function lib.load()
    if lib.resolution.WIDTH and lib.resolution.HEIGHT then
        lib.SCREEN.WIDTH = lib.resolution.WIDTH
        lib.SCREEN.HEIGHT = lib.resolution.HEIGHT
    else
        lib.SCREEN.WIDTH = love.graphics.getWidth()
        lib.SCREEN.HEIGHT = love.graphics.getHeight()
    end
    lib.SCREEN.UI = {
        WIDTH = lib.SCREEN.WIDTH - lib.SCREEN.MAP.WIDTH,
        HEIGHT = lib.SCREEN.HEIGHT
    }
end

---@return boolean
function lib.isMobile()
    local OS = string.lower(love.system.getOS())
    if OS == "android" or OS == "ios" then
        return true
    else
        return false
    end
end

return lib