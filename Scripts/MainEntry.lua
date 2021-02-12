import(Module_System)
import(Module_String)
import(Module_Globals)
import(Module_DataTypes)
import(Module_Package)
import(Module_Map)
import(Module_Table)
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
        --CP:ProcessBuilding()
      end
    end

    if isEvery2Pow(1) then
      for i,CP in ipairs(AiPlayers) do
        --CP:ProcessShapes()
        CP:ProcessConverting()
      end
    end
  end
  -- if isEvery2Pow(5) then
  --   --Temporary
  --   log ("Computer Players Count: " .. #AiPlayers)
  --   for i,CP in ipairs(AiPlayers) do
  --     if (AiPlayers[i] == nil) then
  --       log("it's nil!" .. i)
  --       goto skip
  --     end
  --     local _S = CP:isValid()
  --     local _STR = string.format("Is computer player valid? : %s", tostring(_S))
  --     log(_STR)
  --     if (not _S) then
  --       log("Computer Player was removed. Num: " .. CP.PlayerNum)
  --       log("" .. i)
  --       --This is important to set it to nil, instead of table.remove()
  --       AiPlayers[i] = nil
  --     end
  --     ::skip::
  --   end
  --   -- Unfortunately LUA doesn't pass variable as REFERENCE, so have to return flag from a function :/
  --   -- But thats still looks cleaner. MACRO defines should work
  --   gns.Flags = toggleFlag(gns.Flags,(1<<15))
  --   local s = getShaman(0)
  --   if (s ~= nil) then
  --     if (isFlagIdOn(s.Flags2,25)) then
  --       log("Is in balloon!")
  --     end
  --     if (isFlagOff(s.Flags,(1<<19))) then
  --       log("Is in control!")
  --     end
  --   end
  --   for i=0,31 do
  --     -- local _STR = string.format("Id: %d ; State: %s", i, tostring(isFlagIdOn(gns.Flags,i)))
  --     -- log(_STR)
  --     -- _STR = string.format("Id: %d ; State: %s", i, tostring(isFlagOn(gns.Flags2,(1<<i))))
  --     -- log(_STR)
  --   end
  --   log(string.format("Turn: %d", GetTurn()))
  -- end
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
    if (t.u.Bldg.HasBuildingExistedBefore == 0) then
      AddBldgToQueue(t,t.Owner)
    end
  end
end

log(DEBUG_STR)
