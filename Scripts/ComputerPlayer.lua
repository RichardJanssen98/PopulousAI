local gs = gsi()

_BUILD_BUFFER_IDXES = {
  [0] = {},
  [1] = {},
  [2] = {},
  [3] = {},
  [4] = {},
  [5] = {},
  [6] = {},
  [7] = {}
}

_SHAPE_HUTS_BUFFER = {
  [0] = {},
  [1] = {},
  [2] = {},
  [3] = {},
  [4] = {},
  [5] = {},
  [6] = {},
  [7] = {}
}

_NEW_HUTS_BUILT_BUFFER = {
  [0] = {},
  [1] = {},
  [2] = {},
  [3] = {},
  [4] = {},
  [5] = {},
  [6] = {},
  [7] = {}
}

ComputerPlayer = {}
ComputerPlayer.__index = ComputerPlayer

function ComputerPlayer:Create(_PN)
  local self = setmetatable({},ComputerPlayer)

  self.ERROR = false
  self.isActive = true
  self.PlayerNum = _PN or nil

  --Building attributes
  self.AttrMaxBldgsOnGoing = 0
  self.AttrPrefHuts = 0
  self.AttrPrefWarriorTrains = 0
  self.AttrPrefFirewarriorTrains = 0
  self.AttrPrefTempleTrains = 0
  self.AttrPrefSpyTrains = 0

  --Building flags
  self.FlagsConstructBldgs = false
  self.FlagsAutoBuild = false

  return self
end

function ComputerPlayer:GetHutsCount()
  return gs.Players[self.PlayerNum].NumBuiltOrPartBuiltBuildingsOfType[1] + gs.Players[self.PlayerNum].NumBuiltOrPartBuiltBuildingsOfType[2] + gs.Players[self.PlayerNum].NumBuiltOrPartBuiltBuildingsOfType[3] + #_SHAPE_HUTS_BUFFER[self.PlayerNum]
end

function ComputerPlayer:ProcessBuilding()
  local pn = self.PlayerNum
  if (#_NEW_HUTS_BUILT_BUFFER[pn] > 0) then
    local t_bldg = _NEW_HUTS_BUILT_BUFFER[pn][1]
    if (isFlagIdOn(t_bldg.u.Bldg.Flags,3)) then
      if (OnBuildingComplete ~= nil and type(OnBuildingComplete) == 'function') then
        CallHook(OnBuildingComplete, t_bldg)
        table.remove(_NEW_HUTS_BUILT_BUFFER[pn], 1)
      end
    end
  end
  if (#_BUILD_BUFFER_IDXES[pn] > 0) then
    local mapIdx = _BUILD_BUFFER_IDXES[pn][1]

    if (mapIdx == nil) then
      table.remove(_BUILD_BUFFER_IDXES[pn],1)
      goto process_bldg_skip
    end

    if (self:GetHutsCount() < self.AttrPrefHuts) then
      local buildable = true
      local orient = G_RANDOM(4)
      local mp_ent = MapPosXZ.new()
      mp_ent.Pos = mapIdx
      for f=0,1 do
        increment_map_idx_by_orient(mp_ent,(2+orient) % 4)
      end
      local c2d = Coord2D.new()

      map_idx_to_world_coord2d(mp_ent.Pos,c2d)
      if (is_point_steeper_than(c2d,350) ~= 0) then
        buildable = false
        table.remove(_BUILD_BUFFER_IDXES[pn], 1)
        goto process_bldg_skip
      end
      --local _c3d = Coord3D.new()
      --map_idx_to_world_coord3d(idx,_c3d)
      SearchMapCells(2,0,0,1,mapIdx,function(me)
        if (not me.ShapeOrBldgIdx:isNull()) then
          buildable = false
          return false
        end

        --This doesn't work yet.
        if (BUILD_FLAGS_CHECK_FOR_OBSTACLES) then
          if (me.Flags & (1<<1) ~= 0) then
            buildable = false
            return false
          end
        end
        --This doesn't work yet.

        if (me.Flags & (1<<9) ~= 0 and me.Flags & (1<<10) ~= 0) then
          buildable = false
          return false
        end
        local l_idx = MAP_ELEM_PTR_2_IDX(me)
        local a = is_map_cell_bldg_markable(gs.Players[pn],l_idx,0,0,1,0)
        if (a == 0) then
          buildable = false
          return false
        end
        return true
      end)
      if (buildable) then
        process_shape_map_elements(mapIdx, 1, orient, pn, 2)
        createThing(7,2,8,MAP_XZ_2_WORLD_XYZ(mp_ent.XZ.X,mp_ent.XZ.Z),false,false)
      end

      table.remove(_BUILD_BUFFER_IDXES[pn], 1)
    end

    ::process_bldg_skip::
  end
end

function ScanAreaForBldg(_pn, _idx, _radius)
  local a = _radius
  local m_idx = MapPosXZ.new()
  m_idx.Pos = _idx
  m_idx.XZ.X = m_idx.XZ.X-a
  m_idx.XZ.Z = m_idx.XZ.Z-a
  local x = 0
  local z = 0
  local num = 1
  for i=1,a do
    x = m_idx.XZ.X + (i*2)
    for j=1,a do
      z = m_idx.XZ.Z + (j*2)
      if (i==1 or i==a or j==1 or j==a) then
        local c_c3d = MAP_XZ_2_WORLD_XYZ(x,z)
        local me = world_coord3d_to_map_ptr(c_c3d)
        if (me.Flags & (1<<16) == 0 and me.Flags & (1<<9) == 0 and me.Flags & (1<<10) == 0 and me.Flags & (1<<18) == 0 and me.Flags & (1<<26) == 0 and me.Alt ~= 0) then
          local d = createThing(7,3,0,c_c3d,false,false)
          d.u.Effect.Duration = 32
          table.insert(_BUILD_BUFFER_IDXES[_pn],world_coord3d_to_map_idx(c_c3d))
        end
      end
    end
  end
end

function AddShapeToQueue(t,pn,bldgModel)
  if (bldgModel == 1) then
    table.insert(_SHAPE_HUTS_BUFFER[pn], t)
    log("ShapeHutsBufferCount: " .. #_SHAPE_HUTS_BUFFER[pn])
  end
end

function AddBldgToQueue(t,pn)
  table.insert(_NEW_HUTS_BUILT_BUFFER[pn], t)
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
    CallHook(OnPlayerInit,self.PlayerNum,self)
  end
  ::preinit_end::
end

function ComputerPlayer:isValid()
  return (self.ERROR ~= true)
end
