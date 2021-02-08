import(Module_System)
import(Module_String)
import(Module_Globals)

local gs = gsi()

local function GetTurn()
  return gs.Counts.ProcessThings
end

local DEBUG_STR = string.format("MainEntry.lua has been successfully loaded.")

function function OnTurn()
  if (GetTurn() % 12 == 0) then
    log(string.format("Turn: %d", GetTurn()))
  end
end

log(DEBUG_STR)
