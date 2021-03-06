import(Module_System)
import(Module_String)
import(Module_Globals)
import(Module_DataTypes)
import(Module_Package)
import(Module_Map)
import(Module_Table)
import(Module_Math)
import(Module_Objects)
import(Module_Players)
import(Module_Shapes)
import(Module_Level)
import(Module_Game)
import(Module_Person)
import(Module_Commands)

require "Mods\\PopulousAi\\Scripts\\Lib\\LibHooks"
require "Mods\\PopulousAi\\Scripts\\Lib\\LibGameTurn"
require "Mods\\PopulousAi\\Scripts\\Lib\\LibFlags"
require "Mods\\PopulousAi\\Scripts\\ComputerPlayer"

local gs = gsi()
local gns = gnsi()

ResetSpellsCharging()

function OnPlayerInit(pn,CP)
  log(string.format("[CP] Player %d was initiated.", pn))
  ScanAreaForBldg(pn, world_coord3d_to_map_idx(gs.Players[pn].ReincarnSiteCoord), 13)
  ScanAreaForBldg(pn, world_coord3d_to_map_idx(gs.Players[pn].ReincarnSiteCoord), 15)
  ScanAreaForBldg(pn, world_coord3d_to_map_idx(gs.Players[pn].ReincarnSiteCoord), 17)
  CP.AttrPrefHuts = 35
  CP.AttrPrefTempleTrains = 0
  CP.AttrPrefSpyTrains = 0
  CP.AttrPrefWarriorTrains = 0
  CP.AttrPrefFirewarriorTrains = 1
  CP.AttrMaxBldgsOnGoing = 8 + G_RANDOM(5)

  CP.FlagsAutoBuild = true
  CP.FlagsConstructBldgs = true
  CP.FlagsCheckObstacles = true

  CP:AddSpellQueue(2, 1)
  CP:AddSpellQueue(17, 3)
  CP:AddSpellQueue(2, 2)
  CP:AddSpellQueue(4, 1)
  CP:AddSpellQueue(14, 1)
  CP:AddSpellQueue(5, 2)
  CP:AddSpellQueue(12, 1)
  CP:AddSpellQueue(14, 2)
  CP:AddSpellQueue(5, 4)
  CP:AddSpellQueue(4, 3)
  CP:AddSpellQueue(8, 1)
  CP:AddSpellQueue(3, 2)
  CP:AddSpellQueue(8, 2)
  CP:AddSpellQueue(16, 1)

  for i = 2, 19 do
    EnableSpell(pn, i)
    DisableSpellCharging(pn, i)
  end

  EnableSpellCharging(pn, 17)
  EnableSpellCharging(pn, 2)
  DisableSpellCharging(pn, 10)

  if (pn == 1) then
    CP.ConvManager:AddArea(36, 178, 2)
    CP.ConvManager:AddArea(40, 154, 2)
    CP.ConvManager:AddArea(66, 144, 2)
    CP.ConvManager:AddArea(94, 188, 2)
    CP.ConvManager:AddArea(98, 198, 2)

    CP.ShamanThingIdx:SetStandPointXZ(58, 158)

    CP:SetRebuildableTower(56, 156, 2, 120)
    CP:SetRebuildableTower(60, 156, 2, 140)
    CP:SetRebuildableTower(70, 158, 2, 160)
    CP:SetRebuildableTower(70, 162, 2, 180)
    CP:SetRebuildableTower(78, 162, 2, 200)
    CP:SetRebuildableTower(62, 144, 2, 220)
    CP:SetRebuildableTower(66, 140, 2, 240)
    CP:SetRebuildableTower(42, 150, 2, 260)
    CP:SetRebuildableTower(34, 144, 2, 280)
    CP:SetRebuildableTower(28, 138, 2, 300)
  end
  if (pn == 2) then
    CP.ConvManager:AddArea(62, 112, 2)
    CP.ConvManager:AddArea(64, 130, 2)
    CP.ConvManager:AddArea(36, 106, 2)
    CP.ConvManager:AddArea(26, 112, 2)
    CP.ConvManager:AddArea(10, 80, 2)
    CP.ConvManager:AddArea(22, 80, 2)
    CP.ConvManager:AddArea(22, 80, 6)

    CP.ShamanThingIdx:SetStandPointXZ(52, 98)

    CP:SetRebuildableTower(70, 98, 0, 12)
    CP:SetRebuildableTower(66, 100, 0, 24)
    CP:SetRebuildableTower(56, 100, 0, 160)
    CP:SetRebuildableTower(52, 100, 0, 180)
    CP:SetRebuildableTower(62, 112, 0, 200)
    CP:SetRebuildableTower(62, 116, 0, 220)
    CP:SetRebuildableTower(42, 104, 0, 240)
    CP:SetRebuildableTower(36, 108, 0, 260)
    CP:SetRebuildableTower(32, 112, 0, 280)
    CP:SetRebuildableTower(28, 116, 0, 300)
  end
  if (pn == 3) then
    CP.ConvManager:AddArea(212, 124, 2)
    CP.ConvManager:AddArea(212, 134, 2)
    CP.ConvManager:AddArea(240, 112, 2)
    CP.ConvManager:AddArea(250, 114, 2)
    CP.ConvManager:AddArea(248, 84, 3)
    CP.ConvManager:AddArea(218, 80, 2)
    CP.ConvManager:AddArea(198, 64, 2)

    CP.ShamanThingIdx:SetStandPointXZ(222, 104)

    CP:SetRebuildableTower(204, 100, 0, 6)
    CP:SetRebuildableTower(200, 96, 0, 12)
    CP:SetRebuildableTower(226, 106, 0, 64)
    CP:SetRebuildableTower(222, 106, 0, 96)
    CP:SetRebuildableTower(218, 106, 0, 128)
    CP:SetRebuildableTower(212, 114, 0, 164)
    CP:SetRebuildableTower(212, 120, 0, 196)
    CP:SetRebuildableTower(212, 126, 0, 234)
    CP:SetRebuildableTower(234, 110, 0, 256)
    CP:SetRebuildableTower(238, 114, 0, 290)
    CP:SetRebuildableTower(244, 118, 0, 314)
    CP:SetRebuildableTower(248, 122, 0, 346)
  end
