_g = gsi()

function SpellEnableCharging(_pn, _spell)
  _g.ThisLevelInfo.PlayerThings[_pn].SpellsNotCharging = _g.ThisLevelInfo.PlayerThings[_pn].SpellsNotCharging ~ (1<<_spell-1)
end

function SpellDisableCharging(_pn, _spell)
  _g.ThisLevelInfo.PlayerThings[_pn].SpellsNotCharging = _g.ThisLevelInfo.PlayerThings[_pn].SpellsNotCharging | (1<<_spell-1)
end
