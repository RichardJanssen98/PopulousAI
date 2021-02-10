local gs = gsi()

ComputerPlayer = {}
ComputerPlayer.__index = ComputerPlayer

function ComputerPlayer:Create(_PN)
  local self = setmetatable({},ComputerPlayer)

  self.ERROR = false
  self.isActive = true
  self.PlayerNum = _PN or nil
  self._Shapes = {}

  return self
end

function ComputerPlayer:ASDF()
  -- i hate myself
end

-- Temporary, might change logic.
function ComputerPlayer:PreInitialize()
  local _STR = string.format("[CP] Initializing computer player... Checking if it's valid first...")
  log(_STR)
  --Check if PlayerNum is nill
  if (self.PlayerNum == nil) then
    -- Deactivate if playernum was given an unknown value.
    self.isActive = false
    -- This is basically marking for removing.
    self.ERROR = true
    _STR = string.format("[CP] PlayerNum is invalid!")
    log(_STR)
    goto preinit_end
  end

  --Check if they're actually dead
  if (gs.Players[self.PlayerNum].DeadCount ~= 0) then
    self.isActive = false
    self.ERROR = true
    _STR = string.format("[CP] Computer player isn't alive! Player: %d", self.PlayerNum)
    log(_STR)
    goto preinit_end
  end

  --Mandatory to check if it's a function, you never know who is smart.
  if (OnPlayerInit ~= nil and type(OnPlayerInit) == 'function') then
    CallHook(OnPlayerInit,self.PlayerNum)
  end
  ::preinit_end::
end

function ComputerPlayer:isValid()
  return (self.ERROR ~= true)
end
