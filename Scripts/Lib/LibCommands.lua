--Same as go into building command just named differently.
function GotoTrain(_pers, _train)
  _pers.Flags = _pers.Flags | (1<<4)
  local cmd = Commands.new()
  cmd.CommandType = 8
  cmd.u.TargetIdx:set(_train.ThingNum)
  add_persons_command(_pers, cmd, 0)
end

--Patrol multiple points.
function GotoPatrolMultiC3d(_pers, _c3d_tabl)
  if (_c3d_tabl ~= nil and #_c3d_tabl > 0) then
    _pers.Flags = _pers.Flags | (1<<4)
    for i,c3d in ipairs(_c3d_tabl) do
      local cmd = Commands.new()
      cmd.CommandType = 25
      cmd.Flags = cmd.Flags | (1<<7)
      cmd.u.TargetCoord.Xpos = c3d.Xpos
      cmd.u.TargetCoord.Zpos = c3d.Zpos
      add_persons_command(_pers,cmd,i-1)
    end
  end
end

--Patrol single point.
function GotoPatrolSingleC3d(_pers, _c3d)
  _pers.Flags = _pers.Flags | (1<<4)
  local cmd = Commands.new()
  cmd.CommandType = 25
  cmd.Flags = cmd.Flags | (1<<7)
  cmd.u.TargetCoord.Xpos = _c3d.Xpos
  cmd.u.TargetCoord.Zpos = _c3d.Zpos
  add_persons_command(_pers, cmd, i-1)
end

--Go into building command.
function GotoBldg(_pers, _bldg)
  _pers.Flags = _pers.Flags | (1<<4)
  local cmd = Commands.new()
  cmd.CommandType = 8
  cmd.u.TargetIdx:set(_bldg.ThingNum)
  add_persons_command(_pers, cmd, 0)
end

--Moving command.
function GotoC3d(_thing, _c3d, flag, idx)
  _thing.Flags = _thing.Flags | (1<<4)
  local cmd = Commands.new()
  cmd.CommandType = 3
  if (flag) then
    cmd.Flags = cmd.Flags | (1<<7)
  end
  cmd.u.TargetCoord.Xpos = _c3d.Xpos
  cmd.u.TargetCoord.Zpos = _c3d.Zpos
  add_persons_command(_thing, cmd, idx)
end

--Building command.
function GotoBuild(_thing,shape,idx)
  --log("Sent building")
  _thing.Flags = _thing.Flags | (1<<4)
  local cmd = Commands.new()
  cmd.CommandType = 6
  cmd.u.TMIdxs.TargetIdx:set(shape.ThingNum)
  cmd.u.TMIdxs.MapIdx = world_coord2d_to_map_idx(cmd.u.TMIdxs.TargetIdx:get().Pos.D2)
  add_persons_command(_thing,cmd,idx)
end
