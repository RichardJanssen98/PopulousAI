function isFlagIdOn(_a,_b)
  if (_a & (1 << _b) ~= 0) then return true else return false end
end
function isFlagIdOff(_a,_b)
  if (_a & (1 << _b) == 0) then return true else return false end
end
function isFlagOn(_a,_b)
  if (_a & _b ~= 0) then return true else return false end
end
function isFlagOff(_a,_b)
  if (_a & _b == 0) then return true else return false end
end
function toggleFlag(a,_b)
  local _a = a
  if (_a & _b == 0) then _a = _a | _b else _a = _a ~ _b end return _a
end
