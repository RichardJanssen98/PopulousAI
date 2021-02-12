local gs = gsi()

_WILD_BUFFER = {
  [0] = {},
  [1] = {},
  [2] = {},
  [3] = {},
  [4] = {},
  [5] = {},
  [6] = {},
  [7] = {}
}

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

AiShaman = {}
AiShaman.__index = AiShaman

function AiShaman:RegisterShaman(t)
  local self = setmetatable({}, AiShaman)

  self.ProxyIdx = ObjectProxy.new()
  self.ProxyIdx:set(t.ThingNum)

  self.WildTargetIdx = ObjectProxy.new()
  self.WildConvDelay = 16
  self.WildConvCount = 0

  return self
end

function AiShaman:GotoC3d(_c3d, flag, idx)
  local _thing = self.ProxyIdx:get()
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

function AiShaman:GotoCastSpell(c2d, spell)
  local thing = self.ProxyIdx:get()
  thing.u.Pers.u.Owned.SubState2a = 128 + spell
  thing.Move.CurrDest.Coord = c2d
  thing.Move.StageCoord = c2d
  thing.Move.FinalCoord = c2d
  set_person_new_state(thing, 38)
end

function AiShaman:SetWild(t)
  self.WildTargetIdx:set(t.ThingNum)
  self.WildConvCount = self.WildConvDelay
end

ConvertManager = {}
ConvertManager.__index = ConvertManager

ConvertArea = {}
ConvertArea.__index = ConvertArea

function ConvertArea:New(_c3d, _radius)
  local self = setmetatable({}, ConvertArea)

  self.Coord = _c3d
  self.Radius = _radius

  return self
end

function ConvertManager:Register(_pn)
  local self = setmetatable({}, ConvertManager)

  self.PlrNum = _pn
  self.Areas = {}
  self.Index = 1

  return self
end

function ConvertManager:ScanAreas()
  for i,Area in ipairs(self.Areas) do
    SearchMapCells(2, 0, 0, Area.Radius, world_coord3d_to_map_idx(Area.Coord), function(me)
      if (not me.MapWhoList:isEmpty()) then
        me.MapWhoList:processList(function(t)
          if (t.Type == 1) then
            if (t.Model == 1) then
              table.insert(_WILD_BUFFER[self.PlrNum], t)
              return true
            end
          end
          return true
        end)
      end
      return true
    end)
  end
end

function ConvertManager:AddArea(_x, _z, _rad)
  local c3d = MAP_XZ_2_WORLD_XYZ(_x, _z)
  centre_coord3d_on_block(c3d)

  local a = ConvertArea:New(c3d, _rad)
  table.insert(self.Areas, a)

  --Reset idx
  self.Index = 1
end

ComputerPlayer = {}
ComputerPlayer.__index = ComputerPlayer

function ComputerPlayer:Create(_PN)
  local self = setmetatable({}, ComputerPlayer)

  self.ERROR = false
  self.isActive = true
  self.PlayerNum = _PN or nil

  --Makes computer player not popscript.
  gs.Players[_PN].PlayerType = 2

  --Shaman
  --local s = getShaman(_PN)
  log("" ..  getShaman(_PN).ThingNum)
  self.ShamanThingIdx = AiShaman:RegisterShaman(getShaman(_PN))

  --Converting manager
  self.ConvManager = ConvertManager:Register(_PN)

  --Building attributes
  self.AttrMaxBldgsOnGoing = 0
  self.AttrPrefHuts = 0
  self.AttrPrefWarriorTrains = 0
  self.AttrPrefFirewarriorTrains = 0
  self.AttrPrefTempleTrains = 0
  self.AttrPrefSpyTrains = 0

  --Building flags
  self.FlagsConstructBldgs = true
  self.FlagsAutoBuild = false
  self.FlagsCheckObstacles = true

  return self
end

function ComputerPlayer:GetHutsCount()
  return gs.Players[self.PlayerNum].NumBuiltOrPartBuiltBuildingsOfType[1] + gs.Players[self.PlayerNum].NumBuiltOrPartBuiltBuildingsOfType[2] + gs.Players[self.PlayerNum].NumBuiltOrPartBuiltBuildingsOfType[3] + #_SHAPE_HUTS_BUFFER[self.PlayerNum]
