import(Module_System)
import(Module_String)
import(Module_Globals)
import(Module_DataTypes)
import(Module_Package)
import(Module_Players)
import(Module_Defines)
import(Module_PopScript)
import(Module_Game)
import(Module_Objects)
import(Module_Map)
import(Module_Person)
include("UtilPThings.lua")
include("UtilRefs.lua")
include("AIShaman.lua")
include("AIDefending.lua")

require "Mods\\PopulousAi\\Scripts\\Lib\\LibHooks"
require "Mods\\PopulousAi\\Scripts\\Lib\\LibGameTurn"
require "Mods\\PopulousAi\\Scripts\\Lib\\LibFlags"
require "Mods\\PopulousAi\\Scripts\\Lib\\LibSpells"
require "Mods\\PopulousAi\\Scripts\\ComputerPlayer"

computer_init_player(_gsi.Players[TRIBE_RED])

botBldgsRed = {M_BUILDING_TEPEE,
                   M_BUILDING_DRUM_TOWER,
                   M_BUILDING_WARRIOR_TRAIN,
                   M_BUILDING_SUPER_TRAIN,
                   M_BUILDING_SPY_TRAIN,
                   M_BUILDING_TEMPLE
}

for y,v in ipairs(botBldgsRed) do
    PThing.BldgSet(TRIBE_RED, v, TRUE)
end

WRITE_CP_ATTRIB(TRIBE_RED, ATTR_EXPANSION, 60)
WRITE_CP_ATTRIB(TRIBE_RED, ATTR_HOUSE_PERCENTAGE, 150)
WRITE_CP_ATTRIB(TRIBE_RED, ATTR_DEFENSE_RAD_INCR, 0)
WRITE_CP_ATTRIB(TRIBE_RED, ATTR_MAX_ATTACKS, 0)
WRITE_CP_ATTRIB(TRIBE_RED, ATTR_MAX_BUILDINGS_ON_GO, 15)
WRITE_CP_ATTRIB(TRIBE_RED, ATTR_MAX_TRAIN_AT_ONCE, 10)
WRITE_CP_ATTRIB(TRIBE_RED, ATTR_PREF_SUPER_WARRIOR_TRAINS, 1)
WRITE_CP_ATTRIB(TRIBE_RED, ATTR_PREF_SUPER_WARRIOR_PEOPLE, 30)
WRITE_CP_ATTRIB(TRIBE_RED, ATTR_PREF_WARRIOR_TRAINS, 1)
WRITE_CP_ATTRIB(TRIBE_RED, ATTR_PREF_WARRIOR_PEOPLE, 30)
WRITE_CP_ATTRIB(TRIBE_RED, ATTR_PREF_RELIGIOUS_TRAINS, 1)
WRITE_CP_ATTRIB(TRIBE_RED, ATTR_PREF_RELIGIOUS_PEOPLE, 15)
WRITE_CP_ATTRIB(TRIBE_RED, ATTR_RANDOM_BUILD_SIDE, 1)

STATE_SET(TRIBE_RED, TRUE, CP_AT_TYPE_BUILD_OUTER_DEFENCES)
STATE_SET(TRIBE_RED, TRUE, CP_AT_TYPE_FETCH_WOOD)
STATE_SET(TRIBE_RED, TRUE, CP_AT_TYPE_CONSTRUCT_BUILDING)
STATE_SET(TRIBE_RED, TRUE, CP_AT_TYPE_TRAIN_PEOPLE)
STATE_SET(TRIBE_RED, TRUE, CP_AT_TYPE_AUTO_ATTACK)
STATE_SET(TRIBE_RED, TRUE, CP_AT_TYPE_POPULATE_DRUM_TOWER)
STATE_SET(TRIBE_RED, TRUE, CP_AT_TYPE_FETCH_LOST_PEOPLE)
STATE_SET(TRIBE_RED, TRUE, CP_AT_TYPE_HOUSE_A_PERSON)

SET_DRUM_TOWER_POS(TRIBE_RED, 50, 14)
SHAMAN_DEFEND(TRIBE_RED, 50, 14, TRUE)

SET_DEFENCE_RADIUS(TRIBE_RED, 0)
SET_AUTO_BUILD(TRIBE_RED)


local c2d1 = Coord2D.new()
local c2d2 = Coord2D.new()
local c3d1 = Coord3D.new()
local c3d2 = Coord3D.new()

map_xz_to_world_coord2d(58, 56, c2d1)
map_xz_to_world_coord2d(98, 54, c2d2)

expandLocationsRed = {c2d1, c2d2}

AIDefendingRed = AIDefending:new(nil, TRIBE_RED, 0, 50, 14, 240, 1, 1, 1, 1, 1, 1, 150, 20, expandLocationsRed)
AIShamanRed = AIShaman:new(nil, TRIBE_RED, 1, 1, 1, 1, 1, 0, 0, 1, 1, 10000, 3)
redExpand = 0
RepairPointsRed = {}

--[[AIDefendingRed:addDrumTower(50, 2)
AIDefendingRed:addDrumTower(60, 0)
AIDefendingRed:addDrumTower(78, 2)
AIDefendingRed:addDrumTower(56, 244)
AIDefendingRed:addDrumTower(64, 242)
AIDefendingRed:addDrumTower(74, 242)
AIDefendingRed:addDrumTower(54, 234)
AIDefendingRed:addDrumTower(64, 234)--]]

function OnTurn()

    if (everyPow(36, 1)) then
        AIDefendingRed:defendMarkerLocation(54, 234, 1, 7, 1)
        AIDefendingRed:defendMarkerLocation(72, 234, 0, 7, 1)
        AIDefendingRed:defendMarkerLocation(56, 250, 2, 7, 1)
        AIDefendingRed:defendMarkerLocation(70, 250, 3, 7, 1)
        AIDefendingRed:defendMarkerLocation(52, 8, 4, 7, 1)
        AIDefendingRed:defendMarkerLocation(64, 8, 5, 7, 1)
        AIDefendingRed:defendMarkerLocation(76, 8, 6, 7, 1)
        AIDefendingRed:defendMarkerLocation(56, 36, 7, 11, 1)
        AIDefendingRed:defendMarkerLocation(88, 36, 8, 11, 1)

        GIVE_MANA_TO_PLAYER(TRIBE_BLUE, 50000)
        GIVE_MANA_TO_PLAYER(TRIBE_RED, 50000)
    end

    if (everyPow(128, 1)) then
        RepairPointsRed = AIDefendingRed:repairDamagedTiles(0)
    end

    local turnToForceNextRepair = 0
    if (RepairPointsRed[1] ~= nil and RepairPointsRed[2] ~= nil) then
        local redFinishedRepairing = AIDefendingRed:repairBetweenPoints(RepairPointsRed[1], RepairPointsRed[2])
        if (redFinishedRepairing == 1) then
            RepairPointsRed = {}
            redFinishedRepairing = 1
            log("resetRepairPoints")
        end
    end

    if (GetTurn() > 128) then
       AIShamanRed:handleShamanCombat()

       AIShamanRed:checkSpellDelay()
    end
	
    AIDefendingRed:resetDefend()
end
