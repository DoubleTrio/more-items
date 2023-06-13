HELPERS = {}

---@param item_name string
---@param wild_chance number
---@param charm_chance number
---Adjusts the shiny rate for the entire dungeon when if the player has item.
function HELPERS.AdjustShinySpawnRate(item_name, wild_chance, charm_chance)
  local slot = GAME:FindPlayerItem(item_name, true, true)
  local chance = wild_chance
  if slot:IsValid() then
    chance = charm_chance
  end
  local skin_state = PMDC.Dungeon.SkinTableState(chance, "shiny", "shiny")
  -- NOTE: This line needs to be replaced with something more safer
  -- _DATA.UniversalEvent.UniversalStates:Set(skin_state)
end

---@param context BattleContext
---@param string_key string
---@param is_user boolean
---Logs the message for the single-use item
function HELPERS.LogSingleUseDungeonItem(context, string_key, is_user)
  local player = context.Target
  if is_user then player = context.User end
  local item = player.EquippedItem
  local player_display = player:GetDisplayName(true)
  local map_item = RogueEssence.Dungeon.MapItem(item)
  local msg = RogueEssence.StringKey(string_key):ToLocal()
  msg = string.gsub(msg, "%{0%}", player_display)
  msg = string.gsub(msg, "%{1%}", map_item:GetDungeonName())
  _DUNGEON:LogMsg(msg)
end