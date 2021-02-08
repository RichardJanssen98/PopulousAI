import(Module_System)
import(Module_String)
import(Module_Globals)
import(Module_DataTypes)

local gs = gsi()
local gns = gnsi()

local function isBitAnd(_a,_b)
  if (_a & (1 << _b) ~= 0) then return true else return false end
end

local function GetTurn()
  return gs.Counts.ProcessThings
end

local DEBUG_STR = string.format("MainEntry.lua has been successfully loaded.")

function OnTurn()
  if (GetTurn() % 12 == 0) then
    for i=0,31 do
      local _STR = string.format("Id: %d ; State: %s", i, tostring(isBitAnd(gns.Flags,i)))
      log(_STR)
    end
    log(string.format("Turn: %d", GetTurn()))
  end
end

log(DEBUG_STR)
