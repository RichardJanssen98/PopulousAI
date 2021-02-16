local gs = gsi()

function CheckBldgShape(_mapidx, _pn, _bldg, _orient)
  local buildable = true

  if (_bldg == 1) then
    local mp1 = MapPosXZ.new()
    local mp2 = MapPosXZ.new()
    local mp3 = MapPosXZ.new()
    mp1.Pos = _mapidx
    mp2.Pos = _mapidx
    mp3.Pos = _mapidx

    increment_map_idx_by_orient(mp1, (2 + _orient) % 4)
    increment_map_idx_by_orient(mp2, (2 + _orient) % 4)
    increment_map_idx_by_orient(mp3, (2 + _orient) % 4)
    increment_map_idx_by_orient(mp1, (2 + _orient + 1) % 4)
    increment_map_idx_by_orient(mp3, (2 + _orient - 1) % 4)
    for i = 0, 2 do
      if (is_map_cell_bldg_markable(gs.Players[_pn], mp1.Pos, 0, 0, 1, 0) == 0) then
        buildable = false
        break
      end
      if (is_map_cell_bldg_markable(gs.Players[_pn], mp2.Pos, 0, 0, 1, 0) == 0) then
        buildable = false
        break
      end
      if (is_map_cell_bldg_markable(gs.Players[_pn], mp3.Pos, 0, 0, 1, 0) == 0) then
        buildable = false
        break
      end
      increment_map_idx_by_orient(mp1, (2 + _orient -2) % 4)
      increment_map_idx_by_orient(mp2, (2 + _orient -2) % 4)
      increment_map_idx_by_orient(mp3, (2 + _orient -2) % 4)
    end
  end

  return buildable
end
