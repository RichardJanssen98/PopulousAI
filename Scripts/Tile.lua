import(Module_System)
import(Module_Players)
import(Module_Defines)
import(Module_PopScript)
import(Module_Game)
import(Module_Objects)
import(Module_Map)
import(Module_Person)
import(Module_Commands)
include("UtilPThings.lua")
include("UtilRefs.lua")

Tile = {tribe = 0, c2d = 0, starterAltitude = 0}
Tile.__index = Tile

function Tile:new (o, tribe, c2d, starterAltitude)
    local o = o or {}
    setmetatable(o, Tile)
    o.tribe = tribe
    o.c2d = c2d
    o.starterAltitude = starterAltitude

    return o
end

function Tile:tileAltitudeChange()
    local result = "nothing"
    local currentAltitude = point_altitude(self.c2d.Xpos, self.c2d.Zpos)

    if (self.starterAltitude ~= currentAltitude) then 
        local altDifference = currentAltitude - self.starterAltitude
        
        --Altitude changed into Water
        if (self.starterAltitude > 0 and currentAltitude == 0) then
            result = "water"
        --Big Altitude change
        elseif (altDifference > 30) then
            log("GoingIntoHeight")
            if (self.starterAltitude < currentAltitude) then --If altitude lower than original can't raise it higher anymore
                --Set starterAltitude to currentAltitude somehow
                self.starterAltitude = currentAltitude
                log("setNewHeight")
            end
            result = "height"
        end
    end

    return result
end