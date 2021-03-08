--Same as go into building command just named differently.
function GotoTrain(_pers, _train)
  _pers.Flags = _pers.Flags | (1<<4)
  local cmd = Commands.new()
  cmd.CommandType = 8
  cmd.u.TargetIdx:set(_train.ThingNum)
  add_persons_command(_pers, cmd, 0)
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