end

function ComputerPlayer:GetShotsCount(spell)
  return gs.ThisLevelInfo.PlayerThings[self.PlayerNum].SpellsAvailableOnce[spell] & 15
end

function ComputerPlayer:GetOnGoingBuildings()
  return gs.Players[self.PlayerNum].NumBuildingMarkers
end

function ComputerPlayer:AnyWilds()
  return (#_WILD_BUFFER[self.PlayerNum] > 0)
end

function ComputerPlayer:ProcessConverting()
  local pn = self.PlayerNum
  if (#_WILD_BUFFER[pn] == 0) then
    log("Wild buffer: " .. #_WILD_BUFFER[pn])
    self.ConvManager:ScanAreas()
  end

  if (self:AnyWilds()) then
    local wild = _WILD_BUFFER[pn][1]
    if (wild == nil) then
      table.remove(_WILD_BUFFER[pn], 1)
      goto process_wild_skip
    end

    if (wild.Type ~= 1) then
      table.remove(_WILD_BUFFER[pn], 1)
      goto process_wild_skip
    end

    if (wild.Model ~= 1) then
      table.remove(_WILD_BUFFER[pn], 1)
      goto process_wild_skip
    end

    self.ShamanThingIdx:SetWild(wild)

    if (self:GetShotsCount(17) > 0) then
      if (get_world_dist_xyz(self.ShamanThingIdx.WildTargetIdx:get().Pos.D3, self.ShamanThingIdx.ProxyIdx:get().Pos.D3) < 8192) then
        self.ShamanThingIdx:GotoCastSpell(self.ShamanThingIdx.WildTargetIdx:get().Pos.D2, 17)
      else
        remove_all_persons_commands(self.ShamanThingIdx.ProxyIdx:get())
        self.ShamanThingIdx:GotoC3d(self.ShamanThingIdx.WildTargetIdx:get().Pos.D3, false, 0)
      end
    end

    ::process_wild_skip::
  end
  log("Wild buffer: " .. #_WILD_BUFFER[pn])
end

function ComputerPlayer:ProcessShapes()
  local pn = self.PlayerNum
  if (#_NEW_HUTS_BUILT_BUFFER[pn] > 0) then
    local t_bldg = _NEW_HUTS_BUILT_BUFFER[pn][1]
    if (t_bldg == nil) then
      table.remove(_NEW_HUTS_BUILT_BUFFER[pn], 1)
      goto process_part_bldg_skip
    end
    if (isFlagIdOn(t_bldg.u.Bldg.Flags,3)) then
      if (OnBuildingComplete ~= nil and type(OnBuildingComplete) == 'function') then
        CallHook(OnBuildingComplete, t_bldg)
        table.remove(_NEW_HUTS_BUILT_BUFFER[pn], 1)
      end
    end
    ::process_part_bldg_skip::
  end
  if (#_SHAPE_HUTS_BUFFER[pn] > 0) then
    local t_shape = _SHAPE_HUTS_BUFFER[pn][1]
    if (t_shape == nil) then
      table.remove(_SHAPE_HUTS_BUFFER[pn], 1)
      goto process_shape_skip
    end

    if (t_shape.Type ~= 9) then
      table.remove(_SHAPE_HUTS_BUFFER[pn], 1)
      goto process_shape_skip
    end

    if (t_shape.Owner ~= pn) then
      table.remove(_SHAPE_HUTS_BUFFER[pn], 1)
      goto process_shape_skip
    end

    ::process_shape_skip::
  end
end

function ComputerPlayer:ProcessBuilding()
  local pn = self.PlayerNum
  if (self.FlagsConstructBldgs) then
    if (#_BUILD_BUFFER_IDXES[pn] > 0) then
      local mapIdx = _BUILD_BUFFER_IDXES[pn][1]

      if (mapIdx == nil) then
        table.remove(_BUILD_BUFFER_IDXES[pn], 1)
        goto process_bldg_skip
      end

      if (self:GetHutsCount() < self.AttrPrefHuts and self:GetOnGoingBuildings() < self.AttrMaxBldgsOnGoing) then
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

          if (self.FlagsCheckObstacles) then
            if (me.Flags & (1<<1) ~= 0) then
              buildable = false
              return false
            end
          end

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
