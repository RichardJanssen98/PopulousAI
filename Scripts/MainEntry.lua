import(Module_System)
import(Module_String)
import(Module_Globals)
import(Module_DataTypes)
import(Module_Package)
import(Module_Objects)

require "Scripts\\Lib\\LibGameTurn"
require "Scripts\\Lib\\LibFlags"

local gs = gsi()
local gns = gnsi()

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
  if isEvery2Pow(5) then
    -- Unfortunately LUA doesn't pass variable as REFERENCE, so have to return flag from a function :/
    -- But thats still looks cleaner. MACRO defines should work
    gns.Flags = toggleFlag(gns.Flags,(1<<15))
    local s = getShaman(0)
    if (s ~= nil) then
      if (isFlagIdOn(s.Flags2,25)) then
        log("Is in balloon!")
      end
      if (isFlagOff(s.Flags,(1<<19))) then
        log("Is in control!")
      end
    end
    for i=0,31 do
      -- local _STR = string.format("Id: %d ; State: %s", i, tostring(isFlagIdOn(gns.Flags,i)))
      -- log(_STR)
      -- _STR = string.format("Id: %d ; State: %s", i, tostring(isFlagOn(gns.Flags2,(1<<i))))
      -- log(_STR)
    end
    log(string.format("Turn: %d", GetTurn()))
  end
end

log(DEBUG_STR)
