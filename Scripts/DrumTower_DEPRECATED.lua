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

DrumTower = {tribe = 0, xPos = 0, zPos = 0}
DrumTower.__index = DrumTower

function DrumTower:new (o, tribe, xPos, zPos)
    local o = o or {}
    setmetatable(o, DrumTower)
    o.tribe = tribe
    o.xPos = xPos
    o.zPos = zPos

    o.foundTower = false

    return o
end

function DrumTower:towerStatus()
    local c2d = Coord2D.new()
    map_xz_to_world_coord2d(self.xPos, self.zPos, c2d)

    SearchMapCells(CIRCULAR, 0, 0, 1, world_coord2d_to_map_idx(c2d), function(me)
        me.MapWhoList:processList(function(t)
            if (t.Type == T_SHAPE) then
                if (t.Owner == self.tribe and t.u.Shape.BldgModel == M_BUILDING_DRUM_TOWER) then
                    self.foundTower = true
                    local mp = MapPosXZ.new()
                    mp.Pos = world_coord3d_to_map_idx(t.Pos.D3)
                    if (mp.XZ.X ~= self.xPos or mp.XZ.Z ~= self.zPos) then
                        self.xPos = mp.XZ.X
                        self.zPos = mp.XZ.Z
                    end
                    return false
                end
            end

            if (t.Type == T_BUILDING) then
                if (t.Owner == self.tribe and t.Model == M_BUILDING_DRUM_TOWER) then
                    self.foundTower = true
                    local mp = MapPosXZ.new()
                    mp.Pos = world_coord3d_to_map_idx(t.Pos.D3)
                    if (mp.XZ.X ~= self.xPos or mp.XZ.Z ~= self.zPos) then
                        self.xPos = mp.XZ.X
                        self.zPos = mp.XZ.Z
                    end
                    return false
                end
            end
            return true
            end)
    return true
    end)

    if (self.foundTower == false) then
        BUILD_DRUM_TOWER(self.tribe, self.xPos, self.zPos)

        local c2d = Coord2D.new()
        map_xz_to_world_coord2d(self.xPos, self.zPos, c2d)
        SearchMapCells(CIRCULAR, 0, 0, 1, world_coord2d_to_map_idx(c2d), function (me)
          
        return true
        end)
    else
        self.foundTower = false
    end
end