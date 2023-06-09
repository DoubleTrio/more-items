require 'constants'
require 'helpers'

ListType = luanet.import_type('System.Collections.Generic.List`1')
MobSpawnType = luanet.import_type('RogueEssence.LevelGen.MobSpawn')
DamageDealtType = luanet.import_type('PMDC.Dungeon.DamageDealt')
IDStateType = luanet.import_type('PMDC.Dungeon.IDState')
RecentStateType = luanet.import_type('PMDC.Dungeon.RecentState')
CountDownStateType = luanet.import_type('RogueEssence.Dungeon.CountDownState')

BATTLE_SCRIPT = {}

function BATTLE_SCRIPT.MonsterOrbEvent(owner, ownerChar, context, args)
  context.TurnCancel.Cancel = true
  local radius = 5
  local shiny_rate = CONSTANTS.MONSTER_HOUSE_SHINY_RATE

  if type(args.ShinyRate) == "number" then shiny_rate = args.ShinyRate end
  if type(args.Radius) == "number" then radius = args.Radius end

  local rect_area = RogueElements.Loc(1)
  local rect_area2 = RogueElements.Loc(3)

  function checkBlock(loc)
    local result = _ZONE.CurrentMap:TileBlocked(loc)
    return result
  end

  function checkDiagBlock(loc)
    return true
  end

  local origin = context.User.CharLoc

  local leftmost_x = math.maxinteger
  local rightmost_x = math.mininteger

  local downmost_y = math.mininteger
  local upmost_y = math.maxinteger

  local top_left = RogueElements.Loc(origin.X - radius, origin.Y - radius)
  local bottom_right =  RogueElements.Loc(origin.X + radius, origin.Y + radius)

  local valid_tile_total = 0
  for x = math.max(top_left.X, 0), math.min(bottom_right.X, _ZONE.CurrentMap.Width - 1), 1 do
    for y = math.max(top_left.Y, 0), math.min(bottom_right.Y, _ZONE.CurrentMap.Height - 1), 1 do
      local testLoc = RogueElements.Loc(x,y)
      local is_choke_point = RogueElements.Grid.IsChokePoint(testLoc - rect_area, rect_area2, testLoc, checkBlock, checkDiagBlock)
      local tile_block = _ZONE.CurrentMap:TileBlocked(testLoc)
      local char_at = _ZONE.CurrentMap:GetCharAtLoc(testLoc)

      if tile_block == false and char_at == nil and not is_choke_point then
        valid_tile_total = valid_tile_total + 1
        leftmost_x = math.min(testLoc.X, leftmost_x)
        rightmost_x = math.max(testLoc.X, rightmost_x)
        downmost_y = math.max(testLoc.Y, downmost_y)
        upmost_y = math.min(testLoc.Y, upmost_y)
      end
    end
  end

  local house_event = PMDC.Dungeon.MonsterHouseMapEvent()

  local tl = RogueElements.Loc(leftmost_x - 1, upmost_y - 1)
  local br =  RogueElements.Loc(rightmost_x + 1, downmost_y + 1)

  local bounds = RogueElements.Rect.FromPoints(tl, br)
  house_event.Bounds = bounds

  local min_enemies = math.floor(valid_tile_total / 5)
  local max_enemies = math.floor(valid_tile_total / 4)
  local total_enemies = _DATA.Save.Rand:Next(min_enemies, max_enemies)

  local all_spawns = LUA_ENGINE:MakeGenericType( ListType, { MobSpawnType }, { })
  for i = 0,  _ZONE.CurrentMap.TeamSpawns.Count - 1, 1 do
    local possible_spawns = _ZONE.CurrentMap.TeamSpawns:GetSpawn(i):GetPossibleSpawns()
    for j = 0, possible_spawns.Count - 1, 1 do
      local spawn = possible_spawns:GetSpawn(j)
      all_spawns:Add(spawn)
    end
  end

  if all_spawns.Count > 0 then
    for _ = 1, total_enemies, 1 do
      local randint = _DATA.Save.Rand:Next(0, all_spawns.Count)
      local spawn = all_spawns[randint]
      spawn.SpawnFeatures:Add(PMDC.LevelGen.MobSpawnAltColor(shiny_rate))
      house_event.Mobs:Add(spawn)
    end
  end

  if total_enemies > 0 and house_event.Mobs.Count > 0 then
    local charaContext = RogueEssence.Dungeon.SingleCharContext(context.User)
    TASK:WaitTask(house_event:Apply(owner, ownerChar, charaContext))
    GAME:WaitFrames(20)
  else
    GAME:WaitFrames(20)
    UI:WaitShowDialogue(RogueEssence.StringKey("MSG_NO_ENEMIES_SPAWN"):ToLocal())
    GAME:WaitFrames(20)
  end
