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

_REBUILDABLE_TOWERS = {
  [0] = {},
  [1] = {},
  [2] = {},
  [3] = {},
  [4] = {},
  [5] = {},
  [6] = {},
  [7] = {}
}

AiTower = {}
AiTower.__index = AiTower

function AiTower:CreateTower(_x, _z, _orient, _pn, _ticks)
  local self = setmetatable({}, AiTower)

  self.Coord = MAP_XZ_2_WORLD_XYZ(_x, _z) or nil
  self.PlrNum = _pn
  self.BldgProxy = ObjectProxy.new()
  self.ShapeProxy = ObjectProxy.new()
  self.BldgOrient = _orient
  self.Radius = 0
  self.CheckTimeDelay = _ticks or 240
  self.CheckTimeStamp = gs.Counts.ProcessThings + _ticks

  return self
end

function AiTower:ProcessTower()
  if (not self.ShapeProxy:isNull() and self.BldgProxy:isNull()) then
    if (not self.ShapeProxy:get().u.Shape.BldgThingIdx:isNull()) then
      self.BldgProxy:set(self.ShapeProxy:get().u.Shape.BldgThingIdx:getThingNum())
    end
  end
  self:CheckTower()
end

function AiTower:CheckTower()
  if (self.BldgProxy:isNull() and self.ShapeProxy:isNull()) then
    if (gs.Counts.ProcessThings > self.CheckTimeStamp) then
      self.CheckTimeStamp = gs.Counts.ProcessThings + self.CheckTimeDelay
      local shape_found = false
      SearchMapCells(2, 0, 0, self.Radius, world_coord3d_to_map_idx(self.Coord), function(me)
        if (me.MapWhoList:isEmpty()) then
          me.MapWhoList:processList(function(t)
            if (t.Type == 9) then
              if (t.Owner == self.PlrNum) then
                if (t.u.Shape.BldgModel == 4) then
                  self.ShapeProxy:set(t.ThingNum)
                  self.Radius = 0
                  shape_found = true
                  return false
                end
              end
            end
            return true
          end)
        end
        if (not shape_found) then
          local pos_valid = false
          local m_idx = MAP_ELEM_PTR_2_IDX(me)
          local mp = MapPosXZ.new()
          mp.Pos = m_idx
          if (is_map_cell_bldg_markable(gs.Players[self.PlrNum], m_idx, 0, 0, 1, 0) == 1) then
            increment_map_idx_by_orient(mp, (2 + self.BldgOrient) % 4)
            if (is_map_cell_bldg_markable(gs.Players[self.PlrNum], mp.Pos, 0, 0, 1, 0) == 1) then
              pos_valid = true
            end

            if (pos_valid) then
              process_shape_map_elements(m_idx, 4, self.BldgOrient, self.PlrNum, 2)
              me.MapWhoList:processList(function(t)
                if (t.Type == 9) then
                  if (t.Owner == self.PlrNum) then
                    if (t.u.Shape.BldgModel == 4) then
                      self.ShapeProxy:set(t.ThingNum)
                      self.Radius = 0
                      return false
                    end
                  end
                end
                return true
              end)
            end
          end
          if (pos_valid) then
            return false
          end
          return true
        end
        return true
      end)
      if (self.Radius < 5) then
        self.Radius = self.Radius + 1
      end
    end
  end
end

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

function AiShaman:isCastingSpell()
  return (self.ProxyIdx:get().State == 38)
end

function AiShaman:AcceptingCommands()
  return (get_thing_curr_cmd_list_ptr(self.ProxyIdx:get()) == nil)
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
  self.CheckWildsTimeStamp = gs.Counts.ProcessThings

  return self
end

function ConvertManager:ScanAreas()
  if (gs.Counts.ProcessThings > self.CheckWildsTimeStamp) then
    self.CheckWildsTimeStamp = gs.Counts.ProcessThings + 360
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
end

function ConvertManager:AddArea(_x, _z, _rad)
  local c3d = MAP_XZ_2_WORLD_XYZ(_x, _z)
  centre_coord3d_on_block(c3d)

  local a = ConvertArea:New(c3d, _rad)
  table.insert(self.Areas, a)
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

  --Shaman proxy thing
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
  self.FlagsConstructBldgs = false
  self.FlagsAutoBuild = false
  self.FlagsCheckObstacles = false

  return self
end

function ComputerPlayer:GetHutsCount()
  return gs.Players[self.PlayerNum].NumBuiltOrPartBuiltBuildingsOfType[1] + gs.Players[self.PlayerNum].NumBuiltOrPartBuiltBuildingsOfType[2] + gs.Players[self.PlayerNum].NumBuiltOrPartBuiltBuildingsOfType[3] + #_SHAPE_HUTS_BUFFER[self.PlayerNum]
end

function ComputerPlayer:GetShotsCount(spell)
  return gs.ThisLevelInfo.PlayerThings[self.PlayerNum].SpellsAvailableOnce[spell] & 15
end

function ComputerPlayer:GetOnGoingBuildings()
  return #_SHAPE_HUTS_BUFFER[self.PlayerNum]
  --return gs.Players[self.PlayerNum].NumBuildingMarkers
end

