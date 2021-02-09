local _g = gsi()
function GetTurn() return _g.Counts.ProcessThings end
function isEvery2Pow(exponent,offset)
  local _t = _g.Counts.ProcessThings
  local _off = offset or 0
  local _ft = _t-_off
  if (_ft % (2^exponent) == 0) then return true else return false end
end
function isEveryPow(primary,exponent,offset)
  local _t = _g.Counts.ProcessThings
  local _off = offset or 0
  local _ft = _t-_off
  if (_ft % (primary^exponent) == 0) then return true else return false end
end
function isEveryTurn(primary,offset)
  local _t = _g.Counts.ProcessThings
  local _off = offset or 0
  local _ft = _t-_off
  if (_ft % primary == 0) then return true else return false end
end