end

---@param origin number
---@param radius number
---@param item_name string
---Returns the loc of the nearest item
local function NearestItemLoc(origin, radius, item_name)
  local x = 0
  local y = 0
  local dx, dy = 0, -1
  for _ = 1, radius ^ 2 do
    local testLoc = RogueElements.Loc(origin.X + x, origin.Y + y)
    local item_idx = _ZONE.CurrentMap:GetItem(testLoc)

    if item_idx ~= -1 then
      local item = _ZONE.CurrentMap.Items[item_idx]
      if item.Value == item_name then
        return testLoc
      end
    end

    if x == y or (x < 0 and x == -y) or (x > 0 and x == 1 - y) then
        dx, dy = -dy, dx
    end
    x, y = x + dx, y + dy
  end
end

function BATTLE_SCRIPT.NearestItemInRadius(owner, ownerChar, context, args)
  local item_name = args.Item
  local radius = CONSTANTS.MAX_RANGE

  if type(args.Radius) == "number" then radius = args.Radius end

  local origin = context.User.CharLoc
  local item_loc = NearestItemLoc(origin, radius, item_name)
  if item_loc == nil then
    context.CancelState.Cancel = true
    local inv_item = RogueEssence.Dungeon.InvItem(item_name)
    local map_item = RogueEssence.Dungeon.MapItem(inv_item)
    local msg = RogueEssence.StringKey("MSG_NO_WARP_ITEM"):ToLocal()

    msg = string.gsub(msg, "%{0%}", map_item:GetDungeonName())

    UI:WaitShowDialogue(msg)
  elseif item_loc == context.User.CharLoc then
    context.CancelState.Cancel = true
    UI:WaitShowDialogue(STRINGS:FormatKey("MSG_WARP_FAIL", context.User:GetDisplayName(true)))
  else
    local tbl = LTBL(context.User)
    tbl.ItemLoc = item_loc
  end
end

-- NOTE: This is paired along side with BATTLE_SCRIPT.NearestItemInRadius
function BATTLE_SCRIPT.WarpToItemEvent(owner, ownerChar, context, args)
  local tbl = LTBL(context.User)
  local item_loc = tbl.ItemLoc
  if item_loc ~= nil then
    TASK:WaitTask(_DUNGEON:WarpNear(context.User, item_loc, 0, true))
  end
  tbl.ItemLoc = nil
end

function BATTLE_SCRIPT.LogUseHeldItemEvent(owner, ownerChar, context, args)
  local key = "MSG_USE_ITEM"
  local is_user = false
  if type(args.Key) == "string" then key = args.Key end
  if type(args.IsUser) == "boolean" then is_user = args.IsUser end
  HELPERS.LogSingleUseDungeonItem(context, key, is_user)
end

function BATTLE_SCRIPT.SuperEffectiveCheckEvent(owner, ownerChar, context, args)
  local type_matchup = PMDC.Dungeon.PreTypeEvent.GetDualEffectiveness(context.User, context.Target, context.Data)
  type_matchup = type_matchup - PMDC.Dungeon.PreTypeEvent.NRM_2
  if args.Reverse then
    type_matchup = type_matchup * -1
  end

  local is_super_effective = type_matchup > 0
  local is_physical_attack = context.Data.Category == RogueEssence.Data.BattleData.SkillCategory.Physical
  local is_special_attack = context.Data.Category == RogueEssence.Data.BattleData.SkillCategory.Magical
  if is_super_effective and (is_physical_attack or is_special_attack) and not context.Target.Dead then
    --
  else
    context.CancelState.Cancel = true
  end
end

function BATTLE_SCRIPT.ElementCheckEvent(owner, ownerChar, context, args)
  local element = args.Element
  local is_physical_attack = context.Data.Category == RogueEssence.Data.BattleData.SkillCategory.Physical
  local is_special_attack = context.Data.Category == RogueEssence.Data.BattleData.SkillCategory.Magical
  if context.Data.Element == element and (is_physical_attack or is_special_attack) and not context.Target.Dead then
    -- 
  else
    context.CancelState.Cancel = true
  end