function ComputerPlayer:AnyWilds()
  return (#_WILD_BUFFER[self.PlayerNum] > 0)
end

function ComputerPlayer:Deactivate()
  self.isActive = false
end

function ComputerPlayer:Activate()
  self.isActive = true
end

-- X, Z, Angle, TicksBeforeChecking
--[[
  Viable angles:
  0 - South
  1 - West
  2 - North
  3 - East
]]
function ComputerPlayer:SetRebuildableTower(x, z, orient, ticks)
  local t_tower = AiTower:CreateTower(x, z, orient, self.PlayerNum, ticks)
  table.insert(_REBUILDABLE_TOWERS[self.PlayerNum], t_tower)
end

function ComputerPlayer:ProcessRebuildableTowers()
  if (self.isActive) then
    if (#_REBUILDABLE_TOWERS[self.PlayerNum] > 0) then
      for i,Tower in ipairs(_REBUILDABLE_TOWERS[self.PlayerNum]) do
        Tower:ProcessTower()
      end
    end
  end
end

function ComputerPlayer:ProcessConverting()
  if (self.isActive) then
    local pn = self.PlayerNum
    if (self.ShamanThingIdx.WildConvCount > 0) then
      self.ShamanThingIdx.WildConvCount = self.ShamanThingIdx.WildConvCount - 1
      goto process_wild_cd_skip
    end

    local proxy_wild = nil
    if (not self.ShamanThingIdx.WildTargetIdx:isNull()) then
      proxy_wild = self.ShamanThingIdx.WildTargetIdx:get()
      --goto process_wild_before
    end

    if (#_WILD_BUFFER[pn] == 0) then
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
      proxy_wild = wild

      ::process_wild_before::
      if (self:GetShotsCount(17) > 0 and (not self.ShamanThingIdx:isCastingSpell())) then
        if (get_world_dist_xyz(proxy_wild.Pos.D3, self.ShamanThingIdx.ProxyIdx:get().Pos.D3) < (8192 + math.ceil(self.ShamanThingIdx.ProxyIdx:get().Pos.D3.Ypos * 10))) then
          remove_all_persons_commands(self.ShamanThingIdx.ProxyIdx:get())
          self.ShamanThingIdx:GotoCastSpell(proxy_wild.Pos.D2, 17)
          self.ShamanThingIdx.WildConvCount = self.ShamanThingIdx.WildConvDelay
        else
          self.ShamanThingIdx:GotoC3d(proxy_wild.Pos.D3, false, 0)
        end
      end

      ::process_wild_skip::
    end
    ::process_wild_cd_skip::
  end
end

local function GotoBuild(_thing,shape,idx)
  --log("Sent building")
  _thing.Flags = _thing.Flags | (1<<4)
  local cmd = Commands.new()
  cmd.CommandType = 6
  cmd.u.TMIdxs.TargetIdx:set(shape.ThingNum)
  cmd.u.TMIdxs.MapIdx = world_coord2d_to_map_idx(cmd.u.TMIdxs.TargetIdx:get().Pos.D2)
  add_persons_command(_thing,cmd,idx)
end

function ComputerPlayer:ProcessShapes()
  if (self.isActive) then
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
      local t_brave = nil
      if (self.FlagsAutoBuild) then
        t_brave = ProcessGlobalSpecialList(pn, 0, function(t)
          if (t.Model == 2) then
            if (get_thing_curr_cmd_list_ptr(t) == nil) then
              return false
            end
          end
          return true
        end)
      end
      for i,shp in ipairs(_SHAPE_HUTS_BUFFER[pn]) do
        if (_SHAPE_HUTS_BUFFER[pn][i] == nil) then
          table.remove(_SHAPE_HUTS_BUFFER[pn], i)
          goto process_shape_skip
        end

        if (shp.Type ~= 9) then
          table.remove(_SHAPE_HUTS_BUFFER[pn], i)
          goto process_shape_skip
        end

        if (shp.Owner ~= pn) then
          table.remove(_SHAPE_HUTS_BUFFER[pn], i)
          goto process_shape_skip
        end

        if (not shp.u.Shape.BldgThingIdx:isNull()) then
          table.remove(_SHAPE_HUTS_BUFFER[pn], i)
          goto process_shape_skip
        end

        if (t_brave ~= nil) then
          if (shp.u.Shape.NumWorkers < 2) then
            GotoBuild(t_brave, shp, 0)
            t_brave = nil
          end
        end

        ::process_shape_skip::
      end
      if (t_brave ~= nil) then
        for j, twr in ipairs(_REBUILDABLE_TOWERS[pn]) do
          if (not twr.ShapeProxy:isNull()) then
            local tower = twr.ShapeProxy:get()
            if (tower.u.Shape.NumWorkers < 1) then
              GotoBuild(t_brave, tower, 0)
              t_brave = nil
              break
            end
          end
        end
      end
    end
  end
end

function ComputerPlayer:ProcessBuilding()
  if (self.isActive) then
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
          end

          table.remove(_BUILD_BUFFER_IDXES[pn], 1)
        end

        ::process_bldg_skip::
      end
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
          table.insert(_BUILD_BUFFER_IDXES[_pn],world_coord3d_to_map_idx(c_c3d))
        end
      end
    end
  end
end

function AddShapeToQueue(t,pn,bldgModel)
  if (bldgModel == 1) then
    table.insert(_SHAPE_HUTS_BUFFER[pn], t)
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