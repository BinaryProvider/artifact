local Base = require("libraries.knife.base")

Tile = Base:extend({ x = 0, y = 0, type = 1 })

local x
local y
local type

function Tile:constructor (x, y, type)
    self.x = x
    self.y = y
    self.type = type
end

function Tile:test ()
    --print("yooohoooo!")
end