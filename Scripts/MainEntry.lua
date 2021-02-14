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

function OnPlayerInit(pn,CP)
  log(string.format("Player %d was initiated.", pn))
  ScanAreaForBldg(pn, world_coord3d_to_map_idx(gs.Players[pn].ReincarnSiteCoord), 13)
  ScanAreaForBldg(pn, world_coord3d_to_map_idx(gs.Players[pn].ReincarnSiteCoord), 15)
  ScanAreaForBldg(pn, world_coord3d_to_map_idx(gs.Players[pn].ReincarnSiteCoord), 17)
  CP.AttrPrefHuts = 25 + G_RANDOM(20)
  CP.AttrMaxBldgsOnGoing = 4 + G_RANDOM(4)

  if (pn == 1) then
    CP.ConvManager:AddArea(36, 178, 2)
    CP.ConvManager:AddArea(40, 154, 2)
    CP.ConvManager:AddArea(66, 144, 2)
    CP.ConvManager:AddArea(94, 188, 2)
    CP.ConvManager:AddArea(98, 198, 2)

    CP:SetRebuildableTower(56, 156, 120)
    CP:SetRebuildableTower(60, 156, 140)
    CP:SetRebuildableTower(70, 158, 160)
    CP:SetRebuildableTower(70, 162, 180)
    CP:SetRebuildableTower(78, 162, 200)
    CP:SetRebuildableTower(62, 144, 220)
    CP:SetRebuildableTower(66, 140, 240)
    CP:SetRebuildableTower(42, 150, 260)
    CP:SetRebuildableTower(34, 144, 280)
    CP:SetRebuildableTower(28, 138, 300)
  end
  if (pn == 2) then
    CP.ConvManager:AddArea(62, 112, 2)
    CP.ConvManager:AddArea(64, 130, 2)
    CP.ConvManager:AddArea(36, 106, 2)
    CP.ConvManager:AddArea(26, 112, 2)
    CP.ConvManager:AddArea(10, 80, 2)
    CP.ConvManager:AddArea(22, 80, 2)
    CP.ConvManager:AddArea(22, 80, 6)

    CP:SetRebuildableTower(70, 98, 12)
    CP:SetRebuildableTower(66, 100, 140)
    CP:SetRebuildableTower(56, 100, 160)
    CP:SetRebuildableTower(52, 100, 180)
    CP:SetRebuildableTower(62, 112, 200)
    CP:SetRebuildableTower(62, 116, 220)
    CP:SetRebuildableTower(42, 104, 240)
    CP:SetRebuildableTower(36, 108, 260)
    CP:SetRebuildableTower(32, 112, 280)
    CP:SetRebuildableTower(28, 116, 300)
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
    log("it's nil!" .. i)
    goto skip
  end
  local _S = CP:isValid()
  local _STR = string.format("Is computer player valid? : %s", tostring(_S))
  log(_STR)
  if (not _S) then
    log("Computer Player was removed. Num: " .. CP.PlayerNum)
    log("" .. i)
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

function OnTurn()
  local _TURN = GetTurn()

  --Ai's building entry point
  if (_TURN > 0) then
    if isEvery2Pow(2) then
      for i,CP in ipairs(AiPlayers) do
        CP:ProcessBuilding()
      end
    end

    if isEvery2Pow(1) then
      for i,CP in ipairs(AiPlayers) do
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
    AddShapeToQueue(t,t.Owner,t.u.Shape.BldgModel)
  end

  if (t.Type == 2) then
    --Temporary ignore towers.
    if (t.u.Bldg.HasBuildingExistedBefore == 0 and t.Model ~= 4) then
      AddBldgToQueue(t,t.Owner)
    end
  end
end

log(DEBUG_STR)