end

function BATTLE_SCRIPT.RemoveHeldItemEvent(owner, ownerChar, context, args)
  context.Target:SilentDequipItem()
end

function BATTLE_SCRIPT.AirBalloonEvent(owner, ownerChar, context, args)
  if context.ActionType == RogueEssence.Dungeon.BattleActionType.Skill or context.ActionType == RogueEssence.Dungeon.BattleActionType.Item then
    if context.Data.Category == RogueEssence.Data.BattleData.SkillCategory.Magical or context.Data.Category == RogueEssence.Data.BattleData.SkillCategory.Physical then
      HELPERS.LogSingleUseDungeonItem(context, "MSG_POP_ITEM", false)
      context.Target:SilentDequipItem()
    end
  end
end

function BATTLE_SCRIPT.EvioliteEvent(owner, ownerChar, context, args)
  --NOTE: A 50% decrease in damage was a bit powerful... 
  --This has been nerfed to 20%
  local DEFAULT_NUM = 20
  local DEFUALT_DENOM = 25

  local phy_num = DEFAULT_NUM
  local phy_denom = DEFUALT_DENOM

  local spec_num = DEFAULT_NUM
  local spec_denom = DEFUALT_DENOM

  if type(args.PhyNum) == "number" then p_num = args.PhyNum end
  if type(args.PhyDenom) == "number" then p_denom = args.PhyDenom end
  if type(args.SpecNum) == "number" then spec_num = args.SpecNum end
  if type(args.SpecDenom) == "number" then spec_denom = args.SpecDenom end
  local apply_effect = GAME:CanPromote(context.Target)
  if args.Reverse then apply_effect = (not apply_effect) end

  if apply_effect then
    local effects = {
      PMDC.Dungeon.MultiplyCategoryEvent(RogueEssence.Data.BattleData.SkillCategory.Physical, phy_num, phy_denom),
      PMDC.Dungeon.MultiplyCategoryEvent(RogueEssence.Data.BattleData.SkillCategory.Magical, spec_num, spec_denom)
    }

    for _, effect in pairs(effects) do
      TASK:WaitTask(effect:Apply(owner, ownerChar, context))
    end
  end
end

function BATTLE_SCRIPT.GemEvent(owner, ownerChar, context, args)
  local element = args.Element
  local DEFAULT_NUM = 15
  local DEFUALT_DENOM = 10

  local num = DEFAULT_NUM
  local denom = DEFUALT_DENOM
  if type(args.Numerator) == "number" then num = args.Numerator end
  if type(args.Denominator) == "number" then denom = args.Denominator end

  if context.Data.Element == element and (context.Data.Category == RogueEssence.Data.BattleData.SkillCategory.Magical or context.Data.Category == RogueEssence.Data.BattleData.SkillCategory.Physical) then
    HELPERS.LogSingleUseDungeonItem(context, "MSG_STENGTHEN_POWER", true)
    local multiply_element = PMDC.Dungeon.MultiplyDamageEvent(num, denom)
    TASK:WaitTask(multiply_element:Apply(owner, ownerChar, context))
    context.User:SilentDequipItem()
  end
end

function BATTLE_SCRIPT.FickleSpecsEvent(owner, ownerChar, context, args)
  local boost_rate = 2
  local reverse = false
  if type(args.BoostRate) == "number" then boost_rate = args.BoostRate end
  if type(args.Reverse) == "boolean" then reverse = args.Reverse end

  local move_status_id = "last_used_move"
  local move_repeat_status_id = "times_move_used"
  local move_status = context.User:GetStatusEffect(move_status_id)
  local repeat_status = context.User:GetStatusEffect(move_repeat_status_id)
  if move_status == nil or repeat_status == nil then
    return
  end
  local contains_move_id = move_status.StatusStates:Get(luanet.ctype(IDStateType)).ID == context.Data.ID
  if reverse then
    contains_move_id = not contains_move_id
  end

  if contains_move_id then
    return
  end
  if not repeat_status.StatusStates:Contains(luanet.ctype(RecentStateType)) then
    return
  end

  local effects = {
    PMDC.Dungeon.BoostCriticalEvent(boost_rate)
  }

  for _, effect in pairs(effects) do
    TASK:WaitTask(effect:Apply(owner, ownerChar, context))
  end
end