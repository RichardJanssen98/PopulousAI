local gs = gsi()

--[[
  TO DO:
  -- Obstacle check on main shape
  -- Obstacle check at entrance
  -- Balloon shape check
  -- Boat shape check (?)
]]

function CheckBldgShape(_mapidx, _pn, _bldg, _orient)
  local buildable = true

  --Check if center is actually viable.
  if (is_map_cell_bldg_markable(gs.Players[_pn], _mapidx, 0, 0, 1, 0) == 0) then
    buildable = false
    goto skip
  end

  --Hut & Warrior Shape Check
  if (_bldg == 1 or _bldg == 7) then
    local mp1 = MapPosXZ.new()
    local mp2 = MapPosXZ.new()
    local mp3 = MapPosXZ.new()
    local mpe = MapPosXZ.new()
    mp1.Pos = _mapidx
    mp2.Pos = _mapidx
    mp3.Pos = _mapidx
    mpe.Pos = _mapidx

    increment_map_idx_by_orient(mpe, (2 + _orient) % 4)
    increment_map_idx_by_orient(mpe, (2 + _orient) % 4)
    local c2d = Coord2D.new()

    map_idx_to_world_coord2d(mpe.Pos, c2d)
    if (is_point_steeper_than(c2d, 300) ~= 0) then
      buildable = false
      goto skip
    end

    increment_map_idx_by_orient(mp1, (0 + _orient) % 4)
    increment_map_idx_by_orient(mp2, (0 + _orient) % 4)
    increment_map_idx_by_orient(mp3, (0 + _orient) % 4)
    increment_map_idx_by_orient(mp1, (2 + _orient + 1) % 4)
    increment_map_idx_by_orient(mp3, (2 + _orient - 1) % 4)


    if (is_map_cell_bldg_markable(gs.Players[_pn], mp1.Pos, 0, 0, 1, 0) == 0) then
      buildable = false
      goto skip
    end
    if (is_map_cell_bldg_markable(gs.Players[_pn], mp2.Pos, 0, 0, 1, 0) == 0) then
      buildable = false
      goto skip
    end
    if (is_map_cell_bldg_markable(gs.Players[_pn], mp3.Pos, 0, 0, 1, 0) == 0) then
      buildable = false
      goto skip
    end
    for i = 0, 1 do
      increment_map_idx_by_orient(mp1, (2 + _orient - 4) % 4)
      increment_map_idx_by_orient(mp2, (2 + _orient - 4) % 4)
      increment_map_idx_by_orient(mp3, (2 + _orient - 4) % 4)
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
    end
  end

  --Temple Shape Check
  if (_bldg == 5) then
    local mp1 = MapPosXZ.new()
    local mp2 = MapPosXZ.new()
    local mp3 = MapPosXZ.new()
    local mpe = MapPosXZ.new()
    mp1.Pos = _mapidx
    mp2.Pos = _mapidx
    mp3.Pos = _mapidx
    mpe.Pos = _mapidx

    increment_map_idx_by_orient(mpe, (2 + _orient) % 4)
    increment_map_idx_by_orient(mpe, (2 + _orient) % 4)
    increment_map_idx_by_orient(mpe, (2 + _orient) % 4)

    local c2d = Coord2D.new()
    map_idx_to_world_coord2d(mpe.Pos, c2d)
    if (is_point_steeper_than(c2d, 300) ~= 0) then
      buildable = false
      goto skip
    end

    increment_map_idx_by_orient(mp1, (0 + _orient) % 4)
    increment_map_idx_by_orient(mp2, (0 + _orient) % 4)
    increment_map_idx_by_orient(mp3, (0 + _orient) % 4)
    increment_map_idx_by_orient(mp1, (2 + _orient + 1) % 4)
    increment_map_idx_by_orient(mp3, (2 + _orient - 1) % 4)


    if (is_map_cell_bldg_markable(gs.Players[_pn], mp1.Pos, 0, 0, 1, 0) == 0) then
      buildable = false
      goto skip
    end
    if (is_map_cell_bldg_markable(gs.Players[_pn], mp2.Pos, 0, 0, 1, 0) == 0) then
      buildable = false
      goto skip
    end
    if (is_map_cell_bldg_markable(gs.Players[_pn], mp3.Pos, 0, 0, 1, 0) == 0) then
      buildable = false
      goto skip
    end
    for i = 0, 2 do
      increment_map_idx_by_orient(mp1, (2 + _orient - 4) % 4)
      increment_map_idx_by_orient(mp2, (2 + _orient - 4) % 4)
      increment_map_idx_by_orient(mp3, (2 + _orient - 4) % 4)
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
    end
  end

  --Firewarrior Shape Check
  if (_bldg == 8) then
    local mp1 = MapPosXZ.new()
    local mp2 = MapPosXZ.new()
    local mp3 = MapPosXZ.new()
    local mp4 = MapPosXZ.new()
    local mpe = MapPosXZ.new()
    mp1.Pos = _mapidx
    mp2.Pos = _mapidx
    mp3.Pos = _mapidx
    mp4.Pos = _mapidx
    mpe.Pos = _mapidx

    increment_map_idx_by_orient(mpe, (2 + _orient) % 4)
    increment_map_idx_by_orient(mpe, (2 + _orient) % 4)
    increment_map_idx_by_orient(mpe, (2 + _orient) % 4)

    local c2d = Coord2D.new()
    map_idx_to_world_coord2d(mpe.Pos, c2d)
    if (is_point_steeper_than(c2d, 300) ~= 0) then
      buildable = false
      goto skip
    end

    increment_map_idx_by_orient(mp1, (0 + _orient) % 4)
    increment_map_idx_by_orient(mp2, (0 + _orient) % 4)
    increment_map_idx_by_orient(mp3, (0 + _orient) % 4)
    increment_map_idx_by_orient(mp4, (0 + _orient) % 4)
    increment_map_idx_by_orient(mp1, (2 + _orient + 1) % 4)
    increment_map_idx_by_orient(mp4, (2 + _orient - 1) % 4)
    increment_map_idx_by_orient(mp4, (2 + _orient - 1) % 4)
    increment_map_idx_by_orient(mp3, (2 + _orient - 1) % 4)

    if (is_map_cell_bldg_markable(gs.Players[_pn], mp1.Pos, 0, 0, 1, 0) == 0) then
      buildable = false
      goto skip
    end
    if (is_map_cell_bldg_markable(gs.Players[_pn], mp2.Pos, 0, 0, 1, 0) == 0) then
      buildable = false
      goto skip
    end
    if (is_map_cell_bldg_markable(gs.Players[_pn], mp3.Pos, 0, 0, 1, 0) == 0) then
      buildable = false
      goto skip
    end
    if (is_map_cell_bldg_markable(gs.Players[_pn], mp4.Pos, 0, 0, 1, 0) == 0) then
      buildable = false
      goto skip
    end
    for i = 0, 2 do
      increment_map_idx_by_orient(mp1, (2 + _orient - 4) % 4)
      increment_map_idx_by_orient(mp2, (2 + _orient - 4) % 4)
      increment_map_idx_by_orient(mp3, (2 + _orient - 4) % 4)
      increment_map_idx_by_orient(mp4, (2 + _orient - 4) % 4)
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
      if (is_map_cell_bldg_markable(gs.Players[_pn], mp4.Pos, 0, 0, 1, 0) == 0) then
        buildable = false
        break
      end
    end
  end

  --Tower Shape Check
  if (_bldg == 4) then
    local mpe = MapPosXZ.new()
    mpe.Pos = _mapidx

    local c2d = Coord2D.new()

    increment_map_idx_by_orient(mpe, (2 + _orient) % 4)
    map_idx_to_world_coord2d(mpe.Pos, c2d)
    if (is_point_steeper_than(c2d, 300) ~= 0) then
      buildable = false
      goto skip
    end
  end

  --Spy Shape Check
  if (_bldg == 6) then
    local mp1 = MapPosXZ.new()
    local mp2 = MapPosXZ.new()
    local mpe = MapPosXZ.new()
    mp1.Pos = _mapidx
    mp2.Pos = _mapidx
    mpe.Pos = _mapidx

    if (_orient == 0) then
      increment_map_idx_by_orient(mpe, 2)
      increment_map_idx_by_orient(mpe, 1)
    elseif(_orient == 1) then
      increment_map_idx_by_orient(mpe, 3)
      increment_map_idx_by_orient(mpe, 0)
    elseif(_orient == 2) then
      increment_map_idx_by_orient(mpe, 0)
      increment_map_idx_by_orient(mpe, 0)
      increment_map_idx_by_orient(mpe, 1)
    elseif(_orient == 3) then
      increment_map_idx_by_orient(mpe, 1)
      increment_map_idx_by_orient(mpe, 1)
      increment_map_idx_by_orient(mpe, 0)
    end
    local c2d = Coord2D.new()

    map_idx_to_world_coord2d(mpe.Pos, c2d)
    if (is_point_steeper_than(c2d, 300) ~= 0) then
      buildable = false
      goto skip
    end

    increment_map_idx_by_orient(mp2, 1)

    if (is_map_cell_bldg_markable(gs.Players[_pn], mp1.Pos, 0, 0, 1, 0) == 0) then
      buildable = false
      goto skip
    end
    if (is_map_cell_bldg_markable(gs.Players[_pn], mp2.Pos, 0, 0, 1, 0) == 0) then
      buildable = false
      goto skip
    end
    increment_map_idx_by_orient(mp1, 0)
    increment_map_idx_by_orient(mp2, 0)
    if (is_map_cell_bldg_markable(gs.Players[_pn], mp1.Pos, 0, 0, 1, 0) == 0) then
      buildable = false
      goto skip
    end
    if (is_map_cell_bldg_markable(gs.Players[_pn], mp2.Pos, 0, 0, 1, 0) == 0) then
      buildable = false
      goto skip
    end
  end

  ::skip::
  return buildable
end