end

local AiPlayers = {}

for i=1,3 do
  local cp = ComputerPlayer:Create(i)
  cp:PreInitialize()
  table.insert(AiPlayers,cp)
end

for i,CP in ipairs(AiPlayers) do
  if (AiPlayers[i] == nil) then
    goto skip
  end
  local _S = CP:isValid()
  if (not _S) then
    log("[CP] Computer Player was removed. Num: " .. CP.PlayerNum)

    --This is important to set it to nil, instead of table.remove()
    AiPlayers[i] = nil
  end
  ::skip::
end

--[[ Pow2 Table
=========
0  - 1
1  - 2
2  - 4
3  - 8
4  - 16
5  - 32
6  - 64
7  - 128
8  - 256
9  - 512
10 - 1024
11 - 2048
12 - 4096
13 - 8192
=========
]]

local DEBUG_STR = string.format("MainEntry.lua has been successfully loaded.")
local index = 0

local centre = MAP_XZ_2_WORLD_XYZ(10, 132)

local function randSign()
  local r = -1
  if (G_RANDOM(2) == 0) then
    r = 1
  end
  return r
end

function OnTurn()
  local _TURN = GetTurn()
  if (_TURN > 0) then
    for i,CP in ipairs(AiPlayers) do
      --Building.
      if isEvery2Pow(1, CP.PlayerNum+27+8) then
        CP:ProcessBuilding()
      end

      if isEvery2Pow(8, CP.PlayerNum+27+8) then
        if (CP:GetNumOfFireWarriors() > 4) then
          local fw_to_patrol = CP:GetRandomSparePerson(6)
          if (fw_to_patrol) then
            local tower_to_patrol_around = CP:GetRandomBuiltBuilding(4)
            if (tower_to_patrol_around) then
              local c3d = Coord3D.new()
              c3d.Xpos = tower_to_patrol_around.Pos.D3.Xpos + (G_RANDOM(5) * 512) * randSign()
              c3d.Zpos = tower_to_patrol_around.Pos.D3.Zpos + (G_RANDOM(5) * 512) * randSign()
              GotoPatrolSingleC3d(fw_to_patrol, c3d)
            end
          end
        end
      end

      --Misc stuff.
      if isEvery2Pow(9, CP.PlayerNum+27+8) then
        if (CP:GetNumOfFireWarriors() > 1) then
          CP:PopulateDrumTowers()
        end

        if (CP:GetNumOfBraves() > 40 and CP:GetNumOfFireWarriors() < 16 and CP:GetBuiltWarriorTrainsCount() > 0) then
          CP:TrainPeople(6, 4)
        end

        if (CP:GetBuiltHutsCount() > 10 and CP.AttrPrefFirewarriorTrains == 1) then
          CP.AttrPrefWarriorTrains = 1
        end
      end

      --Spell charging.
      if isEvery2Pow(4, CP.PlayerNum+27+8) then
        CP.ShamanThingIdx:Process()
        CP:ProcessSpellCharging()
      end

      --Misc stuff.
      if isEvery2Pow(3, CP.PlayerNum+27+8) then
        CP:ProcessShapes()
        CP:ProcessRebuildableTowers()
        if (_TURN > 64 and gs.Players[CP.PlayerNum].NumPeople < 42) then
          CP:ProcessConverting()
        end
      end
    end
  end
end

local function DoesExist(input)
  local res = false
  local idx = nil
  for i,k in ipairs(AiPlayers) do
    if (k.PlayerNum == input) then
      res = true
      idx = i
      break
    end
  end
  return res, idx
end

function OnBuildingComplete(t)
  ScanAreaForBldg(t.Owner, world_coord2d_to_map_idx(t.Pos.D2), 9)
  ScanAreaForBldg(t.Owner, world_coord2d_to_map_idx(t.Pos.D2), 11)
  ScanAreaForBldg(t.Owner, world_coord2d_to_map_idx(t.Pos.D2), 13)
end

function OnCreateThing(t)
  if (t.Type == 9) then
    AddShapeToQueue(t, t.Owner, t.u.Shape.BldgModel)
  end

  if (t.Type == 2) then
    --Temporary ignore towers.
    if (t.u.Bldg.HasBuildingExistedBefore == 0 and t.Model ~= 4) then
      AddBldgToQueue(t, t.Owner)
    end
  end
end

log(DEBUG_STR)
